
local Hotbar = Client.UI.Hotbar

---@class Features.RadialMenus : Feature
local RadialMenus = {
    ---Do not modify!
    ---@type Features.RadialMenus.Slot.Empty
    EMPTY_SLOT = {
        Type = "Empty",
        Name = "",
        Icon = nil,
    },
    ---@type Features.RadialMenus.Menu[]
    _Menus = {},
    TranslatedStrings = {
        InputAction_Open_Name = {
            Handle = "h20c8b8dagecb6g4ddbgacd7gd760f1f68305",
            Text = "Show radial menus",
            ContextDescription = [[Keybind name]],
        },
        InputAction_Open_Description = {
            Handle = "h0785e087g2c9ag4eacgae97g6d1441301d17",
            Text = "Opens the radial menus UI.",
            ContextDescription = [[Keybind description for "Show radial menus"]],
        },
        Label_NewMenu = {
            Handle = "he5d99c4bg29e2g4094g8a5bgddba7436dfd9",
            Text = "New Menu",
            ContextDescription = [[Button label]],
        },
        Label_CreateNewMenu = {
            Handle = "h10569261ge489g4575g9010gcac5fdf393bd",
            Text = "Create New Menu",
            ContextDescription = [[Header for creator UI]],
        },
        Label_NoMenus = {
            Handle = "h5a5a16c8g1423g4e47g9b18g1c75d9984a92",
            Text = [[Use the "+" button to create radial menus.]],
            ContextDescription = [[Hint when no menus exist]],
        },
        Setting_NewMenuType_Name = {
            Handle = "hf741a592g9333g47cdgacc5gc7e19a09ab41",
            Text = "Menu Type",
            ContextDescription = [[Form label in creator UI]],
        },
        Setting_NewMenuType_Description = {
            Handle = "h6545fd7fg9919g4e82gb9c3g598cfbc9e4fa",
            Text = "Determines the contents of the new menu.<br>- Hotbar: slots are automatically filled with the contents of the character's hotbar.",
            ContextDescription = [[Tooltip for "Menu Type" form]],
        },
        Setting_HotbarStartIndex_Name = {
            Handle = "h8a3bc887g043fg4901ga76fgd1395661f1dd",
            Text = "Starting Slot",
            ContextDescription = [[Form label when creating menus]],
        },
        Setting_HotbarStartIndex_Description = {
            Handle = "h68a39633g3fa6g4ad8gb86eg7efeeaa768b8",
            Text = "Determines the hotbar slot for the menu's slots to start.<br>For reference, the keyboard + mouse Hotbar UI can show up to 29 slots per row.",
            ContextDescription = [[Tooltip for "Starting Slot" form]],
        },
        Setting_HotbarSlots_Description = {
            Handle = "hff74a7eeg26cag4ea4gb09bgca0544402200",
            Text = "Determines the amount of slots to show in the menu.",
            ContextDescription = [[Tooltip for "Slots" form]],
        },
    },
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        SlotUsed = {}, ---@type Event<Features.RadialMenus.Events.SlotUsed>
    },
}
Epip.RegisterFeature("Features.RadialMenus", RadialMenus)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.RadialMenus.Slot.Type "Skill"|"Empty"|"InputAction"|"Item"

---@class Features.RadialMenus.Slot
---@field Type Features.RadialMenus.Slot.Type
---@field Name TextLib.String
---@field Icon icon?

---@class Features.RadialMenus.Slot.Empty : Features.RadialMenus.Slot

---@class Features.RadialMenus.Slot.Skill : Features.RadialMenus.Slot
---@field SkillID string
---@
---@class Features.RadialMenus.Slot.Item : Features.RadialMenus.Slot
---@field ItemHandle ItemHandle

---@class Features.RadialMenus.Slot.InputAction : Features.RadialMenus.Slot
---@field ActionID string

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.Events.SlotUsed
---@field Character EclCharacter
---@field Slot Features.RadialMenus.Slot

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds a menu to the user.
---@param menu Features.RadialMenus.Menu
function RadialMenus.AddMenu(menu)
    table.insert(RadialMenus._Menus, menu)
end

---Returns the user's menus.
---@return Features.RadialMenus.Menu[]
function RadialMenus.GetMenus()
    return RadialMenus._Menus
end

---Executes a slot's action.
---@see Features.RadialMenus.Events.SlotUsed
---@param char EclCharacter
---@param slot Features.RadialMenus.Slot
function RadialMenus.UseSlot(char, slot)
    RadialMenus.Events.SlotUsed:Throw({
        Character = char,
        Slot = slot,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Execute slot functions.
RadialMenus.Events.SlotUsed:Subscribe(function (ev)
    local slot = ev.Slot
    if slot.Type == "Skill" then -- TODO support controller for all these
        ---@cast slot Features.RadialMenus.Slot.Skill
        Hotbar.UseSkill(slot.SkillID)
    elseif slot.Type == "Item" then
        ---@cast slot Features.RadialMenus.Slot.Item
        Hotbar.UseSkill(Item.Get(slot.ItemHandle))
    elseif slot.Type == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        Client.Input.TryExecuteAction(slot.ActionID)
    end
end, {StringID = "DefaultImplementation.Slot.Skill"})
