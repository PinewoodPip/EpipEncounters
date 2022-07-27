
---@class GenericUI
local Generic = Client.UI.Generic
local Hotbar = Client.UI.Hotbar

---@class GenericUI_Prefab_HotbarSlot_Object
---@field Type "None"|"Skill"|"Item"|"Action"|"Template"
---@field StatsID string? Only for skills/actions.
---@field Item EclItem? Only for items.
---@field TemplateID GUID? Only for templates.

---@class GenericUI_Prefab_HotbarSlot : GenericUI_Prefab
local Slot = {
    ID = nil, ---@type string
    SlotElement = nil, ---@type GenericUI_Element_Slot
    Object = {Type = "None"}, ---@type GenericUI_Prefab_HotbarSlot_Object
    Events = {
        ---@type SubscribableEvent<GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn>
        ObjectDraggedIn = {},
    }
}
Inherit(Slot, Generic._Prefab)
Generic.PREFABS.Slot = Slot
Generic.RegisterPrefab("Slot", Slot)

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
    obj:_Setup()

    obj:Clear()

    obj.SlotElement.Events.MouseUp:Subscribe(function (e) obj:_OnElementMouseUp(e) end)
    obj.SlotElement.Events.Clicked:Subscribe(function (e) obj:_OnSlotClicked(e) end)
    obj.SlotElement.Events.DragStarted:Subscribe(function(e) obj:_OnSlotDragStarted(e) end)
    obj.SlotElement.Events.MouseOver:Subscribe(function (e)
        obj.SlotElement:SetHighlighted(true and obj.SlotElement:GetMovieClip().enabled and obj.SlotElement:GetMovieClip().oldCD == 0)
    end)
    obj.SlotElement.Events.MouseOut:Subscribe(function (e)
        obj.SlotElement:SetHighlighted(false)
    end)
    Ext.Events.Tick:Subscribe(function() obj:_OnTick() end)

    return obj
end

---@param skillID string
function Slot:SetSkill(skillID)
    local stat = Stats.Get("SkillData", skillID)
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

---@param templateID GUID
function Slot:SetTemplate(templateID)
    local slot = self.SlotElement
    local template = Ext.Template.GetTemplate(templateID)

    if template then
        self.Object = {
            Type = "Template",
            TemplateID = templateID,
        }

        slot:SetIcon(template.Icon, 50, 50)
        slot:SetCooldown(-1, false)
    end
end

function Slot:Clear()
    local slot = self.SlotElement
    slot:SetIcon("", 1, 1)
    slot:SetCooldown(-1, false)
    slot:SetEnabled(false)

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
        local skill = Stats.Get("SkillData", objectID)

        if skill then
            self:SetSkill(objectID)
        end
    else
        local item = Ext.Entity.GetItem(data.DragObject)

        if item then
            self:SetTemplate(item.RootTemplate.Id)
            self.Object.Item = item -- For dragging purposes only.
        end
    end
end

function Slot:_OnTick()
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object

    if obj.Type == "Skill" then
        local skill = char.SkillManager.Skills[obj.StatsID]
        local cooldown = -1
        local enabled = false

        if skill then
            cooldown = skill.ActiveCooldown / 6
            enabled = Character.CanUseSkill(char, obj.StatsID)
        end

        slot:SetLabel("")
        slot:SetCooldown(cooldown, false)
        slot:SetEnabled(enabled or cooldown > 0)
    elseif obj.Type == "Item" or obj.Type == "Template" then
        local item

        -- Fetch the first item of this template in the party inventory.
        if obj.Type == "Template" then
            item = Item.GetItemsInPartyInventory(char, function(invItem) return invItem.RootTemplate.Id == obj.TemplateID end)[1]
        else
            item = obj.Item
        end

        if item and item.Amount then
            -- We display the total item count in the party inventory.
            local amount = Item.GetPartyTemplateCount(item.RootTemplate.Id)
            local label = ""
            local isEnabled = amount > 0
            if item.Amount > 1 then label = tostring(amount) end

            slot:SetLabel(label)
            slot:SetCooldown(0, false)

            if item.Stats then
                isEnabled = isEnabled and Game.Stats.MeetsRequirements(char, item.Stats.Name, true, item)
            end

            -- Item skills
            local useActions = item.RootTemplate.OnUsePeaceActions
            for _,action in ipairs(useActions) do
                if action.Type == "UseSkill" and isEnabled then
                    isEnabled = isEnabled and Character.CanUseSkill(char, action.SkillID, item)
                end
            end

            slot:SetEnabled(isEnabled)
        else -- Clear the slot once we consume all stacks of this item.
            self:Clear()
        end
    end
end

function Slot:_OnSlotClicked(e)
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object
    
    if obj.Type == "Skill" then
        Client.UI.Hotbar.UseSkill(obj.StatsID)
    elseif obj.Type == "Item" or obj.Type == "Template" then
        local item = obj.Item
        if not item then item = Item.GetItemsInPartyInventory(char, function(i) return i.RootTemplate.Id == obj.TemplateID end)[1] end

        Client.UI.Hotbar.UseSkill(item)
    end
end

function Slot:_OnSlotDragStarted(e)
    local obj = self.Object

    if obj.Type == "Skill" then
        Ext.UI.GetDragDrop():StartDraggingName(1, obj.StatsID)
    elseif obj.Type == "Item" then
        Ext.UI.GetDragDrop():StartDraggingObject(1, obj.Item.Handle)
    elseif obj.Type == "Template" then
        local item = obj.Item
        if not item then item = Item.GetItemsInPartyInventory(Client.GetCharacter(), function(i) return i.RootTemplate.Id == obj.TemplateID end) end

        Ext.UI.GetDragDrop():StartDraggingObject(1, item.Handle)
    end

    self:Clear()
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterPrefab("HotbarSlot", Slot)