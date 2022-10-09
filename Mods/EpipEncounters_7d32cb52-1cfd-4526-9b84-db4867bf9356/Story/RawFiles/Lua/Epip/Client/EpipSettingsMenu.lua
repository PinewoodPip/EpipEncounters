
local Menu = Epip.GetFeature("Feature_SettingsMenu")

---@param name string
---@return Feature_SettingsMenu_Entry_Label
local function CreateHeader(name)
    return {Type = "Label", Label = Text.Format(name, {Color = "7E72D6", Size = 23})}
end

---@type table<string, Feature_SettingsMenu_Tab>
local tabs = {
    ["EpipEncounters"] = {
        ID = "EpipEncounters",
        ButtonLabel = "General",
        HeaderLabel = "Epip Encounters",
        Elements = {
            {Type = "Label", Label = Text.Format("Most options require a reload for changes to apply.", {Size = 19})},
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
            "LoadingScreen",
        }
    },
    ["Epip_Hotbar"] = {
        ID = "Epip_Hotbar",
        ButtonLabel = "Hotbar",
        HeaderLabel = "Hotbar",
        Elements = {
            CreateHeader("Hotbar"),
            "HotbarCombatLogButton",
            "HotbarHotkeysText",
            "HotbarHotkeysLayout",
            "HotbarCastingGreyOut",
        }
    },
    ["Epip_Overheads"] = {
        ID = "Epip_Overheads",
        ButtonLabel = "Overheads",
        HeaderLabel = "Overheads",
        Elements = {
            CreateHeader("Overheads"),
            "OverheadsSize",
            "DamageOverheadsSize",
            "StatusOverheadsDurationMultiplier",
            "RegionLabelDuration",
        }
    },
    ["Epip_Chat"] = {
        ID = "Epip_Chat",
        ButtonLabel = "Chat",
        HeaderLabel = "Chat",
        Elements = {
            CreateHeader("Chat"),
            "Chat_MessageSound",
            "Chat_ExitAfterSendingMessage",
        }
    },
    ["Epip_Developer"] = {
        ID = "Epip_Developer",
        ButtonLabel = "Developer",
        HeaderLabel = "Developer",
        Elements = {
            CreateHeader("Developer"),
            {Type = "Button", Label = "Warp to AMER_Test", ID = "DEBUG_WarpToAMERTest"},
            "Developer_DebugDisplay",
            "DEBUG_ForceStoryPatching",
            "DEBUG_AI",
            "DEBUG_AprilFools",
        }
    },
    ["Epip_PlayerInfo"] = {
        ID = "Epip_PlayerInfo",
        ButtonLabel = "Player Portraits",
        HeaderLabel = "Player Portraits",
        Elements = {
            CreateHeader("Player Portraits UI"),
            "PlayerInfoBH",
            "PlayerInfo_StatusHolderOpacity",
            "PlayerInfo_EnableSortingFiltering",
            "PlayerInfo_SortingFunction",
            "PlayerInfo_Filter_SourceGen",
            "PlayerInfo_Filter_BatteredHarried",
        }
    },
    ["Epip_SaveLoad"] = {
        ID = "Epip_SaveLoad",
        ButtonLabel = "Save/Load UI",
        HeaderLabel = "Save/Load UI",
        Elements = {
            CreateHeader("Save/Load UI"),
            "SaveLoad_Overlay",
            "SaveLoad_Sorting",
        }
    },
    ["Epip_Crafting"] = {
        ID = "Epip_Crafting",
        ButtonLabel = "Crafting UI",
        HeaderLabel = "Crafting UI",
        Elements = {
            CreateHeader("Crafting UI"),
            "Crafting_DefaultFilter",
        }
    },
    ["Epip_Inventory"] = {
        ID = "Epip_Inventory",
        ButtonLabel = "Inventory UI",
        HeaderLabel = "Inventory UI",
        Elements = {
            CreateHeader("Inventory UI"),
            "Inventory_AutoUnlockInventory",
            "Inventory_InfiniteCarryWeight",
            "Inventory_RewardItemComparison",
        }
    },
    ["Epip_Notifications"] = {
        ID = "Epip_Notifications",
        ButtonLabel = "Notifications",
        HeaderLabel = "Notifications",
        Elements = {
            CreateHeader("Notifications"),
            "CastingNotifications",
            "Notification_ItemReceival",
            "Notification_StatSharing",
        }
    },
    ["Epip_Tooltips"] = {
        ID = "Epip_Tooltips",
        ButtonLabel = "Tooltips",
        HeaderLabel = "Tooltips",
        Elements = {
            CreateHeader("UI Tooltips"),
            "Tooltip_SimpleTooltipDelay_World",
            "Tooltip_SimpleTooltipDelay_UI",

            CreateHeader("World Item Tooltips"),
            "WorldTooltip_OpenContainers",
            "WorldTooltip_HighlightContainers",
            "WorldTooltip_HighlightConsumables",
            "WorldTooltip_HighlightEquipment",
            "WorldTooltip_EmptyContainers",
            "WorldTooltip_ShowSittableAndLadders",
            "WorldTooltip_ShowDoors",
            "WorldTooltip_ShowInactionable",
            "WorldTooltip_MoreTooltips",
        }
    }
}

local tabOrder = {
    tabs.EpipEncounters,
    tabs.Epip_Hotbar,
    tabs.Epip_Overheads,
    tabs.Epip_Chat,
    tabs.Epip_Developer,
    tabs.Epip_PlayerInfo,
    tabs.Epip_SaveLoad,
    tabs.Epip_Crafting,
    tabs.Epip_Inventory,
    tabs.Epip_Notifications,
    tabs.Epip_Tooltips,
}

for _,tab in ipairs(tabOrder) do
    for i,entry in ipairs(tab.Elements) do
        if type(entry) == "string" then
            tab.Elements[i] = {Type = "Setting", Module = tab.ID, ID = entry} -- We make the Module ID be the same as tab ID 
        end
    end

    Menu.RegisterTab(tab)
end