-- GTNH Space Elevator Space Miner — Automation Controller
-- Run with: lua main.lua  (or set as autorun)
--
-- First launch: performs automatic miner discovery and saves miners_config.
-- Subsequent launches: loads saved config and starts mining immediately.
--
-- Item flow is redstone-driven: while a miner works the controller holds its
-- Redstone I/O signal HIGH (pipe feeds the Input Bus, AE2 keeps the interface
-- stocked); dropping the signal drains the bus back into the interface.

-- Clear module cache so edits to any file take effect without reboot.
for _, mod in ipairs({
    "config", "asteroids", "version", "updater",
    "equipment", "lookup", "scheduler", "dronebuffer", "mining", "search",
}) do
    package.loaded[mod] = nil
end

local component  = require("component")
local event      = require("event")
local filesystem = require("filesystem")
local term       = require("term")

local config      = require("config")
local asteroids   = require("asteroids")
local updater     = require("updater")
local equipment   = require("equipment")
local lookup      = require("lookup")
local scheduler   = require("scheduler")
local dronebuffer = require("dronebuffer")
local mining      = require("mining")
local search      = require("search")

-- ─── CONFIG ───────────────────────────────────────────────────────────────────
local ME_SCAN_INTERVAL = config.me_scan_interval or 60
local IDLE_SLEEP       = config.idle_sleep       or 300
local CONFIG_PATH      = config.miners_config    or "/home/miners.lua"
local DEBUG            = config.debug            or false
-- ──────────────────────────────────────────────────────────────────────────────

local function dbg(fmt, ...)
    if DEBUG then print("[DBG] " .. string.format(fmt, ...)) end
end

term.clear()
print("=== GTNH Space Miner Controller ===")
if DEBUG then print("[DBG] Debug mode enabled.") end
print()

-- Check GitHub for a newer release before doing anything else. No-op when
-- offline or already up to date; may prompt to update and reboot.
updater.check()

-- ── 1. SETUP ──────────────────────────────────────────────────────────────────

local dbAddr = equipment.initDatabase()

-- A saved config is valid only if it carries both the miner triplets and the
-- drone-buffer topology in the current format. An older config (a flat miner
-- list, or one missing the drone buffer) is treated as missing so a fresh
-- search regenerates it.
local function configIsValid(path)
    if not filesystem.exists(path) then return false end
    local ok, cfg = pcall(dofile, path)
    if not ok or type(cfg) ~= "table" then return false end

    local miners = cfg.miners
    if type(miners) ~= "table" or #miners == 0 then return false end
    for _, e in ipairs(miners) do
        if type(e) ~= "table"
                or not e.meInterfaceAddress
                or not e.redstoneAddress
                or not e.minerAddress
                or not e.minerLevel then
            return false
        end
    end

    local d = cfg.drone
    if type(d) ~= "table"
            or not d.transposer
            or not d.interface
            or d.chestSide == nil
            or d.interfaceSide == nil then
        return false
    end

    return true
end

if not configIsValid(CONFIG_PATH) then
    print("[setup] No valid " .. CONFIG_PATH .. ". Starting auto-detection...")
    print("[setup] Make sure all miners are powered and connected.")
    search.runSearch()
end

if not configIsValid(CONFIG_PATH) then
    error("[setup] Search failed: no valid miners config generated. Aborting.")
end

local savedConfig = dofile(CONFIG_PATH)
local minerList   = savedConfig.miners
local droneConfig = savedConfig.drone
print(string.format("[setup] Loaded %d miner(s) from config.", #minerList))

-- Overlay the configured ore targets onto the static asteroid catalog before
-- building the scan/scheduler lists.
asteroids.applyTargets(config.ore_targets)

local lookupList     = asteroids.buildLookupList()
local oresByAsteroid = asteroids.buildOresByAsteroid()

if #lookupList == 0 then
    print("[setup] WARNING: No ores have target > 0 in config.ore_targets.")
    print("        Set ore targets via the web configurator (or config.lua), then restart.")
end

local chanceTables = asteroids.chances

dronebuffer.init(droneConfig, dbAddr)
mining.init(minerList, dbAddr)
print()
print(string.format("[main] Tracking %d ore entries across %d asteroid types.",
    #lookupList, (function()
        local n = 0 for _ in pairs(oresByAsteroid) do n = n + 1 end return n
    end)()))
print(string.format("[main] ME scan every %ds  |  idle sleep %ds",
    ME_SCAN_INTERVAL, IDLE_SLEEP))
print("[main] Starting main loop. Press Ctrl+C to stop.")
print()

-- ── 2. MAIN LOOP ──────────────────────────────────────────────────────────────

local running    = true
local meTimer    = ME_SCAN_INTERVAL + 1  -- trigger scan immediately
local oreAmounts = {}
local voltCache  = {}

event.listen("interrupted", function() running = false end)

while running do

    -- ── 2a. Periodic ME scan ──────────────────────────────────────────────────
    if meTimer > ME_SCAN_INTERVAL then
        meTimer = 0

        -- Sweep any drones that drained back into the network (finished/aborted
        -- jobs) into the buffer chest FIRST, so the network is empty again and
        -- the chest count below is accurate. Must run before assignments so a
        -- drone injected later this round is never vacuumed.
        dronebuffer.vacuum(lookup.getAllDrones())

        -- The buffer chest is the source of truth for available drones.
        local rawDrones = dronebuffer.countDrones()
        voltCache = scheduler.buildVoltageCache(rawDrones)

        if DEBUG then
            local parts = {}
            for v, n in pairs(voltCache) do
                parts[#parts + 1] = v .. "=" .. n
            end
            table.sort(parts)
            dbg("Voltage cache: %s", table.concat(parts, "  "))
        end

        if #lookupList > 0 then
            if mining.hasFreeMiners() then
                oreAmounts = lookup.scanOreAmounts(lookupList)
            else
                local busy = mining.getBusyAsteroids()
                if #busy > 0 then
                    oreAmounts = lookup.scanOreAmountsFor(lookupList, busy)
                else
                    oreAmounts = {}
                end
            end

            if DEBUG then
                for label, d in pairs(oreAmounts) do
                    if d.priority > 0 then
                        dbg("Ore %-40s %d / %d (pri %d)",
                            label, d.current, d.target, d.priority)
                    end
                end
            end
        end

        -- ── 2b. Assign idle miners ────────────────────────────────────────────
        if mining.hasFreeMiners() and #lookupList > 0 then
            local idle        = mining.getIdleMiners()
            local assignments = scheduler.assignJobs(
                idle, voltCache, oreAmounts, oresByAsteroid, chanceTables)

            if #assignments > 0 then
                mining.applyAssignments(assignments)
                dbg("Assigned %d miner(s) this round.", #assignments)
            end
        end

        -- ── 2c. Sleep when nothing to do ─────────────────────────────────────
        if scheduler.allTargetsMet(oreAmounts) and #mining.getBusyAsteroids() == 0 then
            print(string.format("[ZZZ] All targets met. Sleeping %ds...", IDLE_SLEEP))
            os.sleep(IDLE_SLEEP)
            meTimer = ME_SCAN_INTERVAL + 1
        end
    end

    -- ── 2d. Mining tick ───────────────────────────────────────────────────────
    mining.tick(oreAmounts, oresByAsteroid)

    os.sleep(0.5)
    meTimer = meTimer + 0.5
end

-- Clean shutdown: drop every signal and clear every interface so all Input
-- Buses drain back into their ME Interfaces.
mining.deactivateAll()

print()
print("[main] Stopped. All Redstone I/O deactivated.")
