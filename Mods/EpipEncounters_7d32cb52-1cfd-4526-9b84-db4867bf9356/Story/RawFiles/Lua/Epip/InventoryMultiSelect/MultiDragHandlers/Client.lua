
local PartyInventory = Client.UI.PartyInventory

---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

MultiSelect.SOUND_DRAG_TO_SLOT = "UI_Game_Inventory_Click"

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

            Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CONTAINER, {
                ItemNetIDs = MultiSelect._SelectionsToNetIDList(ev.OrderedSelections),
                TargetContainerNetID = item.NetID,
            })

            ev:StopPropagation()
            PartyInventory:PlaySound(MultiSelect.SOUND_DRAG_TO_SLOT)
        end
    else
        local hoveredPlayerTabCharacter = MultiSelect._GetSelectedInventoryHeader()
        if hoveredPlayerTabCharacter then -- Send items to character
            MultiSelect:DebugLog("Sending selections to character", hoveredPlayerTabCharacter.DisplayName)

            Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CHARACTER, {
                ItemNetIDs = MultiSelect._SelectionsToNetIDList(ev.OrderedSelections),
                CharacterNetID = hoveredPlayerTabCharacter.NetID,
            })
            ev:StopPropagation()
            PartyInventory:PlaySound(MultiSelect.SOUND_DRAG_TO_SLOT)
        else -- Put items into hovered slot and subsequent available ones
            -- Must be done next tick, or emulating startDragging will throw "Already multi-dragging" error
            Ext.OnNextTick(function ()
                for _,inv in ipairs(MultiSelect._GetInventoryMovieClips()) do
                    if inv.currentSelection >= 0 then
                        local nextSlotIndex = inv.currentSelection

                        -- Move each selection to the next available slot starting from hovered one
                        for _,selection in ipairs(ev.OrderedSelections) do
                            local slot = inv.content_array[nextSlotIndex]
                            while slot and slot._itemHandle ~= 0 do -- Search next empty slot. Cells that don't exist are surely empty.
                                nextSlotIndex = nextSlotIndex + 1
                                slot = inv.content_array[nextSlotIndex]
                                if nextSlotIndex > 999 then
                                    MultiSelect:InternalError("Events.MultiDragEnded", "Could not find slot within reasonable range")
                                end
                            end

                            MultiSelect._MoveItemToPartyInventorySlot(selection.ItemHandle, inv.id, nextSlotIndex)

                            nextSlotIndex = nextSlotIndex + 1
                        end

                        MultiSelect:DebugLog("Holy fuck. The title of 'UI Hackerman' is truly befitting. Anyways the items have been moved")
                        break
                    end
                end
            end)
            PartyInventory:PlaySound(MultiSelect.SOUND_DRAG_TO_SLOT)
            ev:StopPropagation()
        end
    end
end, {StringID = "DefaultImplementation"})