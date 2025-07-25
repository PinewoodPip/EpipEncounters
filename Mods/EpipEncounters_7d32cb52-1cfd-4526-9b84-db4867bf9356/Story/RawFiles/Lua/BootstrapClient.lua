
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

    If there is a particular feature in Epip that you're interested in implementing in your own mod, contact me and I can guide you on how it was engineered. <3

    Huge thanks to the EE community, without whom I would've never gotten this far into modding this game.

    Sick/epic/awesome ASCII header is from https://patorjk.com/software/taag/
]]

-- Epip does not work in-editor.
if Ext.Utils.GameVersion() == "v3.6.51.9303" then
    return
end

Ext.Require("BootstrapBefore.lua")
Utilities = {}

local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"

local coreLibraries = {
    -- OOP
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
    "Utils.lua",
    {
        Scripts = {
            "Utilities/Testing/Shared.lua",
            "Utilities/Testing/_Test.lua",
        },
    },
    "Utilities/table.lua",
    "Utilities/math.lua",
    "Utilities/IO.lua",
    "Utilities/Vector.lua",
    "Utilities/Color.lua",
    {
        Scripts = {
            "Utilities/DataStructures/Main.lua",
            "Utilities/DataStructures/DefaultTable.lua",
            "Utilities/DataStructures/Set.lua",
            "Utilities/DataStructures/ObjectPool.lua",
        },
    },
    {ScriptSet = "Utilities/Entity"},
    {ScriptSet = "Utilities/GameState"},
    "Utilities/Mod.lua",
    "Utilities/Timer.lua",
    "Utilities/Coroutine.lua",
    "Utilities/UserVars.lua",

    -- Text
    {
        Scripts = {
            "Utilities/Text/Library.lua",
            "Utilities/Text/HTML.lua",
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
    "Utilities/Texture.lua",
    "Utilities/Profiling.lua",
    "Utilities/Client/Pointer.lua",

    "Data/Game.lua", -- TODO move stuff out of it into appropriate scripts

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
            "Utilities/Stats/Shared_SkillData.lua",
        },
    },

    "Utilities/Damage/Shared.lua",

    -- Artifacts
    {ScriptSet = "Utilities/Artifact", RequiresEE = true,},

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Sound.lua",
    {
        Scripts = {
            "Utilities/Client/Input/Main.lua",
            "Utilities/Client/Input/CustomActions.lua",
        },
    },
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
            "Utilities/Settings/Setting_String.lua",
            "Utilities/Settings/Setting_InputBinding.lua",
            "Utilities/Settings/Setting_Skill.lua",
            "Utilities/Settings/Setting_Color.lua",
        },
    },

    -- ImageLib
    {
        Scripts = {
            "Utilities/Image/Shared.lua",
            "Utilities/Image/_Decoder.lua",
            "Utilities/Image/Decoders/PNG/Decoder.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IHDR.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IDAT.lua",
            "Utilities/Image/Decoders/PNG/Chunks/IEND.lua",
            "Utilities/Image/Decoders/DDS/Decoder.lua",
        }
    },
}
for _,lib in ipairs(coreLibraries) do
    RequestScriptLoad(lib)
end

local MODS = Mod.GUIDS

---@type (string|ScriptLoadRequest)[]
LOAD_ORDER = {
    "UI/TextDisplay.lua",

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Flash.lua",
    "Client/Sound.lua",
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

    -- Epic Encounters libraries
    {Script = "Utilities/EpicEncounters/Shared.lua"}, -- Core script needs to be present for now due to IsEnabled() - TODO move it out?
    {ScriptSet = "Utilities/EpicEncounters/SourceInfusion", RequiresEE = true},
    {ScriptSet = "Utilities/EpicEncounters/BatteredHarried", RequiresEE = true},
    {
        ScriptSet = "Utilities/EpicEncounters/DeltaMods",
        Scripts = {
            "Utilities/EpicEncounters/DeltaMods/Shared_BaseDeltamodTiers.lua",
        },
        RequiresEE = true
    },
    {ScriptSet = "Utilities/EpicEncounters/Meditate", RequiresEE = true},

    "UI/OptionsSettings.lua",

    "Epip/ExtenderForkVersionCheck/Client.lua",
    "Epip/SkillbookTemplates/Shared.lua",

    -- Needs to be ordered after the above.
    "Epip/Settings.lua",
    "Epip/UIOverrideToggles/Client.lua",

    "UI/StatusConsole.lua",

    {
        ScriptSet = "Epip/EpicEncountersStatsTab",
        Scripts = {
            "Epip/EpicEncountersStatsTab/StatDefinitions.lua"
        },
        RequiresEE = true,
    },

    "UI/EnemyHealthBar.lua",

    "UI/Input.lua",
    "UI/OptionsInput.lua",
    "UI/Time.lua",

    -- Character Sheet
    {
        Scripts = {
            "UI/CharacterSheet/CharacterSheet.lua",
        },
    },

    -- UIs
    "UI/ContextMenu.lua",
    "UI/CharacterCreation.lua",
    "UI/Overhead.lua",
    "UI/MessageBox.lua",
    {
        Scripts = {
            "UI/PlayerInfo/Main.lua",
            "UI/PlayerInfo/FlashArrayTemplates.lua",
        },
    },
    "UI/PartyInventory.lua",
    "UI/ContainerInventory.lua",
    "UI/GameMenu.lua",
    "UI/TutorialBox.lua",
    "UI/Examine.lua",
    "UI/Tooltip.lua",
    "UI/Trade.lua",
    "UI/LoadingScreen.lua",
    "UI/Skills.lua",
    "UI/MainMenu.lua",

    "UI/Controller/MainMenu.lua",
    "UI/Controller/GameMenu.lua",
    "UI/Controller/Minimap.lua",
    "UI/Controller/BottomBar.lua",
    "UI/Controller/ContextMenu.lua",
    "UI/Controller/Examine.lua",
    "UI/Controller/InventorySkillPanel.lua",
    "UI/Controller/PartyInventory.lua",
    "UI/Controller/EquipmentPanel.lua",
    "UI/Controller/PanelSelect.lua",
    "UI/Controller/AreaInteract.lua",
    "UI/Controller/MessageBox.lua",

    -- GM UIs
    {Script = "UI/GM/Roll.lua", GameModes = GAMEMODE_MASK.GameMaster},

    -- TooltipLib
    {
        Scripts = {
            "Utilities/Client/Tooltip/Main.lua",
            "Utilities/Client/Tooltip/Parser.lua",
            "Utilities/Client/Tooltip/Status.lua",
            "Utilities/Client/Tooltip/Controller.lua",
        },
    },

    -- GenericUI
    "Epip/GenericUITextures/Client.lua", -- Should be loaded before Generic itself
    {
        Scripts = {
            "UI/Generic/Main.lua",
            "UI/Generic/Instance.lua",
            "UI/Generic/Prefab.lua",

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
            "UI/Generic/Elements/Texture.lua",

            "UI/Generic/Interfaces/Stylable.lua",
            "UI/Generic/Interfaces/Elementable.lua",
            "UI/Generic/Interfaces/Container.lua",

            "UI/Generic/Navigation/Navigation.lua",
            "UI/Generic/Navigation/Controller.lua",
            "UI/Generic/Navigation/Component.lua",
            "UI/Generic/Navigation/LegacyElementNavigation.lua",
            "UI/Generic/Navigation/Components/Generic.lua",
            "UI/Generic/Navigation/Components/List.lua",
            "UI/Generic/Navigation/Components/ScrollList.lua",
            "UI/Generic/Navigation/Components/Grid.lua",

            "UI/Generic/Prefabs/Text.lua",
            "UI/Generic/Prefabs/HotbarSlot.lua",
            "UI/Generic/Prefabs/FormHorizontalList.lua",
            "UI/Generic/Prefabs/LabelledIcon.lua",
            "UI/Generic/Prefabs/Status.lua",
            "UI/Generic/Prefabs/TooltipPanel.lua",
            "UI/Generic/Prefabs/FormElementBackground.lua",
            "UI/Generic/Prefabs/FormElement.lua",
            "UI/Generic/Prefabs/LabelledCheckbox.lua",
            "UI/Generic/Prefabs/LabelledSlider.lua",
            "UI/Generic/Prefabs/LabelledDropdown.lua",
            "UI/Generic/Prefabs/LabelledTextField.lua",
            "UI/Generic/Prefabs/LabelledSlot.lua", -- TODO rebrand and reorganize these; clearer to call them "form elements"
            "UI/Generic/Prefabs/LabelledColor.lua",
            "UI/Generic/Prefabs/FormSetEntry.lua",
            "UI/Generic/Prefabs/FormSet.lua",
            "UI/Generic/Prefabs/FormTextHolder.lua",
            "UI/Generic/Prefabs/Selector.lua",
            "UI/Generic/Prefabs/DraggingArea.lua",
            "UI/Generic/Prefabs/LoadingFlower.lua",
            "UI/Generic/Prefabs/ValueLabel.lua",
            "UI/Generic/Prefabs/Image.lua",

            "UI/Generic/Prefabs/Button/Prefab.lua",
            "UI/Generic/Prefabs/Button/Styles.lua",

            "UI/Generic/Prefabs/Spinner.lua",

            "UI/Generic/Prefabs/CloseButton.lua",
            "UI/Generic/Prefabs/SearchBar.lua",

            "UI/Generic/Prefabs/SlicedTexture/Prefab.lua",
            "UI/Generic/Prefabs/SlicedTexture/Styles.lua",

            "UI/Generic/Prefabs/AnchoredText.lua",

            "UI/Generic/Prefabs/Containers/PooledContainer.lua",

            "UI/Generic/Prefabs/Containers/VerticalList.lua",
            "UI/Generic/Prefabs/Containers/RadialList.lua",
        },
    },
    "Epip/GenericUITextures/Client_TestUI.lua", -- Should be loaded after Generic itself
    "Epip/NavigationBar/Client.lua",

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
    "UI/Saving.lua",
    "UI/GiftBagContent.lua",
    "UI/ChatLog.lua",
    "UI/SaveLoad.lua",
    "UI/Craft.lua",
    "UI/Reward.lua",
    "UI/WorldTooltip.lua",
    "UI/CombatTurn.lua",
    "UI/Fade.lua",
    "UI/Dialog.lua",

    -- Title screen UIs
    "UI/Mods.lua",

    -- Utility features
    {
        Scripts = {
            "Epip/IconPicker/Client.lua",
            "Epip/IconPicker/UI.lua",
        },
    },
    {
        Scripts = {
            "Epip/ColorPicker/Client.lua",
            "Epip/ColorPicker/UI.lua",
        },
    },
    "Epip/SkillPicker/Client.lua",
    {
        Scripts = {
            "Epip/InputBinder/Client.lua",
            "Epip/InputBinder/UI.lua",
        },
    },
    {Script = "Epip/SettingWidgets/Client.lua"},
    {
        Scripts = {
            "Epip/Assprite/Client.lua",
            "Epip/Assprite/Tools/_Tool.lua",
            "Epip/Assprite/Tools/Brush.lua",
            "Epip/Assprite/Tools/ColorPicker.lua",
            "Epip/Assprite/Tools/Bucket.lua",
            "Epip/Assprite/Tools/Blur.lua",
            "Epip/Assprite/Tools/Noise.lua",
            "Epip/Assprite/UI.lua",
        },
    },
    "Epip/IDEAnnotations/Client.lua",

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

    "Epip/Client/NameTypoFixes.lua",
    "Epip/Client/ExamineImprovements.lua",
    "Epip/Client/ControllerMouse.lua",

    {
        Script = "Epip/TooltipAdjustments/Client.lua",
        Scripts = {
            "Epip/TooltipAdjustments/Client_Scrolling.lua",
            "Epip/TooltipAdjustments/Client_RuneCraftingHint.lua",
            {Script = "Epip/TooltipAdjustments/Client_RewardGenerationWarning.lua", RequiresEE = true},
            "Epip/TooltipAdjustments/Client_WeaponRangeDeltamod.lua",
            "Epip/TooltipAdjustments/Client_DamageTypeDeltamods.lua",
            "Epip/TooltipAdjustments/Client_SimpleTooltips.lua",
            "Epip/TooltipAdjustments/Client_AstrologerFix.lua",
            "Epip/TooltipAdjustments/Client_SurfaceTooltips.lua",
            "Epip/TooltipAdjustments/Client_DeltaModTiers.lua",
            "Epip/TooltipAdjustments/Client_RemoveSetPrefix.lua",
            "Epip/TooltipAdjustments/Client_StatusImprovements.lua",
            "Epip/TooltipAdjustments/Client_TooltipLayer.lua",
            "Epip/TooltipAdjustments/Client_MovementCosts.lua",
            "Epip/TooltipAdjustments/Client_MasterworkedHint.lua",
            "Epip/TooltipAdjustments/Client_ContainerPreview.lua",
            "Epip/TooltipAdjustments/Client_EmptyItemRequirementFix.lua",
            {Script = "Epip/TooltipAdjustments/Client_BaseDeltamodTiers.lua", RequiresEE = true},
            "Epip/TooltipAdjustments/Client_OpaqueBackground.lua",
            {Script = "Epip/TooltipAdjustments/Client_SourceInfusions.lua", RequiresEE = true},
            "Epip/TooltipAdjustments/InventoryTooltipsRepositioning/Client.lua",
            "Epip/TooltipAdjustments/TooltipDelay/Client.lua",
            "Epip/TooltipAdjustments/ResourceCostBoostsFix/Client.lua",
            "Epip/TooltipAdjustments/SkillDamageMultipliers/Client.lua",
            "Epip/TooltipAdjustments/ScriptedStatusesDamage/Client.lua",
            "Epip/TooltipAdjustments/CharacterSheet/Client.lua",
            {ScriptSet = "Epip/TooltipAdjustments/AbeyanceBufferDisplay", RequiresEE = true},
            "Epip/TooltipAdjustments/StatAdjustmentMerging/Client.lua",
            "Epip/TooltipAdjustments/AprilFools/Client.lua",
            "Epip/TooltipAdjustments/CombatRangeWarning/Client.lua",
            {Script = "Epip/TooltipAdjustments/Artifacts/Client.lua", RequiresEE = true},
            {Script = "Epip/TooltipAdjustments/DeveloperInfo/Client.lua", Developer = true},
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
    "Epip/CloseUpDialogueFix/Client.lua",
    "Epip/Client/Notifications.lua",
    "Epip/Client/CraftingFixes.lua",
    "Epip/SkillbookIconsFix/Client.lua",
    "Epip/AreaInteractFix/Client.lua",
    "Epip/BookLayerFix/Client.lua",
    "Epip/UserVarsGUIDSyncWorkaround/Client.lua",
    "Epip/Client/RewardItemComparison.lua",
    {ScriptSet = "Epip/HotbarTweaks"},
    "Epip/Client/ExamineKeybind.lua",
    "Epip/Client/MoreWorldTooltips.lua",
    "Epip/Client/EnemyHealthBarExtraInfo.lua",
    "Epip/TurnNotifications/Client.lua",
    "Epip/SettingsMenuShortcut/Client.lua",
    {Script = "Epip/UILayout/Client.lua"},

    {ScriptSet = "Epip/OverheadFixes"},

    {ScriptSet = "Epip/Greatforge/DrillSockets", RequiresEE = true},
    {ScriptSet = "Epip/Greatforge/Engrave", RequiresEE = true},
    {ScriptSet = "Epip/InfiniteCarryWeight"},
    {ScriptSet = "Epip/DebugDisplay", Developer = true,},
    {ScriptSet = "Epip/UnlearnSkills"},
    {ScriptSet = "Epip/WorldTooltipOpenContainers"},
    {ScriptSet = "Epip/AutoUnlockInventory"},
    {ScriptSet = "Epip/DiscordRichPresence"},

    "Epip/ShowConsumableEffects.lua",
    "Epip/WalkOnCorpses.lua",

    -- Quick Examine
    {
        Scripts = {
            "Epip/Client/QuickExamine/Client.lua",

            "Epip/Client/QuickExamine/Widgets/_Grid.lua",
            "Epip/Client/QuickExamine/Widgets/Resources.lua",
            "Epip/Client/QuickExamine/Widgets/Resistances.lua",
            "Epip/Client/QuickExamine/Widgets/Immunities.lua",
            "Epip/Client/QuickExamine/Widgets/Statuses.lua",
        },
    },
    {Script = "Epip/Client/QuickExamine/Widgets/Artifacts.lua", RequiresEE = true},
    "Epip/Client/QuickExamine/Widgets/Skills.lua",
    "Epip/Client/QuickExamine/Widgets/Equipment.lua",

    "Epip/Client/GenericUIs/SaveLoadOverlay.lua",
    {
        ScriptSet = "Epip/HotbarGroups",
        Scripts = {
            "Epip/HotbarGroups/UIs/Creator.lua",
            "Epip/HotbarGroups/UIs/HotbarGroup.lua",
        },
    },
    {
        Scripts = {
            "Epip/RadialMenus/Client.lua",
            "Epip/RadialMenus/Prefabs/Slot.lua",
            "Epip/RadialMenus/Prefabs/RadialMenu.lua",
            "Epip/RadialMenus/Menus/_Menu.lua",
            "Epip/RadialMenus/Menus/Hotbar.lua",
            "Epip/RadialMenus/Menus/Custom.lua",
            "Epip/RadialMenus/UI/Main.lua",
            "Epip/RadialMenus/UI/Main/Navigation.lua",
            "Epip/RadialMenus/UI/MenuCreator.lua",
            "Epip/RadialMenus/UI/MenuCreator/Navigation.lua",
        },
    },

    "Epip/Client/AprilFoolsCharacterSheet.lua",
    "Epip/AprilFools/AnimationCancellingHotkey/Client.lua",
    "Epip/AprilFools/OverheadTextFixes/Client.lua",
    {
        ScriptSet = "Epip/CustomPortraits",
    },
    "Epip/Screensaver/Client.lua",
    "Epip/Client/ExitChatAfterMessage.lua",
    "Epip/Client/CameraZoom.lua",
    "Epip/CameraControls/Client.lua",
    "Epip/Client/MinimapToggle.lua",
    {Script = "Epip/Client/ImmersiveMeditation.lua", RequiresEE = true},
    -- "Epip/Client/ModMenuImprovements.lua",

    -- Chat Commands
    {
        ScriptSet = "Epip/ChatCommands",
    },
    "Epip/EmoteCommands.lua",

    {Script = "Epip/Compatibility/WeaponExpansion/Client.lua", RequiredMods = {MODS.WEAPON_EXPANSION}},
    {Script = "Epip/Compatibility/DerpyEETweaks/TreasureTableDisplay.lua", RequiredMods = {MODS.EE_DERPY}},

    -- Stats tab
    {
        Scripts = {
            "Epip/StatsTab/Shared.lua",
            "Epip/StatsTab/Data/Categories.lua",
            "Epip/StatsTab/Data/Stats.lua",
            "UI/CharacterSheet/StatsTab.lua", -- UI for stats tab - very old tech
            "Epip/StatsTab/Client/Client.lua",
            "Epip/StatsTab/Client/StatGetters.lua",
        },
    },
    {Script = "Epip/StatsTab/Data/Categories_EpicEncounters.lua", RequiresEE = true},
    {Script = "Epip/StatsTab/Data/Stats_EpicEncounters.lua", RequiresEE = true},
    {Script = "Epip/StatsTab/Data/Stats_Artifacts.lua", RequiresEE = true},

    "Epip/Client/CharacterSheetResistances.lua",
    "Epip/Client/CharacterSheetLevelProgress.lua",
    "Epip/Client/DifficultyToggle.lua",
    -- "Epip/AwesomeSoccer/Client.lua",
    {Script = "Epip/GiftbagLocker/Client.lua"},
    {Script = "Epip/GiftbagLocker/Incompatibilities/EpicEncounters.lua", RequiresEE = true},
    "Epip/Client/ChatNotificationSound.lua",
    "Epip/DialogueTweaks/Client.lua",
    "Epip/FastForwardDialogue/Client.lua",
    "Epip/ContainerInventoryTweaks/Client.lua",
    "Epip/Client/ToggleableWorldTooltips.lua",
    "Epip/Client/WorldTooltipFiltering.lua",
    "Epip/Client/HoverCharacterEffects.lua",
    "Epip/Client/IncompatibleModsWarning.lua",
    "Epip/LocalCoopSupportWarning/Client.lua",
    -- "Epip/Client/LoadingScreenReplacement.lua",

    -- Hotbar stuff
    {ScriptSet = "Epip/Hotbar/Actions"},

    {ScriptSet = "Epip/AscensionShortcuts", RequiresEE = true},

    -- Epic Enemies
    {
        Scripts = {
            "Epip/EpicEnemies/Shared.lua",
            "Epip/EpicEnemies/Client.lua",
            "Epip/EpicEnemies/Effects.lua",
            "Epip/EpicEnemies/ActivationConditionsClient.lua",
            "Epip/EpicEnemies/QuickExamineWidget.lua",
        },
        RequiresEE = true,
    },

    "Epip/PreferredTargetDisplay/Shared.lua",
    "Epip/PreferredTargetDisplay/Client.lua",

    {ScriptSet = "Epip/ItemTagging"},
    {ScriptSet = "Epip/ExtraDataConfig", Developer = true,},
    -- {ScriptSet = "Epip/Housing", WIP = true,},
    -- {Script = "Epip/Housing/Shared_Furniture.lua", WIP = true},
    {ScriptSet = "Epip/StatsEditor", WIP = true,},
    {ScriptSet = "Epip/APCostBoostFix"},
    {ScriptSet = "Epip/GreatforgeDragDrop", RequiresEE = true},
    {ScriptSet = "Epip/Greatforge/MassDismantle", RequiresEE = true},

    {ScriptSet = "Epip/ContextMenus/Greatforge", RequiresEE = true},
    "Epip/ContextMenus/PlayerInfo.lua",

    -- Vanity
    {
        ScriptSet = "Epip/Vanity",
        Scripts = {
            "UI/Vanity/Vanity.lua",
            "UI/Vanity/Tabs/_Tab.lua",
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
    {ScriptSet = "UI/Vanity/Tabs/Shapeshift", WIP = true},

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

            "Epip/QuickInventory/UI.lua",
            "Epip/QuickInventory/UI_Navigation.lua",

            "Epip/QuickInventory/Filters/Equipment.lua",
            "Epip/QuickInventory/Filters/Consumables.lua",
            "Epip/QuickInventory/Filters/Skillbooks.lua",
            "Epip/QuickInventory/Filters/Miscellaneous.lua",
            "Epip/QuickInventory/Filters/Containers.lua",
        }
    },
    {ScriptSet = "Epip/QuickLoot", Scripts = {"Epip/QuickLoot/Client_UI.lua", "Epip/QuickLoot/Client_UI_Navigation.lua"}},

    {
        Script = "Epip/Client/EE_Dyes.lua",
        RequiresEE = true,
    },

    -- Codex
    {
        Scripts = {
            "Epip/Codex/Client.lua",
            "Epip/Codex/Client_UI.lua",

            "Epip/Codex/Sections/__Grid.lua",
            "Epip/Codex/Sections/Skills.lua",
            "Epip/Codex/Sections/Info/Main.lua",
        },
    },
    {Script = "Epip/Codex/Sections/Artifacts.lua", RequiresEE = true},

    {ScriptSet = "Epip/EpipInfoCodex"},

    -- GM features
    {Script = "Epip/GM/AutomaticRollBonuses/Client.lua", GameModes = GAMEMODE_MASK.GameMaster},

    {Script = "Epip/Compatibility/MajoraFashionSins/Client.lua", RequiredMods = {MODS.MAJORA_FASHION_SINS}},
    {Script = "Epip/Compatibility/PortableRespecMirror/Shared.lua", RequiredMods = {MODS.PORTABLE_RESPEC_MIRROR}},
    {Script = "Epip/Compatibility/RendalNPCArmor/Client.lua", RequiredMods = {MODS.RENDAL_NPC_ARMOR}},
    {Script = "Epip/Compatibility/VisitorsFromCyseal/Client.lua", RequiredMods = {MODS.VISITORS_FROM_CYSEAL}},
    {Script = "Epip/Compatibility/DerpysArtifactTiers/Client.lua", RequiredMods = {MODS.EE_DERPY_ARTIFACT_TIERS}},

    {ScriptSet = "Epip/PunisherVoiceActing", RequiredMods = {MODS.EE_DERPY}},

    "Epip/Client/HideIncons.lua",

    {ScriptSet = "Epip/AnimationCancelling"},
    {ScriptSet = "Epip/FlagsDisplay"},
    {
        ScriptSet = "Epip/InventoryMultiSelect",
        Scripts = {
            "Epip/InventoryMultiSelect/Client_UI.lua",
            "Epip/InventoryMultiSelect/SelectionHandlers/PartyInventory.lua",
            "Epip/InventoryMultiSelect/SelectionHandlers/ContainerInventory.lua",
            "Epip/InventoryMultiSelect/MultiDragHandlers/Client.lua",
            {ScriptSet = "Epip/InventoryMultiSelect/ContextMenuActions"},
        },
    },

    "Epip/Client/ImageViewer.lua",
    "Epip/Client/SettingsMenuOverlay.lua",
    "Epip/Client/SettingsMenu/UI_Navigation.lua",
    "Epip/InputSettingsMenu/Client.lua",

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
            "Epip/Bedazzled/Model/Gem/States/MoveFrom.lua",

            "Epip/Bedazzled/Model/GameModes/_GameMode.lua",
            "Epip/Bedazzled/Model/GameModes/Classic.lua",
            "Epip/Bedazzled/Model/GameModes/Twimstve.lua",

            "Epip/Bedazzled/Model/Modifiers/_Modifier.lua",
            "Epip/Bedazzled/Model/Modifiers/TimeLimit.lua",
            "Epip/Bedazzled/Model/Modifiers/MoveLimit.lua",
            "Epip/Bedazzled/Model/Modifiers/RaidMechanics.lua",
            "Epip/Bedazzled/Model/Modifiers/HyenaMode.lua",
            "Epip/Bedazzled/Model/Modifiers/CementMixer.lua",

            "Epip/Bedazzled/UI/Menu.lua",
            "Epip/Bedazzled/UI/ModifierOverlays.lua",
            "Epip/Bedazzled/UI/Game/Classic.lua",
            "Epip/Bedazzled/UI/Game/Twimstve.lua",
        },
    },
    {Script = "Epip/Client/RainbowOverlays.lua"},
    {
        Scripts = {
            "Epip/ProgrammableLights/Client.lua",
            "Epip/ProgrammableLights/Program.lua",
            "Epip/ProgrammableLights/Prefabs/Light.lua",
            "Epip/ProgrammableLights/Programs/Default.lua",
        },
    },

    -- BH Overheads
    {
        Scripts = {
            "Epip/BHOverheads/Shared.lua",
            "Epip/BHOverheads/Client.lua",
            "Epip/BHOverheads/UI.lua",
        },
        RequiresEE = true,
    },

    {ScriptSet = "Epip/HotbarPersistence"},
    {ScriptSet = "Epip/TogglePartyLink"},
    {ScriptSet = "Epip/TradeContainers"},

    -- Statuses display
    {
        Scripts = {
            "Epip/StatusesDisplay/Client.lua",
            "Epip/StatusesDisplay/UI/Display.lua",
        },
    },

    {Script = "Epip/StatusConsoleDividers/Client.lua"},

    "Epip/Client/EpipSettingsMenu.lua",
    "Epip/Keybindings/Client.lua",

    {
        ScriptSet = "Epip/MeditateControllerSupport",
        Scripts = {
            "Epip/MeditateControllerSupport/UI/Overlay.lua",
            "Epip/MeditateControllerSupport/Pages/Ascension/MainHub.lua",
            "Epip/MeditateControllerSupport/Pages/Ascension/Gateway.lua",
            "Epip/MeditateControllerSupport/Pages/Ascension/Cluster.lua",
        },
        RequiresEE = true,
    },

    -- Tips; should load as late as possible as it references other features
    {
        Scripts = {
            "Epip/Tips/Client.lua",
            "Epip/Tips/Tips.lua",
        },
    },

    -- Debug Cheats
    {
        ScriptSet = "Epip/DebugCheats",
        Scripts = {
            "Epip/DebugCheats/ActionTypes/_Action.lua",
        },
    },
    "Epip/DebugCheats/UI/UI.lua",
    {ScriptSet = "Epip/DebugCheats/Cheats/CopyIdentifier"},
    {ScriptSet = "Epip/DebugCheats/Cheats/CopyPosition"},
    {Script = "Epip/DebugCheats/Cheats/SpawnItemTemplate/Shared.lua"},
    {ScriptSet = "Epip/DebugCheats/Cheats/TeleportTo"},

    {
        ScriptSet = "Epip/SurfacePainter",
        Scripts = {
            "Epip/SurfacePainter/Client_UI.lua",
        },
        Developer = true,
    },

    {Script = "Epip/Client/OverlayColorsBruteForcer.lua", Developer = true},
    {
        ScriptSet = "Epip/PersonalScripts",
        Scripts = {
            "Epip/PersonalScripts/Prefabs/Entry.lua",
        },
    },

    -- Should be loaded last
    {ScriptSet = "Epip/DebugMenu", Developer = true,},
}

Ext.Require(prefixedGUID, "Bootstrap.lua")
Ext.Require(prefixedGUID, "_LastScript.lua")
