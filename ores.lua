-- Ore targets and priorities.
-- target   : minimum amount to keep stocked in AE
-- priority : urgency weight (higher = more urgent when depleted)
-- Only entries with target > 0 participate in scheduling.

local ores = {

Adamantium = {
    { label="Adamantium Dust",  target=0,        priority=0  },
    { label="Bismuth Dust",     target=0,        priority=0  },
    { label="Antimony Dust",    target=0,        priority=0  },
    { label="Gallium Dust",     target=0,        priority=0  },
    { label="Lithium Dust",     target=10000000, priority=20 },
},

Aluminium = {
    { label="Aluminium Dust",   target=10000000, priority=3 },
    { label="Bauxite Dust",     target=0,        priority=0 },
    { label="Rutile Dust",      target=0,        priority=0 },
},

["Aluminium-LanthLine"] = {
    { label="Aluminium Dust",  target=0, priority=0 },
    { label="Bauxite Dust",    target=0, priority=0 },
    { label="Monazite Dust",   target=0, priority=0 },
    { label="Bastnasite Dust", target=0, priority=0 },
},

["Ardite/Cobalt"] = {
    { label="Cobalt Dust",    target=10000000, priority=1 },
    { label="Ardite Dust",    target=0,        priority=0 },
    { label="Manyullyn Dust", target=0,        priority=0 },
},

["Basic Magic"] = {
    { label="Infused Gold Dust", target=0, priority=0 },
    { label="Shadow Metal Dust", target=0, priority=0 },
    { label="Air Shard",         target=0, priority=0 },
    { label="Earth Shard",       target=0, priority=0 },
    { label="Fire Shard",        target=0, priority=0 },
    { label="Water Shard",       target=0, priority=0 },
    { label="Entropy Shard",     target=0, priority=0 },
    { label="Order Shard",       target=0, priority=0 },
},

Blue = {
    { label="Lapis Lazuli", target=0, priority=0 },
    { label="Calcite Dust", target=0, priority=0 },
    { label="Lazurite",     target=0, priority=0 },
    { label="Sodalite",     target=0, priority=0 },
},

Cheese = {
    { label="Cheese Powder", target=0, priority=0 },
},

Chrome = {
    { label="Chrome Dust",   target=0, priority=0 },
    { label="Ruby",          target=0, priority=0 },
    { label="Chromite Dust", target=0, priority=0 },
},

Clay = {
    { label="Clay", target=0, priority=0 },
},

Coal = {
    { label="Coal",          target=0, priority=0 },
    { label="Lignite Coal",  target=0, priority=0 },
    { label="Graphite Dust", target=0, priority=0 },
},

Copper = {
    { label="Copper Dust",       target=0, priority=0 },
    { label="Chalcopyrite Dust", target=0, priority=0 },
    { label="Malachite Dust",    target=0, priority=0 },
},

Cosmic = {
    { label="Cosmic Neutronium Dust", target=0, priority=0 },
    { label="Neutronium Dust",        target=0, priority=0 },
    { label="Black Plutonium Dust",   target=0, priority=0 },
    { label="Bedrockium Dust",        target=0, priority=0 },
},

Draconic = {
    { label="Draconium Dust",          target=0, priority=0 },
    { label="Awakened Draconium Dust", target=0, priority=0 },
    { label="Fluxed Electrum Dust",    target=0, priority=0 },
},

["Draconic Core"] = {
    { label="Draconic Core Schematic", target=0, priority=0 },
    { label="Draconic Core",           target=0, priority=0 },
    { label="Zero Point Module",       target=0, priority=0 },
},

Europium = {
    { label="Ledox Dust",        target=10000000, priority=200 },
    { label="Callisto Ice Dust", target=10000000, priority=190 },
    { label="Borax Dust",        target=0,        priority=0   },
    { label="Europium Dust",     target=0,        priority=0   },
},

Everglades = {
    { label="Koboldite Dust",        target=0,       priority=0 },
    { label="Crocoite Dust",         target=0,       priority=0 },
    { label="Gadolinite (Y) Dust",   target=0,       priority=0 },
    { label="Lepersonnite Dust",     target=0,       priority=0 },
    { label="Zircon Dust",           target=0,       priority=0 },
    { label="Lautarite Dust",        target=0,       priority=0 },
    { label="Honeaite Dust",         target=0,       priority=0 },
    { label="Alburnite Dust",        target=0,       priority=0 },
    { label="Thallium Dust",         target=1000000, priority=0 },
    { label="Rare Earth (I) Dust",   target=0,       priority=0 },
    { label="Rare Earth (II) Dust",  target=0,       priority=0 },
    { label="Rare Earth (III) Dust", target=0,       priority=0 },
},

["Gem Ores"] = {
    { label="Ruby",           target=0,       priority=0 },
    { label="Emerald",        target=0,       priority=0 },
    { label="Sapphire",       target=0,       priority=0 },
    { label="Green Sapphire", target=0,       priority=0 },
    { label="Diamond",        target=0,       priority=0 },
    { label="Opal",           target=0,       priority=0 },
    { label="Amethyst",       target=0,       priority=0 },
    { label="Topaz",          target=0,       priority=0 },
    { label="Blue Topaz",     target=0,       priority=0 },
    { label="Bauxite Dust",   target=0,       priority=0 },
    { label="Vinteum",        target=0,       priority=0 },
    { label="Nether Star",    target=5000000, priority=0 },
},

["Holmium/Samarium"] = {
    { label="Holmium Dust",                  target=0, priority=0 },
    { label="Samarium Ore Concentrate Dust", target=0, priority=0 },
    { label="Tiberium",                      target=0, priority=0 },
    { label="Strontium Dust",                target=0, priority=0 },
},

Ichorium = {
    { label="Shadow Iron Dust",   target=0,        priority=0 },
    { label="Meteoric Iron Dust", target=0,        priority=0 },
    { label="Ichorium Dust",      target=0,        priority=0 },
    { label="Desh Dust",          target=0,        priority=0 },
    { label="Americium Dust",     target=10000000, priority=0 },
},

Indium = {
    { label="Indium Dust",     target=0, priority=0 },
    { label="Sphalerite Dust", target=0, priority=0 },
    { label="Zinc Dust",       target=0, priority=0 },
    { label="Cadmium Dust",    target=0, priority=0 },
},

["Infinity Catalyst"] = {
    { label="Infinity Catalyst Dust", target=1000000000, priority=100 },
    { label="Cosmic Neutronium Dust", target=0,          priority=0   },
    { label="Neutronium Dust",        target=0,          priority=0   },
},

Iron = {
    { label="Iron Dust",             target=0, priority=0 },
    { label="Gold Dust",             target=0, priority=0 },
    { label="Magnetite Dust",        target=0, priority=0 },
    { label="Pyrite Dust",           target=0, priority=0 },
    { label="Basaltic Mineral Sand", target=0, priority=0 },
    { label="Granitic Mineral Sand", target=0, priority=0 },
},

Lanthanum = {
    { label="Trinium Dust",   target=0, priority=0 },
    { label="Lanthanum Dust", target=0, priority=0 },
    { label="Orundum",        target=0, priority=0 },
    { label="Silver Dust",    target=0, priority=0 },
},

Lead = {
    { label="Lead Dust",       target=0, priority=0 },
    { label="Arsenic Dust",    target=0, priority=0 },
    { label="Barium Dust",     target=0, priority=0 },
    { label="Lepidolite Dust", target=0, priority=0 },
},

Lutetium = {
    { label="Tellurium Dust", target=0, priority=0 },
    { label="Thulium Dust",   target=0, priority=0 },
    { label="Tantalum Dust",  target=0, priority=0 },
    { label="Lutetium Dust",  target=0, priority=0 },
    { label="Redstone Dust",  target=0, priority=0 },
},

Magnesium = {
    { label="Magnesium Dust", target=50000000, priority=5 },
    { label="Manganese Dust", target=0,        priority=0 },
    { label="Fluorspar",      target=0,        priority=0 },
},

["Mysterious Crystal"] = {
    { label="Mysterious Crystal Dust", target=0, priority=0 },
    { label="Mytryl Dust",             target=0, priority=0 },
    { label="Oriharukon Dust",         target=0, priority=0 },
    { label="Endium Dust",             target=0, priority=0 },
    { label="End Powder",              target=0, priority=0 },
},

Naquadah = {
    { label="Naquadah Oxide Mixture Dust",          target=0, priority=0 },
    { label="Enriched-Naquadah Oxide Mixture Dust", target=0, priority=0 },
    { label="Naquadria Oxide Mixture Dust",         target=0, priority=0 },
},

Nickel = {
    { label="Nickel Dust",      target=0, priority=0 },
    { label="Pentlandite Dust", target=0, priority=0 },
    { label="Garnierite Dust",  target=0, priority=0 },
},

Niobium = {
    { label="Niobium Dust",   target=0, priority=0 },
    { label="Quantium Dust",  target=0, priority=0 },
    { label="Ytterbium Dust", target=0, priority=0 },
    { label="Yttrium Dust",   target=0, priority=0 },
},

Phosphate = {
    { label="Phosphate Dust",       target=0, priority=0 },
    { label="Tricalcium Phosphate", target=0, priority=0 },
    { label="Sulfur Dust",          target=0, priority=0 },
},

["PlatLine Dust"] = {
    { label="Platinum Dust",  target=0, priority=0 },
    { label="Palladium Dust", target=0, priority=0 },
    { label="Iridium Dust",   target=0, priority=0 },
    { label="Osmium Dust",    target=0, priority=0 },
    { label="Ruthenium Dust", target=0, priority=0 },
    { label="Rhodium Dust",   target=0, priority=0 },
},

["PlatLine Ore"] = {
    { label="Platinum Metallic Powder Dust",  target=0, priority=0 },
    { label="Palladium Metallic Powder Dust", target=0, priority=0 },
    { label="Iridium Metal Residue Dust",     target=0, priority=0 },
    { label="Rarest Metal Residue Dust",      target=0, priority=0 },
},

Quartz = {
    { label="Quartzite",     target=0, priority=0 },
    { label="Certus Quartz", target=0, priority=0 },
    { label="Nether Quartz", target=0, priority=0 },
    { label="Vanadium Dust", target=0, priority=0 },
},

Salt = {
    { label="Salt",           target=0, priority=0 },
    { label="Rock Salt",      target=0, priority=0 },
    { label="Saltpeter Dust", target=0, priority=0 },
},

Silicon = {
    { label="Mica Dust",                          target=0,        priority=0 },
    { label="Raw Silicon Dust",                   target=20000000, priority=4 },
    { label="Silicon Solar Grade (Poly SI) Dust", target=0,        priority=0 },
},

Tengam = {
    { label="Dilithium",       target=0, priority=0 },
    { label="Orundum",         target=0, priority=0 },
    { label="Vanadium Dust",   target=0, priority=0 },
    { label="Ytterbium Dust",  target=0, priority=0 },
    { label="Raw Tengam Dust", target=0, priority=0 },
},

["Thaumium Dust"] = {
    { label="Thaumium Dust", target=0, priority=0 },
    { label="Void Dust",     target=0, priority=0 },
},

Tin = {
    { label="Cassiterite Dust", target=0, priority=0 },
    { label="Cassiterite Sand", target=0, priority=0 },
    { label="Tin Dust",         target=0, priority=0 },
    { label="Asbestos Dust",    target=0, priority=0 },
},

["Tungsten-Titanium"] = {
    { label="Tungsten Dust",  target=0, priority=0 },
    { label="Titanium Dust",  target=0, priority=0 },
    { label="Neodymium Dust", target=0, priority=0 },
    { label="Molybdenum Dust",target=0, priority=0 },
    { label="Tungstate Dust", target=0, priority=0 },
},

["Uranium-Plutonium"] = {
    { label="Uranium 238 Dust",   target=0,       priority=0   },
    { label="Uranium 235 Dust",   target=0,       priority=0   },
    { label="Plutonium 239 Dust", target=0,       priority=0   },
    { label="Plutonium 241 Dust", target=5000000, priority=100 },
    { label="Thorianite Dust",    target=0,       priority=0   },
},

}

-- Overlays web/config-supplied ore targets onto the static asteroid catalog.
-- The catalog above maps each asteroid to the ore labels it can yield; the
-- target/priority numbers there are only placeholders. When a target list is
-- given it becomes the single source of truth: every ore is reset to
-- target=0/priority=0 and then the listed labels are applied. The same label
-- may appear under several asteroids — every match is updated, which is what
-- lets the scheduler consider all of them.
--
-- If `targetList` is nil (no `ore_targets` key in config) the catalog is left
-- exactly as written, so hand-edited ores.lua targets keep working. An explicit
-- (even empty) list is authoritative. Call once at startup, before
-- buildLookupList/buildOresByAsteroid.
function ores.applyTargets(targetList)
    if type(targetList) ~= "table" then return end  -- nil → keep catalog as-is

    -- Reset all catalog entries so stale placeholder targets never leak in.
    for _, resources in pairs(ores) do
        if type(resources) == "table" then
            for _, res in ipairs(resources) do
                res.target   = 0
                res.priority = 0
            end
        end
    end

    -- Index desired targets by label for an O(1) lookup while walking catalog.
    local byLabel = {}
    for _, t in ipairs(targetList) do
        if t.label then byLabel[t.label] = t end
    end

    for _, resources in pairs(ores) do
        if type(resources) == "table" then
            for _, res in ipairs(resources) do
                local t = byLabel[res.label]
                if t then
                    res.target   = tonumber(t.target)   or 0
                    res.priority = tonumber(t.priority) or 0
                end
            end
        end
    end
end

-- Flat list of all tracked ores (target > 0), used for ME scanning.
function ores.buildLookupList()
    local list = {}
    for asteroid, resources in pairs(ores) do
        if type(resources) == "table" then
            for _, res in ipairs(resources) do
                if res.target and res.target > 0 then
                    list[#list + 1] = {
                        asteroid = asteroid,
                        label    = res.label,
                        target   = res.target,
                        priority = res.priority or 0,
                    }
                end
            end
        end
    end
    return list
end

-- Tracked ores grouped by asteroid name, used by the scheduler.
function ores.buildOresByAsteroid()
    local result = {}
    for asteroid, resources in pairs(ores) do
        if type(resources) == "table" then
            local tracked = {}
            for _, res in ipairs(resources) do
                if res.target and res.target > 0 then
                    tracked[#tracked + 1] = res
                end
            end
            if #tracked > 0 then
                result[asteroid] = tracked
            end
        end
    end
    return result
end

return ores
