-- Drone, drill tip, and rod definitions per voltage tier.
-- Slot order in ME Interface: [1]=drone [2]=tip [3]=rod
-- dbSlot is filled in by initDatabase() at startup.

local component = require("component")

local equipmentTable = {
    LV = {
        { label="Mining Drone MK-I",            id="gtnhintergalactic:item.MiningDrone", damage=0  },
        { label="Steel Drill Tip",              id="gregtech:gt.metaitem.02",            damage=8305  },
        { label="Steel Rod",                    id="gregtech:gt.metaitem.01",            damage=23305 },
    },
    MV = {
        { label="Mining Drone MK-II",           id="gtnhintergalactic:item.MiningDrone", damage=1  },
        { label="Steel Drill Tip",              id="gregtech:gt.metaitem.02",            damage=8305  },
        { label="Steel Rod",                    id="gregtech:gt.metaitem.01",            damage=23305 },
    },
    HV = {
        { label="Mining Drone MK-III",          id="gtnhintergalactic:item.MiningDrone", damage=2  },
        { label="Titanium Drill Tip",           id="gregtech:gt.metaitem.02",            damage=8028  },
        { label="Titanium Rod",                 id="gregtech:gt.metaitem.01",            damage=23028 },
    },
    EV = {
        { label="Mining Drone MK-IV",           id="gtnhintergalactic:item.MiningDrone", damage=3  },
        { label="Titanium Drill Tip",           id="gregtech:gt.metaitem.02",            damage=8028  },
        { label="Titanium Rod",                 id="gregtech:gt.metaitem.01",            damage=23028 },
    },
    IV = {
        { label="Mining Drone MK-V",            id="gtnhintergalactic:item.MiningDrone", damage=4  },
        { label="Tungstensteel Drill Tip",      id="gregtech:gt.metaitem.02",            damage=8316  },
        { label="Tungstensteel Rod",            id="gregtech:gt.metaitem.01",            damage=23316 },
    },
    LuV = {
        { label="Mining Drone MK-VI",           id="gtnhintergalactic:item.MiningDrone", damage=5  },
        { label="Tungstensteel Drill Tip",      id="gregtech:gt.metaitem.02",            damage=8316  },
        { label="Tungstensteel Rod",            id="gregtech:gt.metaitem.01",            damage=23316 },
    },
    ZPM = {
        { label="Mining Drone MK-VII",          id="gtnhintergalactic:item.MiningDrone", damage=6  },
        { label="Naquadah Drill Tip",           id="gregtech:gt.metaitem.02",            damage=8324  },
        { label="Naquadah Rod",                 id="gregtech:gt.metaitem.01",            damage=23324 },
    },
    UV = {
        { label="Mining Drone MK-VIII",         id="gtnhintergalactic:item.MiningDrone", damage=7  },
        { label="Naquadah Drill Tip",           id="gregtech:gt.metaitem.02",            damage=8324  },
        { label="Naquadah Rod",                 id="gregtech:gt.metaitem.01",            damage=23324 },
    },
    UHV = {
        { label="Mining Drone MK-IX",           id="gtnhintergalactic:item.MiningDrone", damage=8  },
        { label="Naquadah Alloy Drill Tip",     id="gregtech:gt.metaitem.02",            damage=8325  },
        { label="Naquadah Alloy Rod",           id="gregtech:gt.metaitem.01",            damage=23325 },
    },
    UEV = {
        { label="Mining Drone MK-X",            id="gtnhintergalactic:item.MiningDrone", damage=9  },
        { label="Neutronium Drill Tip",         id="gregtech:gt.metaitem.02",            damage=8129  },
        { label="Neutronium Rod",               id="gregtech:gt.metaitem.01",            damage=23129 },
    },
    UIV = {
        { label="Mining Drone MK-XI",           id="gtnhintergalactic:item.MiningDrone", damage=10 },
        { label="Cosmic Neutronium Drill Tip",  id="gregtech:gt.metaitem.02",            damage=8982  },
        { label="Cosmic Neutronium Rod",        id="gregtech:gt.metaitem.01",            damage=23982 },
    },
    UMV = {
        { label="Mining Drone MK-XII",          id="gtnhintergalactic:item.MiningDrone", damage=11 },
        { label="Infinity Drill Tip",           id="gregtech:gt.metaitem.02",            damage=8397  },
        { label="Infinity Rod",                 id="gregtech:gt.metaitem.01",            damage=23397 },
    },
    UXV = {
        { label="Mining Drone MK-XIII",         id="gtnhintergalactic:item.MiningDrone", damage=12 },
        { label="Transcendent Metal Drill Tip", id="gregtech:gt.metaitem.02",            damage=8581  },
        { label="Transcendent Metal Rod",       id="gregtech:gt.metaitem.01",            damage=23581 },
    },
}

-- Writes all equipment items into the database component.
-- Skips items already stored (matched by item id + damage).
-- Fills in item.dbSlot for each entry so ME Interface calls work correctly.
local function initDatabase()
    local dbAddr = component.list("database")()
    if not dbAddr then error("[equipment] Database Upgrade not found!") end
    local db = component.proxy(dbAddr)

    -- Index what is already in the database
    local existing = {}
    local maxSlots = db.size and db.size() or 0
    for i = 1, maxSlots do
        local stack = db.get(i)
        if stack and stack.name then
            existing[stack.name .. ":" .. (stack.damage or 0)] = i
        end
    end

    local nextSlot = maxSlots + 1
    for _, items in pairs(equipmentTable) do
        for _, item in ipairs(items) do
            local key = item.id .. ":" .. (item.damage or 0)
            if existing[key] then
                item.dbSlot = existing[key]
            else
                db.set(nextSlot, item.id, item.damage or 0)
                item.dbSlot    = nextSlot
                existing[key]  = nextSlot
                nextSlot       = nextSlot + 1
            end
        end
    end

    print("[equipment] Database ready (" .. (nextSlot - 1) .. " slots used).")
    return dbAddr
end

return {
    equipmentTable = equipmentTable,
    initDatabase   = initDatabase,
}
