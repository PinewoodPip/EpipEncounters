
local Menu = Epip.GetFeature("Feature_SettingsMenu")
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local AnimationCancelling = Epip.GetFeature("Feature_AnimationCancelling")
local CommonStrings = Text.CommonStrings

---@class Feature_EpipSettingsMenu : Feature
local EpipSettingsMenu = {
    TranslatedStrings = {
        WarpToTestLevel = {
            Handle = "h68a80196g2a32g4e12g9757gc826f58efd20",
            Text = "Warp to AMER_Test",
            ContextDescription = "Debug button to warp to test level",
        },
        SettingApplicationWarning = {
           Handle = "h4a3e28fag3595g4753gb507g4423068aeda8",
           Text = "Most options require a reload for changes to apply.",
           ContextDescription = "Warning at the top of the settings menu",
        },
        TranslationCredits = {
           Handle = "hbce14cb2g1ed7g4076g95d1gb80c6085c3ad",
           Text = "Russian translation by Cathe & JoienReid",
           ContextDescription = "Displayed at the bottom of the general Epip settings tab",
        },
        Tab_Hotbar = {
           Handle = "h37985411gc95dg46a1g858bg021ed39e43cd",
           Text = "Hotbar",
           ContextDescription = "Tab name for hotbar settings",
        },
        Tab_MiscUI = {
           Handle = "hde49d383g961eg49d6gaa46gcc45ab299aa5",
           Text = "Miscellaneous UI",
           ContextDescription = "Settings tab name",
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
    }
}
Epip.RegisterFeature("EpipSettingsMenu", EpipSettingsMenu)
local TSK = EpipSettingsMenu.TranslatedStrings ---@type table<string, TextLib_TranslatedString>

---@param name string|TextLib_TranslatedString
---@return Feature_SettingsMenu_Entry_Label
local function CreateHeader(name)
    if type(name) == "table" then
        name = name:GetString()
    end
    return {Type = "Label", Label = Text.Format(name, {Color = "7E72D6", Size = 23})}
end

---@type table<string, Feature_SettingsMenu_Tab>
local tabs = {
    ["EpipEncounters"] = {
        ID = "EpipEncounters",
        ButtonLabel = "General",
        HeaderLabel = "Epip Encounters",
        Entries = {
            {Type = "Label", Label = Text.Format(TSK.SettingApplicationWarning:GetString(), {Size = 19})},
            "EpipLanguage",
            "AutoIdentify",
            "ImmersiveMeditation",
            "ExaminePosition",
            "Minimap",
            "TreasureTableDisplay",
            "CinematicCombat",
            "ESCClosesAmerUI",
            "RenderShroud",
            "Feature_WalkOnCorpses",
            "CombatLogImprovements",
            "PreferredTargetDisplay",

            CreateHeader(AnimationCancelling.TranslatedStrings.Setting_Name),
            {Type = "Setting", Module = "EpipEncounters_AnimationCancelling", ID = "Enabled"},
            {Type = "Setting", Module = "EpipEncounters_AnimationCancelling", ID = "Blacklist"},

            {Type = "Label", Label = Text.Format("——————————————————————————————", {
                Size = 19,
            })},
            {Type = "Label", Label = Text.Format(TSK.TranslationCredits:GetString(), {
                Size = 19,
            })},
        }
    },
    ["Epip_Hotbar"] = {
        ID = "Epip_Hotbar",
        ButtonLabel = TSK.Tab_Hotbar:GetString(),
        HeaderLabel = TSK.Tab_Hotbar:GetString(),
        Entries = {
            CreateHeader(TSK.Tab_Hotbar),
            "HotbarCombatLogButton",
            "HotbarHotkeysText",
            "HotbarHotkeysLayout",
            "HotbarCastingGreyOut",
        }
    },
    ["Epip_QuickExamine"] = {
        ID = "Epip_QuickExamine",
        ButtonLabel = QuickExamine.TranslatedStrings.Name:GetString(),
        HeaderLabel = QuickExamine.TranslatedStrings.Name:GetString(),
        Entries = {
            CreateHeader(QuickExamine.TranslatedStrings.Name),
            {Module = "EpipEncounters_QuickExamine", ID = "AllowDead"},
            {Module = "EpipEncounters_QuickExamine", ID = "Opacity"},
            {Module = "EpipEncounters_QuickExamine", ID = "Width"},
            {Module = "EpipEncounters_QuickExamine", ID = "Height"},
            {Module = "EpipEncounters_QuickExamine", ID = "Widget_Artifacts"},
            {Module = "EpipEncounters_QuickExamine", ID = "Widget_Statuses"},
            {Module = "EpipEncounters_QuickExamine", ID = "Widget_Skills"},
            {Type = "Button", ID = "QuickExamine_SaveDefaultPosition", Label = QuickExamine.TranslatedStrings.SavePosition:GetString(), Tooltip = QuickExamine.TranslatedStrings.SavePositionTooltip:GetString()},
        }
    },
    ["Epip_Other"] = {
        ID = "Epip_Other",
        ButtonLabel = TSK.Tab_MiscUI:GetString(),
        HeaderLabel = TSK.Tab_MiscUI:GetString(),
        Entries = {
            CreateHeader(TSK.Section_Overheads),
            {Module = "Epip_Overheads", ID = "OverheadsSize"},
            {Module = "Epip_Overheads", ID = "DamageOverheadsSize"},
            {Module = "Epip_Overheads", ID = "StatusOverheadsDurationMultiplier"},
            {Module = "Epip_Notifications", ID = "RegionLabelDuration"},

            CreateHeader(CommonStrings.Chat),
            {Module = "Epip_Chat", ID = "Chat_MessageSound"},
            {Module = "Epip_Chat", ID = "Chat_ExitAfterSendingMessage"},

            CreateHeader(TSK.Section_SaveLoadUI),
            {Module = "Epip_SaveLoad", ID = "SaveLoad_Overlay"},
            {Module = "Epip_SaveLoad", ID = "SaveLoad_Sorting"},
        }
    },
    ["Epip_Developer"] = {
        ID = "Epip_Developer",
        ButtonLabel = CommonStrings.Developer:GetString(),
        HeaderLabel = CommonStrings.Developer:GetString(),
        DeveloperOnly = true,
        Entries = {
            CreateHeader(CommonStrings.Developer),
            {Type = "Button", Label = EpipSettingsMenu.TranslatedStrings.WarpToTestLevel:GetString(), ID = "DEBUG_WarpToAMERTest"},
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
            "PlayerInfoBH",
            "PlayerInfo_StatusHolderOpacity",
            "PlayerInfo_EnableSortingFiltering",
            "PlayerInfo_SortingFunction",
            "PlayerInfo_Filter_SourceGen",
            "PlayerInfo_Filter_BatteredHarried",
        }
    },
    ["Epip_Inventory"] = {
        ID = "Epip_Inventory",
        ButtonLabel = CommonStrings.Inventory:GetString(),
        HeaderLabel = CommonStrings.Inventory:GetString(),
        Entries = {
            CreateHeader(TSK.Section_InventoryUI),
            "Inventory_AutoUnlockInventory",
            "Inventory_InfiniteCarryWeight",
            "Inventory_RewardItemComparison",

            CreateHeader(QuickInventory.TranslatedStrings.Header:GetString()),
            {Type = "Label", Label = Text.Format(QuickInventory.TranslatedStrings.SettingsMenuInfo:GetString(), {Size = 19})},
            {Module = QuickInventory:GetSettingsModuleID(), ID = QuickInventory.Settings.CloseAfterUsing.ID},

            CreateHeader(TSK.Section_CraftingUI),
            {Module = "Epip_Crafting", ID = "Crafting_DefaultFilter"},
        }
    },
    ["Epip_Notifications"] = {
        ID = "Epip_Notifications",
        ButtonLabel = CommonStrings.Notifications:GetString(),
        HeaderLabel = CommonStrings.Notifications:GetString(),
        Entries = {
            CreateHeader(CommonStrings.Notifications:GetString()),
            "CastingNotifications",
            "Notification_ItemReceival",
            "Notification_StatSharing",
        }
    },
    ["Epip_Tooltips"] = {
        ID = "Epip_Tooltips",
        ButtonLabel = CommonStrings.Tooltips:GetString(),
        HeaderLabel = CommonStrings.Tooltips:GetString(),
        Entries = {
            CreateHeader(TSK.Section_UITooltips),
            "Tooltip_SimpleTooltipDelay_World",
            "Tooltip_SimpleTooltipDelay_UI",

            CreateHeader(TSK.Section_WorldItemTooltips),
            "WorldTooltip_OpenContainers",
            "WorldTooltip_HighlightContainers",
            "WorldTooltip_HighlightConsumables",
            "WorldTooltip_HighlightEquipment",
            "WorldTooltip_EmptyContainers",
            "WorldTooltip_ShowSittableAndLadders",
            "WorldTooltip_ShowDoors",
            "WorldTooltip_ShowInactionable",
            "WorldTooltip_MoreTooltips",

            CreateHeader(TooltipAdjustments.TranslatedStrings.Name),
            {Module = "EpipEncounters_TooltipAdjustments", ID = "AstrologerFix"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "DamageTypeDeltamods"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "RewardGenerationWarning"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "RuneCraftingHint"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "SurfaceTooltips"},
            {Module = "EpipEncounters_TooltipAdjustments", ID = "WeaponRangeDeltamods"},
        }
    }
}

local tabOrder = {
    tabs.Epip_Developer,
    tabs.EpipEncounters,
    tabs.Epip_Hotbar,
    tabs.Epip_QuickExamine,
    tabs.Epip_PlayerInfo,
    tabs.Epip_Inventory,
    tabs.Epip_Notifications,
    tabs.Epip_Tooltips,
    tabs.Epip_Other
}

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