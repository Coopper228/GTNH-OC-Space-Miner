-- Drone buffer chest — solves the "stackable drone flood" problem.
--
-- The problem: a miner needs exactly ONE drone, but drones are stackable and
-- the pipe feeding the Input Bus keeps pulling whatever the ME Interface stocks
-- while the redstone signal is HIGH. As long as drones exist in the ME network,
-- AE2 re-stocks the interface slot the instant the pipe drains it, so the bus
-- fills with a whole stack of drones — wasting stock and corrupting the
-- scheduler's drone count.
--
-- The fix: keep ZERO drones in the ME network at rest. All drones live in a
-- dedicated buffer chest, reachable only through a single transposer that also
-- touches a dedicated "drone interface" wired into the ME network:
--
--     [ buffer chest ] -- transposer -- [ drone ME interface ] ~~ ME network
--
-- To start a miner we transposer exactly ONE drone of the wanted tier from the
-- chest into the drone interface; AE2 imports it, so the network now holds
-- exactly one. The per-miner interface stocks it, the pipe pulls it (only one
-- exists, so only one can be pulled), the miner activates, and the network is
-- empty again. Nothing can flood because there is never more than one drone in
-- the network at a time.
--
-- After a job ends the miner's drone drains back into its ME interface and thus
-- into the network. vacuum() sweeps any such stray drones from the drone
-- interface back into the chest, restoring the zero-in-network invariant. It is
-- self-healing: whatever ends up in the network is returned to the chest on the
-- next pass.
--
-- The chest is the single source of truth for "how many drones of each tier do
-- we have available" — see countDrones().

local component = require("component")
local equipment = require("equipment")
local config    = require("config")

local DEBUG = config.debug or false
local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

-- Seconds to wait for AE2 to import the injected drone into the network, or to
-- export a vacuumed drone out of the interface. Item movement through an
-- interface is not instantaneous.
local SETTLE = config.drone_settle_time or 1.5

local DRONE_ITEM = "gtnhintergalactic:item.MiningDrone"

local M = {}

-- Runtime state, filled by init().
local tp          = nil   -- transposer proxy
local iface       = nil   -- drone ME interface proxy (for recovery stocking)
local chestSide   = nil   -- transposer side facing the buffer chest
local ifaceSide   = nil   -- transposer side facing the drone ME interface
local dbAddr      = nil   -- shared database address (for store/compare)
local damageToDb  = {}    -- [drone damage value] = database slot

-- Interface config slot used for recovery stocking (the drone interface is
-- dedicated, so any slot is free).
local RECOVER_SLOT = 1

-- === PRIVATE HELPERS ===

-- Build a map from each drone's damage value to its database slot, so we can
-- ask the transposer to compare/move a specific drone tier. Reuses the slots
-- equipment.initDatabase() already filled in.
local function buildDamageMap()
    local map = {}
    for _, items in pairs(equipment.equipmentTable) do
        local drone = items[1]
        if drone.id == DRONE_ITEM and drone.dbSlot then
            map[drone.damage or 0] = drone.dbSlot
        end
    end
    return map
end

-- === PUBLIC API ===

-- droneCfg = { transposer, chestSide, interfaceSide, interface }
function M.init(droneCfg, sharedDbAddr)
    if not droneCfg then error("[dronebuffer] No drone buffer config!") end
    if not sharedDbAddr then error("[dronebuffer] No database address!") end

    tp        = component.proxy(droneCfg.transposer)
    iface     = component.proxy(droneCfg.interface)
    chestSide = droneCfg.chestSide
    ifaceSide = droneCfg.interfaceSide
    dbAddr    = sharedDbAddr
    damageToDb = buildDamageMap()

    if not tp    then error("[dronebuffer] Transposer proxy failed!") end
    if not iface then error("[dronebuffer] Drone interface proxy failed!") end

    -- Make sure no leftover stock request lingers on the drone interface, so
    -- injected drones import cleanly into the network.
    iface.setInterfaceConfiguration(RECOVER_SLOT)

    print(string.format("[dronebuffer] Ready (transposer %s, chest side %d, iface side %d).",
        droneCfg.transposer:sub(1, 8), chestSide, ifaceSide))
end

-- Counts drones currently in the buffer chest, grouped by damage value.
-- This is the authoritative "available drones" figure: a drone that is out
-- working is physically absent from the chest. Returns { [damage] = count }.
function M.countDrones()
    local result = {}
    local size = tp.getInventorySize(chestSide)
    for slot = 1, size do
        local stack = tp.getStackInSlot(chestSide, slot)
        if stack and stack.name == DRONE_ITEM then
            local dmg = stack.damage or 0
            result[dmg] = (result[dmg] or 0) + (stack.size or 0)
        end
    end
    return result
end

-- Moves exactly ONE drone of the given voltage tier from the chest into the
-- drone interface, so AE2 imports it and the network holds exactly one.
-- Returns true on success. Caller should wait for it to reach the network
-- (inject() already sleeps SETTLE before returning).
function M.inject(voltage)
    local items = equipment.equipmentTable[voltage]
    if not items then
        dbg("inject: unknown voltage %s", tostring(voltage))
        return false
    end
    local drone = items[1]
    local dmg   = drone.damage or 0
    local dbSlot = damageToDb[dmg]
    if not dbSlot then
        dbg("inject: no db slot for drone damage %d (%s)", dmg, voltage)
        return false
    end

    -- Find a chest slot holding this exact drone tier and move one out of it.
    -- Match by item id + damage (the tier meta); NBT such as durability is
    -- intentionally ignored so worn drones still match.
    local size = tp.getInventorySize(chestSide)
    for slot = 1, size do
        local st = tp.getStackInSlot(chestSide, slot)
        if st and st.name == DRONE_ITEM and (st.damage or 0) == dmg and (st.size or 0) > 0 then
            local moved = tp.transferItem(chestSide, ifaceSide, 1, slot)
            if moved and moved > 0 then
                dbg("inject: moved 1x %s drone (dmg %d) chest->iface", voltage, dmg)
                os.sleep(SETTLE)  -- let AE2 import it into the network
                return true
            end
        end
    end

    dbg("inject: no %s drone (dmg %d) found in chest", voltage, dmg)
    return false
end

-- Recovers a single drone tier from the ME network into the chest: stock it on
-- the drone interface so AE2 pulls it from storage into the interface buffer,
-- sweep the buffer into the chest, then clear the stock request. Returns the
-- number recovered.
local function recoverTier(dmg, count)
    local dbSlot = damageToDb[dmg]
    if not dbSlot then return 0 end

    -- Request the drones into the interface buffer where the transposer can
    -- reach them. Cap at a stack — vacuum runs every scan, so any overflow is
    -- caught on the next pass.
    iface.setInterfaceConfiguration(RECOVER_SLOT, dbAddr, dbSlot, math.min(count, 64))
    os.sleep(SETTLE)

    local total = 0
    local size = tp.getInventorySize(ifaceSide)
    for slot = 1, size do
        local st = tp.getStackInSlot(ifaceSide, slot)
        if st and st.name == DRONE_ITEM and (st.damage or 0) == dmg then
            total = total + (tp.transferItem(ifaceSide, chestSide, 64, slot) or 0)
        end
    end

    iface.setInterfaceConfiguration(RECOVER_SLOT)  -- stop stocking
    return total
end

-- Sweeps every drone that has drained back into the ME network (from finished
-- or aborted jobs) back into the chest, restoring the zero-drones-in-network
-- invariant. `networkDrones` is { [damage] = count } as read from the network
-- (see lookup.getAllDrones). Called at the start of each scan, BEFORE any
-- assignment, so a drone injected later in the same round is never swept up.
-- Returns the total number of drones returned to the chest.
function M.vacuum(networkDrones)
    if not networkDrones then return 0 end

    local total = 0
    for dmg, count in pairs(networkDrones) do
        if count > 0 then
            total = total + recoverTier(dmg, count)
        end
    end

    if total > 0 then
        dbg("vacuum: returned %d stray drone(s) to chest", total)
    end
    return total
end

return M
