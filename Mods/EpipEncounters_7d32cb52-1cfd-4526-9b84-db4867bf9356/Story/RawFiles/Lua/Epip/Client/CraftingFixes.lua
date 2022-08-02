
local Craft = Client.UI.Craft

---@type Feature|table<string, any>
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
Fixes:Debug()

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