
---------------------------------------------
-- Adds a hotbar action for Portable Respec Mirror (FJ version only).
---------------------------------------------

local Actions = Epip.GetFeature("Feature_HotbarActions")

---@type Feature
local Mirror = {
    ACTION_ID = "PortableRespecMirror_Use",

    TranslatedStrings = {
        HotbarAction_Name = {
           Handle = "h11ffdfdbg98d0g41afgb4e4g7242c71f6a2d",
           Text = "Respec",
           ContextDescription = "Hotbar action name",
        },
    },

    REQUIRED_MODS = {
        [Mod.GUIDS.PORTABLE_RESPEC_MIRROR] = "Portable Respec Mirror (FJ Edition)",
    },
}
Epip.RegisterFeature("PortableRespecMirrorCompatibility", Mirror)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register the hotbar action.
if Mirror:IsEnabled() then
    Actions.RegisterAction({
        ID = Mirror.ACTION_ID,
        Name = Mirror.TranslatedStrings.HotbarAction_Name:GetString(),
        Icon = "hotbar_icon_magic",
    })

    -- Listen for the action being used
    if Ext.IsServer() then
        Actions.Events.ActionUsed:Subscribe(function (ev)
            if ev.Action.ID == Mirror.ACTION_ID then
                Osiris.PROC_PIP_Hotkey_Respec(ev.Character)
            end
        end)
    end
end