
---@class Feature_Housing : Feature
local Housing = {
    Furniture = {}, ---@type table<GUID, Feature_Housing_Furniture>

    ---@type table<Feature_Housing_FurnitureType, string>
    FURNITURE_TYPE_NAMES = {
        Chair = "Chairs",
        Table = "Tables",
        Bed = "Beds",
        Container = "Containers",
        Light = "Lights",
        Facility = "Facilities",
        Trinket = "Trinkets",
        Painting = "Paintings",
        Door = "Doors",
        Statue = "Statues",
        Interactable = "Interactables",
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetFurnitureTypeName = {}, ---@type SubscribableEvent<Feature_Housing_Hook_GetFurnitureTypeName>
    },
}
Epip.AddFeature("Housing", "Housing", Housing)
Housing:Debug()

---@alias Feature_Housing_FurnitureType string|"Chair"|"Table"|"Bed"|"Container"|"Light"|"Facility"|"Trinket"|"Painting"|"Door"|"Clutter"|"Hangable"|"Statue"|"Decor"|"Interactables"|"Other"

---@class Feature_Housing_Furniture
---@field TemplateGUID GUID
---@field Name string
---@field Type Feature_Housing_FurnitureType
local _Furniture = {}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_Housing_Hook_GetFurnitureTypeName
---@field Type Feature_Housing_FurnitureType
---@field Name string Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---@return Feature_Housing_Furniture?
function Housing.GetFurniture(templateGUID)
    return Housing.Furniture[templateGUID]
end

---Returns a table of furnitures, sorted by type.
---@return table<Feature_Housing_FurnitureType, table<GUID, Feature_Housing_Furniture>>
function Housing.GetFurnitureTable()
    local furniture = {}

    for guid,data in pairs(Housing.Furniture) do
        local objType = data.Type
        if not furniture[objType] then furniture[objType] = {} end

        furniture[objType][guid] = data
    end

    return furniture
end

---@param data Feature_Housing_Furniture
function Housing.RegisterFurniture(data)
    Inherit(data, _Furniture)

    Housing.Furniture[data.TemplateGUID] = data
end

---@param furnitureType Feature_Housing_FurnitureType
function Housing.GetfurnitureTypeName(furnitureType)
    ---@type Feature_Housing_Hook_GetFurnitureTypeName
    local hook = {
        Type = furnitureType,
        Name = Housing.FURNITURE_TYPE_NAMES[furnitureType] or furnitureType,
    }

    Housing.Hooks.GetFurnitureTypeName:Throw(hook)

    return hook.Name
end

---------------------------------------------
-- SETUP
---------------------------------------------

---@type Feature_Housing_Furniture[]
local funiture = {
    {
        Name = "Simple Table",
        TemplateGUID = "54dd6743-652d-43a6-a0da-1fe830c748f6",
        Type = "Table",
    },
    {
        Name = "Bonfire",
        TemplateGUID = "130692f2-a065-4168-be66-27cf4df2fff0",
        Type = "Light",
    },
    {
        Name = "Sack",
        TemplateGUID = "9cd8dce2-a876-4c82-93e2-80405df6b3dd",
        Type = "Container",
    },
    {
        Name = "Well",
        TemplateGUID = "4a68c2d2-7f84-4547-87e5-1b34763be80d",
        Type = "Facility",
    },
    {
        Name = "Wall Torch",
        TemplateGUID = "d5e434cf-3aed-4110-a0e4-60912f855cb9",
        Type = "Light",
    },
    {
        Name = "Target",
        TemplateGUID = "4ea5d2e7-9eef-4fa6-b499-def0bec1dd0e",
        Type = "Facility",
    },
    {
        Name = "Coffe Table",
        TemplateGUID = "40c14ba8-7db1-4337-ba56-36b1a310b305",
        Type = "Table",
    },
    {
        Name = "Training Dummy",
        TemplateGUID = "24a466e5-9f0c-41f6-b4dd-74443858cead",
        Type = "Facility",
    },
    {
        Name = "Brazier",
        TemplateGUID = "89801429-59d5-4846-a5f4-c8f79d77ee5f",
        Type = "Light",
    },
    {
        Name = "Bedroll",
        TemplateGUID = "eae64571-4e99-4036-b3e2-1dcc6da78c89",
        Type = "Bed",
    },
    {
        Name = "Barrel",
        TemplateGUID = "a2b18299-6ee5-48fe-a34b-4e212eb405a7",
        Type = "Container",
    },
    {
        Name = "Reinforced Crate",
        TemplateGUID = "71b52721-a4d7-4eee-8ce8-fe5f1f5bddb4",
        Type = "Container",
    },
    {
        Name = "Crude Bench",
        TemplateGUID = "a350c92c-8af2-45f3-9610-d889b1d72231",
        Type = "Chair",
    },
    {
        Name = "Short Ladder",
        TemplateGUID = "a058fa9c-74c9-4eb2-baa0-a182a766a5fc",
        Type = "Facility",
    },
    {
        Name = "Sack Pile",
        TemplateGUID = "1ed7a061-5535-4958-87e8-cdffe2bf2dcd",
        Type = "Container",
    },
    {
        Name = "Stool",
        TemplateGUID = "e20c2413-ee40-4dee-9eca-3bf0863e13d5",
        Type = "Chair",
    },
    {
        Name = "Pew",
        TemplateGUID = "49f624e6-d7c5-4ffc-8468-788b7cf06824",
        Type = "Chair",
    },
    {
        Name = "Globe",
        TemplateGUID = "da3682f8-38d7-4d67-b245-352833491ef8",
        Type = "Trinket",
    },
    {
        Name = "Simple Chair",
        TemplateGUID = "956438cd-7114-4e92-bbcb-85486c20de30",
        Type = "Chair",
    },
    {
        Name = "Painting of Alexandar",
        TemplateGUID = "2ac8eff3-c582-499b-97ac-e605fd0f0396",
        Type = "Painting",
    },
    {
        Name = "Dressing Panel",
        TemplateGUID = "cf8797ec-8f01-42b7-8821-79ecdf3d2682",
        Type = "Decor",
    },
    {
        Name = "Candles",
        TemplateGUID = "728b84a6-3929-48eb-9368-631a0614e38d",
        Type = "Light",
    },
    {
        Name = "Aeve Van Algaris",
        TemplateGUID = "196baf1d-0d1c-4214-8e8e-61631450821b",
        Type = "Painting",
    },
    {
        Name = "Jail Door",
        TemplateGUID = "358ed990-5cbe-4972-a55e-901219f044d3",
        Type = "Door",
    },
    {
        Name = "Standing Torch",
        TemplateGUID = "02e4b0a4-b2de-4470-846e-1d76be4a0751",
        Type = "Light",
    },
    {
        Name = "Danrun",
        TemplateGUID = "1dcbc71a-15b6-49c8-97b5-10992e50917f",
        Type = "Painting",
    },
    {
        Name = "Rolled Up Carpet",
        TemplateGUID = "37157bc2-2f63-4c28-8bc3-8bec90cb3003",
        Type = "Clutter",
    },
    {
        Name = "Rope",
        TemplateGUID = "12236881-db9f-4086-9f42-b4c729ef593f",
        Type = "Clutter",
    },
    {
        Name = "Tool Rack",
        TemplateGUID = "ac016da7-9947-4253-908d-6661fec476d8",
        Type = "Hangable",
    },
    {
        Name = "Old Plate",
        TemplateGUID = "ed957a87-f07a-4d22-94b8-116e2781c174",
        Type = "Trinket",
    },
    {
        Name = "Open Sack",
        TemplateGUID = "ca5bdf35-1bbc-42b1-bfa8-29f07ef91841",
        Type = "Container",
    },
    {
        Name = "Reinforced Barrel",
        TemplateGUID = "820f165e-62f5-4de4-a739-6274cfac1c8e",
        Type = "Container",
    },
    {
        Name = "Sign Post",
        TemplateGUID = "b775b6c8-a349-4c30-831b-55ada69510b1",
        Type = "Other",
    },
    {
        Name = "Lamp Post",
        TemplateGUID = "b9624923-d8ca-45da-82a1-6839bf8d1e5b",
        Type = "Light",
    },
    {
        Name = "? Statue",
        TemplateGUID = "084d307e-2929-45db-a6f2-6d14c62e1172",
        Type = "Statue",
    },
    {
        Name = "Tree Stump",
        TemplateGUID = "86835e6e-a56d-42fe-b876-037f37280a01",
        Type = "Container",
    },
    {
        Name = "Small Haystack",
        TemplateGUID = "e91ff533-39d6-4990-ae3f-f392f85eb7f4",
        Type = "Other",
    },
    {
        Name = "Haystack",
        TemplateGUID = "dd532b69-d6d7-4514-9b64-7e5c9165dfcd",
        Type = "Other",
    },
    {
        Name = "Ornate Chest",
        TemplateGUID = "4d4af4a3-5916-4b83-b2c4-d6bc454544ed",
        Type = "Container",
    },
    {
        Name = "Oil Barrel",
        TemplateGUID = "1b34b32c-e96c-404e-90cc-054cb549c558",
        Type = "Facility",
    },
    {
        Name = "Bench",
        TemplateGUID = "efa6d1fb-2d03-4aff-a654-382d751e0029",
        Type = "Chair",
    },
    {
        Name = "Tall Vase",
        TemplateGUID = "ce4583ad-e3af-4fca-9379-e52fe1781a0c",
        Type = "Container",
    },
    {
        Name = "Water Barrel",
        TemplateGUID = "59b25792-1cc2-4364-92eb-89aca8fb8425",
        Type = "Facility",
    },
    {
        Name = "Campfire",
        TemplateGUID = "6fee7bbb-4adc-4222-a5b1-82fcfb8d1230",
        Type = "Light",
    },
    {
        Name = "Ceramic Jug",
        TemplateGUID = "cd69c666-426c-4e6b-9cf4-b55777d73d2f",
        Type = "Trinket",
    },
    {
        Name = "Tall Broken Vase",
        TemplateGUID = "2431067a-9db0-4205-ba10-c92d69c437be",
        Type = "Clutter",
    },
    {
        Name = "Fat Vase",
        TemplateGUID = "0c376265-255f-4cff-9311-6223d2a2ec73",
        Type = "Container",
    },
    {
        Name = "Vase",
        TemplateGUID = "c101e371-fb93-41e1-ac9b-fde41e85d76e",
        Type = "Container",
    },
    {
        Name = "Cooking Pot",
        TemplateGUID = "792f35b4-e700-434d-8feb-a1af3f35a034",
        Type = "Facility",
    },
    {
        Name = "Flower Pot",
        TemplateGUID = "ae32612f-ee16-444a-aece-a8cb35aac086",
        Type = "Decor",
    },
    {
        Name = "Tall Candles",
        TemplateGUID = "ef4d1dd9-8d2a-4677-98c3-bb9dd52c0865",
        Type = "Light",
    },
    {
        Name = "Anvil",
        TemplateGUID = "4fcd8129-ad8c-46ff-9373-329387e5b214",
        Type = "Facility",
    },
    {
        Name = "Basket",
        TemplateGUID = "024f59ea-3f37-4e93-b7d9-54f18b5e7541",
        Type = "Decor",
    },
    {
        Name = "Fishing Rod",
        TemplateGUID = "90cdb693-3564-415a-a8fa-4027b7f76f41",
        Type = "Other",
    },
    {
        Name = "Fish Rack",
        TemplateGUID = "307af24b-734a-445b-9325-7d55944e87cd",
        Type = "Container",
    },
    {
        Name = "Open Pot",
        TemplateGUID = "bd240774-79d9-4dd2-ad4f-ccc0660c7731",
        Type = "Clutter",
    },
    {
        Name = "Pot Lid",
        TemplateGUID = "c53675dc-ffc3-43a8-b829-220d01404840",
        Type = "Clutter",
    },
    {
        Name = "Small Pot",
        TemplateGUID = "f2774e19-7970-4eda-b423-28d6d75c4629",
        Type = "Clutter",
    },
    {
        Name = "Crude Torch",
        TemplateGUID = "d0a03afd-059b-41e5-9446-7c6540270305",
        Type = "Light",
    },
    {
        Name = "Wooden Box",
        TemplateGUID = "6f65dd10-5703-4a44-9c76-2577fd9f9366",
        Type = "Table",
    },
    {
        Name = "Well-Worn Chest",
        TemplateGUID = "db7066f9-3dc5-47b3-a318-dbbc3a0fdace",
        Type = "Container",
    },
    {
        Name = "Crude Ladder",
        TemplateGUID = "93304308-825a-419d-b66a-6a91ce987727",
        Type = "Facility",
    },
    {
        Name = "Bowl",
        TemplateGUID = "aeb79511-a929-43b4-9734-7e62da001c2b",
        Type = "Clutter",
    },
    {
        Name = "Skull Candle",
        TemplateGUID = "8c255787-ee37-447a-a25d-c3d5fcb52a64",
        Type = "Light",
    },
    {
        Name = "Fancy Candle",
        TemplateGUID = "f21393ff-31bc-46ff-a024-985e72cd83f5",
        Type = "Light",
    },
    {
        Name = "Candelabra",
        TemplateGUID = "e1a4cbd6-7508-4fa2-810b-ac15e0d84ae2",
        Type = "Light",
    },
    {
        Name = "Lever",
        TemplateGUID = "c42768fb-ee31-459c-b0c3-1c92efaf0304",
        Type = "Interactable",
    },
    {
        Name = "Small Brazier",
        TemplateGUID = "2b3a494e-a257-4ca0-b1f6-86c7ab75f493",
        Type = "Light",
    },
    {
        Name = "Huge Door",
        TemplateGUID = "d1617e38-b9d1-4222-b7ba-58d83a8d4180",
        Type = "Door",
    },
    {
        Name = "Dog Cage Door",
        TemplateGUID = "98cb6feb-c5eb-40cb-a966-4951f7ab40b0",
        Type = "Door",
    },
    {
        Name = "Wardrove",
        TemplateGUID = "05351551-19de-45bc-b593-15b42dee409a",
        Type = "Container",
    },
    {
        Name = "Desk",
        TemplateGUID = "d1dc717d-2744-4fb3-8925-61c3916df880",
        Type = "Container",
    },
    {
        Name = "Screen",
        TemplateGUID = "8f9fde4e-e85a-4785-b003-aecea3fb6593",
        Type = "Decor",
    },
    {
        Name = "Blue Bed",
        TemplateGUID = "0b9bea17-d270-415b-aa05-963e44b7c381",
        Type = "Bed",
    },
    {
        Name = "Dresser",
        TemplateGUID = "f4e21a23-2f75-478b-b13a-fae102f506d7",
        Type = "Container",
    },
    {
        Name = "Empty Cup",
        TemplateGUID = "bb6e5fbd-6adc-406b-978a-214a8c178cbb",
        Type = "Clutter",
    },
    {
        Name = "That thing where you put your silverware",
        TemplateGUID = "15f6b829-8f6c-4132-bce9-8b9a5bbcfe9c",
        Type = "Container",
    },
    {
        Name = "Torture Bed A",
        TemplateGUID = "578db52c-d993-4098-98ff-b51a372374e1",
        Type = "Bed",
    },
    {
        Name = "Torture Bed B",
        TemplateGUID = "08415b20-279f-4c24-89ec-de16c503e528",
        Type = "Bed",
    },
    {
        Name = "Torture Bed C",
        TemplateGUID = "00549009-f9f3-462a-bc8f-a3922eca6a55",
        Type = "Bed",
    },
    {
        Name = "Coffin",
        TemplateGUID = "480f023e-8f64-4b56-b411-c634a2e901d1",
        Type = "Container",
    },
    -- {
    --     Name = "",
    --     TemplateGUID = "",
    --     Type
    -- },
}
for _,data in ipairs(funiture) do
    Housing.RegisterFurniture(data)
end