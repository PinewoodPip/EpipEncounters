
---------------------------------------------
-- Wraps a Generic UI instance to provide keyboard/controller navigation via Components attached to elements and elementables.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation

---@class GenericUI.Navigation.Controller : Class
---@field UI GenericUI.Navigation.UI
---@field _RootComponent GenericUI.Navigation.Component
---@field _ConsumedIggyEventCounts table<iggyevent, integer>
local Controller = {}
Navigation:RegisterClass("GenericUI.Navigation.Controller", Controller)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a navigation controller for a UI.
---@param ui GenericUI_Instance
---@param root GenericUI.Navigation.Component
---@return GenericUI.Navigation.Controller
function Controller.Create(ui, root)
    local instance = Controller:__Create({
        UI = ui,
        _ConsumedIggyEventCounts = DataStructures.Get("DataStructures_DefaultTable").Create(0),
    }) ---@cast instance GenericUI.Navigation.Controller

    instance:_Initialize(root)

    return instance
end

---Initializes the controller.
---@param root GenericUI.Navigation.Component
function Controller:_Initialize(root)
    self._RootComponent = root
    self:SetFocus(root, true)

    self.UI.Events.IggyEventUpCaptured:Subscribe(function (ev)
        self:_ProcessIggyEvent(ev)
    end)
    self.UI.Events.IggyEventDownCaptured:Subscribe(function (ev)
        self:_ProcessIggyEvent(ev)
    end)

    -- Track the navigation controller of a UI with a mix-in
    if self.UI.___NavigationController then
        Generic:Error("Navigation.Controller:_Initialize", "The UI already has a navigation controller.")
    end
    self.UI.___NavigationController = self
end

---Sets the focus of a component. Unfocusing is recursive; unfocusing a component will unfocus all its child components.
---Behaviour of focusing children is driven by the component and not mandatory as a result of this call.
---@param component GenericUI.Navigation.Component
---@param focused boolean
function Controller:SetFocus(component, focused)
    if component:IsFocused() == focused then return end

    component:___SetFocused(focused)

    -- Recursively unfocus elements
    if not focused then
        local focus = component:GetFocus()
        if focus then
            self:SetFocus(focus, false)
        end
    end

    -- Navigation:DebugLog("Component focus changed", component:GetClassName(), focused)

    for _,action in ipairs(component:GetActions()) do
        for input in pairs(action.Inputs) do
            input = input:gsub("^IE ", "")
            self:_UpdateInputEventRefCount(input, focused)
        end
    end
end

---Returns the currently available actions that the components report.
---@return GenericUI.Navigation.Component.Action[]
function Controller:GetCurrentActions()
    local stack = self:GetFocusStack()
    local actions = {} ---@type GenericUI.Navigation.Component.Action[]
    local usedInputs = {} ---@type set<InputLib_InputEventStringID>

    for i=#stack,1,-1 do
        local component = stack[i]
        local componentActions = component:GetActions()
        for _,action in ipairs(componentActions) do
            local valid = false
            -- Only include the action if no deeper components already define one for the input events.
            for inputEvent,_ in pairs(action.Inputs) do
                if not usedInputs[inputEvent] then
                    valid = true
                end
                usedInputs[inputEvent] = true
            end
            if valid then
                table.insert(actions, action)
            end
        end
    end

    return actions
end

---Returns the stack of focused components.
---@return GenericUI.Navigation.Component[] -- In order from lowest (top-level) to highest depth.
function Controller:GetFocusStack()
    local stack = {} ---@type GenericUI.Navigation.Component[]
    local focus = self._RootComponent
    while focus do
        table.insert(stack, focus)
        focus = focus:GetFocus()
    end
    return stack
end

---Forwards an Iggy Event to components that can consume it.
---Consumption is prioritized by depth; the deepest focused component will consume the event.
---@param event GenericUI.Instance.Events.IggyEventCaptured
function Controller:_ProcessIggyEvent(event)
    Navigation:DebugLog("Processing event", event.EventID, event.Timing)
    local iggyEvent = event.EventID

    local stack = self:GetFocusStack()
    for i=#stack,1,-1 do
        local component = stack[i]
        if component:CanConsumeInput(iggyEvent) then
            local consumed = component:OnIggyEvent(event)
            if consumed then
                Navigation:DebugLog(event.EventID, "consumed by", component.__Target.ID)
                break
            end
        end
    end
end

---Updates the bookkeeping for which input events the current focused component stack can consume.
---@param input InputLib_InputEventStringID
---@param focused boolean
function Controller:_UpdateInputEventRefCount(input, focused)
    self._ConsumedIggyEventCounts[input] = self._ConsumedIggyEventCounts[input] + (focused and 1 or -1)
    if self._ConsumedIggyEventCounts[input] < 0 then
        Controller:__LogError("SetFocus", "Input event consumption count reached <0 for", input)
    end

    self.UI:SetIggyEventCapture(input, self._ConsumedIggyEventCounts[input] > 0)
end
