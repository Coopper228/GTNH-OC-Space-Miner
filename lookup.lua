-- ME network queries: item amounts and drone inventory.

local component = require("component")

local me = (function()
    local addr = component.list("me_controller")()
    if not addr then error("[lookup] ME Controller not found!") end
    return component.proxy(addr)
end)()

local DRONE_ITEM_NAME = "gtnhintergalactic:item.MiningDrone"

local M = {}

-- Returns total count of a specific item by display label.
function M.getCurrentAmount(label)
    local items = me.getItemsInNetwork({ label = label }) or {}
    local total = 0
    for _, item in ipairs(items) do
        total = total + (item.size or 0)
    end
    return total
end

-- Returns all mining drones as { [damage_value] = count }.
-- One ME request covers every drone tier simultaneously.
function M.getAllDrones()
    local result = {}
    local items  = me.getItemsInNetwork({ name = DRONE_ITEM_NAME }) or {}
    for _, item in ipairs(items) do
        local dmg = item.damage or 0
        result[dmg] = (result[dmg] or 0) + (item.size or 0)
    end
    return result
end

-- Scans every tracked ore and returns per-label current amounts.
-- Returns { [label] = { current, target, priority } }
function M.scanOreAmounts(lookupList)
    local result = {}
    for _, entry in ipairs(lookupList) do
        local lbl = entry.label
        if not result[lbl] then
            result[lbl] = {
                current  = M.getCurrentAmount(lbl),
                target   = entry.target,
                priority = entry.priority,
            }
        end
    end
    return result
end

-- Targeted scan: only check ores belonging to the given asteroid names.
-- Returns the same structure as scanOreAmounts but only for listed asteroids.
function M.scanOreAmountsFor(lookupList, asteroidNames)
    local nameSet = {}
    for _, n in ipairs(asteroidNames) do nameSet[n] = true end

    local result = {}
    for _, entry in ipairs(lookupList) do
        if nameSet[entry.asteroid] then
            local lbl = entry.label
            if not result[lbl] then
                result[lbl] = {
                    current  = M.getCurrentAmount(lbl),
                    target   = entry.target,
                    priority = entry.priority,
                }
            end
        end
    end
    return result
end

return M
