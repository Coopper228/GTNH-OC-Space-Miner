-- AE2 / ME network layer: equipment definitions, database setup, item queries.

local component = require("component")

local M = {}

M.DRONE_ITEM = "gtnhintergalactic:item.MiningDrone"

-- Drone, drill tip and rod per voltage tier. Slot order: [1]=drone [2]=tip [3]=rod.
-- dbSlot is filled in by initDatabase().
M.equipment = {
    LV  = { { label="Mining Drone MK-I",    id=M.DRONE_ITEM, damage=0  }, { label="Steel Drill Tip",         id="gregtech:gt.metaitem.02", damage=8305 }, { label="Steel Rod",                id="gregtech:gt.metaitem.01", damage=23305 } },
    MV  = { { label="Mining Drone MK-II",   id=M.DRONE_ITEM, damage=1  }, { label="Steel Drill Tip",         id="gregtech:gt.metaitem.02", damage=8305 }, { label="Steel Rod",                id="gregtech:gt.metaitem.01", damage=23305 } },
    HV  = { { label="Mining Drone MK-III",  id=M.DRONE_ITEM, damage=2  }, { label="Titanium Drill Tip",      id="gregtech:gt.metaitem.02", damage=8028 }, { label="Titanium Rod",             id="gregtech:gt.metaitem.01", damage=23028 } },
    EV  = { { label="Mining Drone MK-IV",   id=M.DRONE_ITEM, damage=3  }, { label="Titanium Drill Tip",      id="gregtech:gt.metaitem.02", damage=8028 }, { label="Titanium Rod",             id="gregtech:gt.metaitem.01", damage=23028 } },
    IV  = { { label="Mining Drone MK-V",    id=M.DRONE_ITEM, damage=4  }, { label="Tungstensteel Drill Tip", id="gregtech:gt.metaitem.02", damage=8316 }, { label="Tungstensteel Rod",        id="gregtech:gt.metaitem.01", damage=23316 } },
    LuV = { { label="Mining Drone MK-VI",   id=M.DRONE_ITEM, damage=5  }, { label="Tungstensteel Drill Tip", id="gregtech:gt.metaitem.02", damage=8316 }, { label="Tungstensteel Rod",        id="gregtech:gt.metaitem.01", damage=23316 } },
    ZPM = { { label="Mining Drone MK-VII",  id=M.DRONE_ITEM, damage=6  }, { label="Naquadah Drill Tip",      id="gregtech:gt.metaitem.02", damage=8324 }, { label="Naquadah Rod",             id="gregtech:gt.metaitem.01", damage=23324 } },
    UV  = { { label="Mining Drone MK-VIII", id=M.DRONE_ITEM, damage=7  }, { label="Naquadah Drill Tip",      id="gregtech:gt.metaitem.02", damage=8324 }, { label="Naquadah Rod",             id="gregtech:gt.metaitem.01", damage=23324 } },
    UHV = { { label="Mining Drone MK-IX",   id=M.DRONE_ITEM, damage=8  }, { label="Naquadah Alloy Drill Tip",id="gregtech:gt.metaitem.02", damage=8325 }, { label="Naquadah Alloy Rod",       id="gregtech:gt.metaitem.01", damage=23325 } },
    UEV = { { label="Mining Drone MK-X",    id=M.DRONE_ITEM, damage=9  }, { label="Neutronium Drill Tip",    id="gregtech:gt.metaitem.02", damage=8129 }, { label="Neutronium Rod",           id="gregtech:gt.metaitem.01", damage=23129 } },
    UIV = { { label="Mining Drone MK-XI",   id=M.DRONE_ITEM, damage=10 }, { label="Cosmic Neutronium Drill Tip",   id="gregtech:gt.metaitem.02", damage=8982 }, { label="Cosmic Neutronium Rod",   id="gregtech:gt.metaitem.01", damage=23982 } },
    UMV = { { label="Mining Drone MK-XII",  id=M.DRONE_ITEM, damage=11 }, { label="Infinity Drill Tip",      id="gregtech:gt.metaitem.02", damage=8397 }, { label="Infinity Rod",             id="gregtech:gt.metaitem.01", damage=23397 } },
    UXV = { { label="Mining Drone MK-XIII", id=M.DRONE_ITEM, damage=12 }, { label="Transcendent Metal Drill Tip",  id="gregtech:gt.metaitem.02", damage=8581 }, { label="Transcendent Metal Rod", id="gregtech:gt.metaitem.01", damage=23581 } },
}

-- damage value of a tier's drone -> voltage name (e.g. 0 -> "LV").
M.voltageOfDamage = {}
for voltage, items in pairs(M.equipment) do
    M.voltageOfDamage[items[1].damage] = voltage
end

-- Writes every equipment item into the Database Upgrade (skipping ones already
-- present), filling item.dbSlot so ME Interface stocking calls work. Returns the
-- database address.
function M.initDatabase()
    local dbAddr = component.list("database")()
    if not dbAddr then error("[ae] Database Upgrade not found!") end
    local db = component.proxy(dbAddr)

    local existing = {}
    local maxSlots = db.size and db.size() or 0
    for i = 1, maxSlots do
        local stack = db.get(i)
        if stack and stack.name then
            existing[stack.name .. ":" .. (stack.damage or 0)] = i
        end
    end

    local nextSlot = maxSlots + 1
    for _, items in pairs(M.equipment) do
        for _, item in ipairs(items) do
            local key = item.id .. ":" .. (item.damage or 0)
            if existing[key] then
                item.dbSlot = existing[key]
            else
                db.set(nextSlot, item.id, item.damage or 0)
                item.dbSlot   = nextSlot
                existing[key] = nextSlot
                nextSlot      = nextSlot + 1
            end
        end
    end

    print("[ae] Database ready (" .. (nextSlot - 1) .. " slots used).")
    return dbAddr
end

-- ME controller proxy (lazily; errors only if actually used without one).
local me = (function()
    local addr = component.list("me_controller")()
    if not addr then error("[ae] ME Controller not found!") end
    return component.proxy(addr)
end)()

-- Total count of an item in the network, by localized label.
function M.getCurrentAmount(label)
    local items = me.getItemsInNetwork({ label = label }) or {}
    local total = 0
    for _, item in ipairs(items) do total = total + (item.size or 0) end
    return total
end

-- All mining drones currently in the network, as { [damage] = count }.
function M.getNetworkDrones()
    local result = {}
    local items  = me.getItemsInNetwork({ name = M.DRONE_ITEM }) or {}
    for _, item in ipairs(items) do
        local dmg = item.damage or 0
        result[dmg] = (result[dmg] or 0) + (item.size or 0)
    end
    return result
end

-- { [label] = { current, target, priority } } for every tracked ore.
function M.scanOreAmounts(lookupList)
    local result = {}
    for _, entry in ipairs(lookupList) do
        if not result[entry.label] then
            result[entry.label] = {
                current  = M.getCurrentAmount(entry.label),
                target   = entry.target,
                priority = entry.priority,
            }
        end
    end
    return result
end

-- Same as scanOreAmounts but only for ores of the given asteroids.
function M.scanOreAmountsFor(lookupList, asteroidNames)
    local want = {}
    for _, n in ipairs(asteroidNames) do want[n] = true end

    local result = {}
    for _, entry in ipairs(lookupList) do
        if want[entry.asteroid] and not result[entry.label] then
            result[entry.label] = {
                current  = M.getCurrentAmount(entry.label),
                target   = entry.target,
                priority = entry.priority,
            }
        end
    end
    return result
end

return M
