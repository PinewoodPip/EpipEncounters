
local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"
local EE_CORE_GUID = "63bb9b65-2964-4c10-be5b-55a63ec02fa0"

---@class ScriptLoadRequest
---@field WIP boolean? If `true`, the script will only load in Pip dev mode.
---@field Developer boolean? If `true`, the script will only load in developer modes.
---@field ScriptSet path? Should be a folder. If present, its Shared.lua and Client.lua/Server.lua scripts will be loaded based on context.
---@field Script path?
---@field Scripts (path|ScriptLoadRequest)[]? Will be loaded sequentially, after ScriptSet (if present).
---@field RequiresEE boolean? If `true`, the scripts and script set will only be loaded if EE Core is enabled.

---Requests a script to be loaded.
---@param script ScriptLoadRequest|string
---@return any --Only for simple requests (string).
function RequestScriptLoad(script)
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

        if script.RequiresEE then
            canLoad = canLoad and Ext.Mod.IsModLoaded(EE_CORE_GUID)
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

            for _,subScript in ipairs(script.Scripts or {}) do
                RequestScriptLoad(subScript)
            end
        end
    elseif type(script) == "string" then
        return Ext.Require(prefixedGUID, script)
    end
end