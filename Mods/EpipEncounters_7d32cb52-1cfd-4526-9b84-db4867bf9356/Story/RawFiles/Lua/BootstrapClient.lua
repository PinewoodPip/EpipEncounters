
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

IS_IMPROVED_HOTBAR = false

LOAD_ORDER = {
    "Utilities/Event.lua",
    "Tables/Epip.lua",
    "Tables/_Events.lua",
    "Tables/_Feature.lua",

    -- Utilities
    "Utils.lua",
    "Utilities/Text.lua",
    "Utilities/Hooks.lua",
    "Utilities/Color.lua",
    "Utilities/GameState/Shared.lua",
    "Utilities/GameState/Client.lua",
    "Utilities/Mod.lua",
    "Utilities.lua",

    "Data/Game.lua", -- TODO move stuff out of it into appropriate scripts

    -- Static libraries
    "Game.lua",
    "Game/Characters/Shared.lua",
    "Game/Characters/Client.lua",
    "Game/Items/Shared.lua",
    "Game/Items/Client.lua",
    "Game/Stats/Shared.lua",
    "Utilities/Net/Shared.lua",
    "Utilities/Net/Client.lua",
    {ScriptSet = "Utilities/Artifact"},

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Sound.lua",
    "UI/Data.lua",
    "Client/Input.lua",
    "Tables/_UI.lua",

    "Client/Client.lua",
    "Client/Server.lua",
    "Client/Flash.lua",
    "Client/Sound.lua",
    "UI/Data.lua",
    "Client/Input.lua",

    "Game/Client/Tooltip.lua",
    "Game/Tooltip.lua",

    -- AMER UI
    "Game/AMERUI/Shared.lua",
    "Game/AMERUI/Client.lua",

    "Game/Ascension/Shared.lua",
    "Game/Ascension/Client.lua",

    "Game/SkillDamageCalculation.lua",

    "UI/Options.lua",
    "UI/OptionsSettings.lua",

    -- Needs to be ordered after the above.
    "Epip/Settings.lua",
    "Epip/Client/SettingsRegistration.lua",

    "UI/StatusConsole.lua",

    "EpicStatsKeywords.lua",
    "EpicStatsDefinitions.lua",

    "UI/EnemyHealthBar.lua",

    "Game/Client/Timers.lua",
    
    "UI/Input.lua",
    "UI/OptionsInput.lua",
    "UI/Time.lua",

    "UI/CharacterSheet/CharacterSheet.lua",
    "UI/CharacterSheet/StatsTab.lua",
    "UI/TextDisplay.lua",
    "UI/ContextMenu.lua",
    "UI/CharacterCreation.lua",
    "UI/Overhead.lua",
    "UI/MessageBox.lua",
    "UI/PlayerInfo.lua",
    "UI/PartyInventory.lua",
    "UI/GameMenu.lua",
    "UI/TutorialBox.lua",
    "UI/Examine.lua",

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
    "UI/Generic/Elements/ComboBox.lua",
    "UI/Generic/Prefabs/HotbarSlot.lua",
    "UI/Generic/Prefabs/Spinner.lua",
    -- "UI/Generic/Test.lua", -- TEST!

    "UI/Hotbar/Main.lua",
    "UI/Hotbar/ContextMenus.lua",
    "UI/Hotbar/Actions.lua",
    "UI/Hotbar/Loadouts.lua",
    "UI/Notification.lua",
    "UI/Minimap.lua",
    "UI/VanillaActions.lua",
    "UI/AprilFoolsOverlay.lua",
    "UI/Journal.lua",
    "UI/Saving.lua",
    "UI/GiftBagContent.lua",
    "UI/ChatLog.lua",
    "UI/SaveLoad.lua",
    "UI/CombatLog/CombatLog.lua",
    "UI/Craft.lua",

    "UI/Vanity/Vanity.lua",
    "UI/Vanity/Tabs/_Tab.lua",
    "UI/Vanity/Tabs/Transmog.lua",
    "UI/Vanity/Tabs/Outfits.lua",
    "UI/Vanity/Tabs/Dyes.lua",
    -- "UI/Vanity/Tabs/Auras.lua",
    {ScriptSet = "UI/Vanity/Tabs/Shapeshift", WIP = true},

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

    "UI/Controller/PanelSelect.lua",

    -- Talents
    "Game/Talents/Shared.lua",
    "Game/Talents/Client.lua",

    "Debug/Shared.lua",
    "Debug/Client.lua",
    "Debug/Commands/Client.lua",

    "EpipTalents.lua",

    "Epip/Client/ImmersiveMeditation.lua",
    "Epip/Client/NameTypoFixes.lua",
    "Epip/Client/ExamineImprovements.lua",
    "Epip/Client/TooltipAdjustments.lua",
    "Epip/Client/TreasureTableDisplay.lua",
    "Epip/Client/SummonControlFix.lua",
    "Epip/Client/Notifications.lua",
    "Epip/Client/CraftingFixes.lua",
    -- "Epip/Client/InventoryImprovements.lua",

    "Epip/Client/GenericUIs/QuickExamine.lua",
    "Epip/Client/GenericUIs/SaveLoadOverlay.lua",
    "Epip/Client/GenericUIs/HotbarGroup.lua",

    "Epip/Client/AprilFoolsCharacterSheet.lua",
    "Epip/Client/HotbarActions.lua",
    "Epip/Client/EpicEncountersActions.lua",
    "Epip/Client/AscensionShortcuts.lua",
    "Epip/Client/ModDocs.lua",
    "Epip/Client/JournalChangelog.lua",

    -- Chat commands
    "Epip/ChatCommands/Shared.lua",
    "Epip/ChatCommands/Client.lua",
    "Epip/EmoteCommands.lua",

    "Epip/Compatibility/WeaponExpansion/Client.lua",
    "Epip/Compatibility/DerpyEETweaks/TreasureTableDisplay.lua",

    "Epip/Client/EpipDocs.lua",

    -- Stats tab
    "Epip/StatsTab/Shared.lua",
    "Epip/StatsTab/Client/Client.lua",
    "Epip/StatsTab/Client/StatGetters.lua",

    "Epip/Client/CharacterSheetResistances.lua",
    "Epip/Client/DifficultyToggle.lua",
    -- "Epip/AwesomeSoccer/Client.lua",
    "Epip/Client/GiftbagLocker.lua",
    "Epip/Client/EE_Dyes.lua",

    -- Epic Enemies
    "Epip/EpicEnemies/Shared.lua",
    "Epip/EpicEnemies/Client.lua",
    "Epip/EpicEnemies/Effects.lua",
    "Epip/EpicEnemies/ActivationConditionsClient.lua",

    "Epip/StatusSorting.lua",

    "Epip/PreferredTargetDisplay/Shared.lua",
    "Epip/PreferredTargetDisplay/Client.lua",

    {ScriptSet = "Epip/ItemTagging"},

    -- AMER UI controller support
    -- "Epip/Client/AMERUI_Controller/AMERUI_Controller.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/MainHub.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/Gateway.lua",
    -- "Epip/Client/AMERUI_Controller/Handlers/Ascension/Cluster.lua",

    "Epip/ContextMenus/Greatforge/Client.lua",
    "Epip/ContextMenus/Dyes/Client.lua",
    "Epip/ContextMenus/PlayerInfo.lua", 
    "Epip/ContextMenus/Vanity/Shared.lua",
    "Epip/ContextMenus/Vanity/Client.lua",

    "Epip/Compatibility/MajoraFashionSins/Client.lua",
    "Epip/Compatibility/PortableRespecMirror/Client.lua",
    "Epip/Compatibility/RendalNPCArmor/Client.lua",
    "Epip/Compatibility/VisitorsFromCyseal/Client.lua",

    "Epip/Keybindings/Client.lua",
}

Utilities = {}

-- Epip does not work in-editor.
if Ext.Utils.GameVersion() ~= "v3.6.51.9303" then
    for _,script in ipairs(LOAD_ORDER) do
        if type(script) == "table" and (not script.WIP or Epip.IsDeveloperMode(true)) then
            local contextSpecificScript = "/Client.lua"
            if Ext.IsServer() then contextSpecificScript = "/Server.lua" end

            Ext.Require(prefixedGUID, script.ScriptSet .. "/Shared.lua")
            Ext.Require(prefixedGUID, script.ScriptSet .. contextSpecificScript)
        elseif type(script) == "string" then
            Ext.Require(prefixedGUID, script)
        end
    end
end

-- Loading screen replacement.
Ext.Events.SessionLoading:Subscribe(function()
    if Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "LoadingScreen") then
        -- loading screen replacement. only works after EpipEncounters has loaded. (no effect when module loads for the first time)
        Ext.IO.AddPathOverride("Public/Game/Assets/Textures/UI/DOS2_Loadscreen_DE.dds", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Assets/Textures/epip_encounters_loading_bg.dds")
    end
end)

Ext.Require(prefixedGUID, "_LastScript.lua")