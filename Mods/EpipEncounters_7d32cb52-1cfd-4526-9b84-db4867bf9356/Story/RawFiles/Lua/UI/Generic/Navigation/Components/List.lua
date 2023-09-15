
---------------------------------------------
-- Implements a navigation component for list-like elements that allows navigating their children in order.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Component = Generic:GetClass("GenericUI.Navigation.Component")

---@class GenericUI.Navigation.Components.List : GenericUI.Navigation.Component
---@field _Index integer? Index of the current focus. `nil` if there is no focus (ex. upon creation, if list is empty).
local ListComponent = {
    CONSUMED_IGGY_EVENTS = {
        "UIDown",
        "UIUp",
    },
}
Generic:RegisterClass("GenericUI.Navigation.Components.List", ListComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new List component.
---@param target GenericUI.Navigation.Component.Target
---@return GenericUI.Navigation.Components.List
function ListComponent.Create(target)
    local instance = Component.Create(ListComponent, target) ---@cast instance GenericUI.Navigation.Components.List
    instance._Index = nil
    return instance
end

function ListComponent:OnIggyEvent(event)
    -- Scroll the focus of the list.
    if event.Timing == "Up" then
        Navigation:DebugLog("List", "Scroling")
        local direction = event.EventID == "UIDown" and 1 or -1 -- TODO check other keys explicitly
        local children = self:GetChildren()
        local newIndex
        if self._Index then
            newIndex = self._Index + direction
        else
            newIndex = 1 -- Start at 0 by default. TODO have up start from bottom?
        end
        newIndex = math.indexmodulo(newIndex, #children)

        self._Index = newIndex
        self:SetFocus(children[newIndex])
        Navigation:DebugLog("List", "New focus", children[newIndex].__Target.ID)
    end
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
