
local ContextMenu = Client.UI.ContextMenu
local MsgBox = Client.UI.MessageBox

---@class Features.ItemRenaming
local Renaming = Epip.GetFeature("Features.ItemRenaming")
local TSK = Renaming.TranslatedStrings
Renaming._CurrentItemHandle = nil ---@type ItemHandle

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests an item to be renamed.
---@param item EclItem
---@param newName string|"" Empty string will reset the item's name.
function Renaming.RequestRename(item, newName)
    Net.PostToServer(Renaming.NETMSG_RENAME_ITEM, {
        ItemNetID = item.NetID,
        NewName = newName,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add "rename" option to item context menus.
ContextMenu.RegisterVanillaMenuHandler("Item", function (item)
    if Renaming.CanRename(item) then
        ContextMenu.AddElement({{
            id = "Features.ItemRenaming.RenameItem",
            type = "button",
            text = Renaming.TranslatedStrings.Label_Rename:GetString(),
        }})
    end
end)
ContextMenu.RegisterElementListener("Features.ItemRenaming.RenameItem", "buttonPressed", function (_, _)
    local item = ContextMenu.GetCurrentEntity()
    if not Entity.IsItem(item) then Renaming:__LogWarning("Renaming requested but context menu entity is not an item?") return end
    Renaming._CurrentItemHandle = item.Handle

    -- Prompt the user to name the item
    MsgBox.Open({
        ID = "Features.ItemRenaming.RenameItem",
        Type = "Input",
        Header = TSK.MsgBox_Rename_Header:GetString(),
        Message = TSK.MsgBox_Rename_Body:GetString(),
        AcceptEmpty = true, -- Necessary to allow resetting the name without writing anything in the text field.
        Buttons = {
            -- The unintuitive ID order is necessary for the MsgBox UI to properly handle the enter/accept key; if buttons with IDs >2 were present, enter would submit button ID 3.
            {ID = 1, Text = Text.CommonStrings.Confirm:GetString(), Type = "Yes"},
            {ID = 0, Text = Text.CommonStrings.Reset:GetString(), Type = "Normal"},
            {ID = 2, Text = Text.CommonStrings.Cancel:GetString(), Type = "No"},
        },
    })
end)
MsgBox.RegisterMessageListener("Features.ItemRenaming.RenameItem", MsgBox.Events.InputSubmitted, function (newName, buttonID, _)
    local item = Item.Get(Renaming._CurrentItemHandle)
    if buttonID == 1 then -- Rename.
        Renaming.RequestRename(item, newName)
    elseif buttonID == 0 then -- Reset name.
        Renaming.RequestRename(item, "")
    end
end)

-- Restrict which items can be renamed.
Renaming.Hooks.CanRename:Subscribe(function (ev)
    local item = ev.Item
    local isContainer = Item.IsContainer(item) and Item.IsInInventory(item)
    ev.CanRename = isContainer -- Only allow renaming containers for now.
end)

-- Handle requests from the server to rename an item.
Net.RegisterListener(Renaming.NETMSG_RENAME_ITEM, function (payload)
    local item = payload:GetItem()
    local itemDisplayName = item.CustomDisplayName.Handle
    itemDisplayName.Handle = Text.UNKNOWN_HANDLE
    itemDisplayName.ReferenceString = payload.NewName
end)
