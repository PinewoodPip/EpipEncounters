---------------------------------------------
-- VANILLA ACTIONS
---------------------------------------------

local Hotbar = Client.UI.Hotbar

---@type table<string, HotbarAction>
local vanillaActions = {
    {
        ID = "Pause",
        Name = "Pause",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_pause",
        InputEventID = 225,
        VanillaButtonIndex = 0,
    },
    {
        ID = "Inventory",
        Name = "Inventory",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_inventory",
        InputEventID = 246,
        VanillaButtonIndex = 1,
    },
    {
        ID = "Skills",
        Name = "Skills",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_skills",
        InputEventID = 251,
        VanillaButtonIndex = 2,
    },
    {
        ID = "Crafting",
        Name = "Crafting",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_crafting",
        InputEventID = 247,
        VanillaButtonIndex = 3,
    },
    {
        ID = "Map",
        Name = "Map",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_map",
        InputEventID = 250,
        VanillaButtonIndex = 4,
    },
    {
        ID = "QuestLog",
        Name = "Quest Log",
        Type = "VanillaHotbarButton",
        Icon = "hotbar_icon_journal",
        InputEventID = 249, 
        VanillaButtonIndex = 5,
    },
    {
        ID = "CombatLog",
        Name = "Combat Log",
        Icon = "hotbar_icon_combatlog",
    },
    {
        ID = "Waypoints",
        Name = "Waypoints",
        Icon = "hotbar_icon_waypoints",
    },
    {
        ID = "Ping",
        Name = "Ping",
        Icon = "hotbar_icon_ping",
    },
    {
        ID = "Chat",
        Name = "Chat",
        Icon = "hotbar_icon_chat",
    },
}

for i,action in pairs(vanillaActions) do
    Hotbar.RegisterAction(action.ID, action)
end

-- Buttons from the vanilla hotbar.
local enabledHotbarButtons = {

}

-- Track highlighting of the vanilla buttons
Ext.Events.SessionLoaded:Subscribe(function()
    local ui = Hotbar:GetUI()

    Ext.RegisterUIInvokeListener(ui, "setButtonActive", function(ui, method, btn, state)
        enabledHotbarButtons[btn] = state
    end)
end)

Hotbar:RegisterListener("ActionUsed", function(id, char, data)
    if data.Type == "VanillaHotbarButton" then
        local ui = Hotbar:GetUI()
        ui:ExternalInterfaceCall("hotbarBtnPressed", data.VanillaButtonIndex)
    end
end)

Hotbar:RegisterHook("IsActionHighlighted", function(highlighted, id, char, data)
    if data.Type == "VanillaHotbarButton" then
        return enabledHotbarButtons[data.VanillaButtonIndex]
    end
end)

-- Ping
Hotbar.RegisterActionListener("Ping", "ActionUsed", function(char, data)
    Ext.UI.GetByType(Client.UI.Data.UITypes.minimap):ExternalInterfaceCall("pingButtonPressed")
end)

-- Waypoints
Hotbar.RegisterActionListener("Waypoints", "ActionUsed", function(char, data)
    Ext.UI.GetByType(Client.UI.Data.UITypes.minimap):ExternalInterfaceCall("HomeButtonPressed")
end)
Hotbar.RegisterActionHook("Waypoints", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByPath("Public/Game/GUI/waypoints.swf") ~= nil
end)

-- Combat Log
Hotbar.RegisterActionListener("CombatLog", "ActionUsed", function(char, data)
    Hotbar:GetUI():ExternalInterfaceCall("CombatLogBtnPressed")
end)
Hotbar.RegisterActionHook("CombatLog", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByType(Client.UI.Data.UITypes.combatLog):GetRoot().log_mc.visible
end)

-- Chat
Hotbar.RegisterActionListener("Chat", "ActionUsed", function(char, data)
    Hotbar:GetUI():ExternalInterfaceCall("ToggleChatLog")
end)
Hotbar.RegisterActionHook("Chat", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByType(Client.UI.Data.UITypes.chatLog):GetRoot().log_mc.visible
end)

Hotbar.SetHotkeyAction(1, "Pause")
Hotbar.SetHotkeyAction(2, "Inventory")
Hotbar.SetHotkeyAction(3, "Skills")
Hotbar.SetHotkeyAction(4, "Crafting")
Hotbar.SetHotkeyAction(5, "Map")
Hotbar.SetHotkeyAction(6, "QuestLog")

Hotbar.SetHotkeyAction(7, "CombatLog")
Hotbar.SetHotkeyAction(8, "Waypoints")
Hotbar.SetHotkeyAction(9, "Ping")
Hotbar.SetHotkeyAction(10, "Chat")
-- Hotbar.SetHotkeyAction(11, "Actions") -- TODO replace with actions
-- Hotbar.SetHotkeyAction(12, "Options")

---------------------------------------------
-- EXTRA ACTIONS
---------------------------------------------

-- Teleporter pyramids - a bit sloppy of an implementation atm.
local pyramids = {
    ["fd45268f-5953-47c4-ba2f-255a05e2ce0e"] = true,
    ["34810bdd-1185-468b-a5af-3298d0a861cf"] = true,
    ["74f7068e-d388-4ffe-9e68-89406a6049d1"] = true,
    ["e90a55e7-973e-4c77-b4b3-65f87808791c"] = true,
}

Hotbar.RegisterAction("TeleporterPyramid", {
    Name = "Pyramids",
    Icon = "hotbar_icon_bag",
})

Hotbar.RegisterActionListener("TeleporterPyramid", "ActionUsed", function(char, data)
    Game.Net.PostToServer("EPIP_UseTeleporterPyramid", {NetID = char.NetID})
end)

-- Action is disabled if party has fewer than 2 pyramids.
Hotbar.RegisterActionHook("TeleporterPyramid", "IsActionEnabled", function(char, data)
    local pyramidCount = 0
    local players = Client.UI.PlayerInfo:GetRoot().player_array

    for i=0,#players-1,1 do
        local player = Ext.GetCharacter(Ext.UI.DoubleToHandle(players[i].characterHandle))

        for i,item in ipairs(player:GetInventoryItems()) do
            item = Ext.GetItem(item)

            if pyramids[item.MyGuid] and not item:IsTagged("PYRAMID_DISABLED") then
                pyramidCount = pyramidCount + 1

                if pyramidCount > 1 then
                    break
                end
            end
        end

        if pyramidCount > 1 then
            break
        end
    end

    return pyramidCount > 1
end)

---------------------------------------------
-- BINDING SKILLS
---------------------------------------------
local boundSkills = {

}
local boundItems = {

}

-- Save these along with the rest of the hotbar data
Hotbar:RegisterHook("GetHotbarSaveData", function(data)
    data.BoundArbitrarySkills = boundSkills
    data.BoundArbitraryTemplates = boundItems
    return data
end)

-- Load them from hotbar savedata
Hotbar:RegisterListener("SaveDataLoaded", function(data)
    if data.BoundArbitrarySkills then
        for key,val in pairs(data.BoundArbitrarySkills) do
            boundSkills[tonumber(key)] = val
        end
    end

    if data.BoundArbitraryTemplates then
        for key,val in pairs(data.BoundArbitraryTemplates) do
            boundItems[tonumber(key)] = val
        end
    end
end)

-- The "use arbitrary skill/item" action is never visible in the drawer as it has to be bound in a special manner.
Hotbar.RegisterAction("UseArbitrarySkill", {
    Name = "Invalid Skill (mods missing?)",
    Icon = "hotbar_school_special",
    VisibleInDrawer = false,
})
Hotbar.RegisterAction("UseArbitraryTemplate", {
    Name = "Invalid Item (mods missing?)",
    Icon = "hotbar_school_special",
    VisibleInDrawer = false,
})

local schoolIcons = {
    None = "hotbar_school_special",
    Fire = "hotbar_school_pyrokinetic",
    Water = "hotbar_school_hydrosophist",
    Death = "hotbar_school_necromancy",
    Polymorph = "hotbar_school_polymorph",
    Summoning = "hotbar_school_summoning",
    Air = "hotbar_school_aerotheurge",
    Ranger = "hotbar_school_huntsman",
    Rogue = "hotbar_school_scoundrel",
    Warrior = "hotbar_school_warfare",
    Earth = "hotbar_school_geomancer",
    Source = "hotbar_school_sourcery",
}

Hotbar.RegisterActionHook("UseArbitraryTemplate", "GetActionName", function(name, char, actionData, buttonIndex)
    if buttonIndex then
        local template = boundItems[buttonIndex]

        if template then
            template = Ext.Template.GetTemplate(template)

            if template then
                name = Ext.L10N.GetTranslatedStringFromKey(template.Name)
            end
        end
    end

    return name
end)

Hotbar.RegisterActionHook("UseArbitrarySkill", "GetActionName", function(name, char, actionData, buttonIndex)
    if buttonIndex then
        local skill = boundSkills[buttonIndex]

        if skill then
            skill = Ext.Stats.Get(skill)

            name = Ext.L10N.GetTranslatedStringFromKey(skill.DisplayName)
        end
    end

    return name
end)

Hotbar:RegisterListener("ActionsSwapped", function(action1, action2)
    local skill1 = nil
    local skill2 = nil

    if action1.Action == "UseArbitrarySkill" then
        skill1 = boundSkills[action1.Index]
    end
    if action2.Action == "UseArbitrarySkill" then
        skill2 = boundSkills[action2.Index]
    end

    boundSkills[action1.Index] = skill2
    boundSkills[action2.Index] = skill1
end)

Hotbar:RegisterListener("ActionsSwapped", function(action1, action2)
    local item1 = nil
    local item2 = nil

    if action1.Action == "UseArbitraryTemplate" then
        item1 = boundSkills[action1.Index]
    end
    if action2.Action == "UseArbitraryTemplate" then
        item2 = boundSkills[action2.Index]
    end

    boundItems[action1.Index] = item2
    boundItems[action2.Index] = item1
end)

Hotbar.RegisterActionHook("UseArbitrarySkill", "IsActionEnabled", function(enabled, char, data, buttonIndex)
    enabled = false

    if buttonIndex then
        local skill = boundSkills[buttonIndex]

        if skill then
            local skillData = char.SkillManager.Skills[skill]

            if skillData then
                return (skillData.IsActivated or skillData.IsLearned) and skillData.ActiveCooldown <= 0 and (skillData.MaxCharges == 0 or skillData.NumCharges > 0)
            else
                return false
            end
        end
    end

    return enabled
end)

-- TODO highlight
Hotbar.RegisterActionHook("UseArbitrarySkill", "GetActionIcon", function(icon, char, data, buttonIndex)
    if buttonIndex then
        local skill = boundSkills[buttonIndex]

        if skill then
            local ability = Ext.Stats.Get(skill).Ability
            icon = "hotbar_school_special"

            if schoolIcons[ability] then
                icon = schoolIcons[ability]
            else
                print("missing ability icon " .. ability)
            end
        end
    end
    
    return icon
end)

Hotbar:RegisterListener("SlotDraggedToHotkeyButton", function(index, data)
    if data.Type == "Skill" then
        boundSkills[index] = data.SkillOrStatId
        Hotbar.SetHotkeyAction(index, "UseArbitrarySkill")
    elseif data.Type == "Item" then
        boundItems[index] = Ext.GetItem(data.ItemHandle).RootTemplate.Id
        Hotbar.SetHotkeyAction(index, "UseArbitraryTemplate")
    else
        Client.UI.MessageBox.Open({
            ID = "Hotbar_ArbitraryButtonError",
            Header = "Error",
            Message = "Only skills and items can be dragged to these buttons at the moment.",
            Buttons = {
                {Type = 1, Text = "Accept"},
            }
        })
    end
end)

Hotbar.RegisterActionListener("UseArbitrarySkill", "ActionUsed", function(char, data, buttonIndex)
    if not buttonIndex then return nil end

    local skill = boundSkills[buttonIndex]

    if skill then
        local skillBar = char.PlayerData.SkillBarItems
        local slot = skillBar[145]
        local previousSkill

        if slot.Type == "Skill" then
            previousSkill = slot.SkillOrStatId
        end

        skillBar[145].SkillOrStatId = skill
        skillBar[145].Type = "Skill"

        UpdateSlotTextures()

        Client.Timer.Start("UseHotbarSlot", 0.05, function()
            Hotbar.UseSlot(145)

            -- Rebind the auxiliary slot back to its original skill
            if previousSkill then
                char.PlayerData.SkillBarItems[145].SkillOrStatId = previousSkill
                UpdateSlotTextures()
            end
        end)
    end
end)

Hotbar.RegisterActionListener("UseArbitraryTemplate", "ActionUsed", function(char, data, buttonIndex)
    if buttonIndex then
        local template = boundItems[buttonIndex]

        if template then
            Game.Net.PostToServer("EPIPENCOUNTERS_Hotbar_UseTemplate", {
                NetID = char.NetID,
                Template = template
            })
        end
    end
end)