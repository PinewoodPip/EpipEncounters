
-- both of these UIs are loaded earlier than others as they can appear during the loading screen (ex. for story compile error). We can use this to determine input method shortly after lua is reloaded
isUsingController = false

Ext.Events.SessionLoaded:Subscribe(function()
    isUsingController = (Ext.UI.GetByPath("Public/Game/GUI/msgBox_c.swf") ~= nil) or (Ext.UI.GetByType(75) ~= nil)
end)

Ext.RegisterNetListener("EPICENCOUNTERS_ControllerUser_Request", function(cmd, payload)
    if isUsingController then
        Ext.Net.PostMessageToServer("EPICENCOUNTERS_ControllerUser_Answer", payload)
    end
end)