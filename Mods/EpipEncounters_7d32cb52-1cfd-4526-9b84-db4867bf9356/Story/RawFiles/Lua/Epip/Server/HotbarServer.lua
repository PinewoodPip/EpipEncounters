local Hotbar = {}
Epip.AddFeature("HotbarManager", "HotbarManager", Hotbar)
Hotbar:Debug()

---Save the layout for a char.
---@param char EsvCharacter
---@param layout HotbarState
function Hotbar.SaveLayout(char, layout)
    Osi.DB_PIP_Hotbar_State:Delete(char.MyGuid, nil, nil, nil)

    for i,bar in ipairs(layout.Bars) do
        local visible = 0

        if bar.Visible then
            visible = 1
        end

        -- Do not save extra bars from April Fools mode
        if i > 5 then
            break
        end

        Osi.DB_PIP_Hotbar_State(
            char.MyGuid,
            i,
            bar.Row,
            visible
        )
    end

    Hotbar:DebugLog("Saved state for " .. char.DisplayName)
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Game.Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseTemplate", function(cmd, payload)
    Osi.PROC_PIP_Hotbar_UseTemplate(Ext.GetCharacter(payload.NetID).MyGuid, payload.Template)
end)

Game.Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SaveLayout", function(cmd, payload)
    for guid,state in pairs(payload) do
        Hotbar.SaveLayout(Ext.GetCharacter(tonumber(guid)), state)
    end
end)

Ext.Osiris.RegisterListener("SavegameLoaded", 4, "before", function(major, minor, patch, build)
    for i,tuple in ipairs(Osi.DB_IsPlayer:Get(nil)) do
        local char = Ext.GetCharacter(tuple[1])
        local layout = Hotbar.GetSavedLayout(char)
        local id = Osi.CharacterGetReservedUserID(char.MyGuid)

        if layout then
            Hotbar:Log("Found saved layout for " .. char.DisplayName .. "; sending.")
            Game.Net.PostToUser(id, "EPIPENCOUNTERS_Hotbar_SetLayout", {
                Layout = layout,
                NetID = char.NetID,
            })
        end
    end
end)