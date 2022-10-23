
---@class HotbarUI
local Hotbar = Client.UI.Hotbar

---@class HotbarAction
---@field ID string Set automatically by RegisterAction()
---@field Name string
---@field Icon string
---@field Type? string Intended for use in events, to render groups of actions in a certain way.
---@field InputEventID? integer The vanilla input event for this action. If set, the keybind for it will be shown, rather than the keybind for the action button.
---@field VisibleInDrawer? boolean

---@class HotbarActionState
---@field ActionID string The action bound to this hotkey button.

---------------------------------------------
-- METHODS
---------------------------------------------

---Register an action for the hotkeys area and action drawer.
---@param id string
---@param data HotbarAction
function Hotbar.RegisterAction(id, data)
    if Hotbar.Actions[id] ~= nil then
        Hotbar:LogError("Action already registered: " .. id)
    else
        data.Type = data.Type or "Normal"
        data.ID = id or data.ID

        Hotbar.Actions[id] = data

        table.insert(Hotbar.RegisteredActionOrder, id)

        Hotbar:FireEvent("ActionRegistered", data) -- TODO refresh drawer if this happens while it's open
    end
end

---Use a hotbar action. Ignores whether the action is enabled!
---@param id string
function Hotbar.UseAction(id, buttonIndex)
    local actionData = Hotbar.Actions[id]
    local char = Client.GetCharacter()

    if actionData then
        Hotbar:DebugLog("Action used: " .. id)
        Hotbar:FireEvent("ActionUsed", id, char, actionData, buttonIndex)
        Hotbar:FireEvent("ActionUsed_" .. id, char, actionData, buttonIndex)
    else
        Hotbar:LogError("Tried to use an action that is not registered: " .. id)
    end
end

---Register a listener for a specific action.
---@param action string Action ID.
---@param event string Event ID.
---@param handler function
function Hotbar.RegisterActionListener(action, event, handler)
    Hotbar:RegisterListener(event .. "_" .. action, handler)
end

---Register a hook for a specific action.
---@param action string Action ID.
---@param event string Hook event ID.
---@param handler function
function Hotbar.RegisterActionHook(action, event, handler)
    Hotbar:RegisterHook(event .. "_" .. action, handler)
end

---Toggles the action drawer.
---@param state boolean True for open.
function Hotbar.ToggleDrawer(state)
    local hotkeys = Hotbar.GetHotkeysHolder()

    if state == nil then
        state = not hotkeys.drawer_mc.visible
    end

    hotkeys.toggleDrawer(state)
end

---Returns the data for an action.
---@param id string Action ID.
---@return HotbarAction?
function Hotbar.GetActionData(id)
    if id then
        return Hotbar.Actions[id]
    end

    return nil
end

---Returns the actions bound to the hotkey buttons.
---@return HotbarActionState[]
function Hotbar.GetActionButtons()
    local btns = {}
    for i=1,Hotbar.ACTION_BUTTONS_COUNT,1 do
        table.insert(btns, Hotbar.ActionsState[i] or {
            ActionID = "",
        })
    end

    return btns
end

---Returns whether the actions drawer is open.
---@return boolean
function Hotbar.IsDrawerOpen()
    return Hotbar.GetHotkeysHolder().drawer_mc.visible
end

---Activates an action from a hotkey.
---@param index integer Index of the hotkey button.
---@return boolean #Whether the action was executed.
function Hotbar.PressHotkey(index) -- TODO distinguish mouse/kb
    local hotkeyState = Hotbar.ActionsState[index]
    local usedAction = false

    if Hotbar.HasBoundAction(index) and Client.Input.IsAcceptingInput() then
        local enabled = Hotbar.IsActionEnabled(hotkeyState.ActionID, index)

        if enabled then
            usedAction = true
            Hotbar.UseAction(hotkeyState.ActionID, index)
        end
    end

    return usedAction
end

---Returns whether an action is enabled (usable, not greyed out)
---@param id string Action ID.
---@vararg any Additional arguments passed to the hooks.
---@return boolean Defaults to true.
function Hotbar.IsActionEnabled(id, ...)
    local actionData = Hotbar.Actions[id]

    if actionData then
        local enabled = Hotbar:ReturnFromHooks("IsActionEnabled_" .. actionData.ID, true, Client.GetCharacter(), actionData, ...)
        enabled = Hotbar:ReturnFromHooks("IsActionEnabled", enabled, actionData.ID, Client.GetCharacter(), actionData, ...) -- Generic listeners go last!

        return enabled
    else
        return false
    end
end

---Returns whether an action should show up in the drawer.
---@param id string Action ID.
---@return boolean Defaults to true.
function Hotbar.IsActionVisibleInDrawer(id)
    local actionData = Hotbar.Actions[id]

    if actionData then
        local visible = Hotbar:ReturnFromHooks("IsActionVisibleInDrawer_" .. actionData.ID, true, Client.GetCharacter(), actionData)
        visible = Hotbar:ReturnFromHooks("IsActionVisibleInDrawer", visible, actionData.ID, Client.GetCharacter(), actionData) -- Generic listeners go last!

        return visible
    else
        return false
    end
end

---Returns a property from an action's data through hooks.
---@param id string Action ID.
---@param prop string Hook event ot call.
---@param defaultValue any
---@return any
function Hotbar.GetActionProperty(id, prop, defaultValue, ...)
    local actionData = Hotbar.Actions[id]
    defaultValue = defaultValue or Hotbar.DEFAULT_ACTION_PROPERTIES[prop]

    if actionData and defaultValue ~= nil then
        local value = Hotbar:ReturnFromHooks(prop .. "_" .. actionData.ID, defaultValue, Client.GetCharacter(), actionData, ...)
        value = Hotbar:ReturnFromHooks(prop, value, actionData.ID, Client.GetCharacter(), actionData, ...) -- Generic listeners go last!

        return value
    else
        return defaultValue
    end
end

---Returns whether an action is "active" (highlighted in action buttons)
---@param id string Action ID.
---@return boolean Defaults to false.
function Hotbar.IsActionHighlighted(id)
    return Hotbar.GetActionProperty(id, "IsActionHighlighted")
end

---Sets the action for a hotkey button.
---@param index integer Index of the hotkey button to set.
---@param action string Action ID.
function Hotbar.SetHotkeyAction(index, action)
    if index >= 1 and index <= 12 then
        Hotbar.ActionsState[index] = {
            ActionID = action
        }

        Hotbar:FireEvent("ActionHotkeySet", index, action) -- TODO refresh
    else
        Hotbar:LogError("Invalid index for SetHotkeyAction: " .. tostring(index))
    end
end

---Returns whether the hotbar currently shows a second row of action buttons.
---@return boolean
function Hotbar.HasSecondHotkeysRow()
    local dualLayout = false
    local setting = Settings.GetSettingValue("EpipEncounters", "HotbarHotkeysLayout")

    -- Force dual-row layout
    if setting == 3 then
        dualLayout = true
    -- Otherwise, if the setting does not force single-row, use dual for 2+ bars
    elseif Hotbar.GetBarCount() > 1 and setting ~= 2 then
        dualLayout = true
    end

    return dualLayout
end

---Returns the name for an action.
---@param id string Action ID.
---@vararg any Additional params passed to hooks.
---@return string Defaults to "Unknown"
function Hotbar.GetActionName(id, ...)
    local data = Hotbar.Actions[id]

    if data then
        return Hotbar.GetActionProperty(id, "GetActionName", data.Name, ...)
    else
        return "Unknown"
    end
end

---Returns the icon for an action.
---@param id string Action ID.
---@return string Defaults to "unknown"
function Hotbar.GetActionIcon(id, ...)
    local data = Hotbar.Actions[id]

    if data then
        return Hotbar.GetActionProperty(id, "GetActionIcon", data.Icon, ...)
    else
        return "unknown"
    end
end

---Gets the string display for an action button's keybinding.
---@param index integer Index of the action hotkey button.
---@param shortName boolean? Whether to use short names. Defaults to true.
---@return string Empty if the button is unbound.
function Hotbar.GetKeyString(index, shortName)
    if shortName == nil then shortName = true end
    local state = Hotbar.ActionsState[index]
    local key = ""

    if state.ActionID ~= "" then
        local actionData = Hotbar.Actions[state.ActionID]
        local inputEvent = nil

        -- Manually-defined inputevent takes priority
        if actionData.InputEventID then
            inputEvent = actionData.InputEventID
            key = OptionsMenu:GetKey(inputEvent, true)
        else -- Use the hotbar keybinds
            local bindableAction = Client.UI.OptionsInput.GetKeybinds("EpipEncounters_Hotbar_" .. Text.RemoveTrailingZeros(index))

            if bindableAction then
                if bindableAction.Input1 then
                    key = Client.UI.OptionsInput.StringifyBinding(bindableAction.Input1, shortName)
                elseif bindableAction.Input2 then
                    key = Client.UI.OptionsInput.StringifyBinding(bindableAction.Input2, shortName)
                end
            end
        end

    end

    return key or ""
end

---@param action string
---@return integer
function Hotbar.GetHotkeyIndex(action)
    local actionsState = Hotbar.ActionsState
    local index

    for i,state in ipairs(actionsState) do
        if state.ActionID == action then
            index = i
            break
        end
    end

    return index
end

---@param index integer
---@return boolean
function Hotbar.HasBoundAction(index)
    return Hotbar.ActionsState[index].ActionID ~= "" and Hotbar.ActionsState[index].ActionID ~= nil
end

---Unbinds a hotkey button by index.
---@param index integer
function Hotbar.UnbindActionButton(index)
    if index < 1 or index > Hotbar.ACTION_BUTTONS_COUNT then 
        Hotbar:LogError("Invalid index to UnbindActionButton(); must be between 1 and 12 inclusive.")
        return nil
    end

    local hotkeys = Hotbar.GetHotkeysHolder()
    local button = hotkeys.hotkeyButtons[index - 1]
    
    Hotbar.ActionsState[index].ActionID = ""
    button.setAction("")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Shorthand property on ActionData for IsActionVisibleInDrawer().
Hotbar:RegisterHook("IsActionVisibleInDrawer", function(visible, _, _, actionData)
    if visible and actionData.VisibleInDrawer == false then
        visible = false
    end
    return visible
end)

Hotbar:RegisterCallListener("pipHotbarStartRearrange", function(_, index, action)
    Hotbar:DebugLog("Now dragging " .. action .. " from index " .. index)

    if action ~= "" and not Hotbar.IsLocked() then 
        local draggingPreview = Hotbar.GetHotkeysHolder().draggingPreview

        draggingPreview.index = index
        draggingPreview.visible = true
        draggingPreview.icon_mc.name = "iggy_pip_hotbar_preview"
        draggingPreview.action = action
        draggingPreview.setHighlighted(false)

        Hotbar:GetUI():SetCustomIcon("pip_hotbar_preview", Hotbar.GetActionIcon(action), 32, 32)
    end
end)

Hotbar:RegisterCallListener("pipHotbarStopRearrange", function(_, index)
    index = index + 1
    Hotbar:DebugLog("Stopped dragging on " .. index)
    
    if not Hotbar.IsLocked() then 
        local draggingPreview = Hotbar.GetHotkeysHolder().draggingPreview
        local previousIndex = draggingPreview.index + 1

        draggingPreview.visible = false
        draggingPreview.text_mc.htmlText = ""

        -- Do nothing if button was dragged out of bounds
        if index > 0 then
            local hotkeys = Hotbar.GetHotkeysHolder()
            local finalButton = hotkeys.hotkeyButtons[index]

            local previousAction = Hotbar.ActionsState[index].ActionID -- Action that was on new button

            Hotbar:FireEvent("ActionsSwapped", {
                Index = previousIndex,
                Action = draggingPreview.action,
            }, {
                Index = index,
                Action = previousAction,
            })

            Hotbar.SetHotkeyAction(index, draggingPreview.action)
            Hotbar.SetHotkeyAction(previousIndex, previousAction)
        end

        -- Hide tooltip; otherwise if you keep the cursor on the button you've just dragged an action onto, it shows the old one
        Hotbar:HideTooltip()
        Hotbar.ToggleDrawer(false)
    end

    Hotbar.RenderHotkeys()
end)

Hotbar:RegisterCallListener("pipHotbarHotkeyPressed", function(_, action, index)
    Hotbar:DebugLog("Using action from hotkey button: " .. action)

    if index then
        index = index + 1
    end

    if Hotbar.IsActionEnabled(action, index) then
        Hotbar.UseAction(action, index)
    end
end)

Hotbar:RegisterCallListener("pipDrawerToggled", function(_, open)
    local hotkeys = Hotbar.GetHotkeysHolder()

    if open then
        local buttonWidth = 181

        hotkeys.drawer_mc.x = 70
        hotkeys.drawer_mc.setFrame(buttonWidth, 400)
        Hotbar:GetRoot().hotbar_mc.hotkeys_pip_mc.drawer_mc.clearElements()
        hotkeys.drawer_mc.m_scrollbar_mc.x = buttonWidth - 3

        Hotbar.RenderDrawerButtons()
        Hotbar.PositionDrawer()
    else
        Hotbar:GetRoot().hotbar_mc.hotkeys_pip_mc.drawer_mc.clearElements()
    end
end)