
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")

---@class GenericUI.Prefab.Form.Slot : GenericUI_Prefab_FormElement
---@field Slot GenericUI_Prefab_HotbarSlot
local FormSlot = {
    Events = {
        ObjectDraggedIn = {}, ---@type Event<GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn>
        Clicked = {}, ---@type Event<Empty>
    }
}
OOP.SetMetatable(FormSlot, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI.Prefab.Form.Slot", FormSlot)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefab.Form.Slot"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI.Prefab.Form.Slot
function FormSlot.Create(ui, id, parent, label, size)
    size = size or FormSlot.DEFAULT_SIZE
    local obj = FormSlot:_Create(ui, id) ---@cast obj GenericUI.Prefab.Form.Slot
    obj:__SetupBackground(parent, size)
    obj:SetLabel(label)

    local slot = HotbarSlot.Create(ui, obj:PrefixID("Slot"), obj:GetRootElement()) -- TODO RequiredFeatures
    slot:SetUpdateDelay(-1)
    slot:SetEnabled(true)
    obj.Slot = slot

    obj:SetSize(size:unpack())

    -- Forward events
    slot.Events.ObjectDraggedIn:Subscribe(function (ev)
        obj.Events.ObjectDraggedIn:Throw(ev)
    end)
    slot.Events.Clicked:Subscribe(function (ev)
        obj.Events.Clicked:Throw(ev)
    end)

    -- Extend navigation
    local root = obj:GetRootElement() ---@cast root +GenericUI.Navigation.Component.Target
    local component = root.___Component
    if component then
        component.Hooks.ConsumeInput:Subscribe(function (ev)
            if ev.Event.Timing == "Up" and ev.Action.ID == "Interact" then
                slot:Use()
                ev.Consumed = true
                ev:StopPropagation()
            end
        end, {Priority = 999})
    end

    return obj
end

---Sets the size of the form.
---@param width number
---@param height number
function FormSlot:SetSize(width, height)
    local labelElement = self.Label
    local combo = self.Slot

    self:SetBackgroundSize(Vector.Create(width, height))

    labelElement:SetSize(width, 30)
    labelElement:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN, 0)

    combo:SetPositionRelativeToParent("Right")
end

---@override
function FormSlot:GetInteractableElement()
    return self.Slot:GetRootElement()
end
