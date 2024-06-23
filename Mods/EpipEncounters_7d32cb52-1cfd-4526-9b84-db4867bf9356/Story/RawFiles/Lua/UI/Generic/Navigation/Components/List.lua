
---------------------------------------------
-- Implements a navigation component that allows navigating the target's children in order.
-- Target does not need to be a container.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Component = Navigation:GetClass("GenericUI.Navigation.Component")
local CommonStrings = Text.CommonStrings

---@class GenericUI.Navigation.Components.List : GenericUI.Navigation.Component
---@field __Index integer? Index of the current focus. `nil` if there is no focus (ex. upon creation, if list is empty).
---@field __Wrap boolean
---@field __ChildrenOverride GenericUI.Navigation.Component[]
local ListComponent = {
    ---@class GenericUI.Navigation.Components.List.Events : GenericUI.Navigation.Component.Events
    Events = {
        ChildAdded = {}, ---@type Event<GenericUI.Element.Events.ChildAdded> Use to create components for new children.
    },
}
Navigation:RegisterClass("GenericUI.Navigation.Components.List", ListComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI.Navigation.Components.List.Configuration
---@field ScrollForwardEvents InputLib_InputEventStringID[]? Events that will switch focus to the next target.
---@field ScrollBackwardEvents InputLib_InputEventStringID[]? Events that will switch focus to the previous target.
---@field Wrap boolean? If `true`, scrolling past boundaries will cause focus to wrap to the other edge target. Defaults to `false`.
local _DefaultConfig = {
    ScrollBackwardEvents = {"UIUp"},
    ScrollForwardEvents = {"UIDown"},
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
function ListComponent:Create(target, config)
    if config == nil then -- Use default config by default.
        config = _DefaultConfig
    else
        Inherit(config, _DefaultConfig)
    end
    local instance = Component.Create(self, target) ---@cast instance GenericUI.Navigation.Components.List
    instance.Events.ChildAdded = SubscribableEvent:New("ChildAdded")

    instance.__Wrap = config.Wrap
    instance.__Index = nil

    -- Register default actions
    -- TODO make names customizable as well
    local actions = {} ---@type GenericUI.Navigation.Component.Action[]
    table.insert(actions, {
        ID = "Previous",
        Name = CommonStrings.Previous,
        Inputs = table.listtoset(config.ScrollBackwardEvents),
    })
    table.insert(actions, {
        ID = "Next",
        Name = CommonStrings.Next,
        Inputs = table.listtoset(config.ScrollForwardEvents),
    })
    for _,action in ipairs(actions) do
        instance:AddAction(action)
    end

    -- Forward events
    target.Events.ChildAdded:Subscribe(function (ev)
        instance.Events.ChildAdded:Throw(ev)
    end)

    return instance
end

---@override
function ListComponent:OnFocusChanged(focused)
    if focused and self.__Index then
        local children = self:GetChildren()
        self:FocusByIndex(math.clamp(self.__Index, 1, #children)) -- Children might've changed since the last time the list was focused.
    end
end

---@override
function ListComponent:OnIggyEvent(event)
    if Component.OnIggyEvent(self, event) then return true end

    if event.Timing == "Down" then -- Down is used to allow key repeat
        local scrollDirection = nil
        if self:CanConsumeInput("Next", event.EventID) then
            scrollDirection = 1
        elseif self:CanConsumeInput("Previous", event.EventID) then
            scrollDirection = -1
        end
        -- Scroll the focus of the list.
        if scrollDirection then
            local children = self:GetChildren()
            local newIndex
            if self.__Index then
                newIndex = self.__Index + scrollDirection
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

---Focuses the child with a specific index.
---@param index integer
function ListComponent:FocusByIndex(index)
    local children = self:GetChildren()
    local child = children[index]

    self.__Index = index
    self:SetFocus(child)

    -- Navigation:DebugLog("List", self.__Target.ID, "New focus", child and child.__Target.ID or "nil")
end

---Sets the index of the child to focus without updating the focus.
---Can be used to set the default index to focus.
---@param index integer
function ListComponent:SetFocusedIndex(index)
    self.__Index = index
end

---Returns the child components.
---@return GenericUI.Navigation.Component[]
function ListComponent:GetChildren()
    local components ---@type GenericUI.Navigation.Component[]

    if self.__ChildrenOverride then
        components = self.__ChildrenOverride
    else
        components = {}
        for _,child in ipairs(self.__Target:GetChildren()) do
            ---@cast child GenericUI.Navigation.Component.Target
            if child.___Component and child:IsVisible() then -- Ignore elements with no component as well as invisible elements
                table.insert(components, child.___Component)
            end
        end
    end

    return components
end

---Sets the child components.
---If `nil` (default), children will be searched from the target's child elements.
---@param children GenericUI.Navigation.Component[]?
function ListComponent:SetChildren(children)
    self.__ChildrenOverride = children
end
