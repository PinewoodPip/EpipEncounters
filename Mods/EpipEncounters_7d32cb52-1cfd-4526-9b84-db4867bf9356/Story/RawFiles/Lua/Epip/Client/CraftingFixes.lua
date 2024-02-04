
---------------------------------------------
-- Persists the selected filter in the crafting UI.
-- In the base game, the UI always reverts to the All filert upon opening the UI.
-- Additionally implements a setting to set the default filter.
---------------------------------------------

local Craft = Client.UI.Craft

---@class Features.CraftingFixes : Feature
local Fixes = {
    _PreviousFilter = "All", ---@type CraftUI_Filter_Type

    TranslatedStrings = {
        Setting_DefaultFilter_Name = {
           Handle = "hea8fd41ag8885g40b0g8466gb6a63d91863a",
           Text = "Default Tab",
           ContextDescription = "Default filter setting name",
        },
        Setting_DefaultFilter_Description = {
           Handle = "hd8218bb5gcf00g4051g90f2g05388601ab51",
           Text = "Determines the default tab for the crafting UI.",
           ContextDescription = "Default filter setting tooltip",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.CraftingFixes", Fixes)


---------------------------------------------
-- SETTINGS
---------------------------------------------

-- Default filter setting.
---@type SettingsLib_Setting_Choice_Entry[]
local filterSettingChoices = {}
for id in Craft.VANILLA_FILTERS_IDS:Iterator() do
    local filter = Craft.FILTERS[id]
    table.insert(filterSettingChoices, {ID = filter.StringID, NameHandle = filter.Handle, _NumericID = id})
end
table.sortByProperty(filterSettingChoices, "_NumericID")
Fixes:RegisterSetting("DefaultFilter", {
    Type = "Choice",
    Context = "Client",
    NameHandle = Fixes.TranslatedStrings.Setting_DefaultFilter_Name,
    DescriptionHandle = Fixes.TranslatedStrings.Setting_DefaultFilter_Description,
    DefaultValue = 1,
    Choices = filterSettingChoices,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Restore previous filter whenever the character in the UI is set.
Craft.Events.CharacterSelected:Subscribe(function (_)
    Timer.Start("", 0.05, function()
        Craft.SelectFilter(Fixes._PreviousFilter)
        Fixes:DebugLog("Setting filter to " .. Fixes._PreviousFilter)
    end)
end)

-- When a filter is manually selected, update the filter to return to
-- on future visits to the UI.
Craft.Events.FilterSelected:Subscribe(function (e)
    if not e.Scripted and not e.IsFromEngine then
        Fixes._PreviousFilter = e.Filter
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

---@diagnostic disable-next-line: invisible
function Fixes:__Setup()
    -- Set default filter from setting
    Fixes._PreviousFilter = Fixes:GetSettingValue(Fixes.Settings.DefaultFilter) or Fixes._PreviousFilter
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Checks if restoring previous tab works, and whether it is kept while switching chars.
Testing.RegisterTest(Fixes, {
    ID = "Tab change",
    Function = function (inst)
        Fixes._PreviousFilter = "Equipment"
        Client.UI.Hotbar.UseAction("Crafting", 1)

        inst:Sleep(0.5)

        local button = Craft:GetRoot().craftPanel_mc.experimentPanel_mc.filterTabList.content_array[Craft.FILTERS[Craft.FILTER_IDS.EQUIPMENT].ID - 1] -- Need to shift the index down since the "unknown" tab (index 1) is not rendered in the UI
        assert(button.select_mc.visible, "Equipment tab was not selected upon opening the UI")
    end
})
