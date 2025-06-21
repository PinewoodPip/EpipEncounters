
---------------------------------------------
-- Server-side helpers for using Greatforge options through context menus.
---------------------------------------------

---@class Features.GreatforgeContextMenu
local GreatforgeContextMenu = Epip.GetFeature("Features.GreatforgeContextMenu")

---------------------------------------------
-- DISMANTLE
---------------------------------------------
Net.RegisterListener("EPIPENCOUNTERS_QuickReduce", function(payload)
    Osi.PROC_PIP_QuickReduce(Ext.GetCharacter(payload.Char).MyGuid, Ext.GetItem(payload.Item).MyGuid)
end)

---------------------------------------------
-- EXTRACT RUNES
---------------------------------------------
Net.RegisterListener("EPIPENCOUNTERS_QuickExtractRunes", function(payload)
    local char, item = Character.Get(payload.Char), Item.Get(payload.Item)

    Osiris.PROC_PIP_QuickExtractRunes(char, item)
end)

-- Show overhead when runes are extracted.
Ext.Osiris.RegisterListener("PROC_PIP_ShowGreatforgeCostOverhead", 4, "after", function(charGUID, operation, _, cost) -- Third param is currency type.
    if operation == "Extracted runes" then
        local msg = GreatforgeContextMenu.TranslatedStrings.Overhead_ExtractedRunes.Text:format(cost)
        Osi.CharacterStatusText(charGUID, msg)
    else
        GreatforgeContextMenu:__LogWarning("Unsupported operation from PROC_PIP_ShowGreatforgeCostOverhead: %s", operation)
    end
end)

---------------------------------------------
-- REMOVE MODS (Cull)
---------------------------------------------
Net.RegisterListener("EPIPENCOUNTERS_QuickGreatforge_RemoveMods", function(payload)
    Osi.PROC_PIP_QuickGreatforge_RemoveMods(Ext.GetCharacter(payload.Char).MyGuid, Ext.GetItem(payload.Item).MyGuid, payload.Modifier)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function GreatforgeContextMenu.SendDeltaModsData()
    Net.Broadcast("EPIPENCOUNTERS_QuickGreatforge_ModList", Osi.DB_AMER_Deltamods_Mod_UniqueMod:Get(nil, nil, nil))
end

Utilities.Hooks.RegisterListener("Game", "Loaded", function()
    GreatforgeContextMenu.SendDeltaModsData()
end)

-- Ext.Osiris.RegisterListener("SavegameLoaded", 4, "before", function(major, minor, patch, build)
--     InitializeCustomStats()
--     UpdateEpicStats(false)
-- end)

-- -- initialize stats at new game
-- Ext.Osiris.RegisterListener("PROC_AMER_GEN_CCFinished_GameStarted", 0, "after", function()
--     InitializeCustomStats()
--     UpdateEpicStats(false)
-- end)