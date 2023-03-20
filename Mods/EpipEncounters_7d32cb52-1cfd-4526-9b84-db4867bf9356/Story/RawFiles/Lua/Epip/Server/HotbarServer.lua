local Hotbar = {
    
}
Epip.AddFeature("HotbarManager", "HotbarManager", Hotbar)
Hotbar:Debug()

---@param char EsvCharacter
---@param item EsvItem
function Hotbar.UseItem(char, item)
    Osi.CharacterUseItem(char.MyGuid, item.MyGuid, "")
end

---Save the layout for a char.
---@param char EsvCharacter
---@param layout HotbarState
function Hotbar.SaveLayout(char, layout)
    Osi.DB_PIP_Hotbar_State:Delete(char.MyGuid, nil, nil, nil)

    if not Character.HasOwner(char) then
        for i,bar in ipairs(layout.Bars) do
            local visible = bar.Visible and 1 or 0
    
            Osi.DB_PIP_Hotbar_State(
                char.MyGuid,
                i,
                bar.Row,
                visible
            )
        end
    
        Hotbar:DebugLog("Saved state for " .. char.DisplayName)
    end
end

function Hotbar.GetSavedLayout(char)
    ---@type HotbarState
    local layout = {Bars = {}}
    local db = Osi.DB_PIP_Hotbar_State:Get(char.MyGuid, nil, nil, nil)

    if #db > 0 then
        for i,tuple in ipairs(db) do
            local visible = false
            if tuple[4] == 1 then
                visible = true
            end
            
            layout.Bars[tuple[2]] = {
                Row = tuple[3],
                Visible = visible,
            }
        end
    
        return layout
    else
        return nil
    end
end

---@param char EsvCharacter
function Hotbar.SynchLayout(char)
    local layout = Hotbar.GetSavedLayout(char)
    local id = Osiris.CharacterGetReservedUserID(char)

    if layout then
        Hotbar:DebugLog("Found saved layout for " .. char.DisplayName .. "; sending.")

        Net.PostToUser(id, "EPIPENCOUNTERS_Hotbar_SetLayout", {
            Layout = layout,
            CharacterNetID = char.NetID,
        })
    end
end

function Hotbar.SynchLayouts()
    for _,tuple in ipairs(Osi.DB_IsPlayer:Get(nil)) do
        local char = Character.Get(tuple[1])
        
        Hotbar.SynchLayout(char)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseItem", function(payload)
    Hotbar.UseItem(Character.Get(payload.CharNetID), Item.Get(payload.ItemNetID))
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseTemplate", function(payload)
    Osi.PROC_PIP_Hotbar_UseTemplate(Ext.GetCharacter(payload.NetID).MyGuid, payload.Template)
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SaveLayout", function(payload)
    for guid,state in pairs(payload) do
        Hotbar.SaveLayout(Ext.GetCharacter(tonumber(guid)), state)
    end
end)

-- Listen for clients becoming ready.
GameState.Events.ClientReady:Subscribe(function (ev)
    local userChar = Character.Get(ev.CharacterNetID)

    for _,char in ipairs(Character.GetPartyMembers(userChar)) do
        if char.ReservedUserID == userChar.ReservedUserID then
            Hotbar.SynchLayout(char)
        end
    end
end)