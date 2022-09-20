
---@class MinimapUI : UI
local Minimap = {

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    visible = true,
}
Epip.InitializeUI(Client.UI.Data.UITypes.minimap, "Minimap", Minimap)

function Minimap:Toggle(state, updateState, force)
    if (not Client.UI.CharacterCreation.IsInCharacterCreation() or force) and state ~= Minimap.visible then
        if state then
            Minimap:GetUI():Show()
        else
            Minimap:GetUI():Hide()
        end
    end

    -- updateState == false is used for temporarily hiding the minimap (not saved)
    if updateState then
        Minimap.visible = state
    end
end

function Minimap:ToggleFromSettings()
    local showMinimap = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "Minimap")

    Minimap:Toggle(showMinimap, true)
end

-- TODO
-- hotbar:RegisterAction(GUID, "Epip_ToggleMiniMap", "Toggle Minimap", "hotbar_icon_map", function(char)
--     Minimap:Toggle(not Minimap.visible, true)
-- end)

---------------------------------------------
-- LISTENERS
---------------------------------------------

Client.UI.Hotbar:RegisterListener("Initialized", function()
    Minimap:ToggleFromSettings()
end)

Client.UI.OptionsSettings:RegisterListener("OptionSet", function(data, value)
    if data.ID == "Minimap" then
        Minimap:Toggle(value, true)
    end
end)

Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.minimap, "setMapText", function(ui, method)
    Minimap:Toggle(Minimap.visible, true, true)
end, "After")

-- Only resave the setting to the file on pause to reduce the amount of times we write this to disk
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    
    if (Minimap.visible ~= Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "Minimap")) then
        Client.UI.OptionsSettings.SetOptionValue("EpipEncounters", "Minimap", Minimap.visible)

        Client.UI.OptionsSettings.SaveSettings()
    end
end)