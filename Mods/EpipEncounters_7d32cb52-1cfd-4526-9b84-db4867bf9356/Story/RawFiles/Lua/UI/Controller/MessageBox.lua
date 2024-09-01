
local CommonStrings = Text.CommonStrings

---@class UI.Controller.MessageBox : UI
local MsgBox = {
    ---@enum UI.Controller.MessageBox.PopupType
    POPUP_TYPE = {
        MESSAGE = 1,
        INPUT = 3,
    },
    -- TODO move elsewhere and add the rest; these are from the shared controllerHelper.as script. Though this UI technically only supports these 4.
    ---@enum UI.Controller.MessageBox.ButtonID
    BUTTON_IDS = {
        B = 1,
        A = 2,
        X = 3,
        Y = 4,
    },

    _CurrentCustomMessage = nil, ---@type UI.Controller.MessageBox.Request

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        MessageClosed = {}, ---@type Event<UI.Controller.MessageBox.Events.MessageClosed>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.msgBox_c, "MsgBoxC", MsgBox, false)
Client.UI.Controller.MessageBox = MsgBox

---@type UI.Controller.MessageBox.Request.Buttons
MsgBox.DEFAULT_BUTTONS = {
    [MsgBox.BUTTON_IDS.A] = CommonStrings.Accept,
    [MsgBox.BUTTON_IDS.B] = CommonStrings.Cancel,
}

---@class UI.Controller.MessageBox.Request
---@field ID string?
---@field Header TextLib.String
---@field Body TextLib.String
---@field Type UI.Controller.MessageBox.PopupType? Defaults to message type.
---@field Buttons UI.Controller.MessageBox.Request.Buttons? Defaults to `DEFAULT_BUTTONS`.

---@alias UI.Controller.MessageBox.Request.Buttons table<UI.Controller.MessageBox.ButtonID, TextLib.String> Maps button to its label.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.Controller.MessageBox.Events.MessageClosed
---@field Message UI.Controller.MessageBox.Request
---@field ButtonID UI.Controller.MessageBox.ButtonID
---@field Text string? Text entered by the user. Only present for input messages.

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens a custom message box.
---@param request UI.Controller.MessageBox.Request
function MsgBox.Open(request)
    local root = MsgBox:GetRoot() -- TODO support multiple players
    request.Type = request.Type or MsgBox.POPUP_TYPE.MESSAGE

    root.setCopyBtnVisible(false)
    root.setPasteBtnVisible(false)
    root.setPopupType(request.Type)
    root.changeInputTextPos() -- Reposition text field based on copy & paste button availability.
    if request.Type == MsgBox.POPUP_TYPE.INPUT then
        root.setInputText("") -- Clear previous text.
        root.setInputEnabled(true)
        root.focusInputEnabled()
    end

    root.showPopup(Text.Resolve(request.Header), Text.Resolve(request.Body))

    -- Sort buttons by button ID.
    local buttons = request.Buttons or MsgBox.DEFAULT_BUTTONS
    local sortedButtons = {} ---@type {ID:integer, Label:TextLib.String}[]
    for id,label in pairs(buttons) do
        table.insert(sortedButtons, {ID = id, Label = label})
    end
    table.sort(sortedButtons, function (a, b)
        return a.ID > b.ID
    end)

    -- Render buttons.
    root.clearBtnHints()
    for _,button in ipairs(sortedButtons) do
        root.addBtnHint(-button.ID, Text.Resolve(button.Label), button.ID, button.ID) -- Params 4 & 5 are max width and enabled state respectively, with default values.
    end

    MsgBox._CurrentCustomMessage = request
    root.showWin()
    MsgBox:Show()
end

---Closes the current custom message.
function MsgBox._Close()
    local root = MsgBox:GetRoot() -- TODO support multiple players
    root.hideWin()
    MsgBox:Hide()

    MsgBox._CurrentCustomMessage = nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Handle custom message boxes being closed.
MsgBox:RegisterCallListener("ButtonPressed", function (ev, buttonID, _) -- Last param is device ID.
    local customMsg = MsgBox._CurrentCustomMessage
    if customMsg then
        MsgBox.Events.MessageClosed:Throw({
            Message = customMsg,
            ButtonID = buttonID,
            Text = customMsg.Type == MsgBox.POPUP_TYPE.INPUT and ev.UI:GetRoot().popup_mc.input_mc.input_txt.text or nil,
        })
        MsgBox._Close()
    end
end)
