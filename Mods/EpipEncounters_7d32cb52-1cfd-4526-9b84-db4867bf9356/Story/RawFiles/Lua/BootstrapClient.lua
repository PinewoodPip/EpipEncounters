
--[[
   ____          _                ____                              __                 
  / __/   ___   (_)   ___        / __/  ___  ____ ___  __ __  ___  / /_ ___   ____  ___
 / _/    / _ \ / /   / _ \      / _/   / _ \/ __// _ \/ // / / _ \/ __// -_) / __/ (_-<
/___/   / .__//_/   / .__/     /___/  /_//_/\__/ \___/\_,_/ /_//_/\__/ \__/ /_/   /___/
       /_/         /_/                                                                 

    Welcome to Epip Encounters:tm: by PinewoodPip !!!
    Feel free to browse the code to learn how things are implemented,
    however, you are NOT permitted to reuse it for your own projects.
    Using it as a dependency for your own EE mod is fine.

    The plan is to eventually release Epip's client/UI APIs as a standalone mod with no EE
    dependency.
    It is not my intention to hold modding systems and discoveries "hostage" to EE.
    It takes a lot of time to figure things out, implement them,
    and further time to make and document APIs that I'd deem usable by others.
    I would prefer to release Epip publicly only when it meets my quality standards.
    Please understand.

    If there is a particular feature in EE that you're interested in implementing in your own mod, contact me and I can guide you on how it was engineered. <3

    Huge thanks to the EE community, without whom I would've never gotten this far into modding this game.

    Sick/epic/awesome ASCII header is from https://patorjk.com/software/taag/
]]

local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"

---@type (string|ScriptDefinition)[]
LOAD_ORDER = {
    {
        Scripts = {
            "Utilities/OOP/OOP.lua",
            "Utilities/OOP/_Library.lua",
        },
    },
    "Utilities/Event.lua",
    "Tables/Epip.lua",
    "Tables/_Events.lua",
    "Tables/_Feature.lua",
    "Utilities/Hooks.lua",
    "Utilities.lua",

    -- Utilities
    "Utils.lua",
    "Utilities/table.lua",
    "Utilities/math.lua",
    "Utilities/IO.lua",
    "Utilities/Vector.lua",
    "Utilities/Color.lua",
    {ScriptSet = "Utilities/Entity"},
    {ScriptSet = "Utilities/GameState"},
    "Utilities/Mod.lua",
    "Utilities/Timer.lua",
    "Utilities/Coroutine.lua",
    "Utilities/UserVars.lua",
    {
        Scripts = {
            "Utilities/DataStructures/Main.lua",
            "Utilities/DataStructures/DefaultTable.lua",
            "Utilities/DataStructures/Set.lua",
        },
    },
    {
        Scripts = {
            "Utilities/Text/Library.lua",
            "Utilities/Text/CommonStrings.lua",
            "Utilities/Text/Localization.lua",
        },
    },
    {
        Scripts = {
            "Utilities/Interfaces/Main.lua",
            "Utilities/Interfaces/Identifiable.lua",
            "Utilities/Interfaces/Describable.lua",
        },
    },

    {ScriptSet = "Utilities/Combat"},
    "Utilities/Client/Pointer.lua",

    "Data/Game.lua", -- TODO move stuff out of it into appropriate scripts

    -- Static libraries
    "Game.lua",

    -- Net
    {
        Scripts = {
            "Utilities/Net/Shared.lua",
            "Utilities/Net/Client.lua",
        },
    },
    
    -- CharacterLib
    {
        ScriptSet = "Utilities/Character",
        Scripts = {
            "Utilities/Character/Shared_Talents.lua",
        },
    },

    -- ItemLib
    {
        ScriptSet = "Utilities/Item",
    },

    -- Stats
    {
        Scripts = {
            "Utilities/Stats/Shared.lua",
            "Utilities/Stats/Shared_ModifierLists.lua",
            "Utilities/Stats/Shared_ExtraData.lua",
            "Utilities/Stats/Shared_Actions.lua",
            "Utilities/Stats/Shared_Runes.lua",
            "Utilities/Stats/Shared_Immunities.lua",
        },
    },
    
    {ScriptSet = "Utilities/Artifact"},

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Sound.lua",
    "UI/Data.lua",
    "Client/Input.lua",
    "Tables/_UI.lua",

    -- SettingsLib
    {
        ScriptSet = "Utilities/Settings",
        Scripts = {
            "Utilities/Settings/Setting_Boolean.lua",
            "Utilities/Settings/Setting_Number.lua",
            "Utilities/Settings/Setting_ClampedNumber.lua",
            "Utilities/Settings/Setting_Choice.lua",
            "Utilities/Settings/Setting_Set.lua",
            "Utilities/Settings/Setting_Map.lua",
            "Utilities/Settings/Setting_Vector.lua",
        },
    },

    "UI/TextDisplay.lua",

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Flash.lua",
    "Client/Sound.lua",
    "UI/Data.lua",
    {
        Scripts = {
            "Client/Camera/Camera.lua",
            "Client/Camera/Camera_DefaultPositions.lua",
        },
    },

    "Game/Client/Tooltip.lua",
    "Game/Tooltip.lua",

    -- AMER UI
    {
        Scripts = {
            "Game/AMERUI/Shared.lua",
            "Game/AMERUI/Client.lua",
        },
    },

    -- Ascension
    {
        Scripts = {
            "Game/Ascension/Shared.lua",
            "Game/Ascension/Client.lua",
        },
    },

    "Game/SkillDamageCalculation.lua",
    
    {ScriptSet = "Epip/DatabaseSync"},

    {ScriptSet = "Utilities/EpicEncounters"},
    {ScriptSet = "Utilities/EpicEncounters/SourceInfusion"},
    {ScriptSet = "Utilities/EpicEncounters/BatteredHarried"},

    "UI/OptionsSettings.lua",

    -- Needs to be ordered after the above.
    "Epip/Settings.lua",
    "Epip/Client/SettingsRegistration.lua",

    "UI/StatusConsole.lua",

    "EpicStatsKeywords.lua",
    "EpicStatsDefinitions.lua",

    "UI/EnemyHealthBar.lua",
    
    "UI/Input.lua",
    "UI/OptionsInput.lua",
    "UI/Time.lua",

    -- Character Sheet
    {
        Scripts = {
            "UI/CharacterSheet/CharacterSheet.lua",
            "UI/CharacterSheet/StatsTab.lua",
        },
    },
    
    -- UIs
    "UI/ContextMenu.lua",
    "UI/CharacterCreation.lua",
    "UI/Overhead.lua",
    "UI/MessageBox.lua",
    "UI/PlayerInfo.lua",
    "UI/PartyInventory.lua",
    "UI/GameMenu.lua",
    "UI/TutorialBox.lua",
    "UI/Examine.lua",
    "UI/Tooltip.lua",
    "UI/LoadingScreen.lua",
    "UI/Skills.lua",
    
    "Utilities/Client/Tooltip.lua",

    -- GenericUI
    {
        Scripts = {
            "UI/Generic/Main.lua",

            "UI/Generic/Elements/Element.lua",
            "UI/Generic/Elements/Empty.lua",
            "UI/Generic/Elements/TiledBackground.lua",
            "UI/Generic/Elements/Text.lua",
            "UI/Generic/Elements/IggyIcon.lua",
            "UI/Generic/Elements/Button.lua",
            "UI/Generic/Elements/VerticalList.lua",
            "UI/Generic/Elements/HorizontalList.lua",
            "UI/Generic/Elements/ScrollList.lua",
            "UI/Generic/Elements/StateButton.lua",
            "UI/Generic/Elements/Divider.lua",
            "UI/Generic/Elements/Slot.lua",
            "UI/Generic/Elements/Slider.lua",
            "UI/Generic/Elements/ComboBox.lua",
            "UI/Generic/Elements/Grid.lua",
            "UI/Generic/Elements/Color.lua",

            "UI/Generic/Prefabs/HotbarSlot.lua",
            "UI/Generic/Prefabs/Spinner.lua",
            "UI/Generic/Prefabs/Text.lua",
            "UI/Generic/Prefabs/LabelledDropdown.lua",
            "UI/Generic/Prefabs/LabelledCheckbox.lua",
            "UI/Generic/Prefabs/LabelledTextField.lua",
            "UI/Generic/Prefabs/FormHorizontalList.lua",
            "UI/Generic/Prefabs/LabelledIcon.lua",
            "UI/Generic/Prefabs/Status.lua",
            "UI/Generic/Prefabs/TooltipPanel.lua",
        },
    },
    -- {Script = "UI/Generic/Test.lua", WIP = true}, -- TEST!

    -- Hotbar
    {
        Scripts = {
            "UI/Hotbar/Main.lua",
            "UI/Hotbar/ContextMenus.lua",
            "UI/Hotbar/Actions.lua",
            "UI/Hotbar/Loadouts.lua",
        },
    },
    
    "UI/Notification.lua",
    "UI/Minimap.lua",
    "UI/VanillaActions.lua",
    "UI/AprilFoolsOverlay.lua",
    "UI/Journal.lua",
    "UI/Saving.lua",
    "UI/GiftBagContent.lua",
    "UI/ChatLog.lua",
    "UI/SaveLoad.lua",
    "UI/Craft.lua",
    "UI/Reward.lua",
    "UI/WorldTooltip.lua",
    "UI/CombatTurn.lua",
    "UI/Fade.lua",

    -- Title screen UIs
    "UI/Mods.lua",

    -- Vanity
    {
        Scripts = {
            "UI/Vanity/Vanity.lua",
            "UI/Vanity/Tabs/_Tab.lua",
            -- "UI/Vanity/Tabs/Auras.lua",
        },
    },
    {ScriptSet = "UI/Vanity/Tabs/Shapeshift", WIP = true},

    {
        Scripts = {
            "UI/CombatLog/CombatLog.lua",

            "UI/CombatLog/Messages/_Base.lua",
            "UI/CombatLog/Messages/_Character.lua",
            "UI/CombatLog/Messages/_CharacterInteraction.lua",

            "UI/CombatLog/Messages/Unsupported.lua",
            "UI/CombatLog/Messages/Damage.lua",
            "UI/CombatLog/Messages/Healing.lua",
            "UI/CombatLog/Messages/Lifesteal.lua",
            "UI/CombatLog/Messages/Status.lua",
            "UI/CombatLog/Messages/Scripted.lua",
            "UI/CombatLog/Messages/SourceInfusionLevel.lua",
            "UI/CombatLog/Messages/SourceGeneration.lua",
            "UI/CombatLog/Messages/APPreservation.lua",
            "UI/CombatLog/Messages/Skill.lua",
            "UI/CombatLog/Messages/ReactionCharges.lua",
            "UI/CombatLog/Messages/Attack.lua",
            "UI/CombatLog/Messages/ReflectedDamage.lua",
            "UI/CombatLog/Messages/SurfaceDamage.lua",
            "UI/CombatLog/Messages/CriticalHit.lua",
            "UI/CombatLog/Messages/Dodge.lua",
        },
    },

    "UI/Controller/PanelSelect.lua",

    "Epip/Client/ImmersiveMeditation.lua",
    "Epip/Client/NameTypoFixes.lua",
    "Epip/Client/ExamineImprovements.lua",

    {
        ScriptSet = "Epip/TooltipAdjustments",
        Scripts = {
            "Epip/TooltipAdjustments/Client_Scrolling.lua",
            "Epip/TooltipAdjustments/Client_RuneCraftingHint.lua",
            "Epip/TooltipAdjustments/Client_RewardGenerationWarning.lua",
            "Epip/TooltipAdjustments/Client_WeaponRangeDeltamod.lua",
            "Epip/TooltipAdjustments/Client_DamageTypeDeltamods.lua",
            "Epip/TooltipAdjustments/Client_SimpleTooltips.lua",
            "Epip/TooltipAdjustments/Client_AstrologerFix.lua",
            "Epip/TooltipAdjustments/Client_SurfaceTooltips.lua",
        },
    },

    -- Custom settings UI
    {
        Scripts = {
            "Epip/Client/SettingsMenu/Client.lua",
        },
    },

    "Debug/Shared.lua",
    "Debug/Client.lua",
    "Debug/Commands/Client.lua",
    
    "Epip/Client/TreasureTableDisplay.lua",
    "Epip/Client/SummonControlFix.lua",
    "Epip/Client/Notifications.lua",
    "Epip/Client/CraftingFixes.lua",
    "Epip/Client/RewardItemComparison.lua",
    "Epip/Client/HotbarTweaks.lua",
    "Epip/Client/ExamineKeybind.lua",
    "Epip/Client/MoreWorldTooltips.lua",
    "Epip/Client/EnemyHealthBarExtraInfo.lua",
    -- "Epip/Client/InventoryImprovements.lua",

    {ScriptSet = "Epip/Greatforge/DrillSockets"},
    {ScriptSet = "Epip/Greatforge/Engrave"},
    {ScriptSet = "Epip/InfiniteCarryWeight"},
    {ScriptSet = "Epip/DebugDisplay", Developer = true,},
    {ScriptSet = "Epip/UnlearnSkills"},
    {ScriptSet = "Epip/WorldTooltipOpenContainers"},
    {ScriptSet = "Epip/AutoUnlockInventory"},

    "Epip/ShowConsumableEffects.lua",
    "Epip/WalkOnCorpses.lua",

    -- Quick Examine
    {
        Scripts = {
            "Epip/Client/QuickExamine/Client.lua",

            "Epip/Client/QuickExamine/Widgets/BasicInfo.lua",
            "Epip/Client/QuickExamine/Widgets/Resistances.lua",
            "Epip/Client/QuickExamine/Widgets/Immunities.lua",
            "Epip/Client/QuickExamine/Widgets/Statuses.lua",
            "Epip/Client/QuickExamine/Widgets/Artifacts.lua",
            "Epip/Client/QuickExamine/Widgets/SkillsDisplay.lua",
        },
    },
    "Epip/Client/GenericUIs/SaveLoadOverlay.lua",
    "Epip/Client/GenericUIs/HotbarGroup.lua",

    "Epip/Client/AprilFoolsCharacterSheet.lua",
    "Epip/Client/HotbarActions.lua",
    "Epip/Client/EpicEncountersActions.lua",
    {
        ScriptSet = "Epip/AscensionShortcuts",
    },
    "Epip/Client/ModDocs.lua",
    "Epip/Client/JournalChangelog.lua",
    "Epip/Client/ExitChatAfterMessage.lua",
    "Epip/Client/CameraZoom.lua",
    -- "Epip/Client/ModMenuImprovements.lua",

    -- Chat Commands
    {
        ScriptSet = "Epip/ChatCommands",
    },
    "Epip/EmoteCommands.lua",

    "Epip/Compatibility/WeaponExpansion/Client.lua",
    "Epip/Compatibility/DerpyEETweaks/TreasureTableDisplay.lua",

    "Epip/Client/EpipDocs.lua",

    -- Stats tab
    "Epip/StatsTab/Shared.lua",
    "Epip/StatsTab/Client/Client.lua",
    "Epip/StatsTab/Client/StatGetters.lua",

    "Epip/Client/CharacterSheetResistances.lua",
    "Epip/Client/CharacterSheetLevelProgress.lua",
    "Epip/Client/DifficultyToggle.lua",
    -- "Epip/AwesomeSoccer/Client.lua",
    "Epip/Client/GiftbagLocker.lua",
    "Epip/Client/ChatNotificationSound.lua",
    "Epip/Client/ToggleableWorldTooltips.lua",
    "Epip/Client/WorldTooltipFiltering.lua",
    "Epip/Client/HoverCharacterEffects.lua",
    -- "Epip/Client/LoadingScreenReplacement.lua",

    -- Epic Enemies
    "Epip/EpicEnemies/Shared.lua",
    "Epip/EpicEnemies/Client.lua",
    "Epip/EpicEnemies/Effects.lua",
    "Epip/EpicEnemies/ActivationConditionsClient.lua",
    "Epip/EpicEnemies/QuickExamineWidget.lua",

    "Epip/StatusSorting.lua",

    "Epip/PreferredTargetDisplay/Shared.lua",
    "Epip/PreferredTargetDisplay/Client.lua",

    {ScriptSet = "Epip/ItemTagging"},
    {ScriptSet = "Epip/ExtraDataConfig", Developer = true,},
    -- {ScriptSet = "Epip/Housing", WIP = true,},
    -- {Script = "Epip/Housing/Shared_Furniture.lua", WIP = true},
    {ScriptSet = "Epip/StatsEditor", WIP = true,},
    {ScriptSet = "Epip/APCostBoostFix"},

    -- AMER UI controller support
    -- "Epip/Client/AMERUI_Controller/AMERUI_Controller.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/MainHub.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/Gateway.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/Cluster.lua",

    "Epip/ContextMenus/Greatforge/Client.lua",
    "Epip/ContextMenus/PlayerInfo.lua", 

    -- Vanity
    {
        ScriptSet = "Epip/Vanity",
        Scripts = {
            
        },
    },
    -- Vanity Transmog
    {
        ScriptSet = "Epip/Vanity/Transmog",
        Scripts = {
            "Epip/Vanity/Transmog/Client_Tab.lua",
        }
    },
    -- Vanity Outfits
    {
        ScriptSet = "Epip/Vanity/Outfits",
        Scripts = {
            "Epip/Vanity/Outfits/Client_Tab.lua",
        },
    },
    -- Vanity Dyes
    {
        ScriptSet = "Epip/Vanity/Dyes",
        Scripts = {
            "Epip/Vanity/Dyes/Client_Tab.lua",
        },
    },
    -- Vanity Auras
    {
        ScriptSet = "Epip/Vanity/Auras",
        Scripts = {
            "Epip/Vanity/Auras/Shared_Data.lua",
            "Epip/Vanity/Auras/Client_Tab.lua",
        },
    },

    -- Fishing
    {
        WIP = true,
        ScriptSet = "Epip/Fishing",
        Scripts = {
            "Epip/Fishing/Shared_Data.lua",

            "Epip/Fishing/Client_UI.lua",
            "Epip/Fishing/GameObjects/_GameObject.lua",
            "Epip/Fishing/GameObjects/Fish.lua",
            "Epip/Fishing/GameObjects/Bobber.lua",

            "Epip/Fishing/Client_CollectionLogUI.lua",

            "Epip/Fishing/Client_CharacterTask.lua",
        }
    },

    {
        Scripts = {
            "Epip/QuickInventory/Client.lua",
            "Epip/QuickInventory/Client_Settings.lua",

            "Epip/QuickInventory/Filters/Equipment.lua",
            "Epip/QuickInventory/Filters/Consumables.lua",
            "Epip/QuickInventory/Filters/Skillbooks.lua",

            "Epip/QuickInventory/UI.lua",
        }
    },

    "Epip/Client/EE_Dyes.lua",

    "Epip/Compatibility/MajoraFashionSins/Client.lua",
    "Epip/Compatibility/PortableRespecMirror/Client.lua",
    "Epip/Compatibility/RendalNPCArmor/Client.lua",
    "Epip/Compatibility/VisitorsFromCyseal/Client.lua",

    "Epip/Keybindings/Client.lua",

    -- Should be loaded last
    {ScriptSet = "Epip/DebugMenu", Developer = true,},

    "Epip/Client/HideIncons.lua",

    "Epip/Client/EpipSettingsMenu.lua",

    {ScriptSet = "Epip/AnimationCancelling"},

    {
        Scripts = {
            "Utilities/Image/Shared.lua",
            "Utilities/Image/_Decoder.lua",
            "Utilities/Image/Decoders/PNG/Decoder.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IHDR.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IDAT.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IEND.lua",
        }
    },

    "Epip/Client/ImageViewer.lua",

    {
        Scripts = {
            "Epip/Bedazzled/Client.lua",
            "Epip/Bedazzled/UI.lua",

            "Epip/Bedazzled/Model/Board/Column.lua",
            "Epip/Bedazzled/Model/Board/Gem.lua",
            "Epip/Bedazzled/Model/Board/GemDescriptor.lua",
            "Epip/Bedazzled/Model/Board/Match.lua",
            "Epip/Bedazzled/Model/Board/GemModifierDescriptor.lua",
            "Epip/Bedazzled/Model/Board/Board.lua",

            "Epip/Bedazzled/Model/Gem/States/_State.lua",
            "Epip/Bedazzled/Model/Gem/States/Idle.lua",
            "Epip/Bedazzled/Model/Gem/States/Falling.lua",
            "Epip/Bedazzled/Model/Gem/States/InvalidSwap.lua",
            "Epip/Bedazzled/Model/Gem/States/Swapping.lua",
            "Epip/Bedazzled/Model/Gem/States/Consuming.lua",
            "Epip/Bedazzled/Model/Gem/States/Fusing.lua",
            "Epip/Bedazzled/Model/Gem/States/Transforming.lua",
        },
        WIP = true,
    }
}

Utilities = {}

Ext.Require(prefixedGUID, "Bootstrap.lua")

Ext.Require(prefixedGUID, "_LastScript.lua")