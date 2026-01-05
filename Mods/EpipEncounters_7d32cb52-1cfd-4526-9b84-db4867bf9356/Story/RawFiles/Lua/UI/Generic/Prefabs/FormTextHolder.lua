
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefabs.FormTextHolder : GenericUI_Prefab_FormElement, GenericUI_I_Elementable
---@field FieldList GenericUI_Element_HorizontalList
local FormTextHolder = {
    FIELD_SIZE = Vector.Create(250, 50),
    FIELD_ALPHA = {
        FOCUSED = 0.9,
        UNFOCUSED = 0.5,
    },

    Events = {
        FieldClicked = {}, ---@type Event<GenericUI.Prefabs.FormTextHolder.Events.FieldClicked>
    }
}
Generic:RegisterClass("GenericUI.Prefabs.FormTextHolder", FormTextHolder, {"GenericUI_Prefab_FormElement", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.FormTextHolder", FormTextHolder)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.FormTextHolder"

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class GenericUI.Prefabs.FormTextHolder.Events.FieldClicked
---@field Index integer
---@field CurrentText string

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new FormTextHolder.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI.Prefabs.FormTextHolder
function FormTextHolder.Create(ui, id, parent, label, size)
    local instance = FormTextHolder:_Create(ui, id) ---@type GenericUI.Prefabs.FormTextHolder
    instance:__SetupBackground(parent, size or FormTextHolder.DEFAULT_SIZE)
    instance:SetLabel(label)

    local list = instance:CreateElement("FieldList", "GenericUI_Element_HorizontalList", instance.Background)

    instance.FieldList = list

    return instance
end

---Sets the text fields displayed.
---@param fields string[]
function FormTextHolder:SetFields(fields)
    local list = self.FieldList
    list:Clear() -- TODO optimize

    for i,field in ipairs(fields) do
        local bg = self:CreateElement("Field_" .. tostring(i), "GenericUI_Element_TiledBackground", list)
        bg:SetBackground("Black", self.FIELD_SIZE:unpack())
        bg:SetAlpha(self.FIELD_ALPHA.UNFOCUSED)
        local label = TextPrefab.Create(self.UI, self:PrefixID("Field_" .. tostring(i) .. "_Label"), bg, field, "Center", self.FIELD_SIZE)
        label:SetSize(self.FIELD_SIZE[1], label:GetTextSize()[2])
        label:SetPositionRelativeToParent("Center")

        -- Forward click event
        bg.Events.MouseUp:Subscribe(function (_)
            self.Events.FieldClicked:Throw({
                Index = i,
                CurrentText = field,
            })
        end)

        -- Highlight the field when hovered
        bg.Events.MouseOver:Subscribe(function (_)
            bg:SetAlpha(self.FIELD_ALPHA.FOCUSED)
        end)
        bg.Events.MouseOut:Subscribe(function (_)
            bg:SetAlpha(self.FIELD_ALPHA.UNFOCUSED)
        end)
    end

    list:RepositionElements()
    list:SetPositionRelativeToParent("Right")
end