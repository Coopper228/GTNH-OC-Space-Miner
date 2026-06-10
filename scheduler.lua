-- Scheduler: scores asteroids and assigns each idle miner to its best target.
--
-- Score formula for an (asteroid) entry:
--   score = Σ( deficit_fraction(ore) × priority(ore) )
--   deficit_fraction = max(0, (target - current) / target)
--
-- Each idle miner is then sent to the highest-scoring asteroid it has a viable
-- drone for (best drone = highest chance%). Miners are NOT spread round-robin:
-- the most-needed asteroid takes priority for every miner.

local config = require("config")

local DEBUG = config.debug or false
local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

local M = {}

local DAMAGE_TO_VOLTAGE = {
    [0]  = "LV",  [1]  = "MV",  [2]  = "HV",  [3]  = "EV",
    [4]  = "IV",  [5]  = "LuV", [6]  = "ZPM", [7]  = "UV",
    [8]  = "UHV", [9]  = "UEV", [10] = "UIV", [11] = "UMV", [12] = "UXV",
}

-- Maps raw chest drone counts (by damage) to per-voltage availability.
-- The buffer chest is the single source of truth: a drone that is out working
-- is physically absent from the chest, so no in-use bookkeeping is needed here.
function M.buildVoltageCache(dronesByDamage)
    local cache = {}
    for dmg, count in pairs(dronesByDamage) do
        local v = DAMAGE_TO_VOLTAGE[dmg]
        if v then
            cache[v] = count
        end
    end
    return cache
end

local function oreDeficitScore(asteroidOres, oreAmounts)
    local total = 0
    for _, ore in ipairs(asteroidOres) do
        local data = oreAmounts[ore.label]
        if data and data.target > 0 and data.priority > 0 then
            local deficit  = math.max(0, data.target - data.current)
            local fraction = deficit / data.target
            total = total + fraction * data.priority
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
            bestChance   = info.chance
            bestVoltage  = voltage
            bestDistance = info.distance
        end
    end

    if bestVoltage then
        return { voltage = bestVoltage, distance = bestDistance, chance = bestChance }
    end
    return nil
end

-- Assigns each idle miner to the BEST asteroid it can currently mine.
--
-- "Best" = highest deficit×priority score among asteroids for which this miner
-- still has a viable drone in stock. Targets are NOT spread round-robin:
-- several miners may pile onto the single most-needed asteroid if that is where
-- they are most useful. Drone availability is decremented as miners are
-- assigned, so once a voltage runs out the next miner falls back to its next
-- best option (a lower-priority asteroid or a different drone tier).
function M.assignJobs(idleMiners, voltageCache, oreAmounts, oresByAsteroid, chanceTables)
    if #idleMiners == 0 then return {} end

    local scored = {}
    for asteroid, ores in pairs(oresByAsteroid) do
        local s = oreDeficitScore(ores, oreAmounts)
        if s > 0 then
            scored[#scored + 1] = { name = asteroid, score = s }
        end
    end

    if #scored == 0 then return {} end

    table.sort(scored, function(a, b) return a.score > b.score end)

    if DEBUG then
        dbg("Asteroid scores (%d active targets):", #scored)
        for i, s in ipairs(scored) do
            dbg("  #%-2d  %-30s  %.3f", i, s.name, s.score)
        end
    end

    local drones = {}
    for v, c in pairs(voltageCache) do drones[v] = c end

    local assignments = {}

    for _, miner in ipairs(idleMiners) do
        local ct = chanceTables[miner.data.minerLevel]
        if not ct then goto nextMiner end

        -- Walk targets from most- to least-needed; take the first one this
        -- miner has a drone for.
        for _, s in ipairs(scored) do
            local drone = bestDrone(ct, s.name, drones)
            if drone then
                assignments[#assignments + 1] = {
                    miner    = miner,
                    asteroid = s.name,
                    voltage  = drone.voltage,
                    distance = drone.distance,
                    chance   = drone.chance,
                }
                drones[drone.voltage] = drones[drone.voltage] - 1
                dbg("  assign %s → %s  drone=%s  chance=%.1f%%",
                    miner.data.minerLevel, s.name, drone.voltage, drone.chance)
                goto nextMiner
            end
        end

        dbg("  %s: no valid drone found for any target", miner.data.minerLevel)

        ::nextMiner::
    end

    return assignments
end

function M.allTargetsMet(oreAmounts)
    for _, data in pairs(oreAmounts) do
        if data.priority > 0 and data.current < data.target then
            return false
        end
    end
    return true
end

function M.asteroidStillNeeded(asteroid, oresByAsteroid, oreAmounts)
    local ores = oresByAsteroid[asteroid]
    if not ores then return false end
    for _, ore in ipairs(ores) do
        local data = oreAmounts[ore.label]
        if data and data.priority > 0 and data.current < data.target then
            return true
        end
    end
    return false
end

return M
