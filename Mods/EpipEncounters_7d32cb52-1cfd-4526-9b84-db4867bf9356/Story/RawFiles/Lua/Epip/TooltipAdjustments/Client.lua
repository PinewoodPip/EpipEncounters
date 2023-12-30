
---------------------------------------------
-- Numerous tooltip adjustments.
---------------------------------------------

local TooltipLib = Client.Tooltip
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_TooltipAdjustments : Feature
local TooltipAdjustments = {
    Name = "TooltipAdjustments",

    -- ===================================================
    --    This color was colored by the EE team, all thanks go to Ameranth and Elric!
    --===================================================
    ARTIFACT_RARITY_STRING = "<font color=\"#a34114\">%s</font>",
    -- other colors we tried:
    -- #c7a758
    -- #9c561e
    -- #9e4b06
    -- #9c561e -- PoE color, iirc?

    ---@type DataStructures_Set<pattern>
    WEAPON_ABILITY_PATTERNS = Set.Create({
        "Two%-Handed",
        "Single%-Handed",
        "Ranged",
        "Dual Wielding",
    }),
    LW_BOOST_PATTERN = "(From Lone Wolf: %+0%%)",
    STAT_ADJUSTMENT_PATTERN = "From Stat Adjustment: (%+?-?%d*%.?%d*)%%*",
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

function TooltipAdjustments.MergeStatAdjustments(tooltip)
    local count = 0
    local needsPercentageSign = false

    -- count all stat adjustment status displays, and remove them
    for i,v in pairs(tooltip.Data) do
        if (v.Type == "StatsPercentageBoost" or v.Type == "StatsTalentsBoost" or v.Type == "StatsPercentageMalus" or v.Type == "StatsTalentsMalus") and v.Label:match(TooltipAdjustments.STAT_ADJUSTMENT_PATTERN) then
            local amount, _ = v.Label:match(TooltipAdjustments.STAT_ADJUSTMENT_PATTERN)
            amount = tonumber(amount)

            if amount then
                count = count + amount
            end

            if v.Type == "StatsPercentageBoost" or v.Type == "StatsPercentageMalus" then
                needsPercentageSign = true
            end

            tooltip.Data[i] = nil
        end
    end

    -- insert new tooltip element with the total value
    if count ~= 0 then

        local baseString = "From Stat Adjustment: {PREFIX}%s%%"
        if not needsPercentageSign then
            baseString = "From Stat Adjustment: {PREFIX}%s" -- no percentage sign
        end

        local type = "StatsPercentageBoost"
        if count < 0 then
            type = "StatsTalentsMalus"
        end

        local prefix = "+"
        if count < 0 then prefix = "" end

        baseString = baseString:gsub("{PREFIX}", prefix)

        table.insert(tooltip.Data, {Type = type, Label = string.format(baseString, string.gsub(tostring(count), "%.0?+$", ""))})
    end
end

-- Change rarity color of Artifact items in tooltip
function TooltipAdjustments.ChangeArtifactRarityDisplay(item, tooltip, a, b)

    local isArtifact = item.DisplayName == "Protean Artifact" -- proteans don't have a special tag, so we just detect them by name
    local isArtifactRune = false

    -- UI elements to modify. The tooltip UI is modular and uses different elements for different parts of a tooltip. The extender tooltip API lets you change their data from a lua table.
    local itemNameElement = nil
    local rarityElement = nil
    local runeEffectElement = nil

    local tags = item:GetTags()

    -- artifact items have these tags.
    for i,v in pairs(tags) do
        if v == "AMER_UNI" then
            isArtifact = true
        elseif v == "AMER_UNI_RUNE" then
            isArtifactRune = true
        elseif v == "PIP_FAKE_ARTIFACT" then -- Normal items transmogged into artifacts. 
            isArtifact = false
            break
        end
    end

    -- stop here if item is not artifact nor focus - leaving the tooltip unchanged
    if not isArtifact and not isArtifactRune then return nil end

    for i,v in pairs(tooltip.Data) do
        if v.Type == "ItemName" then
            itemNameElement = v
        elseif v.Type == "ItemRarity" then 
            rarityElement = v 
        elseif v.Type == "RuneEffect" then
            runeEffectElement = v
        end
    end

    local rarityName = "Artifact"
    if isArtifactRune then
        rarityName = "Artifact Focus"
    end
    local rarityString = TooltipAdjustments.ARTIFACT_RARITY_STRING:format(rarityName) -- add the special Artifact color

    -- Change item name
    itemNameElement.Label = TooltipAdjustments.ARTIFACT_RARITY_STRING:format(itemNameElement.Label:match(".*>(.*)<.*"):gsub("Unique", "Artifact")) -- captures the Artifact's name in the tooltip. Replaces unidentified "Unique" with "Artifact"

    -- Change rarity name
    -- Runes need this element added; they do not have it normally
    if not rarityElement then
        -- Does not currently work. Adding this particular element causes an error in Flash.
        -- tooltip:AppendElement({Type = "ItemRarity", Label = rarityString})
    else
        rarityElement.Label = rarityString
    end

    -- Add "Cannot equip" to empty rune effects
    if runeEffectElement then
        local props = {"Rune1", "Rune2", "Rune3"}
        for i,v in pairs(props) do
            if runeEffectElement[v] == "" then
                runeEffectElement[v] = "<font color='7b8087'>Cannot equip.</font>" -- sadly, color here seems to be overwritten somehow.
            end
        end
    end
end

local function OnStatusGetDescription(event)
    local status = event.Status
    local char = event.Owner
    local source = event.StatusSource
    local params = event.Params
    local mainParam = params["1"]

    if mainParam ~= "Damage" then return nil end
    
    local skillName = Data.Game.DAMAGING_STATUS_SKILLS[status.Name]
    if not skillName then 
        TooltipAdjustments:LogWarning("Missing status damage skill for status " .. status.Name)
        return nil 
    end

    -- use torturer skills instead, when source char has the talent
    local torturerSkillOverrides = Data.Game.TORTURER_SKILL_OVERRIDES
    if torturerSkillOverrides[skillName] and source and source.TALENT_Torturer then
        skillName = torturerSkillOverrides[skillName]
    end

    local skill = Ext.Stats.Get(skillName)
    local level = char.Level -- if no source exists, char is used instead
    if source then level = source.Level end

    local damage = GetSkillDamage(skill, source, true, false, {0, 0, 0}, {0, 0, 0}, level, true, nil, nil)

    local newTable = {}
    local newString = ""

    for i,d in pairs(damage:ToTable()) do
        local damageRange = skill["Damage Range"] -- +/- 50% of the damage multiplier
        local minDmg = d.Amount * (1 - ((damageRange/2) / 100))
        local maxDmg = d.Amount * (1 + ((damageRange/2) / 100))

        minDmg = math.max(minDmg, 1)
        minDmg = math.floor(minDmg)

        maxDmg = math.max(maxDmg, 1)
        maxDmg = math.floor(maxDmg)

        local color = ""
        local dName = ""
        local damageType = Client.UI.Data.DAMAGE_TYPES[d.DamageType]
        if damageType then 
            color = damageType.Color
            dName = damageType.Suffix
        else
            TooltipAdjustments:LogWarning("Missing damage type " .. d.DamageType)
        end

        local dmgString = string.format("<font color='#%s'>%s-%s %s</font>", color, minDmg, maxDmg, dName)

        table.insert(newTable, {Amount = dmgString, DamageType = d.DamageType})

        newString = newString .. dmgString
        if i ~= #damage:ToTable() then
            newString = newString .. " + "
        end
    end

    event.Description = newString
end

-- Replace "(before damage modifiers)" in status tooltips that we're fixing to show real damage.
local function OnStatusTooltipRender(_, status, tooltip)
    if Data.Game.DAMAGING_STATUS_SKILLS[status.StatusId] then
        for _,v in pairs(tooltip.Data) do
            v.Label = v.Label:gsub(" %(before damage modifiers%)", "")
            v.Label = v.Label:gsub(" %(before modifiers%)", "")
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
    TooltipAdjustments.MergeStatAdjustments(tooltip)
    TooltipAdjustments.RemoveDeprecatedLWBoosts(char, stat, tooltip)
    TooltipAdjustments.FixSheetDamageTooltip(char, stat, tooltip)
end

local function OnItemTooltipRender(item, tooltip)
    if not TooltipAdjustments:IsEnabled() then return nil end
    -- TooltipAdjustments.ShowAbilityScoresForSI(nil, skill, tooltip) -- TODO
    TooltipAdjustments.ChangeArtifactRarityDisplay(item, tooltip)

    -- TooltipAdjustments.TestElements(item, tooltip)
end

Ext.Events.StatusGetDescriptionParam:Subscribe(OnStatusGetDescription)
Ext.Events.SessionLoaded:Subscribe(function()
    Game.Tooltip.RegisterListener("Stat", nil, OnGenericStatTooltipRender)
    Game.Tooltip.RegisterListener("Ability", nil, OnGenericStatTooltipRender)
    Game.Tooltip.RegisterListener("Item", nil, OnItemTooltipRender)
    Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltipRender)
end)

-- Align tooltips to the top of the screen.
Ext.RegisterUITypeInvokeListener(44, "addFormattedTooltip", function(ui)
    if TooltipAdjustments:IsEnabled() then
        ui:ExternalInterfaceCall("keepUIinScreen", true)
    end
end)