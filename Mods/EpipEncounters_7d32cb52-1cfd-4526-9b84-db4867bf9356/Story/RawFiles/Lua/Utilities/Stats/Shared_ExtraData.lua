
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class StatsLib
local Stats = Stats
Stats.ExtraData = {} ---@type table<string, StatsLib.ExtraData.Entry>

Stats._DefaultExtraDataValues = DefaultTable.Create({}) ---@type table<GUID, table<string, number>>

---@class StatsLib.ExtraData.Entry
---@field ID string
---@field Name string
---@field Description string?
local _ExtraDataEntry = {}

---Creates an ExtraData entry.
---@package
---@param id string
---@return StatsLib.ExtraData.Entry
function _ExtraDataEntry._Create(id)
    local entry = {ID = id, Name = Text.SeparatePascalCase(id)} ---@type StatsLib.ExtraData.Entry
    Inherit(entry, _ExtraDataEntry)
    return entry
end

---Returns the current value of the entry.
---@return number
function _ExtraDataEntry:GetValue()
    ---@diagnostic disable-next-line: return-type-mismatch
    return Stats.Get("Data", self.ID)
end

---@return string
function _ExtraDataEntry:GetName()
    return self.Name or self.ID
end

---@return string
function _ExtraDataEntry:GetDescription()
    return self.Description or ""
end

---Returns the default value of the entry for a mod, as defined in Data.txt.
---@param mod GUID? Defaults to the last mod in the load order that has this value overwritten.
---@return number? --`nil` if the key is not defined in any Data.txt or the mod GUID is invalid / not loaded.
function _ExtraDataEntry:GetDefaultValue(mod)
    if not mod then -- Modless overload.
        local loadOrder = Ext.Mod.GetLoadOrder()
        for i=#loadOrder,1,-1 do
            local guid = loadOrder[i]

            if Stats._DefaultExtraDataValues[guid][self.ID] then
                mod = guid
                break
            end
        end
    end
    if not mod then return nil end

    return Stats._DefaultExtraDataValues[mod][self.ID]
end

---------------------------------------------
-- SETUP
---------------------------------------------

---Initializes an ExtraData entry.
---@param key string
---@return StatsLib.ExtraData.Entry
function Stats._RegisterExtraDataEntry(key)
    local entry = _ExtraDataEntry._Create(key)
    Stats.ExtraData[key] = entry
    return entry
end

-- Register ExtraData values
local loadOrder = Ext.Mod.GetLoadOrder()
for _,guid in ipairs(loadOrder) do
    local mod = Ext.Mod.GetMod(guid)
    local info = mod.Info
    local path = string.format("Public/%s/Stats/Generated/Data/Data.txt", info.Directory)
    local file = IO.LoadFile(path, "data", true)

    if file then
        for key,value in file:gmatch("key \"(%a-)\",\"(.-)\"") do
            Stats._DefaultExtraDataValues[guid][key] = tonumber(value)

            if not Stats.ExtraData[key] then
                Stats._RegisterExtraDataEntry(key)
            end
        end
    end
end