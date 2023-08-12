
local CommonStrings = Text.CommonStrings
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

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

        ::EndTagChecks::

        visible = visible and not Item.IsSkillbook(ev.Item) -- Exclude skillbooks

        ev.Visible = visible
    end
end)