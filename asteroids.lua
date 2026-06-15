-- Static asteroid game data, consolidated from the former
-- asteroids_mk1/2/3.lua and ores.lua (all of it is keyed by asteroid).
--
--   M.chances[minerLevel][asteroid][voltage] = { distance, chance }
--     drone success rates per miner tier (keyed by the MFU component name).
--   ore catalog (local "ores"): asteroid -> { {label,target,priority}, ... }
--     overlaid by config.ore_targets via M.applyTargets() at startup.

local mk1 = {

    Adamantium = {
        EV  = { distance = 101, chance = 12.00 },
        IV  = { distance = 5,   chance = 11.15 },
        LuV = { distance = 5,   chance = 16.48 },
        ZPM = { distance = 5,   chance = 22.73 },
    },

    Aluminium = {
        MV  = { distance = 13, chance = 5.69 },
        HV  = { distance = 5,  chance = 4.78 },
        EV  = { distance = 5,  chance = 4.27 },
    },

    ["Aluminium-LanthLine"] = {
        MV  = { distance = 101, chance = 14.71 },
        HV  = { distance = 101, chance = 12.82 },
        EV  = { distance = 101, chance = 10.00 },
        IV  = { distance = 101, chance = 7.51  },
        LuV = { distance = 101, chance = 8.25  },
        ZPM = { distance = 41,  chance = 8.96  },
    },

    ["Ardite/Cobalt"] = {
        EV  = { distance = 71, chance = 4.62  },
        IV  = { distance = 41, chance = 3.91  },
        LuV = { distance = 41, chance = 4.78  },
        ZPM = { distance = 30, chance = 5.68  },
        UV  = { distance = 30, chance = 14.56 },
        UHV = { distance = 30, chance = 26.79 },
    },

    ["Basic Magic"] = {
        HV  = { distance = 13, chance = 7.72 },
        EV  = { distance = 8,  chance = 6.64 },
        IV  = { distance = 8,  chance = 6.92 },
        LuV = { distance = 8,  chance = 9.90 },
    },

    Blue = {
        HV  = { distance = 181, chance = 38.46 },
        EV  = { distance = 181, chance = 27.78 },
        IV  = { distance = 181, chance = 21.74 },
        LuV = { distance = 181, chance = 29.41 },
        ZPM = { distance = 181, chance = 29.41 },
        UV  = { distance = 20,  chance = 34.72 },
    },

    Chrome = {
        MV  = { distance = 13, chance = 4.74 },
        HV  = { distance = 13, chance = 3.86 },
        EV  = { distance = 13, chance = 3.18 },
        IV  = { distance = 13, chance = 3.31 },
        LuV = { distance = 13, chance = 4.65 },
    },

    Clay = {
        LV  = { distance = 41, chance = 11.63 },
        MV  = { distance = 41, chance = 9.09  },
        HV  = { distance = 71, chance = 7.84  },
        EV  = { distance = 71, chance = 6.15  },
        IV  = { distance = 25, chance = 5.87  },
        LuV = { distance = 25, chance = 7.38  },
    },

    Coal = {
        LV  = { distance = 1, chance = 18.18 },
        MV  = { distance = 1, chance = 18.18 },
        HV  = { distance = 1, chance = 18.18 },
        EV  = { distance = 1, chance = 18.18 },
        IV  = { distance = 1, chance = 18.18 },
        LuV = { distance = 1, chance = 25.00 },
        ZPM = { distance = 1, chance = 25.00 },
    },

    Copper = {
        LV  = { distance = 3, chance = 25.00 },
        MV  = { distance = 3, chance = 25.00 },
        HV  = { distance = 3, chance = 25.00 },
        EV  = { distance = 3, chance = 25.00 },
        IV  = { distance = 3, chance = 25.00 },
        LuV = { distance = 3, chance = 38.46 },
    },

    Everglades = {
        ZPM = { distance = 201, chance = 28.57 },
        UV  = { distance = 201, chance = 28.57 },
        UHV = { distance = 201, chance = 28.57 },
    },

    ["Gem Ores"] = {
        LV  = { distance = 17, chance = 8.70 },
        MV  = { distance = 17, chance = 7.86 },
        HV  = { distance = 17, chance = 6.50 },
        EV  = { distance = 17, chance = 5.42 },
        IV  = { distance = 17, chance = 5.63 },
        LuV = { distance = 17, chance = 7.73 },
    },

    Iron = {
        LV  = { distance = 151, chance = 60.00 },
        MV  = { distance = 151, chance = 60.00 },
        HV  = { distance = 1,   chance = 54.55 },
        EV  = { distance = 1,   chance = 54.55 },
        IV  = { distance = 1,   chance = 54.55 },
        LuV = { distance = 1,   chance = 75.00 },
        ZPM = { distance = 1,   chance = 75.00 },
    },

    Lead = {
        LV  = { distance = 101, chance = 18.03  },
        MV  = { distance = 121, chance = 18.03  },
        HV  = { distance = 121, chance = 14.97  },
        EV  = { distance = 121, chance = 12.79  },
        IV  = { distance = 121, chance = 9.44   },
        LuV = { distance = 5,   chance = 12.09  },
        ZPM = { distance = 5,   chance = 16.67  },
        UV  = { distance = 5,   chance = 100.00 },
    },

    Lutetium = {
        IV  = { distance = 201, chance = 18.18 },
        LuV = { distance = 201, chance = 40.00 },
        ZPM = { distance = 231, chance = 40.00 },
        UV  = { distance = 231, chance = 40.00 },
        UHV = { distance = 231, chance = 40.00 },
    },

    Magnesium = {
        EV  = { distance = 181, chance = 27.78  },
        IV  = { distance = 181, chance = 21.74  },
        LuV = { distance = 181, chance = 29.41  },
        ZPM = { distance = 181, chance = 29.41  },
        UV  = { distance = 10,  chance = 53.19  },
        UHV = { distance = 10,  chance = 100.00 },
    },

    ["Mysterious Crystal"] = {
        IV  = { distance = 101, chance = 6.61   },
        LuV = { distance = 101, chance = 7.26   },
        ZPM = { distance = 101, chance = 7.51   },
        UV  = { distance = 101, chance = 14.19  },
        UHV = { distance = 101, chance = 25.00  },
        UEV = { distance = 65,  chance = 59.46  },
        UIV = { distance = 65,  chance = 59.46  },
        UMV = { distance = 65,  chance = 100.00 },
        UXV = { distance = 65,  chance = 100.00 },
    },

    Naquadah = {
        IV  = { distance = 121, chance = 8.58  },
        LuV = { distance = 121, chance = 9.85  },
        ZPM = { distance = 121, chance = 9.85  },
        UV  = { distance = 50,  chance = 15.04 },
    },

    Nickel = {
        LV  = { distance = 13, chance = 8.99 },
        MV  = { distance = 13, chance = 8.06 },
        HV  = { distance = 5,  chance = 6.77 },
        EV  = { distance = 5,  chance = 6.05 },
        IV  = { distance = 5,  chance = 6.32 },
    },

    Niobium = {
        IV  = { distance = 151, chance = 8.38  },
        LuV = { distance = 151, chance = 9.94  },
        ZPM = { distance = 151, chance = 9.94  },
        UV  = { distance = 151, chance = 15.84 },
        UHV = { distance = 30,  chance = 28.57 },
    },

    Phosphate = {
        IV  = { distance = 241, chance = 33.33  },
        LuV = { distance = 241, chance = 100.00 },
        ZPM = { distance = 241, chance = 100.00 },
        UV  = { distance = 241, chance = 100.00 },
        UHV = { distance = 241, chance = 100.00 },
        UEV = { distance = 60,  chance = 100.00 },
        UIV = { distance = 60,  chance = 100.00 },
    },

    ["PlatLine Ore"] = {
        HV  = { distance = 13, chance = 5.02 },
        EV  = { distance = 13, chance = 4.14 },
        IV  = { distance = 13, chance = 4.30 },
        LuV = { distance = 13, chance = 6.05 },
        ZPM = { distance = 10, chance = 7.65 },
    },

    Quartz = {
        MV  = { distance = 101, chance = 13.53 },
        HV  = { distance = 101, chance = 11.79 },
        EV  = { distance = 101, chance = 9.20  },
        IV  = { distance = 101, chance = 6.91  },
        LuV = { distance = 25,  chance = 8.49  },
        ZPM = { distance = 20,  chance = 10.55 },
    },

    Salt = {
        LV  = { distance = 201, chance = 100.00 },
        MV  = { distance = 201, chance = 100.00 },
        HV  = { distance = 201, chance = 100.00 },
        EV  = { distance = 201, chance = 100.00 },
        IV  = { distance = 241, chance = 66.67  },
    },

    ["Thaumium Dust"] = {
        HV  = { distance = 13, chance = 5.79 },
        EV  = { distance = 13, chance = 4.78 },
        IV  = { distance = 13, chance = 4.97 },
        LuV = { distance = 13, chance = 6.98 },
    },

    Tin = {
        LV  = { distance = 2, chance = 26.67 },
        MV  = { distance = 2, chance = 26.67 },
        HV  = { distance = 2, chance = 26.67 },
        EV  = { distance = 2, chance = 26.67 },
        IV  = { distance = 2, chance = 26.67 },
    },

    ["Tungsten-Titanium"] = {
        LV  = { distance = 181, chance = 25.00 },
        MV  = { distance = 181, chance = 25.00 },
        HV  = { distance = 181, chance = 15.38 },
        EV  = { distance = 181, chance = 11.11 },
        IV  = { distance = 181, chance = 8.70  },
        LuV = { distance = 181, chance = 11.76 },
    },

    ["Uranium-Plutonium"] = {
        HV  = { distance = 51, chance = 5.45 },
        EV  = { distance = 51, chance = 4.35 },
        IV  = { distance = 41, chance = 3.91 },
        LuV = { distance = 41, chance = 4.78 },
        ZPM = { distance = 30, chance = 5.68 },
    },

}

local mk2 = {

    Adamantium = {
        EV  = { distance = 101, chance = 11.11 },
        IV  = { distance = 5,   chance = 11.15 },
        LuV = { distance = 5,   chance = 16.48 },
        ZPM = { distance = 5,   chance = 22.73 },
    },

    Aluminium = {
        MV  = { distance = 13, chance = 5.69 },
        HV  = { distance = 5,  chance = 4.78 },
        EV  = { distance = 5,  chance = 4.27 },
    },

    ["Aluminium-LanthLine"] = {
        MV  = { distance = 101, chance = 14.71 },
        HV  = { distance = 101, chance = 11.63 },
        EV  = { distance = 101, chance = 9.26  },
        IV  = { distance = 101, chance = 6.78  },
        LuV = { distance = 41,  chance = 7.60  },
        ZPM = { distance = 41,  chance = 8.09  },
    },

    ["Ardite/Cobalt"] = {
        EV  = { distance = 71, chance = 4.35  },
        IV  = { distance = 41, chance = 3.76  },
        LuV = { distance = 41, chance = 4.56  },
        ZPM = { distance = 30, chance = 5.38  },
        UV  = { distance = 30, chance = 12.71 },
        UHV = { distance = 30, chance = 21.13 },
    },

    ["Basic Magic"] = {
        HV  = { distance = 13, chance = 7.72 },
        EV  = { distance = 8,  chance = 6.64 },
        IV  = { distance = 8,  chance = 6.92 },
        LuV = { distance = 8,  chance = 9.90 },
    },

    Blue = {
        HV  = { distance = 181, chance = 29.41 },
        EV  = { distance = 181, chance = 22.73 },
        IV  = { distance = 181, chance = 16.56 },
        LuV = { distance = 181, chance = 17.86 },
        ZPM = { distance = 181, chance = 20.83 },
        UV  = { distance = 20,  chance = 34.72 },
    },

    Cheese = {
        IV  = { distance = 181, chance = 0.66   },
        LuV = { distance = 181, chance = 0.71   },
        ZPM = { distance = 181, chance = 0.83   },
        UV  = { distance = 161, chance = 0.83   },
        UHV = { distance = 161, chance = 1.05   },
        UEV = { distance = 121, chance = 3.23   },
        UIV = { distance = 121, chance = 3.23   },
        UMV = { distance = 121, chance = 100.00 },
        UXV = { distance = 121, chance = 100.00 },
    },

    Chrome = {
        MV  = { distance = 13, chance = 4.74 },
        HV  = { distance = 13, chance = 3.86 },
        EV  = { distance = 13, chance = 3.18 },
        IV  = { distance = 13, chance = 3.31 },
        LuV = { distance = 13, chance = 4.65 },
    },

    Clay = {
        LV  = { distance = 41, chance = 11.63 },
        MV  = { distance = 41, chance = 9.09  },
        HV  = { distance = 71, chance = 7.27  },
        EV  = { distance = 25, chance = 5.87  },
        IV  = { distance = 25, chance = 5.87  },
        LuV = { distance = 25, chance = 7.38  },
    },

    Coal = {
        LV  = { distance = 1, chance = 18.18 },
        MV  = { distance = 1, chance = 18.18 },
        HV  = { distance = 1, chance = 18.18 },
        EV  = { distance = 1, chance = 18.18 },
        IV  = { distance = 1, chance = 18.18 },
        LuV = { distance = 1, chance = 25.00 },
        ZPM = { distance = 1, chance = 25.00 },
    },

    Copper = {
        LV  = { distance = 3, chance = 25.00 },
        MV  = { distance = 3, chance = 25.00 },
        HV  = { distance = 3, chance = 25.00 },
        EV  = { distance = 3, chance = 25.00 },
        IV  = { distance = 3, chance = 25.00 },
        LuV = { distance = 3, chance = 38.46 },
    },

    Cosmic = {
        ZPM = { distance = 91, chance = 4.72  },
        UV  = { distance = 61, chance = 7.61  },
        UHV = { distance = 61, chance = 10.86 },
        UEV = { distance = 61, chance = 23.78 },
        UIV = { distance = 61, chance = 31.19 },
        UMV = { distance = 61, chance = 69.39 },
        UXV = { distance = 61, chance = 69.39 },
    },

    Draconic = {
        LuV = { distance = 181, chance = 13.57 },
        ZPM = { distance = 181, chance = 15.83 },
        UV  = { distance = 161, chance = 15.83 },
        UHV = { distance = 161, chance = 20.00 },
    },

    Europium = {
        ZPM = { distance = 41, chance = 4.85  },
        UV  = { distance = 40, chance = 9.97  },
        UHV = { distance = 40, chance = 14.49 },
        UEV = { distance = 40, chance = 40.00 },
        UIV = { distance = 40, chance = 40.00 },
        UMV = { distance = 40, chance = 66.67 },
        UXV = { distance = 40, chance = 66.67 },
    },

    Everglades = {
        ZPM = { distance = 201, chance = 20.00 },
        UV  = { distance = 201, chance = 20.00 },
        UHV = { distance = 201, chance = 20.00 },
    },

    ["Gem Ores"] = {
        LV  = { distance = 17, chance = 8.70 },
        MV  = { distance = 17, chance = 7.86 },
        HV  = { distance = 17, chance = 6.50 },
        EV  = { distance = 17, chance = 5.42 },
        IV  = { distance = 17, chance = 5.63 },
        LuV = { distance = 17, chance = 7.73 },
    },

    ["Holmium/Samarium"] = {
        UV  = { distance = 40, chance = 4.98  },
        UHV = { distance = 40, chance = 7.25  },
        UEV = { distance = 40, chance = 20.00 },
        UIV = { distance = 40, chance = 20.00 },
        UMV = { distance = 40, chance = 33.33 },
        UXV = { distance = 40, chance = 33.33 },
    },

    Indium = {
        IV  = { distance = 51, chance = 3.84  },
        LuV = { distance = 51, chance = 4.56  },
        ZPM = { distance = 51, chance = 5.11  },
        UV  = { distance = 50, chance = 9.07  },
        UHV = { distance = 50, chance = 14.11 },
        UEV = { distance = 50, chance = 31.19 },
    },

    ["Infinity Catalyst"] = {
        UV  = { distance = 91, chance = 6.33  },
        UHV = { distance = 91, chance = 8.82  },
        UEV = { distance = 91, chance = 17.65 },
        UIV = { distance = 81, chance = 17.86 },
        UMV = { distance = 81, chance = 27.78 },
        UXV = { distance = 81, chance = 27.78 },
    },

    Iron = {
        LV  = { distance = 151, chance = 60.00 },
        MV  = { distance = 151, chance = 60.00 },
        HV  = { distance = 1,   chance = 54.55 },
        EV  = { distance = 1,   chance = 54.55 },
        IV  = { distance = 1,   chance = 54.55 },
        LuV = { distance = 1,   chance = 75.00 },
        ZPM = { distance = 1,   chance = 75.00 },
    },

    Lanthanum = {
        IV  = { distance = 201, chance = 16.67  },
        LuV = { distance = 201, chance = 25.00  },
        ZPM = { distance = 201, chance = 30.00  },
        UV  = { distance = 201, chance = 30.00  },
        UHV = { distance = 201, chance = 30.00  },
        UEV = { distance = 30,  chance = 100.00 },
        UIV = { distance = 30,  chance = 100.00 },
    },

    Lead = {
        LV  = { distance = 101, chance = 18.03  },
        MV  = { distance = 121, chance = 18.03  },
        HV  = { distance = 121, chance = 13.17  },
        EV  = { distance = 121, chance = 11.46  },
        IV  = { distance = 5,   chance = 8.18   },
        LuV = { distance = 5,   chance = 12.09  },
        ZPM = { distance = 5,   chance = 16.67  },
        UV  = { distance = 5,   chance = 100.00 },
    },

    Lutetium = {
        IV  = { distance = 231, chance = 13.33 },
        LuV = { distance = 231, chance = 22.22 },
        ZPM = { distance = 231, chance = 40.00 },
        UV  = { distance = 231, chance = 40.00 },
        UHV = { distance = 231, chance = 40.00 },
    },

    Magnesium = {
        EV  = { distance = 181, chance = 22.73  },
        IV  = { distance = 181, chance = 16.56  },
        LuV = { distance = 181, chance = 17.86  },
        ZPM = { distance = 181, chance = 20.83  },
        UV  = { distance = 10,  chance = 53.19  },
        UHV = { distance = 10,  chance = 100.00 },
    },

    ["Mysterious Crystal"] = {
        IV  = { distance = 101, chance = 5.96   },
        LuV = { distance = 101, chance = 6.15   },
        ZPM = { distance = 101, chance = 6.71   },
        UV  = { distance = 101, chance = 11.58  },
        UHV = { distance = 101, chance = 17.89  },
        UEV = { distance = 101, chance = 41.51  },
        UIV = { distance = 101, chance = 41.51  },
        UMV = { distance = 101, chance = 95.65  },
        UXV = { distance = 101, chance = 95.65  },
    },

    Naquadah = {
        IV  = { distance = 121, chance = 7.43  },
        LuV = { distance = 121, chance = 7.75  },
        ZPM = { distance = 121, chance = 8.40  },
        UV  = { distance = 121, chance = 11.24 },
    },

    Nickel = {
        LV  = { distance = 13, chance = 8.99 },
        MV  = { distance = 13, chance = 8.06 },
        HV  = { distance = 5,  chance = 6.77 },
        EV  = { distance = 5,  chance = 6.05 },
        IV  = { distance = 5,  chance = 6.32 },
    },

    Niobium = {
        IV  = { distance = 151, chance = 7.05  },
        LuV = { distance = 151, chance = 7.41  },
        ZPM = { distance = 151, chance = 8.16  },
        UV  = { distance = 30,  chance = 13.56 },
        UHV = { distance = 30,  chance = 22.54 },
    },

    Phosphate = {
        IV  = { distance = 241, chance = 23.08  },
        LuV = { distance = 241, chance = 42.86  },
        ZPM = { distance = 241, chance = 100.00 },
        UV  = { distance = 241, chance = 100.00 },
        UHV = { distance = 241, chance = 100.00 },
        UEV = { distance = 231, chance = 100.00 },
        UIV = { distance = 231, chance = 100.00 },
    },

    ["PlatLine Ore"] = {
        HV  = { distance = 13, chance = 5.02 },
        EV  = { distance = 13, chance = 4.14 },
        IV  = { distance = 13, chance = 4.30 },
        LuV = { distance = 13, chance = 6.05 },
        ZPM = { distance = 10, chance = 7.65 },
    },

    Quartz = {
        MV  = { distance = 101, chance = 13.53 },
        HV  = { distance = 101, chance = 10.70 },
        EV  = { distance = 101, chance = 8.52  },
        IV  = { distance = 25,  chance = 6.74  },
        LuV = { distance = 25,  chance = 8.49  },
        ZPM = { distance = 20,  chance = 10.55 },
    },

    Salt = {
        LV  = { distance = 201, chance = 100.00 },
        MV  = { distance = 201, chance = 100.00 },
        HV  = { distance = 201, chance = 60.00  },
        EV  = { distance = 201, chance = 60.00  },
        IV  = { distance = 241, chance = 46.15  },
    },

    Silicon = {
        HV  = { distance = 201, chance = 40.00 },
        EV  = { distance = 201, chance = 40.00 },
        IV  = { distance = 241, chance = 30.77 },
        LuV = { distance = 241, chance = 57.14 },
    },

    ["Thaumium Dust"] = {
        HV  = { distance = 13, chance = 5.79 },
        EV  = { distance = 13, chance = 4.78 },
        IV  = { distance = 13, chance = 4.97 },
        LuV = { distance = 13, chance = 6.98 },
    },

    Tin = {
        LV  = { distance = 2, chance = 26.67 },
        MV  = { distance = 2, chance = 26.67 },
        HV  = { distance = 2, chance = 26.67 },
        EV  = { distance = 2, chance = 26.67 },
        IV  = { distance = 2, chance = 26.67 },
    },

    ["Tungsten-Titanium"] = {
        LV  = { distance = 181, chance = 25.00 },
        MV  = { distance = 181, chance = 25.00 },
        HV  = { distance = 181, chance = 11.76 },
        EV  = { distance = 181, chance = 9.09  },
        IV  = { distance = 181, chance = 6.62  },
        LuV = { distance = 181, chance = 7.14  },
    },

    ["Uranium-Plutonium"] = {
        HV  = { distance = 41, chance = 5.21 },
        EV  = { distance = 41, chance = 4.19 },
        IV  = { distance = 41, chance = 3.76 },
        LuV = { distance = 41, chance = 4.56 },
        ZPM = { distance = 30, chance = 5.38 },
    },

}

local mk3 = {

    Adamantium = {
        EV  = { distance = 101, chance = 11.11 },
        IV  = { distance = 5,   chance = 11.15 },
        LuV = { distance = 5,   chance = 16.48 },
        ZPM = { distance = 5,   chance = 22.73 },
    },

    Aluminium = {
        MV  = { distance = 13, chance = 5.69 },
        HV  = { distance = 5,  chance = 4.78 },
        EV  = { distance = 5,  chance = 4.27 },
    },

    ["Aluminium-LanthLine"] = {
        MV  = { distance = 101, chance = 14.71 },
        HV  = { distance = 101, chance = 11.63 },
        EV  = { distance = 101, chance = 9.26  },
        IV  = { distance = 101, chance = 6.78  },
        LuV = { distance = 41,  chance = 7.60  },
        ZPM = { distance = 41,  chance = 7.94  },
    },

    ["Ardite/Cobalt"] = {
        EV  = { distance = 71, chance = 4.35  },
        IV  = { distance = 41, chance = 3.76  },
        LuV = { distance = 41, chance = 4.56  },
        ZPM = { distance = 30, chance = 5.26  },
        UV  = { distance = 30, chance = 12.10 },
        UHV = { distance = 30, chance = 19.48 },
    },

    ["Basic Magic"] = {
        HV  = { distance = 13, chance = 7.72 },
        EV  = { distance = 8,  chance = 6.64 },
        IV  = { distance = 8,  chance = 6.92 },
        LuV = { distance = 8,  chance = 9.90 },
    },

    Blue = {
        HV  = { distance = 181, chance = 29.41 },
        EV  = { distance = 181, chance = 22.73 },
        IV  = { distance = 181, chance = 16.56 },
        LuV = { distance = 181, chance = 17.86 },
        ZPM = { distance = 181, chance = 19.84 },
        UV  = { distance = 20,  chance = 34.72 },
    },

    Cheese = {
        IV  = { distance = 181, chance = 0.66   },
        LuV = { distance = 181, chance = 0.71   },
        ZPM = { distance = 181, chance = 0.79   },
        UV  = { distance = 161, chance = 0.79   },
        UHV = { distance = 161, chance = 0.99   },
        UEV = { distance = 121, chance = 2.70   },
        UIV = { distance = 121, chance = 3.22   },
        UMV = { distance = 121, chance = 100.00 },
        UXV = { distance = 121, chance = 100.00 },
    },

    Chrome = {
        MV  = { distance = 13, chance = 4.74 },
        HV  = { distance = 13, chance = 3.86 },
        EV  = { distance = 13, chance = 3.18 },
        IV  = { distance = 13, chance = 3.31 },
        LuV = { distance = 13, chance = 4.65 },
    },

    Clay = {
        LV  = { distance = 41, chance = 11.63 },
        MV  = { distance = 41, chance = 9.09  },
        HV  = { distance = 71, chance = 7.27  },
        EV  = { distance = 25, chance = 5.87  },
        IV  = { distance = 25, chance = 5.87  },
        LuV = { distance = 25, chance = 7.38  },
    },

    Coal = {
        LV  = { distance = 1, chance = 18.18 },
        MV  = { distance = 1, chance = 18.18 },
        HV  = { distance = 1, chance = 18.18 },
        EV  = { distance = 1, chance = 18.18 },
        IV  = { distance = 1, chance = 18.18 },
        LuV = { distance = 1, chance = 25.00 },
        ZPM = { distance = 1, chance = 25.00 },
    },

    Copper = {
        LV  = { distance = 3, chance = 25.00 },
        MV  = { distance = 3, chance = 25.00 },
        HV  = { distance = 3, chance = 25.00 },
        EV  = { distance = 3, chance = 25.00 },
        IV  = { distance = 3, chance = 25.00 },
        LuV = { distance = 3, chance = 38.46 },
    },

    Cosmic = {
        ZPM = { distance = 91, chance = 4.64  },
        UV  = { distance = 61, chance = 7.41  },
        UHV = { distance = 61, chance = 10.46 },
        UEV = { distance = 61, chance = 20.58 },
        UIV = { distance = 61, chance = 28.52 },
        UMV = { distance = 61, chance = 57.63 },
        UXV = { distance = 61, chance = 57.63 },
    },

    Draconic = {
        LuV = { distance = 181, chance = 13.57 },
        ZPM = { distance = 181, chance = 15.08 },
        UV  = { distance = 161, chance = 15.08 },
        UHV = { distance = 161, chance = 18.79 },
    },

    ["Draconic Core"] = {
        UHV = { distance = 161, chance = 0.10 },
        UEV = { distance = 121, chance = 0.27 },
        UIV = { distance = 121, chance = 0.32 },
    },

    Europium = {
        ZPM = { distance = 41, chance = 4.76  },
        UV  = { distance = 40, chance = 9.58  },
        UHV = { distance = 40, chance = 13.70 },
        UEV = { distance = 40, chance = 30.93 },
        UIV = { distance = 40, chance = 35.29 },
        UMV = { distance = 40, chance = 54.55 },
        UXV = { distance = 40, chance = 54.55 },
    },

    Everglades = {
        ZPM = { distance = 201, chance = 20.00 },
        UV  = { distance = 201, chance = 20.00 },
        UHV = { distance = 201, chance = 20.00 },
    },

    ["Gem Ores"] = {
        LV  = { distance = 17, chance = 8.70 },
        MV  = { distance = 17, chance = 7.86 },
        HV  = { distance = 17, chance = 6.50 },
        EV  = { distance = 17, chance = 5.42 },
        IV  = { distance = 17, chance = 5.63 },
        LuV = { distance = 17, chance = 7.73 },
    },

    ["Holmium/Samarium"] = {
        UV  = { distance = 40, chance = 4.79  },
        UHV = { distance = 40, chance = 6.85  },
        UEV = { distance = 40, chance = 15.46 },
        UIV = { distance = 40, chance = 17.65 },
        UMV = { distance = 40, chance = 27.27 },
        UXV = { distance = 40, chance = 27.27 },
    },

    Ichorium = {
        UEV = { distance = 91, chance = 13.50 },
        UIV = { distance = 81, chance = 14.41 },
        UMV = { distance = 81, chance = 20.27 },
        UXV = { distance = 81, chance = 20.27 },
    },

    Indium = {
        IV  = { distance = 51, chance = 3.84  },
        LuV = { distance = 51, chance = 4.56  },
        ZPM = { distance = 51, chance = 5.01  },
        UV  = { distance = 50, chance = 8.79  },
        UHV = { distance = 50, chance = 13.43 },
        UEV = { distance = 50, chance = 25.91 },
    },

    ["Infinity Catalyst"] = {
        UV  = { distance = 91, chance = 6.17  },
        UHV = { distance = 91, chance = 8.52  },
        UEV = { distance = 91, chance = 13.50 },
        UIV = { distance = 81, chance = 14.41 },
        UMV = { distance = 81, chance = 20.27 },
        UXV = { distance = 81, chance = 20.27 },
    },

    Iron = {
        LV  = { distance = 151, chance = 60.00 },
        MV  = { distance = 151, chance = 60.00 },
        HV  = { distance = 1,   chance = 54.55 },
        EV  = { distance = 1,   chance = 54.55 },
        IV  = { distance = 1,   chance = 54.55 },
        LuV = { distance = 1,   chance = 75.00 },
        ZPM = { distance = 1,   chance = 75.00 },
    },

    Lanthanum = {
        IV  = { distance = 201, chance = 16.67 },
        LuV = { distance = 201, chance = 25.00 },
        ZPM = { distance = 201, chance = 30.00 },
        UV  = { distance = 201, chance = 30.00 },
        UHV = { distance = 201, chance = 30.00 },
        UEV = { distance = 30,  chance = 57.69 },
        UIV = { distance = 30,  chance = 75.00 },
    },

    Lead = {
        LV  = { distance = 101, chance = 18.03  },
        MV  = { distance = 121, chance = 18.03  },
        HV  = { distance = 121, chance = 13.17  },
        EV  = { distance = 121, chance = 11.46  },
        IV  = { distance = 5,   chance = 8.18   },
        LuV = { distance = 5,   chance = 12.09  },
        ZPM = { distance = 5,   chance = 16.67  },
        UV  = { distance = 5,   chance = 100.00 },
    },

    Lutetium = {
        IV  = { distance = 231, chance = 13.33 },
        LuV = { distance = 231, chance = 22.22 },
        ZPM = { distance = 231, chance = 40.00 },
        UV  = { distance = 231, chance = 40.00 },
        UHV = { distance = 231, chance = 40.00 },
    },

    Magnesium = {
        EV  = { distance = 181, chance = 22.73  },
        IV  = { distance = 181, chance = 16.56  },
        LuV = { distance = 181, chance = 17.86  },
        ZPM = { distance = 181, chance = 19.84  },
        UV  = { distance = 10,  chance = 53.19  },
        UHV = { distance = 10,  chance = 100.00 },
    },

    ["Mysterious Crystal"] = {
        IV  = { distance = 101, chance = 5.96  },
        LuV = { distance = 101, chance = 6.15  },
        ZPM = { distance = 101, chance = 6.59  },
        UV  = { distance = 101, chance = 11.22 },
        UHV = { distance = 101, chance = 17.04 },
        UEV = { distance = 101, chance = 37.23 },
        UIV = { distance = 101, chance = 41.43 },
        UMV = { distance = 101, chance = 95.65 },
        UXV = { distance = 101, chance = 95.65 },
    },

    Naquadah = {
        IV  = { distance = 121, chance = 7.43  },
        LuV = { distance = 121, chance = 7.75  },
        ZPM = { distance = 121, chance = 8.20  },
        UV  = { distance = 121, chance = 10.87 },
    },

    Nickel = {
        LV  = { distance = 13, chance = 8.99 },
        MV  = { distance = 13, chance = 8.06 },
        HV  = { distance = 5,  chance = 6.77 },
        EV  = { distance = 5,  chance = 6.05 },
        IV  = { distance = 5,  chance = 6.32 },
    },

    Niobium = {
        IV  = { distance = 151, chance = 7.05  },
        LuV = { distance = 151, chance = 7.41  },
        ZPM = { distance = 151, chance = 7.92  },
        UV  = { distance = 30,  chance = 12.90 },
        UHV = { distance = 30,  chance = 20.78 },
    },

    Phosphate = {
        IV  = { distance = 241, chance = 23.08  },
        LuV = { distance = 241, chance = 42.86  },
        ZPM = { distance = 241, chance = 100.00 },
        UV  = { distance = 241, chance = 100.00 },
        UHV = { distance = 241, chance = 100.00 },
        UEV = { distance = 231, chance = 100.00 },
        UIV = { distance = 231, chance = 100.00 },
    },

    ["PlatLine Dust"] = {
        ZPM = { distance = 181, chance = 4.76  },
        UV  = { distance = 25,  chance = 7.69  },
        UHV = { distance = 25,  chance = 19.35 },
        UEV = { distance = 25,  chance = 54.55 },
    },

    ["PlatLine Ore"] = {
        HV  = { distance = 13, chance = 5.02 },
        EV  = { distance = 13, chance = 4.14 },
        IV  = { distance = 13, chance = 4.30 },
        LuV = { distance = 13, chance = 6.05 },
        ZPM = { distance = 10, chance = 7.65 },
    },

    Quartz = {
        MV  = { distance = 101, chance = 13.53 },
        HV  = { distance = 101, chance = 10.70 },
        EV  = { distance = 101, chance = 8.52  },
        IV  = { distance = 25,  chance = 6.74  },
        LuV = { distance = 25,  chance = 8.49  },
        ZPM = { distance = 20,  chance = 10.55 },
    },

    Salt = {
        LV  = { distance = 201, chance = 100.00 },
        MV  = { distance = 201, chance = 100.00 },
        HV  = { distance = 201, chance = 60.00  },
        EV  = { distance = 201, chance = 60.00  },
        IV  = { distance = 241, chance = 46.15  },
    },

    Silicon = {
        HV  = { distance = 201, chance = 40.00 },
        EV  = { distance = 201, chance = 40.00 },
        IV  = { distance = 241, chance = 30.77 },
        LuV = { distance = 241, chance = 57.14 },
    },

    Tengam = {
        UEV = { distance = 20, chance = 100.00 },
        UIV = { distance = 20, chance = 100.00 },
        UMV = { distance = 20, chance = 100.00 },
        UXV = { distance = 20, chance = 100.00 },
    },

    ["Thaumium Dust"] = {
        HV  = { distance = 13, chance = 5.79 },
        EV  = { distance = 13, chance = 4.78 },
        IV  = { distance = 13, chance = 4.97 },
        LuV = { distance = 13, chance = 6.98 },
    },

    Tin = {
        LV  = { distance = 2, chance = 26.67 },
        MV  = { distance = 2, chance = 26.67 },
        HV  = { distance = 2, chance = 26.67 },
        EV  = { distance = 2, chance = 26.67 },
        IV  = { distance = 2, chance = 26.67 },
    },

    ["Tungsten-Titanium"] = {
        LV  = { distance = 181, chance = 25.00 },
        MV  = { distance = 181, chance = 25.00 },
        HV  = { distance = 181, chance = 11.76 },
        EV  = { distance = 181, chance = 9.09  },
        IV  = { distance = 181, chance = 6.62  },
        LuV = { distance = 181, chance = 7.14  },
    },

    ["Uranium-Plutonium"] = {
        HV  = { distance = 41, chance = 5.21 },
        EV  = { distance = 41, chance = 4.19 },
        IV  = { distance = 41, chance = 3.76 },
        LuV = { distance = 41, chance = 4.56 },
        ZPM = { distance = 30, chance = 5.26 },
    },

}

local M = {}

-- Drone chance/distance tables, keyed by miner MFU component name.
M.chances = {
    projectmoduleminert1 = mk1,
    projectmoduleminert2 = mk2,
    projectmoduleminert3 = mk3,
}

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
function M.applyTargets(targetList)
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
function M.buildLookupList()
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
function M.buildOresByAsteroid()
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


return M
