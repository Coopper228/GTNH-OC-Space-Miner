-- Mining controller: drone buffer + scheduler + per-miner state machine.
--
-- Item flow is redstone-driven. While a miner works its Redstone I/O is held
-- HIGH: the pipe feeds the Input Bus and AE2 keeps the ME Interface stocked with
-- tips/rods. Dropping the signal drains the bus back into the interface.
--
-- Drones are special: a miner needs exactly ONE, but they stack, so a stocked
-- ME Interface would let the pipe pull a whole stack while the signal is HIGH.
-- The buffer chest fixes this by keeping ZERO drones in the network at rest;
-- exactly one is injected just before a miner starts, so no more than one can
-- ever reach the bus. See the DRONE BUFFER section.

local component = require("component")
local ae        = require("ae")
local config    = require("config")

local DEBUG = config.debug or false
local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

local RS_ON       = config.redstone_on or 15
local DRAIN_TICKS = math.max(1, math.floor((config.drain_time or 4) * 2))
local DRONE_LOAD  = config.drone_load_time or 6
local DRONE_POLL  = config.drone_poll or 0.05
local OP_TIMEOUT  = config.drone_op_timeout or 2     -- upper bound for buffer polls

local SLOT_DRONE, SLOT_TIP, SLOT_ROD = 1, 2, 3
local STOCK_TIP, STOCK_ROD = 64, 64

local M = {}

-- ════════════════════════════════ DRONE BUFFER ════════════════════════════════
--
-- Hardware: one transposer touching a buffer chest and a dedicated "drone ME
-- interface" wired into the network.  chest --transposer-- drone-iface ~~ network
--
--   inject(voltage)  : chest -> drone-iface -> network   (exactly one drone)
--   reclaim()        : network -> drone-iface -> chest    (every stray drone)
--   chestDrones()    : authoritative count of available drones (reads the chest)
--
-- All operations verify against real state (chest reads / network reads) instead
-- of trusting fixed delays.

local buf = {}   -- { tp, iface, chestSide, ifaceSide, dbAddr, damageToDb }

-- Locate a chest slot holding a drone of the given damage tier. Returns slot|nil.
local function findChestDrone(dmg)
    local size = buf.tp.getInventorySize(buf.chestSide)
    for slot = 1, size do
        local st = buf.tp.getStackInSlot(buf.chestSide, slot)
        if st and st.name == ae.DRONE_ITEM and (st.damage or 0) == dmg and (st.size or 0) > 0 then
            return slot
        end
    end
    return nil
end

-- Available drones in the buffer chest, as { [damage] = count }.
local function chestDrones()
    local result = {}
    local size = buf.tp.getInventorySize(buf.chestSide)
    for slot = 1, size do
        local st = buf.tp.getStackInSlot(buf.chestSide, slot)
        if st and st.name == ae.DRONE_ITEM then
            local dmg = st.damage or 0
            result[dmg] = (result[dmg] or 0) + (st.size or 0)
        end
    end
    return result
end

-- Move exactly one drone of `voltage` from the chest into the network.
-- Returns true if a drone was moved out of the chest.
local function inject(voltage)
    local items = ae.equipment[voltage]
    if not items then dbg("inject: unknown voltage %s", tostring(voltage)); return false end
    local dmg = items[1].damage or 0

    local slot = findChestDrone(dmg)
    if not slot then dbg("inject: no %s drone in chest", voltage); return false end

    local moved = buf.tp.transferItem(buf.chestSide, buf.ifaceSide, 1, slot)
    if not moved or moved < 1 then dbg("inject: transfer failed for %s", voltage); return false end

    -- Confirm it imported into the network (usually instant). Not fatal if not
    -- seen — the miner-start poll is the real gate — but useful as a signal.
    local t = 0
    while t < OP_TIMEOUT do
        if (ae.getNetworkDrones()[dmg] or 0) >= 1 then return true end
        os.sleep(0.05); t = t + 0.05
    end
    dbg("inject: %s drone left chest but not seen in network within %ss", voltage, OP_TIMEOUT)
    return true
end

-- Pull every drone currently in the network back into the chest. Self-healing:
-- runs each scan, so drones that drained back after a job are reclaimed. Returns
-- the number of drones moved.
local function reclaim()
    local total = 0
    for _ = 1, 16 do                          -- bounded; handles >64 per tier
        local net = ae.getNetworkDrones()
        if next(net) == nil then break end

        local progressed = false
        for dmg in pairs(net) do
            local dbSlot = buf.damageToDb[dmg]
            if not dbSlot then
                dbg("reclaim: no db slot for drone damage %d", dmg)
            else
                -- Ask the drone interface to stock these drones from the network
                -- into its buffer, where the transposer can grab them.
                buf.iface.setInterfaceConfiguration(SLOT_DRONE, buf.dbAddr, dbSlot, 64)

                local t = 0
                while t < OP_TIMEOUT do
                    local st = buf.tp.getStackInSlot(buf.ifaceSide, SLOT_DRONE)
                    if st and st.name == ae.DRONE_ITEM and (st.damage or 0) == dmg then break end
                    os.sleep(0.05); t = t + 0.05
                end

                local moved = buf.tp.transferItem(buf.ifaceSide, buf.chestSide, 64, SLOT_DRONE) or 0
                buf.iface.setInterfaceConfiguration(SLOT_DRONE)   -- stop stocking

                if moved > 0 then total = total + moved; progressed = true end
            end
        end
        if not progressed then break end
    end
    if total > 0 then dbg("reclaim: returned %d drone(s) to chest", total) end
    return total
end

-- Verbose buffer diagnostics, printed at startup when debug is on, so problems
-- (wrong sides, drone name mismatch, broken import/export) are immediately visible.
local function diagnoseBuffer()
    print("[diag] Drone buffer:")
    print(string.format("[diag]   transposer %s", buf.tpAddr:sub(1, 8)))
    print(string.format("[diag]   chest side %d  '%s'  (%d slots)",
        buf.chestSide, buf.tp.getInventoryName(buf.chestSide) or "?", buf.tp.getInventorySize(buf.chestSide) or 0))
    print(string.format("[diag]   iface side %d  '%s'  (%d slots)",
        buf.ifaceSide, buf.tp.getInventoryName(buf.ifaceSide) or "?", buf.tp.getInventorySize(buf.ifaceSide) or 0))

    local chest = chestDrones()
    local n = 0
    for dmg, c in pairs(chest) do
        print(string.format("[diag]   chest: %s x%d", ae.voltageOfDamage[dmg] or ("dmg" .. dmg), c))
        n = n + 1
    end
    if n == 0 then print("[diag]   chest: NO drones (transposer can't see them, or wrong side, or name mismatch)") end

    local net = ae.getNetworkDrones()
    for dmg, c in pairs(net) do
        print(string.format("[diag]   network: %s x%d (will be reclaimed)", ae.voltageOfDamage[dmg] or ("dmg" .. dmg), c))
    end
end

local function bufInit(droneCfg, dbAddr)
    if not droneCfg then error("[mining] No drone buffer config!") end
    buf.tpAddr     = droneCfg.transposer
    buf.tp         = component.proxy(droneCfg.transposer)
    buf.iface      = component.proxy(droneCfg.interface)
    buf.chestSide  = droneCfg.chestSide
    buf.ifaceSide  = droneCfg.interfaceSide
    buf.dbAddr     = dbAddr
    buf.damageToDb = {}
    for _, items in pairs(ae.equipment) do
        local drone = items[1]
        if drone.dbSlot then buf.damageToDb[drone.damage or 0] = drone.dbSlot end
    end
    if not buf.tp    then error("[mining] Transposer proxy failed!") end
    if not buf.iface then error("[mining] Drone interface proxy failed!") end
    buf.iface.setInterfaceConfiguration(SLOT_DRONE)   -- clear any leftover stock request
end

-- Exposed for the main loop.
M.countDrones = chestDrones
M.reclaim     = reclaim

-- ═══════════════════════════════════ SCHEDULER ════════════════════════════════
--
-- Score(asteroid) = Σ deficitFraction(ore) × priority. Each idle miner is sent
-- to the highest-scoring asteroid it has a viable drone for (best = highest
-- chance%). Several miners may pile onto the same top asteroid.

-- chest drone counts (by damage) -> per-voltage availability.
function M.buildVoltageCache(dronesByDamage)
    local cache = {}
    for dmg, count in pairs(dronesByDamage) do
        local v = ae.voltageOfDamage[dmg]
        if v then cache[v] = count end
    end
    return cache
end

local function oreDeficitScore(asteroidOres, oreAmounts)
    local total = 0
    for _, ore in ipairs(asteroidOres) do
        local data = oreAmounts[ore.label]
        if data and data.target > 0 and data.priority > 0 then
            total = total + (math.max(0, data.target - data.current) / data.target) * data.priority
        end
    end
    return total
end

local function bestDrone(chanceTable, asteroidName, voltageCache)
    local entry = chanceTable[asteroidName]
    if not entry then return nil end
    local bestChance, bestVoltage, bestDistance = -1, nil, nil
    for voltage, info in pairs(entry) do
        if (voltageCache[voltage] or 0) > 0 and info.chance > bestChance then
            bestChance, bestVoltage, bestDistance = info.chance, voltage, info.distance
        end
    end
    if bestVoltage then
        return { voltage = bestVoltage, distance = bestDistance, chance = bestChance }
    end
    return nil
end

function M.assignJobs(idleMiners, voltageCache, oreAmounts, oresByAsteroid, chanceTables)
    if #idleMiners == 0 then return {} end

    local scored = {}
    for asteroid, ores in pairs(oresByAsteroid) do
        local s = oreDeficitScore(ores, oreAmounts)
        if s > 0 then scored[#scored + 1] = { name = asteroid, score = s } end
    end
    if #scored == 0 then return {} end
    table.sort(scored, function(a, b) return a.score > b.score end)

    local drones = {}
    for v, c in pairs(voltageCache) do drones[v] = c end

    local assignments = {}
    for _, miner in ipairs(idleMiners) do
        local ct = chanceTables[miner.data.minerLevel]
        if ct then
            for _, s in ipairs(scored) do
                local drone = bestDrone(ct, s.name, drones)
                if drone then
                    assignments[#assignments + 1] = {
                        miner = miner, asteroid = s.name,
                        voltage = drone.voltage, distance = drone.distance, chance = drone.chance,
                    }
                    drones[drone.voltage] = drones[drone.voltage] - 1
                    dbg("assign %s -> %s  drone=%s  %.1f%%",
                        miner.data.minerLevel, s.name, drone.voltage, drone.chance)
                    break
                end
            end
        end
    end
    return assignments
end

function M.allTargetsMet(oreAmounts)
    for _, data in pairs(oreAmounts) do
        if data.priority > 0 and data.current < data.target then return false end
    end
    return true
end

function M.asteroidStillNeeded(asteroid, oresByAsteroid, oreAmounts)
    local ores = oresByAsteroid[asteroid]
    if not ores then return false end
    for _, ore in ipairs(ores) do
        local data = oreAmounts[ore.label]
        if data and data.priority > 0 and data.current < data.target then return true end
    end
    return false
end

-- ═════════════════════════════ PER-MINER STATE MACHINE ════════════════════════
--
-- IDLE -> WORKING -> STOPPING -> IDLE

local miners = {}

local function setSignal(miner, value)
    for side = 0, 5 do miner.proxies.redstone.setOutput(side, value) end
end

-- voltage=nil -> clear slots 1..3. wantDrone toggles the drone request only;
-- tips/rods are always requested for the given voltage.
local function configureInterface(miner, voltage, wantDrone)
    local iface = miner.proxies.iface
    if not voltage then
        iface.setInterfaceConfiguration(SLOT_DRONE)
        iface.setInterfaceConfiguration(SLOT_TIP)
        iface.setInterfaceConfiguration(SLOT_ROD)
        return
    end
    local items = ae.equipment[voltage]
    if wantDrone then
        iface.setInterfaceConfiguration(SLOT_DRONE, miner.dbAddr, items[1].dbSlot, 1)
    else
        iface.setInterfaceConfiguration(SLOT_DRONE)
    end
    iface.setInterfaceConfiguration(SLOT_TIP, miner.dbAddr, items[2].dbSlot, STOCK_TIP)
    iface.setInterfaceConfiguration(SLOT_ROD, miner.dbAddr, items[3].dbSlot, STOCK_ROD)
end

local function mid(miner)
    return miner.data.minerLevel .. ":" .. miner.data.minerAddress:sub(1, 4)
end

function M.init(minerList, dbAddr, droneCfg)
    if not dbAddr then error("[mining] No database address!") end
    bufInit(droneCfg, dbAddr)

    miners = {}
    for _, data in ipairs(minerList) do
        local miner = {
            data = data, dbAddr = dbAddr, state = "IDLE", timer = 0, currentJob = nil,
            proxies = {
                iface    = component.proxy(data.meInterfaceAddress),
                redstone = component.proxy(data.redstoneAddress),
                machine  = component.proxy(data.minerAddress),
            },
        }
        setSignal(miner, 0)
        configureInterface(miner, nil)
        miners[#miners + 1] = miner
    end
    print(string.format("[mining] Initialized %d miner(s). Buses draining...", #miners))
    os.sleep(config.drain_time or 4)

    -- Consolidate every drone (network + just-drained buses) into the chest so we
    -- start from the clean "zero drones in network" state.
    local moved = reclaim()
    print(string.format("[mining] Drone buffer ready. Consolidated %d drone(s) into the chest.", moved))
    if DEBUG then diagnoseBuffer() end
end

function M.getMiners() return miners end

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
        if miner.state == "IDLE" then
            miner.currentJob = { asteroid = a.asteroid, voltage = a.voltage, distance = a.distance, chance = a.chance }
            print(string.format("[%s] -> %s @ %s (%.1f%%)",
                miner.data.minerLevel, a.asteroid, a.voltage, a.chance))

            -- Put exactly one drone of this tier into the network. With only one
            -- present the pipe cannot flood the bus.
            if not inject(a.voltage) then
                print(string.format("[WARN] %s: no %s drone available — skipping.",
                    miner.data.minerLevel, a.voltage))
                miner.currentJob = nil
            else
                pcall(miner.proxies.machine.setParameters, 0, 0, a.distance)
                configureInterface(miner, a.voltage, true)
                setSignal(miner, RS_ON)

                local elapsed, activated = 0, false
                while elapsed < DRONE_LOAD do
                    if miner.proxies.machine.isMachineActive() then activated = true; break end
                    os.sleep(DRONE_POLL); elapsed = elapsed + DRONE_POLL
                end

                configureInterface(miner, a.voltage, false)   -- drop drone request, keep supplies

                if activated then
                    miner.state, miner.timer = "WORKING", 0
                    dbg("%s IDLE->WORKING  %s  dist=%d  (%.2fs)", mid(miner), a.asteroid, a.distance, elapsed)
                else
                    print(string.format("[WARN] %s: miner did not start for %s — releasing.",
                        miner.data.minerLevel, a.asteroid))
                    setSignal(miner, 0)
                    configureInterface(miner, nil)
                    miner.currentJob, miner.state, miner.timer = nil, "STOPPING", 0
                end
            end
        end
    end
end

function M.tick(oreAmounts, oresByAsteroid)
    for _, miner in ipairs(miners) do
        if miner.state == "WORKING" then
            if oreAmounts and oresByAsteroid
                    and not M.asteroidStillNeeded(miner.currentJob.asteroid, oresByAsteroid, oreAmounts) then
                print("[DONE] " .. miner.currentJob.asteroid)
                setSignal(miner, 0)
                configureInterface(miner, nil)
                miner.state, miner.timer = "STOPPING", 0
                dbg("%s WORKING->STOPPING  %s", mid(miner), miner.currentJob.asteroid)
            end
        elseif miner.state == "STOPPING" then
            miner.timer = miner.timer + 1
            if miner.timer >= DRAIN_TICKS then
                miner.currentJob, miner.state = nil, "IDLE"
                dbg("%s STOPPING->IDLE", mid(miner))
            end
        end
    end
end

-- Drops every signal and clears every interface (shutdown / pre-search).
function M.deactivateAll()
    for _, miner in ipairs(miners) do
        setSignal(miner, 0)
        configureInterface(miner, nil)
        miner.currentJob, miner.state = nil, "IDLE"
    end
end

return M
