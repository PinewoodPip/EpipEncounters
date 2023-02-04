
---------------------------------------------
-- Registers settings for Quick Inventory.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

QuickInventory.Settings.CloseAfterUsing = QuickInventory:RegisterSetting("CloseAfterUsing", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.CloseAfterUsing_Name,
    Description = QuickInventory.TranslatedStrings.CloseAfterUsing_Description,
    DefaultValue = true,
})

QuickInventory.Settings.ItemCategory = QuickInventory:RegisterSetting("ItemCategory", {
    Type = "Choice",
    Name = QuickInventory.TranslatedStrings.ItemCategory_Name,
    DefaultValue = "Equipment",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Equipment", NameHandle = CommonStrings.Equipment.Handle},
        {ID = "Consumables", NameHandle = CommonStrings.Consumables.Handle},
        {ID = "Skillbooks", NameHandle = CommonStrings.Skillbooks.Handle},
    },
})