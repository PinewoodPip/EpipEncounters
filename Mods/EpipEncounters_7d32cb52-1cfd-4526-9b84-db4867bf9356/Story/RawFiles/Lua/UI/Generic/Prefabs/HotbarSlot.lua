
---@class GenericUI
local Generic = Client.UI.Generic
local Hotbar = Client.UI.Hotbar

---@class GenericUI_Prefab_HotbarSlot : GenericUI_Prefab
local Slot = {
    ID = nil, ---@type string
    SlotElement = nil, ---@type GenericUI_Element_Slot
    Object = nil, ---@type GenericUI_Prefab_HotbarSlot_Object
    Events = {
        ---@type SubscribableEvent<GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn>
        ObjectDraggedIn = {}, -- TODO!
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_HotbarSlot", Slot)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias GenericUI_Prefab_HotbarSlot_Object_Type "None"|"Skill"|"Item"|"Action"|"Template"

---@class GenericUI_Prefab_HotbarSlot_Object
---@field Type GenericUI_Prefab_HotbarSlot_Object_Type
---@field StatsID string? Only for skills/actions.
---@field ItemHandle EntityHandle? Only for items.
---@field TemplateID GUID? Only for templates.
local _SlotObject = {}

---@param type GenericUI_Prefab_HotbarSlot_Object_Type
---@param data GenericUI_Prefab_HotbarSlot_Object?
---@return GenericUI_Prefab_HotbarSlot_Object
function _SlotObject.Create(type, data)
    local obj = table.deepCopy(data or {}) ---@type GenericUI_Prefab_HotbarSlot_Object
    obj.Type = type
    Inherit(obj, _SlotObject)

    return obj
end

---@return EclItem|StatsSkillPrototype|StatsLib_Action
function _SlotObject:GetEntity()
    if self.Type == "Skill" then
        return Stats.Get("SkillData", self.StatsID)
    elseif self.Type == "Action" then
        Ext.PrintError("_SlotObject:GetEntity() not implemented for Actions!!!!")
    elseif self.Type == "Template" or self.Type == "Item" then
        local item

        if self.ItemHandle then
            item = Item.Get(self.ItemHandle) ---@type EclItem
        end

        -- Fetch the first item with this template instead.
        if not item then
            self.ItemHandle = nil -- Clear invalid handles

            item = Item.GetItemsInPartyInventory(Client.GetCharacter(), function(i)
                return i.RootTemplate.Id == self.TemplateID
            end)[1]
        end

        return item
    end
end

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
    local obj = Slot:_Create(ui, id)
    obj.SlotElement = ui:CreateElement(id, "Slot", parent)

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
    GameState.Events.RunningTick:Subscribe(function (e)
        obj:_OnTick()
    end)

    return obj
end

---@param obj GenericUI_Prefab_HotbarSlot_Object
function Slot:SetObject(obj)
    if obj.Type == "Skill" then
        self:SetSkill(obj.StatsID)
    elseif obj.Type == "Template" then
        self:SetTemplate(obj.TemplateID)
    elseif obj.Type == "Item" then
        -- TODO
        Ext.PrintWarning("SetObject() with object type Item not supported")
    else
        self:Clear()
    end
end

---@param skillID string
function Slot:SetSkill(skillID)
    local stat = Stats.Get("SkillData", skillID)
    local slot = self.SlotElement

    slot:SetIcon(stat.Icon, 50, 50)
    slot:SetSourceBorder(stat["Magic Cost"] > 0)

    self.Object = _SlotObject.Create("Skill", {StatsID = skillID})

    slot.Tooltip = {
        Type = "Skill",
        SkillID = skillID,
        Spacing = {10, 0},
    }
end

---@param item EclItem
function Slot:SetItem(item)
    local slot = self.SlotElement
    slot:SetIcon(item.RootTemplate.Icon, 50, 50)
    slot:SetCooldown(0, false)

    self.Object = _SlotObject.Create("Item", {ItemHandle = item.Handle})

    slot.Tooltip = nil
end

---@param templateID GUID
function Slot:SetTemplate(templateID)
    local slot = self.SlotElement
    local template = Ext.Template.GetTemplate(templateID)

    if template then
        self.Object = _SlotObject.Create("Template", {TemplateID = templateID})

        slot:SetIcon(template.Icon, 50, 50)
        slot:SetCooldown(-1, false)

        slot.Tooltip = nil
    end
end

function Slot:Clear()
    local slot = self.SlotElement
    slot:SetIcon("", 1, 1)
    slot:SetCooldown(-1, false)
    slot:SetEnabled(false)
    slot:SetLabel("")

    self.Object = _SlotObject.Create("None")
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
        local item = Item.Get(data.DragObject)

        if item then
            self:SetTemplate(item.RootTemplate.Id)
            self.Object.ItemHandle = item.Handle -- For dragging purposes only.
        end
    end
end

function Slot:_OnTick()
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object
    local preparedSkill = Client.UI.Hotbar.GetPreparedSkill(char)
    local isPreparingSkill = false

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

        if preparedSkill and not preparedSkill.Casting and preparedSkill.SkillID == obj.StatsID then
            isPreparingSkill = true
        end
    elseif obj.Type == "Item" or obj.Type == "Template" then
        local item = obj:GetEntity()

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

    slot:SetActive(isPreparingSkill)
end

function Slot:_OnSlotClicked(e)
    local char = Client.GetCharacter()
    local slot = self.SlotElement
    local obj = self.Object
    
    if obj.Type == "Skill" then
        Client.UI.Hotbar.UseSkill(obj.StatsID)
    elseif obj.Type == "Item" or obj.Type == "Template" then
        local item = obj:GetEntity()

        Client.UI.Hotbar.UseSkill(item)
    end
end

function Slot:_OnSlotDragStarted(e)
    local obj = self.Object

    if obj.Type == "Skill" then
        Ext.UI.GetDragDrop():StartDraggingName(1, obj.StatsID)
    elseif obj.Type == "Item" then
        Ext.UI.GetDragDrop():StartDraggingObject(1, obj.ItemHandle)
    elseif obj.Type == "Template" then
        local item = obj:GetEntity()

        Ext.UI.GetDragDrop():StartDraggingObject(1, item.Handle)
    end

    -- Play dragging sound
    self.UI:PlaySound("UI_Game_PartyFormation_PickUp")

    self:Clear()
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterPrefab("HotbarSlot", Slot)