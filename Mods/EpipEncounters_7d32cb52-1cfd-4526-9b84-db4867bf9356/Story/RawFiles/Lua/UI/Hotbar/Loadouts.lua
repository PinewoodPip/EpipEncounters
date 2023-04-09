
local Hotbar = Client.UI.Hotbar

---@class HotbarLoadout
---@field Name string
---@field Slots HotbarLoadoutSlot[]

---@class HotbarLoadoutSlot
---@field Type string
---@field ElementID string The skill, action or template ID.

---------------------------------------------
-- METHODS
---------------------------------------------

---Apply a saved loadout to a row.
---@param char EclCharacter
---@param loadout string Loadout ID.
---@param row integer
---@param replaceUsedSlots boolean? If false, only empty slots will be filled. Defaults to false.
function Client.UI.Hotbar.ApplyLoadout(char, loadout, row, replaceUsedSlots)
    local data = Hotbar.Loadouts[loadout]

    if data then
        local skillBar = char.PlayerData.SkillBarItems

        local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
        for i=1,Hotbar.GetSlotsPerRow(),1 do
            local slotIndex = startingIndex + i
            local slot = skillBar[slotIndex]

            local savedSlot = data.Slots[i]

            if savedSlot and (replaceUsedSlots or slot.Type == "None") then
                slot.Type = savedSlot.Type
                slot.SkillOrStatId = savedSlot.ElementID
            end
        end

        Hotbar:DebugLog("Applied loadout: " .. loadout .. ", on row " .. row)
        Hotbar.UpdateSlotTextures()
    else
        Hotbar:LogError("Loadout does not exist: " .. loadout)
    end
end

---Save a row loadout.
---@param row integer
---@param name string Name of the loadout. Saving under an existing name overrides the loadout.
function Client.UI.Hotbar.SaveLoadout(row, name)
    local skillBar = Client.GetCharacter().PlayerData.SkillBarItems
    ---@type HotbarLoadout
    local loadout = {
        Slots = {},
        Name = name,
    }

    local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
    for i=1,Hotbar.GetSlotsPerRow(),1 do
        local slotIndex = startingIndex + i
        local slot = skillBar[slotIndex]
        ---@type HotbarLoadoutSlot
        local data = {
            Type = "None",
            ElementID = "",
        }

        -- Saving items is not supported.
        if slot.Type ~= "Item" then
            data.Type = slot.Type
            data.ElementID = slot.SkillOrStatId
        end

        table.insert(loadout.Slots, data)
    end

    Hotbar.Loadouts[name] = loadout

    Hotbar.SaveData()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Hotbar:RegisterCallListener("pipSlotRightClicked", function(ev, index)
    index = index + 1

    local ui = Hotbar:GetUI()
    local root = ui:GetRoot()

    -- We don't pull up the context menu if a skill is being cast.
    if not Hotbar.GetSlotHolder().activeSkill_mc.visible then
        Hotbar:DebugLog("Opening context menu for slots")

        Hotbar.contextMenuSlot = index

        Hotbar.currentLoadoutRow = math.floor((index - 1) / Hotbar.GetSlotsPerRow()) + 1
        ui:ExternalInterfaceCall("pipRequestContextMenu", "hotbarSlot", root.stage.mouseX + 10, root.stage.mouseY - 110, Ext.UI.HandleToDouble(Client.GetCharacter().Handle))
    end
end)