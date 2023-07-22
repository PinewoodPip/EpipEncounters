
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_LabelledSlider : GenericUI_Prefab_FormElement
---@field _MaxDecimals integer
---@field Slider GenericUI_Element_Slider
---@field LeftValueLabel GenericUI_Prefab_Text
---@field RightValueLabel GenericUI_Prefab_Text
---@field CurrentValueLabel GenericUI_Prefab_Text
local Slider = {
    VALUE_LABEL_SIZE = Vector.Create(50, 30),
    DEFAULT_MAX_DECIMALS = 2,

    Events = {
        HandleReleased = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleReleased>
        HandleMoved = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleMoved>
    }
}
OOP.SetMetatable(Slider, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_LabelledSlider", Slider)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_LabelledSlider"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param size Vector2
---@param label string
---@param min number
---@param max number
---@param step number
---@return GenericUI_Prefab_LabelledSlider
function Slider.Create(ui, id, parent, size, label, min, max, step)
    local instance = Slider:_Create(ui, id) ---@cast instance GenericUI_Prefab_LabelledSlider
    instance:__SetupBackground(parent, size)

    instance:SetLabel(label)

    local sliderList = instance:CreateElement("SliderList", "GenericUI_Element_HorizontalList", instance:GetRootElement())

    local leftValueLabel = TextPrefab.Create(ui, instance:PrefixID("LeftValueLabel"), sliderList, "", "Right", instance.VALUE_LABEL_SIZE)
    local slider = instance:CreateElement("Slider", "GenericUI_Element_Slider", sliderList)
    local rightValueLabel = TextPrefab.Create(ui, instance:PrefixID("RightValueLabel"), sliderList, "", "Left", instance.VALUE_LABEL_SIZE)

    leftValueLabel:SetCenterInLists(true)
    slider:SetCenterInLists(true)
    slider:SetSizeOverride(slider:GetWidth(), 30)
    rightValueLabel:SetCenterInLists(true)

    -- Forward events.
    slider.Events.HandleReleased:Subscribe(function (ev)
        instance.Events.HandleReleased:Throw(ev)
        ---@diagnostic disable-next-line: invisible
        instance:_UpdateValueLabel()
    end)
    slider.Events.HandleMoved:Subscribe(function (ev)
        instance.Events.HandleMoved:Throw(ev)
        ---@diagnostic disable-next-line: invisible
        instance:_UpdateValueLabel()
    end)

    local currentValueLabel = TextPrefab.Create(ui, instance:PrefixID("CurrentValueLabel"), slider, "", "Center", instance.VALUE_LABEL_SIZE)
    currentValueLabel:SetWordWrap(false)

    instance.Slider = slider
    instance.LeftValueLabel, instance.RightValueLabel = leftValueLabel, rightValueLabel
    instance.CurrentValueLabel = currentValueLabel

    instance:SetMin(min)
    instance:SetMax(max)
    slider:SetStep(step)
    instance:SetMaxDecimals(instance.DEFAULT_MAX_DECIMALS)

    -- Not sure why both are necessary to get the centering right
    sliderList:SetSize(Vector.Create(sliderList:GetWidth(), size[2]):unpack())
    sliderList:SetSizeOverride(Vector.Create(sliderList:GetWidth(), size[2]):unpack()) -- If we don't set this, reposition elements will use calculated flash height
    sliderList:RepositionElements()
    sliderList:SetPositionRelativeToParent("Right", 0, 0)

    return instance
end

---Sets the minimum value allowed on the slider.
---@param min number
function Slider:SetMin(min)
    local label = self.LeftValueLabel
    label:SetText(Text.RemoveTrailingZeros(min))
    self.Slider:SetMin(min)
end

---Sets the maximum value allowed on the slider.
---@param max number
function Slider:SetMax(max)
    local label = self.RightValueLabel
    label:SetText(Text.RemoveTrailingZeros(max))
    self.Slider:SetMax(max)
end

---Sets the value of the slider.
---@param value number
function Slider:SetValue(value)
    self.Slider:SetValue(value)
    self:_UpdateValueLabel()
end

---Sets the maximum amount of decimal digits to display within the value label.
---Does not affect the possible range of values that can be set.
---@param decimals integer
function Slider:SetMaxDecimals(decimals)
    self._MaxDecimals = decimals
    self:_UpdateValueLabel()
end

---Updates the label showing the current value, repositioning it to stay above the handle, like in vanilla OptionsSettings UI.
function Slider:_UpdateValueLabel()
    local label = self.CurrentValueLabel
    local value = self.Slider:GetValue()
    local referenceElement = self.Slider:GetMovieClip().m_handle_mc

    label:SetText(Text.Round(value, self._MaxDecimals))
    label:SetSize(label:GetTextSize():unpack())
    label:SetPosition(referenceElement.x + 17 - (label:GetTextSize()[1] / 2), referenceElement.y - 25)
end