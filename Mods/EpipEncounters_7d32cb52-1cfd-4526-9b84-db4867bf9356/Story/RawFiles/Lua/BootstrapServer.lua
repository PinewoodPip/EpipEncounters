
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

Utilities = {}

local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"

---@type (string|ScriptDefinition)[]
LOAD_ORDER = {
    "Utilities/Event.lua",
    "Tables/Epip.lua",
    "Tables/_Events.lua",
    "Tables/_Feature.lua",

    "Data/Game.lua",

    "Utils.lua",
    "Utilities/table.lua",
    "Utilities/math.lua",
    "Utilities/IO.lua",
    "Utilities/Vector.lua",
    "Utilities/Text.lua",
    "Utilities/Hooks.lua",
    "Utilities/Color.lua",
    {ScriptSet = "Utilities/Entity"},
    "Utilities/GameState/Shared.lua",
    "Utilities/GameState/Server.lua",
    "Utilities/Mod.lua",
    "Utilities.lua",
    "Utilities/Timer.lua",
    "Utilities/Coroutine.lua",
    {
        Scripts = {
            "Utilities/Settings/Shared.lua",
            "Utilities/Settings/Client.lua",
            "Utilities/Settings/Setting_Boolean.lua",
            "Utilities/Settings/Setting_Number.lua",
            "Utilities/Settings/Setting_ClampedNumber.lua",
            "Utilities/Settings/Setting_Choice.lua",
        },
        WIP = true,
    },
    {ScriptSet = "Utilities/Combat"},
    "Utilities/Server.lua",
    "Server/Osiris.lua",
    {ScriptSet = "Utilities/Artifact"},
    "Epip/Settings.lua",

    -- "Data/Game.lua",

    "Game.lua",

    {ScriptSet = "Utilities/Character"},
    "Utilities/Character/Shared_Talents.lua",
    "Game/Items/Shared.lua",
    "Game/Items/Server.lua",
    "Game/Stats/Shared.lua",
    "Game/Stats/Shared_ModifierLists.lua",
    "Game/Stats/Shared_ExtraData.lua",
    "Game/Stats/Shared_Actions.lua",
    "Game/Stats/Shared_Runes.lua",
    "Utilities/Net/Shared.lua",

    "Game/AMERUI/Shared.lua",
    "Game/AMERUI/Server.lua",
    "Game/Ascension/Shared.lua",
    "Game/Ascension/Server.lua",

    "EpicStatsKeywords.lua",
    "EpicStatsDefinitions.lua",
    "EpipEncountersServer.lua",
    "HotkeysServer.lua",

    -- "GreatforgeExclude.lua",

    "Epip/Server/Shroud.lua",
    "Epip/Server/AMERUI_Controller.lua",

    "JournalServer.lua",
    "Epip/Server/AutoIdentify.lua",
    "Epip/Server/DebugCheats.lua",
    "Epip/Server/AI.lua",
    "Epip/Server/ForceStoryPatching.lua",
    "Epip/Server/DefaultHotbarActions.lua",
    "Epip/Server/HotbarServer.lua",
    "Epip/Server/IncompatibleModsWarning.lua",
    "Epip/Server/ServerSettings.lua",
    {ScriptSet = "Epip/TooltipAdjustments"},
    {ScriptSet = "Epip/WorldTooltipOpenContainers"},
    -- "Epip/Server/FastCasting.lua",

    "Epip/ChatCommands/Shared.lua",
    "Epip/ChatCommands/Server.lua",
    "Epip/EmoteCommands.lua",
    "Debug/Commands/Server.lua",

    "Epip/EpicEnemies/Shared.lua",
    "Epip/EpicEnemies/EffectTemplates.lua",
    "Epip/EpicEnemies/ActivationConditions.lua",
    "Epip/EpicEnemies/Server.lua",
    "Epip/EpicEnemies/Effects.lua",
    
    {ScriptSet = "Epip/Greatforge/DrillSockets"},
    {ScriptSet = "Epip/Greatforge/Engrave"},
    "Epip/Greatforge/Empower/Server.lua",

    "Epip/PreferredTargetDisplay/Shared.lua",
    "Epip/PreferredTargetDisplay/Server.lua",
    
    {ScriptSet = "Epip/ItemTagging"},
    {ScriptSet = "Epip/ExtraDataConfig", Developer = true,},
    {ScriptSet = "Epip/Encumbrance",},
    {ScriptSet = "Epip/Housing", WIP = true,},
    {Script = "Epip/Housing/Shared_Furniture.lua", WIP = true},
    {ScriptSet = "Epip/StatsEditor", WIP = true,},
    {ScriptSet = "Epip/APCostBoostFix"},
    {ScriptSet = "Epip/DebugDisplay", Developer = true,},
    {ScriptSet = "Epip/UnlearnSkills"},
    {ScriptSet = "Epip/DebugMenu", Developer = true,},
    {ScriptSet = "Epip/AutoUnlockInventory"},

    "Epip/ShowConsumableEffects.lua",

    "Epip/StatsTab/Shared.lua",
    "Epip/StatsTab/Server/Server.lua",
    "Epip/StatsTab/Server/StatGetters.lua",

    "Epip/ContextMenus/Greatforge/Server.lua",
    "Epip/ContextMenus/Dyes/Server.lua",
    "Epip/ContextMenus/Vanity/Shared.lua",
    "Epip/ContextMenus/Vanity/Server.lua",
    {ScriptSet = "UI/Vanity/Tabs/Shapeshift", WIP = true},

    "Epip/AwesomeSoccer/Server.lua",

    "Debug/Shared.lua",
    "Debug/Server.lua",
}

Ext.Require(prefixedGUID, "Bootstrap.lua")

local function sendDyes(user)
    -- print("Sending dyes", user)
    -- _D(PersistentVars.Dyes)
    -- Net.Broadcast("EPIPENCOUNTERS_CreateVanityDyes", {
    --     Dyes = PersistentVars.Dyes or {},
    -- })
    Ext.Net.PostMessageToUser(user, "EPIPENCOUNTERS_CreateVanityDyes", Ext.Json.Stringify({
        Dyes = PersistentVars.Dyes or {},
    }))
end

Osiris.RegisterSymbolListener("UserEvent", 2, "after", function(user, ev)
    if ev == "PIP_LoadDyes" then
        sendDyes(user)
    end
end)

Osiris.RegisterSymbolListener("UserConnected", 3, "after", function(user)
    print("user joined")
    sendDyes(user)
end)

-- Ext.Events.SessionLoaded:Subscribe(function()
Osiris.RegisterSymbolListener("SavegameLoading", 4, "after", function(user)

    -- local dyeStat = {
    --     Name = "PIP_GENCOLOR_FF006699_FF669999_FF669999",
    --     Color1 = 6723993,
    --     Color2 = 6723993,
    --     Color3 = 6723993,
    -- }
    -- Ext.Stats.ItemColor.Update(dyeStat, true)

    

    Osi.IterateUsers("PIP_LoadDyes")
    -- Ext.Net.PostMessageToUser(user, "EPIPENCOUNTERS_CreateVanityDyes", {
    --     Dyes = PersistentVars.Dyes or {},
    -- })

    -- local statType = "Armor"
    -- local deltaModName = string.format("Boost_%s_%s", statType, dyeStat.Name)
    -- local boostStatName = "_" .. deltaModName
    -- local stat = Ext.Stats.Create(boostStatName, statType)
    -- Ext.Stats.SetPersistence(boostStatName, true)

    -- if stat then
    --     stat.ItemColor = dyeStat.Name
    -- end

    -- Ext.Stats.DeltaMod.Update({
    --     Name = deltaModName,
    --     MinLevel = 1,
    --     Frequency = 1,
    --     BoostType = "ItemCombo",
    --     ModifierType = statType,
    --     SlotType = "Sentinel",
    --     WeaponType = "Sentinel",
    --     Handedness = "Any",
    --     Boosts = {
    --         {
    --             Boost = boostStatName,
    --             Count = 1,
    --         }
    --     }
    -- })
end)

Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(target, id, causee)
    -- Disabled until a fix for clicking is found
    if true then return nil end
    target = Ext.GetCharacter(target)
    local status = target:GetStatus(id)

    if not status then return nil end
    if not target.Stats.TALENT_Zombie then return nil end
    if status.StatusType ~= "HEAL" and status.StatusType ~= "HEALING" then return nil end

    local healType = ""

    if status.StatusType == "HEALING" then
        healType = status.HealStat
    else
        healType = status.HealType
    end

    if healType == "AllArmor" then
        Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = "PhysicalArmor"})
        Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = "MagicArmor"})

    elseif healType == "PhysicalArmor" or healType == "MagicArmor" then
        Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = healType})
    end
end)

function GreatforgeGetItemData(char, item)
    char = Ext.GetCharacter(char)
    item = Ext.GetItem(item)

    local level = item.Stats.Level
    local itemType = item.Stats.ItemTypeReal
    local slot = item.Stats.ItemSlot
    -- local subType = item.Stats.ItemType

    -- returns ilevel, itemtype, slot,
    return Text.RemoveTrailingZeros(level), itemType, slot
end

-- TODO move elsewhere. Some generic script for events that would be nice to have on client as well.
Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(char, status, causee)
    if status == "UNSHEATHED" then
        Net.Broadcast("EPIP_StatusApplied", {NetID = Ext.GetCharacter(char).NetID, Status = status})
    end
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", function(char, status, causee)
    if status == "UNSHEATHED" then
        Net.Broadcast("EPIP_StatusRemoved", {NetID = Ext.GetCharacter(char).NetID, Status = status})
    end
end)

NULLGUID = "NULL_00000000-0000-0000-0000-000000000000"

Net.RegisterListener("EPIP_AMERUI_GoBack", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local instance, ui, _ = Osiris.DB_AMER_UI_UsersInUI(nil, nil, char.MyGuid)

    if instance ~= nil then
        local _, stackCount = Osiris.DB_AMER_UI_PageStack_Count(instance, nil)

        -- Pop page if there are any. We don't call the method directly as there are some special listeners for it to manipulate the stack in the Greatforge UI.
        if stackCount and stackCount > 0 and ui ~= "AMER_UI_ModSettings" then
            CharacterItemEvent(char.MyGuid, NULLGUID, "AMER_UI_GEN_PagePop")
        else -- Exit UI otherwise
            Osi.PROC_AMER_UI_ExitUI(char.MyGuid)
        end
    end
end)

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

Ext.Require(prefixedGUID, "_LastScript.lua");