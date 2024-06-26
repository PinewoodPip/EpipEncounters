
---------------------------------------------
-- Displays resistances at the bottom of the
-- enemy health bar, or AP/SP/Init info if shift is held.
-- Additionally, moves the level display to the header.
-- Also displays this information in controller selection overheads.
---------------------------------------------

local EnemyHealthBar = Client.UI.EnemyHealthBar
local Overhead = Client.UI.Overhead -- For controller support.
local CommonStrings = Text.CommonStrings

---@class Features.EnemyHealthBarExtraInfo : Feature
local ExtraInfo = {
    -- These are not the 'official' colors,
    -- they're lightly modified for readability.
    RESISTANCE_COLORS = {
        Fire = "f77c27",
        Water = "27aff6",
        Earth = "aa7840",
        Air = "8f83cb",
        Poison = "5bd42b",
        Physical = "acacac",
        Piercing = "c23c3c",
        Shadow = "5b34ca",
    },
    RESISTANCES_DISPLAYED = {
        "Fire", "Water", "Earth", "Air", "Poison", "Physical", "Piercing",
    },
    CHARACTER_LEVEL_MODES = {
        HIDDEN = 1,
        NEAR_NAME = 2,
        BELOW_BAR = 3,
        IN_ALT_INFO = 4,
    },
    RESISTANCES_DISPLAY_MODES = {
        NEVER = 1,
        ONLY_NONZERO = 2,
        IF_ANY_NONZERO = 3,
        ALWAYS = 4,
    },
    TEXT_SIZE = 14.5,
    CONTROLLER_RESISTANCES_SIZE = 19,
    CONTROLLER_ALTERNATIVE_DISPLAY_SIZE = 19,
    CONTROLLER_RESISTANCES_BOTTOM_MARGIN = 5,

    TranslatedStrings = {
        SettingName = {
           Handle = "h52f49bccg59f7g4b72g8440g55847b964cde",
           Text = "Character Level Display",
           ContextDescription = "Name for setting for health bar",
        },
        SettingDescription = {
           Handle = "hedbf4e2fgb8e6g400cgb08bgd33f99bc101d",
           Text = "Controls how character levels are displayed in the health bar UI.",
           ContextDescription = "Tooltip for 'Character Level Display' setting for health bar",
        },
        NearName = {
           Handle = "hd2e9ffeega495g4fdagb818gbc7b6275e9b3",
           Text = "After Name",
           ContextDescription = "Option for 'show enemy level in hp bar' setting",
        },
        BelowBar = {
           Handle = "h2a5a9fedg9c42g4f0ag9d54gb4098614b91b",
           Text = "Below Health Bar",
           ContextDescription = "Option for 'show enemy level in hp bar' setting",
        },
        NearAltInfo = {
           Handle = "h7e532f24g51f1g439cg9851g8ff8f12a6b17",
           Text = "When holding Shift",
           ContextDescription = "Option for 'show enemy level in hp bar' setting",
        },
        Setting_ResistancesDisplay_Name = {
            Handle = "h33af8f80g537eg4f1fga457gf02894f0d762",
            Text = "Resistances Display",
            ContextDescription = "Setting name",
        },
        Setting_ResistancesDisplay_Description = {
            Handle = "h71cef3e3g71bag4da1gb743g56dc62daf7ac",
            Text = "Controls how resistances are shown in the health bar UI.<br><br>- Never: resistances are never shown under the health bar.<br>- Only non-zero: only resistances that are not at 0 are displayed.<br>- If any non-zero: all resistances are displayed if the character has a non-zero amount of any of them; otherwise none are shown.<br>- Always: all resistances are shown.",
            ContextDescription = "Setting tooltip",
        },
        Setting_ResistancesDisplay_Choice_OnlyNonZero = {
            Handle = "h6493dca2g23e2g43d9g8cd4gfa10a05faedd",
            Text = "Only non-zero",
            ContextDescription = "Option for resistances display setting",
        },
        Setting_ResistancesDisplay_Choice_IfNonZero = {
            Handle = "h14408a2cgee5fg4f6agb7f8g33c364419f75",
            Text = "If any non-zero",
            ContextDescription = "Option for resistances display setting",
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetResistances = {}, ---@type Hook<Features.EnemyHealthBarExtraInfo.Hooks.GetResistances>
    }
}
Epip.RegisterFeature("Features.EnemyHealthBarExtraInfo", ExtraInfo)
local TSK = ExtraInfo.TranslatedStrings

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.EnemyHealthBarExtraInfo.Resistance
---@field Color htmlcolor
---@field Amount number As percentage.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Display mode setting is handled by the feature; you're intended to return all resistances that exist or are applicable to the character.
---@class Features.EnemyHealthBarExtraInfo.Hooks.GetResistances
---@field Character EclCharacter
---@field Resistances Features.EnemyHealthBarExtraInfo.Resistance[] Hookable.

---------------------------------------------
-- SETTINGS
---------------------------------------------

ExtraInfo.Settings.Mode = ExtraInfo:RegisterSetting("Mode", {
    Type = "Choice",
    Context = "Client",
    NameHandle = ExtraInfo.TranslatedStrings.SettingName,
    DescriptionHandle = ExtraInfo.TranslatedStrings.SettingDescription,
    DefaultValue = ExtraInfo.CHARACTER_LEVEL_MODES.IN_ALT_INFO,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.HIDDEN, NameHandle = Text.CommonStrings.Hidden.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.NEAR_NAME, NameHandle = ExtraInfo.TranslatedStrings.NearName.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.BELOW_BAR, NameHandle = ExtraInfo.TranslatedStrings.BelowBar.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.IN_ALT_INFO, NameHandle = ExtraInfo.TranslatedStrings.NearAltInfo.Handle},
    },
})

ExtraInfo.Settings.ResistancesDisplay = ExtraInfo:RegisterSetting("ResistancesDisplay", {
    Type = "Choice",
    Context = "Client",
    NameHandle = ExtraInfo.TranslatedStrings.Setting_ResistancesDisplay_Name,
    DescriptionHandle = ExtraInfo.TranslatedStrings.Setting_ResistancesDisplay_Description,
    DefaultValue = ExtraInfo.RESISTANCES_DISPLAY_MODES.ALWAYS,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = ExtraInfo.RESISTANCES_DISPLAY_MODES.NEVER, NameHandle = CommonStrings.Never.Handle},
        {ID = ExtraInfo.RESISTANCES_DISPLAY_MODES.ONLY_NONZERO, NameHandle = TSK.Setting_ResistancesDisplay_Choice_OnlyNonZero.Handle},
        {ID = ExtraInfo.RESISTANCES_DISPLAY_MODES.IF_ANY_NONZERO, NameHandle = TSK.Setting_ResistancesDisplay_Choice_IfNonZero.Handle},
        {ID = ExtraInfo.RESISTANCES_DISPLAY_MODES.ALWAYS, NameHandle = CommonStrings.Always.Handle},
    },
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the resistances label for a character.
---@see Features.EnemyHealthBarExtraInfo.Hooks.GetResistances
---@param char EclCharacter
---@return string? -- `nil` if no resistances are applicable, either due to no hook returns or user setting.
function ExtraInfo.GetResistancesLabel(char)
    local displayMode = ExtraInfo:GetSettingValue(ExtraInfo.Settings.ResistancesDisplay)
    local label = nil

    if displayMode ~= ExtraInfo.RESISTANCES_DISPLAY_MODES.NEVER then
        local resistances = ExtraInfo.Hooks.GetResistances:Throw({
            Character = char,
            Resistances = {},
        }).Resistances

        local resistanceLabels = {}
        local hasResistances = false
        for _,entry in ipairs(resistances) do
            if entry.Amount ~= 0 then
                hasResistances = true
                break
            end
        end
        for _,entry in ipairs(resistances) do
            local resistanceLabel = Text.Format("%d%%", {
                Color = entry.Color,
                FormatArgs = {
                    entry.Amount,
                },
            })

            local canDisplay = displayMode == ExtraInfo.RESISTANCES_DISPLAY_MODES.ALWAYS
            if displayMode == ExtraInfo.RESISTANCES_DISPLAY_MODES.IF_ANY_NONZERO then
                canDisplay = hasResistances
            elseif displayMode == ExtraInfo.RESISTANCES_DISPLAY_MODES.ONLY_NONZERO then
                canDisplay = entry.Amount ~= 0
            end
            if canDisplay then
                table.insert(resistanceLabels, resistanceLabel)
            end
        end

        if resistanceLabels[1] then
            -- Insert some padding at the start
            label = " " .. Text.Join(resistanceLabels, "  ")
        end
    end

    return label
end

---Returns the alternative display label for a character.
---@param char EclCharacter
---@return string
function ExtraInfo.GetAlternativeDisplayLabel(char)
    local sp, maxSp = Character.GetSourcePoints(char)
    local ap, maxAp = Character.GetActionPoints(char)
    local init = Character.GetInitiative(char)
    if maxSp == -1 then
        maxSp = 3
    end
    local texts = {
        string.format("%s/%s %s", ap, maxAp, CommonStrings.AP:GetString()),
        string.format("%s/%s %s", sp, maxSp, CommonStrings.SP:GetString()),
        string.format("%s %s", init, CommonStrings.INIT:GetString()),
    }

    -- Insert level, based on user setting
    if ExtraInfo:GetSettingValue(ExtraInfo.Settings.Mode) == ExtraInfo.CHARACTER_LEVEL_MODES.IN_ALT_INFO and not Client.IsUsingController() then -- Redundant in controller UI as the selection info already shows level nicely.
        local level = Character.GetLevel(char)

        table.insert(texts, 1, string.format("%s %s", CommonStrings.Level:GetString(), level))
    end

    return Text.Join(texts, "  ")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set bottom text of the bar.
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    if ExtraInfo:IsEnabled() then
        -- Show resistances for chars, or alternative info if shift is being held.
        local char, item = ev.Character, ev.Item
        local text = nil

        if char then
            if Client.Input.IsShiftPressed() then -- Show alternate info.
                text = ExtraInfo.GetAlternativeDisplayLabel(char)
            else -- Show resistances.
                text = ExtraInfo.GetResistancesLabel(char)
            end
        elseif item and item.Stats then -- Show item level.
            text = string.format("%s %s", CommonStrings.Level:GetString(), item.Stats.Level)
        end

        if text and text ~= "" then
            -- Make text smaller.
            text = Text.Format(text, {Size = ExtraInfo.TEXT_SIZE})
            table.insert(ev.Labels, text)
        end
    end
end)

-- Default implementation of GetResistances; retrieves all resistances used in vanilla and EE.
ExtraInfo.Hooks.GetResistances:Subscribe(function (ev)
    for _,resistanceId in ipairs(ExtraInfo.RESISTANCES_DISPLAYED) do
        local amount = Character.GetResistance(ev.Character, resistanceId)
        local color = ExtraInfo.RESISTANCE_COLORS[resistanceId]
        ---@type Features.EnemyHealthBarExtraInfo.Resistance
        local entry = {
            Color = color,
            Amount = amount
        }

        table.insert(ev.Resistances, entry)
    end
end, {StringID = "DefaultImplementation"})

-- Display level by character name and hide it from the footer,
-- depending on user settings.
EnemyHealthBar.Hooks.GetHeader:Subscribe(function (ev)
    local setting = ExtraInfo:GetSettingValue(ExtraInfo.Settings.Mode)

    if ExtraInfo:IsEnabled() and setting == ExtraInfo.CHARACTER_LEVEL_MODES.NEAR_NAME then
        local char, item = ev.Character, ev.Item
        local level = (char and Character.GetLevel(char)) or (item and Item.GetLevel(item))

        if level then
            ev.Header = string.format("%s - Lvl %s", ev.Header, level)
        end
    end
end)
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    local setting = ExtraInfo:GetSettingValue(ExtraInfo.Settings.Mode)

    if ExtraInfo:IsEnabled() and setting ~= ExtraInfo.CHARACTER_LEVEL_MODES.BELOW_BAR then
        table.remove(ev.Labels, 1)
    else
        -- Move to the end and lower text size - more aesthetically pleasing
        local label = ev.Labels[1]
        table.remove(ev.Labels, 1)
        table.insert(ev.Labels, Text.Format(label, {Size = ExtraInfo.TEXT_SIZE}))

    end
end, {Priority = -9999999}) -- TODO better way of ensuring we are operating on the level label - implement string IDs for the labels, possibly.

-- Add resistance & alternative info labels to controller selection overheads.
Overhead.Hooks.UpdateSelections:Subscribe(function (ev)
    for _,selection in ipairs(ev.Selections) do
        local char = Entity.GetComponent(Ext.UI.DoubleToHandle(selection.ComponentHandle))
        if char and Entity.IsCharacter(char) then
            ---@cast char +EclCharacter
            local label = ExtraInfo.GetResistancesLabel(char)
            if label then
                selection.NameLabel = Text.Format("%s<br>%s", {
                    FormatArgs = {
                        selection.NameLabel,
                        {
                            Text = label,
                            Size = ExtraInfo.CONTROLLER_RESISTANCES_SIZE,
                        },
                        -- Add a bit of margin at the bottom.
                        {
                            Text = " ",
                            Size = ExtraInfo.CONTROLLER_RESISTANCES_BOTTOM_MARGIN,
                        }
                    }
                })
            end

            -- Only append extra info in situations where combat stats are displayed
            -- and the context menu is opened, as a form of "quick examine" (not to be confused with Quick Examine™).
            local contextMenu = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu_c.Object)
            if selection.ChanceToHitLabel ~= "" and contextMenu.OF_Visible then
                selection.ChanceToHitLabel = Text.Format("%s<br>%s", {
                    FormatArgs = {
                        selection.ChanceToHitLabel,
                        {
                            Text = ExtraInfo.GetAlternativeDisplayLabel(char),
                            Size = ExtraInfo.CONTROLLER_ALTERNATIVE_DISPLAY_SIZE,
                        }
                    }
                })
            end
        end
    end
end)
-- Reposition selection elements to fit alongside the new information labels.
GameState.Events.GameReady:Subscribe(function (_)
    if Client.IsUsingController() then
        GameState.Events.RunningTick:Subscribe(function (_)
            local root = Overhead:GetRoot()
            local array = root.overhead_array
            for i=0,#array-1,1 do
                local info = array[i].sInfo
                if info then
                    local nameText = info.name_mc.name_txt
                    if info and nameText.numLines > 1 then -- Only do this for selections where we added resistance info.
                        info.statusInfo_mc.y = -225 -- The vanilla code repositions these too far up when the name has multiple lines.
                    end
                end
            end
        end, {StringID = "Features.EnemyHealthBarExtraInfo.OverheadSelectionRepositioning"})
    end
end)
