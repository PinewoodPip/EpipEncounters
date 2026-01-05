
---------------------------------------------
-- Implements the ability to rename items.
---------------------------------------------

---@class Features.ItemRenaming : Feature
local Renaming = {
    NETMSG_RENAME_ITEM = "Features.ItemRenaming.NetMsg.RenameItem",

    TranslatedStrings = {
        Label_Rename = {
            Handle = "ha09bd76egd8d2g4d25gad02gfc1cc87f3e3e",
            Text = "Rename...",
            ContextDescription = [[Context menu option]],
        },
        MsgBox_Rename_Header = {
            Handle = "hd65ba8b1gc15dg4cd8gb47cgff75f50f3a4e",
            Text = "Rename Item",
            ContextDescription = [[Message box header]],
        },
        MsgBox_Rename_Body = {
            Handle = "h2c0b1e36g9861g428fgb00fgfc4150878def",
            Text = "Enter a new name for the item:",
            ContextDescription = [[Message box text when renaming an item]],
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        CanRename = {}, ---@type Hook<Features.ItemRenaming.Hooks.CanRename>
    },
}
Epip.RegisterFeature("Features.ItemRenaming", Renaming)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.ItemRenaming.Hooks.CanRename
---@field Item Item
---@field CanRename boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether an item can be renamed.
---@param item Item
---@return boolean
function Renaming.CanRename(item)
    return Renaming.Hooks.CanRename:Throw({
        Item = item,
        CanRename = true,
    }).CanRename
end

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.ItemRenaming.NetMsg.RenameItem : NetLib_Message_Item
---@field NewName string
