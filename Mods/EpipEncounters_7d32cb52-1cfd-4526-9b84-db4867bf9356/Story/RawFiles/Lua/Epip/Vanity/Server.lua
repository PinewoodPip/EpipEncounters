
---@class Feature_Vanity
local Vanity = Epip.GetFeature("Feature_Vanity")

-- Cooldowns for each item requesting a character's visuals to be refreshed.
Vanity._LastItemRefreshTime = {} ---@type table<ItemHandle, integer>
Vanity._ITEM_REFRESH_COOLDOWN = 300 -- In milliseconds.

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to refresh char's appearance only if the item hasn't been responsible for another refresh recently.
---@param char EsvCharacter
---@param item EsvItem
---@param useAlternativeStatus boolean
function Vanity.TryRefreshAppearance(char, item, useAlternativeStatus)
    local lastRefreshTime = Vanity._LastItemRefreshTime[item.Handle] or 0
    local now = Ext.Utils.MonotonicTime()
    if now - lastRefreshTime >= Vanity._ITEM_REFRESH_COOLDOWN then
        Vanity._LastItemRefreshTime[item.Handle] = now
        Vanity.RefreshAppearance(char, useAlternativeStatus)
    end
end

---Reverts the appearance of an item to its original one.
---Will notify the client to do the same.
---@param char EsvCharacter
---@param item EsvItem
function Vanity.RevertAppearance(char, item)
    Vanity._RevertAppearance(char, item)
    Net.Broadcast(Vanity.NETMSG_REVERT_APPEARANCE, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
end

---Reverts the appearance of an item to its original one.
---@param char EsvCharacter
---@param item EsvItem
function Vanity._RevertAppearance(char, item)
    Vanity.Events.ItemAppearanceReset:Throw({
        Character = char,
        Item = item,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Revert appearance of items when they are unequipped.
Osiris.RegisterSymbolListener("ItemUnEquipped", 2, "after", function (itemGUID, charGUID)
    if Osiris.GetFirstFact("DB_IsPlayer", charGUID) and Vanity.Settings.RevertAppearanceOnUnequip:GetValue() == true then
        local item = Item.Get(itemGUID)
        Vanity.RevertAppearance(Character.Get(charGUID), item)
    end
end)

-- Handle requests to revert item appearance.
Net.RegisterListener(Vanity.NETMSG_REVERT_APPEARANCE, function (payload)
    Vanity._RevertAppearance(payload:GetCharacter(), payload:GetItem()) -- Do not notify the client back.
end)
