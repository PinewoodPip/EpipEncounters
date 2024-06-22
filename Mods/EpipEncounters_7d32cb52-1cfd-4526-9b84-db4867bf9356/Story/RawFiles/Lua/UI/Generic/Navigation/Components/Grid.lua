
---------------------------------------------
-- Implements a navigation component that allows navigating Grid targets.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local CommonStrings = Text.CommonStrings

---@class GenericUI.Navigation.Components.Grid : GenericUI.Navigation.Components.List
---@field __Target GenericUI_Element_Grid
---@field __ScrollUpEvents table<InputLib_InputEventStringID, true>
---@field __ScrollDownEvents table<InputLib_InputEventStringID, true>
local GridComponent = {}
Navigation:RegisterClass("GenericUI.Navigation.Components.Grid", GridComponent, {"GenericUI.Navigation.Components.List"})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI.Navigation.Components.Grid.Configuration : GenericUI.Navigation.Components.List.Configuration
---@field ScrollUpEvents InputLib_InputEventStringID[]? Events that will switch focus to the previous row.
---@field ScrollDownEvents InputLib_InputEventStringID[]? Events that will switch focus to the next row.
local _DefaultConfig = {
    ScrollBackwardEvents = {"UILeft"},
    ScrollForwardEvents = {"UIRight"},
    ScrollUpEvents = {"UIUp"},
    ScrollDownEvents = {"UIDown"},
}
Inherit(_DefaultConfig, ListComponent.DEFAULT_CONFIG)
GridComponent.DEFAULT_CONFIG = _DefaultConfig

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new List component.
---@param target GenericUI.Navigation.Component.Target
---@param config GenericUI.Navigation.Components.Grid.Configuration?
---@return GenericUI.Navigation.Components.Grid
function GridComponent:Create(target, config)
    if config == nil then -- Use default config by default.
        config = _DefaultConfig
    else
        Inherit(config, _DefaultConfig)
    end
    local instance = ListComponent.Create(GridComponent, target, config) ---@cast instance GenericUI.Navigation.Components.Grid

    instance.__ScrollUpEvents = table.listtoset(config.ScrollUpEvents)
    instance.__ScrollDownEvents = table.listtoset(config.ScrollDownEvents)

    -- Register events as consumable
    for _,id in ipairs(config.ScrollUpEvents) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end
    for _,id in ipairs(config.ScrollDownEvents) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end

    return instance
end

---@override
function GridComponent:OnIggyEvent(event)
    -- Let ListComponent handle next/prev scrolling
    if ListComponent.OnIggyEvent(self, event) then
        return true
    end

    if event.Timing == "Down" then -- Handle up/down scrolling. Down timing is used to allow key repeat
        local _, gridColumns = self.__Target:GetGridSize()
        local scrollDirection = nil
        if self.__ScrollDownEvents[event.EventID] then
            scrollDirection = 1
        elseif self.__ScrollUpEvents[event.EventID] then
            scrollDirection = -1
        end

        if scrollDirection and gridColumns > 0 then
            local scrollAmount = scrollDirection * gridColumns
            local children = self:GetChildren()
            local newIndex
            if self.__Index then
                newIndex = self.__Index + scrollAmount
            else
                newIndex = self.__ScrollDownEvents[event.EventID] and 1 or #children -- Starting index is based on direction pressed
            end

            if self.__Wrap then
                newIndex = math.indexmodulo(newIndex, #children)
            else
                newIndex = math.clamp(newIndex, 1, #children)
            end

            self:__FocusByIndex(newIndex)

            return true
        end
    end
end

---@override
function GridComponent:GetActions()
    local actions = {} ---@type GenericUI.Navigation.Component.Action[]
    table.insert(actions, {
        Inputs = self.__ScrollBackwardEvents,
        Name = CommonStrings.Left,
    })
    table.insert(actions, {
        Inputs = self.__ScrollForwardEvents,
        Name = CommonStrings.Right,
    })
    table.insert(actions, {
        Inputs = self.__ScrollDownEvents,
        Name = CommonStrings.Down,
    })
    table.insert(actions, {
        Inputs = self.__ScrollUpEvents,
        Name = CommonStrings.Up,
    })
    return actions
end
