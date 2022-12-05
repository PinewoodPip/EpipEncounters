
---------------------------------------------
-- Default data for the Fishing feature.
---------------------------------------------

local Fishing = Epip.GetFeature("Feature_Fishing")

---@type table<string, Feature_Fishing_Fish>
local fishes = {
    ["FishA"] = {
        Icon = "Item_CON_Food_Fish_A",
    },
    ["FishB"] = {
        Icon = "Item_CON_Food_Fish_B",
    },
    ["FishC"] = {
        Icon = "Item_CON_Food_Fish_C",
    },
    ["FishD"] = {
        Icon = "Item_CON_Food_Fish_D",
    },
    ["FishE"] = {
        Icon = "Item_CON_Food_Fish_E",
    },
}

---@type Feature_Fishing_Region[]
local regions = {
    {
        LevelID = "FJ_FortJoy_Main",
        Bounds = Vector.Create(390, 236, 100, 100),
        Fish = {
            {
                ID = "FishA",
                Weight = 1,
            },
            {
                ID = "FishB",
                Weight = 1,
            },
            {
                ID = "FishC",
                Weight = 1,
            },
            {
                ID = "FishD",
                Weight = 1,
            },
            {
                ID = "FishE",
                Weight = 1,
            },
        },
    }
}

for id,fish in pairs(fishes) do
    fish.ID = id
    fish.NameHandle = Fishing.TSK[id .. "_Name"]
    fish.DescriptionHandle = Fishing.TSK[id .. "_Description"]

    Fishing.RegisterFish(fish)
end

for _,region in ipairs(regions) do
    Fishing.RegisterRegion(region)
end