
local Hotbar = Client.UI.Hotbar
local Inventory = Client.UI.PartyInventory
local ContainerInventory = Client.UI.ContainerInventory
local ContextMenu = Client.UI.ContextMenu
local Input = Client.Input

---@class Feature_APCostBoostFix : Feature
local Fix = Epip.GetFeature("EpipEncounters", "APCostBoostFix") -- Defined in Shared.lua

---------------------------------------------
-- METHODS
---------------------------------------------

---Checks if using an item is blocked by the APCostBoost bug and if so, requests the server to use the item instead via CharacterUseItem().
---@param item EclItem
function Fix.CheckItemUseAttempt(item)
    local char = Client.GetCharacter()
    local apCost = Item.GetUseAPCost(item)

    -- Request the server to use the item for us if we're affected by the APCostBoost bug.
    if Fix.IsCostAffected(apCost) and Fix:IsEnabled() and not Item.IsEquipment(item) then
        Fix:DebugLog("Requesting server to use item", item.DisplayName, char.DisplayName)

        Net.PostToServer("EPIPENCOUNTERS_UseItem", {
            ItemNetID = item.NetID,
            CharacterNetID = char.NetID,
        })
    end
end

---Checks whether attacking a character is blocked by the APCostBoost bug and if so, requests the server to have the client character attack the target.
---@param target EclCharacter|EclItem
---@return boolean -- `true` if the check succeeded.
function Fix.CheckAttackAttempt(target)
    local clientChar = Client.GetCharacter()
    local previewedTask = clientChar.InputController.PreviewTask
    local isAttacking = ContextMenu.IsOpen() or (previewedTask and previewedTask.ActionTypeId == Character.CHARACTER_TASKS.ATTACK)
    local isAffectedByBug = isAttacking
    if isAttacking then
        local attackCost = Game.Math.GetCharacterWeaponAPCost(clientChar.Stats) -- TODO this will not consider the GetAttackAPCost extender event due to limitations.
        if Fix.IsCostAffected(attackCost) then
            Fix:DebugLog("Requesting server to attack", target.DisplayName)
            Net.PostToServer(Fix.NETMSG_ATTACK, {
                AttackerNetID = clientChar.NetID,
                TargetNetID = target.NetID,
            })
        else
            isAffectedByBug = false
        end
    end
    return isAffectedByBug
end

---Returns whether an AP cost is currently affected by the bug for the client character.
---@param apCost integer Base AP cost.
---@return boolean
function Fix.IsCostAffected(apCost)
    local char = Client.GetCharacter()
    local ap, _ = Character.GetActionPoints(char)
    local apCostBoost = Character.GetDynamicStat(char, "APCostBoost")
    return apCostBoost > 0 and ap >= (apCost + apCostBoost) and ap < (apCost + apCostBoost * 2) -- The character is only affected if they don't have enough AP to pay the cost + twice the AP cost boost.
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle attempts to attack through mouse controls.
-- By timing miracles, this actually also works for the context menu "Attack" option.
Input.Events.KeyPressed:Subscribe(function (ev)
    if ev.InputID == "left2" then
        local target = (not Client.IsUsingController() and ContextMenu.GetCurrentCharacter()) or Pointer.GetCurrentCharacter(nil, true) -- TODO support controller context menu
        if target and target ~= Client.GetCharacter() then -- Do not attempt to attack self.
            Fix.CheckAttackAttempt(target)
        end
    end
end, {EnabledFunctor = function () return GameState.IsInRunningSession() and Fix:IsEnabled() end})

-- Handle using items from vanilla context menus.
ContextMenu.Events.EntryPressed:Subscribe(function (ev)
    if ev.ID == ContextMenu.VANILLA_ACTIONS.USE then
        local item = ContextMenu.GetCurrentEntity()
        if item and GetExtType(item) == "ecl::Item" then
            Fix.CheckItemUseAttempt(item)
        end
    end
end)

-- Handle using items from inventory via double-click.
Inventory:RegisterCallListener("doubleClickItem", function(_, itemHandle)
    local item = Item.Get(itemHandle, true)

    Fix.CheckItemUseAttempt(item)
end)

-- Handle using items from containers.
ContainerInventory:RegisterCallListener("doubleClickItem", function (_, itemFlashHandle)
    local item = Item.Get(itemFlashHandle, true)
    Fix.CheckItemUseAttempt(item)
end)

-- Handle using items from hotbar.
Hotbar.Events.SlotPressed:Subscribe(function (ev)
    local slotData = ev.SlotData

    if slotData.Type == "Item" then
        local item = Item.Get(slotData.ItemHandle)

        Fix.CheckItemUseAttempt(item)
    end
end)
