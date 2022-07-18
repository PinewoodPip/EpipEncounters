
---@class GenericUI
local Generic = Client.UI.Generic
local Hotbar = Client.UI.Hotbar

---@class GenericUI_Prefab_HotbarSlot_Object
---@field Type "None"|"Skill"|"Item"|"Action"
---@field StatsID string? Only for skills/actions.
---@field Item EclItem? Only for items.

---@class GenericUI_Prefab_HotbarSlot
local Slot = {
    ID = nil, ---@type string
    SlotElement = nil, ---@type GenericUI_Element_Slot
    Object = {}, ---@type GenericUI_Prefab_HotbarSlot_Object
    Events = {
        ---@type SubscribableEvent<GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn>
        ObjectDraggedIn = {},
    }
}
Generic.PREFABS.Slot = Slot

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn
---@field Object GenericUI_Prefab_HotbarSlot_Object

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element
---@return GenericUI_Prefab_HotbarSlot
function Slot.Create(ui, id, parent)
    ---@type GenericUI_Prefab_HotbarSlot
    local obj = {
        ID = id,
        SlotElement = ui:CreateElement(id, "Slot", parent),
    }
    Inherit(obj, Slot)
    obj:_RegisterEvents()

    obj.SlotElement.Events.MouseUp:Subscribe(function (e) obj:_OnElementMouseUp(e) end)
    obj.SlotElement.Events.Clicked:Subscribe(function (e) obj:_OnSlotClicked(e) end)
    obj.SlotElement.Events.DragStarted:Subscribe(function(e) obj:_OnSlotDragStarted(e) end)
    Ext.Events.Tick:Subscribe(function() obj:_OnTick() end)

    return obj
end

-- TODO separate table for prefabs
function Slot:_RegisterEvents()
    local _Templates = self.Events
    
    self.Events = {}

    for id,_ in pairs(_Templates) do
        self.Events[id] = SubscribableEvent:New(id)
    end
end

---@param skillID string
function Slot:SetSkill(skillID)
    local stat = Stats.Get("Skill", skillID)
    local slot = self.SlotElement

    slot:SetIcon(stat.Icon, 50, 50)

    self.Object = {
        Type = "Skill",
        StatsID = skillID,
    }
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

function Slot:_OnElementMouseUp(e)
    local data = Ext.UI.GetDragDrop().PlayerDragDrops[1]
    local objectID = data.DragId

    if objectID ~= "" then
        local skill = Stats.Get("Skill", objectID)

        if skill then
            self:SetSkill(objectID)
        end
    end
end

function Slot:_OnTick()
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object

    if obj.Type == "Skill" then
        local skill = char.SkillManager.Skills[obj.StatsID]
        local cooldown = 0
        local enabled = false

        if skill then
            cooldown = skill.ActiveCooldown / 6
            enabled = Character.CanUseSkill(char, obj.StatsID)
        end

        slot:SetLabel("")
        slot:SetCooldown(cooldown, true)
        slot:SetEnabled(enabled)
    end
end

function Slot:_OnSlotClicked(e)
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object
    
    if obj.Type == "Skill" then
        Client.UI.Hotbar.UseSkill(obj.StatsID)
    end
end

function Slot:_OnSlotDragStarted(e)
    local obj = self.Object

    if obj.Type == "Skill" then
        print("Dragging!")
        Ext.UI.GetDragDrop():StartDraggingName(1, obj.StatsID)
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterPrefab("HotbarSlot", Slot)