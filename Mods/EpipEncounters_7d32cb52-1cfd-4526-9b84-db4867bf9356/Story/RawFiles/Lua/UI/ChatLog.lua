
---@class ChatLogUI : UI
local Chat = {
    Events = {
        MessageSent = {Preventable = true}, ---@type PreventableEvent<ChatLogUI_Event_MessageSent>
        MessageAdded = {Preventable = true}, ---@type PreventableEvent<ChatLogUI_Event_MessageAdded>
    },
    Hooks = {

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
    nextMessageIsFromClient = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.InitializeUI(Client.UI.Data.UITypes.chatLog, "ChatLog", Chat)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when the client sends a message in chat. TODO pass tab
---@class ChatLogUI_Event_MessageSent
---@field Text string
---@field Character EclCharacter
---@field Tab integer|string String for custom tabs.

---Fired when a message is rendered onto the UI.
---@class ChatLogUI_Event_MessageAdded
---@field Tab integer|string String for custom tabs.
---@field Text string
---@field IsFromClient boolean Whether this message was typed by the client.

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
            Chat:LogError("Tried to add message to unregistered custom tab " .. tab)
        return nil end
    end

    if Chat._OnMessageAdded(nil, tab, text) then
        root.addTextToTab(tab, text)
    end
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

---@param ev EclLuaUICallEvent
---@param tab integer
---@param text string
---@return boolean True for success (not prevented).
function Chat._OnMessageAdded(ev, tab, text)
    local event = Chat.Events.MessageAdded:Throw({
        Text = text,
        Tab = Chat.GetTabStringID(tab) or tab,
        IsFromClient = Chat.nextMessageIsFromClient,
    })

    if ev and event.Prevented then
        ev:PreventAction()
    end

    return not event.Prevented
end

---@param numID integer
---@return string?
function Chat.GetTabStringID(numID)
    return table.reverseLookup(Chat.CUSTOM_TABS, numID)
end

---@return integer|string
function Chat.GetCurrentTab()
    local numericID = Chat:GetRoot().log_mc.currentTab
    local id = numericID

    local customTabID = Chat.GetTabStringID(id)
    if customTabID then
        id = customTabID
    end

    return id
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to send messages.
Chat:RegisterCallListener("inputString", function(ev, text)
    -- Only fire the event if the text field was focused, as this call can also fire when the user clicks the button while the field is unfocused and empty.
    if not Chat:IsTextFocused() then return end

    local char = Client.GetCharacter()
    local event = Chat.Events.MessageSent:Throw({
        Character = char,
        Text = text,
        Tab = Chat.GetCurrentTab(),
    })

    Chat:DebugLog("Client attempting to send msg: ", text)

    if event.Prevented then
        ev:PreventAction()
    elseif text ~= "" then -- Empty messages do not get sent by the engine.
        Chat.nextMessageIsFromClient = true
    end
end)

Chat:RegisterInvokeListener("addTextToTab", function(ev, tab, text)
    Chat._OnMessageAdded(ev, tab, text)

    Chat.nextMessageIsFromClient = false
end)

