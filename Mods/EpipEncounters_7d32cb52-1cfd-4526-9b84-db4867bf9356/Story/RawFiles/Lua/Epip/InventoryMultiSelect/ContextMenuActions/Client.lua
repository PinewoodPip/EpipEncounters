
local ContextMenu = Client.UI.ContextMenu
local PartyInventory = Client.UI.PartyInventory

---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
local TSK = MultiSelect.TranslatedStrings

MultiSelect.SOUND_SEND_TO_HOMESTEAD = "UI_Game_Inventory_StoreOnLV"
MultiSelect.SOUND_TOGGLE_WARES = "UI_Game_PartyFormation_PickUp"

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
MultiSelect.TranslatedStrings.ContextMenu_SendTo = MultiSelect:RegisterTranslatedString("hc1f05532ga3a6g4b02gb837g77d3267b8f18", {
    Text = "Send to %s",
    ContextDescription = "Context menu option. Param is character name",
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
    ---@type table[]
    local entries = {
        {id = "Features.InventoryMultiSelect.ToggleWares", type = "button", text = waresLabel},
    }

    -- Add "send to character" entries
    -- Will exclude a single character if all selections come from them.
    local clientChar = Client.GetCharacter()
    local selections = MultiSelect.GetOrderedSelections()
    local excludedCharacterHandle = nil ---@type ComponentHandle?
    for _,selection in ipairs(selections) do
        ---@cast selection Features.InventoryMultiSelect.Selection.PartyInventory
        if excludedCharacterHandle == nil then -- Exclude this character if all selections come from them.
            excludedCharacterHandle = selection.OwnerCharacterHandle
        elseif excludedCharacterHandle ~= selection.OwnerCharacterHandle then -- If there are selections from multiple characters, don't exclude any characters.
            excludedCharacterHandle = nil
            break
        end
    end
    for _,member in ipairs(Character.GetPartyMembers(clientChar)) do
        -- Only insert option if all the selections do not come from this member.
        -- This prevents the option to send all items to the character that owns them from appearing.
        if not excludedCharacterHandle or member.Handle ~= excludedCharacterHandle then
            table.insert(entries, {id = "Features.InventoryMultiSelect.SendToCharacter." .. member.NetID, type = "button", text = string.format(MultiSelect.TranslatedStrings.ContextMenu_SendTo:GetString(), Character.GetDisplayName(member)), params = {NetID = member.NetID}, eventIDOverride = "Features.InventoryMultiSelect.SendToCharacter"})
        end
    end

    if Client.CanSendToLadyVengeance() then
        table.insert(entries, {id = "Features.InventoryMultiSelect.SendToHomestead", type = "button", text = MultiSelect.TranslatedStrings.ContextMenu_SendToHomestead:GetString()})
    end

    -- Add "drop" entry
    table.insert(entries, {
        id = "Vanilla.InventoryMultiSelect.Drop",
        type = "button",
        text = TSK.Label_DropItems:GetString(),
    })

    ContextMenu.Setup({
        menu = {
            id = "main",
            entries = entries,
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
    ContextMenu:PlaySound(MultiSelect.SOUND_TOGGLE_WARES)
end)

-- Listen for requests to send items to a character.
ContextMenu.RegisterElementListener("Features.InventoryMultiSelect.SendToCharacter", "buttonPressed", function(_, params)
    local selections = MultiSelect._SelectionsToNetIDList(MultiSelect.GetOrderedSelections())
    Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CHARACTER, {
        ItemNetIDs = selections,
        CharacterNetID = params.NetID,
    })
    MultiSelect.ClearSelections()
    -- Doesn't need any special sound to play, the vanilla game doesn't use any (other than the context menu click)
end)

-- Listen for requests to send items to homestead chest.
ContextMenu.RegisterElementListener("Features.InventoryMultiSelect.SendToHomestead", "buttonPressed", function(_, _)
    local selections = MultiSelect._SelectionsToNetIDList(MultiSelect.GetOrderedSelections())
    Net.PostToServer(MultiSelect.NETMSG_SEND_TO_HOMESTEAD, {
        ItemNetIDs = selections,
        CharacterNetID = Client.GetCharacter().NetID,
    })
    MultiSelect.ClearSelections()
    ContextMenu:PlaySound(MultiSelect.SOUND_SEND_TO_HOMESTEAD)
end)

-- Listen for requests to drop items.
ContextMenu.RegisterElementListener("Vanilla.InventoryMultiSelect.Drop", "buttonPressed", function(_, _)
    local selections = MultiSelect._SelectionsToNetIDList(MultiSelect.GetOrderedSelections())
    Net.PostToServer(MultiSelect.NETMSG_DROP_ITEMS, {
        ItemNetIDs = selections,
        CharacterNetID = Client.GetCharacter().NetID,
    })
    MultiSelect.ClearSelections()
end)
