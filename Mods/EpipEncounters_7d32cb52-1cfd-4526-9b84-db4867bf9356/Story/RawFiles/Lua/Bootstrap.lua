
local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"

-- Epip does not work in-editor.
if Ext.Utils.GameVersion() ~= "v3.6.51.9303" then
    for _,script in ipairs(LOAD_ORDER) do
        if type(script) == "table" and (not script.WIP or Epip.IsDeveloperMode(true)) then
            local canLoad = false
            if script.WIP then
                if Epip.IsDeveloperMode(true) then
                    canLoad = true
                end
            elseif script.Developer then
                if Epip.IsDeveloperMode() then
                    canLoad = true
                end
            else
                canLoad = true
            end

            if canLoad then
                if script.ScriptSet then
                    local contextSpecificScript = "/Client.lua"
                    if Ext.IsServer() then contextSpecificScript = "/Server.lua" end
        
                    Ext.Require(prefixedGUID, script.ScriptSet .. "/Shared.lua")
                    Ext.Require(prefixedGUID, script.ScriptSet .. contextSpecificScript)
    
                else
                    Ext.Require(prefixedGUID, script.Script)
                end
            end
        elseif type(script) == "string" then
            Ext.Require(prefixedGUID, script)
        end
    end
end