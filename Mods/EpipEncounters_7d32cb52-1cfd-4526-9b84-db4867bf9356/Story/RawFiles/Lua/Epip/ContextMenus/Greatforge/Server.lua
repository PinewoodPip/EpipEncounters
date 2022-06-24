
---------------------------------------------
-- Server-side helpers for using Greatforge options through context menus.
---------------------------------------------

Epip.Features.GreatforgeContextMenu = {
    MassDismantle = {
        currentChar = nil,
        itemQueue = nil,
    }
}
local GreatforgeContextMenu = Epip.Features.GreatforgeContextMenu

---------------------------------------------
-- DISMANTLE
---------------------------------------------
Game.Net.RegisterListener("EPIPENCOUNTERS_QuickReduce", function(cmd, payload)
    Osi.PROC_PIP_QuickReduce(Ext.GetCharacter(payload.Char).MyGuid, Ext.GetItem(payload.Item).MyGuid)
end)

---------------------------------------------
-- EXTRACT RUNES
---------------------------------------------
Game.Net.RegisterListener("EPIPENCOUNTERS_QuickExtractRunes", function(cmd, payload)
    Osi.PROC_PIP_QuickExtractRunes(Ext.GetCharacter(payload.Char).MyGuid, Ext.GetItem(payload.Item).MyGuid)
end)

---------------------------------------------
-- REMOVE MODS (Cull)
---------------------------------------------
Game.Net.RegisterListener("EPIPENCOUNTERS_QuickGreatforge_RemoveMods", function(cmd, payload)
    Osi.PROC_PIP_QuickGreatforge_RemoveMods(Ext.GetCharacter(payload.Char).MyGuid, Ext.GetItem(payload.Item).MyGuid, payload.Modifier)
end)

---------------------------------------------
-- MASS DISMANTLE
---------------------------------------------
Game.Net.RegisterListener("EPIPENCOUNTERS_MassDismantle", function(cmd, payload)
    local container = Ext.GetItem(payload.Container)
    local char = Ext.GetCharacter(payload.Char)

    -- Don't allow multiple people to use this at once
    -- TODO maybe add a message?
    if GreatforgeContextMenu.MassDismantle.currentChar then
        return nil
    end

    local items = container:GetInventoryItems()

    GreatforgeContextMenu.MassDismantle.currentChar = char
    GreatforgeContextMenu.MassDismantle.itemQueue = items

    GreatforgeContextMenu.DismantleNextItemInQueue()
end)

function GreatforgeContextMenu.DismantleNextItemInQueue()
    local itemQueue = GreatforgeContextMenu.MassDismantle.itemQueue
    if not itemQueue or #itemQueue == 0 then return nil end

    local item = itemQueue[1]

    Osi.PROC_PIP_QuickReduce(GreatforgeContextMenu.MassDismantle.currentChar.MyGuid, item)

    table.remove(itemQueue, 1)

    Osi.TimerLaunch("PIP_MassDismantle", 50)
end

function GreatforgeContextMenu.CleanupMassDismantleQueue()
    GreatforgeContextMenu.MassDismantle.currentChar = nil
    GreatforgeContextMenu.MassDismantle.itemQueue = nil
end

Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(event)
    if event == "PIP_MassDismantle" then
        local itemQueue = GreatforgeContextMenu.MassDismantle.itemQueue

        if #itemQueue > 0 then
            GreatforgeContextMenu.DismantleNextItemInQueue()
        else
            GreatforgeContextMenu.CleanupMassDismantleQueue()
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function GreatforgeContextMenu.SendDeltaModsData()
    Game.Net.Broadcast("EPIPENCOUNTERS_QuickGreatforge_ModList", Osi.DB_AMER_Deltamods_Mod_UniqueMod:Get(nil, nil, nil))
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