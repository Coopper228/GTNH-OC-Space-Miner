-- Per-miner state machine (redstone-driven item flow).
--
-- States: IDLE → WORKING → STOPPING → IDLE
--
-- Unlike the old transposer design, the program no longer shuffles items.
-- While a miner works the program just holds its Redstone I/O signal HIGH:
-- the pipe feeds the Input Bus and AE2 keeps the ME Interface stocked, so
-- tips/rods are replenished automatically. Stopping = drop the signal and
-- clear the interface; the pipe then drains the bus back into the interface.
--
-- Drone handling is special. A drone is a reusable tool — the miner needs
-- exactly ONE — but drones are stackable, so while the signal is HIGH the pipe
-- would keep pulling fresh drones into the bus as long as the ME network has
-- drones for AE2 to re-stock the interface with. The fix lives in dronebuffer:
-- drones rest in a buffer chest, the network holds ZERO at rest, and on
-- assignment we inject exactly ONE drone into the network. With only one in the
-- network the pipe physically cannot pull more, so flooding is impossible. We
-- still poll isMachineActive() to confirm the start and then clear the drone
-- request, but the timing is no longer critical — the buffer chest, not the
-- poll speed, is what guarantees a single drone.

local component   = require("component")
local equipment   = require("equipment")
local scheduler   = require("scheduler")
local config      = require("config")
local dronebuffer = require("dronebuffer")

local RS_ON       = config.redstone_on or 15
local DRAIN_TICKS = math.max(1, math.floor((config.drain_time or 4) * 2))
local DRONE_LOAD  = config.drone_load_time or 6
local DRONE_POLL  = config.drone_poll or 0.05

local DEBUG = config.debug or false
local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

local SLOT_DRONE = 1
local SLOT_TIP   = 2
local SLOT_ROD   = 3

-- How many tips/rods to keep requested in the interface. AE2 maintains this
-- buffer and the pipe pushes it into the bus on demand.
local STOCK_DRONE = 1
local STOCK_TIP   = 64
local STOCK_ROD   = 64

local M = {}
local miners = {}

-- === PRIVATE HELPERS ===

-- Emit the same signal on all sides (1 block = 1 miner, wired side irrelevant).
local function setSignal(miner, value)
    for side = 0, 5 do miner.proxies.redstone.setOutput(side, value) end
end

-- Configures the ME Interface.
--   voltage = nil        → clear slots 1..3 (stock nothing)
--   wantDrone = true     → request 1 drone in slot 1
--   wantDrone = false    → clear slot 1 (drone already loaded), keep supplies
-- Tips/rods are always requested for the given voltage.
local function configureInterface(miner, voltage, wantDrone)
    local iface  = miner.proxies.iface
    local dbAddr = miner.dbAddr

    if not voltage then
        iface.setInterfaceConfiguration(SLOT_DRONE)
        iface.setInterfaceConfiguration(SLOT_TIP)
        iface.setInterfaceConfiguration(SLOT_ROD)
        return
    end

    local items = equipment.equipmentTable[voltage]

    if wantDrone then
        iface.setInterfaceConfiguration(SLOT_DRONE, dbAddr, items[1].dbSlot, STOCK_DRONE)
    else
        iface.setInterfaceConfiguration(SLOT_DRONE)
    end
    iface.setInterfaceConfiguration(SLOT_TIP, dbAddr, items[2].dbSlot, STOCK_TIP)
    iface.setInterfaceConfiguration(SLOT_ROD, dbAddr, items[3].dbSlot, STOCK_ROD)
end

local function mid(miner)
    return miner.data.minerLevel .. ":" .. miner.data.minerAddress:sub(1, 4)
end

-- === PUBLIC API ===

function M.init(minerList, dbAddr)
    if not dbAddr then error("[mining] No database address!") end
    miners = {}

    for _, data in ipairs(minerList) do
        local miner = {
            data       = data,
            dbAddr     = dbAddr,
            state      = "IDLE",
            timer      = 0,
            currentJob = nil,
            proxies    = {
                iface    = component.proxy(data.meInterfaceAddress),
                redstone = component.proxy(data.redstoneAddress),
                machine  = component.proxy(data.minerAddress),
            },
        }
        -- Clean slate: drop the signal and clear the interface so any items
        -- still in the bus drain back before the first assignment.
        setSignal(miner, 0)
        configureInterface(miner, nil)
        miners[#miners + 1] = miner
    end

    print(string.format("[mining] Initialized %d miner(s). Buses draining...", #miners))
    os.sleep(config.drain_time or 4)
end

function M.getMiners()    return miners end

function M.getIdleMiners()
    local idle = {}
    for _, m in ipairs(miners) do
        if m.state == "IDLE" then idle[#idle + 1] = m end
    end
    return idle
end

function M.getBusyAsteroids()
    local list = {}
    for _, m in ipairs(miners) do
        if m.currentJob then list[#list + 1] = m.currentJob.asteroid end
    end
    return list
end

function M.hasFreeMiners()
    for _, m in ipairs(miners) do
        if m.state == "IDLE" then return true end
    end
    return false
end

function M.applyAssignments(assignments)
    for _, a in ipairs(assignments) do
        local miner = a.miner
        if miner.state ~= "IDLE" then goto continue end

        miner.currentJob = {
            asteroid = a.asteroid,
            voltage  = a.voltage,
            distance = a.distance,
            chance   = a.chance,
        }

        print(string.format("[%s] -> %s @ %s (%.1f%%)",
            miner.data.minerLevel, a.asteroid, a.voltage, a.chance))

        -- Put exactly ONE drone of this tier into the ME network (from the
        -- buffer chest). If none is available, release the miner cleanly. This
        -- is what makes flooding impossible: the network never holds more than
        -- the single drone we just injected.
        if not dronebuffer.inject(a.voltage) then
            print(string.format("[WARN] %s: no %s drone in buffer chest — skipping.",
                miner.data.minerLevel, a.voltage))
            miner.currentJob = nil
            goto continue
        end

        -- Set distance, request drone + supplies, then raise the signal so the
        -- pipe feeds the bus and the miner starts on its own.
        pcall(miner.proxies.machine.setParameters, 0, 0, a.distance)
        configureInterface(miner, a.voltage, true)
        setSignal(miner, RS_ON)

        -- Drone handshake: poll tightly until the miner activates, which means
        -- its one drone is already in the bus, then immediately clear the drone
        -- request so the stackable drones stop pouring in. Supplies stay
        -- requested so tips/rods keep topping up.
        local elapsed   = 0
        local activated = false
        while elapsed < DRONE_LOAD do
            if miner.proxies.machine.isMachineActive() then activated = true; break end
            os.sleep(DRONE_POLL)
            elapsed = elapsed + DRONE_POLL
        end

        configureInterface(miner, a.voltage, false)  -- drop drone request, keep supplies

        if activated then
            miner.state = "WORKING"
            miner.timer = 0
            dbg("%s IDLE→WORKING  asteroid=%s  dist=%d  (drone loaded in %.2fs)",
                mid(miner), a.asteroid, a.distance, elapsed)
        else
            -- Never started (no drone available, no power, etc.). Abort cleanly:
            -- drop the signal and clear the interface so the bus drains back.
            print(string.format("[WARN] %s: miner did not start for %s — releasing.",
                miner.data.minerLevel, a.asteroid))
            setSignal(miner, 0)
            configureInterface(miner, nil)
            miner.currentJob = nil
            miner.state      = "STOPPING"
            miner.timer      = 0
        end

        ::continue::
    end
end

function M.tick(oreAmounts, oresByAsteroid)
    for _, miner in ipairs(miners) do

        -- ── WORKING ────────────────────────────────────────────────────────────
        if miner.state == "WORKING" then
            if oreAmounts and oresByAsteroid then
                if not scheduler.asteroidStillNeeded(
                        miner.currentJob.asteroid, oresByAsteroid, oreAmounts) then
                    print("[DONE] " .. miner.currentJob.asteroid)
                    -- Stop feeding and clear the request; the bus drains back.
                    setSignal(miner, 0)
                    configureInterface(miner, nil)
                    miner.state = "STOPPING"
                    miner.timer = 0
                    dbg("%s WORKING→STOPPING  asteroid=%s", mid(miner), miner.currentJob.asteroid)
                end
            end

        -- ── STOPPING ───────────────────────────────────────────────────────────
        -- Wait for the bus to drain back into the interface before reusing the
        -- miner, so leftover tips/rods do not restart it under a new job.
        elseif miner.state == "STOPPING" then
            miner.timer = miner.timer + 1
            if miner.timer >= DRAIN_TICKS then
                miner.currentJob = nil
                miner.state      = "IDLE"
                dbg("%s STOPPING→IDLE", mid(miner))
            end
        end
    end
end

-- Drops every miner's signal and clears every interface. Used on shutdown and
-- before a fresh search so all Input Buses drain.
function M.deactivateAll()
    for _, miner in ipairs(miners) do
        setSignal(miner, 0)
        configureInterface(miner, nil)
        miner.currentJob = nil
        miner.state      = "IDLE"
    end
end

return M
