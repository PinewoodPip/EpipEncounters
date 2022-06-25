
---@meta Library: ChatLogUI, ContextClient, Client.UI.ChatLog

---@class ChatLogUI : UI

---@type ChatLogUI
local Chat = {
    Events = {
        ---@type ChatLogUI_Event_MessageSent
        MessageSent = {},
        ---@type ChatLogUI_Event_MessageAdded
        MessageAdded = {},
    },
    Hooks = {
        ---@type ChatLogUI_Hook_CanSendMessage
        CanSendMessage = {},
    },

    TABS = {
        LOCAL = 0,
        PARTY = 1,
        GLOBAL = 2, -- Unconfirmed.
    },
    CUSTOM_TABS = {},
    SENDER_COLOR = "bbbbbb",
    MESSAGE_COLOR = "ffffff",
    FONT_SIZE = 16,
    nextCustomTabID = 3,
}
Epip.InitializeUI(Client.UI.Data.UITypes.chatLog, "ChatLog", Chat)
Client.UI.ChatLog = Chat

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when the client sends a message in chat. TODO pass tab
---@class ChatLogUI_Event_MessageSent : Event
---@field RegisterListener fun(self, listener:fun(text:string, clientChar:EclCharacter))
---@field Fire fun(self, text:string, clientChar:EclCharacter)

---Fired when a message is rendered onto the UI.
---@class ChatLogUI_Event_MessageAdded : Event
---@field RegisterListener fun(self, listener:fun(tab:integer|string, text:string))
---@field Fire fun(self, tab:integer|string, text:string)

---Fired when the client attempts to send a message.
---@class ChatLogUI_Hook_CanSendMessage : Hook
---@field RegisterHook fun(self, handler:fun(canSend:boolean, text:string, char:EclCharacter))
---@field Return fun(self, canSend:boolean, text:string, char:EclCharacter)

---------------------------------------------
-- METHODS
---------------------------------------------

---Sends text onto the chatbox, using the vanilla colors and font sizes.
---@param tab integer|string Tab ID. See ChatLog.TABS enum. For custom tabs, use your string ID.
---@param userName string
---@param message string
function Chat.AddFormattedMessage(tab, userName, message)
    local msg = Text.Format("%s: %s", {
        FormatArgs = {
            {Text = userName, Color = Chat.SENDER_COLOR},
            {Text = message, Color = Chat.MESSAGE_COLOR},
        },
        Size = Chat.FONT_SIZE,
    })

    Chat.AddMessage(tab, msg)
end

---Clear a chat tab's messages.
---@param tab integer|string
-- function Chat.ClearTab(tab)
--     local root = Chat:GetRoot()
--     if type(tab) == "string" then tab = Chat.CUSTOM_TABS[tab] end

--     if not tab then
--         tab = root.log_mc.currentTab
--     end

--     root.log_mc.clearTab(tab)
-- end

---Render raw text onto the chatbox.
---@param tab? integer|string Tab ID. See ChatLog.TABS enum. For custom tabs, use your string ID. Defaults to current tab.
---@param text string
function Chat.AddMessage(tab, text)
    local root = Chat:GetRoot()

    -- Default to current tab
    if tab == nil then
        tab = root.log_mc.currentTab
    end

    -- Translate custom tab ID to number.
    if type(tab) == "string" then
        tab = Chat.CUSTOM_TABS[tab]

        if not tab then 
            Chat:LogError("Tried to add message to unregistered custom tab.")
        return nil end
    end

    root.addTextToTab(tab, text)
    Chat.Events.MessageAdded:Fire(tab, text)
end

---Adds a tab to the chat log.
---@param tabID string
---@param label string
function Chat.AddTab(tabID, label)
    local root = Chat:GetRoot()

    Chat.CUSTOM_TABS[tabID] = Chat.nextCustomTabID

    root.addTab(Chat.nextCustomTabID, label)

    Chat.nextCustomTabID = Chat.nextCustomTabID + 1
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Chat:RegisterCallListener("inputString", function(ev, text)
    local char = Client.GetCharacter()
    local canSend = Chat.Hooks.CanSendMessage:Return(true, text, char)

    if canSend then
        Chat.Events.MessageSent:Fire(text, char)
    else
        ev:PreventAction()
    end
end)

Chat:RegisterInvokeListener("addTextToTab", function(ev, tab, text)
    Chat.Events.MessageAdded:Fire(tab, text)
end)

