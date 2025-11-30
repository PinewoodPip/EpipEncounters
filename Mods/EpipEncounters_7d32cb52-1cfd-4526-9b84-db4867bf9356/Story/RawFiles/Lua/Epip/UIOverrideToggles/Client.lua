
---------------------------------------------
-- Holds settings for toggling Epip's UI overrides.
-- The actual code to toggle these unfortunately has to be coupled
-- to the UIs themselves.
---------------------------------------------

---@class Features.UIOverrideToggles : Feature
local Toggles = {
    Settings = {},
    TranslatedStrings = {
        Label_SettingsMenuHint = {
            Handle = "hdeef5528gca68g4566g9af5gc53982dd1366",
            Text = "The following settings control Epip's UI file overrides. Disabling these allows other mods's overrides to be used instead, but will make some of Epip's functionalities related to that UI unavailable.",
            ContextDescription = [[Hint in settings menu "Compatibility" section]],
        },
        Setting_EnableCharacterSheetOverride_Name = {
            Handle = "hb0c886b2g7598g46e8ga0f3g0b90fa295fff",
            Text = "Character Sheet Overrides",
            ContextDescription = [[Setting name]],
        },
        Setting_EnableCharacterSheetOverride_Description = {
            Handle = "h6e636546ge930g472eg9998gf083a124eca9",
            Text = [[Enables Epip's changes to the character sheet UI. If disabled, the following features will not be available:<br>- Physical & piercing resistance icons<br>- "Keywords & Misc." tab<br>Tooltip adjustments are unaffected.]],
            ContextDescription = [[Setting tooltip for "Character Sheet Overrides"]],
        },
        Setting_EnablePlayerInfoOverride_Name = {
            Handle = "h4978bb6fg7904g44ccg912fgc6ae2897f3d8",
            Text = "Player Portraits Overrides",
            ContextDescription = [[Setting name]],
        },
        Setting_EnablePlayerInfoOverride_Description = {
            Handle = "h36388340g34f3g485fgb871g6391fe5312c6",
            Text = [[Enables Epip's changes to the player portraits UI. If disabled, the following features will not be available:<br>- Wrapping status bar<br>- Battered/Harried indicators<br>- Adjusting status bar opacity<br>- Player context menus<br>The "Alternative Status Display" setting is unaffected.]],
            ContextDescription = [[Setting tooltip for "Player Portraits Overrides"]],
        },

        -- Override for the "Custom stats" tab header.
        Label_KeywordsTab = {
            Handle = "h1a027d33g636fg4a2dga363gfc9f755c6c93",
            Text = "Keywords & Misc.",
            ContextDescription = [[Tooltip for tab with keywords & character stats.]],
        },
    },
}
Epip.RegisterFeature("Features.UIOverrideToggles", Toggles)
local TSK = Toggles.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Toggles.Settings.EnableCharacterSheetOverride = Toggles:RegisterSetting("EnableCharacterSheetOverride", {
    Type = "Boolean",
    Name = TSK.Setting_EnableCharacterSheetOverride_Name,
    Description = TSK.Setting_EnableCharacterSheetOverride_Description,
    DefaultValue = true,
    RequiresReload = true,
})
Toggles.Settings.EnablePlayerInfoOverride = Toggles:RegisterSetting("EnablePlayerInfoOverride", {
    Type = "Boolean",
    Name = TSK.Setting_EnablePlayerInfoOverride_Name,
    Description = TSK.Setting_EnablePlayerInfoOverride_Description,
    DefaultValue = true,
    RequiresReload = true,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update stats tab translated string to use the Epip localized string.
GameState.Events.ClientReady:Subscribe(function()
    local CharacterSheet = Client.UI.CharacterSheet -- Cannot be upvalued, as this feature needs to load before the UI table.
    local label = Toggles.TranslatedStrings.Label_KeywordsTab:GetString()
    for _,handle in ipairs(CharacterSheet.CUSTOM_STATS_TAB_TSKHANDLES) do
        Text.SetTranslatedString(handle, label)
    end
end, {EnabledFunctor = function ()
    return Toggles.Settings.EnableCharacterSheetOverride:GetValue() == true and not GameState.IsInGameMasterMode() -- Do not change the label in GM mode, as this tab is used for its original custom stats purpose there instead.
end})
