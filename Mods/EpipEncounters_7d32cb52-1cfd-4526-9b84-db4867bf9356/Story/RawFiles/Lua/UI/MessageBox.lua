
---------------------------------------------
-- Hooks for msgBox.swf.
---------------------------------------------

---@meta MessageBoxUI, ContextClient

---@class MessageBoxUI
---@field POPUP_TYPES table<string, number>
---@field currentCustomMessageBox MessageBoxData Internal; do not set!

---@type MessageBoxUI
local MessageBox = {
    POPUP_TYPES = {
        -- TODO what is 1?
        MESSAGE = 2,
        INPUT = 3,
    },

    ---------------------------------------------
    -- Internal variables - do not set/read
    ---------------------------------------------
    currentCustomMessageBox = nil,
}
Client.UI.MessageBox = MessageBox
Epip.InitializeUI(Client.UI.Data.UITypes.msgBox, "MessageBox", MessageBox)

---@class MessageBoxButton
---@field ID number Used for events.
---@field Text string

---@type MessageBoxButton
local MessageBoxButton = {
    ID = 1,
    Text = "Close",
}

-- Template data table for ShowMessageBox(), with default values
---@class MessageBoxData
---@field Type MessageBoxType
---@field ID string Used for events.
---@field AcceptEmpty boolean Used with Input boxes, prevents closing if false and input field is empty.
---@field BoxID number
---@field Header string The title of the message.
---@field Message string Main text of the message.
---@field Buttons MessageBoxButton[] If omitted, default will be a "Close" button.

---@type MessageBoxData
local MessageBoxData = {
    Type = "Message",
    ID = "",
    BoxID = 3, -- TODO remove?
    AcceptEmpty = true,
    Header = "",
    Message = "",
    Buttons = {
        MessageBoxButton,
    },
}

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when a button is pressed on any custom message box.
---@class MessageBoxUI_ButtonClicked : Event
---@field id number Button ID.
---@field data MessageBoxData

---Fired when a message box with an input field is closed.
---@class MessageBoxUI_InputSubmitted : Event
---@field input string
---@field id number Button ID.
---@field data MessageBoxData

---------------------------------------------
-- METHODS
---------------------------------------------

---Show a message box.
---@param data MessageBoxData
function MessageBox.ShowMessageBox(data)
    local root = MessageBox:GetRoot()

    if not data.Header or not data.Message then
        MessageBox:LogError("Tried to display a message box with no header and/or message")
        return nil
    end

    setmetatable(data, {__index = MessageBoxData})

    -- Set metatables
    for i,button in pairs(data.Buttons) do
        setmetatable(button, {__index = MessageBoxButton})
    end

    local type = 2
    if data.Type == "Input" then
        type = 3
        -- Set focus for input fields, since the normal tracking in Utilities.lua fails and the focusInputEnabled method seems to not be called by engine.
        Client.Input.SetFocus(true)
    end

    MessageBox.Cleanup()

    for i,button in pairs(data.Buttons) do
        root.addButton(button.ID or i, button.Text, "", "") -- params 3 and 4 are just sounds
    end
    
    root.showWin()
    root.fadeIn()
    root.setPopupType(type)
    root.setInputEnabled(type == 3)

    root.showPopup(data.Header, data.Message)

    MessageBox.currentCustomMessageBox = data

    MessageBox:GetUI():Show()

    root.focusInputEnabled()

    MessageBox:FireMessageEvent(data.ID, "MessageBoxShown", data)
    MessageBox:FireEvent("MessageBoxShown", data)
end

---Register an event listener for a message box with a specific ID.
---@param id string Message box ID.
---@param event string Event ID. See the regular events.
---@param handler function
function MessageBox:RegisterMessageListener(id, event, handler)
    Utilities.Hooks.RegisterListener(MessageBox.MODULE_ID, id .. "_" .. event, handler)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------
function MessageBox.Cleanup()
    local root = MessageBox:GetRoot()

    root.setInputText("")
    root.removeButtons()
end

function MessageBox:FireMessageEvent(id, event, ...)
    Utilities.Hooks.FireEvent(MessageBox.MODULE_ID, id .. "_" .. event, ...)
end

-- Note to self: we tried moving this entirely to client.lua and it somehow became unreliable! wtf.
function MessageBox.CopyToClipboard(text)
    local root = MessageBox:GetRoot()

    root.setInputText(text)
    root.popup_mc.input_mc.acceptSave()
    -- root.getInputText()
    root.focusInputEnabled()

    -- Does not work.
    -- Ext.OnNextTick(function()
        -- Client.UI.MessageBox.UI:ExternalInterfaceCall("copyPressed")
    -- end)
    Client.Timer.Start("MsgBoxCopy", 0.2)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for paste event
Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.msgBox, "setInputText", function(ui, method, str)
    if MessageBox.currentCustomMessageBox then
        MessageBox.currentInput = str
    end
end)

Client.Timer.RegisterListener("MsgBoxCopy", function()
    Client.UI.MessageBox:GetUI():ExternalInterfaceCall("copyPressed")
end)

Ext.RegisterUINameCall("acceptInput", function(ui, method, str)
    local data = MessageBox.currentCustomMessageBox

    if data ~= nil then 
        MessageBox.currentInput = str
    end
end)

Ext.RegisterUINameCall("pastePressed", function(ui, method)
    local data = MessageBox.currentCustomMessageBox

    if data ~= nil then 
        MessageBox.currentInput = MessageBox:GetRoot().popup_mc.input_mc.input_txt.text
    end
end)

Ext.RegisterUITypeCall(Client.UI.Data.UITypes.msgBox, "ButtonPressed", function(ui, method, id, device)
    MessageBox:Log("Button pressed: " .. tostring(id))
    
    local data = MessageBox.currentCustomMessageBox

    if data ~= nil then
        local canClose = true

        local msgId = data.ID

        MessageBox:FireMessageEvent(msgId, "ButtonClicked", id, data)
        MessageBox:FireEvent("ButtonClicked", id, data)

        if data.Type == "Input" then
            -- MessageBox:GetRoot().popup_mc.input_mc.acceptSave()
            -- MessageBox:GetRoot().focusInputEnabled()

            -- local input = MessageBox.Root.popup_mc.input_mc.input_txt.text
            local input = MessageBox.currentInput or ""

            MessageBox:Log("Input submitted: " .. input)

            MessageBox:FireMessageEvent(msgId, "InputSubmitted", input, id, data)
            MessageBox:FireEvent("InputSubmitted", input, id, data)

            canClose = input ~= "" or data.AcceptEmpty
        end

        if canClose then
            Client.Input.interfaceFocused = false
            MessageBox.currentCustomMessageBox = nil

            ui:Hide()
            MessageBox.Cleanup()
        end
    end
end)