
local GameMenu = Client.UI.GameMenu
local CommonStrings = Text.CommonStrings

---@class Features.DiscordRichPresence
local DRP = Epip.GetFeature("Features.DiscordRichPresence")
local TSK = DRP.TranslatedStrings

-- DRP.UPDATE_DELAY = 120 -- In seconds.

DRP._SECOND_LINE_HANDLES = {
    DRP.TSKHANDLES.LONE_ADVENTURER,
    DRP.TSKHANDLES.IN_PARTY,
}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.DiscordRichPresence.Hooks.GetPresence
---@field Line1 string? Hookable. Set to `nil` to use the vanilla status. Typically the lobby status or name of the current level.
---@field Line2 string? Hookable. Set to `nil` to use the vanilla status. Typically the multiplayer status.

---------------------------------------------
-- SETTINGS
---------------------------------------------

DRP.Settings = {
    Mode = DRP:RegisterSetting("Mode", {
        Type = "Choice",
        Name = TSK.Setting_Mode_Name,
        Description = TSK.Setting_Mode_Description,
        DefaultValue = DRP.MODES.VANILLA,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = DRP.MODES.VANILLA, NameHandle = CommonStrings.Vanilla.Handle},
            {ID = DRP.MODES.OVERHAUL, NameHandle = CommonStrings.Overhaul.Handle},
            {ID = DRP.MODES.CUSTOM, NameHandle = CommonStrings.Custom.Handle},
        }
    }),
    CustomLine1 = DRP:RegisterSetting("CustomLine1", {
        Type = "String",
        Name = TSK.Setting_CustomLine1_Name,
        Description = TSK.Setting_CustomLine_Description,
        DefaultValue = "Enjoying state-of-the-art UI",
    }),
    CustomLine2 = DRP:RegisterSetting("CustomLine2", {
        Type = "String",
        Name = TSK.Setting_CustomLine2_Name,
        Description = TSK.Setting_CustomLine_Description,
        DefaultValue = "On that Epip grind",
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Updates the rich presence message in the discord client.
---@see Features.DiscordRichPresence.Hooks.GetTitle
function DRP.UpdatePresence()
    if GameMenu:Exists() then -- Opening the pause menu will update the presence in the discord client.
        GameMenu:Show()
        GameMenu:Hide()
    end
    DRP._UpdatePresence()
end

---Updates all parts of the presence.
function DRP._UpdatePresence()
    local line1, line2 = nil, nil

    -- The level name is frequently used as the first line; we must overwrite it, but also keep track of the original text.
    local level = Entity.GetLevel()
    if level then
        local levelDesc = level.LevelDesc
        local stringKey = levelDesc.LevelName
        local originalText = DRP._OriginalLevelNames[stringKey]
        if originalText == nil then -- Keep track of the original name
            originalText = Text.GetTranslatedString(stringKey)
            DRP._OriginalLevelNames[stringKey] = originalText
        else -- Revert changes
            Ext.L10N.CreateTranslatedString(stringKey, originalText) -- Cannot use CreateTranslatedStringKey as we do not know the handle.
        end
    end

    -- Revert changes to the text that appears in the second line of the presence
    for _,secondLineHandle in ipairs(DRP._SECOND_LINE_HANDLES) do
        local originalString = DRP._OriginalLabels[secondLineHandle]
        if originalString == nil then -- Keep track of the original string
            originalString = Text.GetTranslatedString(secondLineHandle)
            DRP._OriginalLabels[secondLineHandle] = originalString
        else
            Text.SetTranslatedString(secondLineHandle, originalString) -- Revert changes
        end
    end

    local hook = DRP.Hooks.GetPresence:Throw({
        Line1 = nil,
        Line2 = nil,
    })
    line1, line2 = hook.Line1, hook.Line2

    if line1 and level then
        Ext.L10N.CreateTranslatedString(level.LevelDesc.LevelName, line1)
    end
    if line2 then
        for _,secondLineHandle in ipairs(DRP._SECOND_LINE_HANDLES) do
            Text.SetTranslatedString(secondLineHandle, line2)
        end
    end

    DRP:DebugLog("Presence updated")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update presence when game state changes or before the pause menu is brought up.
Ext.Events.GameStateChanged:Subscribe(function (_)
    DRP._UpdatePresence()
end)
Client.UI.GameMenu.Events.Opened:Subscribe(function (_)
    DRP._UpdatePresence()
end)

-- Default implementation of GetPresence.
DRP.Hooks.GetPresence:Subscribe(function (ev)
    local mode = DRP:GetSettingValue(DRP.Settings.Mode)
    if mode == DRP.MODES.OVERHAUL then -- Show game overhaul being used.
        local overhaul = Mod.GetOverhaul()
        local overhaulName = "Vanilla-ish"
        if overhaul then
            if overhaul.Info.ModuleUUID == Mod.GUIDS.EE_CORE then -- EE2 is a special case we rename.
                overhaulName = "Epic Encounters 2"
            else
                overhaulName = overhaul.Info.Name
            end
        end

        local char = Client.GetCharacter()
        if char then
            local regionName = Text.GetTranslatedString(char.PlayerData.Region)
            if regionName == "" then -- Happens in ex. Tomb of Lucian. TODO fallback to level name?
                regionName = TSK.Label_UnknownSubRegion:GetString()
            end
            local level = char.Stats.Level -- Initially we considered using max of party level, but it was deemed unnecessary.

            ev.Line1 = TSK.Label_PartyLevel:Format(regionName, level)
            ev.Line2 = overhaulName
        end
    elseif mode == DRP.MODES.CUSTOM then -- Use user-defined strings.
        local line1 = DRP:GetSettingValue(DRP.Settings.CustomLine1)
        local line2 = DRP:GetSettingValue(DRP.Settings.CustomLine2)
        ev.Line1, ev.Line2 = line1, line2
    end -- Do nothing for Vanilla mode; changes to TSKs are undone before this hook.
end)

-- Update the presence when settings are changed.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if DRP.Settings[ev.Setting:GetID()] ~= nil and GameState.IsInSession() then
        DRP.UpdatePresence()
    end
end)

-- Update the presence regularly if it is in overhaul mode.
-- AFAIK there is no event for characters changing subregions.
-- 12/10/23: disabled due to side-effects of closing UIs such as CharacterSheet.
-- GameState.Events.ClientReady:Subscribe(function (_)
--     local updateTimer = Timer.Start(DRP.UPDATE_DELAY, function (_)
--         if DRP:GetSettingValue(DRP.Settings.Mode) == DRP.MODES.OVERHAUL then
--             DRP:UpdatePresence()
--         end
--     end)
--     updateTimer:SetRepeatCount(-1)
-- end)
