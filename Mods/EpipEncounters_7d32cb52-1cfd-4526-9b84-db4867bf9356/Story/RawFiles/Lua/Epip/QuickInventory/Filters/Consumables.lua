
local CommonStrings = Text.CommonStrings
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local UI = QuickInventory.UI

QuickInventory.CONSUMABLE_ACTIONS = Set.Create({
    "Consume",
    "UseSkill",
})
QuickInventory.POTION_TAGS = Set.Create({
    "POTIONS",
    "Potion", -- Yes, these are 2 different tags used interchangeably by Larian.
    "ORGANIZE_POTION",
})
QuickInventory.FOOD_TAGS = Set.Create({
    "FOOD",
    "ORGANIZE_FOOD",
})
QuickInventory.DRINK_TAGS = Set.Create({
    "DRINK", -- Similar case to POTIONS and Potion.
    "BEVERAGES",
    "ORGANIZE_DRINK",
})
QuickInventory.SCROLL_TAGS = Set.Create({
    "SCROLLS",
    "ORGANIZE_SCROLL",
})
QuickInventory.GRENADE_TAGS = Set.Create({
    "GRENADES",
    "ORGANIZE_GRENADE",
})
QuickInventory.ARROW_TAGS = Set.Create({
    "ARROWS",
    "ORGANIZE_ARROW",
})

-- Sorting order from most important to least.
QuickInventory.CONSUMABLES_SORT_ORDER = {
    QuickInventory.SCROLL_TAGS,
    QuickInventory.GRENADE_TAGS,
    QuickInventory.ARROW_TAGS,
    QuickInventory.POTION_TAGS,
    QuickInventory.FOOD_TAGS,
    QuickInventory.DRINK_TAGS,
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param item EclItem
---@return boolean
local function IsScrollOrGrenade(item)
    return QuickInventory.ItemHasRelevantTag(item, QuickInventory.SCROLL_TAGS) or QuickInventory.ItemHasRelevantTag(item, QuickInventory.GRENADE_TAGS)
end

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
                visible = visible and IsScrollOrGrenade(item)
            elseif subTypeSetting == "FoodAndDrinks" then
                local isFoodOrDrink = QuickInventory.ItemHasRelevantTag(item, QuickInventory.FOOD_TAGS) or QuickInventory.ItemHasRelevantTag(item, QuickInventory.DRINK_TAGS)

                visible = visible and isFoodOrDrink and not QuickInventory.ItemHasRelevantTag(item, QuickInventory.POTION_TAGS) -- Excludes potions.
            end
        end
    end

    ev.Visible = visible
end)

-- Sorting order for Consumables:
-- Scrolls, arrows, grenades, other items.
QuickInventory.Hooks.SortItems:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Consumables" then
        local itemAPriority = nil
        local itemBPriority = nil

        -- Set priority based on tags.
        for priority,tagSet in ipairs(QuickInventory.CONSUMABLES_SORT_ORDER) do
            if itemAPriority == nil and QuickInventory.ItemHasRelevantTag(ev.ItemA, tagSet) then
                itemAPriority = priority
            end
            if itemBPriority == nil and QuickInventory.ItemHasRelevantTag(ev.ItemB, tagSet) then
                itemBPriority = priority
            end

            if itemAPriority ~= nil and itemBPriority ~= nil then
                break
            end
        end

        itemAPriority = itemAPriority or (#QuickInventory.CONSUMABLES_SORT_ORDER + 1)
        itemBPriority = itemBPriority or (#QuickInventory.CONSUMABLES_SORT_ORDER + 1)

        -- Lower priority appears first.
        ev.Result = itemAPriority < itemBPriority
        ev:StopPropagation()
    end
end, {StringID = "DefaultImplementation_Consumables"})

-- Render category settings.
UI.Events.RenderSettings:Subscribe(function (ev)
    if ev.ItemCategory == "Consumables" then
        UI.RenderSetting(QuickInventory.Settings.ConsumablesCategory)
    end
end)