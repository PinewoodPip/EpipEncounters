
local Flash = Client.Flash

---@class UI.Dialog : UI
local Dialog = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    FLASH_ENTRY_TEMPLATES = {
        ANSWER = {
            "Unknown1",
            "Label",
            "Unknown2",
        },
    },

    Events = {
        AnswersAdded = {}, ---@type Event<Dialog.UI.Events.AnswersAdded>
    },
    Hooks = {
        AddAnswers = {}, ---@type Hook<{Answers: Dialog.UI.KeywordAnswer[]}>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.dialog, "Dialog", Dialog)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Dialog.UI.Events.AnswersAdded
---@field Answers string[]

---@class Dialog.UI.KeywordAnswer
---@field Unknown1 integer
---@field Label string
---@field Unknown2 boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the current dialogue's response options.
---@return string[]
function Dialog.GetAnswers()
    local root = Dialog:GetRoot()
    local dialog = root.dialog_mc
    local optionsHolder = dialog.playerOptionsHolder
    local answersArr = optionsHolder.answer_array
    local options = {} ---@type string[]
    for i=0,#answersArr-1,1 do
        local option = answersArr[i]
        options[i + 1] = option.text_txt.htmlText
    end
    return options
end

---Picks a response option for the current dialogue.
---@param index integer 1-based.
function Dialog.PickAnswer(index)
    Dialog:ExternalInterfaceCall("QuestionPressed", index - 1)
end

---Returns whether the client can interact with the current dialogue.
---@return boolean
function Dialog.IsInteractable()
    return Dialog:GetRoot().dialog_mc.dialogActive
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Throw events when new answers are added.
local _AddedAnswers = false
Dialog:RegisterInvokeListener("updateDialog", function (_)
    local arr = Dialog:GetRoot().addAHArray
    local answersArr = Dialog:GetRoot().addKWAnswerArray

    -- Throw answers hook
    local answers = Flash.ParseArray(answersArr, Dialog.FLASH_ENTRY_TEMPLATES.ANSWER)
    answers = Dialog.Hooks.AddAnswers:Throw({
        Answers = answers,
    }).Answers
    Flash.EncodeArray(answersArr, Dialog.FLASH_ENTRY_TEMPLATES.ANSWER, answers)

    _AddedAnswers = #arr > 0 -- Not all updates add answers.
end, "Before")
Dialog:RegisterInvokeListener("updateDialog", function (_)
    if _AddedAnswers then
        Ext.OnNextTick(function () -- The answers array will be null when accessed immediately from this listener.
            local answers = Dialog.GetAnswers()
            Dialog.Events.AnswersAdded:Throw({
                Answers = answers,
            })
        end)
    end
    _AddedAnswers = false
end, "After")
