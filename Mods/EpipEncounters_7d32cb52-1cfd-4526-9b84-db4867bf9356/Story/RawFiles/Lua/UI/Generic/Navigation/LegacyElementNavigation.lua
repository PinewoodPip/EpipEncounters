
---------------------------------------------
-- Contains utility functions to aid with navigating legacy Generic elements.
-- Intended to aid with creation of components for prefabs or UIs that depend on these elements.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation

---@class GenericUI.Navigation.LegacyElementNavigation : Class
local LegacyNavigation = {
    Events = {
        ElementFocusChanged = SubscribableEvent:New("ElementInteracted"), ---@type Event<{Element:GenericUI.Navigation.LegacyElementNavigation.ElementType, Focused:boolean}>
        ElementInteracted = SubscribableEvent:New("ElementInteracted"), ---@type Event<{Element:GenericUI.Navigation.LegacyElementNavigation.ElementType}>
    }
}
Navigation:RegisterClass("GenericUI.Navigation.LegacyElementNavigation", LegacyNavigation)

---@alias GenericUI.Navigation.LegacyElementNavigation.ElementType GenericUI_Element_Button|GenericUI_Element_StateButton|GenericUI_Element_ComboBox

---------------------------------------------
-- METHODS
---------------------------------------------

---Interacts with a legacy element.
---@see GenericUI.Navigation.LegacyElementNavigation.ElementType
---@param element GenericUI.Navigation.LegacyElementNavigation.ElementType Must be a legacy element.
function LegacyNavigation.InteractWith(element)
    LegacyNavigation.Events.ElementInteracted:Throw({
        Element = element,
    })
end

---Sets focus-related visuals on an element.
---@see GenericUI.Navigation.LegacyElementNavigation.ElementType
---@param element GenericUI.Navigation.LegacyElementNavigation.ElementType Must be a legacy element.
---@param focused boolean
function LegacyNavigation.SetFocus(element, focused)
    LegacyNavigation.Events.ElementFocusChanged:Throw({
        Element = element,
        Focused = focused,
    })
end

---Scrolls the selection within a focused and opened combobox.
---@param comboBox GenericUI_Element_ComboBox
---@param direction 1|-1
function LegacyNavigation.ScrollComboBox(comboBox, direction)
    local mc = comboBox:GetMovieClip()
    local options = comboBox:GetOptions()
    local newIndex = mc.selectedIndex + direction
    mc.selectedIndex = newIndex % #options
end

---Changes the value of a slider by 1 step.
---@param slider GenericUI_Element_Slider
---@param direction 1|-1
function LegacyNavigation.AdjustSlider(slider, direction)
    local min, max = slider:GetRange()
    slider:SetValue(math.clamp(slider:GetValue() + direction * slider:GetStep(), min, max))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementations of FocusChanged and ElementInteracted for Button.
LegacyNavigation.Events.ElementInteracted:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_Button" then
        ---@cast element GenericUI_Element_Button
        element.Events.Pressed:Throw()
    end
end, {StringID = "DefaultImplementation.Button"})
LegacyNavigation.Events.ElementFocusChanged:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_Button" then
        ---@cast element GenericUI_Element_Button
        local mc = element:GetMovieClip()
        if ev.Focused then
            mc.onMouseOver()
        else
            mc.onMouseOut()
        end
    end
end, {StringID = "DefaultImplementation.Button"})

-- Default implementations of FocusChanged and ElementInteracted for StateButton.
LegacyNavigation.Events.ElementInteracted:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_StateButton" then
        ---@cast element GenericUI_Element_StateButton
        local mc = element:GetMovieClip()
        mc.setActive(not mc.m_Active)
    end
end, {StringID = "DefaultImplementation.StateButton"})
LegacyNavigation.Events.ElementFocusChanged:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_StateButton" then
        ---@cast element GenericUI_Element_StateButton
        local mc = element:GetMovieClip()
        if ev.Focused then
            mc.onMouseOver()
        else
            mc.onMouseOut()
        end
    end
end, {StringID = "DefaultImplementation.StateButton"})

-- Default implementations of FocusChanged ElementInteracted for ComboBox.
LegacyNavigation.Events.ElementInteracted:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_ComboBox" then
        ---@cast element GenericUI_Element_ComboBox
        local mc = element:GetMovieClip()
        if element:IsOpen() then
            local selectedIndex = mc.selectedIndex
            element.Events.OptionSelected:Throw({
                Option = element:GetOptions()[selectedIndex + 1],
                Index = selectedIndex,
            })
            mc.close()
        else
            mc.open()
        end
    end
end, {StringID = "DefaultImplementation.ComboBox"})
LegacyNavigation.Events.ElementFocusChanged:Subscribe(function (ev)
    local element = ev.Element
    if element.Type == "GenericUI_Element_ComboBox" then
        ---@cast element GenericUI_Element_ComboBox
        local mc = element:GetMovieClip()
        if ev.Focused then
            mc.topOver()
        else
            mc.topOut()
        end
    end
end, {StringID = "DefaultImplementation.ComboBox"})
