
---@type OptionsSettingsOption[]
local Header = {
    -- {
    --     ID = "Epip_Header",
    --     Type = "Header",
    --     Label = "<font color='7e72d6' size='30'>Epip Encounters</font>",
    -- },
    {
        ID = "Epip_Hint",
        Type = "Header",
        Label = Text.Format("Most options require a reload for changes to apply.", {Size = 19}),
    },
}

---@type OptionsSettingsOption[]
local Hotbar = {
    {
        ID = "Epip_Hotbar",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Hotbar</font>",
    },
    -- {
    --     ID = "Hotbar",
    --     Type = "Checkbox",
    --     Label = "Improved Hotbar",
    --     Tooltip = "Enables Epip Encounter's hotbar improvements: multiple rows and customizable hotkey buttons.",
    --     DefaultValue = true,
    -- },
    {
        ID = "HotbarCombatLogButton",
        Type = "Checkbox",
        Label = "Show Vanilla Combat Log Button",
        Tooltip = "Shows the combat log button on the right side of the hotbar.<br>If disabled, you can still toggle the combat log through hotbar actions.",
        DefaultValue = true,
    },
    {
        ID = "HotbarHotkeysText",
        Type = "Checkbox",
        Label = "Show Action Hotkeys",
        Tooltip = "Shows the keyboard hotkeys for custom actions.",
        DefaultValue = true,
    },
    {
        ID = "HotbarHotkeysLayout",
        Type = "Dropdown",
        Label = "Hotbar Buttons Area Sizing",
        Tooltip = "Controls the behaviour of the hotbar custom buttons area. 'Automatic' will cause it to switch between the single-row and dual-row layouts based on how many slot rows you have visible. Other settings will make it stick to one layout.",
        DefaultValue = 1,
        Options = {
            "Automatic",
            "Always One Row",
            "Always Two Rows",
        }
    },
    {
        ID = "HotbarCastingGreyOut",
        Type = "Checkbox",
        Label = "Disable Slots while Casting",
        Tooltip = "Disables the hotbar slots while a spell is being cast.",
        DefaultValue = true,
    },
    -- {
    --     ID = "HotbarRowsQuickToggle",
    --     Type = "Slider",
    --     Label = "Hotbar Quick Toggle Rows",
    --     MinAmount = 1,
    --     MaxAmount = 5,
    --     Interval = 1,
    --     HideNumbers = false,
    --     DefaultValue = 1,
    --     Tooltip = "Controls how many rows will be visible at maximum when you press the 'Toggle Additional Bars' hotkey.",
    -- },
}

if Ext.Mod.IsModLoaded(Data.Mods.WEAPON_EXPANSION) then
    table.insert(Hotbar, {
        ID = "WEAPONEX_OriginalButton",
        Type = "Checkbox",
        Label = "Show Mastery Button",
        Tooltip = "Shows the Mastery button. If disabled, it remains accessible through hotbar actions.",
        DefaultValue = true,
    })
end

---@type OptionsSettingsOption[]
local Overheads = {
    {
        ID = "Epip_Overheads",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Overheads</font>",
    },
    {
        ID = "OverheadsSize",
        Type = "Slider",
        Label = "Overhead Text Size",
        MinAmount = 10,
        MaxAmount = 45,
        DefaultValue = 19,
        Interval = 1,
        HideNumbers = false,
        Tooltip = "Controls the size of regular text above characters talking.<br><br>Default is 19.",
    },
    {
        ID = "DamageOverheadsSize",
        Type = "Slider",
        Label = "Overhead Damage Size",
        MinAmount = 10,
        MaxAmount = 45,
        DefaultValue = 24,
        HideNumbers = false,
        Interval = 1,
        Tooltip = "Controls the size of damage overheads.<br><br>Default is 24.",
    },
    {
        ID = "StatusOverheadsDurationMultiplier",
        Type = "Slider",
        Label = "Overhead Status Duration Multiplier",
        MinAmount = 0.1,
        MaxAmount = 2,
        Interval = 0.1,
        DefaultValue = 1,
        HideNumbers = false,
        Tooltip = "Multiplies the duration of status overheads.<br><br>Default is 1.",
    },
    {
        ID = "RegionLabelDuration",
        Type = "Slider",
        Label = "Area Transition Label Duration",
        MinAmount = 0,
        MaxAmount = 5,
        Interval = 0.1,
        DefaultValue = 5,
        HideNumbers = false,
        Tooltip = "Changes the duration of the label that appears at the top of the screen when you change areas. Set to 0 to disable them entirely.<br><br>Default is 5 seconds.",
    },
}

---@type OptionsSettingsOption[]
local Developer = {
    {
        ID = "Epip_Developer",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Developer</font>",
    },
    {
        ID = "DEBUG_WarpToAMERTest",
        Type = "Button",
        ServerOnly = true,
        Label = "Warp to AMER_Test",
        Tooltip = "Warp the party to AMER_Test.",
        DefaultValue = false,
    },
    {
        ID = "DEBUG_SniffUICalls",
        Type = "Dropdown",
        Label = "Sniff UI Calls",
        Tooltip = "Logs ExternalInterface calls to the console, optionally filtered per UI and call. Requires a reload. See Debug/Client/SniffCalls.lua.",
        DefaultValue = 1,
        Options = {
            "Disabled",
            "Log Filtered",
            "Log All"
        }
    },
    {
        ID = "DEBUG_ForceStoryPatching",
        Type = "Checkbox",
        ServerOnly = true,
        Label = "Force Story Patching",
        Tooltip = "Forces story patching on every session load.",
        DefaultValue = false,
    },
    {
        ID = "DEBUG_AI",
        Type = "Checkbox",
        ServerOnly = true,
        Label = "Log AI Scoring",
        Tooltip = "Logs AI scoring to the console.",
        DefaultValue = false,
    },
    {
        ID = "DEBUG_AprilFools",
        Type = "Checkbox",
        ServerOnly = false,
        Label = "Out of season April Fools jokes",
        Tooltip = "Don't you guys have phones?",
        DefaultValue = false,
    },
    {
        ID = "DBUG_TestServerSetting",
        Type = "Checkbox",
        ServerOnly = true,
        SaveOnServer = true,
        Label = "Test.",
        Tooltip = "Test.",
        DefaultValue = false,
    },
    {
        ID = "TestSelector",
        Type = "Selector",
        Label = "",
        Tooltip = "Test",
        DefaultValue = 1,
        Options = {
            {
                Label = "TestOption 1 asdasd",
                SubSettings = {"OverheadsSize", "DEBUG_AprilFools"},
            },
            {
                Label = "TestOption 2",
                SubSettings = {"AutoIdentify", "DBUG_TestServerSetting"},
            },
        },
    },
    {
        ID = "Epip_Developer_Footer",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Normie settings</font>",
    },
}

---@type OptionsSettingsOption[]
local Experimental = {
    -- {
    --     ID = "Epip_Experimental",
    --     Type = "Header",
    --     Label = "<font color='7e72d6' size='23'>Experimental/WIP</font>",
    -- },
    -- {
    --     ID = "Vanity",
    --     Type = "Checkbox",
    --     Label = "Transmog Context Menu",
    --     Tooltip = "Enables a transmog context menu option.",
    --     DefaultValue = true,
    -- },
}

---@type OptionsSettingsOption[]
local OtherOptions = {
    {
        ID = "Epip_OtherOptions",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Other</font>",
    },
    {
        ID = "RenderShroud",
        Type = "Checkbox",
        ServerOnly = true,
        Label = "Show Fog of War",
        Tooltip = "Host-only setting. Toggles Fog of War, which hides unexplored areas. This setting applies to all players in the server and is non-destructive; re-enabling it will restore FoW to normal, and all your exploration progress with the setting off will apply.",
        DefaultValue = true,
    },
    {
        ID = "CombatLogImprovements",
        Type = "Checkbox",
        Label = "Improved Combat Log",
        Tooltip = "Adds improvements to the combat log: custom filters (accessible through right-click), merging messages, and slight rewording to improve consistency.<br>You must reload the save after making changes to this setting.",
        DefaultValue = false,
    },
    {
        ID = "PreferredTargetDisplay",
        Type = "Dropdown",
        Label = "Show Aggro Information",
        Tooltip = "Adds aggro information to the health bar when hovering over enemies: AI preferred/unpreferred/ignored tag, as well as taunt source/target(s).",
        DefaultValue = 1,
        Options = {
            "Disabled",
            "Show when holding shift",
            "Show by default",
        }
    },
    {
        ID = "LoadingScreen",
        Type = "Checkbox",
        Label = "Epic Loading Screen",
        Tooltip = "Changes the loading screen into a family photoshoot!",
    },
}

local PlayerInfo = {
    {
        ID = "Epip_PlayerInfo",
        Type = "Header",
        Label = "<font color='7e72d6' size='23'>Player Portraits</font>",
    },
    {
        ID = "PlayerInfoBH",
        Type = "Checkbox",
        Label = "Display B/H on player portraits",
        DefaultValue = false,
        Tooltip = "If enabled, Battered and Harried stacks will be shown beside player portraits on the left interface.",
    },
    {
        ID = "PlayerInfo_StatusHolderOpacity",
        Type = "Slider",
        Label = "Status Opacity in Combat",
        MinAmount = 0,
        MaxAmount = 1,
        DefaultValue = 1,
        Interval = 0.05,
        HideNumbers = false,
        Tooltip = "Controls the opacity of your character portraits's status bars in combat. Hovering over the statuses will always display them at full opacity.<br><br>Default is 1.",
    },
    {
        ID = "PlayerInfo_EnableSortingFiltering",
        Type = "Checkbox",
        Developer = true,
        Label = "Enable sorting/filtering",
        DefaultValue = false,
        Tooltip = Text.Format("Enables the sorting and filtering systems, allowing the settings below to take effect.<br>%s", {
            FormatArgs = {
                Text.Format("Changes to this setting will take effect when the UI is refreshed; for example, when a new status is applied, or when the player portraits are dragged.", {Color = Color.COLORS.MAGIC_ARMOR})
            }
        }),
    },
    {
        ID = "PlayerInfo_SortingFunction",
        Type = "Dropdown",
        Developer = true,
        Label = "Sorting Order",
        Tooltip = "Determines the order of statuses, in order of importance.",
        DefaultValue = 1,
        Options = {
            "Descending (important first)",
            "Ascending (important last)",
        }
    },
    {
        ID = "PlayerInfo_Filter_SourceGen",
        Type = "Checkbox",
        Developer = true,
        Label = "Show Source Generation Status",
        DefaultValue = true,
        Tooltip = "Shows the Source Generation status while sorting/filtering is enabled.",
    },
    {
        ID = "PlayerInfo_Filter_BatteredHarried",
        Type = "Checkbox",
        Developer = true,
        Label = "Show Battered/Harried Statuses",
        DefaultValue = true,
        Tooltip = "Shows the Battered/Harries statuses while sorting/filtering is enabled.<br>If you disable this, it is recommended to enable the B/H display on the portraits.",
    },
}

local TopOptions = {
    {
        ID = "AutoIdentify",
        Type = "Dropdown",
        ServerOnly = true,
        Label = "Auto-Identify Items",
        Tooltip = "Automatically and instantly identify items whenever they are generated.<br>'With enough Loremaster' uses the highest Loremaster of all player characters, regardless of party.",
        DefaultValue = 1,
        Options = {
            "Disabled",
            "With enough Loremaster",
            "Always"
        }
    },
    {
        ID = "ImmersiveMeditation",
        Type = "Checkbox",
        Label = "Immersive Meditation",
        Tooltip = "Hides the Hotbar and Minimap while within the Ascension and Greatforge UIs.",
        DefaultValue = false,
    },
    {
        ID = "CastingNotifications",
        Type = "Checkbox",
        Label = "Skill-casting Notifications",
        Tooltip = "Controls whether notifications for characters casting skills show up in combat.",
    },
    {
        ID = "ExaminePosition",
        Type = "Dropdown",
        Label = "Examine Menu Position",
        Tooltip = "Controls the default position of the Examine menu when it is opened.",
        DefaultValue = 1,
        Options = {
            "Center",
            "Middle Right",
            "Middle Left"
        }
    },
    {
        ID = "Minimap",
        Type = "Checkbox",
        Label = "Show Minimap",
        Tooltip = "Toggles visibility of the minimap UI element.",
        DefaultValue = true,
    },
    {
        ID = "AutoUnlockInventory",
        Type = "Checkbox",
        Label = "Auto-unlock inventory (Multiplayer)",
        Tooltip = "If enabled, your characters's inventories in multiplayer will be automatically unlocked after a reload.",
        DefaultValue = true,
    },
    {
        ID = "TreasureTableDisplay",
        Type = "Checkbox",
        Label = "Show loot drops in health bar",
        Tooltip = "If enabled, the health bar when you hover over characters and items will show their treasure table (if relevant) as well as the chance of getting an artifact. For characters, this requires holding the Show Sneak Cones key (shift by default)",
        DefaultValue = false,
    },
    {
        ID = "Minimap",
        Type = "Checkbox",
        Label = "Show Minimap",
        Tooltip = "Toggles visibility of the minimap UI element.",
        DefaultValue = true,
    },
    {
        ID = "CinematicCombat",
        Type = "Checkbox",
        Label = "Cinematic Combat",
        Tooltip = "Adds visual improvements while it is not your turn to improve immersiveness.",
        DefaultValue = false,
    },
    {
        ID = "ESCClosesAmerUI",
        Type = "Checkbox",
        Label = "Escape Key Closes EE UIs",
        Tooltip = "If enabled, the Escape key will close EE UIs rather than turning back a page.",
        DefaultValue = false,
    },
}

local Order = {
    Header,
    TopOptions,
    Hotbar,
    PlayerInfo,
    Overheads,
    OtherOptions,
    Experimental,
}

if Ext.IsDeveloperMode() then
    table.insert(Order, 2, Developer)
end

for i,category in ipairs(Order) do
    for z,setting in ipairs(category) do
        Epip.SETTINGS[setting.ID] = setting
    end
end

Epip.SETTINGS_CATEGORIES = Order