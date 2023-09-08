
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_FormSetEntry : GenericUI_Prefab_FormElement
---@field RemoveButton GenericUI_Element_Button
local Prefab = {
    Events = {
        RemovePressed = {}, ---@type Event<EmptyEvent>
    }
}
Generic:RegisterClass("GenericUI_Prefab_FormSetEntry", Prefab, {"GenericUI_Prefab_FormElement"})
Generic.RegisterPrefab("GenericUI_Prefab_FormSetEntry", Prefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormSetEntry"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param minimumSize Vector2
---@return GenericUI_Prefab_FormSetEntry
function Prefab.Create(ui, id, parent, label, minimumSize)
    local instance = Prefab:_Create(ui, id) ---@cast instance GenericUI_Prefab_FormSetEntry

    instance:__SetupBackground(parent, minimumSize)
    instance:SetLabel(label)

    local button = instance:CreateElement("RemoveButton", "GenericUI_Element_Button", instance.Background)
    button:SetType("Close")

    button.Events.Pressed:Subscribe(function (_)
        instance.Events.RemovePressed:Throw()
    end)

    -- Resize the element to fit the text
    local textSize = instance.Label:GetTextSize() + Vector.Create(40, 0)
    textSize = Vector.Create(math.max(minimumSize[1], textSize[1]), 30)

    instance:SetBackgroundSize(textSize)
    instance.Label:SetSize(textSize:unpack())
    instance.Label:SetPositionRelativeToParent("Left")

    -- Needs to be set after determining real background size from text size
    button:SetPositionRelativeToParent("Right", -5)

    return instance
end
