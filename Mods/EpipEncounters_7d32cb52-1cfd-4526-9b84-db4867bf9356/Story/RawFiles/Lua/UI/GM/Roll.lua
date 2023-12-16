
---@class UI.GM.Roll : UI
local Roll = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    ---@enum UI.GM.Roll.StatCheckType
    STAT_CHECK_TYPE = {
        FREE_ROLL = 0,
        STRENGTH = 1,
        FINESSE = 2,
        INTELLIGENCE = 3,
        CONSTITUTION = 4,
        MEMORY = 5,
        WITS = 6,
    },

    Hooks = {
        RollRequested = {}, ---@type Event<UI.GM.Roll.Hooks.RollRequested>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.roll, "Roll", Roll, false)
Client.UI.GM.Roll = Roll

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.GM.Roll.Hooks.RollRequested
---@field DiceType integer Hookable. Amount of faces on the die.
---@field DiceAmount integer Hookable. Amount of dice to throw.
---@field StatCheckType UI.GM.Roll.StatCheckType Hookable.
---@field AddedValue integer Hookable.
---@field Characters EclCharacter[] Empty if the roll was a GM-made roll.
---@field IsGameMasterRoll boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the UI is in the Game Master roll panel.
---@return boolean
function Roll.IsInGameMasterPanel()
    return Roll:GetRoot().tabGMRolls_mc.Active
end

---Returns the players selected for making a roll.
---@return EclCharacter[] -- Will be empty if the UI was in the Game Master roll panel.
function Roll.GetSelectedCharacters()
    local root = Roll:GetRoot()
    local characters = {}

    if not Roll.IsInGameMasterPanel() then
        local playerArr = root.playerContainer_mc.player_array.content_array
        for i=0,#playerArr-1,1 do
            local player = playerArr[i]
            if player.selected then
                table.insert(characters, Character.Get(player._handle, true))
            end
        end
    end

    return characters
end

---Returns the currently-selected ability for the roll.
---@return UI.GM.Roll.StatCheckType
function Roll.GetSelectedAbility()
    local root = Roll:GetRoot()
    local rollsPanel = root.dmRollsPanel_mc

    return rollsPanel.selectedAbility
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hook roll requests.
Roll:RegisterCallListener("requestRoll", function (ev, num1, diceType, diceAmount, addedValue, selectedAbility, scripted)
    if scripted then return end
    local isGameMaster = Roll.IsInGameMasterPanel()
    local characters = Roll.GetSelectedCharacters()

    local hook = Roll.Hooks.RollRequested:Throw({
        DiceType = diceType,
        DiceAmount = diceAmount,
        StatCheckType = selectedAbility,
        AddedValue = addedValue,
        Characters = characters,
        IsGameMasterRoll = isGameMaster,
    })

    -- Redo the UI call with the scripted flag set.
    ev:PreventAction()
    ev.UI:ExternalInterfaceCall("requestRoll", num1, hook.DiceType, hook.DiceAmount, hook.AddedValue, hook.StatCheckType, true)
end, "Before")
