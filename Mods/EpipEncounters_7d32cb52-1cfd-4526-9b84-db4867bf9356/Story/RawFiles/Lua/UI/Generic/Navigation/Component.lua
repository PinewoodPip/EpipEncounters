
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation

---@class GenericUI.Navigation.Component : Class
---@field __Target GenericUI.Navigation.Component.Target
---@field _Focus GenericUI.Navigation.Component?
---@field _IsFocused boolean
---@field CONSUMED_IGGY_EVENTS InputLib_InputEventStringID[] List of Iggy Events the component will consume when focused. Do not change after the component is created.
---@field _ConsumedIggyEventsMap table<InputLib_InputEventStringID, true> Automatically generated.
local Component = {
    CONSUMED_IGGY_EVENTS = {},
}
Generic:RegisterClass("GenericUI.Navigation.Component", Component)

---@alias GenericUI.Navigation.Component.Target GenericUI_Element|GenericUI_I_Elementable|{___Component: GenericUI.Navigation.Component}

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a navigation component for an elementable.
---Inheritable constructor.
---@param target GenericUI.Navigation.Component.Target
function Component:Create(target)
    local instance = self:__Create({
        __Target = target,
        _Focus = nil,
        _IsFocused = false,
    }) ---@cast instance GenericUI.Navigation.Component

    -- Track the component for the target
    -- Preventing component replacement is not necessary, and anti-modding.
    instance.__Target.___Component = instance

    return instance
end

---Called when the focus of the element changes.
---@virtual
---@param focused boolean
---@diagnostic disable-next-line: unused-local
function Component:OnFocusChanged(focused) end

---Called when the component receives an Iggy Event.
---@virtual
---@param event GenericUI.Instance.Events.IggyEventCaptured
---@return boolean -- If `true`, the event will be considered consumed and will not propagate to parent components.
---@diagnostic disable-next-line: unused-local
function Component:OnIggyEvent(event)
    return false
end

---Gets the focused subcomponent.
---Focused components will consume input events.
---@return GenericUI.Navigation.Component?
function Component:GetFocus()
    return self._Focus
end

---Sets the focused subcomponent.
---@param focus GenericUI.Navigation.Component?
function Component:SetFocus(focus)
    local previousFocus = self._Focus
    self._Focus = focus
    local controller = self:_GetController() -- TODO nil check? Using components without a controller is atm undefined behaviour.

    if previousFocus then
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
    return not table.isdestroyed(self.__Target)
end

---Sets whether the component is focused by its parent.
---@package
---@param focused boolean
function Component:___SetFocused(focused)
    self._IsFocused = focused
    self:OnFocusChanged(focused)
end

---Returns whether the component can consume an Iggy Event.
---@param iggyEvent InputLib_InputEventStringID
---@return boolean
function Component:___CanConsumeIggyEvent(iggyEvent)
    if not self._ConsumedIggyEventsMap then
        self._ConsumedIggyEventsMap = table.listtoset(self.CONSUMED_IGGY_EVENTS)
    end
    return self._ConsumedIggyEventsMap[iggyEvent] == true
end

---Returns the navigation controller that the component is bound to.
---@return GenericUI.Navigation.Controller?
function Component:_GetController()
    local ui = self.__Target.UI ---@cast ui GenericUI.Navigation.UI
    return ui.___NavigationController
end
