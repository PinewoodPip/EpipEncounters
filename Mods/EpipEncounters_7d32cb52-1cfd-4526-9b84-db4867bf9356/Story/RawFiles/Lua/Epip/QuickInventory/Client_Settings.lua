
---------------------------------------------
-- Registers core settings for Quick Inventory.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- TSKS
---------------------------------------------

QuickInventory.TranslatedStrings.Setting_InContainersOnly_Name = QuickInventory:RegisterTranslatedString({
    Handle = "h92793b1ag76e5g4b94ga417g50e41f56a8c7",
    Text = [[Only show items in containers]],
    ContextDescription = [[Filter setting name]],
})
QuickInventory.TranslatedStrings.Setting_InContainersOnly_Description = QuickInventory:RegisterTranslatedString({
    Handle = "hc4ae20b2ga3f9g4393gac8fg591e7e2986e3",
    Text = [[If enabled, only items within containers will be shown.]],
    ContextDescription = [[Filter setting tooltip for "Only show items in containers"]],
})
QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Name = QuickInventory:RegisterTranslatedString("h3201d71eg90b3g4068gba08ga89e00180089", {
    Text = "Recursive Search",
    ContextDescription = "Option name",
})
QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Description_Warning = QuickInventory:RegisterTranslatedString("h1110db28g66a0g4f73gb67fgdc8d32c3af40", {
    Text = "Warning: can be very slow!",
    ContextDescription = "Recursive search option warning in tooltip",
})
QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Description = QuickInventory:RegisterTranslatedString("hda7ece02g6e5dg41a7gb4f7g62de6a4b3c1f", {
    Text = "If enabled, items will also be searched recursively within containers.<br>%s",
    ContextDescription = "Option tooltip. First param is warning about it being slow.",
    FormatOptions = {
        FormatArgs = {
            {
                Text = QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Description_Warning:GetString(),
                Color = Color.LARIAN.YELLOW,
            },
        },
    },
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.CloseAfterUsing = QuickInventory:RegisterSetting("CloseAfterUsing", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.CloseAfterUsing_Name,
    Description = QuickInventory.TranslatedStrings.CloseAfterUsing_Description,
    DefaultValue = true,
})

QuickInventory.Settings.CloseOnClickOutOfBounds = QuickInventory:RegisterSetting("CloseOnClickOutOfBounds", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_CloseOnClickOutOfBounds_Name,
    Description = QuickInventory.TranslatedStrings.Setting_CloseOnClickOutOfBounds_Description,
    DefaultValue = false,
})

QuickInventory.Settings.ItemCategory = QuickInventory:RegisterSetting("ItemCategory", {
    Type = "Choice",
    Name = QuickInventory.TranslatedStrings.ItemCategory_Name,
    DefaultValue = "Equipment",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = { -- TODO have the subscripts insert their choices instead of declaring them here
        {ID = "Equipment", NameHandle = CommonStrings.Equipment.Handle},
        {ID = "Consumables", NameHandle = CommonStrings.Consumables.Handle},
        {ID = "Skillbooks", NameHandle = CommonStrings.Skillbooks.Handle},
        {ID = "Runes", NameHandle = CommonStrings.Runes.Handle},
        {ID = "Containers", NameHandle = CommonStrings.Containers.Handle},
        {ID = "Miscellaneous", NameHandle = CommonStrings.Miscellaneous.Handle},
    },
})

QuickInventory.Settings.InContainersOnly = QuickInventory:RegisterSetting("InContainersOnly", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_InContainersOnly_Name,
    Description = QuickInventory.TranslatedStrings.Setting_InContainersOnly_Description,
    DefaultValue = false,
})

QuickInventory.Settings.RecursiveSearch = QuickInventory:RegisterSetting("RecursiveSearch", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Name,
    Description = QuickInventory.TranslatedStrings.Setting_RecursiveSearch_Description,
    DefaultValue = false,
})
