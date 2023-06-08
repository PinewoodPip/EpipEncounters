
---------------------------------------------
-- Hooks for overhead.swf.
-- Epip uses this to fix overhead damage text for restoring armor on undead characters, which does not work in the base game.
---------------------------------------------

---@class OverheadUI : UI
local Overhead = {
    UI = nil,
    Root = nil,

    DEFAULT_OVERHEADS_SIZE = 19, -- TODO implement in swf
    DEFAULT_DAMAGE_OVERHEADS_SIZE = 24,
    OVERHEAD_DAMAGE_TEMPLATE = "<font size=\"%d\" color=\"%s\">+</font><font size=\"%d\" color=\"%s\">%d</font>",

    ---------------------------------------------
    -- Internal variables, do not set
    ---------------------------------------------
    currentOverheadSize = 19,
    statusOverheadDurationMultiplier = 1;
    currentDamageOverheadSize = 24,

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/overhead.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/overhead.swf",
    },
    SETTINGS = {
        StatusOverheadsDurationMultiplier = true,
        DamageOverheadsSize = true,
        OverheadsSize = true,
    }
}
Epip.InitializeUI(Client.UI.Data.UITypes.overhead, "Overhead", Overhead)

-- TODO call for normal overhead

function Overhead.SetSizes(overheadSize, damageOverheadSize)
    if Overhead:GetUI() then
        if overheadSize then
            Overhead:GetRoot().setOverheadSize(overheadSize)
            Overhead.currentOverheadSize = overheadSize
        end
    
        if damageOverheadSize then
            Overhead:GetRoot().damageOverheadSize = damageOverheadSize
            Overhead.currentDamageOverheadSize = damageOverheadSize
        end
    end
end

function Overhead.SetStatusDurationMultiplier(number)
    Overhead:GetRoot().overheadStatusDurationMultiplier = number
end

-- Use this function to display damage overheads
function Overhead.ShowDamage(char, amount, color)
    local str = Overhead.FormatDamage(amount, color)
    Overhead.AddDamage(char, str)
end

-- Use this one to display arbitrary text instead, using the OverheadDamage behaviour
function Overhead.AddDamage(char, str)
    local handle = Ext.UI.HandleToDouble(char.Handle)
    local root = Overhead:GetRoot()
    root.addOverhead(handle, "", 0) -- necessary in order for tracking to work properly. There's possibly some update call that is not made when applying just overhead damage? unlikely, need to investigate further
    root.addOverheadDamage(handle, str)
end

-- Set sizes from Epip settings
function Overhead.SetFromSettings()
    Overhead.SetSizes(Settings.GetSettingValue("Epip_Overheads", "OverheadsSize"), Settings.GetSettingValue("Epip_Overheads", "DamageOverheadsSize"))
    Overhead.SetStatusDurationMultiplier(Settings.GetSettingValue("Epip_Overheads", "StatusOverheadsDurationMultiplier"))
end

-- Reset sizes to the default ones
function Overhead.ResetSizes()
    Overhead.SetSizes(Overhead.DEFAULT_OVERHEADS_SIZE, Overhead.DEFAULT_DAMAGE_OVERHEADS_SIZE)
end

---------------------------------------------
-- INTERNAL METHODS
---------------------------------------------
function Overhead.FormatDamage(amount, color)
    local size = Overhead.currentDamageOverheadSize
    local template = Overhead.OVERHEAD_DAMAGE_TEMPLATE
    local str = string.format(template, size, color, size, color, tostring(amount))

    return str
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "Epip_Overheads" and Overhead.SETTINGS[ev.Setting.ID] then
        Overhead.SetFromSettings()
    end
end)

Ext.Events.SessionLoaded:Subscribe(function()
    Overhead.SetFromSettings()
end)

-- Revert any custom sizing while within AMER UIs.
Utilities.Hooks.RegisterListener("AMERUI", "CharacterEnteredUI", function(data)
    if Utilities.IsClientControlled(data.Character) then
        Overhead.ResetSizes()
    end
end)
Utilities.Hooks.RegisterListener("AMERUI", "CharacterExitedUI", function(data)
    if Utilities.IsClientControlled(data.Character) then
        Overhead.SetFromSettings()
    end
end)

Ext.RegisterUITypeCall(Client.UI.Data.UITypes.overhead, "pipOverheadAttempt", function(ui, method, handle, str)

    str = str:gsub(Text.PATTERNS.FONT_SIZE, string.format(Text.TEMPLATES.FONT_SIZE, Overhead.currentDamageOverheadSize))

    local char = Ext.GetCharacter(Ext.UI.DoubleToHandle(handle))
    if not char then char = Ext.GetItem(Ext.UI.DoubleToHandle(handle)) end

    if not char then return nil end

    Overhead.AddDamage(char, str)
end)

Ext.RegisterUITypeCall(Client.UI.Data.UITypes.overhead, "pipOverheadDialogAttempt", function(ui, method, handle, str, duration)

    str = str:gsub(Text.PATTERNS.FONT_SIZE, string.format(Text.TEMPLATES.FONT_SIZE, Overhead.currentOverheadSize))

    Overhead:GetRoot().addADialog(handle, str, duration)
end)

---------------------------------------------
-- TESTS AND LOGGING
---------------------------------------------
-- local function OnOverheadClear(ui, method)
--     local selection = ParseFlashArray(Overheads.Root.CH_array, {
--         {name = "1", paramsCount = 1}
--     })

--     -- Ext.Print("-----")
--     -- Ext.Dump(selection)
-- end

-- local function OnOverheadUpdate(ui, method)
--     local contents = ParseFlashArray(Overheads.Root.addOH_array, {
--         {name = "1", params = {"1", "2", "3"}},
--         {name = "2", params = {"1", "2", "3"}},
--         {name = "3", params = {"1", "2", "3"}},
--         {name = "4", params = {"1", "2", "3"}},
--     })

--     Ext.Dump(contents)
-- end

-- Ext.Events.SessionLoaded:Subscribe(function()
--     -- Ext.RegisterUIInvokeListener(Overheads.UI, "updateOHs", OnOverheadUpdate)
--     -- Ext.RegisterUIInvokeListener(Overheads.UI, "clearObsoleteOHTs", OnOverheadClear)
-- end)