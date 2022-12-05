
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_Fishing : Feature
local Fishing = {
    FISHING_ROD_TEMPLATES = Set.Create({
        "81cbf17f-cc71-4e09-9ab3-ca2a5cb0cefc"
    }),

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsFishingRod = {}, ---@type Event<Feature_Fishin_Hook_IsFishingRod>
    }
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
-- METHODS
---------------------------------------------

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