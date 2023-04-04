
local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"

---@class ScriptLoadRequest
---@field WIP boolean? If `true`, the script will only load in Pip dev mode.
---@field Developer boolean? If `true`, the script will only load in developer modes.
---@field ScriptSet path? Should be a folder. If present, its Shared.lua and Client.lua/Server.lua scripts will be loaded based on context.
---@field Script path?
---@field Scripts path[]? Will be loaded sequentially, after ScriptSet (if present).

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
                    if Ext.IsServer() then
                        contextSpecificScript = "/Server.lua"
                    end
        
                    Ext.Require(prefixedGUID, script.ScriptSet .. "/Shared.lua")
                    Ext.Require(prefixedGUID, script.ScriptSet .. contextSpecificScript)
                elseif script.Script then
                    Ext.Require(prefixedGUID, script.Script)
                end

                for _,scriptName in ipairs(script.Scripts or {}) do
                    Ext.Require(prefixedGUID, scriptName)
                end
            end
        elseif type(script) == "string" then
            Ext.Require(prefixedGUID, script)
        end
    end
end