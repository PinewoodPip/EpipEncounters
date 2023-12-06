
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class UserVarsLib : Library
UserVars = {
    NETMSG_REQUEST_SYNC = "UserVarsLib.NetMsg.RequestSync", -- Empty message.

    ---@type table<string, UserVarsLib_UserVar>
    _RegisteredVariables = {},
    ---@type table<GUID, table<string, UserVarsLib_ModVar>>
    _RegisteredModVars = DefaultTable.Create({})
}
Epip.InitializeLibrary("UserVars", UserVars)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias UserVarsLib_CompatibleComponent Character|Item

---@class UserVarsLib_UserVar
---@field ID string
---@field Client boolean
---@field Server boolean
---@field WriteableOnServer boolean Defaults to `true`.
---@field WriteableOnClient boolean Defaults to `false`.
---@field Persistent boolean
---@field SyncToClient boolean Defaults to `true`.
---@field SyncToServer boolean Defaults to `true`.
---@field SyncOnWrite boolean Defaults to `false`.
---@field SyncOnTick boolean Defaults to `true`.
---@field DontCache boolean Defaults to `false`
---@field DefaultValue any?

---@class UserVarsLib_ModVar : UserVarsLib_UserVar
---@field ModGUID GUID

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a user variable.
---Must be done once for each context where you want the variable to exist.
---@see UserVarsLib_UserVar
---@param name string
---@param data UserVarsLib_UserVar? Defaults to default values (see class).
---@return UserVarsLib_UserVar
function UserVars.RegisterUserVariable(name, data)
    -- TODO investigate what causes synching issues
    local options = {
        Persistent = false,
        Client = true,
        Server = true,
        SyncToClient = true,
        SyncToServer = true,
        SyncOnWrite = true,
        SyncOnTick = true,
        WriteableOnServer = true,
        WriteableOnClient = true,
    }
    if data.Persistent then
        options.Persistent = true
    end

    UserVars._RegisteredVariables[name] = data

    Ext.Vars.RegisterUserVariable(name, options)

    return data
end

---Returns the definition of a user variable.
---@param varName string
---@return UserVarsLib_UserVar
function UserVars.GetUserVarDefinition(varName)
    return UserVars._RegisteredVariables[varName]
end

---Returns the value of a user variable for an entity.
---@param component UserVarsLib_CompatibleComponent
---@param varName string
---@return any? -- Defaults to `DefaultValue`.
function UserVars.GetUserVarValue(component, varName)
    local def = UserVars.GetUserVarDefinition(varName)
    local value = component.UserVars[varName]

    if value == nil then
        value = UserVars._GetVarDefaultValue(def)
    end

    return value
end

---Registers a mod variable.
---@param modGUID GUID
---@param name string
---@param data UserVarsLib_ModVar? Defaults to default values (see class).
---@return UserVarsLib_ModVar
function UserVars.RegisterModVariable(modGUID, name, data)
    data = UserVars._ParseVarParameters(name, data) ---@cast data UserVarsLib_ModVar

    UserVars._RegisteredModVars[modGUID][name] = data
    data.ModGUID = modGUID

    -- TODO investigate what causes synching issues
    local options = {
        Persistent = false,
        Client = true,
        Server = true,
        SyncToClient = true,
        SyncToServer = true,
        SyncOnWrite = true,
        SyncOnTick = true,
        WriteableOnServer = true,
        WriteableOnClient = false,
    }
    if data.Persistent then
        options.Persistent = true
    end

    Ext.Vars.RegisterModVariable(modGUID, name, options)

    return data
end

---Returns the mod variables of a mod.
---@param modGUID GUID
---@return table
function UserVars.GetModVariables(modGUID)
    return Ext.Vars.GetModVariables(modGUID)
end

---Returns the value of a mod var.
---@param modGUID GUID
---@param varName string
---@return any? -- Defaults to `DefaultValue`.
function UserVars.GetModVarValue(modGUID, varName)
    local def = UserVars.GetModVarDefinition(modGUID, varName)
    local modVars = UserVars.GetModVariables(modGUID)
    local value = modVars[varName]

    if value == nil then
        value = UserVars._GetVarDefaultValue(def)
    end

    return value
end

---Returns the definition of a mod variable.
---@param modGUID GUID
---@param var string
---@return UserVarsLib_ModVar
function UserVars.GetModVarDefinition(modGUID, var)
    return UserVars._RegisteredModVars[modGUID][var]
end

---Parses the parameters for creating a variable.
---@param name string
---@param data UserVarsLib_UserVar? Defaults to default values (see class).
---@return UserVarsLib_UserVar
function UserVars._ParseVarParameters(name, data)
    -- TODO fix
    data = data or {} ---@type UserVarsLib_UserVar
    data.Client = true
    data.Server = true
    data.WriteableOnServer = true
    data.WriteableOnClient = true
    data.Persistent = data.Persistent or false
    data.SyncToClient = true
    data.SyncToServer = true
    data.SyncOnWrite = data.SyncOnWrite or false
    data.SyncOnTick = true
    data.DontCache = false

    return data
end

---Returns the default value of a variable.
---@param var UserVarsLib_UserVar|UserVarsLib_ModVar
---@return any?
function UserVars._GetVarDefaultValue(var)
    local value

    if type(var.DefaultValue) == "table" then
        value = table.deepCopy(var.DefaultValue)
    else
        value = var.DefaultValue
    end

    return value
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Request all variables to be synched when joining a session as a non-host.
-- This is a workaround for a flaw in the extender that causes variables to not be synched when joining a session mid-way.
if Ext.IsClient() then
    GameState.Events.ClientReady:Subscribe(function (ev)
        if not Client.IsHost() and not ev.FromReset then -- Not necessary to do this from a lua reset.
            UserVars:DebugLog("Connecting as non-host; requesting all variables to be synched")
            Net.PostToServer(UserVars.NETMSG_REQUEST_SYNC)
        end
    end)
else -- Dirtying must be done on the server side due to another flaw where client-to-server syncs are not propagated to other clients.
    Net.RegisterListener(UserVars.NETMSG_REQUEST_SYNC, function (_)
        UserVars:DebugLog("Synching all variables")

        Ext.Vars.DirtyUserVariables()
        Ext.Vars.DirtyModVariables()
    end)
end

-- Clear UserVars of dying summons to reduce savefile bloat.
-- TODO store a copy in case a mod tries to access them at this same point?
if Ext.IsServer() then
    Osiris.RegisterSymbolListener("CharacterDied", 1, "after", function (charGUID)
        local char = Character.Get(charGUID)
        if Character.IsSummon(char) then
            for id, var in pairs(UserVars._RegisteredVariables) do
                if var.WriteableOnServer and char.UserVars[id] ~= nil then -- Need to check whether the character has the var to avoid the annoying "repaired GUID" message on the client if it didn't have any.
                    char.UserVars[id] = nil
                end
            end
        end
    end)
end
