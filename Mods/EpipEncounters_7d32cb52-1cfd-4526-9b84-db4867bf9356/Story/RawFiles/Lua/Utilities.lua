
---------------------------------------------
-- Gloabl utility methods.
---------------------------------------------

function GetConfig(modname, defaultConfig)
    local configFilename = "Config_" .. modname .. ".json"
    local storedSettings = Ext.IO.LoadFile(configFilename)

    if storedSettings then
        storedSettings = Ext.Json.Parse(storedSettings)
    else
        storedSettings = {}
    end

    -- add missing entries to the config
    local hasNewEntries = false
    for i,v in pairs(defaultConfig) do
        if storedSettings[i] == nil then
            storedSettings[i] = v
            hasNewEntries = true
        end
    end

    if hasNewEntries then -- resave to add missing options to the file
        Ext.IO.SaveFile(configFilename, Ext.Json.Stringify(storedSettings))
    end

    return storedSettings
end

function SaveConfig(modname, config)
    local configFilename = "Config_" .. modname .. ".json"
    Ext.IO.SaveFile(configFilename, Ext.Json.Stringify(config))
end

---Sets table1 to index undefined properties in table2.
---@param table1 table
---@param table2 table
function Inherit(table1, table2)
    setmetatable(table1, {__index = table2})
end

local append = {
    isPaused = false,

    GetConfig = GetConfig,
    SaveConfig = SaveConfig,
}

for k,v in pairs(append) do
    Utilities[k] = v
end

function Utilities.RandomSign()
    if Ext.Random(0, 1) == 1 then
        return 1
    else
        return -1
    end
end

function Utilities.LoadJson(file, source)
    local contents = Ext.IO.LoadFile(file, source)

    if contents then
        contents = Ext.Json.Parse(contents)
    end

    return contents
end

function Utilities.SaveJson(filename, contents)
    Ext.IO.SaveFile(filename, Ext.DumpExport(contents))
end

---Count the amount of keys in a table.
---@param t table
---@return integer Key count.
function Utilities.CountKeys(t)
    local count = 0
    for i,v in pairs(t) do
        count = count + 1
    end
    return count
end

function Utilities.IsClientControlled(character)
    local root = Client.UI.PlayerInfo:GetRoot()

    for i=0,#root.player_array-1,1 do
        local player = root.player_array[i]

        if Ext.UI.DoubleToHandle(player.id) == character.Handle then
            return player.controlled
        end 
    end
    return false
end

function Utilities.IsEditor()
    return Ext.Utils.GameVersion() == Game.EDITOR_VERSION
end

function Utilities.Log(module, message, type)
    Utilities._Log(module, type, message)
end

function Utilities._Log(module, type, ...)
    local str = " [" .. module:upper() .. "]"
    -- str = str .. " " .. message

    if not type then type = "" end

    Ext["Print" .. type](str, ...)
end

function Utilities.LogWarning(module, message)
    Utilities.Log(module, message, "Warning")
end

function Utilities.LogError(module, message)
    Utilities.Log(module, message, "Error")
end

local ready = false
Ext.Events.GameStateChanged:Subscribe(function(event)
    local old = event.FromState
    local new = event.ToState
    
    if old == "PrepareRunning" and new == "Running" then
        Utilities.Hooks.FireEvent("GameState", "ClientReady")

        if not ready then
            Game.Net.PostToServer("EPIPENCOUNTERS_ClientReady", {NetID = Client.GetCharacter().NetID})
        end
    end
    if new == "Paused" then
        Utilities.isPaused = true
        Utilities.Hooks.FireEvent("GameState", "GamePaused")
    elseif new == "Running" then
        Utilities.isPaused = false
        Utilities.Hooks.FireEvent("GameState", "GameUnpaused")
    end
end)

function Utilities.Stringify(message)
    if type(message) ~= "string" then
        message = Ext.Json.Stringify(message)
    end
    return message
end

function Utilities.TableIsEmpty(table)
    local empty = true

    for i,v in pairs(table) do
        empty = false
        break
    end

    return empty
end

function Utilities.GetPrefixedGUID(char)
    return char.RootTemplate.Name .. "_" .. char.MyGuid
end

function Utilities.GetPrefixedRootTemplateID(entity)
    return entity.RootTemplate.Name .. "_" .. entity.RootTemplate.Id
end

---------------------------------------------
-- GameLoaded Event
---------------------------------------------

local _loaded = false
if Ext.IsServer() then
    Ext.Osiris.RegisterListener("SavegameLoaded", 4, "after", function(major, minor, patch, build)
        Utilities.Hooks.FireEvent("Game", "Loaded")
        Game.Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
    end)

    Ext.Osiris.RegisterListener("PROC_AMER_GEN_CCFinished_GameStarted", 4, "after", function(major, minor, patch, build)
        Utilities.Hooks.FireEvent("Game", "Loaded")
        Game.Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
    end)
else
    Ext.RegisterNetListener("EPIPENCOUNTERS_GameLoaded", function(cmd, payload)
        if not _loaded then
            Utilities.Hooks.FireEvent("Game", "Loaded")
            _loaded = true
        end
    end)
    Utilities.Hooks.RegisterListener("GameState", "ClientReady", function()
        if not _loaded then
            Utilities.Hooks.FireEvent("Game", "Loaded")
            _loaded = true
        end
    end)
end

Ext.Events.ResetCompleted:Subscribe(function()
    Utilities.Hooks.FireEvent("Game", "Loaded")
    Utilities.Hooks.FireEvent("GameState", "ClientReady")
    Game.Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
end)