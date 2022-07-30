
---@class InputLib : Feature
local Input = {
    HeldKeys = {},

    keyStates = {},
    mouseState = nil, ---@type InputMouseState

    RAW_INPUT_TYPES = {
        KEY = "Key",
        MOUSE = "Mouse",
        TOUCH_BAR = "Touchbar",
    },

    MOUSE_RAW_INPUT_EVENTS = {
        MOTION = true,
        MOTION_X_NEGATIVE = true,
        MOTION_Y_POSITIVE = true,
        MOTION_X_POSITIVE = true,
        MOTION_Y_NEGATIVE = true,
    },

    NORBYTE_ENUM_NAMES = {
        NUM0 = "NUM_0",
        NUM1 = "NUM_1",
        RIGHT2 = "RIGHT_2",
        NUM2 = "NUM_2",
        NUM3 = "NUM_3",
        NUM4 = "NUM_4",
        NUM5 = "NUM_5",
        NUM6 = "NUM_6",
        NUM7 = "NUM_7",
        NUM8 = "NUM_8",
        NUM9 = "NUM_9",
        KP_DIVIDE = "KEYPAD_DIVIDE",
        KP_MULTIPLY = "KEYPAD_MULTIPLY",
        KP_MINUS = "KEYPAD_MINUS",
        KP_PLUS = "KEYPAD_PLUS",
        KP_ENTER = "KEYPAD_ENTER",
        KP_1 = "KEYPAD_1",
        KP_2 = "KEYPAD_2",
        KP_3 = "KEYPAD_3",
        KP_4 = "KEYPAD_4",
        KP_5 = "KEYPAD_5",
        KP_6 = "KEYPAD_6",
        KP_7 = "KEYPAD_7",
        KP_8 = "KEYPAD_8",
        KP_9 = "KEYPAD_9",
        KP_10 = "KEYPAD_0",
        KP_PERIOD = "KEYPAD_PERIOD",
        LCTRL = "LEFT_CTRL",
        LALT = "LEFT_ALT",
        LSHIFT = "LEFT_SHIT",
        LGUI = "LEFT_GUI",
        RCTRL = "RIGHT_CTRL",
        RSHIFT = "RIGHT_SHIFT",
        RALT = "RIGHT_ALT",
        RGUI = "RIGHT_GUI",
        LEFT2 = "LEFT_2",
        MOTION_XNEG = "MOTION_X_NEGATIVE",
        MOTION_YPOS = "MOTION_Y_POSITIVE",
        MOTION_XPOS = "MOTION_X_POSITIVE",
        MOTION_YNEG = "MOTION_Y_NEGATIVE",
        WHEEL_XPOS = "WHEEL_X_POSITIVE",
        WHEEL_XNEG = "WHEEL_X_NEGATIVE",
        WHEEL_YPOS = "WHEEL_Y_POSITIVE",
        WHEEL_YNEG = "WHEEL_Y_NEGATIVE",
        LEFTSTICK_XNEG = "LEFT_STICK_X_NEGATIVE",
        LEFTSTICK_YPOS = "LEFT_STICK_Y_POSITIVE",
        LEFTSTICK_XPOS = "LEFT_STICK_X_POSITIVE",
        LEFTSTICK_YNEG = "LEFT_STICK_Y_NEGATIVE",
        LEFTRIGGER = "LEFT_TRIGGER",
        RIGHTTRIGGER = "RIGHT_TRIGGER",
        LEFTSTICK = "LEFT_STICK",
        RIGHTSTICK = "RIGHT_STICK",
        LEFTSHOULDER = "LEFT_SHOULDER",
        RIGHTSHOULDER = "RIGHT_SHOULDER",
        LEFTBRACKET = "LEFT_BRACKET",
        RIGHTBRACKET = "RIGHT_BRACKET",
        PAGEUP = "PAGE_UP",
        PAGEDOWN = "PAGE_DOWN",
        ITEM1 = "ITEM_1",
        ITEM2 = "ITEM_2",
        ITEM3 = "ITEM_3",
        ITEM4 = "ITEM_4",
        ITEM5 = "ITEM_5",
        ITEM6 = "ITEM_6",
        ITEM7 = "ITEM_7",
        ITEM8 = "ITEM_8",
        ITEM9 = "ITEM_9",
        ITEM10 = "ITEM_10",
        ITEM11 = "ITEM_11",
    },

    RAW_INPUT_EVENTS_ENUM = {}, ---@type table<integer, string> Automatically generated.
    RAW_INPUT_EVENTS = {
        ENTER = 0,
        ESCAPE = 1,
        BACKSPACE = 2,
        TAB = 3,
        CAPSLOCK = 4,
        SPACE = 5,
        PRINT_SCREEN = 6,
        SCROLL_LOCK = 7,
        PAUSE = 8,
        INSERT = 9,
        HOME = 10,
        PAGE_UP = 11,
        DELETE = 12,
        END = 13,
        PAGE_DOWN = 14,
        COMMA = 15,
        DASH = 16,
        DOT = 17,
        SLASH = 18,
        SEMICOLON = 19,
        LEFT_BRACKET = 21,
        BACKSLASH = 22,
        RIGHT_BRACKET = 23,
        TILDE = 24,
        APOSTROPHE = 25,
        NUM_0 = 26,
        NUM_1 = 27,
        NUM_2 = 28,
        NUM_3 = 29,
        NUM_4 = 30,
        NUM_5 = 31,
        NUM_6 = 32,
        NUM_7 = 33,
        NUM_8 = 34,
        NUM_9 = 35,
        A = 36,
        B = 37,
        C = 38,
        D = 39,
        E = 40,
        F = 41,
        G = 42,
        H = 43,
        I = 44,
        J = 45,
        K = 46,
        L = 47,
        M = 48,
        N = 49,
        O = 50,
        P = 51,
        Q = 52,
        R = 53,
        S = 54,
        T = 55,
        U = 56,
        V = 57,
        W = 58,
        X = 59,
        Y = 60,
        Z = 61,
        F1 = 62,
        F2 = 63,
        F3 = 64,
        F4 = 65,
        F5 = 66,
        F6 = 67,
        F7 = 68,
        F8 = 69,
        F9 = 70,
        F10 = 71,
        F11 = 72,
        F12 = 73,
        F13 = 74,
        F14 = 75,
        F15 = 76,
        F16 = 77,
        F17 = 78,
        F18 = 79,
        F19 = 80,
        F20 = 81,
        F21 = 82,
        F22 = 83,
        F23 = 84,
        F24 = 85,
        RIGHT = 86,
        LEFT = 87,
        DOWN = 88,
        UP = 89,
        NUM_LOCK = 90,

        KEYPAD_DIVIDE = 91,
        KEYPAD_MULTIPLY = 92,
        KEYPAD_MINUS = 93,
        KEYPAD_PLUS = 94,
        KEYPAD_ENTER = 95,
        KEYPAD_1 = 96,
        KEYPAD_2 = 97,
        KEYPAD_3 = 98,
        KEYPAD_4 = 99,
        KEYPAD_5 = 100,
        KEYPAD_6 = 101,
        KEYPAD_7 = 102,
        KEYPAD_8 = 103,
        KEYPAD_9 = 104,
        KEYPAD_0 = 105,
        KEYPAD_PERIOD = 106,

        LEFT_CTRL = 107,
        LEFT_SHIFT = 108,
        LEFT_ALT = 109,
        LEFT_GUI = 110,
        RIGHT_CTRL = 111,
        RIGHT_SHIFT = 112,
        RIGHT_ALT = 113,
        RIGHT_GUI = 114,
        MODE = 115,
        LEFT_2 = 116,
        MIDDLE = 117,
        RIGHT_2 = 118,
        X1 = 119,
        X2 = 120,
        MOTION = 121,
        MOTION_X_NEGATIVE = 122,
        MOTION_Y_POSITIVE = 123,
        MOTION_X_POSITIVE = 124,
        MOTION_Y_NEGATIVE = 125,
        WHEEL_X_POSITIVE = 126,
        WHEEL_X_NEGATIVE = 127,
        WHEEL_Y_POSITIVE = 128,
        WHEEL_Y_NEGATIVE = 129,
        LEFT_STICK_X_NEGATIVE = 130,
        LEFT_STICK_Y_POSITIVE = 131,
        LEFT_STICK_X_POSITIVE = 132,
        LEFT_STICK_Y_NEGATIVE = 133,
        RIGHT_STICK_X_NEGATIVE = 134,
        RIGHT_STICK_Y_POSITIVE = 135,
        RIGHT_STICK_X_POSITIVE = 136,
        RIGHT_STICK_Y_NEGATIVE = 137,
        LEFT_TRIGGER = 138,
        RIGHT_TRIGGER = 139,
        CONTROLLER_A = 140,
        CONTROLLER_B = 141,
        CONTROLLER_X = 142,
        CONTROLLER_Y = 143,
        BACK = 144,
        GUIDE = 145,
        START = 146,
        LEFT_STICK = 147,
        RIGHT_STICK = 148,
        LEFT_SHOULDER = 149,
        RIGHT_SHOULDER = 150,
        DPAD_UP = 151,
        DPAD_DOWN = 152,
        DPAD_LEFT = 153,
        DPAD_RIGHT = 154,
        TOUCH_TAP = 155,
        TOUCH_HOLD = 156,
        TOUCH_PINCH_IN = 157,
        TOUCH_PINCH_OUT = 158,
        TOUCH_ROTATE = 159,
        TOUCH_FLICK = 160,
        TOUCH_PRESS = 161,
        ITEM_1 = 162,
        ITEM_2 = 163,
        ITEM_3 = 164,
        ITEM_4 = 165,
        ITEM_5 = 166,
        ITEM_6 = 167,
        ITEM_7 = 168,
        ITEM_8 = 169,
        ITEM_9 = 170,
        ITEM_10 = 171,
        ITEM_11 = 172,
    },

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

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        MouseMoved = {}, ---@type SubscribableEvent<InputLib_Event_MouseMoved>
    }
}
Client.Input = Input
Epip.InitializeLibrary("Input", Input)
Input:Debug()

-- Generate enum table.
for name,index in pairs(Input.RAW_INPUT_EVENTS) do
    Input.RAW_INPUT_EVENTS_ENUM[index] = name
end

---@class InputMouseState
---@field Moving boolean
---@field MoveVector Vector2D

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired once per tick, since it relies on multiple raw input events firing.
---@class InputLib_Event_MouseMoved
---@field Vector Vector2D

---------------------------------------------
-- METHODS
---------------------------------------------

---@param name string
---@return integer?
function Input.GetRawInputEventID(name)
    local id

    name = name:upper()
    if Input.NORBYTE_ENUM_NAMES[name] then
        name = Input.NORBYTE_ENUM_NAMES[name]
    end

    id = Input.RAW_INPUT_EVENTS[name]

    return id
end

---Returns whether a raw input event ID is a mouse-related one, including movement and buttons.
---@param rawID string|integer
---@return boolean
function Input.IsMouseInput(rawID)
    if type(rawID) == "number" then
        rawID = Input.RAW_INPUT_EVENTS_ENUM[rawID]
    end

    return Input.MOUSE_RAW_INPUT_EVENTS[rawID] == true
end

---Returns true if the game is unpaused and there are no focused elements in Flash.
---@return boolean
function Input.IsAcceptingInput()
    return not GameState.IsPaused() and not Input.interfaceFocused
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