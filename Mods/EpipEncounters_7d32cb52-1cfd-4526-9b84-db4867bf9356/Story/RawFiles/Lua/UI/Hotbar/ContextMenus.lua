
---------------------------------------------
-- Context menus for the Hotbar.
---------------------------------------------

local ContextMenu = Client.UI.ContextMenu
local MsgBox = Client.UI.MessageBox
local Hotbar = Client.UI.Hotbar
local CommonStrings = Text.CommonStrings

---@class Features.HotbarContextMenus : Feature
local HotbarContextMenus = {
    TranslatedStrings = {
        SavedLoadoutsSubMenu = {
            Handle = "h44e4ad2fg13e9g4f1aga10cg5fac200f82fd",
            Text = "Saved Loadouts...",
            ContextDescription = "Hotbar slot context menu entry opening the loadouts submenu",
        },
        CreateGroup = {
            Handle = "he7bcafb3gaa7dg4b0bga0d9g63dcdcc2aec5",
            Text = "Create group...",
            ContextDescription = "Hotbar slot context menu entry",
        },
        ShiftSlotsLeft = {
            Handle = "h528bebc9g5ab4g4e02g9e66ga97cefd7b8d7",
            Text = "Shift slots to the left",
            ContextDescription = "Hotbar slot context menu entry",
        },
        ShiftSlotsRight = {
            Handle = "he30cbf0fg3c2eg433cg9750g3ced1cd9da80",
            Text = "Shift slots to the right",
            ContextDescription = "Hotbar slot context menu entry",
        },
        RemoveUnmemorized = {
            Handle = "h8b1f7c4bg61e9g49bagb791gf907d40f11d9",
            Text = "Remove unmemorized spells",
            ContextDescription = "Hotbar slot context menu entry",
        },
        ClearRow = {
            Handle = "h13f894c2g6856g4630gab09g52860a7bcc53",
            Text = "Clear row",
            ContextDescription = "Hotbar slot context menu entry",
        },
        LoadoutsHeader = {
            Handle = "hd5ec1b49g8624g4a2eg8927gb7a5f911348d",
            Text = "—— Saved Loadouts ——",
            ContextDescription = "Header of the saved loadouts submenu",
        },
        SaveLoadout = {
            Handle = "h600fe11bg406fg4714g83d3gad0d30616017",
            Text = "Save Loadout",
            ContextDescription = "Submenu button and message box header",
        },
        ApplyLoadoutHeader = {
            Handle = "hb6429fe0gcd7bg4453gb7b4g5fae218ca177",
            Text = "Apply Loadout",
            ContextDescription = "Message box header",
        },
        ApplyLoadoutMessage = {
            Handle = "h8f894aefgaf17g492eg8294gb16bbd0ac3cc",
            Text = "Are you sure? This will replace all of this row's skills/items!",
            ContextDescription = "Message box body when applying a loadout to a non-empty row",
        },
        SaveLoadoutMessage = {
            Handle = "h81739a49g92bfg4507ga6dagfe219c747e1c",
            Text = "Name this row loadout:",
            ContextDescription = "Message box body when saving a loadout",
        },
    }
}
Epip.RegisterFeature("Features.HotbarContextMenus", HotbarContextMenus)
local TSK = HotbarContextMenus.TranslatedStrings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open context menu upon right-clicking a slot.
ContextMenu.RegisterMenuHandler("hotbarSlot", function()
    local isRowEmpty = Hotbar.IsRowEmpty(Hotbar.currentLoadoutRow)

    local entries = {
        {id = "hotBarRow_LoadoutsMenu", type = "subMenu", subMenu = "hotBarLoadoutsMenu", text = TSK.SavedLoadoutsSubMenu:GetString()},

        {id = "hotBarRow_CreateGroup", type = "button", text = TSK.CreateGroup:GetString()},

        {id = "hotBarRow_ShiftLeft", type = "button", text = TSK.ShiftSlotsLeft:GetString(), closeOnButtonPress = false, params = {Direction = "left"}, eventIDOverride = "hotBar_ShiftRow"},
        {id = "hotBarRow_ShiftRight", type = "button", text = TSK.ShiftSlotsRight:GetString(), closeOnButtonPress = false, params = {Direction = "right"}, eventIDOverride = "hotBar_ShiftRow"},
        {id = "hotBarRow_RemoveUnmemorized", type = "button", text = TSK.RemoveUnmemorized:GetString(), requireShiftClick = true},
        {id = "hotBarRow_ClearRow", type = "button", text = TSK.ClearRow:GetString(), requireShiftClick = true, selectable = not isRowEmpty, faded = isRowEmpty},
    }

    ContextMenu.Setup({
        menu = {
            id = "main",
            entries = entries,
        }
    })

    ContextMenu.Open()
end)

---------------------------------------------
-- CONTEXT MENU ACTIONS
---------------------------------------------

-- Shift slots.
ContextMenu.RegisterElementListener("hotBar_ShiftRow", "buttonPressed", function(_, params)
    Hotbar.ShiftSlots(Hotbar.contextMenuSlot, params.Direction)
end)

-- Remove unmemorized skills.
ContextMenu.RegisterElementListener("hotBarRow_RemoveUnmemorized", "buttonPressed", function(char, _)
    Hotbar.ClearRow(char, Hotbar.currentLoadoutRow, function(predicateChar, slot)
        if slot.Type == "Skill" then
            ---@type EclSkill
            local skill = predicateChar.SkillManager.Skills[slot.SkillOrStatId]
            return skill == nil or not skill.IsLearned
        end
        return false
    end)
    Hotbar.currentLoadoutRow = nil
end)

-- Clear row.
ContextMenu.RegisterElementListener("hotBarRow_ClearRow", "buttonPressed", function(char, _)
    Hotbar.ClearRow(char, Hotbar.currentLoadoutRow)
    Hotbar.currentLoadoutRow = nil
end)

---------------------------------------------
-- LOADOUTS
---------------------------------------------

-- Render sub-menu.
ContextMenu.RegisterMenuHandler("hotBarLoadoutsMenu", function()
    local entries = {
        {id = "hotBarRow_Header", type = "header", text = TSK.LoadoutsHeader:GetString()},
        {id = "hotBarRow_SaveLoadout", type = "button", text = TSK.SaveLoadout:GetString()},
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

    ContextMenu.AddSubMenu({
        menu = {
            id = "hotBarLoadoutsMenu",
            entries = entries,
        }
    })
end)

-- Remove a loadout.
ContextMenu.RegisterElementListener("hotBarLoadLoadout", "removablePressed", function(_, params)
    Hotbar.Loadouts[params.ID] = nil
    Hotbar.currentLoadoutRow = nil
end)

-- Apply loadout.
ContextMenu.RegisterElementListener("hotBarLoadLoadout", "buttonPressed", function(char, params)
    -- Apply loadout instantly if the row is empty,
    -- prompt for confirmation otherwise.
    if Hotbar.IsRowEmpty(Hotbar.currentLoadoutRow) then
        Hotbar.ApplyLoadout(char, params.ID, Hotbar.currentLoadoutRow)
    else
        MsgBox.Open({
            ID = "epip_Hotbar_LoadLoadout",
            Header = TSK.ApplyLoadoutHeader:GetString(),
            Message = TSK.ApplyLoadoutMessage:GetString(),
            Type = "Message",
            LoadoutID = params.ID,
            Buttons = {
                {ID = 1, Type = "Yes", Text = CommonStrings.Apply:GetString()},
                {ID = 2, Type = "No", Text = CommonStrings.Cancel:GetString()},
            }
        })
    end
end)
MsgBox.RegisterMessageListener("epip_Hotbar_LoadLoadout", MsgBox.Events.ButtonPressed, function(buttonId, data)
    if buttonId == 1 then
        Hotbar.ApplyLoadout(Client.GetCharacter(), data.LoadoutID,Hotbar.currentLoadoutRow, true)
    end
    Hotbar.currentLoadoutRow = nil
end)

-- Save loadout.
ContextMenu.RegisterElementListener("hotBarRow_SaveLoadout", "buttonPressed", function()
    MsgBox.Open({
        ID = "epip_Hotbar_SaveLoadout",
        Header = TSK.SaveLoadout:GetString(),
        Message = TSK.SaveLoadoutMessage:GetString(),
        Type = "Input",
        Buttons = {
            {ID = 1, Type = "Yes", Text = CommonStrings.Save:GetString()},
            {ID = 2, Type = "No", Text = CommonStrings.Cancel:GetString()}
        }
    })
end)
MsgBox.RegisterMessageListener("epip_Hotbar_SaveLoadout", MsgBox.Events.InputSubmitted, function(text, buttonID, _)
    if buttonID == 1 then
        Hotbar.SaveLoadout(Hotbar.currentLoadoutRow, text)
    end
end)
