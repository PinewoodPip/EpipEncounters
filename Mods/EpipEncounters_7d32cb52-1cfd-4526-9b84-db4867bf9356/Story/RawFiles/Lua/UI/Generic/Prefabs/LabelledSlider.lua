
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledSlider : GenericUI_Prefab_FormElement
---@field Slider GenericUI_Element_Slider
local Slider = {
    Events = {
        HandleReleased = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleReleased>
    }
}
OOP.SetMetatable(Slider, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_LabelledSlider", Slider)

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
    local instance = Slider:_Create(ui, id) ---@type GenericUI_Prefab_LabelledSlider
    instance:__SetupBackground(parent, size)

    instance:SetLabel(label)

    local slider = instance:CreateElement("Slider", "GenericUI_Element_Slider", instance:GetRootElement())
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetStep(step)

    -- Forward events.
    slider.Events.HandleReleased:Subscribe(function (ev)
        instance.Events.HandleReleased:Throw(ev)
    end)

    instance.Slider = slider

    return instance
end