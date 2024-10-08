
---------------------------------------------
-- Context menus containing debug cheats.
-- TODO:
-- Make the flexstat table only be parsed at SessionLoaded to make it easier to modify
---------------------------------------------

local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")

Epip.Features.DebugCheats = {
    -- FlexStats visible in the "Add FlexStat..." context menu.
    -- All FlexStats are supported and need no special implementation, we just only display select ones so as not make the context menu look bloated.
    VISIBLE_GENERIC_FLEXSTATS = {
        "DAMAGEBOOST",
        "VITALITYBOOST",
        "MOVEMENT",
        "MOVEMENTSPEEDBOOST",
        "INITIATIVE",
        "DODGEBOOST",
        "LIFESTEAL",
        "CRITICALCHANCE",
        "ACCURACYBOOST",
        "APMAXIMUM",
        "APRECOVERY",
        "APSTART",
        "RANGEBOOST",
        "Sight",
        "Hearing",
    }
}

Debug.CheatsContextMenu = {id = "playerInfo_Cheats", type = "subMenu", text = "Debugging Cheats...", subMenu = "epip_Cheats"}

local ContextMenu = Client.UI.ContextMenu
local MessageBox = Client.UI.MessageBox

local FLEXSTAT_CHEATS = {}

-- Talents
local TalentMenu = {}
for id,data in pairs(Character.Talents) do
    table.insert(TalentMenu, {
        id = id,
        text = data:GetName(),
        type = "checkbox",
        eventIDOverride = "epip_Cheats_AddTalent",
        netMsg = "EPIPENCOUNTERS_Cheats_AddTalent",
        checked = false,
        params = {ID = id},
    })
end
table.sort(TalentMenu, function (a, b)
    return a.text < b.text
end)

for id,data in pairs(Data.Game.FlexStats) do

    -- organize by subtype when one is defined
    local sortedType = data.SubType or data.Type

    if not FLEXSTAT_CHEATS[sortedType] then FLEXSTAT_CHEATS[sortedType] = {} end

    local text = id

    if sortedType == "Immunity" then
        text = text:gsub("IMMUNITY_", "")
    end

    local entry = {
        id = "epip_Cheats_Stats_FlexStats_Abilities_" .. id,
        type = "stat",
        selectable = false,
        text = text,
        eventIDOverride = "epip_Cheats_Stats_AddFlexStat",
        params = {
            type = data.Type,
            id = id,
        }
    }

    -- Sort by index, if defined
    if data.Index then
        FLEXSTAT_CHEATS[sortedType][data.Index] = entry
    else
        table.insert(FLEXSTAT_CHEATS[sortedType], entry)
    end
end

FLEXSTAT_CHEATS.Generic = {}
for i,id in pairs(Epip.Features.DebugCheats.VISIBLE_GENERIC_FLEXSTATS) do
    local data = Data.Game.FlexStats[id]

    local entry = {
        id = "epip_Cheats_Stats_FlexStats_Generic_" .. id,
        type = "stat",
        selectable = false,
        text = id,
        eventIDOverride = "epip_Cheats_Stats_AddFlexStat",
        params = {
            type = data.Type,
            id = id,
        }
    }

    table.insert(FLEXSTAT_CHEATS.Generic, entry)
end

-- Submenu handlers are not defined within main menus so you can reuse them throughout different context menus without needing obnoxious nested tables
ContextMenu.RegisterMenuHandler("epip_Cheats", function(char)
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats",
            entries = {
                {id = "epip_Cheats_CopyGUID", type = "button", text = "Copy GUID to clipboard"},
                {id = "epip_Cheats_Teleport", type = "button", text = "Teleport to Object"},
                {id = "epip_Cheats_KillResurrect", type = "button", text = "Kill/Resurrect", netMsg = "EPIP_CHEATS_KILLRESURRECT"},
                {id = "epip_Cheats_Heal", type = "button", text = "Restore Health + Armors", netMsg = "EPIP_CHEATS_HEAL"},
                {id = "epip_Cheats_InfiniteAP", type = "checkbox", text = "Pipmode", netMsg = "EPIP_CHEATS_INFINITEAP", checked = char:HasTag("PIP_DEBUGCHEATS_INFINITEAP")},
                {id = "epip_Cheats_GiveSP", type = "button", text = "Give AP/SP", netMsg = "EPIP_CHEATS_GIVESP"},
                {id = "epip_Cheats_ResetCDs", type = "button", text = "Reset Cooldowns", netMsg = "EPIP_CHEATS_RESETCDS"},

                -- Stat submenus
                {id = "epip_Cheats_Stats_FlexStatSubMenu_Generics", type = "subMenu", text = "Add FlexStat...", subMenu = "epip_Cheats_Stats_FlexStats_Generic"},
                {id = "epip_Cheats_Stats_FlexStatSubMenu_Attributes", type = "subMenu", text = "Add Attribute...", subMenu = "epip_Cheats_Stats_FlexStats_Attribute"},
                {id = "epip_Cheats_Stats_FlexStatSubMenu_Abilities", type = "subMenu", text = "Add Ability...", subMenu = "epip_Cheats_Stats_FlexStats_Abilities"},
                {id = "epip_Cheats_Stats_Talents", type = "subMenu", text = "Add Talents...", subMenu = "epip_Cheats_Stats_Talents"},
                -- {id = "epip_Cheats_Stats_FlexStatSubMenu_Immunities", type = "subMenu", text = "Add Immunity FlexStat...", subMenu = "epip_Cheats_Stats_FlexStats_Immunities"},

                {id = "epip_Cheats_SpecialLogic", type = "button", text = "Add SpecialLogic"},
                {id = "epip_Cheats_Stats_FlexStats_Spell", type = "button", text = "Add Spell"},
                {id = "epip_Cheats_AddStatus", type = "button", text = "Add Status"},
                {id = "epip_Cheats_AddTag", type = "button", text = "Add Tag"},
                {id = "epip_Cheats_RemoveTag", type = "button", text = "Remove Tag"},

                {id = "epip_Cheats_ItemsSubMenu", type = "subMenu", text = "Items...", subMenu = "epip_Cheats_Items"},
            }
        }
    })
end)

ContextMenu.RegisterVanillaMenuHandler("Character", function(char)
    if Epip.IsDeveloperMode() then
        ContextMenu.AddElements(nil, {
            id = "main",
            entries = {
                Debug.CheatsContextMenu
            }
        })
    end
end)

-- Generic FlexStats.
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_FlexStats_Generic", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_FlexStats_Generic",
            entries = FLEXSTAT_CHEATS.Generic,
        }
    })
end)

-- ATTRIBUTES
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_FlexStats_Attribute", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_FlexStats_Attribute",
            entries = FLEXSTAT_CHEATS.Attribute
        }
    })
end)

-- ABILITIES
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_FlexStats_Abilities", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_FlexStats_Abilities",
            entries = FLEXSTAT_CHEATS.Ability
        }
    })
end)

-- Talents submenu
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_Talents", function()
    local char = ContextMenu.GetCurrentCharacter()

    -- Refresh checked state
    for _,entry in ipairs(TalentMenu) do
        entry.checked = char.Stats["TALENT_" .. entry.params.ID]
    end

    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_Talents",
            entries = TalentMenu,
        }
    })
end)

-- IMMUNITIES
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_FlexStats_Immunities", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_FlexStats_Immunities",
            entries = FLEXSTAT_CHEATS.Immunity
        }
    })
end)

-- ITEM CHEATS
ContextMenu.RegisterMenuHandler("epip_Cheats_Items", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Items",
            entries = {
                {id = "epip_Cheats_Items_SpawnTemplate", type = "stat", text = "Add Template", min = 1, selectable = true, closeOnButtonPress = true},
                {id = "epip_Cheats_Items_SpawnTreasure", type = "stat", text = "Add Treasure", min = 1, selectable = true, closeOnButtonPress = true},
                {id = "epip_Cheats_Items_SpawnArtifacts", type = "button", text = "Add Artifacts", netMsg = "EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTS"},
                {id = "epip_Cheats_Items_SpawnArtifactsFoci", type = "button", text = "Add Artifacts Foci", netMsg = "EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTSFOCI"},
            }
        }
    })
end)

---------------------------------------------
-- Ground-targeted cheats.
---------------------------------------------

-- Ext.Events.InputEvent:Subscribe(function(event)
        -- event = event.Event

--     if event.EventId == 223 and event.Press and Ext.Debug.IsDeveloperMode() and Client.Input.IsShiftPressed() then
--         local x = Client.UI.Hotbar.Root.stage.mouseX
--         local y = Client.UI.Hotbar.Root.stage.mouseY
--         Ext.Print(x, y)

--         Timer.Start("PIP_GroundContextMenu", 0.001, function()
--             ContextMenu.RequestMenu(x, y, "epip_Cheats_Ground")
--         end)
--     end
-- end)

Client.UI.ContextMenu.RegisterMenuHandler("epip_Cheats_Ground", function()
    Ext.Print("here")
    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "playerInfo_Header", type = "button", text = "—— Player Status ——"},

                -- {id = "playerInfo_ToggleStatuses", type = "checkbox", text = "Show Statuses", checked = PlayerInfo.GetStatusesVisibility()},
                -- {id = "playerInfo_ToggleSummons", type = "checkbox", text = "Show Summons", checked = PlayerInfo.GetSummonsVisibility()},
            }
        }
    })

    Client.UI.ContextMenu.Open()
end)

---------------------------------------------
-- HOOKS
---------------------------------------------

-- Amount of cheated stats is tracked through tags
ContextMenu.RegisterStatDisplayHook("epip_Cheats_Stats_AddFlexStat", function(originalValue, character, elementParams)
    for i,tag in pairs(character:GetTags()) do
        local stat,amount = tag:match("PIP_CHEATEDSTATS_(.*)_(-?[0-9]*)$")
        if stat == elementParams.id and amount then
            return amount
        end
    end
end)

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Listen for "Warp to AMER_Test" button being pressed in settings menu.
SettingsMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.ButtonID == "DEBUG_WarpToAMERTest" then
        Net.PostToServer("EPIPENCOUNTERS_WARPPARTY", {
            Trigger = '99343515-4420-4660-9c39-a237634e92b7',
        })
    end
end)

ContextMenu.RegisterElementListener("epip_Cheats_Stats_AddFlexStat", "statButtonPressed", function(character, params, amount)
    Net.PostToServer("EPIP_CHEATS_FLEXSTAT", {
        NetID = character.NetID,
        StatType = params.type,
        Stat = params.id,
        Amount = amount,
    })
end)

-- Add tag.
ContextMenu.RegisterElementListener("epip_Cheats_AddTag", "buttonPressed", function(character, params)
    MessageBox.Open({
        ID = "epip_Cheats_AddTag",
        NetID = character.NetID,
        Header = "Add Tag",
        Message = "Enter a tag.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_AddTag", MessageBox.Events.InputSubmitted, function(text, id, data)
    Net.PostToServer("EPIP_CHEATS_ADDTAG", {NetID = data.NetID, Tag = text})
end)

-- Clear tag.
ContextMenu.RegisterElementListener("epip_Cheats_RemoveTag", "buttonPressed", function(character, params)
    MessageBox.Open({
        ID = "epip_Cheats_RemoveTag",
        NetID = character.NetID,
        Header = "Remove Tag",
        Message = "Enter a tag.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_RemoveTag", MessageBox.Events.InputSubmitted, function(text, id, data)
    Net.PostToServer("EPIP_CHEATS_REMOVETAG", {NetID = data.NetID, Tag = text})
end)

-- Flexstat spell.
ContextMenu.RegisterElementListener("epip_Cheats_Stats_FlexStats_Spell", "buttonPressed", function(character, params)
    MessageBox.Open({
        ID = "epip_Cheats_FlexStats_Spell",
        NetID = character.NetID,
        Header = "Add Spell",
        Message = "Enter a stats ID, prefixed with archetype.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_FlexStats_Spell", MessageBox.Events.InputSubmitted, function(text, _, data)
    Net.PostToServer("EPIP_CHEATS_SPELL", {NetID = data.NetID, StatsID = text})
end)

-- Add status.
ContextMenu.RegisterElementListener("epip_Cheats_AddStatus", "buttonPressed", function(character, _)
    MessageBox.Open({
        ID = "epip_Cheats_AddStatus",
        NetID = character.NetID,
        Header = "Add Status",
        Message = "Enter the StatusID. Put a space and number afterwards to define duration (default 1 turn).",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_AddStatus", MessageBox.Events.InputSubmitted, function(text, id, data)
    local status, duration = table.unpack(Text.Split(text, " "))
    if duration then duration = duration * 6 else duration = 6 end

    Net.PostToServer("EPIP_CHEATS_ADDSTATUS", {
        NetID = data.NetID, StatusID = status, Duration = duration,
    })
end)

-- Teleport to object.
ContextMenu.RegisterElementListener("epip_Cheats_Teleport", "buttonPressed", function(character, params)
    MessageBox.Open({
        ID = "epip_Cheats_Teleport",
        NetID = character.NetID,
        Header = "Teleport to",
        Message = "Enter a GUID.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

-- Log RootTemplate GUID.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == "EpipEncounters_Debug_LogRootTemplate" then
        local entity = Ext.UI.GetPickingState(1).HoverItem
        if entity then
            entity = Item.Get(entity)
        else
            entity = Ext.UI.GetPickingState(1).HoverEntity

            if entity then
                entity = Character.Get(entity)
            end
        end

        if entity then
            -- local guid = entity.RootTemplate.Name .. "_" .. entity.RootTemplate.Id
            local guid = entity.RootTemplate.RootTemplate
            if guid == "" then guid = entity.RootTemplate.Id end

            print(guid)

            Client.CopyToClipboard(guid)
        end
    end
end)

-- For testing talent tooltips.
-- Client.UI.CharacterSheet:RegisterInvokeListener("updateArraySystem", function(ev)
--     local root = ev.UI:GetRoot()
--     local arr = root.talent_array

--     for i=1,128,1 do
--         local index = (i - 1) * 3
--         arr[index] = tostring(i)
--         arr[index + 1] = i
--         arr[index + 2] = false
--     end
-- end)

MessageBox.RegisterMessageListener("epip_Cheats_Teleport", MessageBox.Events.InputSubmitted, function(text, id, data)
    Net.PostToServer("EPIP_CHEATS_TELEPORTTO", {NetID = data.NetID, TargetGUID = text})
end)

-- Grant treasure table.
local templateAmount = 1
ContextMenu.RegisterElementListener("epip_Cheats_Items_SpawnTreasure", "buttonPressed", function(character, params)
    templateAmount = params._statAmount

    MessageBox.Open({
        ID = "epip_Cheats_Items_SpawnTreasure",
        NetID = character.NetID,
        Header = string.format("Grant Treasure (%sx)", Text.RemoveTrailingZeros(templateAmount)),
        Message = "Enter a Treasure Table.<br>Might cause a lot of lag if gear generation is involved.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Accept"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_Items_SpawnTreasure", MessageBox.Events.InputSubmitted, function(text, _, data)
    Net.PostToServer("EPIP_CHEATS_GRANTTREASURE", {NetID = data.NetID, Treasure = text, Amount = templateAmount})
end)

-- Print Char GUID.
ContextMenu.RegisterElementListener("epip_Cheats_CopyGUID", "buttonPressed", function(character, _)
    local prefixedGUID = character.RootTemplate.Name .. "_" .. character.MyGuid

    Client.CopyToClipboard(prefixedGUID)
end)

-- Add SpecialLogic.
ContextMenu.RegisterElementListener("epip_Cheats_SpecialLogic", "buttonPressed", function(character, params)
    MessageBox.Open({
        ID = "epip_Cheats_SpecialLogic",
        NetID = character.NetID,
        Header = "Add SpecialLogic",
        Message = "Enter the SpecialLogic ID.",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Add"},
            {Type = 2, Text = "Remove"},
        }
    })
end)

MessageBox.RegisterMessageListener("epip_Cheats_SpecialLogic", MessageBox.Events.InputSubmitted, function(text, buttonId, data)
    local amount = 1.0

    if buttonId == 1 then -- TODO check if works
        amount = -1.0
    end

    Net.PostToServer("EPIP_CHEATS_SPECIALLOGIC", {NetID = data.NetID, SpecialLogic = text, Amount = amount})
end)

-- Teleport to cursor.
-- Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
--     if action == "EpipEncounters_DebugTeleport" or action == "EpipEncounters_DebugTeleport_Party" then
--         local pos = Pointer.GetWalkablePosition()
        
--         if pos then
--             Net.PostToServer("EPIPENCOUNTERS_CHEATS_TeleportChar", {
--                 CharacterNetID = Client.GetCharacter().NetID,
--                 Position = pos,
--                 TeleportParty = action == "EpipEncounters_DebugTeleport_Party",
--             })
--         end
--     end
-- end)