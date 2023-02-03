
local CommonStrings = Text.CommonStrings
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

QuickInventory.CONSUMABLE_ACTIONS = Set.Create({
    "Consume",
    "UseSkill",
})
QuickInventory.POTION_TAGS = Set.Create({
    "POTIONS",
    "Potion", -- Yes, these are 2 different tags used interchangeably by Larian.
    "ORGANIZE_POTION",
})
QuickInventory.FOOD_AND_DRINK_TAGS = Set.Create({
    "FOOD",
    "ORGANIZE_FOOD",

    "DRINK", -- Similar case to POTIONS and Potion.
    "BEVERAGES",
})
QuickInventory.SCROLL_AND_GRENADES_TAGS = Set.Create({
    "SCROLLS",
    "ORGANIZE_SCROLL",
    "GRENADES",
    "ORGANIZE_GRENADE",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.ConsumablesCategory = QuickInventory:RegisterSetting("ConsumablesCategory", {
    Type = "Choice",
    Name = QuickInventory.TranslatedStrings.ConsumablesCategory_Name,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Potions", NameHandle = CommonStrings.Potions.Handle},
        {ID = "ScrollsAndGrenades", NameHandle = QuickInventory.TranslatedStrings.ScrollsAndGrenades.Handle},
        {ID = "FoodAndDrinks", NameHandle = CommonStrings.FoodAndDrinks.Handle},
    },
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Consumables filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Consumables" then
        local subTypeSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.ConsumablesCategory)
        local hasRelevantUseAction = false

        for actionType in QuickInventory.CONSUMABLE_ACTIONS:Iterator() do
            if Item.HasUseAction(item, actionType) then
                hasRelevantUseAction = true
                break
            end
        end

        visible = visible and hasRelevantUseAction

        if subTypeSetting ~= "Any" then
            if subTypeSetting == "Potions" then
                visible = visible and QuickInventory.ItemHasRelevantTag(item, QuickInventory.POTION_TAGS)
            elseif subTypeSetting == "ScrollsAndGrenades" then
                visible = visible and QuickInventory.ItemHasRelevantTag(item, QuickInventory.SCROLL_AND_GRENADES_TAGS)
            elseif subTypeSetting == "FoodAndDrinks" then
                visible = visible and QuickInventory.ItemHasRelevantTag(item, QuickInventory.FOOD_AND_DRINK_TAGS) and not QuickInventory.ItemHasRelevantTag(item, QuickInventory.POTION_TAGS) -- Excludes potions.
            end
        end
    end
    
    ev.Visible = visible
end)