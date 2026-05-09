
local Hotbar = Client.UI.Hotbar
local PlayerInfo = Client.UI.PlayerInfo
local Input = Client.Input

---@class Features.RadialMenus
local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.RadialMenus.Slot.Type "Skill"|"Empty"|"InputAction"|"Item"|"PartyMember"

---@class Features.RadialMenus.Slot
---@field Type Features.RadialMenus.Slot.Type

---@class Features.RadialMenus.Slot.Empty : Features.RadialMenus.Slot

---@class Features.RadialMenus.Slot.Skill : Features.RadialMenus.Slot
---@field SkillID string

---@class Features.RadialMenus.Slot.Item : Features.RadialMenus.Slot
---@field ItemHandle ItemHandle

---@class Features.RadialMenus.Slot.PartyMember : Features.RadialMenus.Slot
---@field CharacterHandle CharacterHandle

---@class Features.RadialMenus.Slot.InputAction : Features.RadialMenus.Slot
---@field ActionID string

---@class Features.RadialMenus.SaveData
---@field Protocol integer
---@field Menus Features.RadialMenus.Menu.SaveData[]

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.Events.SlotUsed
---@field Character EclCharacter
---@field Slot Features.RadialMenus.Slot

---@class Features.RadialMenus.Hooks.GetSlotData
---@field Slot Features.RadialMenus.Slot
---@field Name string Hookable. Defaults to empty string.
---@field Icon icon? Hookable. Defaults to `nil`.
---@field CharacterPortraitHandle CharacterHandle? If set, the character portrait will be used as the slot's icon. Takes precedence over `Icon`.

---@class Features.RadialMenus.Hooks.IsSlotUsable
---@field Slot Features.RadialMenus.Slot
---@field Usable boolean Hookable. Defaults to whether the slot is not empty.

---@class Features.RadialMenus.Hooks.IsSlotValid
---@field Slot Features.RadialMenus.Slot
---@field IsValid boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds a menu to the user.
---@param menu Features.RadialMenus.Menu
function RadialMenus.AddMenu(menu)
    table.insert(RadialMenus._Menus, menu)
end

---Removes a menu from the user.
---@param menu Features.RadialMenus.Menu
function RadialMenus.RemoveMenu(menu)
    table.remove(RadialMenus._Menus, table.reverseLookup(RadialMenus._Menus, menu))
end

---Returns the user's menus.
---@return Features.RadialMenus.Menu[]
function RadialMenus.GetMenus()
    return RadialMenus._Menus
end

---Returns the extra data of a slot.
---@see Features.RadialMenus.Hooks.GetSlotData
---@param slot Features.RadialMenus.Slot
---@return Features.RadialMenus.Hooks.GetSlotData
function RadialMenus.GetSlotData(slot)
    local data = RadialMenus.Hooks.GetSlotData:Throw({
        Slot = slot,
        Name = "",
        Icon = nil,
    })
    return data
end

---Executes a slot's action.
---@see Features.RadialMenus.Events.SlotUsed
---@param char EclCharacter
---@param slot Features.RadialMenus.Slot
function RadialMenus.UseSlot(char, slot)
    RadialMenus.Events.SlotUsed:Throw({
        Character = char,
        Slot = slot,
    })
end

---Creates a slot for a skill.
---@param skillID skill
---@return Features.RadialMenus.Slot.Skill
function RadialMenus.CreateSkillSlot(skillID)
    ---@type Features.RadialMenus.Slot.Skill
    local slot = {
        Type = "Skill",
        SkillID = skillID,
    }
    return slot
end

---Creates a slot for an input action.
---@param actionID string
---@return Features.RadialMenus.Slot.InputAction
function RadialMenus.CreateInputActionSlot(actionID)
    ---@type Features.RadialMenus.Slot.InputAction
    local slot = {
        Type = "InputAction",
        ActionID = actionID,
    }
    return slot
end

---Creates a slot for an item.
---@param item EclItem
---@return Features.RadialMenus.Slot.Item
function RadialMenus.CreateItemSlot(item)
    ---@type Features.RadialMenus.Slot.Item
    local slot = {
        Type = "Item",
        ItemHandle = item.Handle,
    }
    return slot
end

---Creates an empty slot.
---@return Features.RadialMenus.Slot.Empty
function RadialMenus.CreateEmptySlot()
    ---@type Features.RadialMenus.Slot.Empty
    return {
        Type = "Empty",
    }
end

---Returns whether a slot can currently be used.
---@see Features.RadialMenus.Hooks.IsSlotUsable
---@param slot Features.RadialMenus.Slot
---@return boolean
function RadialMenus.IsSlotUsable(slot)
    return RadialMenus.Hooks.IsSlotUsable:Throw({
        Slot = slot,
        Usable = slot.Type ~= "Empty",
    }).Usable
end

---Returns whether a slot's data is valid.
---@see Features.RadialMenus.Hooks.IsSlotValid
---@param slot Features.RadialMenus.Slot
---@return boolean
function RadialMenus.IsSlotValid(slot)
    return RadialMenus.Hooks.IsSlotValid:Throw({
        Slot = slot,
        IsValid = true,
    }).IsValid
end

---Returns whether a slot can be edited.
---TODO add hooks
---@param menu Features.RadialMenus.Menu? Defaults to current menu.
---@param index integer
---@return boolean
function RadialMenus.CanEditSlot(menu, index)
    local canEdit = false
    local slot = menu:GetSlots()[index]
    canEdit = slot and menu:GetClassName() == "Features.RadialMenus.Menu.Custom"
    return canEdit
end

---Saves the user's radial menus.
function RadialMenus.SaveData()
    -- Write to the setting
    ---@type Features.RadialMenus.SaveData
    local data = {
        Protocol = RadialMenus.SAVE_PROTOCOL,
        Menus = {},
    }
    for i,menu in ipairs(RadialMenus.GetMenus()) do
        data.Menus[i] = menu:GetSaveData()
    end
    RadialMenus.Settings.RadialMenus:SetValue(data)
    RadialMenus:SaveSettings()
end

---Loads the user's radial menus from their saved settings.
function RadialMenus.LoadData()
    local data = RadialMenus.Settings.RadialMenus:GetValue() ---@cast data Features.RadialMenus.SaveData
    if not data or not data.Protocol then return end

    -- Remove previous menus
    RadialMenus._Menus = {}

    -- Reinstantiate all menus
    for _,menuData in ipairs(data.Menus) do
        local class = RadialMenus:GetClass(menuData.ClassName) ---@type Features.RadialMenus.Menu
        local menu = class:CreateFromSaveData(menuData)
        RadialMenus.AddMenu(menu)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Execute slot functions.
RadialMenus.Events.SlotUsed:Subscribe(function (ev)
    local slot = ev.Slot
    if slot.Type == "Skill" then -- TODO support controller for all these
        ---@cast slot Features.RadialMenus.Slot.Skill
        Client.PrepareSkill(ev.Character, slot.SkillID)
    elseif slot.Type == "Item" then
        ---@cast slot Features.RadialMenus.Slot.Item
        Hotbar.UseSkill(Item.Get(slot.ItemHandle))
    elseif slot.Type == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        Client.Input.TryExecuteAction(slot.ActionID)
    elseif slot.Type == "PartyMember" then
        ---@cast slot Features.RadialMenus.Slot.PartyMember
        if Input.IsShiftPressed() or Input.IsKeyPressed("righttrigger") then
            -- Chain/unchain the character to the active character.
            local clientChar = Client.GetCharacter()
            local char = Character.Get(slot.CharacterHandle)
            if clientChar ~= char then
                -- The chaining UI calls do not work on controller, thus we must do this via Osiris instead.
                if Client.IsUsingController() then
                    Net.PostToServer(RadialMenus.NETMSG_TOGGLE_CHAIN, {
                        CharacterNetID = char.NetID,
                        TargetNetID = clientChar.NetID,
                    })
                else
                    PlayerInfo.ToggleChain(char, clientChar)
                end
            end
        else -- Switch active character.
            PlayerInfo.SelectCharacter(slot.CharacterHandle)
        end
    end
end, {StringID = "DefaultImplementation.Slot.Skill"})

-- Provide name and icons for slots.
RadialMenus.Hooks.GetSlotData:Subscribe(function (ev)
    local slot, slotType = ev.Slot, ev.Slot.Type
    if slotType == "Skill" then
        ---@cast slot Features.RadialMenus.Slot.Skill
        local action = Stats.GetAction(slot.SkillID)
        if action then
            ev.Name = action:GetName()
            ev.Icon = action.Icon
        else -- Regular skill case.
            local skill = Stats.Get("StatsLib_StatsEntry_SkillData", slot.SkillID)
            if skill then
                ev.Name = Text.GetTranslatedString(skill.DisplayName)
                ev.Icon = skill.Icon
            end
        end
    elseif slotType == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        local action = Input.GetAction(slot.ActionID)
        ev.Name = action:GetName()
        ev.Icon = action.Icon
    elseif slotType == "Item" then
        ---@cast slot Features.RadialMenus.Slot.Item
        local item = Item.Get(slot.ItemHandle)
        if item then
            ev.Name = Item.GetDisplayName(item)
            ev.Icon = Item.GetIcon(item)
        end
    elseif slot.Type == "PartyMember" then
        ---@cast slot Features.RadialMenus.Slot.PartyMember
        local char = Character.Get(slot.CharacterHandle)
        ev.Name = Character.GetDisplayName(char)
        ev.CharacterPortraitHandle = slot.CharacterHandle
    end
end)

-- Validate slots.
RadialMenus.Hooks.IsSlotValid:Subscribe(function (ev)
    local slot = ev.Slot
    if slot.Type == "Skill" then
        ---@cast slot Features.RadialMenus.Slot.Skill
        ev.IsValid = Stats.GetSkillData(slot.SkillID) ~= nil
    elseif slot.Type == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        ev.IsValid = Input.GetAction(slot.ActionID) ~= nil
    end
end, {StringID = "DefaultImplementation"})

-- Load saved data upon entering the session.
GameState.Events.GameReady:Subscribe(function (_)
    RadialMenus.LoadData()
end)
