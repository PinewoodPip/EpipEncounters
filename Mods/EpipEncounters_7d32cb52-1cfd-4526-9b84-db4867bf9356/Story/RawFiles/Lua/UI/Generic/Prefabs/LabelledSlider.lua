
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local BackgroundPrefab = Generic.GetPrefab("GenericUI_Prefab_FormElementBackground")

---@class GenericUI_Prefab_LabelledSlider : GenericUI_Prefab
---@field Background GenericUI_Prefab_FormElementBackground
---@field Label GenericUI_Prefab_Text
---@field Slider GenericUI_Element_Slider
local Slider = {
    Events = {
        HandleReleased = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleReleased>
    }
}
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
    
    local bg = BackgroundPrefab.Create(ui, instance:PrefixID("Background"), parent, size)
    local text = TextPrefab.Create(ui, instance:PrefixID("Label"), bg.Background, label, "Left", size)
    local slider = instance:CreateElement("Slider", "GenericUI_Element_Slider")
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetStep(step)

    -- Forward events.
    slider.Events.HandleReleased:Subscribe(function (ev)
        instance.Events.HandleReleased:Throw(ev)
    end)

    instance.Background = bg
    instance.Label = text
    instance.Slider = slider

    return instance
end