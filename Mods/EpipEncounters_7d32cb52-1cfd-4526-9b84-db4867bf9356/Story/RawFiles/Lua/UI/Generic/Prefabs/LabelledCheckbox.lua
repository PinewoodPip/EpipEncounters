
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledCheckbox : GenericUI_Prefab_FormElement
---@field Checkbox GenericUI_Element_StateButton
---@field _Style "Right-aligned"|"Left-aligned"
local Checkbox = {
    Events = {
        StateChanged = {}, ---@type Event<GenericUI_Element_StateButton_Event_StateChanged>
    }
}
OOP.RegisterClass("GenericUI_Prefab_LabelledCheckbox", Checkbox, {"GenericUI_Prefab_FormElement"})
Generic.RegisterPrefab("GenericUI_Prefab_LabelledCheckbox", Checkbox)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_LabelledCheckbox"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI_Prefab_LabelledCheckbox
function Checkbox.Create(ui, id, parent, label, size)
    size = size or Checkbox.DEFAULT_SIZE
    local obj = Checkbox:_Create(ui, id) ---@cast obj GenericUI_Prefab_LabelledCheckbox
    obj._Style = "Right-aligned"
    obj:__SetupBackground(parent, size)
    obj:SetLabel(label)

    local checkbox = obj:CreateElement("Checkbox", "GenericUI_Element_StateButton", obj:GetRootElement())
    checkbox:SetType("CheckBox")

    obj.Checkbox = checkbox

    obj:SetSize(600, 50)

    -- Forward events
    checkbox.Events.StateChanged:Subscribe(function (ev)
        obj.Events.StateChanged:Throw(ev)
    end)

    return obj
end

---@param active boolean
function Checkbox:SetState(active)
    self.Checkbox:SetActive(active)
end

-- TODO
-- function Checkbox:IsTicked()
--     return self.Checkbox
-- end

---@param width number
---@param height number
function Checkbox:SetSize(width, height)
    self:SetBackgroundSize(Vector.Create(width, height))
    self.Label:SetSize(width - self.Checkbox:GetMovieClip().width, 30)

    self:Render()
end

---Changes the layout of the element.
---@param style "Right-aligned"|"Left-aligned" Default style is `"Right-aligned"`
function Checkbox:SetStyle(style)
    self._Style = style

    self:Render()
end

---Re-renders the element with the current style.
function Checkbox:Render()
    if self._Style == "Right-aligned" then
        self.Label:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN, 0)
        self.Checkbox:SetPositionRelativeToParent("Right")

    elseif self._Style == "Left-aligned" then
        self.Label:SetPositionRelativeToParent("Right", -self.LABEL_SIDE_MARGIN, 0)
        self.Checkbox:SetPositionRelativeToParent("Left")
    else
        Generic:Error("GenericUI_Prefab_LabelledCheckbox:Render", "Invalid style value")
    end
end