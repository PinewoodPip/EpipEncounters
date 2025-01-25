
---------------------------------------------
-- A form element that displays a color and its HTML code.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefab.Form.Color : GenericUI_Prefab_FormElement
---@field ColorList GenericUI_Element_HorizontalList
---@field ColorLabel GenericUI_Prefab_Text
---@field Color GenericUI_Element_Color
local FormColor = {
    Events = {
        ColorClicked = {}, ---@type Event<Empty>
    },
}
OOP.SetMetatable(FormColor, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI.Prefab.Form.Color", FormColor)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefab.Form.Color"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a color form.
---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI.Prefab.Form.Color
function FormColor.Create(ui, id, parent, label, size)
    size = size or FormColor.DEFAULT_SIZE
    local obj = FormColor:_Create(ui, id) ---@cast obj GenericUI.Prefab.Form.Color
    obj:__SetupBackground(parent, size)
    obj:SetLabel(label)

    local rightList = obj:AddChild("ColorList", "GenericUI_Element_HorizontalList")
    obj.ColorList = rightList

    local colorLabel = TextPrefab.Create(ui, obj:PrefixID("ColorLabel"), rightList, "", "Right", Vector.Create(100, 40))
    obj.ColorLabel = colorLabel

    local color = rightList:AddChild(obj:PrefixID("Color"), "GenericUI_Element_Color")
    obj.Color = color

    obj:SetSize(size:unpack())

    -- Forward events
    color.Events.MouseUp:Subscribe(function (ev)
        obj.Events.ColorClicked:Throw(ev)
    end)

    -- Extend navigation
    local root = obj:GetRootElement() ---@cast root +GenericUI.Navigation.Component.Target
    local component = root.___Component
    if component then
        component.Hooks.ConsumeInput:Subscribe(function (ev)
            if ev.Event.Timing == "Up" and ev.Action.ID == "Interact" then
                color.Events.MouseUp:Throw() -- Interact with the color.
                ev.Consumed = true
                ev:StopPropagation()
            end
        end, {Priority = 999})
    end

    return obj
end

---Sets the displayed color.
---@param color RGBColor
function FormColor:SetColor(color)
    self.Color:SetColor(color)
    self.ColorLabel:SetText(color:ToHex(true))
    self.ColorLabel:FitSize()

    -- Reposition list
    local list = self.ColorList
    list:RepositionElements()
    list:SetPositionRelativeToParent("Right")
end

---Sets the size of the form.
---@param width number
---@param height number
function FormColor:SetSize(width, height)
    local labelElement = self.Label
    local list = self.ColorList

    self:SetBackgroundSize(Vector.Create(width, height))

    labelElement:SetSize(width, 30)
    labelElement:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN, 0)

    list:RepositionElements()
    list:SetPositionRelativeToParent("Right")
end

---@override
function FormColor:GetInteractableElement()
    return self.Color
end
