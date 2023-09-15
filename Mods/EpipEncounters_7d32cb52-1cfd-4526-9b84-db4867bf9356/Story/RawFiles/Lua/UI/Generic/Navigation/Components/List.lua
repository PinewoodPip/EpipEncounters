
---------------------------------------------
-- Implements a navigation component for list-like elements that allows navigating their children in order.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Component = Generic:GetClass("GenericUI.Navigation.Component")

---@class GenericUI.Navigation.Components.List : GenericUI.Navigation.Component
---@field _Index integer? Index of the current focus. `nil` if there is no focus (ex. upon creation, if list is empty).
---@field _ScrollForwardEvents table<InputLib_InputEventStringID, true>
---@field _ScrollBackwardEvents table<InputLib_InputEventStringID, true>
---@field _Wrap boolean
local ListComponent = {}
Generic:RegisterClass("GenericUI.Navigation.Components.List", ListComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI.Navigation.Components.List.Configuration
---@field ScrollForwardEvents InputLib_InputEventStringID[]? Events that will switch focus to the next target.
---@field ScrollBackwardEvents InputLib_InputEventStringID[]? Events that will switch focus to the previous target.
---@field Wrap boolean? If `true`, scrolling past boundaries will cause focus to wrap to the other edge target. Defaults to `false`.
local _DefaultConfig = {
    ScrollBackwardEvents = {"UIUp", "UILeft"},
    ScrollForwardEvents = {"UIDown", "UIRight"},
    Wrap = false,
}
ListComponent.DEFAULT_CONFIG = _DefaultConfig

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new List component.
---@param target GenericUI.Navigation.Component.Target
---@param config GenericUI.Navigation.Components.List.Configuration?
---@return GenericUI.Navigation.Components.List
function ListComponent.Create(target, config)
    if config == nil then -- Use default config by default.
        config = _DefaultConfig
    else
        Inherit(config, _DefaultConfig)
    end
    local instance = Component.Create(ListComponent, target) ---@cast instance GenericUI.Navigation.Components.List
    instance._Index = nil

    instance._ScrollBackwardEvents = table.listtoset(config.ScrollBackwardEvents)
    instance._ScrollForwardEvents = table.listtoset(config.ScrollForwardEvents)
    instance._Wrap = config.Wrap

    -- Register events as consumable
    instance.CONSUMED_IGGY_EVENTS = {}
    for _,id in ipairs(config.ScrollBackwardEvents) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end
    for _,id in ipairs(config.ScrollForwardEvents) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end

    return instance
end

function ListComponent:OnIggyEvent(event)
    if event.Timing == "Up" then
        local scrollDirection = nil
        if self._ScrollForwardEvents[event.EventID] then
            scrollDirection = 1
        elseif self._ScrollBackwardEvents[event.EventID] then
            scrollDirection = -1
        end
        -- Scroll the focus of the list.
        if scrollDirection then
            Navigation:DebugLog("List", "Scroling")
            local children = self:GetChildren()
            local newIndex
            if self._Index then
                newIndex = self._Index + scrollDirection
            else
                newIndex = event.EventID == "UIDown" and 1 or #children -- Starting index is based on direction pressed
            end

            if self._Wrap then
                newIndex = math.indexmodulo(newIndex, #children)
            else
                newIndex = math.clamp(newIndex, 1, #children)
            end

            self:_FocusByIndex(newIndex)
        end
    end
end

---Focuses the child with a specific index.
---@param index integer
function ListComponent:_FocusByIndex(index)
    local children = self:GetChildren()
    local child = children[index]

    self._Index = index
    self:SetFocus(child)

    Navigation:DebugLog("List", "New focus", child.__Target.ID)
end

---Returns the child components.
---@return GenericUI.Navigation.Component[]
function ListComponent:GetChildren()
    local components = {} ---@type GenericUI.Navigation.Component[]

    for _,child in ipairs(self.__Target:GetChildren()) do
        ---@cast child GenericUI.Navigation.Component.Target
        if child.___Component then -- Ignore elements with no component
            table.insert(components, child.___Component)
        end
    end

    return components
end
