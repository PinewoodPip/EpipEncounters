---------------------------------------------
-- Adds a setting to toggle the vanilla turn notifications from the Status Console UI.
---------------------------------------------

local StatusConsole = Client.UI.StatusConsole
local SettingsLib = Settings

---@type Feature
local Notifications = {
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h3793ded0g7ef1g4f73ga0a8g2f2b9bb05727",
            Text = "Turn Notifications",
            ContextDescription = [["Turn notifications" setting name]],
        },
        Setting_Enabled_Description = {
            Handle = "h7fda32ffg167cg43e5gad2dg8672bc83a0ba",
            Text = "Controls whether toast widgets will be shown by the bottom health bar whenever a new turn begins in combat.",
            ContextDescription = [["Turn notifications" setting tooltip]],
        },
    },
    Settings = {},
}
local TSK = Notifications.TranslatedStrings
Epip.RegisterFeature("Features.TurnNotifications", Notifications)

---------------------------------------------
-- SETTINGS
---------------------------------------------

local Settings = {
    Enabled = Notifications:RegisterSetting("Enabled", {
        Type = "Boolean",
        Name = TSK.Setting_Enabled_Name,
        Description = TSK.Setting_Enabled_Description,
        DefaultValue = false, -- Technically these are vanilla behaviour, however they were gone from Epip for so long (2021 - 2025, predating this setting) that it would've been controversial to set them back on by default.
    }),
}

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Prevent turn notifications if the setting is disabled.
StatusConsole:RegisterInvokeListener("setCombatTurnNotification", function (ev, turnID, _, _, _) -- Other params are notice, isPlayerTurn, showTimer
    if turnID >= 0 and Settings.Enabled:GetValue() == false then
        ev:PreventAction()

        -- Send engine callback so the internal message queue doesn't clog up
        Timer.StartTickTimer(3, function (_)
            StatusConsole:ExternalInterfaceCall("animDone")
        end)
    end
end)

-- Hide any existing toast when the setting is disabled.
SettingsLib.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == Settings.Enabled and ev.Value == false then
        StatusConsole:GetRoot().setCombatTurnNotification(-1, "", false, false)
    end
end, {EnabledFunctor = function ()
    return StatusConsole:Exists()
end})