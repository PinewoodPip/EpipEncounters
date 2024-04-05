
---------------------------------------------
-- Hooks for msgBox.swf.
---------------------------------------------

---@meta MessageBoxUI, ContextClient

---@class MessageBoxUI : UI
---@field POPUP_TYPES table<string, number>
---@field currentCustomMessageBox MessageBoxData Internal; do not set!

---@class MessageBoxUI
local MessageBox = {
    POPUP_TYPES = {
        -- TODO Cleanup. These values are wrong
        MESSAGE = 1,
        INPUT = 2,
    },

    ---@type table<string, MessageBoxButtonType>
    BUTTON_TYPES = {
        NORMAL = "Normal",
        BLUE = "Blue",
        ACCEPT = "Yes",
        DECLINE = "No",
    },

    Events = {
        ---@type MessageBoxUI_Event_ClipboardTextRequestComplete
        ClipboardTextRequestComplete = {},
        ---@type MessageBoxUI_Event_ButtonPressed
        ButtonPressed = {},
        ---@type MessageBoxUI_Event_InputSubmitted
        InputSubmitted = {},
        ---@type MessageBoxUI_Event_MessageShown
        MessageShown = {},
    },
    Hooks = {

    },
    -- PATH = "Public/Game/GUI/msgBox.swf",
    -- PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/msgBox.swf",

    ---------------------------------------------
    -- Internal variables - do not set/read
    ---------------------------------------------
    currentCustomMessageBox = nil,
}
Epip.InitializeUI(Ext.UI.TypeID.msgBox, "MessageBox", MessageBox)
MessageBox:Debug()

---@alias MessageBoxButtonType "Normal" | "Blue" | "Yes" | "No"
---@alias MessageBoxType "Message" | "Input"

---@class MessageBoxButton
---@field ID number? Used for events. Can be auto-assigned, starting from 0.
---@field Text string
---@field Type MessageBoxButtonType? Defaults to Normal.

---@type MessageBoxButton
local MessageBoxButton = {
    ID = 0,
    Text = "Close",
    Type = MessageBox.BUTTON_TYPES.NORMAL,
}

-- Template data table for Open(), with default values
---@class MessageBoxData
---@field Type MessageBoxType
---@field ID string Used for events.
---@field AcceptEmpty boolean? Used with Input boxes, prevents closing if false and input field is empty. Defaults to false.
---@field Header string The title of the message.
---@field Message string Main text of the message.
---@field Buttons MessageBoxButton[] If omitted, default will be a "Close" button.
local MessageBoxData = {
    Type = "Message",
    ID = "",
    AcceptEmpty = true,
    Header = "",
    Message = "",
    Buttons = {
        MessageBoxButton,
    },
}

function MessageBoxData:GetNumericType()
    return MessageBox.POPUP_TYPES[self.Type:upper()]
end

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when a custom message box is shown.
---@class MessageBoxUI_Event_MessageShown : Event
---@field RegisterListener fun(self, listener:fun(messageID:string, message:MessageBoxData))
---@field Fire fun(self, messageID:string, message:MessageBoxData)

---Fired when a button is pressed on any custom message box.
---@class MessageBoxUI_Event_ButtonPressed : Event
---@field RegisterListener fun(self, listener:fun(messageID:string, buttonID:number, message:MessageBoxData))
---@field Fire fun(self, messageID:string, buttonID:number, message:MessageBoxData)

---Fired when a message box with an input field is closed.
---@class MessageBoxUI_Event_InputSubmitted : Event
---@field RegisterListener fun(self, listener:fun(messageID:string, text:string, buttonID:number, message:MessageBoxData))
---@field Fire fun(self, messageID:string, text:string, buttonID:number, message:MessageBoxData)

---@class MessageBoxUI_Event_ClipboardTextRequestComplete : Event
---@field RegisterListener fun(self, listener:fun(id:string, text:string))
---@field Fire fun(self, id:string, text:string)

---------------------------------------------
-- METHODS
---------------------------------------------

---Show a message box.
---@param data MessageBoxData
function MessageBox.Open(data)
    local root = MessageBox:GetRoot()

    if not data.Header or not data.Message then
        MessageBox:LogError("Tried to display a message box with no header and/or message")
        return nil
    end

    -- Set metatables
    for _,button in pairs(data.Buttons or {}) do
        Inherit(button, MessageBoxButton)
    end
    Inherit(data, MessageBoxData)

    local type = MessageBox.POPUP_TYPES[data.Type:upper()] or MessageBox.POPUP_TYPES.MESSAGE

    MessageBox.Cleanup(MessageBox:GetUI(), false)

    for i,button in pairs(data.Buttons) do
        root.addButton(button.ID or i, button.Text, "", "") -- params 3 and 4 are just sounds
    end
    
    root.showWin()
    root.fadeIn()

    if type == MessageBox.POPUP_TYPES.INPUT then
        root.setPopupType(3)
    else
        root.setPopupType(1)
    end
    
    root.setInputEnabled(type == MessageBox.POPUP_TYPES.INPUT)

    root.showPopup(data.Header, data.Message)

    MessageBox.currentCustomMessageBox = data

    MessageBox:GetUI():Show()

    root.focusInputEnabled()

    MessageBox.Events.MessageShown:Fire(data.ID, data)
end

---Register an event listener for a message box with a specific ID.
---@param id string Message box ID.
---@param event Event Event ID. See the regular events.
---@param handler function
function MessageBox.RegisterMessageListener(id, event, handler)
    event:RegisterListener(function(messageID, ...)
        if id == messageID then
            handler(...)
        end
    end)
end

---Returns the text currently entered in the UI by the user.
---@return string
function MessageBox.GetCurrentInput() -- TODO consider currentInput var?
    return MessageBox:GetRoot().popup_mc.input_mc.input_txt.text
end

---Requests the contents of the user's clipboard.
---It will be returned via the ClipboardTextRequestComplete event, **asynchronously**.
---@param requestID string
function MessageBox.RequestClipboardText(requestID)
    Client.UI.MessageBox:GetUI():ExternalInterfaceCall("pastePressed")

    Timer.Start("PIP_MessageBoxPaste", 0.1, function()
        local text = MessageBox.GetCurrentInput()

        MessageBox.Events.ClipboardTextRequestComplete:Fire(requestID, text)
    end)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function MessageBox.Cleanup(ui, close)
    local root = ui:GetRoot()

    MessageBox.currentCustomMessageBox = nil

    if close or close == nil then
        ui:Hide()
    end

    root.setInputText("")
    root.removeButtons()
end

-- Note to self: we tried moving this entirely to client.lua and it somehow became unreliable! wtf.

---Copies text to the clipboard, without opening the UI.
function MessageBox.CopyToClipboard(text)
    local root = MessageBox:GetRoot()

    root.setInputText(text)
    root.popup_mc.input_mc.acceptSave()
    root.focusInputEnabled()

    -- Does not work.
    -- Ext.OnNextTick(function()
        -- Client.UI.MessageBox.UI:ExternalInterfaceCall("copyPressed")
    -- end)
    Timer.Start("MsgBoxCopy", 0.2, function()
        MessageBox:GetUI():ExternalInterfaceCall("copyPressed")
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Close the message box on reset, since we will have lost the custom message data anyways.
-- TODO fix
Ext.Events.ResetCompleted:Subscribe(function()
    Timer.Start("", 0.5, function() MessageBox:GetUI():Hide() end)
end)

-- Listen for paste-like events
MessageBox:RegisterInvokeListener("setInputText", function(ev, str)
    if MessageBox.currentCustomMessageBox then
        MessageBox.currentInput = str
    end
end)

MessageBox:RegisterCallListener("pastePressed", function(ev)
    if MessageBox.currentCustomMessageBox then 
        MessageBox.currentInput = MessageBox.GetCurrentInput()
    end
end)

-- Listen for input being updates
MessageBox:RegisterCallListener("acceptInput", function(ev, str)
    if MessageBox.currentCustomMessageBox then 
        MessageBox.currentInput = str
    end
end)

MessageBox:RegisterCallListener("ButtonPressed", function(ev, id, device)
    MessageBox:DebugLog("Button pressed:", id)
    
    local data = MessageBox.currentCustomMessageBox

    if data then
        local canClose = true
        local msgId = data.ID

        MessageBox.Events.ButtonPressed:Fire(data.ID, id, data)

        if data:GetNumericType() == MessageBox.POPUP_TYPES.INPUT then
            -- MessageBox:GetRoot().popup_mc.input_mc.acceptSave()
            -- MessageBox:GetRoot().focusInputEnabled()

            -- local input = MessageBox.Root.popup_mc.input_mc.input_txt.text
            local input = MessageBox.currentInput or ""

            MessageBox:DebugLog("Input submitted:", input)

            MessageBox.Events.InputSubmitted:Fire(data.ID, input, id, data)

            canClose = input ~= "" or data.AcceptEmpty
        end

        if canClose then
            Client.Input.interfaceFocused = false

            MessageBox.Cleanup(ev.UI)
        end
    end
end)