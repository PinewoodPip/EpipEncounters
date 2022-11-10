
---@class InputLib : Feature
local Input = {

    HeldKeys = {},
    pressedKeys = {}, ---@type table<InputRawType, true>
    mouseState = nil, ---@type InputMouseState
    blockedInputs = {}, ---@type table<InputRawType, true>

    ---@enum RawInputDevice
    RAW_INPUT_DEVICES = {
        KEY = "Key",
        MOUSE = "Mouse",
        TOUCH_BAR = "Touchbar",
        CONTROLLER = "C",
    },

    ---@type table<InputModifier, {Name:string, ShortName:string}>
    MODIFIER_NAMES = {
        Shift = {Name = "Shift", ShortName = "Shft"},
        Ctrl = {Name = "Ctrl", ShortName = "^"},
        Alt = {Name = "Alt", ShortName = "Alt"},
        Gui = {Name = "Windows", ShortName = "Win"},
    },

    MOTION_EVENTS = {
        motion = true,
        motion_xneg = true,
        motion_ypos = true,
        motion_xpos = true,
        motion_yneg = true,
    },

    MOTION_AXIS = {
        motion_xneg = "x",
        motion_xpos = "x",
        motion_ypos = "y",
        motion_yneg = "y",

        wheel_xpos = "x",
        wheel_xneg = "x",
        wheel_ypos = "y",
        wheel_yneg = "y",

        leftstick_xpos = "x",
        leftstick_xneg = "x",
        leftstick_ypos = "y",
        leftstick_yneg = "y",

        rightstick_xpos = "x",
        rightstick_xneg = "x",
        rightstick_ypos = "y",
        rightstick_yneg = "y",
    },

    MOUSE_RAW_INPUT_EVENTS = {
        motion = true,
        motion_xneg = true,
        motion_ypos = true,
        motion_xpos = true,
        motion_yneg = true,
        left2 = true,
        right2 = true,
        middle = true,
        wheel_xpos = true,
        wheel_xneg = true,
        wheel_ypos = true,
        wheel_yneg = true,
        x1 = true,
        x2 = true,
    },

    MOUSE_CLICK_EVENTS = {
        left2 = true,
        right2 = true,
        middle = true,
        x1 = true,
        x2 = true,
    },

    TOUCH_RAW_EVENTS = {
        touch_tap = true,
        touch_hold = true,
        touch_pinch_in = true,
        touch_pinch_out = true,
        touch_rotate = true,
        touch_flick = true,
        touch_press = true,
    },

    ---@type table<InputRawType, {Name:string, ShortName:string}>
    RAW_INPUT_NAMES = {
        ["printscreen"] = {Name = "Print Screen", ShortName = "PrtScrn"},
        ["num5"] = {Name = "Number 5", ShortName = "5"},
        ["f1"] = {Name = "Function Key 1", ShortName = "F1"},
        ["righttrigger"] = {Name = "Right Trigger", ShortName = "RT"},
        ["scrolllock"] = {Name = "Scroll Lock", ShortName = "ScrollLock"},
        ["g"] = {Name = "G", ShortName = "G"},
        ["f12"] = {Name = "Function Key 12", ShortName = "F12"},
        ["numlock"] = {Name = "Num Lock", ShortName = "NumLock"},
        ["lshift"] = {Name = "Left Shift", ShortName = "LShift"},
        ["controller_a"] = {Name = "A Button", ShortName = "[A]"},
        ["escape"] = {Name = "Escape", ShortName = "ESC"},
        ["delete_key"] = {Name = "Delete", ShortName = "Del"},
        ["equals"] = {Name = "Equals", ShortName = "="},
        ["r"] = {Name = "R", ShortName = "R"},
        ["f23"] = {Name = "Function Key 23", ShortName = "F23"},
        ["kp_8"] = {Name = "Numpad 8", ShortName = "KP8"},
        ["x1"] = {Name = "Mouse BackAD", ShortName = "M5"},
        ["controller_b"] = {Name = "B Button", ShortName = "[B]"},
        ["item9"] = {Name = "Item 9", ShortName = "I9"},
        ["pagedown"] = {Name = "Page Down", ShortName = "PgDown"},
        ["comma"] = {Name = "Comma", ShortName = ","},
        ["num7"] = {Name = "Number 7", ShortName = "7"},
        ["f3"] = {Name = "Function Key 3", ShortName = "F3"},
        ["controller_x"] = {Name = "X Button", ShortName = "[X]"},
        ["semicolon"] = {Name = "Semicolon", ShortName = ";"},
        ["i"] = {Name = "I", ShortName = "I"},
        ["f14"] = {Name = "Function Key 14", ShortName = "F14"},
        ["lgui"] = {Name = "Left GUI", ShortName = "LGUI"},
        ["controller_y"] = {Name = "Y Button", ShortName = "[Y]"},
        ["leftbracket"] = {Name = "Left Bracket", ShortName = "["},
        ["t"] = {Name = "T", ShortName = "T"},
        ["kp_0"] = {Name = "Numpad 0", ShortName = "KP0"},
        ["motion"] = {Name = "Mouse Motion", ShortName = "Mouse"},
        ["leftstick"] = {Name = "Left Stick", ShortName = "LStick"},
        ["item11"] = {Name = "Item 11", ShortName = "I11"},
        ["dot"] = {Name = "Dot", ShortName = "."},
        ["backslash"] = {Name = "Backslash", ShortName = "\\"},
        ["num9"] = {Name = "Number 9", ShortName = "9"},
        ["f5"] = {Name = "Function Key 5", ShortName = "F5"},
        ["rightstick"] = {Name = "Right Stick", ShortName = "RStick"},
        ["rightbracket"] = {Name = "Right Bracket", ShortName = "]"},
        ["k"] = {Name = "K", ShortName = "K"},
        ["f16"] = {Name = "Function Key 16", ShortName = "F16"},
        ["kp_1"] = {Name = "Numpad 1", ShortName = "KP1"},
        ["rshift"] = {Name = "Right Shift", ShortName = "RShift"},
        ["leftshoulder"] = {Name = "Left Button", ShortName = "LB"},
        ["apostrophe"] = {Name = "Apostrophe", ShortName = "'"},
        ["num0"] = {Name = "Number 0", ShortName = "0"},
        ["v"] = {Name = "V", ShortName = "V"},
        ["rightshoulder"] = {Name = "Right Button", ShortName = "RB"},
        ["b"] = {Name = "B", ShortName = "B"},
        ["f7"] = {Name = "Function Key 7", ShortName = "F7"},
        ["kp_divide"] = {Name = "Numpad Divide", ShortName = "KP/"},
        ["dpad_down"] = {Name = "Numpad Down", ShortName = "NPDown"},
        ["m"] = {Name = "M", ShortName = "M"},
        ["f18"] = {Name = "Function Key 18", ShortName = "F18"},
        ["left"] = {Name = "Left", ShortName = "<-"},
        ["kp_multiply"] = {Name = "Numpad Multiply", ShortName = "KP*"},
        ["kp_3"] = {Name = "Numpad 3", ShortName = "KP3"},
        ["rgui"] = {Name = "Right GUI", ShortName = "RGUI"},
        ["dpad_left"] = {Name = "Dpad Left", ShortName = "D<-"},
        ["item4"] = {Name = "Item 4", ShortName = "I4"},
        ["insert"] = {Name = "Insert", ShortName = "INS"},
        ["num2"] = {Name = "Number 2", ShortName = "2"},
        ["x"] = {Name = "X", ShortName = "X"},
        ["kp_minus"] = {Name = "Numpad Minus", ShortName = "KP-"},
        ["guide"] = {Name = "Guide", ShortName = "[*]"},
        ["dpad_right"] = {Name = "Dpad Right", ShortName = "D->"},
        ["tab"] = {Name = "Tab", ShortName = "TAB"},
        ["d"] = {Name = "D", ShortName = "D"},
        ["f9"] = {Name = "Function Key 9", ShortName = "F9"},
        ["kp_enter"] = {Name = "Enter", ShortName = "ENTER"},
        ["touch_tap"] = {Name = "Tap", ShortName = "[Tap]"},
        ["item2"] = {Name = "Item 2", ShortName = "I2"},
        ["o"] = {Name = "O", ShortName = "O"},
        ["f20"] = {Name = "Function Key 20", ShortName = "F20"},
        ["kp_5"] = {Name = "Numpad 5", ShortName = "KP5"},
        ["kp_period"] = {Name = "Numpad Period", ShortName = "KP."},
        ["left2"] = {Name = "Left Click", ShortName = "M1"},
        ["touch_hold"] = {Name = "Touch Hold", ShortName = "[Hold]"},
        ["item6"] = {Name = "Item 6", ShortName = "I6"},
        ["pageup"] = {Name = "Page Up", ShortName = "PgUp"},
        ["num4"] = {Name = "Number 4", ShortName = "4"},
        ["z"] = {Name = "Z", ShortName = "Z"},
        ["motion_xneg"] = {Name = "Mouse Movemement Left", ShortName = "Mouse Movement Left"},
        ["touch_pinch_in"] = {Name = "Pinch In", ShortName = "[PinchIn]"},
        ["f"] = {Name = "F", ShortName = "F"},
        ["f11"] = {Name = "F11", ShortName = "F11"},
        ["lctrl"] = {Name = "Left Ctrl", ShortName = "LCtrl"},
        ["motion_ypos"] = {Name = "", ShortName = "Mouse Movement Up"},
        ["touch_pinch_out"] = {Name = "Pinch Out", ShortName = "[PinchOut]"},
        ["enter"] = {Name = "Enter", ShortName = "Enter"},
        ["q"] = {Name = "Q", ShortName = "Q"},
        ["f22"] = {Name = "Function Key 22", ShortName = "F22"},
        ["kp_7"] = {Name = "Numpad 7", ShortName = "KP7"},
        ["right2"] = {Name = "Right Click", ShortName = "M2"},
        ["motion_xpos"] = {Name = "Mouse Movement Right", ShortName = "Mouse Movement Right"},
        ["touch_rotate"] = {Name = "Touch Rotate", ShortName = "[Rotate]"},
        ["item8"] = {Name = "Item 8", ShortName = "I8"},
        ["num6"] = {Name = "Number 6", ShortName = "6"},
        ["f2"] = {Name = "Function Key 2", ShortName = "F2"},
        ["up"] = {Name = "Up", ShortName = "Up"},
        ["motion_yneg"] = {Name = "Mouse Movement Down", ShortName = "Mouse Movement Down"},
        ["dpad_up"] = {Name = "Dpad Up", ShortName = "Dpad Up"},
        ["touch_flick"] = {Name = "Touch Flick", ShortName = "[Flick]"},
        ["h"] = {Name = "H", ShortName = "H"},
        ["f13"] = {Name = "Function Key 13", ShortName = "F13"},
        ["lalt"] = {Name = "Left Alt", ShortName = "LAlt"},
        ["wheel_xpos"] = {Name = "Scroll Wheel X+", ShortName = "Scroll X+"},
        ["touch_press"] = {Name = "Touch Press", ShortName = "[Press]"},
        ["s"] = {Name = "S", ShortName = "S"},
        ["f24"] = {Name = "Function Key 24", ShortName = "F24"},
        ["kp_9"] = {Name = "Numpad 9", ShortName = "KP9"},
        ["x2"] = {Name = "Mouse Forward", ShortName = "M4"},
        ["wheel_xneg"] = {Name = "Scroll Wheel X-", ShortName = "Scroll X-"},
        ["item10"] = {Name = "Item 10", ShortName = "I10"},
        ["dash"] = {Name = "Dash", ShortName = "-"},
        ["num8"] = {Name = "Number 8", ShortName = "8"},
        ["f4"] = {Name = "Function Key 4", ShortName = "F4"},
        ["wheel_ypos"] = {Name = "Scroll Wheel Up", ShortName = "Scroll Up"},
        ["j"] = {Name = "J", ShortName = "J"},
        ["f15"] = {Name = "Function Key 15", ShortName = "F15"},
        ["rctrl"] = {Name = "Right Ctrl", ShortName = "RCtrl"},
        ["wheel_yneg"] = {Name = "Scroll Wheel Down", ShortName = "Scroll Down"},
        ["space"] = {Name = "Space", ShortName = "[Space]"},
        ["u"] = {Name = "U", ShortName = "U"},
        ["down"] = {Name = "Down", ShortName = "Down"},
        ["leftstick_xneg"] = {Name = "Left Stick X-", ShortName = "LStick X-"},
        ["slash"] = {Name = "Slash", ShortName = "/"},
        ["a"] = {Name = "A", ShortName = "A"},
        ["f6"] = {Name = "Function Key 6", ShortName = "F6"},
        ["leftstick_ypos"] = {Name = "Left Stick Y+", ShortName = "LStick Y+"},
        ["end"] = {Name = "End", ShortName = "END"},
        ["l"] = {Name = "L", ShortName = "L"},
        ["f17"] = {Name = "Function Key 17", ShortName = "F17"},
        ["right"] = {Name = "Right", ShortName = "->"},
        ["kp_2"] = {Name = "Numpad 2", ShortName = "KP2"},
        ["ralt"] = {Name = "", ShortName = "RAlt"},
        ["leftstick_xpos"] = {Name = "Left Stick X+", ShortName = "LStick X+"},
        ["item3"] = {Name = "Item 3", ShortName = "I3"},
        ["pause"] = {Name = "Pause", ShortName = "Pause"},
        ["num1"] = {Name = "Number 1", ShortName = "1"},
        ["w"] = {Name = "W", ShortName = "W"},
        ["leftstick_yneg"] = {Name = "Left Stick Y-", ShortName = "LStick Y-"},
        ["back"] = {Name = "Back", ShortName = "Back"},
        ["c"] = {Name = "C", ShortName = "C"},
        ["f8"] = {Name = "Function Key 8", ShortName = "F8"},
        ["rightstick_xneg"] = {Name = "Right Stick X-", ShortName = "RStick X-"},
        ["item1"] = {Name = "Item 1", ShortName = "I1"},
        ["n"] = {Name = "N", ShortName = "N"},
        ["f19"] = {Name = "Function Key 19", ShortName = "F19"},
        ["kp_4"] = {Name = "Numpad 4", ShortName = "KP4"},
        ["mode"] = {Name = "Mode", ShortName = "Mode"},
        ["rightstick_ypos"] = {Name = "Right Stick Y+", ShortName = "RStick Y+"},
        ["item5"] = {Name = "Item 5", ShortName = "I5"},
        ["home"] = {Name = "Home", ShortName = "Home"},
        ["num3"] = {Name = "Number 3", ShortName = "3"},
        ["y"] = {Name = "Y", ShortName = "Y"},
        ["kp_plus"] = {Name = "Numpad Plus", ShortName = "KP+"},
        ["rightstick_xpos"] = {Name = "Right Stick X+", ShortName = "RStick X+"},
        ["start"] = {Name = "Start", ShortName = "Start"},
        ["backspace"] = {Name = "Backspace", ShortName = "Backspace"},
        ["tilde"] = {Name = "Tilde", ShortName = "`"},
        ["e"] = {Name = "E", ShortName = "E"},
        ["f10"] = {Name = "Function Key 10", ShortName = "F10"},
        ["rightstick_yneg"] = {Name = "Right Stick Y-", ShortName = "RStick Y-"},
        ["capslock"] = {Name = "Caps Lock", ShortName = "CapsLock"},
        ["p"] = {Name = "P", ShortName = "P"},
        ["f21"] = {Name = "Function Key 21", ShortName = "F21"},
        ["kp_6"] = {Name = "Numpad 6", ShortName = "KP6"},
        ["middle"] = {Name = "Middle Click", ShortName = "M3"},
        ["lefttrigger"] = {Name = "Left Trigger", ShortName = "LT"},
        ["item7"] = {Name = "Item 7", ShortName = "I7"},
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

    
    INPUT_EVENTS = {}, ---@type table<integer, InputLib_InputEventDefinition> Automatically generated. See Setup region.
    INPUT_EVENT_STRING_ID_MAP = {}, ---@type table<InputLib_InputEventStringID, integer> Automatically generated. See Setup region.

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
        MouseMoved = {}, ---@type Event<InputLib_Event_MouseMoved>
        KeyStateChanged = {Preventable = true}, ---@type PreventableEvent<InputLib_Event_KeyStateChanged>
        KeyPressed = {}, ---@type Event<InputLib_Event_KeyPressed>
        KeyReleased = {}, ---@type Event<InputLib_Event_KeyReleased>
        MouseButtonPressed = {}, ---@type Event<InputLib_Event_MouseButtonPressed>
    }
}
Epip.InitializeLibrary("Input", Input)
Client.Input = Input
-- Input:Debug()

-- Generate enum table.
for name,index in pairs(Input.RAW_INPUT_EVENTS) do
    Input.RAW_INPUT_EVENTS_ENUM[index] = name
end

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias InputLib_InputEventStringID "FlashLeftMouse"|"FlashRightMouse"|"FlashMiddleMouse"|"Action1"|"ControllerUnlinkedBack"|"ControllerUnlinkedStart"|"ControllerUnlinkedA"|"ControllerUnlinkedB"|"ControllerUnlinkedX"|"ControllerUnlinkedY"|"KeyboardAny"|"ToggleFullscreen"|"ReloadInputConfig"|"Screenshot"|"Benchmark"|"CloseApplication"|"DefaultCameraPanCamera"|"DefaultCameraSpecialPanCamera1"|"DefaultCameraSpecialPanCamera2"|"DefaultCameraToggleMouseRotation"|"DefaultCameraCaptureInput"|"DefaultCameraLeft"|"DefaultCameraRight"|"DefaultCameraForward"|"DefaultCameraBackward"|"DefaultCameraZoomIn"|"DefaultCameraZoomOut"|"DefaultCameraRotateLeft"|"DefaultCameraRotateRight"|"DefaultCameraRotateUp"|"DefaultCameraRotateDown"|"DefaultCameraMouseLeft"|"DefaultCameraMouseRight"|"DefaultCameraMouseUp"|"DefaultCameraMouseDown"|"DefaultCameraTopView"|"DefaultCameraLeftView"|"DefaultCameraFrontView"|"DefaultCameraSlow"|"DefaultCameraFast"|"WidgetToggleOutput"|"WidgetToggleEffectStats"|"WidgetScreenshot"|"WidgetScreenshotVideo"|"WidgetToggleOptions"|"WidgetToggleHierarchicalProfiler"|"WidgetToggleStats"|"WidgetToggleDebugConsole"|"WidgetToggleGraphicsDebug"|"WidgetToggleDevComments"|"WidgetButtonTab"|"WidgetButtonLeft"|"WidgetButtonRight"|"WidgetButtonUp"|"WidgetButtonDown"|"WidgetButtonHome"|"WidgetButtonEnd"|"WidgetButtonDelete"|"WidgetButtonBackSpace"|"WidgetButtonEnter"|"WidgetButtonEscape"|"WidgetButtonPageUp"|"WidgetButtonPageDown"|"WidgetButtonSpace"|"WidgetButtonA"|"WidgetButtonC"|"WidgetButtonV"|"WidgetButtonX"|"WidgetButtonY"|"WidgetButtonZ"|"WidgetScrollUp"|"WidgetScrollDown"|"WidgetMouseMotion"|"WidgetMouseLeft"|"WidgetMouseRight"|"FlashPerfmonUp"|"FlashPerfmonDown"|"FlashPerfmonLeft"|"FlashPerfmonRight"|"FlashPerfmonLShoulder"|"FlashPerfmonRShoulder"|"FlashPerfmonRTrigger"|"FlashPerfmonLTrigger"|"FlashPerfmonButton1"|"FlashPerfmonButton2"|"FlashPerfmonButton3"|"FlashPerfmonButton4"|"FlashMouseMove"|"FlashArrowUp"|"FlashArrowLeft"|"FlashArrowRight"|"FlashArrowDown"|"FlashEnter"|"FlashPgUp"|"FlashPgDn"|"FlashBackspace"|"FlashTab"|"FlashDelete"|"FlashHome"|"FlashEnd"|"FlashCtrl"|"FlashAlt"|"FlashScrollUp"|"FlashScrollDown"|"FlashCancel"|"FlashMouseMoveLeft"|"FlashMouseMoveRight"|"FlashMouseMoveUp"|"FlashMouseMoveDown"|"ActionMenu"|"CameraCenter"|"CameraToggleMouseRotate"|"CameraBackward"|"CameraForward"|"CameraLeft"|"CameraRight"|"CameraZoomIn"|"CameraZoomOut"|"CameraRotateLeft"|"CameraRotateRight"|"CameraRotateMouseLeft"|"CameraRotateMouseRight"|"FreeCameraToggleMouseRotate"|"FreeCameraMoveForward"|"FreeCameraMoveBackward"|"FreeCameraMoveLeft"|"FreeCameraMoveRight"|"FreeCameraFoVInc"|"FreeCameraFoVDec"|"FreeCameraSpeedInc"|"FreeCameraSpeedDec"|"FreeCameraSpeedReset"|"FreeCameraRotSpeedInc"|"FreeCameraRotSpeedDec"|"FreeCameraRotateControllerLeft"|"FreeCameraRotateControllerRight"|"FreeCameraRotateControllerUp"|"FreeCameraRotateControllerDown"|"FreeCameraRotateMouseLeft"|"FreeCameraRotateMouseRight"|"FreeCameraRotateMouseUp"|"FreeCameraRotateMouseDown"|"FreeCameraHeightInc"|"FreeCameraHeightDec"|"FreeCameraSlowdown"|"FreeCameraFreezeGameTime"|"CharacterCreationRotateLeft"|"CharacterCreationRotateRight"|"CharacterCreationAccept"|"CharacterMoveForward"|"CharacterMoveBackward"|"CharacterMoveLeft"|"CharacterMoveRight"|"ClearSurface"|"CreateWaterSurface"|"CreateFrozenWaterSurface"|"CreateBloodSurface"|"CreatePoisonSurface"|"CreateOilSurface"|"CreateFireSurface"|"CreateSourceSurface"|"CreateLavaSurface"|"CreateWaterCloud"|"CreateBloodCloud"|"CreatePoisonCloud"|"CreateSmokeCloud"|"CreateFireCloud"|"BlessSurface"|"CurseSurface"|"ElectrifySurface"|"FreezeSurface"|"MeltSurface"|"CondenseSurface"|"VaporizeSurface"|"IncreaseSurfaceBrush"|"DecreaseSurfaceBrush"|"DebugViewHide"|"DebugViewScrollUp"|"DebugViewScrollDown"|"DebugAIGridTakeStep"|"DebugToggleCharacter"|"DebugLevelUp"|"DebugTogglePartyEdit"|"DebugKillCombat"|"ToggleFlyCam"|"DebugSelectCharacter"|"DebugDeselectCharacter"|"DebugToggleUseWorkerThreads"|"DebugToggleThreadedServer"|"SwitchDebugParty"|"ShowSoundDebugWindow"|"ForceKillApp"|"TelemetryStart"|"TelemetryStop"|"ForceEndDialog"|"JoinLocalLobby"|"ForceKillObject"|"ForceRemoveObject"|"ForceKillParty"|"GiveSomeGold"|"Revive"|"ShowWayPointMenu"|"EnableController"|"IggyExplorerNext"|"IggyExplorerPrev"|"ForceEndTurn"|"ToggleAiGrid"|"TogglePhysics"|"ToggleAIBounds"|"ToggleDecalBounds"|"ToggleBlindToCriminals"|"ForceAnimation"|"DragSingleToggle"|"TogglePresentation"|"PartyManagement"|"MoveCharacterUpInGroup"|"PanelSelect"|"CycleCharactersNext"|"CycleCharactersPrev"|"DestructionToggle"|"HighlightCharacters"|"Interact"|"ActionCancel"|"NextObject"|"Pause"|"PrevObject"|"QueueCommand"|"QuickLoad"|"QuickSave"|"ShowChat"|"SkipVideo"|"SplitItemToggle"|"RotateItemLeft"|"RotateItemRight"|"TeleportPlayer"|"TeleportParty"|"ToggleCombatMode"|"ToggleSplitscreen"|"ToggleEquipment"|"ToggleHomestead"|"ToggleInGameMenu"|"ToggleInfo"|"ToggleInputMode"|"CancelSelectorMode"|"ToggleCharacterPane"|"ToggleInventory"|"ToggleCraft"|"ToggleRecipes"|"ToggleJournal"|"ToggleMap"|"ToggleSkills"|"ToggleSneak"|"ToggleStats"|"AreaPickup"|"ToggleMonsterSelect"|"ToggleSetStartPoint"|"ToggleSurfacePainter"|"ToggleOverviewMap"|"ToggleVignette"|"ToggleGMPause"|"ToggleGMShroud"|"ToggleRollPanel"|"ToggleGMInventory"|"ToggleManageTarget"|"ToggleGMMiniMap"|"GMKillResurrect"|"GMSetHealth"|"SwitchGMMode"|"GMNormalAlignMode"|"ToggleGMRewardPanel"|"ToggleGMItemGeneratorPane"|"ToggleGMMoodPanel"|"ToggleStatusPanel"|"ToggleReputationPanel"|"TogglePartyManagement"|"ContextMenu"|"ControllerContextMenu"|"Combine"|"ToggleTacticalCamera"|"ShowWorldTooltips"|"SelectorMoveBackward"|"SelectorMoveForward"|"SelectorMoveLeft"|"SelectorMoveRight"|"ShowSneakCones"|"UIDelete"|"UIAccept"|"UIBack"|"UICancel"|"UITakeAll"|"UIEndTurn"|"UIHotBarNext"|"UIHotBarPrev"|"UIRadialLeft"|"UIRadialRight"|"UIRadialUp"|"UIRadialDown"|"UILeft"|"UIRight"|"UIUp"|"UIDown"|"UIContextMenuModifier"|"UISelectChar1"|"UISelectChar2"|"UISelectChar3"|"UISelectChar4"|"UISelectSlot0"|"UISelectSlot1"|"UISelectSlot2"|"UISelectSlot3"|"UISelectSlot4"|"UISelectSlot5"|"UISelectSlot6"|"UISelectSlot7"|"UISelectSlot8"|"UISelectSlot9"|"UISelectSlot11"|"UISelectSlot12"|"UIToggleEquipment"|"CCZoomIn"|"CCZoomOut"|"UIRefresh"|"UITabPrev"|"UITabNext"|"UIShowTooltip"|"UICompareItems"|"UITooltipUp"|"UITooltipDown"|"UIDialogTextUp"|"UIDialogTextDown"|"UIRequestTrade"|"UIAddPoints"|"UIRemovePoints"|"UIDialogRPSRock"|"UIDialogRPSPaper"|"UIDialogRPSScissors"|"UICreateProfile"|"UIDeleteProfile"|"UISetSlot"|"UICreationPrev"|"UICreationNext"|"UICreationEditClassPrev"|"UICreationEditClassNext"|"UICreationTabPrev"|"UICreationTabNext"|"UIStartGame"|"UIEditCharacter"|"UIPortraitPrev"|"UIPortraitNext"|"UIShowInfo"|"UIRename"|"UIFilter"|"UIMapDown"|"UIMapUp"|"UIMapLeft"|"UIMapRight"|"UIMapZoomIn"|"UIMapZoomOut"|"UIMapReset"|"UIMapRemoveMarker"|"UITradeSwitchWindow"|"UITradeRemoveOffer"|"UITradeBalance"|"UIRemoveItemSelection"|"UIMessageBoxA"|"UIMessageBoxB"|"UIMessageBoxX"|"UIMessageBoxY"|"UIInvite"|"UIToggleTutorials"|"UICreationAddSkill"|"UICreationRemoveSkill"|"UIModPrev"|"UIModNext"|"UIAddonUp"|"UIAddonDown"|"Ping"|"UICopy"|"UICut"|"UIPaste"|"UIMarkWares"|"UIToggleMultiselection"|"UIToggleActions"|"UIToggleHelmet"|"CopyVersionToClipboard"|"UISend"|"ConnectivityMenu"|"UISwitchLeft"|"UISwitchRight"|"UISwitchUp"|"UISwitchDown"|"Unknown"

---@class InputMouseState
---@field Moving boolean
---@field MoveVector Vector2D Pixels moved.

---@class InputLib_InputEventDefinition
---@field NameHandle TranslatedStringHandle
---@field ReferenceName string
---@field EventID integer
---@field StringID string
---@field CategoryName string
local _InputEventDefinition = {}

function _InputEventDefinition:GetName()
    return Ext.L10N.GetTranslatedString(self.NameHandle, self.ReferenceName)
end

---@class InputLib_InputEventDefinition
---@field EventName string
---@field CategoryName string
---@field ReferenceString string
---@field NumID integer

---@class InputLib_Binding
local _Binding = {}

---@param useShortNames boolean? Defaults to false.
---@return string
function _Binding:Stringify(useShortNames)
    return ""
end

function _Binding.__tostring(self)
    return self:Stringify()
end

---@class InputLib_InputEventBinding : InputLib_Binding
---@field DeviceType RawInputDevice
---@field InputID InputRawType
---@field Shift boolean
---@field Ctrl boolean
---@field Alt boolean
---@field GUI boolean
local _GameBinding = {}
Inherit(_GameBinding, _Binding)

---@param data InputLib_InputEventBinding
---@return InputLib_InputEventBinding
function _GameBinding.Create(data)
    Inherit(data, _GameBinding)

    return data
end

---@param useShortNames boolean? Defaults to false.
---@return string
function _GameBinding:Stringify(useShortNames)
    local modifierNames = {}
    local modifierProperties = {
        {TableKey = "Shift", Modifier = "Shift"},
        {TableKey = "Alt", Modifier = "Alt"},
        {TableKey = "Ctrl", Modifier = "Ctrl"},
        {TableKey = "GUI", Modifier = "Gui"},
    }

    for _,mod in ipairs(modifierProperties) do
        if self[mod.TableKey] then
            local modifierName = Input.MODIFIER_NAMES[mod.Modifier]

            table.insert(modifierNames, useShortNames and modifierName.ShortName or modifierName.Name)
        end
    end

    table.insert(modifierNames, Input.GetInputName(self.InputID, useShortNames))

    return string.concat(modifierNames, useShortNames and "+" or " + ")
end

function _GameBinding.__tostring(self)
    return self:Stringify()
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired once per tick, since it relies on multiple raw input events firing.
---@class InputLib_Event_MouseMoved
---@field Vector Vector2D Pixels moved.

---@class InputLib_Event_KeyStateChanged : PreventableEventParams
---@field InputID InputRawType
---@field State InputState

---@class InputLib_Event_KeyPressed
---@field InputID InputRawType

---@class InputLib_Event_KeyReleased
---@field InputID InputRawType

---@class InputLib_Event_MouseButtonPressed
---@field Position Vector2D
---@field InputID InputRawType

---------------------------------------------
-- METHODS
---------------------------------------------

---@return InputManager
function Input.GetManager()
    return Ext.Input.GetInputManager()
end

---@param eventID string
---@return integer
function Input.GetGameEventNumID(eventID)
    local manager = Input.GetManager()
    local numID

    for i,def in pairs(manager.InputDefinitions) do -- TODO cache these
        if def.EventName == eventID then
            numID = i
            break
        end
    end

    return numID
end

---@param id string|integer
---@return InputLib_InputEventDefinition
function Input.GetGameEvent(id)
    local manager = Input.GetManager()
    if type(id) == "string" then id = Input.GetGameEventNumID(id) end
    local data = manager.InputDefinitions[id]

    ---@type InputLib_InputEventDefinition
    local event = {
        EventName = data.EventName,
        CategoryName = data.CategoryName,
        ReferenceString = data.EventDesc.Handle.ReferenceString,
        NumID = id,
    }

    return event
end

---@param eventID string|integer
---@param deviceType RawInputDevice? Defaults to "Key"
---@param bindingIndex (1|2)? Defaults to 1.
---@param playerIndex integer? Defaults to 1 (player index 0 in engine).
---@return InputLib_Binding?
function Input.GetBinding(eventID, deviceType, bindingIndex, playerIndex)
    if type(eventID) == "string" then eventID = Input.GetGameEventNumID(eventID) end
    local manager = Input.GetManager()
    local scheme = manager.InputScheme
    playerIndex = playerIndex or 1
    bindingIndex = bindingIndex or 1
    deviceType = deviceType or "Key"

    local obj
    local binding
    local bindings = scheme.PerPlayerBindings[playerIndex][eventID]

    local validBindings = {}
    for _,b in ipairs(bindings) do
        if b.DeviceId == deviceType then
            table.insert(validBindings, b)
        end
    end
    binding = #validBindings > 0 and validBindings[bindingIndex]

    if binding then
        ---@type InputLib_InputEventBinding
        obj = _GameBinding.Create({
            Alt = binding.Alt,
            Shift = binding.Shift,
            Ctrl = binding.Ctrl,
            GUI = binding.Gui,
            InputID = binding.InputId,
            DeviceType = binding.DeviceId,
        })
    end

    return obj
end

---Returns the name for a raw input ID.
---@param rawID InputRawType
---@param short boolean?
---@return string
function Input.GetInputName(rawID, short)
    local data = Input.RAW_INPUT_NAMES[rawID]
    local name = data.Name
    if short then name = data.ShortName end

    return name
end

---@param id integer|InputLib_InputEventStringID
---@return InputLib_InputEventDefinition
function Input.GetInputEventDefinition(id)
    if type(id) == "string" then
        id = Input.INPUT_EVENT_STRING_ID_MAP[id] 
    end

    return Input.INPUT_EVENTS[id]
end

---@param deviceID RawInputDevice
---@param rawID InputRawType
---@param state InputState
---@param value1 number? Defaults to 0 for released, 1 for pressed.
---@param value2 number? Defaults to 0 for released, 1 for pressed.
---@param immediate boolean? Defaults to true. If false, the input will be processed on the next frame.
function Input.Inject(deviceID, rawID, state, value1, value2, immediate)
    local defaultValues = {Pressed = 1, Released = 0}
    if immediate == nil then immediate = true end
    
    if value1 == nil then
        value1 = defaultValues[state]
    end
    if value2 == nil then
        value2 = defaultValues[state]
    end

    Ext.Input.InjectInput(deviceID, rawID, state, value1, value2, immediate)
end

---@param rawID InputRawType
---@param requestID string
---@param blocked boolean
function Input.SetInputBlocked(rawID, requestID, blocked)
    if not Input.blockedInputs[rawID] then
        Input.blockedInputs[rawID] = {}
    end

    Input.blockedInputs[rawID][requestID] = blocked or nil
end

---@param rawID InputRawType
---@return boolean
function Input.IsInputBlocked(rawID)
    local blocked = false

    for _,bool in pairs(Input.blockedInputs[rawID] or {}) do
        if bool then blocked = true break end
    end

    return blocked
end

---Get the numeric ID of a raw input event.
---@param name InputRawType
---@return integer?
function Input.GetRawInputNumericID(name)
    local id

    name = name:upper()
    if Input.NORBYTE_ENUM_NAMES[name] then
        name = Input.NORBYTE_ENUM_NAMES[name]
    end

    id = Input.RAW_INPUT_EVENTS[name]

    return id
end

---Returns a list of pressed *keyboard* keys.
---@return InputRawType[]
function Input.GetPressedKeys()
    local keys = {}

    for key,_ in pairs(Input.pressedKeys) do
        if not Input.IsMouseInput(key) and not Input.IsTouchInput(key) then
            table.insert(keys, key)
        end
    end

    return keys
end

---Returns whether a raw input event ID is a mouse-related one, including movement and buttons.
---@param rawID InputRawType
---@return boolean
function Input.IsMouseInput(rawID)
    return Input.MOUSE_RAW_INPUT_EVENTS[rawID] == true
end

---Returns whether a raw input event ID is a touch-related one.
---@param rawID InputRawType
---@return boolean
function Input.IsTouchInput(rawID)
    return Input.TOUCH_RAW_EVENTS[rawID] == true
end

---Returns true if the game is unpaused and there are no focused elements in Flash.
---@return boolean
function Input.IsAcceptingInput()
    return not GameState.IsPaused() and not Input.interfaceFocused
end

---Returns whether a key is pressed.
---@param rawID InputRawType
---@return boolean
function Input.IsKeyPressed(rawID)
    return Input.pressedKeys[rawID] == true
end

---Returns whether either of the 2 shift keys is being pressed.
---@return boolean
function Input.IsShiftPressed()
    return Input.IsKeyPressed("lshift") or Input.IsKeyPressed("rshift")
end

---Returns whether either of the 2 ctrl keys is being pressed.
---@return boolean
function Input.IsCtrlPressed()
    return Input.IsKeyPressed("lctrl") or Input.IsKeyPressed("rctrl")
end

---Returns whether either of the 2 alt keys is being pressed.
---@return boolean
function Input.IsAltPressed()
    return Input.IsKeyPressed("lalt") or Input.IsKeyPressed("ralt")
end

---Returns whether either of the 2 GUI keys is being pressed.
---@return boolean
function Input.IsGUIPressed()
    return Input.IsKeyPressed("lgui") or Input.IsKeyPressed("rgui")
end

---Returns true if any modifier key is being pressed.
---@return boolean
function Input.AreModifierKeysPressed()
    return Input.IsShiftPressed() or Input.IsCtrlPressed() or Input.IsAltPressed() or Input.IsGUIPressed()
end

---------------------------------------------
-- INTERNAL METHODS
---------------------------------------------

---Sets whether a UI is focused (capturing input)
---@param focused boolean
function Input._SetFocused(focused)
    Input.interfaceFocused = focused

    Input:FireEvent("FocusChanged", focused)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.RawInput:Subscribe(function(e)
    local inputEventData = e.Input
    local id = tostring(inputEventData.Input.InputId)
    local deviceType = tostring(inputEventData.Input.DeviceId)
    if not id then return nil end -- Happens for unsupported keys, ex. < or >

    -- Update pressed state tracking
    if inputEventData.Value.State == "Pressed" then
        Input.pressedKeys[id] = true
    else
        Input.pressedKeys[id] = nil
    end

    if not Input.MOTION_EVENTS[id] then
        Input:Dump(e)
    end

    -- Track mouse movement
    if deviceType == Input.RAW_INPUT_DEVICES.MOUSE then
        local axis = Input.MOTION_AXIS[id]
        if not Input.mouseState then
            Input.mouseState = {
                MoveVector = {x = 0, y = 0},
                Moving = false,
            }
        end
        local state = Input.mouseState

        if axis then
            local value = inputEventData.Value.Value2

            if value ~= 0 then
                state.Moving = true
                
                state.MoveVector[axis] = state.MoveVector[axis] + value
            end
        end
    end

    local state = inputEventData.Value.State

    -- Mouse pressed event
    if Input.MOUSE_CLICK_EVENTS[id] and state == "Pressed" then
        local x, y = Client.GetMousePosition()

        -- This does not fire in Main Menu. TODO?
        if x and y then
            Input.Events.MouseButtonPressed:Throw({
                Position = {x = x, y = y},
                InputID = id,
            })
        end 
    end

    local event = {InputID = id, State = state,} ---@type InputLib_Event_KeyStateChanged

    Input.Events.KeyStateChanged:Throw(event)

    if state == "Released" then
        Input.Events.KeyReleased:Throw({
            InputID = id,
        })
    else
        Input.Events.KeyPressed:Throw({
            InputID = id,
        })
    end

    if event.Prevented then
        inputEventData.Input.InputId = "item7" -- Let's hope no one manages to bind this particular one...
    end
end)

-- Fire MouseMoved events
Ext.Events.Tick:Subscribe(function (e)
    if Input.mouseState and Input.mouseState.Moving then
        Input.Events.MouseMoved:Throw({
            Vector = Input.mouseState.MoveVector,
        })

        Input.mouseState = nil
    end
end)

-- Block inputs based on requests to SetInputBlocked()
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if Input.IsInputBlocked(ev.InputID) then
        ev:Prevent()
    end
end, {Priority = -9999})

-- Track focus gain/loss in UI
Ext.RegisterUINameCall("inputFocus", function(_) 
    Input._SetFocused(true)
end)
Ext.RegisterUINameCall("inputFocusLost", function(_) 
    Input._SetFocused(false)
end)

-- Listen for input events.
Ext.Events.InputEvent:Subscribe(function(event)
    event = event.Event

    Input.HeldKeys[event.EventId] = event.Press

    -- Fire event for sneak cones. TODO generic ones too!
    if event.EventId == 285 then
        Input:FireEvent("SneakConesToggled", event.Press)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Generate InputEvent integer -> string map
local InputManager = Ext.Input.GetInputManager() ---@type InputManager
for eventID,data in pairs(InputManager.InputDefinitions) do
    ---@type InputLib_InputEventDefinition
    local entry = {
        NameHandle = data.EventDesc.Handle.Handle,
        ReferenceName = data.EventDesc.Handle.ReferenceString,
        EventID = eventID,
        StringID = data.EventName,
        CategoryName = data.CategoryName,
    }
    Inherit(entry, _InputEventDefinition)

    Input.INPUT_EVENTS[eventID] = entry
    Input.INPUT_EVENT_STRING_ID_MAP[entry.StringID] = eventID
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Input.Events.MouseMoved:Subscribe(function (e)
--     _D(e)
-- end)

-- Input.Events.KeyStateChanged:Subscribe(function (e)
--     _D(e)
-- end)

-- Input.Events.MouseButtonPressed:Subscribe(function (e)
--     _D(e)
-- end)