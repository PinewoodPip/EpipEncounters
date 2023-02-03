
---@class GenericUI
local Generic = Client.UI.Generic
local Tooltip = Client.Tooltip
local V = Vector.Create

---@class GenericUI_Prefab_HotbarSlot : GenericUI_Prefab
---@field SlotIcon GenericUI_Element_IggyIcon
---@field RarityIcon GenericUI_Element_IggyIcon
---@field _CanDragDrop boolean
---@field _AutoUpdateDelay number In seconds.
---@field _AutoUpdateRemainingDelay number In seconds.
local Slot = {
    ID = nil, ---@type string
    SlotElement = nil, ---@type GenericUI_Element_Slot
    Object = nil, ---@type GenericUI_Prefab_HotbarSlot_Object

    ICON_SIZE = V(52, 52),

    Events = {
        ObjectDraggedIn = {}, ---@type Event<GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn>
        Clicked = {}, ---@type Event<EmptyEvent>
    },
    Hooks = {
        GetTooltipData = {}, ---@type Event<GenericUI_Prefab_HotbarSlot_Hook_GetTooltipData>
    },
}
Generic.RegisterPrefab("GenericUI_Prefab_HotbarSlot", Slot)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Prefab_HotbarSlot_Event_ObjectDraggedIn
---@field Object GenericUI_Prefab_HotbarSlot_Object

---@class GenericUI_Prefab_HotbarSlot_Hook_GetTooltipData
---@field Position Vector2 Hookable. Defaults to mouse position.
---@field Owner EclCharacter Hookable. Defaults to client character.

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

---Returns the entity assigned to the slot.
---@return EclItem|StatsLib_SkillData|StatsLib_Action
function _SlotObject:GetEntity()
    local entity

    if self.Type == "Skill" then
        entity = Stats.Get("SkillData", self.StatsID)
    elseif self.Type == "Action" then
        entity = Stats.GetAction(self.StatsID)
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

        entity = item
    end

    return entity
end

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
    obj._CanDragDrop = false
    obj._AutoUpdateDelay = 0.1
    obj._AutoUpdateRemainingDelay = obj._AutoUpdateDelay
    obj._Usable = true

    obj.SlotElement = ui:CreateElement(id, "Slot", parent)
    local slot = obj.SlotElement

    local icon = obj:CreateElement("Icon", "GenericUI_Element_IggyIcon", slot)
    obj.SlotIcon = icon
    local iconMC = icon:GetMovieClip()
    iconMC.iggy_mc.y = 1
    iconMC.iggy_mc.x = 1

    local rarityIcon = obj:CreateElement("RarityIcon", "GenericUI_Element_IggyIcon", slot)
    rarityIcon:SetPosition(1, 1)
    obj.RarityIcon = rarityIcon

    ---@diagnostic disable invisible
    slot.Events.MouseUp:Subscribe(function (e) obj:_OnElementMouseUp(e) end)
    slot.Events.Clicked:Subscribe(function (e) obj:_OnSlotClicked(e) end)
    slot.Events.DragStarted:Subscribe(function(_) obj:_OnSlotDragStarted() end)
    slot.Events.MouseOver:Subscribe(function (_)
        obj:_ShowTooltip()
        slot:SetHighlighted(slot:GetMovieClip().enabled and obj.SlotElement:GetMovieClip().oldCD == 0)
    end)
    slot.Events.MouseOut:Subscribe(function (_)
        Tooltip.HideTooltip()
        slot:SetHighlighted(false)
    end)
    GameState.Events.RunningTick:Subscribe(function (ev)
        obj:_OnTick(ev)
    end)
    ---@diagnostic enable invisible

    obj:Clear()

    return obj
end

---@param obj GenericUI_Prefab_HotbarSlot_Object
function Slot:SetObject(obj)
    if obj.Type == "Skill" then
        self:SetSkill(obj.StatsID)
    elseif obj.Type == "Template" then
        self:SetTemplate(obj.TemplateID)
    elseif obj.Type == "Item" then
        self:SetItem(Item.Get(obj.ItemHandle))
    else
        self:Clear()
    end
end

---@param skillID string
function Slot:SetSkill(skillID)
    local stat = Stats.Get("SkillData", skillID)
    local slot = self.SlotElement

    self:SetIcon(stat.Icon)
    slot:SetSourceBorder(stat["Magic Cost"] > 0)

    self.Object = _SlotObject.Create("Skill", {StatsID = skillID})
end

---@param item EclItem
function Slot:SetItem(item)
    local slot = self.SlotElement
    self:SetIcon(Item.GetIcon(item))
    self:SetRarityIcon(item)
    self:SetCooldown(0, false)
    self:SetLabel(item.Amount > 1 and item.Amount or "")

    self.Object = _SlotObject.Create("Item", {ItemHandle = item.Handle})
    slot.Tooltip = nil
end

---Sets the label of the slot, displayed in the bottom right corner.
---@param label string
function Slot:SetLabel(label)
    local slot = self.SlotElement

    slot:SetLabel(tostring(label))
end

---Sets the icon of the slot.
---@param icon icon
---@param size Vector2?
function Slot:SetIcon(icon, size)
    local slot = self.SlotIcon
    size = size or Slot.ICON_SIZE

    slot:SetIcon(icon, size:unpack())
end

---Sets the rarity frame.
---@param rarity ItemLib_Rarity|EclItem
function Slot:SetRarityIcon(rarity)
    local element = self.RarityIcon
    local icon = Item.GetRarityIcon(rarity)
    
    if icon then
        element:SetIcon(icon, Slot.ICON_SIZE:unpack())
    else
        element:SetIcon("", 1, 1)
    end
end

---Sets the slot to contain an item template.
---Does not set rarity icon by design (since the player could have multiple items of the same template with varying rarities).
---@param templateID GUID
function Slot:SetTemplate(templateID)
    local slot = self.SlotElement
    local template = Ext.Template.GetTemplate(templateID) ---@type ItemTemplate

    if template then
        self.Object = _SlotObject.Create("Template", {TemplateID = templateID})

        self:SetIcon(template.Icon)
        self:SetCooldown(-1, false)

        slot.Tooltip = nil
    end
end

---Sets the enabled state of the slot.
---@param enabled boolean
function Slot:SetEnabled(enabled)
    local slot = self.SlotElement

    slot:SetEnabled(enabled)
end

---Sets the cooldown displayed on the slot.
---@param cooldown number In turns.
---@param playRefreshAnimation boolean? Defaults to `false`.
function Slot:SetCooldown(cooldown, playRefreshAnimation)
    local slot = self.SlotElement

    slot:SetCooldown(cooldown, playRefreshAnimation)
end

---Sets whether the slot can be interacted with to use its object.
---Default behaviour is to allow usage.
---@param usable boolean
function Slot:SetUsable(usable)
    self._Usable = usable
end

function Slot:Clear()
    local slot = self.SlotElement
    self:SetIcon("", V(1, 1))
    self:SetCooldown(-1, false)
    slot:SetEnabled(false)
    self:SetLabel("")

    self.Object = _SlotObject.Create("None")
end

---Returns whether entities can be dragged in or out of the slot.
---@return boolean
function Slot:CanDragDrop()
    return self._CanDragDrop
end

---Sets whether entities can be dragged in or out of the slot.
---@param canDrag boolean
function Slot:SetCanDragDrop(canDrag)
    self._CanDragDrop = canDrag
end

---Sets the time between the element being automatically updated with data of its set entity.
---@param delay number In seconds. Set to `-1` to disable.
function Slot:SetUpdateDelay(delay)
    self._AutoUpdateDelay = delay
end

---Returns whether the slot currently holds no object.
---@return boolean
function Slot:IsEmpty()
    return self.Object == nil or self.Object.Type == "None"
end

---Shows the tooltip for the slot's held object.
function Slot:_ShowTooltip()
    local data = self.Hooks.GetTooltipData:Throw({
        Position = V(Client.GetMousePosition()),
        Owner = Client.GetCharacter(),
    })

    if not self:IsEmpty() then
        local obj = self.Object
        if obj.Type == "Item" or obj.Type == "Template" then
            local entity = obj:GetEntity() ---@type EclItem?
    
            if entity then
                Tooltip.ShowItemTooltip(entity, data.Position)
            end
        elseif obj.Type == "Skill" or obj.Type == "Action" then
            Tooltip.ShowSkillTooltip(data.Owner, obj.StatsID, data.Position)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

function Slot:_OnElementMouseUp(_)
    if self:CanDragDrop() then
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

        -- Fire event if an item was set
        if not self:IsEmpty() then
            self.Events.ObjectDraggedIn:Throw({
                Object = self.Object
            })
        end
    end
end

---Updates the element based on the held entity.
---@param ev GameStateLib_Event_RunningTick
function Slot:_OnTick(ev)
    local canUpdate = false

    if self._AutoUpdateDelay > -1 then -- TODO use a timer instead
        local remainingTime = self._AutoUpdateRemainingDelay

        remainingTime = remainingTime - ev.DeltaTime / 1000

        if remainingTime <= 0 then
            canUpdate = true

            remainingTime = self._AutoUpdateDelay
        end

        self._AutoUpdateRemainingDelay = remainingTime
    end

    if canUpdate then
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
    
            self:SetLabel("")
            self:SetCooldown(cooldown, false)
            self:SetEnabled(enabled or cooldown > 0)
    
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
                if amount > 1 then label = tostring(amount) end -- Only display label for >1 item stacks
    
                self:SetLabel(label)
                self:SetCooldown(0, false)
    
                if item.Stats then
                    isEnabled = isEnabled and Game.Stats.MeetsRequirements(char, item.Stats.Name, true, item)
                end
    
                -- Item skills
                local useActions = item.RootTemplate.OnUsePeaceActions
                for _,action in ipairs(useActions) do
                    if action.Type == "UseSkill" and isEnabled then
                        action = action ---@type UseSkillActionData

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
end

function Slot:_OnSlotClicked(_)
    local obj = self.Object

    if self._Usable then
        if obj.Type == "Skill" then
            Client.UI.Hotbar.UseSkill(obj.StatsID)
        elseif obj.Type == "Item" or obj.Type == "Template" then
            local item = obj:GetEntity()
    
            Client.UI.Hotbar.UseSkill(item)
        end
    end

    -- Throw clicked event regardless of usable state
    self.Events.Clicked:Throw()
end

---Handles drag-drops starting on the slot.
function Slot:_OnSlotDragStarted()
    if self:CanDragDrop() then
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
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterPrefab("HotbarSlot", Slot)