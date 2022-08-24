
local Craft = Client.UI.Craft

---@class Feature_CraftingFixes : Feature
local Fixes = {
    previousFilter = "All", ---@type CraftUI_Filter

    ---@type CraftUI_Filter[]
    DEFAULT_FILTER_OPTIONS = {
        "All",
        "Equipment",
        "Consumables",
        "Magical",
        "Ingredients",
        "Miscellaneous",
    },
}
Epip.AddFeature("CraftingFixes", "CraftingFixes", Fixes)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Craft.Events.CharacterSelected:Subscribe(function (e)
    Timer.Start("", 0.05, function()
        Craft.SelectFilter(Fixes.previousFilter)
        Fixes:DebugLog("Setting filter to " .. Fixes.previousFilter)
    end)
end)

Craft.Events.FilterSelected:Subscribe(function (e)
    if not e.Scripted and not e.IsFromEngine then
        Fixes.previousFilter = e.Filter
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Fixes:__Setup()
    Fixes.previousFilter = Fixes.DEFAULT_FILTER_OPTIONS[Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "Crafting_DefaultFilter")]
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Checks if restoring previous tab works, and whether it is kept while switching chars.
Fixes:RegisterTest("Test1", function(inst)
    Fixes.previousFilter = "Equipment" 

    Client.UI.Hotbar.UseAction("Crafting", 1)

    inst:Sleep(0.5)

    local button = Craft:GetRoot().craftPanel_mc.experimentPanel_mc.filterTabList.content_array[Craft.FILTERS.EQUIPMENT - 1] -- Need to shift the index down since the "unknown" tab (index 1) is not rendered in the UI

    assert(button.select_mc.visible, "Equipment tab was not selected upon opening the UI") 
end)