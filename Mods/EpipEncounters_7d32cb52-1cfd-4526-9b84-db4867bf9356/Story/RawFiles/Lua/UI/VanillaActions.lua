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
        InputEventID = 241,
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
        ID = "ShowActions",
        Name = "Show Actions",
        Icon = "hotbar_icon_clover",
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
Hotbar.SetHotkeyAction(11, "ShowActions")

-- Buttons from the vanilla hotbar.
local highlightedHotbarButtons = {}
local disabledHotbarButtons = {} ---@type set<integer>

-- Track enabled and highlighted state of the vanilla buttons
Hotbar:RegisterInvokeListener("setButtonActive", function (_, btn, state)
    highlightedHotbarButtons[btn] = state
end)
Hotbar:RegisterInvokeListener("setButtonDisabled", function (_, id, disabled)
    disabledHotbarButtons[id] = disabled or nil
end)

Hotbar:RegisterListener("ActionUsed", function(id, char, data)
    if data.ID == "ShowActions" then
        Hotbar:GetRoot().toggleActionSkillHolder()
    end
end)

Hotbar:RegisterListener("ActionUsed", function(id, char, data)
    if data.Type == "VanillaHotbarButton" then
        local ui = Hotbar:GetUI()
        ui:ExternalInterfaceCall("hotbarBtnPressed", data.VanillaButtonIndex)
    end
end)

Hotbar:RegisterHook("IsActionHighlighted", function(highlighted, id, char, data)
    if data.Type == "VanillaHotbarButton" then
        return highlightedHotbarButtons[data.VanillaButtonIndex]
    end
end)
Hotbar:RegisterHook("IsActionEnabled", function(_, _, _, data)
    if data.Type == "VanillaHotbarButton" then
        return disabledHotbarButtons[data.VanillaButtonIndex] == nil
    end
end)

-- Ping
Hotbar.RegisterActionListener("Ping", "ActionUsed", function(char, data)
    Ext.UI.GetByType(Ext.UI.TypeID.minimap):ExternalInterfaceCall("pingButtonPressed")
end)

-- Waypoints
Hotbar.RegisterActionListener("Waypoints", "ActionUsed", function(char, data)
    Ext.UI.GetByType(Ext.UI.TypeID.minimap):ExternalInterfaceCall("HomeButtonPressed")
end)
Hotbar.RegisterActionHook("Waypoints", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByPath("Public/Game/GUI/waypoints.swf") ~= nil
end)

-- Combat Log
Hotbar.RegisterActionListener("CombatLog", "ActionUsed", function(char, data)
    Hotbar:GetUI():ExternalInterfaceCall("CombatLogBtnPressed")
end)
Hotbar.RegisterActionHook("CombatLog", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByType(Ext.UI.TypeID.combatLog):GetRoot().log_mc.visible
end)

-- Chat
Hotbar.RegisterActionListener("Chat", "ActionUsed", function(char, data)
    Hotbar:GetUI():ExternalInterfaceCall("ToggleChatLog")
end)
Hotbar.RegisterActionHook("Chat", "IsActionHighlighted", function(highlighted, char, data)
    return Ext.UI.GetByType(Ext.UI.TypeID.chatLog):GetRoot().log_mc.visible
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
            skill = Ext.Stats.Get(skill, nil, false)

            if skill then
                name = Ext.L10N.GetTranslatedStringFromKey(skill.DisplayName)
            end
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
            return Character.CanUseSkill(Client.GetCharacter(), skill)
        end
    end

    return enabled
end)

-- TODO highlight
Hotbar.RegisterActionHook("UseArbitrarySkill", "GetActionIcon", function(icon, char, data, buttonIndex)
    if buttonIndex then
        local skill = boundSkills[buttonIndex]

        if skill then
            local stat = Ext.Stats.Get(skill, nil, false)

            if stat then
                local ability = stat.Ability
                icon = "hotbar_school_special"

                if schoolIcons[ability] then
                    icon = schoolIcons[ability]
                else
                    print("missing ability icon " .. ability)
                end
            end
        end
    end
    
    return icon
end)

Hotbar.Events.ContentDraggedToHotkey:Subscribe(function (ev)
    local draggedSkill = Pointer.GetDraggedSkill()
    local draggedItem = Pointer.GetDraggedItem()
    local index = ev.Index

    -- Cannot drag actions to the hotkeys.
    if draggedSkill and not Stats.GetAction(draggedSkill) then
        boundSkills[index] = draggedSkill
        Hotbar.SetHotkeyAction(index, "UseArbitrarySkill")
    elseif draggedItem then
        boundItems[index] = draggedItem.RootTemplate.Id
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
        Hotbar.UseSkill(skill)
    end
end)

Hotbar.RegisterActionListener("UseArbitraryTemplate", "ActionUsed", function(char, _, buttonIndex)
    if buttonIndex then
        local template = boundItems[buttonIndex]

        if template then
            Net.PostToServer("EPIPENCOUNTERS_Hotbar_UseTemplate", {
                CharacterNetID = char.NetID,
                Template = template
            })
        end
    end
end)