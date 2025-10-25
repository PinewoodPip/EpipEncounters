
local Menu = Epip.GetFeature("Feature_SettingsMenu")
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local AnimationCancelling = Epip.GetFeature("Feature_AnimationCancelling")
local StatusesDisplay = Epip.GetFeature("Feature_StatusesDisplay")
local CraftingFixes = Epip.GetFeature("Features.CraftingFixes")
local SkillbookIconsFix = Epip.GetFeature("Features.SkillbookIconsFix")
local InventoryMultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
local DiscordRichPresence = Epip.GetFeature("Features.DiscordRichPresence")
local ContainerInventoryTweaks = Epip.GetFeature("Features.ContainerInventoryTweaks")
local TooltipRepositioning = Epip.GetFeature("Features.TooltipAdjustments.InventoryTooltipsRepositioning")
local TooltipDelay = Epip.GetFeature("Features.TooltipAdjustments.TooltipDelay")
local StatusConsoleDividers = Epip.GetFeature("Features.StatusConsoleDividers")
local HotbarTweaks = Epip.GetFeature("Features.HotbarTweaks")
local CombatLogTweaks = Epip.GetFeature("Features.CombatLogTweaks")
local Vanity = Epip.GetFeature("Feature_Vanity")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local UIOverrideToggles = Epip.GetFeature("Features.UIOverrideToggles")
local FastForwardDialogue = Epip.GetFeature("Features.FastForwardDialogue")
local MinimapToggle = Epip.GetFeature("Feature_MinimapToggle")
local TurnNotifications = Epip.GetFeature("Features.TurnNotifications")
local Input = Client.Input
local CommonStrings = Text.CommonStrings

local QuickExamineWidgets = {
    Statuses = Epip.GetFeature("Features.QuickExamine.Widgets.Statuses"),
    Artifacts = Epip.GetFeature("Features.QuickExamine.Widgets.Artifacts"),
    Skills = Epip.GetFeature("Features.QuickExamine.Widgets.Skills"),
    Equipment = Epip.GetFeature("Features.QuickExamine.Widgets.Equipment"),
}

local InventoryMultiSelectInputActionSettings = {
    ToggleSelection = Input.GetActionBindingSetting(InventoryMultiSelect.InputActions.ToggleSelection),
    SelectRange = Input.GetActionBindingSetting(InventoryMultiSelect.InputActions.SelectRange),
}

local QuickExamineInputActionSettings = {
    Open = Input.GetActionBindingSetting(QuickExamine.InputActions.Open),
}

---@class Feature_EpipSettingsMenu : Feature
local EpipSettingsMenu = {
    LABEL_FONT_SIZE = 19, -- Font size of general info labels.
    BUTTONID_NEXT_TIP = "Info.NextTip",

    TranslatedStrings = {
        WarpToTestLevel = {
            Handle = "h68a80196g2a32g4e12g9757gc826f58efd20",
            Text = "Warp to AMER_Test",
            ContextDescription = "Debug button to warp to test level",
        },
        Subtitle = {
           Handle = "h866e5a46g3002g4c1bgba33g4aaef5ca5413",
           Text = "%s v%s by %s",
           ContextDescription = "Shows in the default tab of the settings menu",
        },
        Label_TipOfTheDay = {
            Handle = "h10e67f1agfadcg40d5ga31ag0cbbe61c180b",
            Text = "Tip of the day",
            ContextDescription = [[Label in "Info" tab]],
        },
        Label_NextTip = {
            Handle = "h890f714agb2d5g4e07gadacg068f217314eb",
            Text = "Next Tip",
            ContextDescription = [[Button in the "Info" tab]],
        },
        Label_SettingsMenuHint = {
            Handle = "h78121f59g7e1bg4d00g8b1eg8065379bf1dc",
            Text = "Use the tabs on the left to browse Epip's configuration settings.",
            ContextDescription = [[Hint in the "Info" tab]],
        },
        SettingApplicationWarning = {
           Handle = "h4a3e28fag3595g4753gb507g4423068aeda8",
           Text = "Some settings may require a reload for changes to apply. You'll be warned when this is the case.",
           ContextDescription = "Warning at the top of the settings menu",
        },
        Credits_Main = {
            Handle = "hae3e6bddg3af0g4355gb90ag512c668df8a9",
            Text = "Design & programming by PinewoodPip<br>Additional UI art by Elric",
            ContextDescription = [[Credits in the "Info" tab]],
        },
        Credits_SpecialThanks = {
            Handle = "hf25b230cg35fbg4142g8b49g40c4989cae08",
            Text = [[Special thanks to Ameranth & Elric, Norbyte, all Cathes (Cathe, Bun, JoienReid), Derpy Moa, Clibanarius, AQUACORAL, Zares, and the entire Epic Encounters community]],
            ContextDescription = [[Credits in the "Info" tab]],
        },
        Header_Translations = {
            Handle = "hb19f4840g3f0bg486ag8510g605da376dbff",
            Text = "Translation Credits",
            ContextDescription = [[Header in the "Info" tab]],
        },
        TranslationCredits_Russian = {
           Handle = "hbce14cb2g1ed7g4076g95d1gb80c6085c3ad",
           Text = "Russian translation by JoienReid & Cathe",
           ContextDescription = "Displayed at the bottom of the info Epip settings tab",
        },
        TranslationCredits_BrazilianPortuguese = {
           Handle = "h0e034a16gd835g46bcga5bfgd44c3f88a36e",
           Text = "Brazilian Portuguese translation by Ferocidade",
           ContextDescription = "Displayed at the bottom of the info Epip settings tab",
        },
        TranslationCredits_SimplifiedChinese = {
           Handle = "h98c83d5fgd30dg41f6g825ag14707c6db182",
           Text = "Simplified Chinese translation by Ainsky & HeiMao",
           ContextDescription = "Displayed at the bottom of the info Epip settings tab",
        },
        TranslationCredits_French = {
            Handle = "h5b1b94ebg3d90g47e5g8b29g9f75c0aa6cd6",
            Text = "French translation by Bern', Drayander & Ostheboss",
            ContextDescription = "Displayed at the bottom of the info Epip settings tab",
        },
        TranslationCredits_Spanish = {
            Handle = "hb6222658gfc63g4d1ag8c41g71f86ef5ec99",
            Text = "Spanish translation by AquaVXI",
            ContextDescription = [[Displayed at the bottom of the info Epip settings tab]],
        },
        TranslationCredits_Polish = {
            Handle = "hc7d35703gbf43g4f19ga94dg590f99309514",
            Text = "Polish translation by Nektun",
            ContextDescription = [[Displayed at the bottom of the info Epip settings tab]],
        },
        Tab_Hotbar = {
           Handle = "h37985411gc95dg46a1g858bg021ed39e43cd",
           Text = "Hotbar",
           ContextDescription = "Tab name for hotbar settings",
        },
        Tab_Hotbar_Description = {
            Handle = "h43088c55g78c4g4cadg90ceg15b4b979274f",
            Text = "Customize the Hotbar and related widgets.",
            ContextDescription = [[Description for the Hotbar settings tab]],
        },
        Tab_Tooltips_Description = {
            Handle = "hbe7663beg1066g45bag9dbcg27bdf6d18421",
            Text = "Customize tooltip behaviours and which items display world tooltips.",
            ContextDescription = [[Description for the "Tooltips" settings tab]],
        },
        Tab_MiscUI = {
           Handle = "hde49d383g961eg49d6gaa46gcc45ab299aa5",
           Text = "Miscellaneous UI",
           ContextDescription = "Settings tab name",
        },
        Tab_MiscUI_Description = {
            Handle = "h13bbc4f0g191dg485eg990agd6f5ec58c4d7",
            Text = "Customize various other UIs and widgets.",
            ContextDescription = [[Description for the "Miscellaneous UI" settings tab]],
        },
        Tab_EpicEncounters_Description = {
            Handle = "h3b085ee9g7e53g4d41gb55fg7c035b5a44d1",
            Text = "Settings specific to Epic Encounters 2.",
            ContextDescription = [[Description for the "Epic Encounters" settings tab]],
        },
        Tab_MiscQoL = {
            Handle = "ha2808031g83f4g48d6g8304gabe840372382",
            Text = "Miscellaneous QoL",
            ContextDescription = [[Settings tab name; "QoL" is short for "Quality of life"]],
        },
        Tab_MiscQoL_Description = {
            Handle = "h96ed79f6gc2cdg4355g83bcg8bca076dc98c",
            Text = "Customize various quality of life features unrelated to UIs.",
            ContextDescription = [[Description for the "Miscellaneous QoL" settings tab]],
        },
        Section_Overheads = {
           Handle = "h6ba9c31fgd5d1g4563gb72eg32f83bcb1302",
           Text = "Overheads",
           ContextDescription = "Settings menu section name",
        },
        Section_SaveLoadUI = {
           Handle = "he1539138g972fg4dffg9026gb1624ae59da1",
           Text = "Save/Load UI",
           ContextDescription = "Settings menu section name",
        },
        Section_PlayerInfo = {
           Handle = "he0473fbcg6b57g48aegb3c0g7bb24b1e0393",
           Text = "Player Portraits",
           ContextDescription = "Settings menu section name",
        },
        Tab_PlayerInfo_Description = {
            Handle = "ha407da41gc23dg48d6g84e7gcf7d32870e47",
            Text = "Customize the player portraits UI on the side of the screen and its status bars.",
            ContextDescription = [[Description for the "Player Portraits" settings tab]],
        },
        Section_UITooltips = {
           Handle = "hd34a81ecg7b8eg4ad6g8fc4gf6310e5ae556",
           Text = "UI Tooltips",
           ContextDescription = "Settings section name",
        },
        Section_InventoryUI = {
           Handle = "hc574348cg706eg4618g9629g6a08ad4aed70",
           Text = "Inventory UI",
           ContextDescription = "Settings section name",
        },
        Tab_Inventory_Description = {
            Handle = "hd4768ef1g4729g4cd6gbcdag38396e85cff3",
            Text = "Customize inventory UIs.",
            ContextDescription = [[Description for the "Inventory UI" settings tab]],
        },
        Tab_Notifications_Description = {
            Handle = "h6f4a5e88g9ac4g4d9dg9788g6f16cc3f7a82",
            Text = "Customize notification messages.",
            ContextDescription = [[Description for the "Notifications" settings tab]],
        },
        Section_WorldItemTooltips = {
           Handle = "had9e68fbgbd66g4141gab13gd1b41046c493",
           Text = "World Item Tooltips",
           ContextDescription = "Settings section name",
        },
        Section_CraftingUI = {
           Handle = "h39849f5cga570g43bcg9258gf0c20c6f7e75",
           Text = "Crafting UI",
           ContextDescription = "Settings section name",
        },
        Section_Navigation = {
            Handle = "h663df9f7g47dcg4de4g9178gdea692da71a9",
            Text = "Keyboard & Controller UI Navigation",
            ContextDescription = [[Settings menu section name]],
        },
    }
}
Epip.RegisterFeature("EpipSettingsMenu", EpipSettingsMenu)
local TSK = EpipSettingsMenu.TranslatedStrings

---Creates a header for dividing sections.
---@param name string|TextLib_TranslatedString
---@return Feature_SettingsMenu_Entry_Label
local function CreateHeader(name)
    if type(name) == "table" then
        name = name:GetString()
    end
    return {Type = "Label", Label = Text.Format(name, {Color = "7E72D6", Size = 23})}
end

---Creates a standard information label.
---@param str TextLib.String
---@return Feature_SettingsMenu_Entry_Label
local function CreateLabel(str)
    return {Type = "Label", Label = Text.Format(Text.Resolve(str), {Size = EpipSettingsMenu.LABEL_FONT_SIZE})}
end

---Creates an entry for a setting.
---@param setting SettingsLib_Setting
---@return Feature_SettingsMenu_Entry_Setting
local function CreateSettingEntry(setting)
    return {Type = "Setting", Module = setting.ModTable, ID = setting:GetID()}
end

---Creates an entry for settings within the legacy "EpipEncounters" module.
---@param id string
---@return Feature_SettingsMenu_Entry_Setting
local function CreateLegacySettingEntry(id)
    return {Type = "Setting", Module = "EpipEncounters", ID = id}
end

---@type table<string, Feature_SettingsMenu_Tab>
local tabs = {
    ["EpipEncounters"] = {
        ID = "EpipEncounters",
        ButtonLabel = CommonStrings.Info:GetString(),
        HeaderLabel = CommonStrings.Info:GetString(),
        Entries = {
            -- Main header and settings menu hint(s)
            {Type = "Label", Label = Text.Format(TSK.Subtitle:GetString(), {
                Size = 23,
                FormatArgs = {
                    {Text = CommonStrings.Epip:GetString(), Color = Color.TEAM_PINEWOOD.PIP_PURPLE},
                    Epip.VERSION,
                    {Text = CommonStrings.TeamPinewood:GetString(), Color = Color.TEAM_PINEWOOD.LIGHT_GREEN},
                },
            })},
            CreateLabel(TSK.Label_SettingsMenuHint),
            CreateLabel(TSK.SettingApplicationWarning),

            CreateLegacySettingEntry("EpipLanguage"),

            -- Tips
            CreateLabel("——————————————————————————————"),
            CreateHeader(TSK.Label_TipOfTheDay),
            {Type = "Tip"},
            {Type = "Button", ID = EpipSettingsMenu.BUTTONID_NEXT_TIP, Label = TSK.Label_NextTip:GetString(), Tooltip = ""},
            {Type = "Setting", Module = "EpipEncounters_Features.Tips", ID = "ShowInLoadingScreen"}, -- Annoying case due to the feature itself needing to load very late.

            -- Credits
            CreateLabel("——————————————————————————————"),
            CreateHeader(CommonStrings.Credits),
            CreateLabel(TSK.Credits_Main),
            CreateLabel(TSK.Credits_SpecialThanks),
            CreateLabel("——————————————————————————————"),
            CreateHeader(TSK.Header_Translations),
            CreateLabel(TSK.TranslationCredits_Russian),
            CreateLabel(TSK.TranslationCredits_BrazilianPortuguese),
            CreateLabel(TSK.TranslationCredits_SimplifiedChinese),
            CreateLabel(TSK.TranslationCredits_French),
            CreateLabel(TSK.TranslationCredits_Spanish),
            CreateLabel(TSK.TranslationCredits_Polish),
        }
    },
    ["Epip.EpicEncounters"] = {
        ID = "Epip.EpicEncounters",
        ButtonLabel = "Epic Encounters", -- Not necessary to be translatable.
        HeaderLabel = "Epic Encounters",
        Entries = {
            CreateLabel(TSK.Tab_EpicEncounters_Description),

            {Type = "Setting", Module = "EpipEncounters_ImmersiveMeditation", ID = "Enabled"},
            {Type = "Setting", Module = "EpipEncounters", ID = "ESCClosesAmerUI"},
        },
    },
    ["Epip_Hotbar"] = {
        ID = "Epip_Hotbar",
        ButtonLabel = TSK.Tab_Hotbar:GetString(),
        HeaderLabel = TSK.Tab_Hotbar:GetString(),
        Entries = {
            CreateHeader(TSK.Tab_Hotbar),
            CreateLabel(TSK.Tab_Hotbar_Description),
            "HotbarCombatLogButton",
            "HotbarHotkeysText",
            "HotbarHotkeysLayout",
            "HotbarCastingGreyOut",
            {Type = "Setting", Module = HotbarTweaks:GetNamespace(), ID = HotbarTweaks.Settings.AllowDraggingUnlearntSkills:GetID()},
            {Type = "Setting", Module = HotbarTweaks:GetNamespace(), ID = HotbarTweaks.Settings.SlotKeyboardModifiers:GetID()},
            {Type = "Setting", Module = StatusConsoleDividers:GetNamespace(), ID = StatusConsoleDividers.Settings.DividerInterval:GetID()},
        }
    },
    ["Features.Vanity"] = {
        ID = "Features.Vanity",
        ButtonLabel = Vanity.TranslatedStrings.FeatureName:GetString(),
        HeaderLabel = Vanity.TranslatedStrings.FeatureName:GetString(),
        Entries = {
            CreateHeader(Vanity.TranslatedStrings.FeatureName:GetString()),
            {Type = "Label", Label = Vanity.TranslatedStrings.SettingsMenu_Description:Format({Size = 19})},
            CreateSettingEntry(Vanity.Settings.RevertAppearanceOnUnequip),
        }
    },
    ["Epip_QuickExamine"] = {
        ID = "Epip_QuickExamine",
        ButtonLabel = QuickExamine.TranslatedStrings.Name:GetString(),
        HeaderLabel = QuickExamine.TranslatedStrings.Name:GetString(),
        Entries = {
            CreateHeader(QuickExamine.TranslatedStrings.Name),
            CreateLabel(QuickExamine.TranslatedStrings.Description),

            -- Keybind
            {Module = QuickExamineInputActionSettings.Open.ModTable, ID = QuickExamineInputActionSettings.Open:GetID()},

            -- Settings
            CreateSettingEntry(QuickExamine.Settings.AllowDead),
            CreateSettingEntry(QuickExamine.Settings.Opacity),
            CreateSettingEntry(QuickExamine.Settings.Width),
            CreateSettingEntry(QuickExamine.Settings.Height),

            -- Widgets
            CreateSettingEntry(QuickExamineWidgets.Statuses.Settings.Enabled),
            CreateSettingEntry(QuickExamineWidgets.Skills.Settings.Enabled),
            CreateSettingEntry(QuickExamineWidgets.Equipment.Settings.Enabled),
            CreateSettingEntry(QuickExamineWidgets.Equipment.Settings.SlotOrder),

            {Type = "Button", ID = "QuickExamine_SaveDefaultPosition", Label = QuickExamine.TranslatedStrings.SavePosition:GetString(), Tooltip = QuickExamine.TranslatedStrings.SavePositionTooltip:GetString()},
        }
    },
    ["Epip_Other"] = {
        ID = "Epip_Other",
        ButtonLabel = TSK.Tab_MiscUI:GetString(),
        HeaderLabel = TSK.Tab_MiscUI:GetString(),
        Entries = {
            CreateLabel(TSK.Tab_MiscUI_Description),

            CreateHeader(CommonStrings.General),
            {Module = "EpipEncounters_Features.UILayout", ID = "Enabled"},

            -- Enemy health bar
            CreateHeader(CommonStrings.HealthBars),
            {Type = "Setting", Module = "EpipEncounters_Features.EnemyHealthBarExtraInfo", ID = "Mode"},
            {Type = "Setting", Module = "EpipEncounters_Features.EnemyHealthBarExtraInfo", ID = "ResistancesDisplay"},
            "PreferredTargetDisplay",
            {Type = "Setting", Module = "EpipEncounters_FlagsDisplay", ID = "Enabled"},
            {Type = "Setting", Module = "EpipEncounters_TreasureTableDisplay", ID = "Enabled"},

            -- Overheads
            CreateHeader(TSK.Section_Overheads),
            {Module = "Epip_Overheads", ID = "OverheadsSize"},
            {Module = "Epip_Overheads", ID = "DamageOverheadsSize"},
            {Module = "Epip_Overheads", ID = "StatusOverheadsDurationMultiplier"},
            {Module = "Epip_Notifications", ID = "RegionLabelDuration"},

            -- Navigation
            CreateHeader(TSK.Section_Navigation),
            CreateSettingEntry(Navbar.Settings.EnabledForKeyboard),
            CreateSettingEntry(Navbar.Settings.EnabledForController),
            CreateSettingEntry(Navbar.Settings.GlyphStyle),

            -- Dialogue
            CreateHeader(CommonStrings.Dialogue),
            CreateSettingEntry(Input.GetActionBindingSetting(FastForwardDialogue.InputActions.FastForward)),
            CreateSettingEntry(FastForwardDialogue.Settings.Strategy),

            -- Combat log
            CreateHeader(CommonStrings.CombatLog),
            {Type = "Setting", Module = "EpipEncounters", ID = "CombatLogImprovements"},
            CreateSettingEntry(CombatLogTweaks.Settings.ImproveDamageTypeContrast),

            -- Minimap
            CreateHeader(CommonStrings.Minimap),
            {Type = "Setting", Module = "EpipEncounters", ID = "Minimap"},
            CreateSettingEntry(Input.GetActionBindingSetting(MinimapToggle.InputActions.Toggle)),

            -- Examine
            CreateHeader(CommonStrings.ExamineUI),
            {Type = "Setting", Module = "EpipEncounters", ID = "ExaminePosition"},

            -- Chat
            CreateHeader(CommonStrings.Chat),
            {Module = "Epip_Chat", ID = "Chat_MessageSound"},
            {Module = "Epip_Chat", ID = "Chat_ExitAfterSendingMessage"},

            -- Skillbook
            CreateHeader(CommonStrings.Skills),
            CreateSettingEntry(SkillbookIconsFix.Settings.Enabled),

            -- Save/load
            CreateHeader(TSK.Section_SaveLoadUI),
            {Module = "Epip_SaveLoad", ID = "SaveLoad_Overlay"},
            {Module = "Epip_SaveLoad", ID = "SaveLoad_Sorting"},

            -- Discord Rich Presence
            CreateHeader(DiscordRichPresence.TranslatedStrings.Label_RichPresence),
            {Module = DiscordRichPresence:GetNamespace(), ID = DiscordRichPresence.Settings.Mode:GetID()},
            {Module = DiscordRichPresence:GetNamespace(), ID = DiscordRichPresence.Settings.CustomLine1:GetID()},
            {Module = DiscordRichPresence:GetNamespace(), ID = DiscordRichPresence.Settings.CustomLine2:GetID()},

            -- Mod compatibility
            CreateHeader(CommonStrings.Compatibility),
            {Type = "Label", Label = Text.Format(UIOverrideToggles.TranslatedStrings.Label_SettingsMenuHint:GetString(), {
                Size = 19,
            })},
            CreateSettingEntry(UIOverrideToggles.Settings.EnableCharacterSheetOverride),
            CreateSettingEntry(UIOverrideToggles.Settings.EnablePlayerInfoOverride),
        }
    },
    ["Epip.MiscellaneousQol"] = {
        ID = "Epip.MiscellaneousQol",
        ButtonLabel = TSK.Tab_MiscQoL:GetString(),
        HeaderLabel = TSK.Tab_MiscQoL:GetString(),
        Entries = {
            CreateHeader(TSK.Tab_MiscQoL),
            CreateLabel(TSK.Tab_MiscQoL_Description),

            CreateLegacySettingEntry("AutoIdentify"),
            {Type = "Setting", Module = "Epip_Inventory", ID = "Inventory_InfiniteCarryWeight"},
            CreateLegacySettingEntry("RenderShroud"),
            CreateLegacySettingEntry("Feature_WalkOnCorpses"),
        }
    },
    ["Epip_Developer"] = {
        ID = "Epip_Developer",
        ButtonLabel = CommonStrings.Developer:GetString(),
        HeaderLabel = CommonStrings.Developer:GetString(),
        DeveloperOnly = true,
        Entries = {
            CreateHeader(CommonStrings.Developer),
            {Type = "Button", Label = EpipSettingsMenu.TranslatedStrings.WarpToTestLevel:GetString(), ID = "DEBUG_WarpToAMERTest", Tooltip = ""},
            "Developer_DebugDisplay",
            "Developer_SimulateNoEE",
            "DEBUG_ForceStoryPatching",
            "DEBUG_AI",
            "DEBUG_AprilFools",
        }
    },
    ["Epip_PlayerInfo"] = {
        ID = "Epip_PlayerInfo",
        ButtonLabel = TSK.Section_PlayerInfo:GetString(),
        HeaderLabel = TSK.Section_PlayerInfo:GetString(),
        Entries = {
            CreateHeader(TSK.Section_PlayerInfo),
            CreateLabel(TSK.Tab_PlayerInfo_Description),

            "PlayerInfoBH",
            "PlayerInfo_StatusHolderOpacity",
            {Module = StatusesDisplay:GetSettingsModuleID(), ID = StatusesDisplay.Settings.Enabled.ID},
            {Module = StatusesDisplay:GetSettingsModuleID(), ID = StatusesDisplay.Settings.ShowSourceGeneration.ID},
            {Module = StatusesDisplay:GetSettingsModuleID(), ID = StatusesDisplay.Settings.ShowBatteredHarried.ID},
            {Module = StatusesDisplay:GetSettingsModuleID(), ID = StatusesDisplay.Settings.FilteredStatuses.ID},
        }
    },
    ["Epip_Inventory"] = {
        ID = "Epip_Inventory",
        ButtonLabel = CommonStrings.Inventory:GetString(),
        HeaderLabel = CommonStrings.Inventory:GetString(),
        Entries = {
            CreateLabel(TSK.Tab_Inventory_Description),
            CreateHeader(TSK.Section_InventoryUI),

            {Module = InventoryMultiSelect:GetNamespace(), ID = InventoryMultiSelect.Settings.Enabled.ID},
            {Module = InventoryMultiSelectInputActionSettings.ToggleSelection.ModTable, ID = InventoryMultiSelectInputActionSettings.ToggleSelection:GetID()},
            {Module = InventoryMultiSelectInputActionSettings.SelectRange.ModTable, ID = InventoryMultiSelectInputActionSettings.SelectRange:GetID()},

            "Inventory_AutoUnlockInventory",
            "Inventory_RewardItemComparison",
            {Module = ContainerInventoryTweaks:GetNamespace(), ID = ContainerInventoryTweaks.Settings.HighlightEmptySlots:GetID()},

            CreateHeader(QuickInventory.TranslatedStrings.Header:GetString()),
            {Type = "Label", Label = Text.Format(QuickInventory.TranslatedStrings.SettingsMenuInfo:GetString(), {Size = 19})},
            {Module = QuickInventory:GetSettingsModuleID(), ID = QuickInventory.Settings.CloseAfterUsing.ID},
            {Module = QuickInventory:GetSettingsModuleID(), ID = QuickInventory.Settings.CloseOnClickOutOfBounds.ID},

            CreateHeader(TSK.Section_CraftingUI),
            {Module = CraftingFixes:GetNamespace(), ID = CraftingFixes.Settings.DefaultFilter.ID},
        }
    },
    ["Epip_Notifications"] = {
        ID = "Epip_Notifications",
        ButtonLabel = CommonStrings.Notifications:GetString(),
        HeaderLabel = CommonStrings.Notifications:GetString(),
        Entries = {
            CreateHeader(CommonStrings.Notifications:GetString()),
            CreateLabel(TSK.Tab_Notifications_Description),

            "CastingNotifications",
            "Notification_ItemReceival",
            "Notification_StatSharing",
            CreateSettingEntry(TurnNotifications.Settings.Enabled),
            {Type = "Setting", Module = "EpipEncounters_DialogueTweaks", ID = "Enabled"},
            {Type = "Setting", Module = "EpipEncounters_DialogueTweaks", ID = "AutoListen"},
            {Type = "Setting", Module = "EpipEncounters_DialogueTweaks", ID = "AutoListenRangeLimit"},
        }
    },
    ["Epip_Tooltips"] = {
        ID = "Epip_Tooltips",
        ButtonLabel = CommonStrings.Tooltips:GetString(),
        HeaderLabel = CommonStrings.Tooltips:GetString(),
        Entries = {
            CreateLabel(TSK.Tab_Tooltips_Description),
            CreateHeader(TSK.Section_UITooltips),

            "Tooltip_SimpleTooltipDelay_World",
            "Tooltip_SimpleTooltipDelay_UI",
            {Module = TooltipRepositioning:GetNamespace(), ID = TooltipRepositioning.Settings.Position:GetID()},
            {Module = TooltipDelay:GetNamespace(), ID = TooltipDelay.Settings.ItemTooltipDelay:GetID()},
            {Module = TooltipDelay:GetNamespace(), ID = TooltipDelay.Settings.CompareTooltipDelay:GetID()},

            CreateHeader(TSK.Section_WorldItemTooltips),
            "WorldTooltip_MoreTooltips",
            "WorldTooltip_OpenContainers",
            "WorldTooltip_HighlightContainers",
            "WorldTooltip_HighlightConsumables",
            "WorldTooltip_HighlightEquipment",
            "WorldTooltip_EmptyContainers",
            "WorldTooltip_ShowSittableAndLadders",
            "WorldTooltip_ShowDoors",
            {Module = "EpipEncounters_WorldTooltipFiltering", ID = "ShowLights"},
            "WorldTooltip_ShowInactionable",

            CreateHeader(TooltipAdjustments.TranslatedStrings.Name),
            {Module = "EpipEncounters_TooltipAdjustments.AstrologerFix", ID = "Enabled"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "DamageTypeDeltamods"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "RewardGenerationWarning"},
            {Module = "EpipEncounters_TooltipAdjustments.RuneCraftingHint", ID = "Enabled"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "SurfaceTooltips"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "WeaponRangeDeltamods"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "RemoveSetPrefixes"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "StatusImprovements"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "TooltipLayer"},
            {Module = "EpipEncounters_TooltipAdjustments.MasterworkedHint", ID = "Enabled"},
            {Module = "EpipEncounters_TooltipAdjustments.ContainerPreview", ID = "DetailedItemsAmount"},
            {Module = "EpipEncounters_TooltipAdjustments.OpaqueBackground", ID = "Enabled"},
        }
    },
    ["Features.QuickLoot"] = {
        ID = "Features.QuickLoot",
        ButtonLabel = QuickLoot.TranslatedStrings.Label_FeatureName:GetString(),
        HeaderLabel = QuickLoot.TranslatedStrings.Label_FeatureName:GetString(),
        Entries = {
            CreateHeader(QuickLoot.TranslatedStrings.Label_FeatureName),
            {Type = "Label", Label = QuickLoot.TranslatedStrings.Label_FeatureDescription:Format({Size = 19})},
            CreateSettingEntry(Input.GetActionBindingSetting(QuickLoot.InputActions.Search)),
            CreateSettingEntry(QuickLoot.Settings.BaseRadius),
            CreateSettingEntry(QuickLoot.Settings.LootingEffect),
            CreateHeader(CommonStrings.Filters),
            CreateSettingEntry(QuickLoot.Settings.FilterMode),
            CreateSettingEntry(QuickLoot.Settings.MinEquipmentRarity),
            CreateSettingEntry(QuickLoot.Settings.ShowConsumables),
            CreateSettingEntry(QuickLoot.Settings.ShowFoodAndDrinks),
            CreateSettingEntry(QuickLoot.Settings.ShowIngredients),
            CreateSettingEntry(QuickLoot.Settings.ShowBooks),
            CreateSettingEntry(QuickLoot.Settings.ShowClutter),
            CreateSettingEntry(QuickLoot.Settings.ShowGroundItems),
        },
    },
    ["Features.AnimationCancelling"] = {
        ID = "Features.AnimationCancelling",
        ButtonLabel = AnimationCancelling.TranslatedStrings.Label_FeatureName:GetString(),
        HeaderLabel = AnimationCancelling.TranslatedStrings.Label_FeatureName:GetString(),
        Entries = {
            CreateHeader(AnimationCancelling.TranslatedStrings.Label_FeatureName),
            CreateLabel(AnimationCancelling.TranslatedStrings.Label_Description),

            CreateSettingEntry(AnimationCancelling.Settings.CancelSkills),
            CreateSettingEntry(AnimationCancelling.Settings.CancelAttacks),
            CreateSettingEntry(AnimationCancelling.Settings.CancelNPCAnimations),
            CreateSettingEntry(AnimationCancelling.Settings.Blacklist),
            CreateSettingEntry(AnimationCancelling.Settings.CancelWorldTooltipItemPickups),
        },
    },
}

-- Insert EE-only settings
if EpicEncounters.IsEnabled() then
    local index, _ = table.getFirst(tabs.Epip_QuickExamine.Entries, function (_, v)
        ---@cast v Feature_SettingsMenu_Entry_Setting Type is not checked as it is not yet initialized for most old entries.
        return v.Module == "EpipEncounters_QuickExamine" and v.ID == "Height"
    end)
    table.insert(tabs.Epip_QuickExamine.Entries, index + 1, CreateSettingEntry(QuickExamineWidgets.Artifacts.Settings.Enabled))
end

local tabOrder = {
    tabs.Epip_Developer,
    tabs.EpipEncounters,
    tabs.Epip_Hotbar,
    tabs["Epip.EpicEncounters"],
    tabs["Features.Vanity"],
    tabs.Epip_QuickExamine,
    tabs["Features.QuickLoot"],
    tabs["Features.AnimationCancelling"],
    tabs.Epip_PlayerInfo,
    tabs.Epip_Inventory,
    tabs.Epip_Notifications,
    tabs.Epip_Tooltips,
    tabs.Epip_Other,
    tabs["Epip.MiscellaneousQol"]
}

-- GM tab is only visible in the corresponding game mode
if Ext.GetGameMode() == "GameMaster" then
    -- TODO extract this string to somewhere, maybe TextLib?
    local gameMasterModeName = Text.GetTranslatedString("h808cea4bg2b0eg45fcgb176g61b44335e4e8", "Game Master")
    local AutomaticRollBonus = Epip.GetFeature("Features.GM.AutomaticRollBonuses")
    tabs.Epip_GameMaster = {
        ID = "Epip_GameMaster",
        ButtonLabel = gameMasterModeName,
        HeaderLabel = gameMasterModeName,
        Entries = {
            CreateHeader(gameMasterModeName),
            {Module = AutomaticRollBonus:GetNamespace(), ID = AutomaticRollBonus.Settings.AutomaticBonus:GetID()},
        },
    }

    table.insert(tabOrder, tabs.Epip_GameMaster)
end

for tabIndex,tab in ipairs(tabOrder) do
    for i,entry in ipairs(tab.Entries) do
        if type(entry) == "string" then
            tab.Entries[i] = {Type = "Setting", Module = tab.ID, ID = entry} -- We make the Module ID be the same as tab ID
        else
            ---@diagnostic disable-next-line: undefined-field
            if entry.Module then
                entry.Type = "Setting"
            end
        end
    end

    Menu.RegisterTab(tab, tabIndex)
end

-- Show a new tip when requested via the button.
Menu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.ButtonID == EpipSettingsMenu.BUTTONID_NEXT_TIP then
        Menu.SetActiveTab("EpipEncounters") -- TODO do this without re-rendering the whole tab
    end
end)
