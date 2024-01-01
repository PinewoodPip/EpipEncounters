
---@class Features.HotbarTweaks : Feature
local Tweaks = {
    TOGGLE_BARS_KEYBIND = "EpipEncounters_Hotbar_ToggleVisibility",
    NOTIFICATION_SKILL_UNKNOWN_HANDLE = "hc06b03e5gb780g42dfgb39ege54c7aeac8a8",

    barsVisible = true,
    _CurrentHoveredSlotIndex = nil,

    TranslatedStrings = {
        Setting_AllowDraggingUnlearntSkills_Name = {
            Handle = "h1608e07agf046g4d0dg8298gcfd263df903e",
            Text = "Allow dragging in unlearnt skills",
            ContextDescription = "Setting name",
        },
        Setting_AllowDraggingUnlearntSkills_Description = {
            Handle = "hfcebd9e1g7fa9g4176g81b4g7cb089ba65ba",
            Text = "If enabled, you will be able to drag skills the character doesn't know onto the hotbar.\nThis does not allow the skills to be used, but is useful for creating placeholders.",
            ContextDescription = "Setting tooltip",
        },
        Setting_SlotKeyboardModifiers_Name = {
           Handle = "had42db79gf12cg4376g970bg0b9e0276a5d2",
           Text = "Select upper bars with modifier keys",
           ContextDescription = "Setting name",
        },
        Setting_SlotKeyboardModifiers_Description = {
           Handle = "h3be3b775gcd1ag4340g8bb2g53aff8a65aaa",
           Text = "If enabled, holding shift, ctrl, alt or GUI while using keybinds for slots will attempt to use slots from the 2nd, 3rd, 4th and 5th visible bars respectively.",
           ContextDescription = "Setting tooltip",
        },
        Notification_ToggleBarVisibility_On = {
            Handle = "h75631deegfe03g4b5bgafd8g16871fb83e77",
            Text = "Toggled extra bars visibility on.",
            ContextDescription = "Notification for toggling hotbar bars",
        },
        Notification_ToggleBarVisibility_Off = {
            Handle = "he6c5280dgedd4g413cgb5a3gd80c63000fbb",
            Text = "Toggled extra bars visibility off.",
            ContextDescription = "Notification for toggling hotbar bars",
        },
    },
    Settings = {},

    SupportedGameStates = _Feature.GAME_STATES.RUNNING_SESSION,
}
Epip.RegisterFeature("Features.HotbarTweaks", Tweaks)
local TSK = Tweaks.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Tweaks.Settings.AllowDraggingUnlearntSkills = Tweaks:RegisterSetting("AllowDraggingUnlearntSkills", {
    Type = "Boolean",
    Context = "Client",
    NameHandle = TSK.Setting_AllowDraggingUnlearntSkills_Name,
    DescriptionHandle = TSK.Setting_AllowDraggingUnlearntSkills_Description,
    DefaultValue = false,
})
Tweaks.Settings.SlotKeyboardModifiers = Tweaks:RegisterSetting("SlotKeyboardModifiers", {
    Type = "Boolean",
    Context = "Client",
    NameHandle = TSK.Setting_SlotKeyboardModifiers_Name,
    DescriptionHandle = TSK.Setting_SlotKeyboardModifiers_Description,
    DefaultValue = false,
})
