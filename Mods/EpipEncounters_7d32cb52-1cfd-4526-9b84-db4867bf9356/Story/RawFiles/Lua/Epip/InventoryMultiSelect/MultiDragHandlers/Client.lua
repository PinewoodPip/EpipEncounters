
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Creates a list of NetIDs from selections.
---@param selections Features.InventoryMultiSelect.Selection[]
---@return NetId[]
local function SelectionsToNetIDList(selections)
    local itemsNetIDs = {} ---@type NetId[]
    for _,selection in ipairs(selections) do
        table.insert(itemsNetIDs, Item.Get(selection.ItemHandle).NetID)
    end
    return itemsNetIDs
end

-- Handle multi-drags ending.
MultiSelect.Events.MultiDragEnded:Subscribe(function (ev)
    -- Listen for multi-drags ending over a container item.
    -- This will move selected items into the container.
    if MultiSelect._CurrentHoveredItemHandle then
        local item = Item.Get(MultiSelect._CurrentHoveredItemHandle)
        if Item.IsContainer(item) then
            MultiSelect:DebugLog("Sending selections to container", item.DisplayName)

            Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CONTAINER, {
                ItemNetIDs = SelectionsToNetIDList(ev.OrderedSelections),
                TargetContainerNetID = item.NetID,
            })

            ev:StopPropagation()
        end
    else
        local hoveredPlayerTabCharacter = MultiSelect._GetSelectedInventoryHeader()
        if hoveredPlayerTabCharacter then
            MultiSelect:DebugLog("Sending selections to character", hoveredPlayerTabCharacter.DisplayName)

            Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CHARACTER, {
                ItemNetIDs = SelectionsToNetIDList(ev.OrderedSelections),
                CharacterNetID = hoveredPlayerTabCharacter.NetID,
            })
        end
    end
end, {StringID = "DefaultImplementation"})