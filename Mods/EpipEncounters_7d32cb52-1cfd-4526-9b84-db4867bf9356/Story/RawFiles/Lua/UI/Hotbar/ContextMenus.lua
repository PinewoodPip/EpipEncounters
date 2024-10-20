
---------------------------------------------
-- Context menus for the Hotbar.
---------------------------------------------

---@class HotbarUI
local Hotbar = Client.UI.Hotbar

-- Open context menu upon right-clicking a slot.
Client.UI.ContextMenu.RegisterMenuHandler("hotbarSlot", function()
    local isRowEmpty = Hotbar.IsRowEmpty(Hotbar.currentLoadoutRow)

    local entries = {
        {id = "hotBarRow_LoadoutsMenu", type = "subMenu", subMenu = "hotBarLoadoutsMenu", text = "Saved Loadouts..."},

        -- TODO hook
        {id = "hotBarRow_CreateGroup", type = "button", text = "Create group..."},

        {id = "hotBarRow_ShiftLeft", type = "button", text = "Shift slots to the left", closeOnButtonPress = false, params = {Direction = "left"}, eventIDOverride = "hotBar_ShiftRow"},
        {id = "hotBarRow_ShiftRight", type = "button", text = "Shift slots to the right", closeOnButtonPress = false, params = {Direction = "right"}, eventIDOverride = "hotBar_ShiftRow"},
        {id = "hotBarRow_RemoveUnmemorized", type = "button", text = "Remove unmemorized spells", requireShiftClick = true},
        {id = "hotBarRow_ClearRow", type = "button", text = "Clear row", requireShiftClick = true, selectable = not isRowEmpty, faded = isRowEmpty},
    }

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = entries,
        }
    })

    Client.UI.ContextMenu.Open(true)
end)

---------------------------------------------
-- CONTEXT MENU ACTIONS
---------------------------------------------

-- Shift slots.
Client.UI.ContextMenu.RegisterElementListener("hotBar_ShiftRow", "buttonPressed", function(_, params)
    Hotbar.ShiftSlots(Hotbar.contextMenuSlot, params.Direction)
end)

-- Remove unmemorized skills.
Client.UI.ContextMenu.RegisterElementListener("hotBarRow_RemoveUnmemorized", "buttonPressed", function(char, _)
    Hotbar.ClearRow(char, Hotbar.currentLoadoutRow, function(predicateChar, slot)
        if slot.Type == "Skill" then
            ---@type EclSkill
            local skill = predicateChar.SkillManager.Skills[slot.SkillOrStatId]
            return skill == nil or not skill.IsLearned
        end
    end)
    Hotbar.currentLoadoutRow = nil
end)

-- Clear row.
Client.UI.ContextMenu.RegisterElementListener("hotBarRow_ClearRow", "buttonPressed", function(char, _)
    Hotbar.ClearRow(char, Hotbar.currentLoadoutRow)
    Hotbar.currentLoadoutRow = nil
end)

---------------------------------------------
-- LOADOUTS
---------------------------------------------

-- Render sub-menu.
Client.UI.ContextMenu.RegisterMenuHandler("hotBarLoadoutsMenu", function()
    local entries = {
        {id = "hotBarRow_Header", type = "header", text = "—— Saved Loadouts ——"},
        {id = "hotBarRow_SaveLoadout", type = "button", text = "Save Loadout"},
    }
    local loadoutEntries = {}

    local loadouts = {}
    for id,loadout in pairs(Hotbar.Loadouts) do
        loadout.Name = id
        table.insert(loadouts, loadout)
    end
    table.sort(loadouts, function(a ,b) return a.Name < b.Name end)

    for _,data in pairs(loadouts) do
        -- Insert footer/divider only if we had at least one loadout saved
        if #loadoutEntries == 0 then
            table.insert(entries, #entries, {id = "hotBarRow_Footer", type = "header", text = "———————————"})
        end

        table.insert(loadoutEntries, {
            id = "hotBarRow_LoadLoadout_" .. data.Name, type = "removable", text = data.Name, eventIDOverride = "hotBarLoadLoadout", params = {ID = data.Name},
        })
    end

    -- Insert loadout entries before the divider
    for _,entry in ipairs(loadoutEntries) do
        table.insert(entries, #entries - 1, entry)
    end

    Client.UI.ContextMenu.AddSubMenu({
        menu = {
            id = "hotBarLoadoutsMenu",
            entries = entries,
        }
    })
end)

-- Remove a loadout.
Client.UI.ContextMenu.RegisterElementListener("hotBarLoadLoadout", "removablePressed", function(_, params)
    Hotbar.Loadouts[params.ID] = nil
    Hotbar.currentLoadoutRow = nil
end)

-- Apply loadout.
Client.UI.ContextMenu.RegisterElementListener("hotBarLoadLoadout", "buttonPressed", function(char, params)
    -- Apply loadout instantly if the row is empty,
    -- prompt for confirmation otherwise.
    if Hotbar.IsRowEmpty(Hotbar.currentLoadoutRow) then
        Hotbar.ApplyLoadout(char, params.ID, Hotbar.currentLoadoutRow)
    else
        Client.UI.MessageBox.Open({
            ID = "epip_Hotbar_LoadLoadout",
            Header = "Apply Loadout",
            Message = "Are you sure? This will replace all of this row's spells/items!",
            Type = "Message",
            LoadoutID = params.ID,
            Buttons = {
                {Type = 1, Text = "Apply", ID = 1},
                {Type = 1, Text = "Cancel", ID = 2},
            }
        })
    end
end)

Client.UI.MessageBox.RegisterMessageListener("epip_Hotbar_LoadLoadout", Client.UI.MessageBox.Events.ButtonPressed, function(buttonId, data)
    if buttonId == 1 then
        Hotbar.ApplyLoadout(Client.GetCharacter(), data.LoadoutID,Hotbar.currentLoadoutRow, true)
    end
    Hotbar.currentLoadoutRow = nil
end)

-- Save loadout.
Client.UI.ContextMenu.RegisterElementListener("hotBarRow_SaveLoadout", "buttonPressed", function()
    Client.UI.MessageBox.Open({
        ID = "epip_Hotbar_SaveLoadout",
        Header = "Save Loadout",
        Message = "Name this row loadout!",
        Type = "Input",
        Buttons = {
            {Type = 1, Text = "Save"},
            -- {Type = 1, Text = "Save all rows"}
        }
    })
end)

Client.UI.MessageBox.RegisterMessageListener("epip_Hotbar_SaveLoadout", Client.UI.MessageBox.Events.InputSubmitted, function(text, _, _)
    -- local saveAllRows = buttonId == 2

    Hotbar.SaveLoadout(Hotbar.currentLoadoutRow, text)
end)