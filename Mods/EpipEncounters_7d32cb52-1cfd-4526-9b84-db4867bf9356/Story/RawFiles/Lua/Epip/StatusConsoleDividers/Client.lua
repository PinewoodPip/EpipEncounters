
---------------------------------------------
-- Implements customizable AP dividers for the status console.
---------------------------------------------

local StatusConsole = Client.UI.StatusConsole

---@class Features.StatusConsoleDividers : Feature
local Dividers = {
    ---@type table<GUID, integer> Default setting value to be used when certain mods are loaded. Used for mods that change the base AP values, where these dividers can be helpful for readability.
    OVERHAUL_DEFAULTS = {
        [Mod.GUIDS.EE_CORE] = 4,
        [Mod.GUIDS.FARANDOLE] = 4,
    },
    Settings = {},
    TranslatedStrings = {
        Setting_DividerInterval_Name = {
            Handle = "hd74d99b1gf914g4cb2gb3bfg832230e4cf0f",
            Text = "AP Divider Interval",
            ContextDescription = "Setting name; 'AP' refers to action points",
        },
        Setting_DividerInterval_Description = {
            Handle = "h9d0d399dg626eg48f9ga7cag91bc0899906d",
            Text = "Determines the amount of action points between which a larger divider graphic is shown on the AP bar. May help with readability of remaining \"actions\".<br><br>Set to '20' to effectively disable them.",
            ContextDescription = "Setting tooltip",
        },
    },
}
Epip.RegisterFeature("Features.StatusConsoleDividers", Dividers)
local TSK = Dividers.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

local _OverhaulMod = Mod.GetOverhaul()
Dividers.Settings.DividerInterval = Dividers:RegisterSetting("DividerInterval", {
    Type = "ClampedNumber",
    Name = TSK.Setting_DividerInterval_Name,
    Description = TSK.Setting_DividerInterval_Description,
    Min = 1,
    Max = 20,
    Step = 1,
    HideNumbers = false,
    DefaultValue = (_OverhaulMod and Dividers.OVERHAUL_DEFAULTS[_OverhaulMod.Info.ModuleUUID]) or 20, -- Defaults to 4 AP for overhauls that change the AP economy to be DOS1-like, effectively disabled otherwise.
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Updates the divider visuals.
function Dividers.Update()
    local root = StatusConsole:GetRoot()
    local apHolder = root.console_mc.ap_mc
    local amount = math.min(#apHolder.apList.content_array, apHolder.maxAPs)
    local character = Client.GetCharacter()
    local list = apHolder.dividerList
    local listWidth = amount * 22
    local interval = Dividers.Settings.DividerInterval:GetValue()

    list.EL_SPACING = -10
    list.x = -14.5
    list.y = -2
    list.positionElements()

    apHolder.x = (-7) - math.floor(listWidth / 2)
    apHolder.y = -92 + 6

    local apList = apHolder.apList
    local extraX = 0
    local SPACING = 2
    local SPACING_AFTER_DIVIDER = 1

    apList.positionElements()

    -- In lua, gotoAndStop cannot be used on the same tick the element is created
    Ext.OnNextTick(function ()
        for i=0,#list.content_array-1,1 do
            local divider = list.content_array[i]
            if i ~= 0 and i ~= #list.content_array-1 and i % interval == 0 then
                divider.gotoAndStop(2)
                divider.y = -10
            else
                divider.gotoAndStop(1)
                divider.y = 0
            end
        end
    end)

    for i=0,#apList.content_array-1,1 do
        if i % interval == 0 and i > 0 then
            extraX = extraX + SPACING
        end

        local orb = apList.content_array[i]
        local divider = list.content_array[i]

        divider.x = divider.x + extraX
        if i % interval == 0 and i > 0 then
            extraX = extraX + SPACING + SPACING_AFTER_DIVIDER
        end
        orb.x = orb.x + extraX

        if i == #apList.content_array-1 then
            divider = list.content_array[i + 1]
            divider.x = divider.x + extraX
        end

    end

    -- Center the AP bar
    -- Length check is necessary as accessing negative indexes on a FlashArray appears to be bugged and returns a reference to the same array.
    local dividersAmount = #list.content_array
    if dividersAmount > 0 then
        local lastDivider = list.content_array[dividersAmount - 1]

        apHolder.x = -3 - ((lastDivider.x + lastDivider.width) / 2)
        apHolder.apGlow_mc.visible = false
        apHolder.apOverflow_mc.x = 503
        apHolder.apOverflow_mc.y = -7
        apHolder.apOverflow_mc.overflow_txt.x = -15
        apHolder.apOverflow_mc.visible = character and character.Stats.CurrentAP > 20

        local shadowList = apHolder.shadowList
        shadowList.positionElements()
        shadowList.x = -7
        shadowList.y = -13
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update dividers when max AP is set.
StatusConsole:RegisterInvokeListener("setMaxAp", function (_, _)
    Ext.OnNextTick(function ()
        Dividers.Update()
    end)
end, "After")

-- Update dividers when the interval setting changes.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == Dividers.Settings.DividerInterval and StatusConsole:IsVisible() then
        Dividers.Update()
    end
end)
