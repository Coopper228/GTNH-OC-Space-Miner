-- Auto-detects which ME Interface, Redstone I/O, and GT Miner belong together.
--
-- New topology: each miner is a triplet { ME Interface, Redstone I/O, Miner }.
-- Item flow is redstone-driven (no transposer): the program can no longer read
-- the Input Bus, so links are found purely by watching which miner activates.
--
-- A miner activates only when BOTH conditions hold simultaneously:
--   (1) its ME Interface is stocked with drone + tips + rods, AND
--   (2) its Redstone I/O signal is HIGH (so the pipe feeds the Input Bus).
--
-- Pass A — link interface→miner:
--   Hold ALL redstone signals HIGH, then stock interfaces ONE AT A TIME.
--   Only the stocked interface's bus fills, so only its miner lights up.
--
-- Pass B — link redstone→miner:
--   Stock ALL interfaces (signal LOW keeps items waiting in the interface),
--   then raise redstone signals ONE AT A TIME. Only that redstone's bus fills,
--   so only its miner lights up.
--
-- Joining the two passes on the miner address yields the full triplet.

local component = require("component")
local ae        = require("ae")
local config    = require("config")

local DEBUG = config.debug or false
local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

local M = {}

local CONFIG_FILE = config.miners_config or "/home/miners.lua"
local RS_ON       = config.redstone_on or 15
local STOCK_TIME  = config.search_stock_time or 3
local START_TIME  = config.search_start_time or 4
local DRAIN_TIME  = config.drain_time or 4
local POLL        = 0.1

local MINER_NAMES = {
    projectmoduleminert1 = true,
    projectmoduleminert2 = true,
    projectmoduleminert3 = true,
}

local SLOT_DRONE = 1
local SLOT_TIP   = 2
local SLOT_ROD   = 3

-- Generous amounts so a miner of any tier (cost up to 32) starts at least one
-- cycle during detection. Waste is irrelevant for a one-time search.
local TEST_DRONE = 1
local TEST_TIP   = 64
local TEST_ROD   = 64
local TEST_DIST  = 3

local function log(fmt, ...)
    print(string.format(fmt, ...))
end

local function serializeKV(tbl, indent)
    local out = ""
    for k, v in pairs(tbl) do
        local val = (type(v) == "string") and string.format("%q", v) or tostring(v)
        out = out .. string.format("%s%s = %s,\n", indent, k, val)
    end
    return out
end

-- Saved config shape: { miners = { triplets... }, drone = { buffer info } }.
local function serializeConfig(miners, drone)
    local out = "return {\n  miners = {\n"
    for _, e in ipairs(miners) do
        out = out .. "    {\n" .. serializeKV(e, "      ") .. "    },\n"
    end
    out = out .. "  },\n  drone = {\n" .. serializeKV(drone, "    ") .. "  },\n}\n"
    return out
end

-- ── Component discovery ─────────────────────────────────────────────────────

local function findComponents()
    local miners, ifaces, redstones = {}, {}, {}

    -- Miners are exposed through their MFU (a gt_machine proxy).
    for addr in component.list("gt_machine") do
        local p = component.proxy(addr)
        if p.getName and MINER_NAMES[p.getName()] then
            miners[#miners + 1] = { address = addr, proxy = p, name = p.getName() }
        end
    end

    for addr in component.list("me_interface") do
        ifaces[#ifaces + 1] = { address = addr, proxy = component.proxy(addr) }
    end

    for addr in component.list("redstone") do
        redstones[#redstones + 1] = { address = addr, proxy = component.proxy(addr) }
    end

    return miners, ifaces, redstones
end

-- ── Redstone & interface helpers ────────────────────────────────────────────

-- Emit the same signal on every side; 1 block = 1 miner, so the wired side is
-- irrelevant and outputting on all sides is the most robust choice.
local function setSignal(rs, value)
    for side = 0, 5 do rs.proxy.setOutput(side, value) end
end

local function setAllSignals(redstones, value)
    for _, rs in ipairs(redstones) do setSignal(rs, value) end
end

local function clearIface(iface)
    for i = 1, 9 do iface.proxy.setInterfaceConfiguration(i) end
end

local function clearAllIfaces(ifaces)
    for _, iface in ipairs(ifaces) do clearIface(iface) end
end

local function stockIface(iface, dbAddr, items)
    iface.proxy.setInterfaceConfiguration(SLOT_DRONE, dbAddr, items[1].dbSlot, TEST_DRONE)
    iface.proxy.setInterfaceConfiguration(SLOT_TIP,   dbAddr, items[2].dbSlot, TEST_TIP)
    iface.proxy.setInterfaceConfiguration(SLOT_ROD,   dbAddr, items[3].dbSlot, TEST_ROD)
end

-- Tell every miner to keep working so it activates the moment items arrive.
local function armMiners(miners)
    for _, m in ipairs(miners) do
        pcall(m.proxy.setParameters, 0, 0, TEST_DIST)
    end
end

-- Polls for an active miner that has not yet been linked in this pass.
-- Returns the miner (or nil after timeout).
local function waitForActiveMiner(miners, linked, timeout)
    local elapsed = 0
    while true do
        for _, m in ipairs(miners) do
            if not linked[m.address] and m.proxy.isMachineActive() then
                return m
            end
        end
        if elapsed >= timeout then return nil end
        os.sleep(POLL)
        elapsed = elapsed + POLL
    end
end

-- Drops all signals and clears all interfaces, then waits for every Input Bus
-- to drain back into its ME Interface.
local function drainAll(ifaces, redstones)
    clearAllIfaces(ifaces)
    setAllSignals(redstones, 0)
    os.sleep(DRAIN_TIME)
end

-- ── Pass A: interface → miner ───────────────────────────────────────────────

local function linkInterfaces(ifaces, miners, redstones, dbAddr, items)
    log("[Pass A] Linking %d interface(s) to miners...", #ifaces)

    setAllSignals(redstones, RS_ON)  -- every pipe ready to feed its bus

    local ifaceByMiner = {}   -- [minerAddr] = ifaceAddr
    local linked       = {}   -- [minerAddr] = true

    for idx, iface in ipairs(ifaces) do
        io.write(string.format("  [%d/%d] iface %s -> ", idx, #ifaces, iface.address:sub(1, 8)))

        stockIface(iface, dbAddr, items)
        armMiners(miners)        -- (re)allow work so the fed miner starts
        os.sleep(STOCK_TIME)

        local m = waitForActiveMiner(miners, linked, START_TIME)
        if m then
            io.write(m.name .. "\n")
            ifaceByMiner[m.address] = iface.address
            linked[m.address]       = true
        else
            io.write("no miner activated\n")
        end

        clearIface(iface)  -- stop stocking; its bus contents get consumed/drained later
    end

    drainAll(ifaces, redstones)
    return ifaceByMiner
end

-- ── Pass B: redstone → miner ────────────────────────────────────────────────

local function linkRedstones(ifaces, miners, redstones, dbAddr, items)
    log("[Pass B] Linking %d redstone I/O to miners...", #redstones)

    setAllSignals(redstones, 0)   -- signals low: stocked items wait in interfaces

    -- Stock every interface; with signals low the items stay in the interface
    -- and only flow once that interface's redstone goes high.
    for _, iface in ipairs(ifaces) do stockIface(iface, dbAddr, items) end
    os.sleep(STOCK_TIME)

    local redstoneByMiner = {}   -- [minerAddr] = redstoneAddr
    local linked          = {}   -- [minerAddr] = true

    for idx, rs in ipairs(redstones) do
        io.write(string.format("  [%d/%d] redstone %s -> ", idx, #redstones, rs.address:sub(1, 8)))

        armMiners(miners)        -- (re)allow work so the fed miner starts
        setSignal(rs, RS_ON)

        local m = waitForActiveMiner(miners, linked, START_TIME)
        if m then
            io.write(m.name .. "\n")
            redstoneByMiner[m.address] = rs.address
            linked[m.address]          = true
        else
            io.write("no miner activated\n")
        end

        setSignal(rs, 0)  -- drain this bus back before testing the next redstone
    end

    drainAll(ifaces, redstones)
    return redstoneByMiner
end

-- ── Drone buffer detection ──────────────────────────────────────────────────
--
-- The drone buffer is a single transposer sitting between a buffer chest and a
-- dedicated "drone interface" (the one ME interface NOT bound to any miner).
-- We detect:
--   * the transposer address           (the single transposer component)
--   * the drone interface address       (the spare, unlinked ME interface)
--   * the transposer side facing the chest and the side facing the interface
--
-- Sides are told apart by name and inventory size: an ME interface exposes a
-- small inventory, a chest exposes 27+ slots. This is independent of where the
-- drones currently sit, so it works even on the very first search.

local function classifySides(tp)
    local invSides = {}
    for side = 0, 5 do
        local size = tp.getInventorySize(side)
        if size and size > 0 then
            local name = tp.getInventoryName(side) or ""
            invSides[#invSides + 1] = { side = side, name = name, size = size }
        end
    end

    local ifaceSide, chestSide

    -- Prefer explicit name hints.
    for _, s in ipairs(invSides) do
        local lname = s.name:lower()
        if not ifaceSide and lname:find("interface") then ifaceSide = s.side end
        if not chestSide and lname:find("chest")     then chestSide = s.side end
    end

    -- Fall back to inventory size: the interface is the small inventory, the
    -- chest is the large one.
    if not ifaceSide then
        local smallest
        for _, s in ipairs(invSides) do
            if s.side ~= chestSide and (not smallest or s.size < smallest.size) then
                smallest = s
            end
        end
        if smallest then ifaceSide = smallest.side end
    end
    if not chestSide then
        local largest
        for _, s in ipairs(invSides) do
            if s.side ~= ifaceSide and (not largest or s.size > largest.size) then
                largest = s
            end
        end
        if largest then chestSide = largest.side end
    end

    return chestSide, ifaceSide, #invSides
end

local function detectDroneBuffer(ifaces, results)
    -- The drone interface is the one ME interface not bound to any miner.
    local used = {}
    for _, r in ipairs(results) do used[r.meInterfaceAddress] = true end
    local spare = {}
    for _, iface in ipairs(ifaces) do
        if not used[iface.address] then spare[#spare + 1] = iface.address end
    end
    if #spare ~= 1 then
        log("[search] WARNING: expected exactly 1 spare ME interface for the drone")
        log("[search]          buffer, found %d. Drone buffer NOT configured.", #spare)
        return nil
    end
    local droneIface = spare[1]

    -- There should be exactly one transposer in the whole system.
    local tpAddr
    for addr in component.list("transposer") do
        if tpAddr then
            log("[search] WARNING: multiple transposers found; using the first.")
            break
        end
        tpAddr = addr
    end
    if not tpAddr then
        log("[search] WARNING: no transposer found. Drone buffer NOT configured.")
        return nil
    end

    local chestSide, ifaceSide, nInv = classifySides(component.proxy(tpAddr))
    if not chestSide or not ifaceSide then
        log("[search] WARNING: could not identify chest/interface sides on the")
        log("[search]          transposer (found %d adjacent inventories). Check the build.", nInv)
        return nil
    end

    return {
        transposer    = tpAddr,
        interface     = droneIface,
        chestSide     = chestSide,
        interfaceSide = ifaceSide,
    }
end

-- ── Entry point ───────────────────────────────────────────────────────────────

function M.runSearch()
    local dbAddr = component.list("database")()
    if not dbAddr then error("[search] No Database Upgrade found!") end

    -- Use the shared LV test kit; dbSlots are already set by ae.initDatabase()
    -- (main runs it before search). Do NOT re-write the database here — that
    -- would clobber other tiers' slots.
    local items = ae.equipment["LV"]
    if not items or not items[1].dbSlot then error("[search] LV equipment not in database!") end

    local miners, ifaces, redstones = findComponents()
    log("[search] Found: %d interface(s), %d redstone I/O, %d miner(s)",
        #ifaces, #redstones, #miners)

    if #miners == 0    then log("[search] ERROR: No GT Miners (MFU) found.");        return end
    if #ifaces == 0    then log("[search] ERROR: No ME Interfaces found.");          return end
    if #redstones == 0 then log("[search] ERROR: No Redstone I/O blocks found.");    return end

    -- Full cleanup before starting: clear every interface and drop every signal
    -- so all Input Buses drain back into their ME Interfaces.
    log("[search] Deactivating all Redstone I/O and clearing interfaces...")
    drainAll(ifaces, redstones)

    local ifaceByMiner    = linkInterfaces(ifaces, miners, redstones, dbAddr, items)
    local redstoneByMiner = linkRedstones(ifaces, miners, redstones, dbAddr, items)

    -- Join both passes on the miner address.
    local results = {}
    for _, m in ipairs(miners) do
        local ifA = ifaceByMiner[m.address]
        local rsA = redstoneByMiner[m.address]
        if ifA and rsA then
            results[#results + 1] = {
                meInterfaceAddress = ifA,
                redstoneAddress    = rsA,
                minerAddress       = m.address,
                minerLevel         = m.name,
            }
        elseif ifA or rsA then
            log("[search] WARNING: miner %s linked to only %s — skipped.",
                m.address:sub(1, 8), ifA and "an interface" or "a redstone I/O")
        end
    end

    log("[search] Complete: %d / %d miner(s) fully linked.", #results, #miners)

    if #results == 0 then
        log("[search] No complete triplets found. Check power, pipes and connections.")
        return
    end

    local drone = detectDroneBuffer(ifaces, results)
    if not drone then
        log("[search] Config NOT saved (drone buffer missing). Fix the transposer/")
        log("[search] chest/drone-interface and re-run search.")
        return
    end
    log("[search] Drone buffer: transposer %s  chest side %d  iface side %d  iface %s",
        drone.transposer:sub(1, 8), drone.chestSide, drone.interfaceSide, drone.interface:sub(1, 8))

    local f = io.open(CONFIG_FILE, "w")
    f:write(serializeConfig(results, drone))
    f:close()
    log("[search] Config saved to %s", CONFIG_FILE)
end

return M
