
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
    Object = {Type = "None"}, ---@type GenericUI_Prefab_HotbarSlot_Object
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

    obj:Clear()

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

function Slot:SetItem(item)
    local slot = self.SlotElement
    slot:SetIcon(item.RootTemplate.Icon, 50, 50)
    slot:SetCooldown(0, false)

    self.Object = {
        Type = "Item",
        Item = item, -- TODO change to handle
    }
end

function Slot:Clear()
    local slot = self.SlotElement
    slot:SetIcon("", 1, 1)
    slot:SetCooldown(0, false)
    slot:SetEnabled(true)

    self.Object = {
        Type = "None",
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
    else
        local item = Ext.Entity.GetItem(data.DragObject)

        if item then
            self:SetItem(item)
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
    elseif obj.Type == "Item" then
        local label = ""
        local item = obj.Item
        local isEnabled = true
        if item.Amount > 1 then label = tostring(item.Amount) end

        slot:SetLabel(label)
        slot:SetCooldown(0, false)

        if item.Stats then
            isEnabled = Game.Stats.MeetsRequirements(char, item.Stats.Name, true, item)
        end

        -- Item skills
        local useActions = item.RootTemplate.OnUsePeaceActions
        for _,action in ipairs(useActions) do
            if action.Type == "UseSkill" and isEnabled then
                isEnabled = isEnabled and Character.CanUseSkill(char, action.SkillID, item)
            end
        end

        slot:SetEnabled(isEnabled)
    end
end

function Slot:_OnSlotClicked(e)
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object
    
    if obj.Type == "Skill" then
        Client.UI.Hotbar.UseSkill(obj.StatsID)
    elseif obj.Type == "Item" then
        Client.UI.Hotbar.UseSkill(obj.Item)
    end
end

function Slot:_OnSlotDragStarted(e)
    local obj = self.Object

    if obj.Type == "Skill" then
        Ext.UI.GetDragDrop():StartDraggingName(1, obj.StatsID)
    elseif obj.Type == "Item" then
        Ext.UI.GetDragDrop():StartDraggingObject(1, obj.Item.Handle)
    end

    self:Clear()
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterPrefab("HotbarSlot", Slot)