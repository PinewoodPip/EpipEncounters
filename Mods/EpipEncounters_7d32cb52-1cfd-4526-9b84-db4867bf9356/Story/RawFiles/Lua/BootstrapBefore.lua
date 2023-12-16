
local prefixedGUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"
local EE_CORE_GUID = "63bb9b65-2964-4c10-be5b-55a63ec02fa0"

---@enum ScriptLoadRequest.GameModeMask
GAMEMODE_MASK = {
    Campaign = 1,
    Arena = 2,
    GameMaster = 4,
}

---@class ScriptLoadRequest
---@field WIP boolean? If `true`, the script will only load in Pip dev mode.
---@field Developer boolean? If `true`, the script will only load in developer modes.
---@field ScriptSet path? Should be a folder. If present, its Shared.lua and Client.lua/Server.lua scripts will be loaded based on context.
---@field Script path?
---@field Scripts (path|ScriptLoadRequest)[]? Will be loaded sequentially, after ScriptSet (if present).
---@field RequiresEE boolean? If `true`, the scripts and script set will only be loaded if EE Core is enabled.
---@field RequiredMods GUID[]? If present, the request will only be fulfilled if all required mods are loaded.
---@field GameModes ScriptLoadRequest.GameModeMask? If present, the script will only be loaded if the current gamemode is in the mask. Defaults to all gamemodes.

---Returns whether a script load request can be fulfilled.
---@param request ScriptLoadRequest
---@return boolean
local function CanLoadRequest(request)
    local canLoad = false
    if request.WIP then
        if Epip.IsDeveloperMode(true) then
            canLoad = true
        end
    elseif request.Developer then
        if Epip.IsDeveloperMode() then
            canLoad = true
        end
    else
        canLoad = true
    end

    if request.RequiresEE then
        canLoad = canLoad and Ext.Mod.IsModLoaded(EE_CORE_GUID)
    end

    if request.GameModes then
        local gameMode = Ext.GetGameMode()
        local index = GAMEMODE_MASK[gameMode]

        canLoad = canLoad and ((request.GameModes & index) ~= 0)
    end

    for _,guid in ipairs(request.RequiredMods or {}) do -- Check mod requirements
        canLoad = canLoad and Ext.Mod.IsModLoaded(guid)
        if not canLoad then break end
    end
    return canLoad
end

---Requests a script to be loaded.
---@param script ScriptLoadRequest|string
---@return any --Only for simple requests (string).
function RequestScriptLoad(script)
    if type(script) == "table" and CanLoadRequest(script) then
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
    elseif type(script) == "string" then
        return Ext.Require(prefixedGUID, script)
    end
end