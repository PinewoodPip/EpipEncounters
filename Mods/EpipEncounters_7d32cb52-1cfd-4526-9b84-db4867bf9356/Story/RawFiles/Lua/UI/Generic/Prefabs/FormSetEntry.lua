
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_FormSetEntry : GenericUI_Prefab_FormElement
---@field RemoveButton GenericUI_Element_Button
local Prefab = {
    Events = {
        RemovePressed = {}, ---@type Event<EmptyEvent>
    }
}
Inherit(Prefab, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_FormSetEntry", Prefab)


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
    local instance = Prefab:_Create(ui, id) ---@type GenericUI_Prefab_FormSetEntry

    instance:__SetupBackground(parent, minimumSize)
    instance:SetLabel(label)

    local button = instance:CreateElement("RemoveButton", "GenericUI_Element_Button", instance.Background)
    button:SetType("Close")
    button:SetPositionRelativeToParent("Right", -5)

    button.Events.Pressed:Subscribe(function (_)
        instance.Events.RemovePressed:Throw()
    end)

    return instance
end