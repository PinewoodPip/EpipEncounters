
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation

---@class GenericUI.Navigation.Component : Class
---@field __Target GenericUI.Navigation.Component.Target
---@field __ActionsMap table<InputLib_InputEventStringID, GenericUI.Navigation.Component.Action>
---@field __Actions GenericUI.Navigation.Component.Action[] In order of registration.
---@field __ActionsByID table<string, GenericUI.Navigation.Component.Action>
---@field _Focus GenericUI.Navigation.Component?
---@field _IsFocused boolean
---@field _ConsumedIggyEventsMap set<InputLib_InputEventStringID> Automatically generated.
local Component = {
    ---@class GenericUI.Navigation.Component.Events
    Events = {
        ActionAdded = {}, ---@type Event<GenericUI.Navigation.Component.Events.ActionAdded>
    },
    Hooks = {
        ConsumeInput = {}, ---@type Hook<GenericUI.Navigation.Component.Hooks.ConsumeInput>
    },
}
Navigation:RegisterClass("GenericUI.Navigation.Component", Component)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias GenericUI.Navigation.Component.Target GenericUI_Element|GenericUI_I_Elementable|{___Component: GenericUI.Navigation.Component}

---@class GenericUI.Navigation.Component.Action
---@field ID string
---@field Name TextLib.String
---@field Inputs set<InputLib_InputEventStringID>
---@field IsConsumableFunctor (fun(component:GenericUI.Navigation.Component):boolean)? If `nil`, the action is considered to always be consumable.

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI.Navigation.Component.Events.ActionAdded
---@field Action GenericUI.Navigation.Component.Action

---@class GenericUI.Navigation.Component.Hooks.ConsumeInput
---@field Event GenericUI.Instance.Events.IggyEventCaptured
---@field Action GenericUI.Navigation.Component.Action
---@field Consumed boolean Hookable. Defaults to `false`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a navigation component for an elementable.
---Inheritable constructor.
---@param target GenericUI.Navigation.Component.Target
---@return GenericUI.Navigation.Component
function Component:Create(target)
    -- Other components expect Target to be element. TODO also hold a prefab ref?
    if OOP.ImplementsClass(target, "GenericUI_I_Elementable") then
        target = target:GetRootElement()
    end
    local instance = self:__Create({
        __Target = target,
        _Focus = nil,
        _IsFocused = false,
    }) ---@cast instance GenericUI.Navigation.Component

    -- Track the component for the target
    -- Preventing component replacement is not necessary, and anti-modding.
    instance.__Target.___Component = instance
    instance.__Actions = {}
    instance.__ActionsMap = {}
    instance.__ActionsByID = {}

    instance.Events = SubscribableEvent.CreateEventsTable(Component.Events)
    instance.Hooks = SubscribableEvent.CreateEventsTable(Component.Hooks)

    return instance
end

---Called when the focus of the element changes.
---@virtual
---@param focused boolean
---@diagnostic disable-next-line: unused-local
function Component:OnFocusChanged(focused) end

---Called when the component receives an Iggy Event.
---@see GenericUI.Navigation.Component.Hooks.ConsumeInput
---@virtual
---@param event GenericUI.Instance.Events.IggyEventCaptured
---@return boolean -- If `true`, the event will be considered consumed and will not propagate to parent components.
---@diagnostic disable-next-line: unused-local
function Component:OnIggyEvent(event)
    return self.Hooks.ConsumeInput:Throw({
        Action = self:GetInputEventAction(event.EventID),
        Event = event,
        Consumed = false,
    }).Consumed
end

---Registers an action that the component can consume while focused.
---@param action GenericUI.Navigation.Component.Action
function Component:AddAction(action)
    for input in pairs(action.Inputs) do
        if self.__ActionsMap[input] then
            Component:__Error("AddAction", input, "is already in use by another action")
        end
        self.__ActionsMap[input] = action
    end
    table.insert(self.__Actions, action)
    self.__ActionsByID[action.ID] = action
    self.Events.ActionAdded:Throw({
        Action = action,
    })
    -- If the component was focused, the ref counts for the inputs to consume need to be updated
    local controller = self:_GetController()
    if controller and self:IsFocused() then
        for input in pairs(action.Inputs) do
            ---@diagnostic disable-next-line: invisible
            controller:_UpdateInputEventRefCount(input, true)
        end
    end
end

---Returns the actions for an input event.
---@param inputEvent InputLib_InputEventStringID
---@return GenericUI.Navigation.Component.Action?
function Component:GetInputEventAction(inputEvent)
    return self.__ActionsMap[inputEvent]
end

---Gets the focused subcomponent.
---Focused components will consume input events.
---@return GenericUI.Navigation.Component?
function Component:GetFocus()
    return (self._Focus and self._Focus:IsAlive()) and self._Focus or nil
end

---Sets the focused subcomponent.
---@param focus GenericUI.Navigation.Component?
function Component:SetFocus(focus)
    local previousFocus = self._Focus
    self._Focus = focus
    local controller = self:_GetController() -- TODO nil check? Using components without a controller is atm undefined behaviour.

    if previousFocus and previousFocus:IsAlive() then
        controller:SetFocus(previousFocus, false)
        previousFocus:OnFocusChanged(false)
    end
    if focus then
        controller:SetFocus(focus, true)
        focus:OnFocusChanged(true)
    end
end

---Returns whether the component is focused by its parent.
---@return boolean
function Component:IsFocused()
    return self._IsFocused
end

---Returns whether the target for this component still exists (as in, has not been destroyed).
---@return boolean
function Component:IsAlive()
    return not self.__Target:IsDestroyed()
end

---Returns the actions registered for the component.
---@return GenericUI.Navigation.Component.Action[]
function Component:GetActions()
    return self.__Actions
end

---Returns the actions currently consumable by the component.
---@return GenericUI.Navigation.Component.Action[]
function Component:GetConsumableActions()
    local actions = self:GetActions()
    local consumableActions = {}
    for _,action in ipairs(actions) do
        if action.IsConsumableFunctor == nil or action.IsConsumableFunctor(self) then
            table.insert(consumableActions, action)
        end
    end
    return consumableActions
end

---Returns an action by ID.
---@param id string
---@return GenericUI.Navigation.Component.Action?
function Component:GetAction(id)
    return self.__ActionsByID[id]
end

---Sets whether the component is focused by its parent.
---@package
---@param focused boolean
function Component:___SetFocused(focused)
    self._IsFocused = focused
    self:OnFocusChanged(focused)
end

---Returns whether there are any actions that can consume an input event.
---Note that actual event consumption may have conditional logic not reflected by this.
---@overload fun(input):boolean
---@param input InputLib_InputEventStringID
---@return boolean
function Component:CanConsumeInput(actionID, input)
    if input == nil then -- Input-only overload.
        input = actionID
        actionID = nil
    end
    local action = self:GetInputEventAction(input)
    return action and (actionID == nil or action.ID == actionID)
end

---Returns the navigation controller that the component is bound to.
---@return GenericUI.Navigation.Controller?
function Component:_GetController()
    local ui = self.__Target.UI ---@cast ui GenericUI.Navigation.UI
    return ui.___NavigationController
end
