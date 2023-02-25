
---@class UserVarsLib : Library
UserVars = {
    ---@type table<string, UserVarsLib_UserVar>
    _RegisteredVariables = {},
}
Epip.InitializeLibrary("UserVars", UserVars)

---------------------------------------------
-- CLASSES
---------------------------------------------

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

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a user variable.
---Must be done once for each context where you want the variable to exist.
---@see UserVarsLib_UserVar
---@param name string
---@param data UserVarsLib_UserVar? Defaults to default values (see class).
---@return UserVarsLib_UserVar
function UserVars.Register(name, data)
    data = data or {} ---@type UserVarsLib_UserVar
    data.Name = name
    data.Client = data.Client ~= nil and data.Client or true
    data.Server = data.Server ~= nil and data.Server or true
    data.WriteableOnServer = data.WriteableOnServer or true
    data.WriteableOnClient = data.WriteableOnClient or false
    data.Persistent = data.Persistent or false
    data.SyncToClient = data.SyncToClient or true
    data.SyncToServer = data.SyncToServer or true
    data.SyncOnWrite = data.SyncOnWrite or false
    data.SyncOnTick = data.SyncOnTick or true
    data.DontCache = data.DontCache or false

    UserVars._RegisteredVariables[name] = data

    Ext.Utils.RegisterUserVariable(name, data)

    return data
end