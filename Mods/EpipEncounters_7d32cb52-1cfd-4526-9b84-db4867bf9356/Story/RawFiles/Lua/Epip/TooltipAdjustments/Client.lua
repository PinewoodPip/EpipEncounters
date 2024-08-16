
---------------------------------------------
-- Numerous tooltip adjustments.
---------------------------------------------

local TooltipLib = Client.Tooltip
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_TooltipAdjustments : Feature
local TooltipAdjustments = {
    Name = "TooltipAdjustments",

    ---@type DataStructures_Set<pattern>
    WEAPON_ABILITY_PATTERNS = Set.Create({
        "Two%-Handed",
        "Single%-Handed",
        "Ranged",
        "Dual Wielding",
    }),
    LW_BOOST_PATTERN = "(From Lone Wolf: %+0%%)",
    BOOST_AP_COST_TSKHANDLE = "h228e474ag396ag4dc9g837egd8d05d15bbb2", -- "AP Cost", used in boost tooltips

    Settings = {
        DamageTypeDeltamods = {
            Type = "Boolean",
            Name = "Display +Elemental damage deltamods",
            Description = Text.Format("If enabled, deltamods that add elemental damage will display in item tooltips.<br>%s", {
                FormatArgs = {
                    {Text = "Applies only to EE deltamods.", Color = Color.LARIAN.YELLOW},
                },
            }),
            DefaultValue = true,
        },
        SurfaceTooltips = {
            Type = "Boolean",
            Name = "Show surface tooltip ownership and scaling",
            Description = "If enabled, surface tooltips will show the owner of the surface, as well as hints regarding their damage scaling.",
            DefaultValue = true,
        },
        WeaponRangeDeltamods = {
            Type = "Boolean",
            Name = "Show weapon range deltamods",
            Description = "If enabled, weapons with deltamods that scale their range will be displayed like regular deltamods.",
            DefaultValue = true,
        }
    },

    TranslatedStrings = {
        Name = {
           Handle = "haabd6906gee2dg4b39ga339gf5cdf1a2ee8b",
           Text = "Tooltip Adjustments",
           ContextDescription = "Feature name",
        },
        Override_APCosts = {
           Handle = "hc28e1c17g7862g402bgabc7gaab851087be4",
           Text = "AP Costs",
           ContextDescription = "Override for Larian string 'AP Cost' to make it plural, used in tooltips. Original handle h228e474ag396ag4dc9g837egd8d05d15bbb2",
        },
    },
}
Epip.RegisterFeature("TooltipAdjustments", TooltipAdjustments)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_GetSurfaceData : NetLib_Message_Character
---@field Position table {1:integer, 2:integer, 3:integer}

---@class EPIPENCOUNTERS_ReturnSurfaceData : NetLib_Message
---@field GroundSurfaceOwnerNetID NetId
---@field CloudSurfaceOwnerNetID NetId

---------------------------------------------
-- METHODS
---------------------------------------------

---@param setting SettingsLib_Setting_Boolean
---@return boolean
function TooltipAdjustments.IsAdjustmentEnabled(setting)
    return TooltipAdjustments:IsEnabled() and TooltipAdjustments:GetSettingValue(setting) == true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Fix the mess that is the character sheet damage tooltip.
function TooltipAdjustments.FixSheetDamageTooltip(_, _, tooltip)
    local header = tooltip:GetElement("StatName")

    if not header or header.Label ~= "Damage" then
        return nil
    end

    -- RemoveElement() crashes for this, for some reason.
    for i,v in pairs(tooltip.Data) do
        if v.Label == "" or v.Label:find("From Gear: ") then
            tooltip.Data[i] = nil

        elseif v.Type == "StatsPercentageBoost" then
            for ability in TooltipAdjustments.WEAPON_ABILITY_PATTERNS:Iterator() do
                if v.Label:match("(From " .. ability .. ": )") then
                    local amount = v.Label:match("From " .. ability .. ": (.*)%%")

                    v.Label = string.format("From %s: %sx", ability:gsub("%%", ""), 1 + amount/100)

                    break
                end
            end
        end
    end
end

-- Remove misleading "+0% from LW" maluses.
function TooltipAdjustments.RemoveDeprecatedLWBoosts(_, _, tooltip)
    for _,v in pairs(tooltip:GetElements("StatsPercentageMalus")) do
        if v.Label:match(TooltipAdjustments.LW_BOOST_PATTERN) then
            tooltip:RemoveElement(v)
        end
    end
end


-- Make +AP Costs red, since it's a negative effect.
Game.Tooltip.RegisterListener("Status", nil, function(_, _, tooltip)
    local statusBonuses = tooltip:GetElements("StatusBonus")
    local statusMaluses = tooltip:GetElements("StatusMalus")

    if statusBonuses and statusMaluses then
        for _,malus in ipairs(statusMaluses) do
            table.insert(statusBonuses, malus)
        end
    end

    if statusBonuses then
        local vanillaAPCostLabel = Text.GetTranslatedString(TooltipAdjustments.BOOST_AP_COST_TSKHANDLE, "AP Cost")
        for _,entry in ipairs(statusBonuses) do
            local amount = entry.Label:match(vanillaAPCostLabel .. ": (%+?%-?%d+)")
            if amount then
                amount = tonumber(amount)
                local color = Color.TOOLTIPS.MALUS
                local sign = "+"
                entry.Type = "StatusDescription" -- TODO should we append instead?

                if amount < 0 then
                    color = Color.TOOLTIPS.BONUS
                    sign = ""
                end

                entry.Label = Text.Format("%s: %s%s", {
                    Color = color,
                    FormatArgs = {
                        TooltipAdjustments.TranslatedStrings.Override_APCosts:GetString(),
                        sign,
                        amount
                    }
                })
            end
        end
    end
end)

-- Show skill IDs.
TooltipLib.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    if Epip.IsDeveloperMode() then
        ev.Tooltip:InsertElement({
            Type = "Engraving",
            Label = Text.Format("StatsId: %s", {
                FormatArgs = {ev.SkillID},
                Color = Color.LARIAN.GREEN,
            })
        })
    end
end)

-- Fix the erroneous GB5 penalty tooltip icons.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    local desc = tooltip:GetElement("StatusDescription") or {Type = "StatusDescription", Label = ""}

    for _,element in ipairs(tooltip.Data) do
        if element.Type == "StatusMalus" then
            desc.Label = Text.Format("%s\n%s", {
                FormatArgs = {
                    desc.Label,
                    Text.Format(element.Label, {Color = Color.TOOLTIPS.MALUS})
                }
            })
        end
    end

    tooltip:RemoveElements("StatusMalus")
end)

-- Show ACTIVE_DEFENSE charges.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    status = status ---@type EclStatusActiveDefense

    if status.StatusType == "ACTIVE_DEFENSE" then
        local stat = Stats.Get("StatsLib_StatsEntry_StatusData", status.StatusId)
        local maxCharges = stat.Charges
        local charges = status.Charges

        if charges > 0 then
            local text = Text.Format("Charges: %s/%s", {
                FormatArgs = {charges, maxCharges},
                FontType = Text.FONTS.ITALIC,
                Color = Color.LARIAN.LIGHT_GRAY,
            })

            -- Special case for statuses with "infinite" charges.
            if charges >= 999 then
                text = Text.Format("Infinite Charges", {
                    FontType = Text.FONTS.ITALIC,
                    Color = Color.LARIAN.LIGHT_GRAY,
                })
            end

            local elements = tooltip:GetElements("StatusDescription")
            local element = elements[#elements] -- Append to the last description (usually the duration text)

            if not element then
                tooltip:AppendElement({
                    Type = "StatusDescription",
                    Label = text,
                })
            else
                element.Label = element.Label .. "<br>" .. text
            end
        end
    end
end)

-- Show talent IDs in Talent tooltips.
Game.Tooltip.RegisterListener("Talent", nil, function(_, talentID, tooltip)
    if Epip.IsDeveloperMode() then
        table.insert(tooltip.Data, 1, {Type = "Engraving", Label = Text.Format("ID: %s", {FormatArgs = {talentID}, Color = Color.GREEN})})
    end
end)

function TooltipAdjustments.TestElements(item, tooltip)
    local LABEL_ELEMENTS = {
        "ItemName",
        "ItemDescription",
        "ItemRarity",
        "WeaponDamagePenalty",
        "SkillName",
        "SkillIcon",
        "SkillDescription",
        "Reflection",
        "SkillAlreadyLearned",
        "SkillOnCooldown",
        "SkillAlreadyUsed",
        "ExtraProperties",
        "Flags",
        "CanBackstab",
        "ArmorSlotType",
        "NeedsIdentifyLevel",
        "PickpocketInfo",
        "Engraving",
        "ContainerIsLocked",
        "SkillTier",
        "ConsumableEffectUnknown",
        "AbilityTitle",
        "TalentTitle",
        "WarningText",
        "StatName",
        "StatsDescription",
    }
    local LABEL_VALUE_ELEMENTS = {
        "ItemLevel",
        -- "OtherStatBoost",
        "ConsumableDuration",
        "ConsumablePermanentDuration",
        "ConsumableEffect",
        "WeaponCritMultiplier",
        "WeaponCritChance",
        "WeaponRange",
        "AccuracyBoost",
        "DodgeBoost",
        "ArmorValue",
        "Blocking",
        "PriceToIdentify",
        "PriceToRepair",
        "SkillRange",
        "SkillExplodeRadius",
        "SkillCanPierce",
        "SkillCanFork",
        "SkillStrikeCount",
        "SkillProjectileCount",
        "SkillCleansesStatus",
        "SkillMultiStrikeAttacks",
        "SkillWallDistance",
        "SkillPathDistance",
        "SkillPathSurface",
        "SkillHealAmount",
        "RuneSlot",
        "EmptyRuneSlot",
        "StatsDescriptionBoost",
    }
    tooltip.Data = {
        -- {
        --     Type = "OtherStatBoost",
        --     Value = "OtherStatBoost",
        --     -- Unused = "",
        -- }
        {
            Type = "ItemUseAPCost",
            Value = 1,
            Warning = "ItemUseAPCost",
            RequirementMet = true,
        },
        {
            Type = "ShowSkillIcon"
        }
    }

    for i,id in pairs(LABEL_ELEMENTS) do
        table.insert(tooltip.Data, {
            Type = id,
            Label = id,
        })
    end

    for i,id in pairs(LABEL_VALUE_ELEMENTS) do
        table.insert(tooltip.Data, {
            Type = id,
            Label = id,
            Value = 1,
        })
    end
end

local function OnGenericStatTooltipRender(char, stat, tooltip)
    if not tooltip or not TooltipAdjustments:IsEnabled() then return nil end -- TODO why does this happen with item examine tooltips?
    TooltipAdjustments.RemoveDeprecatedLWBoosts(char, stat, tooltip)
    TooltipAdjustments.FixSheetDamageTooltip(char, stat, tooltip)
end

Ext.Events.SessionLoaded:Subscribe(function()
    Game.Tooltip.RegisterListener("Stat", nil, OnGenericStatTooltipRender)
    Game.Tooltip.RegisterListener("Ability", nil, OnGenericStatTooltipRender)
end)

-- Align tooltips to the top of the screen.
Ext.RegisterUITypeInvokeListener(44, "addFormattedTooltip", function(ui)
    if TooltipAdjustments:IsEnabled() then
        ui:ExternalInterfaceCall("keepUIinScreen", true)
    end
end)
