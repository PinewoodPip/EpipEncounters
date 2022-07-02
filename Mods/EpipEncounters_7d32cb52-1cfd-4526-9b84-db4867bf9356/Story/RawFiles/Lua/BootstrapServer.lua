
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

Ext.Require(prefixedGUID, "Tables/Epip.lua");
Ext.Require(prefixedGUID, "Tables/_Events.lua");
Ext.Require(prefixedGUID, "Tables/_Feature.lua");
Ext.Require(prefixedGUID, "Data/Game.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utils.lua");
Ext.Require(prefixedGUID, "Utilities/Text.lua");
Ext.Require(prefixedGUID, "Epip/Settings.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utilities/Text.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utilities/Hooks.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utilities/Color.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utilities.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Utilities/Server.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Server/Osiris.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Data/Game.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game.lua");
Ext.Require(prefixedGUID, "Game/Characters/Shared.lua");
Ext.Require(prefixedGUID, "Game/Characters/Server.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Items/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Items/Server.lua");
Ext.Require(prefixedGUID, "Game/Stats/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Net/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Net/Server.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Talents/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Talents/Server.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/AMERUI/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/AMERUI/Server.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Ascension/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Game/Ascension/Server.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Config.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "EpicStatsKeywords.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "EpicStatsDefinitions.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "EpipEncountersServer.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "HotkeysServer.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "EpipTalents.lua");

-- Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "GreatforgeExclude.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/Shroud.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/AMERUI_Controller.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "JournalServer.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/PartyInventoryServer.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/AutoIdentify.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/DebugCheats.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/AI.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/ForceStoryPatching.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/DefaultHotbarActions.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/HotbarServer.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/IncompatibleModsWarning.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/ServerSettings.lua");
-- Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/Server/FastCasting.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/ChatCommands/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/ChatCommands/Server.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Epip/EmoteCommands.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Debug/Commands/Server.lua");

-- Epic Enemies
Ext.Require(prefixedGUID, "Epip/EpicEnemies/Shared.lua");
Ext.Require(prefixedGUID, "Epip/EpicEnemies/EffectTemplates.lua");
Ext.Require(prefixedGUID, "Epip/EpicEnemies/ActivationConditions.lua");
Ext.Require(prefixedGUID, "Epip/EpicEnemies/Server.lua");

-- Stats Tab
Ext.Require(prefixedGUID, "Epip/StatsTab/Shared.lua");
Ext.Require(prefixedGUID, "Epip/StatsTab/Server/Server.lua");
Ext.Require(prefixedGUID, "Epip/StatsTab/Server/StatGetters.lua");

Ext.Require(prefixedGUID, "Epip/ContextMenus/Greatforge/Server.lua");
Ext.Require(prefixedGUID, "Epip/ContextMenus/Dyes/Server.lua");
Ext.Require(prefixedGUID, "Epip/ContextMenus/Vanity/Shared.lua");
Ext.Require(prefixedGUID, "Epip/ContextMenus/Vanity/Server.lua");

Ext.Require(prefixedGUID, "Epip/AwesomeSoccer/Server.lua");

Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Debug/Shared.lua");
Ext.Require("EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356", "Debug/Server.lua");

-- intended to be used with NRD_ModCall from Osi.
function TestPrint(value)
    Ext.Print(value)
end

local function sendDyes(user)
    -- print("Sending dyes", user)
    -- _D(PersistentVars.Dyes)
    -- Game.Net.Broadcast("EPIPENCOUNTERS_CreateVanityDyes", {
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
        Game.Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = "PhysicalArmor"})
        Game.Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = "MagicArmor"})

    elseif healType == "PhysicalArmor" or healType == "MagicArmor" then
        Game.Net.Broadcast("EPIPENCOUNTERS_Overhead", {NetID = target.NetID, Amount = status.HealAmount, Type = healType})
    end
end)

-- Ext.RegisterListener("TreasureItemGenerated", function(item)
--     if not item:HasTag("AMER_DELTAMODS_HANDLED") and Osi.ItemIsEquipable(item.MyGuid) == 1 then
--         Ext.Print(item.MyGuid)
--         Osi.SetTag(item.MyGuid, "asdasd")

--         Osi.ItemToInventory(item.MyGuid, Osi.CharacterGetHostCharacter(), 1, 1 ,0)

--         -- crash
--         -- Osi.PROC_AMER_Deltamods_GenerateOnItem(item.MyGuid)
--     end
-- end)

-- function _ChangeTreasureTables(table1, table2)
--     Game.Stats.Treasure:SetOverride(table1, Ext.GetTreasureTable(table2))
-- end

local timers = {}

Game.Net.RegisterListener("EPIPENCOUNTERS_Timer", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid
    local owner = Osi.CharacterGetReservedUserID(char)

    if not timers[owner] then timers[owner] = {} end

    timers[owner][payload.Event] = true

    Osi.ProcObjectTimer(char, payload.Event, payload.Seconds * 1000)
end)


-- TODO better name
Ext.Osiris.RegisterListener("ProcObjectTimerFinished", 2, "after", function(char, event)
    local user = Osi.CharacterGetReservedUserID(char)
    if timers[user] and timers[user][event] then
        timers[user][event] = nil

        Game.Net.PostToUser(user, "EPIPENCOUNTERS_Timer", {Event = event})
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
    return RemoveTrailingZeros(level), itemType, slot
end

-- TODO move elsewhere. Some generic script for events that would be nice to have on client as well.
Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(char, status, causee)
    if status == "UNSHEATHED" then
        Game.Net.Broadcast("EPIP_StatusApplied", {NetID = Ext.GetCharacter(char).NetID, Status = status})
    end
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", function(char, status, causee)
    if status == "UNSHEATHED" then
        Game.Net.Broadcast("EPIP_StatusRemoved", {NetID = Ext.GetCharacter(char).NetID, Status = status})
    end
end)

-- TODO move
local function OnGenericOsirisSymbol(...)
    
end

NULLGUID = "NULL_00000000-0000-0000-0000-000000000000"

Game.Net.RegisterListener("EPIP_AMERUI_GoBack", function(cmd, payload)
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
Game.Net.RegisterListener("EPIP_RegisterGenericOsiSymbolEvent", function(cmd, payload)
    -- Don't register listeners multiple times
    -- Alternatively we could only send these requests from the host client :thinking:
    for i,s in ipairs(_registeredSymbols) do
        if s.Arity == payload.Arity and s.Symbol == payload.Symbol then
            return nil
        end
    end

    table.insert(_registeredSymbols, {Symbol = payload.Symbol, Arity = payload.Arity})

    Osiris.RegisterSymbolListener(payload.Symbol, payload.Arity, "after", function(...)
        Game.Net.Broadcast("EPIP_GenericOsiSymbolEvent", {
            Symbol = payload.Symbol,
            Arity = payload.Arity,
            Params = {...},
        })
    end)
end)

Ext.Require(prefixedGUID, "_LastScript.lua");

-- Osiris.RegisterSymbolListener("NRD_OnActionStateExit", 2, "after", function(char, state)
--     print("exit", char, state)
-- end)

local casters = {}
Osiris.RegisterSymbolListener("NRD_OnActionStateEnter", 2, "after", function(char, state)
    -- print("enter", char, state)
    local player = Osiris.DB_IsPlayer:Get(char)
    if state == "UseSkill" and player then
        casters[char] = true
        Game.Net.PostToOwner(Ext.GetCharacter(char), "EPIPENCOUNTERS_Hotbar_SkillUsed")
    end
end)

Ext.Events.Tick:Subscribe(function()
    for caster,_ in pairs(casters) do
        local state = NRD_CharacterGetCurrentAction(caster)

        if state ~= "UseSkill" then
            Game.Net.PostToOwner(Ext.GetCharacter(caster), "EPIPENCOUNTERS_Hotbar_SkillUseFinished")
            casters[caster] = nil
        end
    end
end)