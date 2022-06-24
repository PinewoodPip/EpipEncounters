
---@meta ClientInput, ContextClient

---@class Input
---@field HeldKeys table<number, boolean> The events currently in a pressed state.
---@field INPUT_EVENTS table<string, number> Internal; do not set!
---@field MODIFIER_KEYS number[] Internal; do not set!

---@type Input
local Input = {
    HeldKeys = {},

    -- Not complete!
    INPUT_EVENTS = {
        CLICK = 1,
        INTERACT = 4,
        CANCEL_ACTION = 223,
        QUEUE_COMMAND = 232,
        ZOOM_OUT = 233,
        ZOOM_IN = 234,
        UNSHEATHE = 237,
        FORCE_ATTACK = 242,
        TOGGLE_UI = 214,
        TOGGLE_MENU = 241,
        SHOW_SNEAK_CONES = 285,
        GM_ALIGN_TO_TERRAIN = 269,
        GM_TOGGLE_MINIMAP = 265
    },
    CONTROLLER_EVENTS = {
        RIGHT_BUTTON = 233,
        LEFT_BUTTON = 234,
        RIGHT_TRIGGER = 217,
        LEFT_TRIGGER = 215,
        LEFT_STICK_PRESS = 243,
        RIGHT_STICK_PRESS = 280,
        INTERACT = 4,
        BUTTON_B = 244,
    },
    -- Todo write a script to find all of these
    FLASH_EVENTS = {
        TOGGLE_MENU = "IE ToggleInGameMenu",
        ACCEPT = "IE UIAccept",
        CANCEL = "IE UICancel",
        UP = "IE UIUp",
        DOWN = "IE UIDown",
        LEFT = "IE UILeft",
        RIGHT = "IE UIRight",
        TOOLTIP_UP = "IE UITooltipUp",
        TOOLTIP_DOWN = "IE UITooltipDown",
        SHOW_INFO = "IE UIShowInfo",
        END_TURN = "IE UIEndTurn",
        HOTBAR_PREV = "IE UIHotBarPrev",
        HOTBAR_NEXT = "IE UIHotBarNext",
        CONTROLLER_CONTEXT_MENU = "IE ControllerContextMenu",
        TAB_PREV = "IE UITabPrev",
        TAB_NEXT = "IE UITabNext",
        BACK = "IE UIBack",
        CREATION_TAB_PREV = "IE UICreationTabPrev",
        CREATION_TAB_NEXT = "IE UICreationTabNext",
        TOGGLE_EQUIPMENT = "IE UIToggleEquipment",
        EDIT_CHARACTER = "IE UIEditCharacter",
        START_GAME = "IE UIStartGame",
        CONTEXT_MENU = "IE ContextMenu",
        SHOW_TOOLTIP = "IE UIShowTooltip",
        MESSAGE_BOX_X = "IE UIMessageBoxX",
        FILTER = "IE UIFilter",
        COMPARE_ITEMS = "IE UICompareItems",
        TAKE_ALL = "IE UITakeAll",
        TOGGLE_MULTI_SELECT = "IE UIToggleMultiselection",
        COMBINE = "IE Combine",
        DIALOG_TEXT_UP = "IE UIDialogTextUp",
        DIALOG_TEXT_DOWN = "IE UIDialogTextDown",
        TOGGLE_DIPLOMACY = "IE ToggleDiplomacyPanel",
        TOGGLE_HELMET = "IE UIToggleHelmet",
        TOGGLE_INVENTORY = "IE ToggleInventory",
        CREATE_PROFILE = "IE UICreateProfile",
        SEND = "IE UISend",
        BALANCE_TRADE = "IE UITradeBalance",
        SELECT_SLOT_1 = "IE UISelectSlot1",
        SELECT_SLOT_2 = "IE UISelectSlot2",
        SELECT_SLOT_3 = "IE UISelectSlot3",
        SELECT_SLOT_4 = "IE UISelectSlot4",
        SELECT_SLOT_5 = "IE UISelectSlot5",
        SELECT_SLOT_6 = "IE UISelectSlot6",
        SELECT_SLOT_7 = "IE UISelectSlot7",
        SELECT_SLOT_8 = "IE UISelectSlot8",
        SELECT_SLOT_9 = "IE UISelectSlot9",
        SELECT_SLOT_10 = "IE UISelectSlot10",
        SELECT_SLOT_11 = "IE UISelectSlot11",
        SELECT_SLOT_12 = "IE UISelectSlot12",
        TOGGLE_ACTIONS = "IE UIToggleActions",
        MARK_WARES = "IE UIMarkWares",
        GM_SET_HEALTH = "IE GMSetHealth",
        PING = "IE Ping",
        TOGGLE_MAP = "IE ToggleMap",
        MAP_REMOVE_MARKER = "IE UIMapRemoveMarker",
        TOGGLE_JOURNAL = "IE ToggleJournal",
    },
    MODIFIER_KEYS = {285},
}
Client.Input = Input
Epip.InitializeLibrary("Input", Input)
-- Input:Debug()

---Returns true if the game is unpaused and there are no focused elements in Flash.
---@return boolean
function Input.IsAcceptingInput()
    return not Utilities.isPaused and not Input.interfaceFocused
end

---Returns true if the key bound to the event `id` is being held.  
---Note that not all InputEvents support being held.
---@param id number Input event id.
---@return boolean
function Input.KeyHeld(id)
    return Input.HeldKeys[id]
end

---Returns whether a modifier key is being held.  
---Set modifier keys with `Input.SetModifierKey`.  
---Default is ToggleSneakCones.
---@param num number? Which modifier key to check.
---@return boolean
function Input.IsHoldingModifierKey(num)
    num = num or 1
    return Input.HeldKeys[Input.MODIFIER_KEYS[num]]
end

---Sets the InputEvent for a modifier key.  
---You can declare as many modifier keys as you want,  
---and query them with `Input.IsHoldingModifierKey()`.
---@param event number The InputEvent.
---@param num number Which modifier key to set.
function Input.SetModifierKey(event, num)
    Input.MODIFIER_KEYS[num] = event
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function Input.SetFocus(focused)
    Input.interfaceFocused = focused
    Input:FireEvent("FocusChanged", focused)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Track focus gain/loss in UI
Ext.RegisterUINameCall("inputFocus", function(ui, method) 
    Input.SetFocus(true)
end)

Ext.RegisterUINameCall("inputFocusLost", function(ui, method) 
    Input.SetFocus(false)
end)

-- Listen for input events.
Ext.Events.InputEvent:Subscribe(function(event)
    event = event.Event

    Input.HeldKeys[event.EventId] = event.Press

    if Input:IsDebug() then
        -- TODO fix
        if not Input.INPUT_EVENTS[event.EventId] and not Input.CONTROLLER_EVENTS[event.EventId] then
            Input:DebugLog("INPUT ID NOT IN ENUM: " .. event.EventId)
            -- Input:Dump(event)
            -- print(OptionsMenu:GetKey(event.EventId))
        end
    end

    -- Fire event for sneak cones. TODO generic ones too!
    if event.EventId == Input.INPUT_EVENTS.SHOW_SNEAK_CONES then
        Input:FireEvent("SneakConesToggled", event.Press)
    end
end)