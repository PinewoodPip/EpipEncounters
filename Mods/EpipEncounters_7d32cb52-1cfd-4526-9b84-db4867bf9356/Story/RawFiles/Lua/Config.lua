
-- load config json
function LoadSettings()

    if Ext.IsClient() and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "LoadingScreen") then
        -- loading screen replacement. only works after EpipEncounters has loaded. (no effect when module loads for the first time)
        Ext.IO.AddPathOverride("Public/Game/Assets/Textures/UI/DOS2_Loadscreen_DE.dds", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Assets/Textures/epip_encounters_loading_bg.dds")
    end

    -- UI stuff goes here
    if Utilities.IsEditor() or Ext.IsServer() then return nil end

    -- Ext.IO.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterSheet_rewrite.swf")

    Ext.IO.AddPathOverride("Public/Game/GUI/textDisplay.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/textDisplay.swf")

    Ext.IO.AddPathOverride("Public/Game/GUI/optionsSettings.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/optionsSettings.swf")

    Ext.IO.AddPathOverride("Public/Game/GUI/notification.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/notification.swf")
    
    -- Ext.IO.AddPathOverride("Public/Game/GUI/characterCreation.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterCreation_newPreset.swf")
    Ext.IO.AddPathOverride("Public/Game/GUI/characterCreation.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterCreation_talentsDisabled.swf")
    Ext.IO.AddPathOverride("Public/Game/GUI/statusConsole.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/statusConsole_rewritten.swf")

    Ext.IO.AddPathOverride("Public/Game/GUI/contextMenu.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/contextMenu.swf")
end
Ext.Events.SessionLoading:Subscribe(LoadSettings)