
local Trade = Client.UI.Trade
local ContainerInventory = Client.UI.ContainerInventory
local Input = Client.Input

---@class Features.TradeContainers
local TradeContainers = Epip.GetFeature("Features.TradeContainers")

---------------------------------------------
-- METHODS
---------------------------------------------

---Reconfigures the Trade & ContainerInventory UIs to support using both simultaneously.
function TradeContainers._SetupUIs()
    local tradeUI = Trade:GetUI()
    tradeUI.OF_PlayerModal1 = false
    ContainerInventory:GetUI().Layer = tradeUI.Layer + 1
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Request containers to be opened upon right-clicking them.
Input.Events.KeyPressed:Subscribe(function (ev)
    if ev.InputID == "right2" and Trade:IsVisible() then
        local slot = Trade.GetSelectedSlot()
        if slot and slot.Item and Item.IsContainer(slot.Item) then
            Net.PostToServer(TradeContainers.NETMSG_OPEN_CONTAINER, {
                CharacterNetID = Client.GetCharacter().NetID,
                ItemNetID = slot.Item.NetID,
            })
        end

        TradeContainers._SetupUIs()
    end
end)

-- Handle items being clicked within container inventories.
-- "slotUp" is not convenient to use as it fires twice per interaction.
Input.Events.KeyReleased:Subscribe(function (ev)
    if ev.InputID == "left2" and Trade:IsVisible() and ContainerInventory:IsVisible() and not Client.UI.ContextMenu.IsOpen() and Pointer.GetDraggedItem() == nil then -- Do not request items to be added to the trade offer if a drag was started on them.
        local item = ContainerInventory.GetSelectedItem()
        if item then
            Net.PostToServer(TradeContainers.NETMSG_SEND_TO_CHARACTER, {
                CharacterNetID = Trade.GetSelectedCharacter().NetID,
                ItemNetID = item.NetID,
            })
            Trade:PlaySound("UI_Game_PartyFormation_PickUp") -- TODO verify which event is exactly used for the swoosh.
        end
    end
end)

-- Add items from backpacks to the current order when the server has confirmed they've been moved.
Net.RegisterListener(TradeContainers.NETMSG_SEND_TO_CHARACTER_COMPLETED, function (payload)
    local item = payload:GetItem()
    local handle = item.Handle
    Timer.StartTickTimer(2, function (_)
        Trade:ExternalInterfaceCall("itemClick", Trade.GRID_IDS.PLAYER_INVENTORY, Ext.UI.HandleToDouble(handle))
    end)
end)

-- Add hint to container tooltips on how to open them.
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if ev.UI:GetTypeId() == Ext.UI.TypeID.trade then
        local item = ev.Item
        if Item.IsContainer(item) then
            local description = ev.Tooltip:GetFirstElement("ItemDescription") or {Type = "ItemDescription", Label = ""}
            description.Label = Text.Format("%s<br><br>%s", {
                FormatArgs = {
                    description.Label,
                    TradeContainers.TranslatedStrings.Tooltip_Hint:Format({
                        Color = Color.LARIAN.GREEN
                    })
                }
            })
        end
    end
end)