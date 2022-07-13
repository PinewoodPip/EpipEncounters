
local Input = {
    ID = "PIP_Input",
    PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/input.swf",
    INPUT_DEVICE = "KeyboardMouse",

    CAPTURED_EVENTS = {

    },
    KEY_CODES = {
        [17] = "Ctrl",
        [18] = "Alt",
        [9] = "Tab",
        [46] = "Del",
        [35] = "End",
        [33] = "PrevPg",
        [34] = "NextPg",
        [37] = "Left",
        [38] = "Down",
        [39] = "Right",
        [40] = "Up",
    },
    SPECIAL_KEYBINDS = {
        [243] = "EX1",
        [253] = "EX2",
    },
    focused = false,
    SpecialKeysPressed = {
        ALT = false,
        CTRL = false,
    },
    lastKeyboardCharacterTime = 0,
    REPEAT_RATE = 100,
    lastKeyboardCharacter = nil,
    ctrlTime = 0,
    altTime = 0,
    SPECIAL_KEY_TIME = 500, -- 500 ms
    Events = {
        ---@type InputUI_Event_EventCaptured
        EventCaptured = {},
        ---@type InputUI_Event_KeyPressed
        KeyPressed = {},
    },
}
if IS_IMPROVED_HOTBAR then
    Input.PATH = "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/input.swf"
end
Client.UI.Input = Input
Epip.InitializeUI(nil, "Input", Input)

local UI_EVENTS = Client.Input.FLASH_EVENTS

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class InputUI_Event_EventCaptured : Event
---@field RegisterListener fun(self, listener:fun(event:string))
---@field Fire fun(self, event:string)

---@class InputUI_Event_KeyPressed : Event
---@field RegisterListener fun(self, listener:fun(key:string))
---@field Fire fun(self, key:string)

---------------------------------------------
-- METHODS
---------------------------------------------

function Input.EventIsBeingCaptured(event)
    local captured = false
    local state = Input.CAPTURED_EVENTS[event]

    if state then
        for k,b in pairs(state) do
            if b then
                captured = true
                break
            end
        end
    end

    return captured
end

function Input.ToggleEventCapture(event, capture, requestID)
    if not requestID then Input:LogError("ToggleEventCapture(): A request ID must be passed.") end
    if not capture then capture = nil end

    if not Input.CAPTURED_EVENTS[event] then Input.CAPTURED_EVENTS[event] = {} end

    if Input.EventIsBeingCaptured(event) and not capture then
        Input:GetRoot().removeEvent(event)
        Input:DebugLog("Removing event: " .. event)
    elseif not Input.EventIsBeingCaptured(event) and capture then
        Input:GetRoot().captureEvent(event)
        Input:DebugLog("Capturing event: " .. event)
    end
    
    Input.CAPTURED_EVENTS[event][requestID] = capture
end

function Input.PressedCtrlRecently()
    return Ext.MonotonicTime() - Input.ctrlTime < Input.SPECIAL_KEY_TIME
end

function Input.PressedAltRecently()
    return Ext.MonotonicTime() - Input.altTime < Input.SPECIAL_KEY_TIME
end

---TODO rework
function Input.IsAltPressed()
    local pressed = false

    for i,flag in ipairs(Ext.UI.GetByPath("Public/Game/GUI/worldTooltip.swf").Flags) do
        if flag == "OF_Visible" then
            pressed = true
            break
        end
    end

    return pressed
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Input:RegisterCallListener("inputFocus", function(ev)
    Input.focused = true
end)

Input:RegisterCallListener("pipSpecialKeyUp", function(ev)
    local keycode = ev.Args[1]

    print(keycode, "up")
end)

Input:RegisterCallListener("pipInputCaptured", function(ev)
    local event = ev.Args[1]
    local id = Input:GetRoot().events[event]

    Input:DebugLog("Event captured: " .. id)

    Input.Events.EventCaptured:Fire(id)
end)

Input:RegisterCallListener("pipKeyboardTextFieldCharacterAdded", function(ev, key)
    local time = Ext.MonotonicTime()

    if key ~= Input.lastKeyboardCharacter or time - Input.lastKeyboardCharacterTime > Input.REPEAT_RATE then
        Input:DebugLog("Key pressed: " .. key)

        Input.lastKeyboardCharacter = key
        Input.lastKeyboardCharacterTime = time

        Input.Events.KeyPressed:Fire(string.lower(key))

        if Input.focused then
            Input.focused = false
            Input:GetRoot().loseFocus()
        end
    else
        Input.lastKeyboardCharacterTime = time
    end
end)

Ext.Events.InputEvent:Subscribe(function(ev)
    local specialBind = Input.SPECIAL_KEYBINDS[ev.Event.EventId]

    if specialBind then
        Input.Events.KeyPressed:Fire(specialBind)
    end
end)

Input:RegisterCallListener("pipBackspacePressed", function(ev)
    Input:DebugLog("Backspace pressed")

    Input.Events.KeyPressed:Fire("backspace")
end)

Input:RegisterCallListener("pipKeyDown", function(ev, keyCode, shiftKey, ctrlKey, altKey, commandKey)
    local keyName = Input.KEY_CODES[keyCode]

    Input:DebugLog("Special key pressed. Modifiers:", shiftKey, ctrlKey, altKey, commandKey)

    if ctrlKey then
        Input.SpecialKeysPressed.CTRL = ctrlKey
        Input.ctrlTime = Ext.MonotonicTime()
    end
    if altKey then
        Input.SpecialKeysPressed.ALT = altKey
        Input.altTime = Ext.MonotonicTime()
    end

    if not keyName then
        Input:LogWarning("Special keycode not named: " .. keyCode)
    else
        Input.Events.KeyPressed:Fire(keyName)
    end

    -- Stop capturing alt/ctrl after a short while
    -- Client.Timer.Start("PIP_CancelSpecialKey", 0.5, function()
    --     Input:GetRoot().loseFocus()
    -- end)
end)

-- Doesn't currently work in flash.
-- Input:RegisterCallListener("pipKeyUp", function(ev, keyCode)
--     local keyName = Input.KEY_CODES[keyCode]

--     print(keyCode)

--     if not keyName then
--         Input:LogWarning("Special keycode not named: " .. keyCode)
--     else
--         print("key released", keyName)
--     end

-- end)

-- Re-focus our dummy textfield after the player is done typing in any real one
Ext.Events.InputEvent:Subscribe(function (ev)
    -- if ev.Event.EventId == Client.Input.INPUT_EVENTS.CLICK then
        Input:GetRoot().focusTextField()
    -- end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.UI.Create(Input.ID, Input.PATH, 2000)
Input:GetUI():Show()
local root = Input:GetRoot()
root.focusTextField()
root.keyboard_txt.visible = false

function Input:__Setup()
    Input:Debug()

    Input:GetRoot().handleSpecialKeys = false
    
    -- Input:GetRoot().keyboard_txt.htmlText = "TESTING2!!!!"
    -- Input.ToggleEventCapture(UI_EVENTS.SELECT_SLOT_1, true, "Test")
    -- Input.ToggleEventCapture(UI_EVENTS.SELECT_SLOT_1, true, "Test")
    -- Input.ToggleEventCapture(UI_EVENTS.CANCEL, true, "Test")
    -- Input.ToggleEventCapture(UI_EVENTS.PING, true, "Test")
end