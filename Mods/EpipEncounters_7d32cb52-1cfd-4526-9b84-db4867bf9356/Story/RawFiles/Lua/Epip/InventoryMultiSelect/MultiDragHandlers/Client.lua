
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle multi-drags ending.
MultiSelect.Events.MultiDragEnded:Subscribe(function (ev)
    -- Listen for multi-drags ending over a container item.
    -- This will move selected items into the container.
    if MultiSelect._CurrentHoveredItemHandle then
        local item = Item.Get(MultiSelect._CurrentHoveredItemHandle)
        if Item.IsContainer(item) then
            MultiSelect:DebugLog("Sending selections to container", item.DisplayName)

            local itemsNetIDs = {} ---@type NetId[]
            for _,selection in ipairs(ev.OrderedSelections) do
                table.insert(itemsNetIDs, Item.Get(selection.ItemHandle).NetID)
            end
            Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CONTAINER, {
                ItemNetIDs = itemsNetIDs,
                TargetContainerNetID = item.NetID,
            })

            ev:StopPropagation()
        end
    end
end, {StringID = "DefaultImplementation"})