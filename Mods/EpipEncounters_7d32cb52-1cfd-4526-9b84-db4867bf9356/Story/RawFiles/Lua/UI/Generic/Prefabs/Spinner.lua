
---------------------------------------------
-- Implements a Spinner form element, where
-- the user may alter a numeric value through -/+ buttons.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local V = Vector.Create

---@class GenericUI_Prefab_Spinner : GenericUI_Prefab_FormElement, GenericUI_I_Stylable
---@field Background GenericUI_Element_TiledBackground
---@field Label GenericUI_Element_Text
---@field CounterText GenericUI_Element_Text
---@field PlusButton GenericUI_Prefab_Button
---@field MinusButton GenericUI_Prefab_Button
---@field Size Vector2
---@field __Style GenericUI.Prefabs.Spinner.Style
local Spinner = {
    DEFAULT_SIZE = V(200, 30),
    LIST_SIZE = V(100, 30),
    LABEL_HEIGHT = 30,

    minValue = 0,
    maxValue = math.maxinteger,
    step = 1,
    currentValue = 0,

    Events = {
        ValueChanged = {}, ---@type Event<Events.ValueEvent> Thrown when the value is changed **by the user**.
    },
    Hooks = {
        GetValueLabel = {}, ---@type Hook<GenericUI.Prefabs.Spinner.Hooks.GetValueLabel>
    },
}
Generic:RegisterClass("GenericUI_Prefab_Spinner", Spinner, {"GenericUI_Prefab_FormElement", "GenericUI_I_Stylable"})
Generic.RegisterPrefab("GenericUI_Prefab_Spinner", Spinner)

-- TODO extract to separate script
---@type GenericUI.Prefabs.Spinner.Style
Spinner.DEFAULT_STYLE = {
    PlusButtonStyle = ButtonPrefab:GetStyle("IncrementCharacterSheet"),
    MinusButtonStyle = ButtonPrefab:GetStyle("DecrementCharacterSheet"),
    AmountLabelSize = V(50, 30),
}
Spinner:RegisterStyle("Default", Spinner.DEFAULT_STYLE)
Spinner:RegisterStyle("DOS1Large", {
    PlusButtonStyle = ButtonPrefab:GetStyle("DOS1IncrementLarge"),
    MinusButtonStyle = ButtonPrefab:GetStyle("DOS1DecrementLarge"),
    AmountLabelSize = V(75, 30),
})

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Spinner"

---@class GenericUI.Prefabs.Spinner.Style : GenericUI_I_Stylable_Style
---@field MinusButtonStyle GenericUI_Prefab_Button_Style
---@field PlusButtonStyle GenericUI_Prefab_Button_Style
---@field AmountLabelSize Vector2

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class GenericUI.Prefabs.Spinner.Hooks.GetValueLabel
---@field Label string Hookable. Defaults to stringified value with trailing zeros removed and white color applied.
---@field Color htmlcolor? Hookable. Will be applied afterwards. Defaults to white.
---@field Value number

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
---@param style GenericUI.Prefabs.Spinner.Style? Defaults to `DEFAULT_STYLE`
---@return GenericUI_Prefab_Spinner
function Spinner.Create(ui, id, parent, label, min, max, step, size, style)
    min = min or 0
    max = max or math.maxinteger
    step = step or 1
    size = size or Spinner.DEFAULT_SIZE
    style = style or Spinner.DEFAULT_STYLE

    local spinner = Spinner:_Create(ui, id, ui, parent, label) ---@cast spinner GenericUI_Prefab_Spinner
    spinner.Size = size
    spinner.currentValue = min
    spinner.__Style = style -- Should be set before running Init().

    spinner:__SetupBackground(parent, size)
    spinner:_Init(ui)
    spinner:SetLabel(label)
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
function Spinner:_Init(ui)
    local container = self.Background
    local list = container:AddChild(self:PrefixID("List"), "GenericUI_Element_HorizontalList")

    local minusButton = ButtonPrefab.Create(self.UI, self:PrefixID("Minus"), list, self.__Style.MinusButtonStyle)
    minusButton:SetCenterInLists(true)

    local amountText = TextPrefab.Create(ui, self:PrefixID("CounterText"), list, "", "Center", self.__Style.AmountLabelSize)
    amountText:SetCenterInLists(true)

    local plusButton = ButtonPrefab.Create(self.UI, self:PrefixID("Plus"), list, self.__Style.PlusButtonStyle)
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
    self:SetBackgroundSize(Vector.Create(width, height))
    self:_UpdateList()
end

---Updates the counter label.
function Spinner:_UpdateCounter()
    local value = self:GetValue() ---@type number|string
    local valueLabel = tostring(value)
    local text = self.CounterText

    -- Remove trailing zeros for integer-only spinners
    -- TODO this assumes min/max is an integer as well.
    if self.step == 1 then
        value = Text.RemoveTrailingZeros(value)
    end

    -- Get final label and text color from hooks.
    local hook = self.Hooks.GetValueLabel:Throw({
        Label = valueLabel,
        Color = Color.WHITE,
        Value = value,
    })
    valueLabel = Text.Format(hook.Label, {
        Color = hook.Color,
    })

    text:SetText(valueLabel)
end

---Updates appearances of buttons based on set style.
function Spinner:_UpdateButtons()
    local style = self.__Style
    self.PlusButton:SetStyle(style.PlusButtonStyle)
    self.MinusButton:SetStyle(style.MinusButtonStyle)
    self:_UpdateList()
end

---Updates the positioning of the spinner button & value label list.
function Spinner:_UpdateList()
    self.ButtonList:RepositionElements()
    self.ButtonList:SetPositionRelativeToParent("Right", -self.LABEL_SIDE_MARGIN)
end

---@override
function Spinner:GetRootElement()
    return self.Background
end

---@override
function Spinner:__OnStyleChanged()
    self:_UpdateButtons()
end
