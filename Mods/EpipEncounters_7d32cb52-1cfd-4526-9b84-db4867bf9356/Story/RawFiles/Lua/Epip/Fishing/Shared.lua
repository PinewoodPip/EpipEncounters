
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_Fishing : Feature
local Fishing = {
    _Fish = {}, ---@type table<string, Feature_Fishing_Fish>
    _Regions = DefaultTable.Create({}), ---@type DataStructures_DefaultTable<string, Feature_Fishing_Region[]>

    FISHING_ROD_TEMPLATES = Set.Create({
        "81cbf17f-cc71-4e09-9ab3-ca2a5cb0cefc"
    }),

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        ["h467929cdge276g4833gbcffg7294c0a60514"] = {
            Text = "Fish A",
            ContextDescription = "TODO",
            LocalKey = "FishA_Name",
        },
        ["hb651eb42g5092g4ed5g96faga5ba0df7d284"] = {
            Text = "Fish A",
            ContextDescription = "TODO",
            LocalKey = "FishA_Description",
        },
        ["h96c20d10g5931g4cddga3c0ge24d8188da43"] = {
            Text = "Fish B",
            ContextDescription = "TODO",
            LocalKey = "FishB_Name",
        },
        ["h2fd692d7g6559g4775gbd79g85956021916a"] = {
            Text = "Fish B",
            ContextDescription = "TODO",
            LocalKey = "FishB_Description",
        },
        ["h3cb365d5gcc3fg4031gafccga6ce52313d17"] = {
            Text = "Fish C",
            ContextDescription = "TODO",
            LocalKey = "FishC_Name",
        },
        ["h4502abf5g22d2g479bgb078g6619dcc1dfdb"] = {
            Text = "Fish C",
            ContextDescription = "TODO",
            LocalKey = "FishC_Description",
        },
        ["h4c7b5054gd964g4252g944eg534a8979a1a5"] = {
            Text = "Fish D",
            ContextDescription = "TODO",
            LocalKey = "FishD_Name",
        },
        ["h1f160d38g7650g411bg8ddcg730de9bd44c2"] = {
            Text = "Fish D",
            ContextDescription = "TODO",
            LocalKey = "FishD_Description",
        },
        ["h66ec8f55g6a04g4a80ga160g1e71b2bb2e15"] = {
            Text = "Fish E",
            ContextDescription = "TODO",
            LocalKey = "FishE_Name",
        },
        ["h154469f8g092dg4780g9b98g903799adfb8f"] = {
            Text = "Fish E",
            ContextDescription = "TODO",
            LocalKey = "FishE_Description",
        },
    },
    Hooks = {
        IsFishingRod = {}, ---@type Event<Feature_Fishin_Hook_IsFishingRod>
    },
}
Epip.RegisterFeature("Fishing", Fishing)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_Fishin_Hook_IsFishingRod
---@field Character Character
---@field Item Item
---@field IsFishingRod boolean Hookable. Defaults to false.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Fishing_Fish : TextLib_DescribableObject
---@field ID string
---@field Icon string

---@class Feature_Fishing_Region
---@field LevelID string
---@field Bounds Vector4 X, Y, width, height.
---@field Fish Feature_Fishing_Region_FishEntry[]

---@class Feature_Fishing_Region_FishEntry
---@field ID string ID of the fish.
---@field Weight number Relative chance for the fish to be picked.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Fishing_Fish
function Fishing.RegisterFish(data)
    if not data.ID then Fishing:Error("RegisterFish", "Data must include ID.") end

    Text.MakeDescribable(data)

    Fishing._Fish[data.ID] = data
end

---@param data Feature_Fishing_Region
function Fishing.RegisterRegion(data)
    table.insert(Fishing._Regions[data.LevelID], data)
end

---@param levelID string
---@return Feature_Fishing_Region[]
function Fishing.GetRegions(levelID)
    return Fishing._Regions[levelID]
end

---@param id string
---@return Feature_Fishing_Fish?
function Fishing.GetFish(id)
    return Fishing._Fish[id]
end

---@param pos Vector3D
---@return Feature_Fishing_Region?
function Fishing.GetRegionAt(pos)
    local levelID = Entity.GetLevel().LevelDesc.LevelName
    local regions = Fishing.GetRegions(levelID)
    local region

    for _,otherRegion in ipairs(regions) do
        local bounds = otherRegion.Bounds
        if pos[1] >= bounds[1] and pos[1] <= bounds[1] + bounds[3] and pos[3] >= bounds[2] and pos[3] <= bounds[2] + bounds[4] then
            region = otherRegion
            break
        end
    end

    return region
end

---@param region Feature_Fishing_Region
---@return Feature_Fishing_Fish
function Fishing.GetRandomFish(region)
    local totalWeight = 0
    local fishID
    local seed

    for _,entry in ipairs(region.Fish) do
        local fish = Fishing.GetFish(entry.ID)
        if not fish then Fishing:Error("GetRandomFish", "Found unregistered fish " .. entry.ID) end -- TODO move to registerregion

        totalWeight = totalWeight + entry.Weight
    end

    seed = totalWeight * math.random()

    for _,entry in ipairs(region.Fish) do
        seed = seed - entry.Weight

        if seed <= 0 then
            fishID = entry.ID
            break
        end
    end

    return Fishing.GetFish(fishID)
end

---@param char Character
---@return boolean
function Fishing.HasFishingRodEquipped(char)
    local item = Item.GetEquippedItem(char, "Weapon")
    local event = Fishing.Hooks.IsFishingRod:Throw({
        Character = char,
        Item = item,
        IsFishingRod = false,
    })

    return event.IsFishingRod
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Check for fishing rod template.
Fishing.Hooks.IsFishingRod:Subscribe(function (ev)
    if Fishing.FISHING_ROD_TEMPLATES:Contains(ev.Item.RootTemplate.Id) then
        ev.IsFishingRod = true
    end
end)