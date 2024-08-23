
local Hotbar = Client.UI.Hotbar
local Input = Client.Input

---@class Features.RadialMenus : Feature
local RadialMenus = {
    SAVE_PROTOCOL = 0,

    _Menus = {}, ---@type Features.RadialMenus.Menu[]

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
        InputAction_PreviousMenu_Name = {
            Handle = "h692c89c9g7ce4g42e4g8c52ge027ea83f186",
            Text = "Radial Menus: Previous Menu",
            ContextDescription = [[Keybind name]],
        },
        InputAction_PreviousMenu_Description = {
            Handle = "h8f5b9b70g4ee0g4c60gb9f8gf5ff26567f0d",
            Text = "Cycles to the previous radial menu while the UI is open.",
            ContextDescription = [[Keybind description for "Radial Menus: Previous Menu"]],
        },
        InputAction_NextMenu_Name = {
            Handle = "ha60bb03egff09g41bfg8d51gb512877729c4",
            Text = "Radial Menus: Next Menu",
            ContextDescription = [[Keybind name]],
        },
        InputAction_NextMenu_Description = {
            Handle = "ha643cdeagcf4dg4128g81c6gd1cf68f76a18",
            Text = "Cycles to the next radial menu while the UI is open.",
            ContextDescription = [[Keybind description for "Radial Menus: Next Menu"]],
        },
        Label_RadialMenus = {
            Handle = "ha50291ebgfcdbg4a3bgbd43g75802d9d0b67",
            Text = "Radial Menus",
            ContextDescription = [[Feature name]],
        },
        Label_NewMenu = {
            Handle = "he5d99c4bg29e2g4094g8a5bgddba7436dfd9",
            Text = "New Menu",
            ContextDescription = [[Button label]],
        },
        Label_EditSlotHint = {
            Handle = "hba173410g9d70g4a7fg9fdbg23ba719d69c7",
            Text = "Right-click a slot to edit it.",
            ContextDescription = [[Hint at the bottom of the UI when using a custom menu]],
        },
        Label_CreateNewMenu = {
            Handle = "h10569261ge489g4575g9010gcac5fdf393bd",
            Text = "Create New Menu",
            ContextDescription = [[Header for creator UI]],
        },
        Label_EditMenu = {
            Handle = "h1cef44f3g474bg4ed6gb45cg2956edf2d87e",
            Text = "Edit Menu",
            ContextDescription = [[Header for editor UI]],
        },
        Label_EditSlot = {
            Handle = "hdf2431e0g2c4fg4f52gb076g27f53a00306f",
            Text = "Edit Slot",
            ContextDescription = [[Header for editor UI]],
        },
        Label_NoMenus = {
            Handle = "h5a5a16c8g1423g4e47g9b18g1c75d9984a92",
            Text = [[Use the "+" button to create radial menus.]],
            ContextDescription = [[Hint when no menus exist]],
        },
        Label_PreviousMenu = {
            Handle = "h7031852fg830cg42d3gbbc3g8179d3ffd957",
            Text = "Previous Menu",
            ContextDescription = [[Input label]],
        },
        Label_NextMenu = {
            Handle = "hb50b9e8bgefe9g4c8bg957cge4597f8df3c8",
            Text = "Next Menu",
            ContextDescription = [[Input label]],
        },
        MsgBox_DeleteMenu_Title = {
            Handle = "hde39ce3dgd432g48beg98f2g347228bb4de6",
            Text = "Delete Menu",
            ContextDescription = [[Message box header]],
        },
        MsgBox_DeleteMenu_Body = {
            Handle = "h920ae542ga390g42d7g8cd3g0cb24794c3bb",
            Text = [[Are you sure you want to delete the "%s" menu?]],
            ContextDescription = [[Message box for deleting menus; param is the menu's name (named by user)]],
        },
        Setting_NewMenuType_Name = {
            Handle = "hf741a592g9333g47cdgacc5gc7e19a09ab41",
            Text = "Menu Type",
            ContextDescription = [[Form label in creator UI]],
        },
        Setting_NewMenuType_Description = {
            Handle = "h6545fd7fg9919g4e82gb9c3g598cfbc9e4fa",
            Text = "Determines the contents of the new menu.<br>- Hotbar: slots are automatically filled with the contents of the character's hotbar.<br>- Custom: slots must be manually configured.",
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
        Setting_SlotType_Name = {
            Handle = "h67cc16ccgd666g4bf6ga746g4f2445ceeed0",
            Text = "Slot Type",
            ContextDescription = [[Form name]],
        },
        Setting_SlotType_Description = {
            Handle = "hb02313dagf2c3g4bb0gaeb1ga6447c96896d",
            Text = "Determines what kind of action this slot can hold.",
            ContextDescription = [[Tooltip for "Slot Type" form]],
        },
        Setting_Keybind_Description = {
            Handle = "hba30f22ag08acg4becg91b4g8832160d6270",
            Text = "Determines the Epip keybind action to fire when the slot is used.<br>Actions that require the keybind to be held are not currently supported.",
            ContextDescription = [[Form tooltip for "Keybind"]],
        },
        Setting_Skill_Description = {
            Handle = "hc4a1e5a0gdbaeg4a2dg8e92gd7ef42084361",
            Text = "Determines the skill to use for the slot. Drag-and-drop a skill or interact with the socket to pick one.",
            ContextDescription = [[Tooltip for skill slot form]],
        },
    },
    Settings = {
        RadialMenus = {
            Type = "Map",
            Context = "Client",
        },
    },
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        SlotUsed = {}, ---@type Event<Features.RadialMenus.Events.SlotUsed>
    },
    Hooks = {
        GetSlotData = {}, ---@type Event<Features.RadialMenus.Hooks.GetSlotData>
        IsSlotUsable = {}, ---@type Hook<Features.RadialMenus.Hooks.IsSlotUsable>
    }
}
Epip.RegisterFeature("Features.RadialMenus", RadialMenus)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.RadialMenus.Slot.Type "Skill"|"Empty"|"InputAction"|"Item"

---@class Features.RadialMenus.Slot
---@field Type Features.RadialMenus.Slot.Type

---@class Features.RadialMenus.Slot.Empty : Features.RadialMenus.Slot

---@class Features.RadialMenus.Slot.Skill : Features.RadialMenus.Slot
---@field SkillID string
---@
---@class Features.RadialMenus.Slot.Item : Features.RadialMenus.Slot
---@field ItemHandle ItemHandle

---@class Features.RadialMenus.Slot.InputAction : Features.RadialMenus.Slot
---@field ActionID string

---@class Features.RadialMenus.SaveData
---@field Protocol integer
---@field Menus Features.RadialMenus.Menu.SaveData[]

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.Events.SlotUsed
---@field Character EclCharacter
---@field Slot Features.RadialMenus.Slot

---@class Features.RadialMenus.Hooks.GetSlotData
---@field Slot Features.RadialMenus.Slot
---@field Name string Hookable. Defaults to empty string.
---@field Icon icon? Hookable. Defaults to `nil`.

---@class Features.RadialMenus.Hooks.IsSlotUsable
---@field Slot Features.RadialMenus.Slot
---@field Usable boolean Hookable. Defaults to whether the slot is not empty.

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds a menu to the user.
---@param menu Features.RadialMenus.Menu
function RadialMenus.AddMenu(menu)
    table.insert(RadialMenus._Menus, menu)
end

---Removes a menu from the user.
---@param menu Features.RadialMenus.Menu
function RadialMenus.RemoveMenu(menu)
    table.remove(RadialMenus._Menus, table.reverseLookup(RadialMenus._Menus, menu))
end

---Returns the user's menus.
---@return Features.RadialMenus.Menu[]
function RadialMenus.GetMenus()
    return RadialMenus._Menus
end

---Returns the extra data of a slot.
---@see Features.RadialMenus.Hooks.GetSlotData
---@param slot Features.RadialMenus.Slot
---@return Features.RadialMenus.Hooks.GetSlotData
function RadialMenus.GetSlotData(slot)
    local data = RadialMenus.Hooks.GetSlotData:Throw({
        Slot = slot,
        Name = "",
        Icon = nil,
    })
    return data
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

---Creates a slot for a skill.
---@param skillID skill
---@return Features.RadialMenus.Slot.Skill
function RadialMenus.CreateSkillSlot(skillID)
    ---@type Features.RadialMenus.Slot.Skill
    local slot = {
        Type = "Skill",
        SkillID = skillID,
    }
    return slot
end

---Creates a slot for an input action.
---@param actionID string
---@return Features.RadialMenus.Slot.InputAction
function RadialMenus.CreateInputActionSlot(actionID)
    ---@type Features.RadialMenus.Slot.InputAction
    local slot = {
        Type = "InputAction",
        ActionID = actionID,
    }
    return slot
end

---Creates a slot for an item.
---@param item EclItem
---@return Features.RadialMenus.Slot.Item
function RadialMenus.CreateItemSlot(item)
    ---@type Features.RadialMenus.Slot.Item
    local slot = {
        Type = "Item",
        ItemHandle = item.Handle,
    }
    return slot
end

---Creates an empty slot.
---@return Features.RadialMenus.Slot.Empty
function RadialMenus.CreateEmptySlot()
    ---@type Features.RadialMenus.Slot.Empty
    return {
        Type = "Empty",
    }
end

---Returns whether a slot can currently be used.
---@see Features.RadialMenus.Hooks.IsSlotUsable
---@param slot Features.RadialMenus.Slot
---@return boolean
function RadialMenus.IsSlotUsable(slot)
    return RadialMenus.Hooks.IsSlotUsable:Throw({
        Slot = slot,
        Usable = slot.Type ~= "Empty",
    }).Usable
end

---Returns whether a slot can be edited.
---TODO add hooks
---@param menu Features.RadialMenus.Menu? Defaults to current menu.
---@param index integer
---@return boolean
function RadialMenus.CanEditSlot(menu, index)
    local canEdit = false
    local slot = menu:GetSlots()[index]
    canEdit = slot and menu:GetClassName() == "Features.RadialMenus.Menu.Custom"
    return canEdit
end

---Saves the user's radial menus.
function RadialMenus.SaveData()
    -- Write to the setting
    ---@type Features.RadialMenus.SaveData
    local data = {
        Protocol = RadialMenus.SAVE_PROTOCOL,
        Menus = {},
    }
    for i,menu in ipairs(RadialMenus.GetMenus()) do
        data.Menus[i] = menu:GetSaveData()
    end
    RadialMenus.Settings.RadialMenus:SetValue(data)
    RadialMenus:SaveSettings()
end

---Loads the user's radial menus from their saved settings.
function RadialMenus.LoadData()
    local data = RadialMenus.Settings.RadialMenus:GetValue() ---@cast data Features.RadialMenus.SaveData
    if not data or not data.Protocol then return end

    -- Remove previous menus
    RadialMenus._Menus = {}

    -- Reinstantiate all menus
    for _,menuData in ipairs(data.Menus) do
        local class = RadialMenus:GetClass(menuData.ClassName) ---@type Features.RadialMenus.Menu
        local menu = class:CreateFromSaveData(menuData)
        RadialMenus.AddMenu(menu)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Execute slot functions.
RadialMenus.Events.SlotUsed:Subscribe(function (ev)
    local slot = ev.Slot
    if slot.Type == "Skill" then -- TODO support controller for all these
        ---@cast slot Features.RadialMenus.Slot.Skill
        Client.PrepareSkill(ev.Character, slot.SkillID)
    elseif slot.Type == "Item" then
        ---@cast slot Features.RadialMenus.Slot.Item
        Hotbar.UseSkill(Item.Get(slot.ItemHandle))
    elseif slot.Type == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        Client.Input.TryExecuteAction(slot.ActionID)
    end
end, {StringID = "DefaultImplementation.Slot.Skill"})

-- Provide name and icons for slots.
RadialMenus.Hooks.GetSlotData:Subscribe(function (ev)
    local slot, slotType = ev.Slot, ev.Slot.Type
    if slotType == "Skill" then
        ---@cast slot Features.RadialMenus.Slot.Skill
        local action = Stats.GetAction(slot.SkillID)
        if action then
            ev.Name = action:GetName()
            ev.Icon = action.Icon
        else -- Regular skill case.
            local skill = Stats.Get("StatsLib_StatsEntry_SkillData", slot.SkillID)
            ev.Name = Text.GetTranslatedString(skill.DisplayName)
            ev.Icon = skill.Icon
        end
    elseif slotType == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        local action = Input.GetAction(slot.ActionID)
        ev.Name = action:GetName()
        ev.Icon = action.Icon
    elseif slotType == "Item" then
        ---@cast slot Features.RadialMenus.Slot.Item
        local item = Item.Get(slot.ItemHandle)
        ev.Name = Item.GetDisplayName(item)
        ev.Icon = Item.GetIcon(item)
    end
end)

-- Load saved data upon entering the session.
GameState.Events.GameReady:Subscribe(function (_)
    RadialMenus.LoadData()
end)
