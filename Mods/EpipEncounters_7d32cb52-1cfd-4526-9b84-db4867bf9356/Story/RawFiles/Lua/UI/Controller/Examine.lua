
local ContextMenu = Client.UI.Controller.ContextMenu

---@class UI.Controller.Examine : UI
local Examine = {
    _LastSelectedCharacterHandle = nil, ---@type CharacterHandle?
    _LastSelectedItemHandle = nil, ---@type CharacterHandle?
}
Epip.InitializeUI(Ext.UI.TypeID.examine_c, "ExamineC", Examine, false)
Client.UI.Controller.Examine = Examine

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character being examined.
---@return EclCharacter? -- `nil` if no character is being examined.
function Examine.GetCharacter()
    return (Examine:IsVisible() and Examine._LastSelectedCharacterHandle and Character.Get(Examine._LastSelectedCharacterHandle)) or nil
end

---Returns the item being examined.
---@return EclItem? -- `nil` if no item is being examined.
function Examine.GetItem()
    return (Examine:IsVisible() and Examine._LastSelectedItemHandle and Item.Get(Examine._LastSelectedItemHandle)) or nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Deduce entity being examined from latest picker state when opening the context menu.
-- TODO move to context menu
ContextMenu.Events.Opened:Subscribe(function (_)
    local char, item = Pointer.GetCurrentCharacter(nil, true), Pointer.GetCurrentItem() -- Work for inventory UIs too.
    if char then
        Examine._LastSelectedCharacterHandle = char.Handle
        Examine._LastSelectedItemHandle = nil
    elseif item then
        Examine._LastSelectedCharacterHandle = nil
        Examine._LastSelectedItemHandle = item.Handle
    end
end)
