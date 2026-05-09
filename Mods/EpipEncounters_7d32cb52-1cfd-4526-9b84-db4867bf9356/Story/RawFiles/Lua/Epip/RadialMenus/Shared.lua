
---------------------------------------------
-- Implements customizable radial menus that can hold skills, items, Epip keybinds and more.
---------------------------------------------

---@class Features.RadialMenus : Feature
local RadialMenus = {
    NETMSG_TOGGLE_CHAIN = "Features.RadialMenus.NetMsgs.ToggleChain",

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
            Text = "Determines the contents of the new menu.<br>- Hotbar: slots are automatically filled with the contents of the character's hotbar.<br>- Party Members: slots allow switching between party members and chaining them (via shift-click or right trigger + A).<br>- Custom: slots must be manually configured and can hold skills, items or Epip keybinds.",
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
        GetSlotData = {}, ---@type Hook<Features.RadialMenus.Hooks.GetSlotData>
        IsSlotUsable = {}, ---@type Hook<Features.RadialMenus.Hooks.IsSlotUsable>
        IsSlotValid = {}, ---@type Hook<Features.RadialMenus.Hooks.IsSlotValid>
    }
}
Epip.RegisterFeature("Features.RadialMenus", RadialMenus)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.RadialMenus.NetMsgs.ToggleChain : NetLib_Message_Character
---@field TargetNetID CharacterHandle
