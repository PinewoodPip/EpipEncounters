
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
    if event.Timing == "Up" then
        local scrollDirection = nil
        if event.EventID == "UIDown" then
            scrollDirection = 1
        elseif event.EventID == "UIUp" then
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
            newIndex = math.indexmodulo(newIndex, #children)

            self._Index = newIndex
            self:SetFocus(children[newIndex])
            Navigation:DebugLog("List", "New focus", children[newIndex].__Target.ID)
        end
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
