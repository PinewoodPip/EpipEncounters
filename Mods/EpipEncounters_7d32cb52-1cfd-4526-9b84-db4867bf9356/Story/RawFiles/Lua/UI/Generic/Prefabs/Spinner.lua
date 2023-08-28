
---------------------------------------------
-- Implements a Spinner form element, where
-- the user may alter a numeric value through -/+ buttons.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

---@class GenericUI_Prefab_Spinner : GenericUI_Prefab, GenericUI_I_Elementable
---@field Background GenericUI_Element_TiledBackground
---@field Label GenericUI_Element_Text
---@field CounterText GenericUI_Element_Text
---@field PlusButton GenericUI_Element_Button
---@field MinusButton GenericUI_Element_Button
---@field Size Vector2
local Spinner = {
    DEFAULT_SIZE = V(200, 30),
    LIST_SIZE = V(100, 30),
    COUNTER_TEXT_SIZE = V(50, 30),

    minValue = 0,
    maxValue = math.maxinteger,
    step = 1,
    currentValue = 0,

    Events = {
        ValueChanged = {}, ---@type Event<Events.ValueEvent> Thrown when the value is changed **by the user**.
    }
}
Generic:RegisterClass("GenericUI_Prefab_Spinner", Spinner, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI_Prefab_Spinner", Spinner)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Spinner"

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
---@param size Vector2? Defaults to `DEFAULT_SIZE`.
---@return GenericUI_Prefab_Spinner
function Spinner.Create(ui, id, parent, label, min, max, step, size)
    min = min or 0
    max = max or math.maxinteger
    step = step or 1

    local spinner = Spinner:_Create(ui, id, ui, parent, label) ---@cast spinner GenericUI_Prefab_Spinner

    spinner.Size = size or Spinner.DEFAULT_SIZE
    spinner.currentValue = min

    spinner:_Init(ui, parent, label)
    spinner:SetBounds(min, max, step)

    return spinner
end

---Returns the current value of the spinner.
---@return number
function Spinner:GetValue()
    return self.currentValue
end

---Sets the value of the spinner. Ignores min/max bounds or step, but will be floored if step is an integer.
---Does not fire events.
---@param value number
function Spinner:SetValue(value)
    if self.step % 1 == 0 then
        value = math.floor(value)
    end

    self.currentValue = value

    self:_UpdateCounter()
end

---Adds to the current value. **Throws the ValueChanged event.**
---@param val number
---@return number -- New value.
function Spinner:AddValue(val)
    local value = self:GetValue()

    value = Ext.Math.Clamp(value + val, self.minValue, self.maxValue)

    self.currentValue = value

    self:_UpdateCounter()

    -- Throw event
    self.Events.ValueChanged:Throw({Value = value})

    return value
end

---Increments the value on the spinner by the step. **Throws the ValueChanged event.**
---@return number
function Spinner:Increment()
    return self:AddValue(self.step)
end

---Decrements the value on the spinner by the step. **Throws the ValueChanged event.**
---@return number
function Spinner:Decrement()
    return self:AddValue(-self.step)
end

---@param ui GenericUI_Instance
---@param parent (GenericUI_Element|string)?
---@param label string
function Spinner:_Init(ui, parent, label)
    local container = ui:CreateElement(self:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetAlpha(0.4) -- TODO use FormElement

    local list = container:AddChild(self:PrefixID("List"), "GenericUI_Element_HorizontalList")
    list:SetSize(self.LIST_SIZE:unpack())

    local text = TextPrefab.Create(ui, self:PrefixID("Label"), container, Text.Format(label, {Color = Color.WHITE}), "Left", self.Size)

    local minusButton = list:AddChild(self:PrefixID("Minus"), "GenericUI_Element_Button")
    minusButton:SetType("StatMinus")
    minusButton:SetCenterInLists(true)

    local amountText = TextPrefab.Create(ui, self:PrefixID("CounterText"), list, "", "Center", self.COUNTER_TEXT_SIZE)

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

    self.Background = container
    self.Label = text
    self.CounterText = amountText
    self.PlusButton = plusButton
    self.MinusButton = minusButton
    self.ButtonList = list

    self:SetSize(self.Size:unpack())
end

---Sets the bounds of the allowed values on the spinner and clamps the current value to the new valid range.
---@param min number? Defaults to current.
---@param max number? Defaults to current.
---@param step number? Defaults to current.
function Spinner:SetBounds(min, max, step)
    min = min or self.minValue
    max = max or self.maxValue
    step = step or self.step

    self.minValue = min
    self.maxValue = max
    self.step = step

    self:SetValue(Ext.Math.Clamp(self.currentValue, min, max))
end

---@param width number
---@param height number
function Spinner:SetSize(width, height)
    local bg = self.Background
    bg:SetBackground("Black", width, height)

    self.Label:SetSize(width, 30) -- TODO extrct
    self.Label:SetPositionRelativeToParent("Left")
    self.ButtonList:SetPositionRelativeToParent("Right")
end

---Updates the counter label.
function Spinner:_UpdateCounter()
    local value = self:GetValue() ---@type number|string
    local text = self.CounterText
    if self.step == 1 then
        value = Text.RemoveTrailingZeros(value)
    end

    text:SetText(Text.Format(tostring(value), {Color = Color.WHITE}))
end

---@override
function Spinner:GetRootElement()
    return self.Background
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------