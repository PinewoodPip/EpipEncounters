
---------------------------------------------
-- Implements a navigation component that allows navigating Grid targets.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local CommonStrings = Text.CommonStrings

---@class GenericUI.Navigation.Components.Grid : GenericUI.Navigation.Components.List
---@field __Target GenericUI_Element_Grid
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

    -- Register default actions
    -- TODO make names customizable as well, rename inherited List ones
    local actions = {} ---@type GenericUI.Navigation.Component.Action[]
    table.insert(actions, {
        ID = "Down",
        Name = CommonStrings.Down,
        Inputs = table.listtoset(config.ScrollDownEvents),
    })
    table.insert(actions, {
        ID = "Up",
        Name = CommonStrings.Up,
        Inputs = table.listtoset(config.ScrollUpEvents),
    })
    for _,action in ipairs(actions) do
        instance:AddAction(action)
    end

    return instance
end

---@override
function GridComponent:OnIggyEvent(event)
    -- Let ListComponent handle next/prev scrolling
    if ListComponent.OnIggyEvent(self, event) then return true end

    if event.Timing == "Down" then -- Handle up/down scrolling. Down timing is used to allow key repeat
        local _, gridColumns = self.__Target:GetGridSize()
        local scrollDirection = nil
        if self:CanConsumeInput("Down", event.EventID) then
            scrollDirection = 1
        elseif self:CanConsumeInput("Up", event.EventID) then
            scrollDirection = -1
        end

        if scrollDirection and gridColumns > 0 then
            local scrollAmount = scrollDirection * gridColumns
            local children = self:GetChildren()
            local newIndex
            if self.__Index then
                newIndex = self.__Index + scrollAmount
            else
                newIndex = scrollDirection == 1 and 1 or #children -- Starting index is based on direction pressed
            end

            if self.__Wrap then
                newIndex = math.indexmodulo(newIndex, #children)
            else
                newIndex = math.clamp(newIndex, 1, #children)
            end

            self:FocusByIndex(newIndex)

            return true
        end
    end
end
