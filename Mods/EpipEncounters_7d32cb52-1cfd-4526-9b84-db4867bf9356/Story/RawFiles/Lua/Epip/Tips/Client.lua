
---------------------------------------------
-- Offers a way to show mod usage tips to the user.
---------------------------------------------

local SettingsMenu = Epip.GetFeature("Feature_SettingsMenuOverlay")

---@class Features.Tips : Feature
local Tips = {
    _Tips = {}, ---@type table<string, Features.Tips.Tip>

    Settings = {},
    TranslatedStrings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsTipApplicable = {}, ---@type Hook<{Tip: Features.Tips.Tip, Applicable:boolean}>
    },
}
Epip.RegisterFeature("Features.Tips", Tips)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias Features.SettingsMenu.Entry.Type "Tip"

---@class Features.Tips.Tip
---@field ID string
---@field Tip TextLib.String
---@field InputDevice inputdevice? Input device restriction. `nil` indicates no restriction.
---@field RequiresEE boolean? Defaults to `false`.

---------------------------------------------
-- SETTINGS
---------------------------------------------

Tips.Settings.SeenTips = Tips:RegisterSetting("SeenTips", {
    Type = "Map",
    DefaultValue = {},
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a tip.
---@param tip Features.Tips.Tip
function Tips.RegisterTip(tip)
    Tips._Tips[tip.ID] = tip
end

---Returns whether a tip is applicable to the user's current setup.
---@param tip Features.Tips.Tip|string
---@return boolean
function Tips.IsApplicable(tip)
    tip = type(tip) == "string" and Tips._Tips[tip] or tip -- ID overload.
    return Tips.Hooks.IsTipApplicable:Throw({
        Tip = tip,
        Applicable = true,
    }).Applicable
end

---Marks a tip as seen.
---@param tip Features.Tips.Tip|string
function Tips.MarkAsSeen(tip)
    tip = type(tip) == "table" and tip.ID or tip -- Table overload.
    local setting = Tips.Settings.SeenTips:GetValue()

    setting[tip] = true
    Tips.Settings.SeenTips:SetValue(setting)

    Tips:SaveSettings()
end

---Returns whether a tip has been seen by the user.
---@param tip Features.Tips.Tip|string
function Tips.WasSeen(tip)
    tip = type(tip) == "table" and tip.ID or tip -- Table overload.
    return Tips.Settings.SeenTips:GetValue()[tip] == true
end

---Returns a random applicable hint.
---@param includeSeen boolean? Defaults to `false`. Seen tips might still be returned if the user has seen them all at least once.
---@return Features.Tips.Tip? `nil` if no valid tips are available.
function Tips.GetRandomTip(includeSeen)
    local validTips = {} ---@type string[]
    local chosenTip
    for id,_ in pairs(Tips.GetApplicableTips()) do
        if includeSeen or not Tips.WasSeen(id) then
            table.insert(validTips, id)
        end
    end

    -- If all tips have been seen, pick from any tip.
    if not includeSeen and #validTips == 0 then
        chosenTip = Tips.GetRandomTip(true)
    else
        chosenTip = Tips._Tips[validTips[math.random(1, #validTips)]]
    end

    return chosenTip
end

---Returns the tips applicable to the user's setup.
---@return table<string, Features.Tips.Tip>
function Tips.GetApplicableTips()
    local allTips = Tips._Tips
    local validTips = {}
    for id,tip in pairs(allTips) do
        if Tips.IsApplicable(tip) then
            validTips[id] = tip
        end
    end
    return validTips
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Only show tips relevant to the current input device.
Tips.Hooks.IsTipApplicable:Subscribe(function (ev)
    local device = ev.Tip.InputDevice
    if device then
        if device == "KeyboardAndMouse" then
            ev.Applicable = ev.Applicable and Client.IsUsingKeyboardAndMouse()
        elseif device == "Controller" then
            ev.Applicable = ev.Applicable and Client.IsUsingController()
        end
    end
end, {StringID = "DefaultImplementation.InputDevice"})

-- Only show EE tips when playing EE.
Tips.Hooks.IsTipApplicable:Subscribe(function (ev)
    if ev.Tip.RequiresEE then
        ev.Applicable = ev.Applicable and EpicEncounters.IsEnabled()
    end
end)

-- Implement a "Tip" entry type for the settings menu.
SettingsMenu.Events.RenderEntry:Subscribe(function (ev)
    if ev.Entry.Type == "Tip" then
        local tip = Tips.GetRandomTip()
        SettingsMenu.UI.RenderEntry({Type = "Label", Label = tip and Text.Resolve(tip.Tip) or ""})
    end
end)
