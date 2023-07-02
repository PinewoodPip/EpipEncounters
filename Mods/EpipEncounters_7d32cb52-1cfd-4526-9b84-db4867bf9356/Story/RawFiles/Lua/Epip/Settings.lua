
---------------------------------------------
-- Registers general settings for Epip.
-- Most of the settings here are remnants from before
-- the SettingsLib rewrite, which is why they are not registered in their
-- respective scripts.
---------------------------------------------

---@class Feature_EpipSettings : Feature
local EpipSettings = {
    TranslatedStrings = {
        EpipLanguage_Name = {
            Handle = "h2b23b849g0345g4d0dgb48dg15315ade1779",
            Text = "Epip Language",
            ContextDescription = "Epip language setting name",
        },
        EpipLanguage_Description = {
            Handle = "h2c6440beg71c6g45c3g8a8bg9f6c64454faf",
            Text = "Changes Epip's language to display in a language different than the one the game is running in.<br>Use to remedy current issues with running EE mods in languages other than English.",
            ContextDescription = "Epip language setting tooltip",
        },

        AutoIdentify_Name = {
            Handle = "h799513e4g3995g4d45g8e0bg3ee08e6cd1db",
            Text = "Auto-Identify Items",
            ContextDescription = "Auto-identify setting name",
        },
        AutoIdentify_Description = {
            Handle = "he0bb8817g7c40g4572g9170gce3d351dc753",
            Text = "Automatically and instantly identify items whenever they are generated.<br>'With enough Loremaster' uses the highest Loremaster of all player characters, regardless of party.",
            ContextDescription = "Auto-identify setting tooltip",
        },
        AutoIdentify_Option_WithLoremaster = {
           Handle = "h00be848dgbfbfg404agabddg983860260ed4",
           Text = "With enough Loremaster",
           ContextDescription = "Autoidentify option",
        },

        ExaminePosition_Name = {
            Handle = "h53b42eecg74ccg4164gbd64g0bda6052e6f1",
            Text = "Examine Menu Position",
            ContextDescription = "Examine menu position setting name",
        },
        ExaminePosition_Description = {
            Handle = "h262d04a1g16d3g4dabg8f01gd68a6b25efc7",
            Text = "Controls the default position of the Examine menu when it is opened.",
            ContextDescription = "Examine menu position setting tooltip",
        },

        Minimap_Name = {
            Handle = "h19c9fc59g789ag4c24gb90ag4858f13e79df",
            Text = "Show Minimap",
            ContextDescription = "Minimap setting name",
        },
        Minimap_Description = {
            Handle = "h7c2f8512g3c4eg4dffg946aga4482de181ae",
            Text = "Toggles visibility of the minimap UI element.",
            ContextDescription = "Minimap setting tooltip",
        },
        
        TreasureTableDisplay_Name = {
            Handle = "hcd9974f8g16cfg4cbfga08agbf28ee5b55eb",
            Text = "Show loot drops in health bar",
            ContextDescription = "Treasure table display setting name",
        },
        TreasureTableDisplay_Description = {
            Handle = "h9cd1245egdfdeg4cbbgbae7gfa179a954eac",
            Text = "If enabled, the health bar when you hover over characters and items will show their treasure table (if relevant) as well as the chance of getting an artifact. For characters, this requires holding the Show Sneak Cones key (shift by default)",
            ContextDescription = "Treasure table display setting tooltip",
        },

        ESCClosesAmerUI_Name = {
            Handle = "h9172c74eg120fg4ea6gac99gf5f558433e70",
            Text = "Escape Key Closes EE UIs",
            ContextDescription = "'ESC closes EE UIs' setting name",
        },
        ESCClosesAmerUI_Description = {
            Handle = "h28a24072g481eg4d1fgaac8gfacbe5243bdb",
            Text = "If enabled, the Escape key will close EE UIs rather than turning back a page.",
            ContextDescription = "'ESC closes EE UIs' setting tooltip",
        },

        RenderShroud_Name = {
            Handle = "h3f4780c9g726bg43c3g8b59gd85d2a0aad07",
            Text = "Show Fog of War",
            ContextDescription = "Render fog of war setting name",
        },
        RenderShroud_Description = {
            Handle = "h00aa4e07g8833g4040g9355g6bed488f1237",
            Text = "Host-only setting. Toggles Fog of War, which hides unexplored areas. This setting applies to all players in the server and is non-destructive; re-enabling it will restore FoW to normal, and all your exploration progress with the setting off will apply.",
            ContextDescription = "Render fog of war setting tooltip",
        },

        WalkOnCorpses_Name = {
            Handle = "h86c94636gb954g4e3dg9679g477c7f889bb3",
            Text = "Allow walking to corpses in combat",
            ContextDescription = "Walk on corpses setting name",
        },
        WalkOnCorpses_Description = {
            Handle = "h49611d79g2ae8g47dcgb20bge13634676cad",
            Text = "Disables looting corpses in combat, unless shift is held. This allows you to easily move to their position.",
            ContextDescription = "Walk on corpses setting tooltip",
        },

        ImprovedCombatLog_Name = {
            Handle = "h01f17781g7f5ag4113g9505g4cba31cd0d07",
            Text = "Improved Combat Log",
            ContextDescription = "Improved combat log setting name",
        },
        ImprovedCombatLog_Description = {
            Handle = "h3eb881efg123fg449bg9718g65ba0891f5bc",
            Text = "Adds improvements to the combat log: custom filters (accessible through right-click), merging messages, and slight rewording to improve consistency.<br>You must reload the save after making changes to this setting.",
            ContextDescription = "Improved combat log setting tooltip",
        },

        AggroInfo_Name = {
            Handle = "h05a930e2g0444g4cd3gacccg34cb46da59c9",
            Text = "Show Aggro Information",
            ContextDescription = "Show aggro information setting name",
        },
        AggroInfo_Description = {
            Handle = "hdf91946ag8402g42ecgafc2g4f2a232b81ef",
            Text = "Adds aggro information to the health bar when hovering over enemies: AI preferred/unpreferred/ignored tag, as well as taunt source/target(s).",
            ContextDescription = "Show aggro information setting tooltip",
        },

        LoadingScreen_Name = {
            Handle = "hbd18d9b1g7709g419agb8d6gdccf938dcaf3",
            Text = "Epic Loading Screen",
            ContextDescription = "Meme loading screen setting name",
        },
        LoadingScreen_Description = {
            Handle = "h4bd4b3d7gf239g412dgb4e9g3421524ff330",
            Text = "Changes the loading screen into a family photoshoot!",
            ContextDescription = "Meme loading screen setting tooltip",
        },

        Hotbar_CombatLogButton_Name = {
            Handle = "h4e5e3786g9b22g4009gaf4egc680d28b83bd",
            Text = "Show Combat Log Button",
            ContextDescription = "Show combat log setting name",
        },
        Hotbar_CombatLogButton_Description = {
            Handle = "h8e644d3dg9c33g4251g9674g48555ee9573b",
            Text = "Shows the combat log button on the right side of the hotbar.<br>If disabled, you can still toggle the combat log through hotbar actions.",
            ContextDescription = "Show combat log setting tooltip",
        },
        Hotbar_HotkeysText_Name = {
            Handle = "h8307bcc5gb35cg4277ga1d6gb9cc9d8d2eed",
            Text = "Show Action Hotkeys",
            ContextDescription = "Hotbar hotkeys text setting name",
        },
        Hotbar_HotkeysText_Description = {
            Handle = "hcda03853g5322g48e6gb8d2g37a87a295fef",
            Text = "Shows the keyboard hotkeys for custom actions.",
            ContextDescription = "Hotbar hotkeys text setting tooltip",
        },
        Hotbar_HotkeysLayout_Name = {
            Handle = "h58774ddfga909g4acfg95e1g9ba772b7be4a",
            Text = "Hotbar Buttons Area Sizing",
            ContextDescription = "Hotbar hotkeys layout setting name",
        },
        Hotbar_HotkeysLayout_Description = {
            Handle = "h063ae4cag4291g4352g88c4gefad4a2e9fe4",
            Text = "Controls the behaviour of the hotbar custom buttons area. 'Automatic' will cause it to switch between the single-row and dual-row layouts based on how many slot rows you have visible. Other settings will make it stick to one layout.",
            ContextDescription = "Hotbar hotkeys layout setting tooltip",
        },
        Hotbar_Greyout_Name = {
            Handle = "hd0e2b5b7geca4g4a5dgad60g1893680e319a",
            Text = "Disable Slots while Casting",
            ContextDescription = "Hotbar greyout setting name",
        },
        Hotbar_Greyout_Description = {
            Handle = "h3da94ae0ge613g4331gb629gb467b74f7ca4",
            Text = "Disables the hotbar slots while a spell is being cast.",
            ContextDescription = "Hotbar greyout setting tooltip",
        },

        WeaponExButton_Name = {
            Handle = "h54022e48gaecfg4b0ega332gd42d4ac64dd4",
            Text = "Show Mastery Button",
            ContextDescription = "WeaponEX button setting name",
        },
        WeaponExButton_Description = {
            Handle = "h058cdfb5g6b63g486bg9e05g413c1cf64d4a",
            Text = "Shows the Mastery button. If disabled, it remains accessible through hotbar actions.",
            ContextDescription = "WeaponEX button setting tooltip",
        },

        Overheads_Size_Name = {
            Handle = "h7d635871g9febg4ee3gbca9g2cedbf770d1e",
            Text = "Overhead Text Size",
            ContextDescription = "Overheads size setting name",
        },
        Overheads_Size_Description = {
            Handle = "h17cf934dg824dg4400g8380g495e3bef019d",
            Text = "Controls the size of regular text above characters talking.<br><br>Default is 19.",
            ContextDescription = "Overheads size setting tooltip",
        },
        Overheads_DamageSize_Name = {
            Handle = "hbd336157gc5fag442fgb2cfgb85f9e2c44fd",
            Text = "Overhead Damage Size",
            ContextDescription = "Overhead damage size setting name",
        },
        Overheads_DamageSize_Description = {
            Handle = "hb53a9902g6a6fg4885ga47cg4329d6de565d",
            Text = "Controls the size of damage overheads.<br><br>Default is 24.",
            ContextDescription = "Overhead damage size setting tooltip",
        },
        Overhead_StatusDuration_Name = {
            Handle = "h37fadbc1g48acg4963gb243gd517a74d58b3",
            Text = "Overhead Status Duration Multiplier",
            ContextDescription = "Overhead status duration setting name",
        },
        Overhead_StatusDuration_Description = {
            Handle = "h832b19aege182g49acgb536gfa969d7669b3",
            Text = "Multiplies the duration of status overheads.<br><br>Default is 1.",
            ContextDescription = "Overhead status duration setting tooltip",
        },

        Chat_MessageSound_Name = {
            Handle = "h3315b640gf25bg45eag8afbgde0e87cba2f5",
            Text = "Message Sound",
            ContextDescription = "Chat message sound setting name",
        },
        Chat_MessageSound_Description = {
            Handle = "hce85d2d7g4957g4a29g8962gb4d42f693e1a",
            Text = "Plays a sound effect when a message is received, so as to make it easier to notice.",
            ContextDescription = "Chat message sound setting tooltip",
        },
        Chat_ExitAfterSendingMessage_Name = {
            Handle = "h315ae29bg868cg4eceg8cc6gebc6623df369",
            Text = "Unfocus after sending messages",
            ContextDescription = "'Exit after message' setting name",
        },
        Chat_ExitAfterSendingMessage_Description = {
            Handle = "h16a650aegefdeg4a47g8abbg044995f9147c",
            Text = "Unfocuses the UI after you send a message, restoring input to the rest of the game.",
            ContextDescription = "'Exit after message' setting tooltip",
        },

        Developer_DebugDisplay_Name = {
            Handle = "hafd62d05gc85eg434bg8f49g68214f14bb72",
            Text = "Debug Display",
            ContextDescription = "Debug display setting name",
        },
        Developer_DebugDisplay_Description = {
            Handle = "hf7dbc203g640cg4c40g8fd3gdd2cf3545672",
            Text = "Enables a UI widget that displays framerate, server tickrate, and mod versions.",
            ContextDescription = "Debug display setting tooltip",
        },
        Developer_SimulateNoEE_Name = {
            Handle = "hbe066f75ge516g49f1g8f3cg328153a5d890",
            Text = "Simulate no EE",
            ContextDescription = "'Simulate no EE' setting name",
        },
        Developer_SimulateNoEE_Description = {
            Handle = "hb74bc767gb91ag4a4cg9d9cg4c574397046c",
            Text = "Causes EpicEncounters.IsLoaded() call to return false even if EE Core is enabled.",
            ContextDescription = "'Simulate no EE' setting tooltip",
        },
        Developer_ForceStoryPatching_Name = {
            Handle = "h3a72d579gc132g43d8gb6f0g097bfdbf76fb",
            Text = "Force Story Patching",
            ContextDescription = "Force story patching setting name",
        },
        Developer_ForceStoryPatching_Description = {
            Handle = "hfd959b44gc01bg403eg95ebg5b17cd08d1ff",
            Text = "Forces story patching on every session load.",
            ContextDescription = "Force story patching setting tooltip",
        },
        Developer_AILogging_Name = {
            Handle = "h44d539cdg17cag473dg98c3gcddc60e27f5b",
            Text = "Log AI Scoring",
            ContextDescription = "AI logging setting name",
        },
        Developer_AILogging_Description = {
            Handle = "he1ba8777g2269g40b6gb21cg353aea79fb9b",
            Text = "Logs AI scoring to the console.",
            ContextDescription = "AI logging setting tooltip",
        },
        Developer_AprilFools_Name = {
            Handle = "ha1fb1fb3g2796g4850gbdb0g727186aa7f71",
            Text = "Out of season April Fools jokes",
            ContextDescription = "Force april fools setting name",
        },
        Developer_AprilFools_Description = {
            Handle = "hfff84bafgd93cg41bagb87fg582303ca13c9",
            Text = "Don't you guys have phones?",
            ContextDescription = "Force april fools setting tooltip",
        },

        PlayerInfo_BH_Name = {
            Handle = "h2ce0c9f6gc6b1g4191g9901g7383f9dbe3ef",
            Text = "Display B/H on player portraits",
            ContextDescription = "Portrait BH setting name",
        },
        PlayerInfo_BH_Description = {
            Handle = "ha13d577fg043ag4324g8d55gd5f2ba85efac",
            Text = "If enabled, Battered and Harried stacks will be shown beside player portraits on the left interface.",
            ContextDescription = "Portrait BH setting tooltip",
        },
        PlayerInfo_StatusHolderOpacity_Name = {
            Handle = "h17251a41gb5a5g412dgb36ag4cfca9cebe22",
            Text = "Status Opacity in Combat",
            ContextDescription = "Portrait status opacity setting name",
        },
        PlayerInfo_StatusHolderOpacity_Description = {
            Handle = "hb62c4354g1648g4f0eg83e9g4c2783e5fc86",
            Text = "Controls the opacity of your character portraits's status bars in combat. Hovering over the statuses will always display them at full opacity.<br><br>Default is 1.",
            ContextDescription = "Portrait status opacity setting tooltip",
        },
        -- TODO
        -- PlayerInfo_EnableSortingFiltering_Name = {
        --     Text = "",
        --     ContextDescription = "Portrait status sorting/filtering setting name",
        -- },
        -- PlayerInfo_EnableSortingFiltering_Description = {
        --     Text = "",
        --     ContextDescription = "Portrait status sorting/filtering setting tooltip",
        -- },
        PlayerInfo_SortingFunction_Name = {
            Handle = "h0aacad96g933cg4888g9f70g832a231c6bad",
            Text = "Sorting Order",
            ContextDescription = "Portrait status sorting setting name",
        },
        PlayerInfo_SortingFunction_Description = {
            Handle = "hd90b74d9g5ae7g49fbg97cdg6b2e0d7fbee8",
            Text = "Determines the order of statuses, in order of importance.",
            ContextDescription = "Portrait status sorting setting tooltip",
        },
        SaveLoadOverlay_Enabled_Name = {
            Handle = "h831d1efeg7f97g4306g9f6fgf0ed6c97bc6f",
            Text = "Save/Load UI Improvements",
            ContextDescription = "Save/load overlay setting name",
        },
        SaveLoadOverlay_Enabled_Description = {
            Handle = "hb7ac349eg981eg4bdega605g533f9a7bea9c",
            Text = "Enables alternative sorting for the save/load UI, as well as searching.",
            ContextDescription = "Save/load overlay setting tooltip",
        },
        SaveLoadOverlay_Sorting_Name = {
            Handle = "hafbe381ag6da6g4760gb278g1b6c5a36f530",
            Text = "Save/Load Sorting",
            ContextDescription = "Save/load overlay sorting setting name",
        },
        SaveLoadOverlay_Sorting_Description = {
            Handle = "h454a0cb5ga2edg439cga8fdg9dde0686c731",
            Text = "Determines sorting in the save/load UI, if improvements for it are enabled.",
            ContextDescription = "Save/load overlay sorting setting tooltip",
        },

        Crafting_DefaultFilter_Name = {
            Handle = "h942bb08bg5e26g439eg8189ga3ece811436f",
            Text = "Default Tab",
            ContextDescription = "Crafting UI default filter setting name",
        },
        Crafting_DefaultFilter_Description = {
            Handle = "h1afda15cgc951g46e6g8aa6g333bc56665ae",
            Text = "Determines the default tab for the crafting UI.",
            ContextDescription = "Crafting UI default filter setting tooltip",
        },

        Inventory_AutoUnlockInventory_Name = {
            Handle = "h5bef00c6g36deg4db0ga3d5gb006dbc5f601",
            Text = "Auto-unlock inventory (Multiplayer)",
            ContextDescription = "Auto-unlock inventory setting name",
        },
        Inventory_AutoUnlockInventory_Description = {
            Handle = "h09f0f7e8gb224g4018g9301g1cf150d5bc20",
            Text = "If enabled, your characters's inventories in multiplayer will be automatically unlocked after a reload.",
            ContextDescription = "Auto-unlock inventory setting tooltip",
        },
        Inventory_InfiniteCarryWeight_Name = {
            Handle = "hd71aa49cgcb72g4cd1ga209g28e6a6159b95",
            Text = "Infinite Carry Weight",
            ContextDescription = "Infinite carry weight setting name",
        },
        Inventory_InfiniteCarryWeight_Description = {
            Handle = "h7fe5f99dgae97g4586ga824g457d7c1322b5",
            Text = "Gives characters practically infinite carry weight.",
            ContextDescription = "Infinite carry weight setting tooltip",
        },
        Inventory_RewardItemComparison_Name = {
            Handle = "h21723370gb5acg4f7bg8628g6b7b3249808c",
            Text = "Show Character Sheet in Reward UI",
            ContextDescription = "Reward UI item comparison setting name",
        },
        Inventory_RewardItemComparison_Description = {
            Handle = "h8945fbb1g7db8g42a8ga6c5g8db176a633ee",
            Text = "Allows you to check all your equipped items while in the quest rewards UI.",
            ContextDescription = "Reward UI item comparison setting tooltip",
        },

        Notifaction_SkillCasting_Name = {
            Handle = "h54361ee5gb59eg40d9g9915g8c47e5631ad9",
            Text = "Skill-casting Notifications",
            ContextDescription = "Skill-casting notifications setting name",
        },
        Notifaction_SkillCasting_Description = {
            Handle = "hca79eaccgc9c9g4a87g9f9egdbfa57800a5a",
            Text = "Controls whether notifications for characters casting skills show up in combat.",
            ContextDescription = "Skill-casting notifications setting tooltip",
        },
        Notification_ItemReceival_Name = {
            Handle = "h1e03cfb3g592dg4698ga246gdc1e34d9915a",
            Text = "Item Notifications",
            ContextDescription = "Item received notification setting name",
        },
        Notification_ItemReceival_Description = {
            Handle = "h6e1d16e8g4adbg4df0g9169g2ceed7a9a8a1",
            Text = "Controls whether notifications for receiving items show.",
            ContextDescription = "Item received notification setting tooltip",
        },
        Notifcation_StatSharing_Name = {
            Handle = "h99515a08gaa1fg4214g81fag15521e601583",
            Text = "Stat-sharing Notifications",
            ContextDescription = "Stat-sharing notification setting name",
        },
        Notifcation_StatSharing_Description = {
            Handle = "hf3f1fedfg8c70g4342g95d7g64f3280f310a",
            Text = "Controls whether notifications for sharing stats (Loremaster, Lucky Charm) show.",
            ContextDescription = "Stat-sharing notification setting tooltip",
        },
        Notification_RegionLabelDuration_Name = {
            Handle = "hf61f1a35g7ee7g4b79g8728g9a278d2522b0",
            Text = "Area Transition Label Duration",
            ContextDescription = "Area transition label setting name",
        },
        Notification_RegionLabelDuration_Description = {
            Handle = "h351cdabfg577fg45e8gbe9dg6a513e599d13",
            Text = "Changes the duration of the label that appears at the top of the screen when you change areas. Set to 0 to disable them entirely.<br><br>Default is 5 seconds.",
            ContextDescription = "Area transition label setting tooltip",
        },

        Tooltip_SimpleTooltipDelay_World_Name = {
            Handle = "h8f7f66d4g1806g478agb229g3f36b527d44d",
            Text = "Simple Tooltip Delay (World)",
            ContextDescription = "Simple world tooltip delay setting name",
        },
        Tooltip_SimpleTooltipDelay_World_Description = {
            Handle = "hb8f2e390g2811g4df4gb9fdg3661092ef520",
            Text = "Controls the delay for simple tooltips to appear while hovering over objects in the world.<br><br>Default is 0.5s.",
            ContextDescription = "Simple world tooltip delay setting tooltip",
        },
        
        WorldTooltip_OpenContainers_Name = {
            Handle = "hb733d1c1g7bc7g4fc5ga090ga2f662e9220d",
            Text = "Open containers",
            ContextDescription = "World tooltip open containers setting name",
        },
        WorldTooltip_OpenContainers_Description = {
            Handle = "hae703884g68c4g44d1gb1d2g211f87e7309c",
            Text = "If enabled, clicking world tooltips will open containers rather than picking them up.",
            ContextDescription = "World tooltip open containers setting tooltip",
        },
        WorldTooltip_HighlightContainers_Name = {
            Handle = "h1437af42g72a6g49cegb64eg044a99447c10",
            Text = "Containers Emphasis",
            ContextDescription = "World tooltip highlight containers setting name",
        },
        WorldTooltip_HighlightContainers_Description = {
            Handle = "he759cd00g404dg4731gb2a6g0ece913a327e",
            Text = "Emphasizes container items in world tooltips.",
            ContextDescription = "World tooltip highlight containers setting tooltip",
        },
        WorldTooltip_HighlightConsumables_Name = {
            Handle = "h63aee58dg36e4g411cg9dcbg541062d696f0",
            Text = "Consumables Emphasis",
            ContextDescription = "World tooltip highlight consumables setting name",
        },
        WorldTooltip_HighlightConsumables_Description = {
            Handle = "h39e2d175g348eg4697g93a5gf28a9544e4ba",
            Text = "Emphasizes consumable items in world tooltips.",
            ContextDescription = "World tooltip highlight consumables setting tooltip",
        },
        WorldTooltip_HighlightEquipment_Name = {
            Handle = "h643f5e4cg0c44g48f7ga003g253a087afa7e",
            Text = "Equipment Emphasis",
            ContextDescription = "World tooltip highlight equipment setting name",
        },
        WorldTooltip_HighlightEquipment_Description = {
            Handle = "hb461a9b1g4866g4bbdgb046gd478f7368fab",
            Text = "Emphasizes equipment items in world tooltips.",
            ContextDescription = "World tooltip highlight equipment setting tooltip",
        },
        WorldTooltip_EmptyContainers_Name = {
            Handle = "he0105763gc21bg4f2ag995bg827864f3db23",
            Text = "Show empty containers/bodies",
            ContextDescription = "World tooltip show empty containers setting name",
        },
        WorldTooltip_EmptyContainers_Description = {
            Handle = "h60bebbb6g771fg4fe8g8658g4b01db6b2d87",
            Text = "Controls whether tooltips are shown for empty containers and bodies.",
            ContextDescription = "World tooltip show empty containers setting tooltip",
        },
        WorldTooltip_ShowSittableAndLadders_Name = {
            Handle = "haa0cd7a5g5950g4cceg8fe0gd343fc6db5e0",
            Text = "Show chairs and ladders",
            ContextDescription = "World tooltip shows chairs and ladders setting name",
        },
        WorldTooltip_ShowSittableAndLadders_Description = {
            Handle = "ha1146687g9261g49d4gad63g0269559fce2d",
            Text = "If enabled, chairs and ladders will show world tooltips. Requires \"Show more items\" to be enabled, as these do not have tooltips by default.",
            ContextDescription = "World tooltip shows chairs and ladders setting tooltip",
        },
        WorldTooltip_ShowDoors_Name = {
            Handle = "h46166b8cg4afbg4039g822dg00fab1a7db15",
            Text = "Show doors",
            ContextDescription = "World tooltip show doors setting name",
        },
        WorldTooltip_ShowDoors_Description = {
            Handle = "h868a6168gd10eg4340gb5f4gb35dc338c453",
            Text = "If enabled, doors will show world tooltips. Requires \"Show more items\" to be enabled, as these do not have tooltips by default.",
            ContextDescription = "World tooltip show doors setting tooltip",
        },
        WorldTooltip_ShowInactionable_Name = {
            Handle = "h854a85fegf878g45a3g98b6g0fff3d5496b7",
            Text = "Show items with no use actions",
            ContextDescription = "World tooltip show inactionable items setting name",
        },
        WorldTooltip_ShowInactionable_Description = {
            Handle = "h0023bed4gd590g4375g80dcgf1e135f30b1e",
            Text = "If enabled, items with no use actions will show world tooltips.",
            ContextDescription = "World tooltip show inactionable items setting tooltip",
        },
        -- TODO description
        WorldTooltip_MoreTooltips_Name = {
            Handle = "hf288311dg0fccg47dcgbc6ag954c4d848835",
            Text = "Enable tooltips for all items",
            ContextDescription = "World tooltip show more items setting name",
        },
    },
}
Epip.RegisterFeature("EpipSettings", EpipSettings)

---@param name string
---@return OptionsSettingsOption
local function CreateHeader(name)
    return {ID = "Header_" .. name, Type = "Header", Label = Text.Format(name, {Color = "7E72D6", Size = 23})}
end

---@type OptionsSettingsOption[]
local Header = {
    {
        ID = "Epip_Hint",
        Type = "Header",
        Label = Text.Format("Most options require a reload for changes to apply.", {Size = 19}),
    },
}

---@type OptionsSettingsOption[]
local Hotbar = {
    CreateHeader("Hotbar"),
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

if Mod.IsLoaded(Mod.GUIDS.WEAPON_EXPANSION) then
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
    CreateHeader("Overheads"),
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
local Chat = {
    CreateHeader("Chat"),
    {
        ID = "Chat_MessageSound",
        Type = "Dropdown",
        Label = "Message Sound",
        Tooltip = "Plays a sound effect when a message is received, so as to make it easier to notice.",
        DefaultValue = 1,
        Options = {
            "None",
            "Sound 1 (Click)",
            "Sound 2 (High-pitched click)",
            "Sound 3 (Synth)",
        }
    },
    {
        ID = "Chat_ExitAfterSendingMessage",
        Type = "Checkbox",
        Label = "Unfocus after sending messages",
        Tooltip = "Unfocuses the UI after you send a message, restoring input to the rest of the game.",
        DefaultValue = false,
    },
}

---@type OptionsSettingsOption[]
local Developer = {
    CreateHeader("Developer"),
    {
        ID = "DEBUG_WarpToAMERTest",
        Type = "Button",
        ServerOnly = true,
        Label = "Warp to AMER_Test",
        Tooltip = "Warp the party to AMER_Test.",
        DefaultValue = false,
    },
    {
        ID = "Developer_DebugDisplay",
        Type = "Checkbox",
        Label = "Debug Display",
        Tooltip = "Enables a UI widget that displays framerate, server tickrate, and mod versions.",
        DefaultValue = false,
        DeveloperOnly = true,
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
    -- CreateHeader("Experimental"),
}

---@type OptionsSettingsOption[]
local OtherOptions = {
    CreateHeader("Other Settings"),
    {
        ID = "RenderShroud",
        Type = "Checkbox",
        ServerOnly = true,
        Label = "Show Fog of War",
        Tooltip = "Host-only setting. Toggles Fog of War, which hides unexplored areas. This setting applies to all players in the server and is non-destructive; re-enabling it will restore FoW to normal, and all your exploration progress with the setting off will apply.",
        DefaultValue = true,
    },
    {
        ID = "Feature_WalkOnCorpses",
        Type = "Checkbox",
        Label = "Allow walking to corpses in combat",
        Tooltip = "Disables looting corpses in combat, unless shift is held. This allows you to easily move to their position.",
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
    CreateHeader("Player Portraits"),
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
        DeveloperOnly = true,
        Label = "Enable sorting/filtering",
        DefaultValue = false,
        Tooltip = Text.Format("Enables the sorting and filtering systems, allowing the settings below to take effect.<br>%s", {
            FormatArgs = {
                Text.Format("Changes to this setting will take effect when the UI is refreshed; for example, when a new status is applied, or when the player portraits are dragged.", {Color = Color.MAGIC_ARMOR})
            }
        }),
    },
    {
        ID = "PlayerInfo_SortingFunction",
        Type = "Dropdown",
        DeveloperOnly = true,
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
        DeveloperOnly = true,
        Label = "Show Source Generation Status",
        DefaultValue = true,
        Tooltip = "Shows the Source Generation status while sorting/filtering is enabled.",
    },
    {
        ID = "PlayerInfo_Filter_BatteredHarried",
        Type = "Checkbox",
        DeveloperOnly = true,
        Label = "Show Battered/Harried Statuses",
        DefaultValue = true,
        Tooltip = "Shows the Battered/Harries statuses while sorting/filtering is enabled.<br>If you disable this, it is recommended to enable the B/H display on the portraits.",
    },
}

local SaveLoadOptions = {
    CreateHeader("Save/Load UI"),
    {
        ID = "SaveLoad_Overlay",
        Type = "Checkbox",
        Label = "Save/Load UI Improvements",
        Tooltip = "Enables alternative sorting for the save/load UI, as well as searching.",
        DefaultValue = false,
    },
    {
        ID = "SaveLoad_Sorting",
        Type = "Dropdown",
        Label = "Save/Load Sorting",
        Tooltip = "Determines sorting in the save/load UI, if improvements for it are enabled.",
        DefaultValue = 1,
        Options = {
            "Date",
            "Alphabetic",
        }
    },
}

local CraftingOptions = {
    CreateHeader("Crafting UI"),
    {
        ID = "Crafting_DefaultFilter",
        Type = "Dropdown",
        Label = "Default Tab",
        Tooltip = "Determines the default tab for the crafting UI.",
        DefaultValue = 1,
        Options = {
            "All",
            "Equipment",
            "Consumables",
            "Magical",
            "Ingredients",
            "Miscellaneous",
        }
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
        ID = "TreasureTableDisplay",
        Type = "Checkbox",
        Label = "Show loot drops in health bar",
        Tooltip = "If enabled, the health bar when you hover over characters and items will show their treasure table (if relevant) as well as the chance of getting an artifact. For characters, this requires holding the Show Sneak Cones key (shift by default)",
        DefaultValue = false,
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

local Inventory = {
    CreateHeader("Inventory"),
    {
        ID = "Inventory_AutoUnlockInventory",
        Type = "Checkbox",
        Label = "Auto-unlock inventory (Multiplayer)",
        Tooltip = "If enabled, your characters's inventories in multiplayer will be automatically unlocked after a reload.",
        DefaultValue = false,
    },
    {
        ID = "Inventory_InfiniteCarryWeight",
        Type = "Checkbox",
        Label = "Infinite Carry Weight",
        Tooltip = "Gives characters practically infinite carry weight.",
        DefaultValue = false,
        ServerOnly = true,
    },
    {
        ID = "Inventory_RewardItemComparison",
        Type = "Checkbox",
        Label = "Show Character Sheet in Reward UI",
        Tooltip = "Allows you to check all your equipped items while in the quest rewards UI.",
        DefaultValue = false,
    },
}

local Notification = {
    CreateHeader("Notifications"),
    {
        ID = "CastingNotifications",
        Type = "Checkbox",
        Label = "Skill-casting Notifications",
        Tooltip = "Controls whether notifications for characters casting skills show up in combat.",
        DefaultValue = true,
    },
    {
        ID = "Notification_ItemReceival",
        Type = "Checkbox",
        Label = "Item Notifications",
        Tooltip = "Controls whether notifications for receiving items show.",
        DefaultValue = true,
    },
    {
        ID = "Notification_StatSharing",
        Type = "Checkbox",
        Label = "Stat-sharing Notifications",
        Tooltip = "Controls whether notifications for sharing stats (Loremaster, Lucky Charm) show.",
        DefaultValue = true,
    },
}

local WorldTooltipsEmphasisColorsDropdown = {
    "None",
    "Blue Label",
    "Green Label",
    "Yellow Label",
    "Orange Label",
}

local WorldTooltipsEmphasisColorsChoices = {
    {ID = 1, Name = "None",},
    {ID = 2, Name = "Blue Label",},
    {ID = 3, Name = "Green Label",},
    {ID = 4, Name = "Yellow Label",},
    {ID = 5, Name = "Orange Label",},
}

local Tooltips = {
    CreateHeader("Tooltips"),
    {
        ID = "Tooltip_SimpleTooltipDelay_World",
        Type = "Slider",
        Label = "Simple Tooltip Delay (World)",
        MinAmount = 0,
        MaxAmount = 4,
        DefaultValue = 0.5,
        Interval = 0.1,
        HideNumbers = false,
        Tooltip = "Controls the delay for simple tooltips to appear while hovering over objects in the world.<br><br>Default is 0.5s.",
    },
    {
        ID = "Tooltip_SimpleTooltipDelay_UI",
        Type = "Slider",
        Label = "Simple Tooltip Delay (UI)",
        MinAmount = 0,
        MaxAmount = 4,
        DefaultValue = 0.1, -- TODO figure out why this doesn't seem to work properly. Causes some tooltips to be "missed" and never show up.
        Interval = 0.1,
        HideNumbers = false,
        Tooltip = "Controls the delay for simple tooltips to appear while hovering over UI elements.<br><br>Default is 0.5s.",
    },
}

local WorldTooltips = {
    CreateHeader("World Item Tooltips"),
    {
        ID = "WorldTooltip_OpenContainers",
        Type = "Checkbox",
        Label = "Open containers",
        Tooltip = "If enabled, clicking world tooltips will open containers rather than picking them up.",
        DefaultValue = false,
    },
    {
        ID = "WorldTooltip_HighlightContainers",
        Type = "Dropdown",
        Label = "Containers Emphasis",
        Tooltip = "Emphasizes container items in world tooltips.",
        DefaultValue = 1,
        Options = WorldTooltipsEmphasisColorsDropdown,
    },
    {
        ID = "WorldTooltip_HighlightConsumables",
        Type = "Dropdown",
        Label = "Consumables Emphasis",
        Tooltip = "Emphasizes consumable items in world tooltips.",
        DefaultValue = 1,
        Options = WorldTooltipsEmphasisColorsDropdown,
    },
    {
        ID = "WorldTooltip_HighlightEquipment",
        Type = "Dropdown",
        Label = "Equipment Emphasis",
        Tooltip = "Emphasizes equipment items in world tooltips.",
        DefaultValue = 1,
        Options = WorldTooltipsEmphasisColorsDropdown,
    },
    {
        ID = "WorldTooltip_EmptyContainers",
        Type = "Checkbox",
        Label = "Show empty containers/bodies",
        Tooltip = "Controls whether tooltips are shown for empty containers and bodies.",
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowSittableAndLadders",
        Type = "Checkbox",
        Label = "Show chairs and ladders",
        Tooltip = "If enabled, chairs and ladders will show world tooltips. Requires \"Show more items\" to be enabled, as these do not have tooltips by default.",
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowDoors",
        Type = "Checkbox",
        Label = "Show doors",
        Tooltip = "If enabled, doors will show world tooltips. Requires \"Show more items\" to be enabled, as these do not have tooltips by default.",
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowInactionable",
        Type = "Checkbox",
        Label = "Show items with no use actions",
        Tooltip = "If enabled, items with no use actions will show world tooltips.",
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_MoreTooltips",
        Type = "Checkbox",
        Label = "Enable tooltips for all items",
        Tooltip = "If enabled, world tooltips will be shown for all items. This includes clutter like doors.<br>" .. Text.Format("Requires a reload.", {Color = Color.LARIAN.YELLOW}),
        DefaultValue = false,
    },
}

local Order = {
    Header,
    TopOptions,
    Hotbar,
    PlayerInfo,
    Inventory,
    Notification,
    Chat,
    Tooltips,
    WorldTooltips,
    Overheads,
    SaveLoadOptions,
    CraftingOptions,
    OtherOptions,
    Experimental,
}

if Epip.IsDeveloperMode() then
    table.insert(Order, 2, Developer)
end

for _,category in ipairs(Order) do
    for _,setting in ipairs(category) do
        Epip.SETTINGS[setting.ID] = setting
    end
end

Epip.SETTINGS_CATEGORIES = Order

local TSKs = EpipSettings.TranslatedStrings

-- New settings declarations
---@type SettingsLib_Setting[]
local newSettings = {
    -- Main Epip settings
    {
        ID = "EpipLanguage",
        Type = "Choice",
        Context = "Client",
        NameHandle = TSKs.EpipLanguage_Name,
        DescriptionHandle = TSKs.EpipLanguage_Description,
        DefaultValue = "",
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = "", Name = "Game Language"},
            {ID = "Russian", Name = "Russian"},
            {ID = "Portuguesebrazil", Name = "Brazilian Portuguese"},
            {ID = "Simplified Chinese", Name = "Simplified Chinese"},
        }
    },
    {
        ID = "AutoIdentify",
        Type = "Choice",
        Context = "Host",
        NameHandle = TSKs.AutoIdentify_Name,
        DescriptionHandle = TSKs.AutoIdentify_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Disabled"},
            {ID = 2, NameHandle = TSKs.AutoIdentify_Option_WithLoremaster.Handle},
            {ID = 3, Name = "Always"},
        }
    },
    {
        ID = "ExaminePosition",
        Type = "Choice",
        NameHandle = TSKs.ExaminePosition_Name,
        DescriptionHandle = TSKs.ExaminePosition_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Center"},
            {ID = 2, Name = "Middle Right"},
            {ID = 3, Name = "Middle Left"},
        }
    },
    {
        ID = "Minimap",
        Type = "Boolean",
        NameHandle = TSKs.Minimap_Name,
        DescriptionHandle = TSKs.Minimap_Description,
        DefaultValue = true,
    },
    {
        ID = "TreasureTableDisplay",
        Type = "Boolean",
        NameHandle = TSKs.TreasureTableDisplay_Name,
        DescriptionHandle = TSKs.TreasureTableDisplay_Description,
        DefaultValue = false,
    },
    {
        ID = "ESCClosesAmerUI",
        Type = "Boolean",
        NameHandle = TSKs.ESCClosesAmerUI_Name,
        DescriptionHandle = TSKs.ESCClosesAmerUI_Description,
        DefaultValue = false,
    },
    {
        ID = "RenderShroud",
        Type = "Boolean",
        Context = "Host",
        NameHandle = TSKs.RenderShroud_Name,
        DescriptionHandle = TSKs.RenderShroud_Description,
        DefaultValue = true,
    },
    {
        ID = "Feature_WalkOnCorpses",
        Type = "Boolean",
        NameHandle = TSKs.WalkOnCorpses_Name,
        DescriptionHandle = TSKs.WalkOnCorpses_Description,
        DefaultValue = true,
    },
    {
        ID = "CombatLogImprovements",
        Type = "Boolean",
        NameHandle = TSKs.ImprovedCombatLog_Name,
        DescriptionHandle = TSKs.ImprovedCombatLog_Description,
        DefaultValue = true,
    },
    {
        ID = "PreferredTargetDisplay",
        Type = "Choice",
        NameHandle = TSKs.AggroInfo_Name,
        DescriptionHandle = TSKs.AggroInfo_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Disabled"},
            {ID = 2, Name = "Show when holding shift"},
            {ID = 3, Name = "Show by default"},
        }
    },
    {
        ID = "LoadingScreen",
        Type = "Boolean",
        NameHandle = TSKs.LoadingScreen_Name,
        DescriptionHandle = TSKs.LoadingScreen_Description,
        DefaultValue = false,
    },

    -- Hotbar settings
    {
        ID = "HotbarCombatLogButton",
        ModTable = "Epip_Hotbar",
        Type = "Boolean",
        NameHandle = TSKs.Hotbar_CombatLogButton_Name,
        DescriptionHandle = TSKs.Hotbar_CombatLogButton_Description,
        DefaultValue = true,
    },
    {
        ID = "HotbarHotkeysText",
        ModTable = "Epip_Hotbar",
        Type = "Boolean",
        NameHandle = TSKs.Hotbar_HotkeysText_Name,
        DescriptionHandle = TSKs.Hotbar_HotkeysText_Description,
        DefaultValue = true,
    },
    {
        ID = "HotbarHotkeysLayout",
        ModTable = "Epip_Hotbar",
        Type = "Choice",
        NameHandle = TSKs.Hotbar_HotkeysLayout_Name,
        DescriptionHandle = TSKs.Hotbar_HotkeysLayout_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Automatic"},
            {ID = 2, Name = "Always One Row"},
            {ID = 3, Name = "Always Two Rows"},
        }
    },
    {
        ID = "HotbarCastingGreyOut",
        ModTable = "Epip_Hotbar",
        Type = "Boolean",
        NameHandle = TSKs.Hotbar_Greyout_Name,
        DescriptionHandle = TSKs.Hotbar_Greyout_Description,
        DefaultValue = true,
    },
    {
        ID = "WEAPONEX_OriginalButton",
        Type = "Boolean",
        NameHandle = TSKs.WeaponExButton_Name,
        DescriptionHandle = TSKs.WeaponExButton_Description,
        DefaultValue = true,
    },

    -- Overhead options
    {
        ID = "OverheadsSize",
        ModTable = "Epip_Overheads",
        Type = "ClampedNumber",
        NameHandle = TSKs.Overheads_Size_Name,
        DescriptionHandle = TSKs.Overheads_Size_Description,
        Min = 10,
        Max = 45,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 19,
    },
    {
        ID = "DamageOverheadsSize",
        ModTable = "Epip_Overheads",
        Type = "ClampedNumber",
        NameHandle = TSKs.Overheads_DamageSize_Name,
        DescriptionHandle = TSKs.Overheads_DamageSize_Description,
        Min = 10,
        Max = 45,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 24,
    },
    {
        ID = "StatusOverheadsDurationMultiplier",
        ModTable = "Epip_Overheads",
        Type = "ClampedNumber",
        NameHandle = TSKs.Overhead_StatusDuration_Name,
        DescriptionHandle = TSKs.Overhead_StatusDuration_Description,
        Min = 0.1,
        Max = 2,
        Step = 0.1,
        HideNumbers = false,
        DefaultValue = 1,
    },

    -- Chat settings
    {
        ID = "Chat_MessageSound",
        Type = "Choice",
        ModTable = "Epip_Chat",
        NameHandle = TSKs.Chat_MessageSound_Name,
        DescriptionHandle = TSKs.Chat_MessageSound_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "None"},
            {ID = 2, Name = "Sound 1 (Click)"},
            {ID = 3, Name = "Sound 2 (High-pitched click)"},
            {ID = 3, Name = "Sound 3 (Synth)"},
        },
    },
    {
        ID = "Chat_ExitAfterSendingMessage",
        Type = "Boolean",
        ModTable = "Epip_Chat",
        NameHandle = TSKs.Chat_ExitAfterSendingMessage_Name,
        DescriptionHandle = TSKs.Chat_ExitAfterSendingMessage_Description,
        DefaultValue = false,
    },

    -- Debug settings
    {
        ID = "Developer_DebugDisplay",
        Type = "Boolean",
        ModTable = "Epip_Developer",
        NameHandle = TSKs.Developer_DebugDisplay_Name,
        DescriptionHandle = TSKs.Developer_DebugDisplay_Description,
        DefaultValue = false,
        DeveloperOnly = true,
    },
    -- TODO remove
    -- {
    --     ID = "DEBUG_SniffUICalls",
    --     Type = "Dropdown",
    --     Label = "Sniff UI Calls",
    --     Tooltip = "Logs ExternalInterface calls to the console, optionally filtered per UI and call. Requires a reload. See Debug/Client/SniffCalls.lua.",
    --     DefaultValue = 1,
    --     Options = {
    --         "Disabled",
    --         "Log Filtered",
    --         "Log All"
    --     }
    -- },
    {
        ID = "DEBUG_ForceStoryPatching",
        Type = "Boolean",
        ModTable = "Epip_Developer",
        Context = "Host",
        NameHandle = TSKs.Developer_ForceStoryPatching_Name,
        DescriptionHandle = TSKs.Developer_ForceStoryPatching_Description,
        DefaultValue = false,
    },
    {
        ID = "Developer_SimulateNoEE",
        Type = "Boolean",
        ModTable = "Epip_Developer",
        Context = "Host",
        NameHandle = TSKs.Developer_SimulateNoEE_Name,
        DescriptionHandle = TSKs.Developer_SimulateNoEE_Description,
        DefaultValue = false,
    },
    {
        ID = "DEBUG_AI",
        Type = "Boolean",
        ModTable = "Epip_Developer",
        Context = "Host",
        NameHandle = TSKs.Developer_AILogging_Name,
        DescriptionHandle = TSKs.Developer_AILogging_Description,
        DefaultValue = false,
    },
    {
        ID = "DEBUG_AprilFools",
        Type = "Boolean",
        ModTable = "Epip_Developer",
        NameHandle = TSKs.Developer_AprilFools_Name,
        DescriptionHandle = TSKs.Developer_AprilFools_Description,
        DefaultValue = false,
    },

    -- PlayerInfo settings
    {
        ID = "PlayerInfoBH",
        Type = "Boolean",
        ModTable = "Epip_PlayerInfo",
        NameHandle = TSKs.PlayerInfo_BH_Name,
        DescriptionHandle = TSKs.PlayerInfo_BH_Description,
        DefaultValue = false,
    },
    {
        ID = "PlayerInfo_StatusHolderOpacity",
        Type = "ClampedNumber",
        ModTable = "Epip_PlayerInfo",
        NameHandle = TSKs.PlayerInfo_StatusHolderOpacity_Name,
        DescriptionHandle = TSKs.PlayerInfo_StatusHolderOpacity_Description,
        Min = 0,
        Max = 1,
        Step = 0.05,
        HideNumbers = false,
        DefaultValue = 1,
    },
    {
        ID = "PlayerInfo_EnableSortingFiltering",
        Type = "Boolean",
        ModTable = "Epip_PlayerInfo",
        DeveloperOnly = true,
        Name = "Enable sorting/filtering",
        DefaultValue = false,
        Description = Text.Format("Enables the sorting and filtering systems, allowing the settings below to take effect.<br>%s", {
            FormatArgs = {
                Text.Format("Changes to this setting will take effect when the UI is refreshed; for example, when a new status is applied, or when the player portraits are dragged.", {Color = Color.MAGIC_ARMOR})
            }
        }),
    },
    {
        ID = "PlayerInfo_SortingFunction",
        Type = "Choice",
        ModTable = "Epip_PlayerInfo",
        DeveloperOnly = true,
        NameHandle = TSKs.PlayerInfo_SortingFunction_Name,
        DescriptionHandle = TSKs.PlayerInfo_SortingFunction_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Descending (important first)"},
            {ID = 2, Name = "Ascending (important last)"},
        },
    },
    {
        ID = "PlayerInfo_Filter_SourceGen",
        Type = "Boolean",
        ModTable = "Epip_PlayerInfo",
        NameHandle = TSKs.PlayerInfo_Filter_SourceGen_Name,
        DescriptionHandle = TSKs.PlayerInfo_Filter_SourceGen_Description,
        DefaultValue = true,
        DeveloperOnly = true,
    },
    {
        ID = "PlayerInfo_Filter_BatteredHarried",
        Type = "Boolean",
        ModTable = "Epip_PlayerInfo",
        NameHandle = TSKs.PlayerInfo_Filter_BatteredHarried_Name,
        DescriptionHandle = TSKs.PlayerInfo_Filter_BatteredHarried_Description,
        DefaultValue = true,
        DeveloperOnly = true,
    },

    -- Save/Load settings
    {
        ID = "SaveLoad_Overlay",
        Type = "Boolean",
        ModTable = "Epip_SaveLoad",
        NameHandle = TSKs.SaveLoadOverlay_Enabled_Name,
        DescriptionHandle = TSKs.SaveLoadOverlay_Enabled_Description,
        DefaultValue = false,
    },
    {
        ID = "SaveLoad_Sorting",
        Type = "Choice",
        ModTable = "Epip_SaveLoad",
        NameHandle = TSKs.SaveLoadOverlay_Sorting_Name,
        DescriptionHandle = TSKs.SaveLoadOverlay_Sorting_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "Date"},
            {ID = 2, Name = "Alphabetic"},
        },
    },

    -- Crafting settings
    {
        ID = "Crafting_DefaultFilter",
        Type = "Choice",
        ModTable = "Epip_Crafting",
        NameHandle = TSKs.Crafting_DefaultFilter_Name,
        DescriptionHandle = TSKs.Crafting_DefaultFilter_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, Name = "All"},
            {ID = 2, Name = "Equipment"},
            {ID = 3, Name = "Consumables"},
            {ID = 4, Name = "Magical"},
            {ID = 5, Name = "Ingredients"},
            {ID = 6, Name = "Miscellaneous"},
        },
    },

    -- Inventory settings
    {
        ID = "Inventory_AutoUnlockInventory",
        Type = "Boolean",
        ModTable = "Epip_Inventory",
        NameHandle = TSKs.Inventory_AutoUnlockInventory_Name,
        DescriptionHandle = TSKs.Inventory_AutoUnlockInventory_Description,
        DefaultValue = false,
    },
    {
        ID = "Inventory_InfiniteCarryWeight",
        Type = "Boolean",
        ModTable = "Epip_Inventory",
        Context = "Host",
        NameHandle = TSKs.Inventory_InfiniteCarryWeight_Name,
        DescriptionHandle = TSKs.Inventory_InfiniteCarryWeight_Description,
        DefaultValue = false,
    },
    {
        ID = "Inventory_RewardItemComparison",
        Type = "Boolean",
        ModTable = "Epip_Inventory",
        NameHandle = TSKs.Inventory_RewardItemComparison_Name,
        DescriptionHandle = TSKs.Inventory_RewardItemComparison_Description,
        DefaultValue = false,
    },

    -- Notification settings
    {
        ID = "CastingNotifications",
        Type = "Boolean",
        ModTable = "Epip_Notifications",
        NameHandle = TSKs.Notifaction_SkillCasting_Name,
        DescriptionHandle = TSKs.Notifaction_SkillCasting_Description,
        DefaultValue = true,
    },
    {
        ID = "Notification_ItemReceival",
        Type = "Boolean",
        ModTable = "Epip_Notifications",
        NameHandle = TSKs.Notification_ItemReceival_Name,
        DescriptionHandle = TSKs.Notification_ItemReceival_Description,
        DefaultValue = true,
    },
    {
        ID = "Notification_StatSharing",
        Type = "Boolean",
        ModTable = "Epip_Notifications",
        NameHandle = TSKs.Notifcation_StatSharing_Name,
        DescriptionHandle = TSKs.Notifcation_StatSharing_Description,
        DefaultValue = true,
    },
    {
        ID = "RegionLabelDuration",
        ModTable = "Epip_Notifications",
        Type = "ClampedNumber",
        NameHandle = TSKs.Notification_RegionLabelDuration_Name,
        DescriptionHandle = TSKs.Notification_RegionLabelDuration_Description,
        Min = 0,
        Max = 5,
        Step = 0.1,
        HideNumbers = false,
        DefaultValue = 5,
    },

    -- Tooltip settings
    {
        ID = "Tooltip_SimpleTooltipDelay_World",
        Type = "ClampedNumber",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.Tooltip_SimpleTooltipDelay_World_Name,
        DescriptionHandle = TSKs.Tooltip_SimpleTooltipDelay_World_Description,
        Min = 0,
        Max = 4,
        DefaultValue = 0.5,
        Step = 0.1,
        HideNumbers = false,
    },
    {
        ID = "Tooltip_SimpleTooltipDelay_UI",
        Type = "ClampedNumber",
        ModTable = "Epip_Tooltips",
        Name = "Simple Tooltip Delay (UI)",
        Description = "Controls the delay for simple tooltips to appear while hovering over UI elements.<br><br>Default is 0.5s.",
        Min = 0,
        Max = 4,
        DefaultValue = 0.1, -- TODO figure out why this doesn't seem to work properly. Causes some tooltips to be "missed" and never show up.
        Step = 0.1,
        HideNumbers = false,
    },

    -- World tooltip settings
    {
        ID = "WorldTooltip_OpenContainers",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_OpenContainers_Name,
        DescriptionHandle = TSKs.WorldTooltip_OpenContainers_Description,
        DefaultValue = false,
    },
    {
        ID = "WorldTooltip_HighlightContainers",
        Type = "Choice",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_HighlightContainers_Name,
        DescriptionHandle = TSKs.WorldTooltip_HighlightContainers_Description,
        DefaultValue = 1,
        Choices = WorldTooltipsEmphasisColorsChoices,
    },
    {
        ID = "WorldTooltip_HighlightConsumables",
        Type = "Choice",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_HighlightConsumables_Name,
        DescriptionHandle = TSKs.WorldTooltip_HighlightConsumables_Description,
        DefaultValue = 1,
        Choices = WorldTooltipsEmphasisColorsChoices,
    },
    {
        ID = "WorldTooltip_HighlightEquipment",
        Type = "Choice",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_HighlightEquipment_Name,
        DescriptionHandle = TSKs.WorldTooltip_HighlightEquipment_Description,
        DefaultValue = 1,
        Choices = WorldTooltipsEmphasisColorsChoices,
    },
    {
        ID = "WorldTooltip_EmptyContainers",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_EmptyContainers_Name,
        DescriptionHandle = TSKs.WorldTooltip_EmptyContainers_Description,
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowSittableAndLadders",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_ShowSittableAndLadders_Name,
        DescriptionHandle = TSKs.WorldTooltip_ShowSittableAndLadders_Description,
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowDoors",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_ShowDoors_Name,
        DescriptionHandle = TSKs.WorldTooltip_ShowDoors_Description,
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_ShowInactionable",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_ShowInactionable_Name,
        DescriptionHandle = TSKs.WorldTooltip_ShowInactionable_Description,
        DefaultValue = true,
    },
    {
        ID = "WorldTooltip_MoreTooltips",
        Type = "Boolean",
        ModTable = "Epip_Tooltips",
        NameHandle = TSKs.WorldTooltip_MoreTooltips_Name,
        Description = "If enabled, world tooltips will be shown for all items. This includes clutter like doors.<br>" .. Text.Format("Requires a reload.", {Color = Color.LARIAN.YELLOW}),
        DefaultValue = false,
    },
}
for _,setting in ipairs(newSettings) do
    setting.Context = setting.Context or "Client"
    setting.ModTable = setting.ModTable or "EpipEncounters"

    Settings.RegisterSetting(setting)
end

-- Update language setting.
-- This is stored in a different manner to allow it to be loaded ASAP.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting
    if setting.ModTable == "EpipEncounters" and setting.ID == "EpipLanguage" then
        IO.SaveFile("Epip/LanguageOverride.txt", ev.Value, true)
    end
end)