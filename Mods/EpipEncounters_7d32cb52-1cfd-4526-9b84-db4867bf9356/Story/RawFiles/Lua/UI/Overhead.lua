
---------------------------------------------
-- Hooks for overhead.swf.
-- Epip uses this to fix overhead damage text for restoring armor on undead characters, which does not work in the base game.
---------------------------------------------

---@class OverheadUI : UI
local Overhead = {
    UI = nil,
    Root = nil,

    ---@enum UI.Overhead.Type
    FLASH_OVERHEAD_TYPES = {
        OVERHEAD = 0, -- Used for CharacterStatusText.
        DAMAGE = 1,
        DIALOG = 2,
        CHARHOLDER = 3,
    },
    FLASH_ADDOH_ARRAY_TEMPLATE = {
        "Type",
        "CharacterHandle",
        "Label",
        "Duration",
    },
    FLASH_ENTRY_TEMPLATES = {
        SELECTION_INFO = {
            "ComponentHandle",
            "NameLabel",
            "Unused1",
            "UnknownColor",
            "VitalityFraction",
            "PhysicalArmorFraction",
            "MagicArmorFraction",
            "PhysicalArmorLabel",
            "MagicArmorLabel",
            "Unknown10",
            "LevelLabel",
            "InteractLabel",
            "InteractInfoLabel",
            "ActionPointsLabel",
            "HasEnoughAPForAction",
            "ShowCyclers",
            "VitalityLabel",
            "ChanceToHitLabel",
            "HasNoAction_m",
            "PlayerOwnerID",
            "CanCreateNewHolder",
        },
    },

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
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        RequestOverheads = {}, ---@type Hook<UI.Overhead.Hooks.RequestOverheads>
        UpdateSelections = {}, ---@type Hook<UI.Overhead.Hooks.UpdateSelections>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.overhead, "Overhead", Overhead)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class UI.Overhead.OverheadRequest
---@field Type UI.Overhead.Type
---@field CharacterHandle integer
---@field Label string
---@field Duration integer Has different meaning for CHARHOLDER. TODO

---@class UI.Overhead.SelectionRequest
---@field ComponentHandle FlashItemHandle|FlashCharacterHandle
---@field NameLabel string
---@field Unused1 unknown
---@field UnknownColor number
---@field VitalityFraction number
---@field PhysicalArmorFraction number
---@field MagicArmorFraction number
---@field PhysicalArmorLabel string
---@field MagicArmorLabel string
---@field Unknown10 unknown
---@field LevelLabel string
---@field InteractLabel string
---@field InteractInfoLabel string
---@field ActionPointsLabel string
---@field HasEnoughAPForAction boolean
---@field ShowCyclers boolean
---@field VitalityLabel string
---@field ChanceToHitLabel string
---@field HasNoAction_m boolean
---@field PlayerOwnerID integer
---@field CanCreateNewHolder boolean

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.Overhead.Hooks.RequestOverheads
---@field Overheads UI.Overhead.OverheadRequest[] Hookable.

---@class UI.Overhead.Hooks.UpdateSelections
---@field Selections UI.Overhead.SelectionRequest[] Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

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

-- Hook overhead requests.
Overhead:RegisterInvokeListener("updateOHs", function (ev)
    local root = ev.UI:GetRoot()
    local array = root.addOH_array
    local contents = Client.Flash.ParseArray(array, Overhead.FLASH_ADDOH_ARRAY_TEMPLATE, false) ---@type UI.Overhead.OverheadRequest[]

    contents = Overhead.Hooks.RequestOverheads:Throw({
        Overheads = contents,
    }).Overheads

    Client.Flash.EncodeArray(array, Overhead.FLASH_ADDOH_ARRAY_TEMPLATE, contents)

    local selectionArray = root.selectionInfo_array
    local selections = Client.Flash.ParseArray(selectionArray, Overhead.FLASH_ENTRY_TEMPLATES.SELECTION_INFO)
    selections = Overhead.Hooks.UpdateSelections:Throw({
        Selections = selections,
    }).Selections
    Client.Flash.EncodeArray(selectionArray, Overhead.FLASH_ENTRY_TEMPLATES.SELECTION_INFO, selections)
end, "Before")

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

Ext.RegisterUITypeCall(Ext.UI.TypeID.overhead, "pipOverheadAttempt", function(ui, method, handle, str)

    str = str:gsub(Text.PATTERNS.FONT_SIZE, string.format(Text.TEMPLATES.FONT_SIZE, Overhead.currentDamageOverheadSize))

    local char = Ext.GetCharacter(Ext.UI.DoubleToHandle(handle))
    if not char then char = Ext.GetItem(Ext.UI.DoubleToHandle(handle)) end

    if not char then return nil end

    Overhead.AddDamage(char, str)
end)

Ext.RegisterUITypeCall(Ext.UI.TypeID.overhead, "pipOverheadDialogAttempt", function(ui, method, handle, str, duration)

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