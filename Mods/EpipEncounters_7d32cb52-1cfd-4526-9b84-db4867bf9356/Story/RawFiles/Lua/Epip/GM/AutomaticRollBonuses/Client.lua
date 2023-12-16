
---------------------------------------------
-- Implements automatic "added value" bonuses to rolls.
---------------------------------------------

local Roll = Client.UI.GM.Roll
local Notification = Client.UI.Notification

---@class Features.GM.AutomaticRollBonuses : Feature
local RollBonuses = {
    AUTOMATIC_BONUS_TYPE = {
        NONE = 1,
        ATTRIBUTE_BASED = 2,
    },

    Settings = {},
    TranslatedStrings = {
        Setting_AutomaticBonus_Name = {
            Handle = "h2e0dd640gb3b8g4eb2ga012gb9e60601636a",
            Text = "Automatic Roll Bonus",
            ContextDescription = "Setting name; 'roll' refers to dice rolls",
        },
        Setting_AutomaticBonus_Description = {
            Handle = "h470d8e3eg7fcfg4136g8f86g8c6813a3e43d",
            Text = "Determines the automatic value bonus to apply to dice roll requests for playable characters. Only applies to rolls requested for a single character, and does not affect GM rolls.",
            ContextDescription = "Setting tooltip",
        },
        Setting_AutomaticBonus_Choice_AttributeBased = {
            Handle = "h775b02a6gb863g4905g8236gb25783da02b0",
            Text = "Attribute-based",
            ContextDescription = "Setting choice for 'Automatic Roll Bonus'",
        },
        Notification_AddedBonus = {
            Handle = "h37a8a223g5123g4baeg9459g9273671626b0",
            Text = "Added %s%d from attribute.",
            ContextDescription = "Notification from adding an automatic roll bonus",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetBonus = {}, ---@type Hook<{Character:EclCharacter, Bonus:integer}> -- Bonus is hookable, defaults to 0.
    },
}
Epip.RegisterFeature("Features.GM.AutomaticRollBonuses", RollBonuses)
local TSK = RollBonuses.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

RollBonuses.Settings.AutomaticBonus = RollBonuses:RegisterSetting("AutomaticBonus", {
    Type = "Choice",
    Context = "Client",
    NameHandle = TSK.Setting_AutomaticBonus_Name,
    DescriptionHandle = TSK.Setting_AutomaticBonus_Description,
    DefaultValue = RollBonuses.AUTOMATIC_BONUS_TYPE.NONE,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = RollBonuses.AUTOMATIC_BONUS_TYPE.NONE, NameHandle = Text.CommonStrings.None.Handle},
        {ID = RollBonuses.AUTOMATIC_BONUS_TYPE.ATTRIBUTE_BASED, NameHandle = TSK.Setting_AutomaticBonus_Choice_AttributeBased.Handle},
    },
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the automatic bonus for a character.
---Hookable.
---@param char EclCharacter
---@return integer
function RollBonuses.GetBonus(char)
    return RollBonuses.Hooks.GetBonus:Throw({
        Character = char,
        Bonus = 0,
    }).Bonus
end

---Returns a simple attribute-based roll bonus.
---@param char EclCharacter
---@param statCheck UI.GM.Roll.StatCheckType
---@return integer
function RollBonuses._GetAddedValueFromAttribute(char, statCheck)
    local attributeScore = 10
    local addedValue

    if statCheck == Roll.STAT_CHECK_TYPE.STRENGTH then
        attributeScore = char.Stats.Strength
    elseif statCheck == Roll.STAT_CHECK_TYPE.FINESSE then
        attributeScore = char.Stats.Finesse
    elseif statCheck == Roll.STAT_CHECK_TYPE.INTELLIGENCE then
        attributeScore = char.Stats.Intelligence
    elseif statCheck == Roll.STAT_CHECK_TYPE.CONSTITUTION then
        attributeScore = char.Stats.Constitution
    elseif statCheck == Roll.STAT_CHECK_TYPE.MEMORY then
        attributeScore = char.Stats.Memory
    elseif statCheck == Roll.STAT_CHECK_TYPE.WITS then
        attributeScore = char.Stats.Wits
    end

    addedValue = attributeScore - 10

    return addedValue
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the "added value" display on the UI with any automatic bonuses.
GameState.Events.RunningTick:Subscribe(function (_)
    if Roll:IsVisible() and not Roll.IsInGameMasterPanel() then
        local root = Roll:GetRoot()
        local rollsPanel = root.dmRollsPanel_mc
        local dicesPanel = rollsPanel.dicesPanel_mc
        local totalTxt = dicesPanel.total_txt
        local diceStr = string.format("%dd%d", dicesPanel.numberOfDices, dicesPanel.dice)
        local addedValue = dicesPanel.addedValue
        local characters = Roll.GetSelectedCharacters()

        if addedValue ~= 0 then
            diceStr = diceStr .. " " .. (addedValue > 0 and "+" or "") .. " " .. Text.RemoveTrailingZeros(addedValue)
        end

        if #characters == 1 then
            local bonusValue = RollBonuses.GetBonus(characters[1])

            if bonusValue ~= 0 then
                diceStr = diceStr .. " " .. (bonusValue > 0 and "+" or "") .. " " .. Text.RemoveTrailingZeros(bonusValue)
            end
        end

        totalTxt.text = diceStr
    end
end)

-- Apply automatic roll bonuses.
Roll.Hooks.RollRequested:Subscribe(function (ev)
    -- Can only add value from attributes if the roll is for a single character, as the UI call only tracks the added value for all characters, and the UI itself does not allow simulataneous different rolls for different characters(?)
    if not ev.IsGameMasterRoll and #ev.Characters == 1 then
        local addedValue = RollBonuses.GetBonus(ev.Characters[1])

        ev.AddedValue = ev.AddedValue + addedValue

        if addedValue ~= 0 then
            Notification.ShowNotification(TSK.Notification_AddedBonus:Format(addedValue > 0 and "+" or "-", addedValue))
        end
    end
end)

-- Default implementation of GetBonus.
RollBonuses.Hooks.GetBonus:Subscribe(function (ev)
    local bonusSetting = RollBonuses.Settings.AutomaticBonus:GetValue()
    if bonusSetting == RollBonuses.AUTOMATIC_BONUS_TYPE.ATTRIBUTE_BASED then
        ev.Bonus = RollBonuses._GetAddedValueFromAttribute(ev.Character, Roll.GetSelectedAbility())
    end
end, {StringID = "DefaultImplementation"})
