
---------------------------------------------
-- Displays resistances at the bottom of the
-- enemy health bar, or AP/SP/Init info if shift is held.
-- Additionally, moves the level display to the header.
---------------------------------------------

local EnemyHealthBar = Client.UI.EnemyHealthBar

---@type Feature
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
    TEXT_SIZE = 14.5,

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
    },
}
Epip.RegisterFeature("EnemyHealthBarExtraInfo", ExtraInfo)

---------------------------------------------
-- SETTINGS
---------------------------------------------

ExtraInfo:RegisterSetting("Mode", {
    Type = "Choice",
    Context = "Client",
    NameHandle = ExtraInfo.TranslatedStrings.SettingName,
    DescriptionHandle = ExtraInfo.TranslatedStrings.SettingDescription,
    DefaultValue = 4,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.HIDDEN, NameHandle = Text.CommonStrings.Hidden.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.NEAR_NAME, NameHandle = ExtraInfo.TranslatedStrings.NearName.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.BELOW_BAR, NameHandle = ExtraInfo.TranslatedStrings.BelowBar.Handle},
        {ID = ExtraInfo.CHARACTER_LEVEL_MODES.IN_ALT_INFO, NameHandle = ExtraInfo.TranslatedStrings.NearAltInfo.Handle},
    },
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set bottom text of the bar.
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    if ExtraInfo:IsEnabled() then
        -- Show resistances for chars, or alternative info if shift is being held.
        local char, item = ev.Character, ev.Item
        local text = ""

        if char then
            if Client.Input.IsShiftPressed() then -- Show alternate info.
                local sp, maxSp = Character.GetSourcePoints(char)
                local ap, maxAp = Character.GetActionPoints(char)
                local init = Character.GetInitiative(char)
                if maxSp == -1 then
                    maxSp = 3
                end
                local texts = {
                    string.format("%s/%s AP", ap, maxAp),
                    string.format("%s/%s SP", sp, maxSp),
                    string.format("%s INIT", init),
                }

                -- Insert level, based on user setting
                if ExtraInfo:GetSettingValue(ExtraInfo.Settings.Mode) == ExtraInfo.CHARACTER_LEVEL_MODES.IN_ALT_INFO then
                    local level = Character.GetLevel(char)

                    table.insert(texts, 1, string.format("Level %s", level))
                end
    
                text = Text.Join(texts, "  ")
            else -- Show resistances.
                local resistances = {}
    
                for _,resistanceId in ipairs(ExtraInfo.RESISTANCES_DISPLAYED) do
                    local amount = Character.GetResistance(char, resistanceId)
                    local color = ExtraInfo.RESISTANCE_COLORS[resistanceId]
                    local display = Text.Format("%s%%", {
                        Color = color,
                        FormatArgs = {
                            amount,
                        },
                    })
    
                    table.insert(resistances, display)
                end

                -- Insert some padding at the start
                text = " " .. Text.Join(resistances, "  ")
            end
        elseif item and item.Stats then -- Show item level.
            text = string.format("Level %s", item.Stats.Level)
        end
    
        -- Make text smaller.
        text = Text.Format(text, {Size = ExtraInfo.TEXT_SIZE})
    
        table.insert(ev.Labels, text)
    end
end)


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