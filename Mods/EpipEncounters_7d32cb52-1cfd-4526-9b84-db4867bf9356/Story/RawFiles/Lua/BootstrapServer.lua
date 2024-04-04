
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
Ext.Require("BootstrapBefore.lua")
Utilities = {}

PersistentVars = PersistentVars or {}

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
    {
        Scripts = {
            "Utilities/Testing/Shared.lua",
            "Utilities/Testing/_Test.lua",
        },
    },

    "Data/Game.lua",

    "Utils.lua",
    "Utilities/table.lua",
    "Utilities/math.lua",
    "Utilities/IO.lua",
    "Utilities/Vector.lua",
    "Utilities/Color.lua",

    -- Data structures
    {
        Scripts = {
            "Utilities/DataStructures/Main.lua",
            "Utilities/DataStructures/DefaultTable.lua",
            "Utilities/DataStructures/Set.lua",
            "Utilities/DataStructures/ObjectPool.lua",
        },
    },
    {
        Scripts = {
            "Utilities/Net/Shared.lua",
        },
    },
    {ScriptSet = "Utilities/Entity"},

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
    "Utilities/Mod.lua",
    "Utilities/Timer.lua",
    "Utilities/Coroutine.lua",
    {
        Scripts = {
            "Server/Osiris/Osiris.lua",
            "Server/Osiris/SymbolRegistrations.lua",
        },
    },
    {ScriptSet = "Utilities/GameState"},
    "Utilities/UserVars.lua",

    {ScriptSet = "Utilities/Combat"},
    "Utilities/Texture.lua",
    "Utilities/Profiling.lua",
    {ScriptSet = "Utilities/Artifact", RequiresEE = true,},

    {ScriptSet = "Utilities/Character"},
    "Utilities/Character/Shared_Talents.lua",

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
        },
    },
}
for _,lib in ipairs(coreLibraries) do
    RequestScriptLoad(lib)
end

local MODS = Mod.GUIDS

---@type (string|ScriptLoadRequest)[]
LOAD_ORDER = {
    "Epip/Settings.lua",

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

    "Epip/SkillbookTemplates/Shared.lua",

    "Game/AMERUI/Shared.lua",
    "Game/AMERUI/Server.lua",
    "Game/Ascension/Shared.lua",
    "Game/Ascension/Server.lua",

    "EpicStatsKeywords.lua",
    "EpicStatsDefinitions.lua",
    "EpipEncountersServer.lua",

    -- "GreatforgeExclude.lua",

    "Epip/Server/Shroud.lua",
    "Epip/Server/AMERUI_Controller.lua",

    "Epip/Server/AutoIdentify.lua",
    "Epip/Server/DebugCheats.lua",
    "Epip/Server/AI.lua",
    "Epip/Server/ForceStoryPatching.lua",
    "Epip/Server/HotbarServer.lua",
    {Script = "Epip/TooltipAdjustments/Server.lua"},
    {ScriptSet = "Epip/WorldTooltipOpenContainers"},

    -- Chat Commands
    {
        ScriptSet = "Epip/ChatCommands",
    },
    "Epip/EmoteCommands.lua",
    "Debug/Commands/Server.lua",

    -- Hotbar stuff
    {ScriptSet = "Epip/Hotbar/Actions"},

    -- Epic Enemies
    {
        Scripts = {
            "Epip/EpicEnemies/Shared.lua",
            "Epip/EpicEnemies/InitRequest.lua",
            "Epip/EpicEnemies/EffectTemplates.lua",
            "Epip/EpicEnemies/ActivationConditions.lua",
            "Epip/EpicEnemies/Server.lua",
            "Epip/EpicEnemies/Effects.lua",
        },
        RequiresEE = true,
    },

    {ScriptSet = "Epip/OverheadFixes"},
    {ScriptSet = "Epip/AscensionShortcuts", RequiresEE = true},
    {ScriptSet = "Epip/Greatforge/DrillSockets", RequiresEE = true},
    {ScriptSet = "Epip/Greatforge/Engrave", RequiresEE = true},
    {Script = "Epip/Greatforge/Empower/Server.lua", RequiresEE = true},

    "Epip/PreferredTargetDisplay/Shared.lua",
    "Epip/PreferredTargetDisplay/Server.lua",

    {ScriptSet = "Epip/ItemTagging"},
    {ScriptSet = "Epip/ExtraDataConfig", Developer = true,},
    {ScriptSet = "Epip/InfiniteCarryWeight",},
    {ScriptSet = "Epip/Housing", WIP = true,},
    {Script = "Epip/Housing/Shared_Furniture.lua", WIP = true},
    {ScriptSet = "Epip/StatsEditor", WIP = true,},
    {ScriptSet = "Epip/APCostBoostFix"},
    {ScriptSet = "Epip/GreatforgeDragDrop", RequiresEE = true},
    {ScriptSet = "Epip/Greatforge/MassDismantle", RequiresEE = true},

    {ScriptSet = "Epip/DebugDisplay", Developer = true,},
    {ScriptSet = "Epip/UnlearnSkills"},
    {ScriptSet = "Epip/AutoUnlockInventory"},

    "Epip/ShowConsumableEffects.lua",

    -- Stats tab
    {
        Scripts = {
            "Epip/StatsTab/Shared.lua",
            "Epip/StatsTab/Data/Categories.lua",
            "Epip/StatsTab/Data/Stats.lua",
            "Epip/StatsTab/Server/Server.lua",
            "Epip/StatsTab/Server/StatGetters.lua",
        },
    },
    {Script = "Epip/StatsTab/Data/Categories_EpicEncounters.lua", RequiresEE = true},
    {Script = "Epip/StatsTab/Data/Stats_EpicEncounters.lua", RequiresEE = true},
    {Script = "Epip/StatsTab/Data/Stats_Artifacts.lua", RequiresEE = true},

    {Script = "Epip/ContextMenus/Greatforge/Server.lua", RequiresEE = true},

    -- Vanity
    {
        ScriptSet = "Epip/Vanity",
    },
    -- Vanity Transmog
    {
        ScriptSet = "Epip/Vanity/Transmog",
    },
    -- Vanity Dyes
    {
        ScriptSet = "Epip/Vanity/Dyes",
    },
    -- Vanity Auras
    {
        ScriptSet = "Epip/Vanity/Auras",
        Scripts = {
            "Epip/Vanity/Auras/Shared_Data.lua",
        },
    },

    -- Fishing
    {
        WIP = true,
        ScriptSet = "Epip/Fishing",
        Scripts = {
            "Epip/Fishing/Shared_Data.lua",
        }
    },

    {ScriptSet = "Epip/AnimationCancelling",},
    {ScriptSet = "Epip/FlagsDisplay"},
    {
        ScriptSet = "Epip/InventoryMultiSelect",
        Scripts = {
            "Epip/InventoryMultiSelect/MultiDragHandlers/Server.lua",
            {ScriptSet = "Epip/InventoryMultiSelect/ContextMenuActions"},
        }
    },

    {ScriptSet = "UI/Vanity/Tabs/Shapeshift", WIP = true},

    "Epip/AwesomeSoccer/Server.lua",

    {ScriptSet = "Epip/TooltipAdjustments/AbeyanceBufferDisplay", RequiresEE = true},

    "Debug/Shared.lua",
    "Debug/Server.lua",

    {ScriptSet = "Epip/HotbarPersistence"},
    {ScriptSet = "Epip/EpipInfoCodex"},

    "Epip/OsirisIDEAnnotationGenerator.lua",

    -- Debug Cheats
    {
        ScriptSet = "Epip/DebugCheats",
        Scripts = {
            "Epip/DebugCheats/ActionTypes/_Action.lua",
        },
    },
    {ScriptSet = "Epip/DebugCheats/Cheats/CopyIdentifier"},
    {ScriptSet = "Epip/DebugCheats/Cheats/CopyPosition"},
    {ScriptSet = "Epip/DebugCheats/Cheats/SpawnItemTemplate"},
    {ScriptSet = "Epip/DebugCheats/Cheats/TeleportTo"},

    {ScriptSet = "Epip/SurfacePainter", Developer = true},

    -- Compatibility
    {Script = "Epip/Compatibility/PortableRespecMirror/Shared.lua", RequiredMods = {MODS.PORTABLE_RESPEC_MIRROR}},

    {ScriptSet = "Epip/PunisherVoiceActing", RequiredMods = {MODS.EE_DERPY}},

    {Script = "Epip/PersonalScripts/Shared.lua", Developer = true},

    -- Should be loaded last
    {ScriptSet = "Epip/DebugMenu", Developer = true,},
}

Ext.Require(prefixedGUID, "Bootstrap.lua")

function GreatforgeGetItemData(char, item)
    char = Character.Get(char)
    item = Item.Get(item)

    local level = item.Stats.Level
    local itemType = item.Stats.ItemTypeReal
    local slot = item.Stats.ItemSlot

    slot  = tostring(slot)

    -- returns ilevel, itemtype, slot,
    return Text.RemoveTrailingZeros(level), itemType, slot
end

NULLGUID = "NULL_00000000-0000-0000-0000-000000000000"

local _registeredSymbols = {}
Net.RegisterListener("EPIP_RegisterGenericOsiSymbolEvent", function(payload)
    -- Don't register listeners multiple times
    -- Alternatively we could only send these requests from the host client :thinking:
    for i,s in ipairs(_registeredSymbols) do
        if s.Arity == payload.Arity and s.Symbol == payload.Symbol then
            return nil
        end
    end

    table.insert(_registeredSymbols, {Symbol = payload.Symbol, Arity = payload.Arity})

    Osiris.RegisterSymbolListener(payload.Symbol, payload.Arity, "after", function(...)
        Net.Broadcast("EPIP_GenericOsiSymbolEvent", {
            Symbol = payload.Symbol,
            Arity = payload.Arity,
            Params = {...},
        })
    end)
end)

GameState.Events.GamePaused:Subscribe(function (_)
    if Settings._SettingsLoaded then
        IO.SaveFile("_Epip_PersistentVars", PersistentVars)
    end
end)

Ext.Require(prefixedGUID, "_LastScript.lua");