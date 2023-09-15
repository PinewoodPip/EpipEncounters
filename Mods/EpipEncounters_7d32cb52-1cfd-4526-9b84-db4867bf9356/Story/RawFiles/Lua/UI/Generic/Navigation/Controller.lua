
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
Generic:RegisterClass("GenericUI.Navigation.Controller", Controller)

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
    component:___SetFocused(focused)

    Navigation:DebugLog("Component focus changed", component:GetClassName(), focused)

    for _,iggyEvent in ipairs(component.CONSUMED_IGGY_EVENTS) do
        iggyEvent = iggyEvent:gsub("^IE ", "")

        self._ConsumedIggyEventCounts[iggyEvent] = self._ConsumedIggyEventCounts[iggyEvent] + (focused and 1 or -1)
        if self._ConsumedIggyEventCounts[iggyEvent] < 0 then
            Generic:LogError("Navigation.Controller:SetFocus", "Iggy event consumption count reached <0 for", iggyEvent)
        end

        self.UI:SetIggyEventCapture(iggyEvent, self._ConsumedIggyEventCounts[iggyEvent] > 0)
    end

    -- Recursively unfocus elements
    if not focused then
        local focus = component:GetFocus()
        while focus do
            local current = focus
            focus = current:GetFocus()
            current:___SetFocused(focused)
        end
    end
end

---Forwards an Iggy Event to components that can consume it.
---Consumption is prioritized by depth; the deepest focused component will consume the event.
---@param event GenericUI.Instance.Events.IggyEventCaptured
function Controller:_ProcessIggyEvent(event)
    Navigation:DebugLog("Processing event", event.EventID, event.Timing)
    local iggyEvent = event.EventID

    local stack = {} ---@type GenericUI.Navigation.Component[]
    local focus = self._RootComponent
    while focus do
        table.insert(stack, focus)
        focus = focus:GetFocus()
    end
    for i=#stack,1,-1 do
        local component = stack[i]
        if component:___CanConsumeIggyEvent(iggyEvent) then
            local consumed = component:OnIggyEvent(event)
            if consumed then
                break
            end
        end
    end
end
