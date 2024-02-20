
---------------------------------------------
-- A selector form element. Allows choosing from a set of values, and each can be associated with sub-components to be displayed below the selector.
---------------------------------------------

local Generic = Client.UI.Generic
local FormElement = Generic.GetPrefab("GenericUI_Prefab_FormElement")

---@class GenericUI_Prefab_Selector : GenericUI_Prefab_FormElement
---@field ScrollLeftButton GenericUI_Element_Button
---@field ScrollRightButton GenericUI_Element_Button
---@field SubElementsLists GenericUI_Element_VerticalList[]
---@field Options string[]
---@field _CurrentOptionIndex integer
---@field _SelectorLabel string
local Selector = {
    Events = {
        Updated = {}, ---@type Event<GenericUI_Prefab_Selector_Event_Updated>
    }
}
OOP.SetMetatable(Selector, FormElement)
Generic.RegisterPrefab("GenericUI_Prefab_Selector", Selector)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Selector"

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when the selection changes.
---@class GenericUI_Prefab_Selector_Event_Updated
---@field Index integer Index of new selection.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@param options string[]
---@return GenericUI_Prefab_Selector
function Selector.Create(ui, id, parent, label, size, options)
    local instance = Selector:_Create(ui, id) ---@cast instance GenericUI_Prefab_Selector
    instance:__SetupBackground(parent, size)
    instance.Label:SetType("Center")
    instance.Label:SetSize(size[1], 30)
    instance:SetLabel(label)

    instance.Options = options
    instance._SelectorLabel = label
    instance._CurrentOptionIndex = 1
    instance.SubElementsLists = {}

    instance:_SetupSubElementsContainers()
    instance:_SetupButtons()

    instance:SetBackgroundSize(size or instance.DEFAULT_SIZE) -- Necessary as __SetupBackground calls base class method.

    instance:SetSelectedOption(1)

    return instance
end

---Returns the container for subelements of an option's index.
---@param index integer
---@return GenericUI_Element_VerticalList
function Selector:GetSubElementContainer(index)
    if index < 1 or index > #self.Options then
        Generic:Error("Selector:GetSubElementContainer", "Index out of bounds")
    end

    return self.SubElementsLists[index]
end

---Changes the selector's value to the previous or next one.
---@param direction "Left"|"Right"|-1|1
function Selector:Scroll(direction)
    local offset = direction
    if type(direction) == "string" then
        offset = "Left" and -1 or 1
    end
    local newIndex = self._CurrentOptionIndex + offset

    if newIndex < 1 then
        newIndex = #self.Options
    elseif newIndex > #self.Options then
        newIndex = 1
    end

    self:SetSelectedOption(newIndex)
end

---Sets the selected option.
---@param index integer
function Selector:SetSelectedOption(index)
    if index < 1 or index > #self.Options then
        Generic:Error("Selector:SetSelectedOption", "Index out of bounds")
    end

    self._CurrentOptionIndex = index
    self:UpdateSelection()
    self.Events.Updated:Throw({
        Index = self._CurrentOptionIndex
    })
end

---@override
function Selector:SetBackgroundSize(size)
    self._BackgroundSize = size

    FormElement.SetBackgroundSize(self, size)

    self.Label:SetPositionRelativeToParent("Center")
    self.ScrollLeftButton:SetPositionRelativeToParent("Left")
    self.ScrollRightButton:SetPositionRelativeToParent("Right")
end

---Updates the render of the selected option and subelements.
function Selector:UpdateSelection()
    local option = self.Options[self._CurrentOptionIndex]
    local label = Text.Format("%s: %s", {
        FormatArgs = {
            self._SelectorLabel,
            option,
        },
    })

    self:SetLabel(label)

    for i=1,#self.Options,1 do
        self.SubElementsLists[i]:SetVisible(i == self._CurrentOptionIndex)
    end

    -- Set size override to consider the original background and current category.
    self:SetSizeOverride(self._BackgroundSize + self.SubElementsLists[self._CurrentOptionIndex]:GetSize())
end

---Creates the scrolling buttons.
function Selector:_SetupButtons()
    local leftButton = self:CreateElement("ScrollLeftButton", "GenericUI_Element_Button", self.Background)
    local rightButton = self:CreateElement("ScrollRightButton", "GenericUI_Element_Button", self.Background)

    leftButton:SetText(Text.CommonStrings.Previous:GetString(), 2)
    rightButton:SetText(Text.CommonStrings.Next:GetString(), 2)

    leftButton.Events.Pressed:Subscribe(function (_)
        self:Scroll(-1)
    end)
    rightButton.Events.Pressed:Subscribe(function (_)
        self:Scroll(1)
    end)

    self.ScrollLeftButton = leftButton
    self.ScrollRightButton = rightButton
end

function Selector:_SetupSubElementsContainers()
    for i=1,#self.Options,1 do
        local container = self:CreateElement("SubElementsList_" .. i, "GenericUI_Element_VerticalList", self.Background)
        container:SetPosition(0, self.Background:GetHeight())

        self.SubElementsLists[i] = container
    end
end