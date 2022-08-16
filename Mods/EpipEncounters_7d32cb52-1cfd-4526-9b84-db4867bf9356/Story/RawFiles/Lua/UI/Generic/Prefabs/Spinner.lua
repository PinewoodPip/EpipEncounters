
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_Spinner : GenericUI_Prefab
local Spinner = {
    Label = nil, ---@type GenericUI_Element_Text
    CounterText = nil, ---@type GenericUI_Element_Text
    PlusButton = nil, ---@type GenericUI_Element_Button
    MinusButton = nil, ---@type GenericUI_Element_Button

    minValue = 0,
    maxValue = math.maxinteger,
    step = 1,
    currentValue = 0,

    Events = {

    }
}
Generic.RegisterPrefab("GenericUI_Prefab_Spinner", Spinner)

---------------------------------------------
-- EVENTS
---------------------------------------------

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a Spinner element.
---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param min number? Defaults to 0.
---@param max number? Defaults to math.maxinteger.
---@param step number? Defaults to 1.
---@return GenericUI_Prefab_Spinner
function Spinner.Create(ui, id, parent, label, min, max, step)
    min = min or 0
    max = max or math.maxinteger
    step = step or 1

    ---@type GenericUI_Prefab_Spinner
    local spinner = {ID = id}
    Inherit(spinner, Spinner)

    spinner.currentValue = min
    spinner.maxValue = max
    spinner.minValue = min
    spinner.step = step

    spinner:_Setup(ui, parent, label)

    return spinner
end

---@return number
function Spinner:GetValue()
    return self.currentValue
end

---Sets the value of the spinner. Ignores min/max bounds or step.
---@param value number
function Spinner:SetValue(value)
    self.currentValue = value

    self:UpdateCounter()
end

---@return number
function Spinner:Decrement()
    return self:AddValue(-self.step)
end

---@param val number
---@return number New value.
function Spinner:AddValue(val)
    local value = self:GetValue()

    value = value + val
    if value < self.minValue then value = self.minValue end
    if value > self.maxValue then value = self.maxValue end

    self.currentValue = value

    self:UpdateCounter()

    return value
end

---@return number
function Spinner:Increment()
    return self:AddValue(self.step)
end

function Spinner:UpdateCounter()
    local value = self:GetValue()
    local text = self.CounterText

    text:SetText(tostring(value))
end

---@param ui GenericUI_Instance
---@param parent (GenericUI_Element|string)?
---@param label string
function Spinner:_Setup(ui, parent, label)
    self.UI = ui
    self:_SetupEvents()

    local container = ui:CreateElement(self:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetBackground("Black", 200, 30)
    container:SetAlpha(0.2)

    local list = container:AddChild(self:PrefixID("List"), "GenericUI_Element_HorizontalList")
    list:SetSize(100, 30)

    local text = list:AddChild("Text", "GenericUI_Element_Text")
    text:SetText(label)
    text:SetType(0)
    text:SetSize(110, 30)

    local minusButton = list:AddChild(self:PrefixID("Minus"), "GenericUI_Element_Button")
    minusButton:SetType("StatMinus")
    minusButton:SetCenterInLists(true)

    local amountText = list:AddChild(self:PrefixID("AmountText"), "GenericUI_Element_Text")
    amountText:SetText(tostring(self:GetValue()))
    amountText:SetSize(30, 30)

    local plusButton = list:AddChild(self:PrefixID("Plus"), "GenericUI_Element_Button")
    plusButton:SetType("StatPlus")
    plusButton:SetCenterInLists(true)

    list:RepositionElements()

    minusButton.Events.Pressed:Subscribe(function(_)
        self:Decrement()
        list:RepositionElements()
    end)
    plusButton.Events.Pressed:Subscribe(function(_)
        self:Increment()
        list:RepositionElements()
    end)

    self.Label = text
    self.CounterText = amountText
    self.PlusButton = plusButton
    self.MinusButton = minusButton
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------