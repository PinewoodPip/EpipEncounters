
local V = Vector.Create

---------------------------------------------
-- Default data for the Fishing feature.
---------------------------------------------

local Fishing = Epip.GetFeature("Feature_Fishing")

---@type table<string, Feature_Fishing_Fish>
local fishes = {
    -- ["FishA"] = {
    --     Icon = "Item_CON_Food_Fish_A",
    --     TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d",
    -- },
    -- ["FishB"] = {
    --     Icon = "Item_CON_Food_Fish_B",
    --     TemplateID = "e9f60640-98dd-480d-9531-7f016bd0cced",
    -- },
    -- ["FishC"] = {
    --     Icon = "Item_CON_Food_Fish_C",
    --     TemplateID = "b7101e9c-2305-4015-8872-b46bbf13d237",
    -- },
    -- ["FishD"] = {
    --     Icon = "Item_CON_Food_Fish_D",
    --     TemplateID = "6245ee9e-69b7-426a-97ce-e7f491d42129",
    -- },
    -- ["FishE"] = {
    --     Icon = "Item_CON_Food_Fish_E",
    --     TemplateID = "93c60d6d-7db1-4e53-b5ac-f1fefbf832a9",
    -- },

    -- Poisoned variants
    -- ["FishA_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_A",
    --     TemplateID = "8c693596-08d8-4ff4-b01d-e0e40dae5a51",
    -- },
    -- ["FishB_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_B",
    --     TemplateID = "a3297c8e-1cad-463d-9b0b-ac8be948824c",
    -- },
    -- ["FishC_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_C",
    --     TemplateID = "7a8e19cd-26cd-446a-b2af-94a0700fca4e",
    -- },
    -- ["FishD_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_D",
    --     TemplateID = "36f59d4a-1a8a-42c3-8818-9e8ec9507fcc",
    -- },
    -- ["FishE_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_E",
    --     TemplateID = "8c6f9d68-5455-41dd-88b8-9b6291f46109",
    -- },
    -- ["FishF_Poisoned"] = {
    --     Icon = "Item_CON_Food_Fish_F",
    --     TemplateID = "c3900e31-3a0e-4136-b4e2-a79a99e4becd",
    -- },

    -- Void-tainted variants
    -- ["FishA_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_A",
    --     TemplateID = "ccab0994-cc3a-4ae6-9b45-2a2263cc677f",
    -- },
    -- ["FishB_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_B",
    --     TemplateID = "ea14f970-ac06-463a-a6f2-7a5fb9a268ac",
    -- },
    -- ["FishC_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_C",
    --     TemplateID = "c241b56c-e0e7-406f-b426-ad5d96b2c93b",
    -- },
    -- ["FishD_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_D",
    --     TemplateID = "7be66d14-a96c-4b0f-8650-8cbd3cd26bd0",
    -- },
    -- ["FishE_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_E",
    --     TemplateID = "47473dc2-a5a9-49f3-bb27-d8e151fb1cec",
    -- },
    -- ["FishF_Tainted"] = {
    --     Icon = "Item_CON_Food_Fish_F",
    --     TemplateID = "42b291a3-4922-482b-b256-b4744655177a",
    -- },

    -- Shells
    -- ["Shell_A"] = {
    --     TemplateID = "ef10b963-05b5-4db9-9ce7-1c9dadd99bc1",
    -- },
    -- ["Shell_B"] = {
    --     TemplateID = "06848e53-53b8-4eb6-bd2d-2802a0b2d35e",
    -- },
    -- ["Shell_Pilgrim"] = {
    --     TemplateID = "d2f37ffd-bcb4-4237-9faf-b2b96957eb5a",
    -- },
    -- ["Shell_Big_A"] = {
    --     TemplateID = "36900f30-df7d-4922-bd47-ff5238048a2e",
    -- },
    -- ["Shell_Big_B"] = {
    --     TemplateID = "8d9be96d-2731-47d8-abe0-469810e37ce4",
    -- },
    -- ["Shell_Big_C"] = {
    --     TemplateID = "a1e2c015-f94d-4009-80a3-dd4f0e003d80",
    -- },

    -- Misc
    ["Starfish"] = {
        Icon = "Item_HAR_Starfish_A",
        TemplateID = "77077fc8-470c-483d-bb13-fa506cfcf229",
    },
    -- ["SkeletonFish"] = {
    --     Icon = "Item_JUNK_FishSkeleton_A",
    --     TemplateID = "f80baa33-442d-443d-b573-cd5169473147",
    -- },
    -- ["Pearl"] = {
    --     Icon = "Item_HAR_Pearl_A",
    --     TemplateID = "1bde972a-fcdf-4d63-8227-955437cc8255",
    -- },

    ["Bluefish"] = {
        Icon = "Item_CON_Food_Fish_A",
        TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d", -- Temp!
    },
    ["Perch"] = {
        Icon = "Item_CON_Food_Fish_A",
        TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d", -- Temp!
    },
    ["Swordfish"] = {
        Icon = "Item_CON_Food_Fish_F",
        TemplateID = "6e06b364-76ae-4f2b-911b-af879adeec72",
    },
    ["Wolffish"] = {
        Icon = "Item_CON_Food_Fish_A",
        TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d", -- Temp!
    },
    ["Moi"] = {
        Icon = "Item_CON_Food_Fish_A",
        TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d", -- Temp!
    },
    ["Mahimahi"] = {
        Icon = "Item_CON_Food_Fish_A",
        TemplateID = "35bfe2cf-7a83-422c-b8c4-8a90b0c0e55d", -- Temp!
    },
}

---@type Feature_Fishing_Region[]
local regions = {
    -- FJ_FortJoy_Main
    {
        ID = "FJ_StartingBeach",
        LevelID = "FJ_FortJoy_Main",
        Bounds = Vector.Create(128, 410, 216, 189),
        Fish = {
            {
                ID = "Pearl",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_PrisonerArea",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(83, 257, 291, 52),
        Fish = {
            {
                ID = "Pearl",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_TurtleBeach",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(218, 416, 324, 341),
        Fish = {
            {
                ID = "Pearl",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_NorthCoast",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(299, 341, 664, 220),
        Fish = {
            {
                ID = "Swordfish",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_SouthCoast",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(303, 120, 591, 5),
        Fish = {
            {
                ID = "Starfish",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_AmadiaSanctuary",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(419, 41, 434, 12),
        RequiresWater = false,
        Priority = 99,
        Fish = {
            {
                ID = "Pearl",
                Weight = 0.5,
            },
        },
    },
    {
        ID = "FJ_DragonBeach",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(533, 209, 608, 86),
        Fish = {
            {
                ID = "Pearl",
                Weight = 0.5,
            },
        },
    },
    -- No deepwater here; this one will need multiple bounds defined.
    -- {
    --     ID = "FJ_ElfCave",
    --     LevelID = "FJ_FortJoy_Main",
    --     Bounds = V(475, 557, 545, 481),
    --     Fish = {
    --         {
    --             ID = "Pearl",
    --             Weight = 0.5,
    --         },
    --     },
    -- },
    {
        ID = "FJ_FortDungeons",
        LevelID = "FJ_FortJoy_Main",
        Bounds = V(308, 597, 327, 567),
        RequiresWater = false,
        Fish = {
            {
                ID = "SkeletonFish",
                Weight = 0.5,
            },
        },
    },
}

for id,fish in pairs(fishes) do
    fish.ID = id
    
    fish.NameHandle = Fishing:GetTranslatedStringHandleForKey(id .. "_Name")
    fish.DescriptionHandle = Fishing:GetTranslatedStringHandleForKey(id .. "_Description")

    Fishing.RegisterFish(fish)
end

for _,region in ipairs(regions) do
    local bounds = region.Bounds

    -- Set the bounds to use width/height for 3rd and 4th element, instead of coords.
    bounds[3] = bounds[3] - bounds[1]
    bounds[4] = bounds[2] - bounds[4]

    Fishing.RegisterRegion(region)
end