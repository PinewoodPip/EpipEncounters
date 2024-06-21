
---------------------------------------------
-- Derived List component *only* for ScrollList elements,
-- handling keeping focused elements within the viewport and allowing manual scrolling.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")

---@class GenericUI.Navigation.Components.ScrollList : GenericUI.Navigation.Components.List
---@field __Target GenericUI_Element_ScrollList
---@field __ScrollUpEvents set<InputLib_InputEventStringID>
---@field __ScrollDownEvents set<InputLib_InputEventStringID>
---@field __ScrollAmount number Pixels to scroll per ScrollUp/ScrollDown event.
local ScrollListComponent = {
    DEFAULT_SCROLL_AMOUNT = 50,

    Events = {},
}
for k,v in pairs(ListComponent.Events) do -- Inherit events
    ScrollListComponent.Events[k] = v
end
Navigation:RegisterClass("GenericUI.Navigation.Components.ScrollList", ScrollListComponent, {"GenericUI.Navigation.Components.List"})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI.Navigation.Components.ScrollList.Configuration : GenericUI.Navigation.Components.List.Configuration
---@field ScrollUpEvents InputLib_InputEventStringID[]? Events that will scroll the list up without changing the focused element.
---@field ScrollDownEvents InputLib_InputEventStringID[]? Events that will scroll the down up without changing the focused element.
---@field ScrollAmount number Pixels to scroll per ScrollUp/ScrollDown event.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a ScrollList component.
---@param target GenericUI_Element_ScrollList
---@param config GenericUI.Navigation.Components.ScrollList.Configuration?
---@return GenericUI.Navigation.Components.ScrollList
function ScrollListComponent:Create(target, config)
    config = config or EMPTY
    if not target.Type or target.Type ~= "GenericUI_Element_ScrollList" then
        ScrollListComponent:__Error("Create", "Target must be a ScrollList element")
    end

    local instance = ListComponent.Create(self, target, config) ---@cast instance GenericUI.Navigation.Components.ScrollList

    self.__ScrollAmount = config.ScrollAmount or self.DEFAULT_SCROLL_AMOUNT

    -- Add manual scrolling input events
    instance.__ScrollUpEvents = table.listtoset(config.ScrollUpEvents or EMPTY)
    instance.__ScrollDownEvents = table.listtoset(config.ScrollDownEvents or EMPTY)
    for _,id in ipairs(config.ScrollUpEvents or EMPTY) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end
    for _,id in ipairs(config.ScrollDownEvents or EMPTY) do
        table.insert(instance.CONSUMED_IGGY_EVENTS, id)
    end

    return instance
end

---@override
function ScrollListComponent:OnIggyEvent(event)
    if event.Timing == "Down" then
        if self.__ScrollUpEvents[event.EventID] then
            self:Scroll(-self.__ScrollAmount)
            return true
        elseif self.__ScrollDownEvents[event.EventID] then
            self:Scroll(self.__ScrollAmount)
            return true
        else
            return ListComponent.OnIggyEvent(self, event)
        end
    end
end

---@override
function ScrollListComponent:SetFocus(focus)
    ListComponent.SetFocus(self, focus)

    -- Keep focused element within the viewport of the ScrollList.
    local target = self.__Target
    if focus and target.Type and target.Type == "GenericUI_Element_ScrollList" then
        local mc = target:GetMovieClip()
        local _, y = focus.__Target:GetPosition()
        local height = focus.__Target:GetHeight()
        mc.list.m_scrollbar_mc.scrollIntoView(y, height)
    end
end

---Scrolls the list.
---@param offset number Positive amounts will scroll down, negatives will scroll up.
function ScrollListComponent:Scroll(offset)
    local mc = self.__Target:GetMovieClip()
    local scrollbar = mc.list.m_scrollbar_mc
    scrollbar.scrollTo(scrollbar.scrolledY + offset)
end
