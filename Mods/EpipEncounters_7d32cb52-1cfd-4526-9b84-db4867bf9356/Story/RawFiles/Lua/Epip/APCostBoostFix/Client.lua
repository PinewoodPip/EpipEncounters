
local Hotbar = Client.UI.Hotbar
local Inventory = Client.UI.PartyInventory
local ContextMenu = Client.UI.ContextMenu

---@class Feature_APCostBoostFix : Feature
local Fix = Epip.GetFeature("EpipEncounters", "APCostBoostFix") -- Defined in Shared.lua

---------------------------------------------
-- METHODS
---------------------------------------------

---Checks if using an item is blocked by the APCostBoost bug and if so, requests the server to use the item instead via CharacterUseItem().
---@param item EclItem
function Fix.CheckItemUseAttempt(item)
    local char = Client.GetCharacter()
    local ap, _ = Character.GetActionPoints(char)
    local apCostBoost = Character.GetDynamicStat(char, "APCostBoost")
    local apCost = Item.GetUseAPCost(item) + apCostBoost

    -- Request the server to use the item for us if we're affected by the APCostBoost bug.
    if apCostBoost > 0 and ap >= apCost and Fix:IsEnabled() and not Item.IsEquipment(item) then
        Fix:DebugLog("Requesting server to use item", item.DisplayName, char.DisplayName)

        Net.PostToServer("EPIPENCOUNTERS_UseItem", {
            ItemNetID = item.NetID,
            CharacterNetID = char.NetID,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle using items from vanilla context menus.
ContextMenu:RegisterCallListener("buttonPressed", function(_, _, actionID)
    if actionID == "2" then -- "Use" action ID, TODO make an enum of these
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

-- Handle using items from hotbar.
Hotbar.Events.SlotPressed:Subscribe(function (ev)
    local slotData = ev.SlotData

    if slotData.Type == "Item" then
        local item = Item.Get(slotData.ItemHandle)

        Fix.CheckItemUseAttempt(item)
    end
end)