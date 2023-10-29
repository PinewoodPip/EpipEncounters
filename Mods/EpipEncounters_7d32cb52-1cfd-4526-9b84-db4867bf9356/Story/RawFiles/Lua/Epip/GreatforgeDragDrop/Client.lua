
local TextDisplay = Client.UI.TextDisplay
local Input = Client.Input

local GreatforgeDragDrop = Epip.GetFeature("Feature_GreatforgeDragDrop")
GreatforgeDragDrop._ITEM_DROP_CURSOR = "CursorItemMove"

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the client can drop an item to bench it.
---@return boolean
function GreatforgeDragDrop._CanDrop()
    local mouseState = Ext.UI.GetCursorControl()

    return GreatforgeDragDrop:IsEnabled() and Game.AMERUI.ClientIsInSocketScreen() and Pointer.GetDraggedItem() and mouseState.MouseCursor == GreatforgeDragDrop._ITEM_DROP_CURSOR
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO add/remove these subscribers at appropriate moments.

-- Listen for the mouse moving and check the cursor to determine if its over a UI or the world to add a hint.
-- No better way of knowing this at the moment.
Input.Events.MouseMoved:Subscribe(function (_)
    if GreatforgeDragDrop:IsEnabled() then
        if Client.GetCharacter() and GreatforgeDragDrop._CanDrop() then
            TextDisplay.ShowText(Text.Format(GreatforgeDragDrop.TranslatedStrings.MouseHint:GetString(), {
                Color = Color.AREA_INTERACT,
            }), Vector.Create(Client.GetMousePosition()))
        elseif Game.AMERUI.ClientIsInSocketScreen() then
            TextDisplay.RemoveText()
        end
    end
end)

-- Request the item to be benched when mouse is released.
Input.Events.KeyReleased:Subscribe(function (ev)
    if ev.InputID == "left2" and GreatforgeDragDrop._CanDrop() then
        local draggedItem = Pointer.GetDraggedItem()
        local char = Client.GetCharacter()

        if draggedItem then
            Net.PostToServer(GreatforgeDragDrop.REQUEST_BENCH_NET_MSG, {
                CharacterNetID = char.NetID,
                ItemNetID = draggedItem.NetID,
            })

            GreatforgeDragDrop.Events.ItemDropped:Throw({
                Character = char,
                Item = draggedItem,
            })

            TextDisplay.RemoveText()

            -- Prevent dragged items from being unequipped.
            -- Dropping items is already impossible.
            Pointer.StopDragging()
        end
    end
end)