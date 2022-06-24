
OptionsMenu = {
    ui = nil,
    root = nil,
    readingKeys = false,
    initialized = false,
    currentTab = 0,
    changedKeys = {},
    Controls = {

    },
    modSettings = {},
    pendingModSettingsOverrides = {},
    settingsHandlers = {},

    SETTINGS_ELEMENTS = {
        {
            id = 0.0,
            name = "Checkbox",
            paramsCount = 6,
            -- paramNames = ["number"]
        },
        {
            id = 1.0,
            name = "Dropdown",
            paramsCount = 3,
        },
        {
            id = 2.0,
            name = "Dropdown Entry",
            paramsCount = 2,
        },
        {
            id = 3.0,
            name = "Select Dropdown Entry",
            paramsCount = 2,
        },
        {
            id = 4.0,
            name = "Slider",
            paramsCount = 8,
        },
        {
            id = 5.0,
            name = "Button",
            paramsCount = 5,
        },
        {
            id = 6.0,
            name = "Section Header",
            paramsCount = 1,
        },
        {
            id = 7.0,
            name = "Tab Header",
            paramsCount = 1,
        },
        {
            id = 8.0,
            name = "Set Menu Dropdown Enabled",
            paramsCount = 2,
        },
        {
            id = 9.0,
            name = "Set Menu Checkbox",
            paramsCount = 3,
        },
    },

    -- Hardcoded input events, not bindable.
    HARDCODED_ACTION_TO_NAME = {
        [225] = "Escape",
    },
    
    SHORT_NAMES = {
        Escape = "Esc",
        ["Mouse X1"] = "M4",
        ["Mouse X2"] = "M5",
        Backslash = "\\",
        Quote = "'",
        ["Middle Mouse Button"] = "M3",
        ["Left Mouse Button"] = "M1",
        ["Right Mouse Button"] = "M2",
        ["Right Bracket"] = "]",
        ["Left Bracket"] = "[",
        Minus = "-",
        Equals = "=",
        Plus = "+",
        ["Left Shift"] = "LShift",
        ["Right Shift"] = "RShift",
        ["Numpad 0"] = "N0",
        ["Numpad 1"] = "N1",
        ["Numpad 2"] = "N2",
        ["Numpad 3"] = "N3",
        ["Numpad 4"] = "N4",
        ["Numpad 5"] = "N5",
        ["Numpad 6"] = "N6",
        ["Numpad 7"] = "N7",
        ["Numpad 8"] = "N8",
        ["Numpad 9"] = "N9",
        ["Numpad Multiply"] = "N*",
        ["Numpad Divide"] = "N/",
        ["Numpad Plus"] = "N+",
        ["Numpad Minus"] = "N-",
        ["Num Lock"] = "NL",
        ["Numpad Period"] = "N.",
        ["Numpad Enter"] = "NE",
    }
}

function OptionsMenu.GetKey(optionsMenu, event, useShortNames)
    if not optionsMenu.initialized then return nil end

    local name = nil

    if optionsMenu.HARDCODED_ACTION_TO_NAME[event] then -- hardcoded actions, not bindable.
        name = optionsMenu.HARDCODED_ACTION_TO_NAME[event]
    else -- bindable actions, parsed from the menu
        local data = optionsMenu.Controls[event]
        if not data then return nil end

        name = data.keys[1] or data.keys[2]
    end

    if useShortNames then
        -- show key combos as ?
        if name:match("+") then
            name = "?"
        end

        name = optionsMenu.SHORT_NAMES[name] or name
    end
    return name
end

function OptionsMenu.OpenInputMenu()
    local ui = Ext.UI.GetByPath("Public/Game/GUI/gameMenu.swf")

    ui:ExternalInterfaceCall("buttonPressed", 10.0) -- open the settings menu (we cannot get it directly because it does not exist while you're not in it)

    local settings = Ext.UI.GetByPath("Public/Game/GUI/optionsSettings.swf")
    settings:ExternalInterfaceCall("switchMenu", 4.0) -- switch to the controls tab (which is actually an entirely different UI)
end

function OptionsMenu.CloseInputMenu(ui)
    ui:GetRoot().requestClose()
    Ext.UI.GetByPath("Public/Game/GUI/gameMenu.swf"):GetRoot().closeMenu()
end

function OptionsMenu.ReadKeys(optionsMenu)
    OptionsMenu.readingKeys = true
    OptionsMenu.OpenInputMenu()
end

function OnInputAddEntry(ui, method, num1, num2, str1, str2, str3)
    -- Ext.Print(num1)
    -- Ext.Print(num2)
    -- Ext.Print(str1)
    -- Ext.Print(str2)
    -- Ext.Print(str3)

    OptionsMenu.Controls[num2] = {name = str1, keys = {str2, str3}}
end

function OnInitDone(ui, method)

    if not OptionsMenu.readingKeys then return nil end

    OptionsMenu.CloseInputMenu(ui)

    OptionsMenu.initialized = true
    OptionsMenu.readingKeys = false
end

Ext.Events.SessionLoaded:Subscribe(function()
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.optionsInput, "addEntry", OnInputAddEntry)
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.optionsInput, "initDone", OnInitDone)

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.optionsInput, "setInput", function(ui, method, eventId, bindingIndex, keyString)

        if not OptionsMenu.changedKeys[eventId] then
            OptionsMenu.changedKeys[eventId] = {id = eventId, keys = {}}
        end
        OptionsMenu.changedKeys[eventId].keys[bindingIndex + 1] = keyString
    end)

    Ext.RegisterUINameCall("ApplyKeyChanges", function(ui, method, param1, param2)
        for i,v in pairs(OptionsMenu.changedKeys) do
            OptionsMenu.Controls[i].keys = v.keys
        end
        OptionsMenu.changedKeys = {}
    end)

    OptionsMenu:ReadKeys()
end)