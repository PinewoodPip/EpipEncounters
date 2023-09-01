
local ContextMenu = Client.UI.ContextMenu
local PartyInventory = Client.UI.PartyInventory

---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

---------------------------------------------
-- TSKS
---------------------------------------------

MultiSelect.TranslatedStrings.ContextMenu_MarkAsWares = MultiSelect:RegisterTranslatedString("h74611874g72f2g4e23g8ae3g0200019466fe", {
    Text = "Mark as wares",
    ContextDescription = "Context menu option",
})
MultiSelect.TranslatedStrings.ContextMenu_UnmarkAsWares = MultiSelect:RegisterTranslatedString("h98751807g9fe2g40d6g9ca4gc0ddd1f2da3d", {
    Text = "Unmark as wares",
    ContextDescription = "Context menu option",
})
MultiSelect.TranslatedStrings.ContextMenu_SendToHomestead = MultiSelect:RegisterTranslatedString("h51a61f00g9350g4a6eg943bg340d01c6b8a4", { -- TODO allow overriding in custom campaigns?
    Text = "Store on Lady Vengeance",
    ContextDescription = "Context menu option",
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether all selections are marked as wares.
function MultiSelect._AreAllSelectionsWares()
    for _,selection in pairs(MultiSelect.GetSelections()) do
        if not Item.IsMarkedAsWares(Item.Get(selection.ItemHandle)) then
            return false
        end
    end
    return true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Replace context menu with a custom one while right-clicking a selection.
PartyInventory:RegisterCallListener("openContextMenu", function (ev, _, flashItemHandle) -- First param is character handle.
    local item = Item.Get(flashItemHandle, true)
    if MultiSelect.IsSelected(item) then -- Only do this if right-clicking a selection.
        local x, y = Client.GetMousePosition()
        ContextMenu.RequestMenu(x, y, "Features.InventoryMultiSelect", nil)

        ev:PreventAction()
    else -- Clear selections if an unrelated item was context menu'd
        MultiSelect.ClearSelections()
    end
end)

-- Listen for requests to create the context menu.
ContextMenu.RegisterMenuHandler("Features.InventoryMultiSelect", function(_)
    local waresLabel = MultiSelect._AreAllSelectionsWares() and MultiSelect.TranslatedStrings.ContextMenu_UnmarkAsWares:GetString() or MultiSelect.TranslatedStrings.ContextMenu_MarkAsWares:GetString()
    local contextMenu = {
        {id = "Features.InventoryMultiSelect.ToggleWares", type = "button", text = waresLabel},
        {id = "Features.InventoryMultiSelect.SendToHomestead", type = "button", text = MultiSelect.TranslatedStrings.ContextMenu_SendToHomestead:GetString()},
    }

    ContextMenu.Setup({
        menu = {
            id = "main",
            entries = contextMenu,
        }
    })

    ContextMenu.Open()
end)

-- Listen for requests to toggle wares flag.
ContextMenu.RegisterElementListener("Features.InventoryMultiSelect.ToggleWares", "buttonPressed", function(_, _)
    local selections = MultiSelect._SelectionsToNetIDList(MultiSelect.GetOrderedSelections())
    Net.PostToServer(MultiSelect.NETMSG_TOGGLE_WARES, {
        ItemNetIDs = selections,
        MarkAsWares = not MultiSelect._AreAllSelectionsWares(),
    })
    -- TODO do this properly - wait for server response
    Timer.Start(0.3, function (_)
        MultiSelect:DebugLog("Refreshed UI")
        PartyInventory:Show()
    end)
    MultiSelect.ClearSelections()
end)

-- Listen for requests to send items to homestead chest.
ContextMenu.RegisterElementListener("Features.InventoryMultiSelect.SendToHomestead", "buttonPressed", function(_, _)
    local selections = MultiSelect._SelectionsToNetIDList(MultiSelect.GetOrderedSelections())
    Net.PostToServer(MultiSelect.NETMSG_SEND_TO_HOMESTEAD, {
        ItemNetIDs = selections,
        CharacterNetID = Client.GetCharacter().NetID,
    })
    MultiSelect.ClearSelections()
end)