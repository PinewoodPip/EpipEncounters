
---@class Features.ItemRenaming
local Renaming = Epip.GetFeature("Features.ItemRenaming")

---------------------------------------------
-- METHODS
---------------------------------------------

---Renames an item.
---@param item EsvItem
---@param newName string
function Renaming.Rename(item, newName)
    item.CustomDisplayName = newName
    Renaming:DebugLog("Renamed item", item.MyGuid, "to", newName)

    -- Notify all clients to update the TSKs.
    Net.Broadcast(Renaming.NETMSG_RENAME_ITEM, {
        ItemNetID = item.NetID,
        NewName = newName,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to rename items.
Net.RegisterListener(Renaming.NETMSG_RENAME_ITEM, function (payload)
    local item = payload:GetItem()
    local newName = payload.NewName
    Renaming.Rename(item, newName)
end)
