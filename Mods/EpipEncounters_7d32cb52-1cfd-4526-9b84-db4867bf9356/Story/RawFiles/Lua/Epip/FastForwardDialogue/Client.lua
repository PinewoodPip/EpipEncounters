
---------------------------------------------
-- Implements an input action that auto-selects
-- dialogue options while held.
---------------------------------------------

local Dialog = Client.UI.Dialog
local GameMenu = Client.UI.GameMenu
local CommonStrings = Text.CommonStrings
local Input = Client.Input

---@type Feature
local FF = {
    STRATEGIES = {
        FIRST = 1,
        LAST = 2,
        RANDOM = 3,
    },

    _EVENTID_TICK_SELECT_OPTION = "Features.FastForwardDialogue.SelectOption",

    Settings = {},
    TranslatedStrings = {
        Setting_Strategy_Name = {
            Handle = "h98801058gfb66g43dfg99fbg957f057f235b",
            Text = "Fast-forward Strategy",
            ContextDescription = [[Setting name]],
        },
        Setting_Strategy_Description = {
            Handle = "hc6136040gde31g4d2ag8687g4b65823c2d20",
            Text = [[Determines which answers to pick while using the "Fast-forward Dialogue" keybind.]],
            ContextDescription = [[Setting tooltip for "Fast-forward Strategy"]],
        },
        Setting_Strategy_Choice_First = {
            Handle = "hb9ee62f3g9ee1g4045g85feg92d88e5fc29d",
            Text = "First answer",
            ContextDescription = [[Setting choice for "Fast-forward Strategy"]],
        },
        Setting_Strategy_Choice_Last = {
            Handle = "ha7270389gce2dg488fg97bcgcdfddf004180",
            Text = "Last answer",
            ContextDescription = [[Setting choice for "Fast-forward Strategy"]],
        },
        InputAction_FastForward_Name = {
            Handle = "h724c5f19g3e5eg405cgbb02g202b4219f120",
            Text = "Fast-forward Dialogue",
            ContextDescription = [[Keybind name]],
        },
        InputAction_FastForward_Description = {
            Handle = "hf56e75b9gec18g485bga1eag5f5401dab30b",
            Text = [[While held when in dialogue, options will automatically be picked according to the "Fast-forward Strategy" setting.]],
            ContextDescription = [[Keybind tooltip for "Fast-forward Dialogue"]],
        },
    },
}
Epip.RegisterFeature("Features.FastForwardDialogue", FF)
local TSK = FF.TranslatedStrings

---------------------------------------------
-- SETTINGS & INPUT ACTIONS
---------------------------------------------

FF.Settings.Strategy = FF:RegisterSetting("Strategy", {
    Type = "Choice",
    Name = TSK.Setting_Strategy_Name,
    Description = TSK.Setting_Strategy_Description,
    DefaultValue = FF.STRATEGIES.FIRST,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = FF.STRATEGIES.FIRST, NameHandle = TSK.Setting_Strategy_Choice_First.Handle},
        {ID = FF.STRATEGIES.LAST, NameHandle = TSK.Setting_Strategy_Choice_Last.Handle},
        {ID = FF.STRATEGIES.RANDOM, NameHandle = CommonStrings.Random.Handle}, -- TODO names
    }
})

FF.InputActions.FastForward = FF:RegisterInputAction("FastForward", {
    Name = TSK.InputAction_FastForward_Name,
    Description = TSK.InputAction_FastForward_Description,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Selects an answer to the current dialogue based on the current strategy.
---@param answers string[]? Defaults to the UI's current answers.
---@return integer? -- Index of the selected answer, 1-based. `nil` if there's no current interactable dialogue.
function FF.TryPickAnswer(answers)
    if not Dialog.IsInteractable() then return nil end
    answers = answers or Dialog.GetAnswers()
    local index = FF.GetAnswer(answers)
    Dialog.PickAnswer(index)
    return index
end

---Returns the answer to use based on the current strategy.
---@param answers string[]? Defaults to the UI's current answers.
---@return integer -- Index of the selected answer, 1-based.
function FF.GetAnswer(answers)
    answers = answers or Dialog.GetAnswers()
    local strategy = FF.Settings.Strategy:GetValue()
    local index
    if strategy == FF.STRATEGIES.FIRST then
        index = 1
    elseif strategy == FF.STRATEGIES.LAST then
        index = #answers
    elseif strategy == FF.STRATEGIES.RANDOM then
        index = math.random(#answers)
    end
    return index
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Fast-forward dialogue when the key is pressed in dialogue.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == FF.InputActions.FastForward.ID then
        FF.TryPickAnswer()
    end
end, {EnabledFunctor = Client.IsInDialogue})

-- Fast-forward dialogue while the key is held when new answers are added.
Dialog.Events.AnswersAdded:Subscribe(function (ev)
    local action = Input.GetCurrentAction()
    if action and action.ID == FF.InputActions.FastForward.ID then
        FF.TryPickAnswer(ev.Answers)
    end
end)

-- Allow executing the action in dialogue,
-- as actions normally cannot execute at that time.
Input.Hooks.CanExecuteAction:Subscribe(function (ev)
    if ev.Action.ID == FF.InputActions.FastForward.ID then
        ev.CanExecute = Client.IsInDialogue() and not GameMenu:IsVisible()
    end
end)
