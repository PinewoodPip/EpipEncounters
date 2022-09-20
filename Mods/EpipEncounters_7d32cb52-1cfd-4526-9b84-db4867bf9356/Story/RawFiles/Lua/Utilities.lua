
---------------------------------------------
-- Gloabl utility methods.
---------------------------------------------

---Sets table1 to index undefined properties in table2.
---@param table1 table
---@param table2 table
function Inherit(table1, table2)
    setmetatable(table1, {
        __index = table2,
        __newindex = table2.__newindex,
        __mode = table2.__mode,
        __call = table2.__call,
        __metatable = table2.__metatable,
        __tostring = table2.__tostring,
        __len = table2.__len,
        __pairs = table2.__pairs,
        __ipairs = table2.__ipairs,
        __name = table2.__name,

        __unm = table2.__unm,
        __add = table2.__add,
        __sub = table2.__sub,
        __mul = table2.__mul,
        __div = table2.__div,
        __idiv = table2.__idiv,
        __mod = table2.__mod,
        __pow = table2.__pow,
        __concat = table2.__concat,

        __band = table2.__band,
        __bor = table2.__bor,
        __bxor = table2.__bxor,
        __bnot = table2.__bnot,
        __shl = table2.__shl,
        __shr = table2.__shr,

        __eq = table2.__eq,
        __lt = table2.__lt,
        __le = table2.__le,
    })
end

function InheritMultiple(table1, ...)
    local tbls = {...}

    setmetatable(table1, {
        __index = function(_, key)
            for _,tbl in ipairs(tbls) do
                if tbl[key] ~= nil then
                    return tbl[key]
                end
            end
        end
    })
end

local append = {
    isPaused = false,
}

for k,v in pairs(append) do
    Utilities[k] = v
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
            Net.PostToServer("EPIPENCOUNTERS_ClientReady", {NetID = Client.GetCharacter().NetID})
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
        Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
    end)

    Ext.Osiris.RegisterListener("PROC_AMER_GEN_CCFinished_GameStarted", 4, "after", function(major, minor, patch, build)
        Utilities.Hooks.FireEvent("Game", "Loaded")
        Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
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

if Ext.IsServer() then
    Ext.Events.ResetCompleted:Subscribe(function()
        Utilities.Hooks.FireEvent("Game", "Loaded")
        Utilities.Hooks.FireEvent("GameState", "ClientReady")
        Net.Broadcast("EPIPENCOUNTERS_GameLoaded")
    end)
end