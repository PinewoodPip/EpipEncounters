
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledCheckbox : GenericUI_Prefab
---@field _Style "Right-aligned"|"Left-aligned"
local Checkbox = {
    Checkbox = nil, ---@type GenericUI_Element_StateButton
    Label = nil, ---@type GenericUI_Element_Text

    Events = {
        StateChanged = {}, ---@type Event<GenericUI_Element_StateButton_Event_StateChanged>
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_LabelledCheckbox", Checkbox)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@return GenericUI_Prefab_LabelledCheckbox
function Checkbox.Create(ui, id, parent, label)
    local obj = Checkbox:_Create(ui, id) ---@type GenericUI_Prefab_LabelledCheckbox
    obj._Style = "Right-aligned"

    local container = ui:CreateElement(obj:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetAlpha(0.2)

    local text = container:AddChild("Label", "GenericUI_Element_Text")
    text:SetType("Left")
    text:SetText(label)

    local checkbox = container:AddChild("Checkbox", "GenericUI_Element_StateButton")
    checkbox:SetType("CheckBox")

    obj.Checkbox = checkbox
    obj.Label = text

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
    local container = self:GetMainElement() ---@type GenericUI_Element_TiledBackground

    container:SetBackground("Black", width, height)

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
        self.Label:SetPositionRelativeToParent("Left")
        self.Checkbox:SetPositionRelativeToParent("Right")

    elseif self._Style == "Left-aligned" then
        self.Label:SetPositionRelativeToParent("Right")
        self.Checkbox:SetPositionRelativeToParent("Left")
    else
        Generic:Error("GenericUI_Prefab_LabelledCheckbox:Render", "Invalid style value")
    end
    
end