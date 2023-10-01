
local CommonStrings = Text.CommonStrings
local Set = DataStructures.Get("DataStructures_Set")
local ItemTagging = Epip.GetFeature("Features.ItemTagging")

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local UI = QuickInventory.UI

QuickInventory.BOOK_TAGS = Set.Create({
    "BOOK",
    "ORGANIZE_BOOK",
})
QuickInventory.KEY_TAGS = Set.Create({
    "KEYS",
    "Key",
    "ORGANIZE_KEY",
})

---@type table<string, {Tags:DataStructures_Set<string>}>
QuickInventory.MISCELLANEOUS_SUBCATEGORIES = {
    ["Books"] = {Tags = QuickInventory.BOOK_TAGS},
    ["Keys"] = {Tags = QuickInventory.KEY_TAGS},
}

---------------------------------------------
-- TSKS
---------------------------------------------

QuickInventory.TranslatedStrings.Setting_ShowUsedMiscellaneousItems_Name = QuickInventory:RegisterTranslatedString("h50e08a06gb022g457fg9f6ag83565deb610f", {
    Text = "Show Used Items",
    ContextDescription = "Setting name",
})
QuickInventory.TranslatedStrings.Setting_ShowUsedMiscellaneousItems_Description = QuickInventory:RegisterTranslatedString("h13d1cd67ga1e8g4d7cg813bg3c01187b10ce", {
    Text = "If enabled, books that have been read and keys that have been used will be shown.",
    ContextDescription = "Setting tooltip",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.MiscellaneousItemType = QuickInventory:RegisterSetting("MiscellaneousItemType", {
    Type = "Choice",
    Name = CommonStrings.Type,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Books", NameHandle = CommonStrings.Books.Handle},
        {ID = "Keys", NameHandle = CommonStrings.Keys.Handle},
    },
})
QuickInventory.Settings.ShowUsedMiscellaneousItems = QuickInventory:RegisterSetting("ShowUsedMiscellaneousItems", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_ShowUsedMiscellaneousItems_Name,
    Description = QuickInventory.TranslatedStrings.Setting_ShowUsedMiscellaneousItems_Description,
    DefaultValue = true,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply filters.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Miscellaneous" and ev.Visible then
        local subcategory = QuickInventory:GetSettingValue(QuickInventory.Settings.MiscellaneousItemType)
        local visible = false

        for category,data in pairs(QuickInventory.MISCELLANEOUS_SUBCATEGORIES) do
            if subcategory == "Any" or subcategory == category then
                visible = QuickInventory.ItemHasRelevantTag(ev.Item, data.Tags)
                if visible then
                    goto EndTagChecks
                end
            end
        end

        -- Some books in Origins (ex. Meistr's note) have no book tags; we check the use action as fallback.
        if (subcategory == "Any" or subcategory == "Books") and Item.HasUseAction(ev.Item, "Book") then
            visible = true
        end

        ::EndTagChecks::

        visible = visible and not Item.IsSkillbook(ev.Item) -- Exclude skillbooks

        if visible and ItemTagging then -- Check used item tags. We do not assume the feature exists.
            local showUsed = QuickInventory:GetSettingValue(QuickInventory.Settings.ShowUsedMiscellaneousItems)
            visible = visible and (showUsed or not ItemTagging.IsItemUsed(ev.Item))
        end

        ev.Visible = visible
    end
end)

-- Render category settings.
UI.Events.RenderSettings:Subscribe(function (ev)
    if ev.ItemCategory == "Miscellaneous" then
        UI.RenderSetting(QuickInventory.Settings.MiscellaneousItemType)

        -- Only show "Show used items" if the feature is available.
        if ItemTagging then
            UI.RenderSetting(QuickInventory.Settings.ShowUsedMiscellaneousItems)
        end
    end
end)