
---------------------------------------------
-- Numerous tooltip adjustments.
---------------------------------------------

Epip.Features.TooltipAdjustments = {
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
}
local TooltipAdjustments = Epip.Features.TooltipAdjustments
setmetatable(TooltipAdjustments, {__index = _Feature})

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Fix the mess that is the character sheet damage tooltip.
function TooltipAdjustments.FixSheetDamageTooltip(char, stat, tooltip)
    local header = tooltip:GetElement("StatName")

    if not header or header.Label ~= "Damage" then
        return nil
    end

    -- RemoveElement() crashes for this, for some reason.
    for i,v in pairs(tooltip.Data) do
        if v.Label == "" or v.Label:find("From Gear: ") then
            tooltip.Data[i] = nil

        elseif v.Type == "StatsPercentageBoost" then
            for ability,z in pairs(Data.Patterns.WeaponAbilityPatterns) do
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
function TooltipAdjustments.RemoveDeprecatedLWBoosts(char, stat, tooltip)
    for i,v in pairs(tooltip:GetElements("StatsPercentageMalus")) do

        if v.Label:match(Data.Patterns.LW_BOOST_PATTERN) then
            tooltip:RemoveElement(v)
        end
    end
end

function TooltipAdjustments.MergeStatAdjustments(tooltip)
    local count = 0
    local needsPercentageSign = false

    -- count all stat adjustment status displays, and remove them
    for i,v in pairs(tooltip.Data) do
        if (v.Type == "StatsPercentageBoost" or v.Type == "StatsTalentsBoost" or v.Type == "StatsPercentageMalus" or v.Type == "StatsTalentsMalus") and v.Label:match(Data.Patterns.STAT_ADJUSTMENT_PATTERN) then
            local amount, _ = v.Label:match(Data.Patterns.STAT_ADJUSTMENT_PATTERN)
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

-- Show a warning in tooltip for Masterworked items
function TooltipAdjustments.AddDeltamodsHandledWarning(item, tooltip)
    if not item.Stats then return nil end

    local tags = item:GetTags()
    local isMasterworked = false

    for _,v in pairs(item:GetDeltaMods()) do
        if Data.Game.MASTERWORK_HANDLED_TAGS[v] then
            isMasterworked = true
        end
    end

    if not isMasterworked then return nil end

    table.insert(tooltip.Data, {Label = "Masterworked", Type = "StatsTalentsMalus"})
end

-- todo split up
function TooltipAdjustments.ShowAbilityScoresForSI(char, skill, tooltip)
    char = char or Client.GetCharacter()
    local element = tooltip:GetElement("SkillDescription")
    if not element or not skill then return nil end

    local school = Ext.Stats.Get(skill)
    if not school then return nil end
    school = school["Ability"]
    if not school or school == "None" then return nil end

    school = Data.Game.StatObjectAbilities[school]
    local schoolName = Data.Game.ABILITIES[school]

    local score = char.Stats[school]

    -- highlight unmet infusion requirements.
    -- Only do this when infusing or holding shift.
    for _,req in pairs(Data.Game.INFUSION_TIERS) do
        if score < req and (Client.Input.IsHoldingModifierKey() or Client.IsPreparingInfusion()) then
            local reqStr = string.format("(requires %d %s):", req, schoolName)
            local startPos, endPos = element.Label:find(Text.EscapePatternCharacters(reqStr))

            if startPos and endPos then
                element.Label = element.Label:insert("</font>", endPos)
                element.Label = element.Label:insert(string.format("<font color='%s'>", Data.Colors.IllegalAction), startPos - 1)

                -- local text = element.Label:sub(1, startPost)
                -- Ext.Print(reqStr)
                -- text = text .. element.Label:sub(endPos, #element.Label)
                -- Ext.Print(text)
            end
        end
    end

    -- Show current score next to SI text
    if not Client.Input.IsHoldingModifierKey() then return nil end

    local _, position = element.Label:find("Source Infusions:")

    if not position then return nil end

    -- element.Label = element.Label:insert(string.format("<font size='17'><br>Your score: %d</font>", score), position)
    element.Label = element.Label:insert(string.format(" <font size='17'>(current: %d %s)</font>", score, schoolName), position)
end

-- Make normal tooltips appear instantly, without the 0.5s delay.
-- This is not perfect; it will not work if you open a new tooltip while one is already existing. But that only happens in situations where you move the mosue very fast,
-- so it's probably fine.
Ext.RegisterUINameInvokeListener("addTooltip", function(ui, method, str, offsetx, offsety, delay, param5, param6)
    ui:GetRoot().addTooltip(str, offsetx, offsety, 0, param5, param6)
end, "After")

-- Fix tooltips when char has increased AP costs (ex. Slowed III in old Epip)
function TooltipAdjustments.FixTooltipAPCosts(tooltip)
    local char = Client.GetCharacter()
    if not char then return nil end
    
    local increasedActionCosts = 0

    for i,v in pairs(char.Stats.DynamicStats) do
        increasedActionCosts = increasedActionCosts + v.APCostBoost
    end
    
    for i,v in pairs(tooltip.Data) do
        if (v.Type == "SkillAPCost" or v.Type == "ItemUseAPCost") and v.Value > 0 then -- 0 AP skills are not affected by AP cost boost
            v.Value = v.Value + increasedActionCosts
            break
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
function OnStatusTooltipRender(char, status, tooltip)
    if Data.Game.DAMAGING_STATUS_SKILLS[status.StatusId] then
        for i,v in pairs(tooltip.Data) do
            v.Label = v.Label:gsub(" %(before damage modifiers%)", "")
            v.Label = v.Label:gsub(" %(before modifiers%)", "")
        end
    end
end

-- Show skill IDs.
Game.Tooltip.RegisterListener("Skill", nil, function(char, skill, tooltip)
    if Ext.Debug.IsDeveloperMode() then
        tooltip:AppendElement({
            Type = "Engraving",
            Label = Text.Format("StatsId: %s", {
                FormatArgs = {skill},
                Color = Color.COLORS.LARIAN.GREEN,
            })
        })
    end
end)

-- Show status source.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    local source = Character.Get(status.StatusSourceHandle)

    if source then
        local text = Text.Format("Applied by %s", {
            FormatArgs = {source.DisplayName},
            FontType = Text.FONTS.ITALIC,
            Color = Color.COLORS.LARIAN.LIGHT_GRAY,
        })
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
end)

-- Show status object information in dev mode.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    if Ext.Debug.IsDeveloperMode() then
        tooltip:AppendElement({
            Type = "Engraving",
            Label = Text.Format("StatusId: %s<br>StatusType: %s", {
                FormatArgs = {
                    status.StatusId,
                    status.StatusType,
                },
                Color = Color.COLORS.LARIAN.GREEN,
            })
        })
    end
end)

function TooltipAdjustments.AddBaseDeltamodTierDisplay(item, tooltip)
    local elementsToTry = {
        -- "WarningText", -- red X
        "AbilityTitle", -- header of tooltip
        -- "StatsGearBoostNormal", -- does not work
        -- "StatsBaseValue",
        -- "Sulfur", -- does not work on items
        -- "StatusImmunity", -- yellow text, bottom
        -- "TagDescription", -- white text
        -- "SurfaceDescription",
        -- "ExtraProperties", -- blue text with star
        -- "WeaponDamagePenalty", -- nothing
        -- "NeedsIdentifyLevel", -- needs identif overlay
        "ArmorSlotType", -- slot type, above dmg/armors
        -- "PriceToIdentify", -- white text
        -- "PriceToRepair", -- white text
        -- "PickpocketInfo", -- white text
        -- "Tags", -- tag small icon, bottom
        -- "Engraving", -- separate text tab at top
        -- "Reflection",
        -- "StatName", -- nothing?
        "StatsPointValue",
        -- "StatMEMSlot", -- bookmark, top middle panel
        -- "StatusBonus", -- green text bottom?
    }

    if not item.Stats then return nil end

    local tier = 0
    local itemType = Item.GetItemSlot(item)
    local tiers = Data.Game.EQUIPMENT_BASE_BOOST_TIERS

    -- use subtypes for armor only
    if itemType ~= "Weapon" and Data.Game.SLOTS_WITH_SUBTYPES[itemType] then
        itemType = Item.GetEquipmentSubtype(item)
    end

    -- happens with the starting tattered robes
    if not tiers[itemType] then return nil end

    -- find the "tier" of the item based on boosts
    local boost = nil
    for i,v in pairs(item.Stats.DynamicStats) do

        local boostName = v.ObjectInstanceName

        if tiers[itemType].Boosts[boostName] ~= nil then
            tier = tiers[itemType].Boosts[boostName]
            break
        end
    end

    -- do nothing for items with no generated stats
    if tier == 0 then return nil end

    local slotType = tooltip:GetElement("ArmorSlotType")
    local tierDisplay = 0
    local totalTiers = tiers[itemType].Tiers
    local tierCutoff = math.max(0, totalTiers - 10)

    if tier >= tierCutoff then -- 55% to 100%, 10 tiers
        tierDisplay = ((tier - tierCutoff) * 0.05) + 0.5
    else -- 20% to 50%, 4 tiers
        tierDisplay = (tier * 0.1) + 0.1
    end

    tierDisplay = tierDisplay * 100

    tierDisplay = math.floor(tierDisplay)
    tierDisplay = math.max(0, tierDisplay)

    if tierDisplay == 100 then
        tierDisplay = "Max Quality" -- fancy display for fancy items!
    else
        tierDisplay = string.format("Quality %s%%", tierDisplay)
    end

    if slotType then
        slotType.Label = slotType.Label .. string.format("  -  %s", tierDisplay)
        slotType.Label = slotType.Label:gsub("Two%-Handed", "2Handed")
        slotType.Label = slotType.Label:gsub("One%-Handed", "1Handed")
    end
end

-- The inconsistencies are killing me
local SET_DELTAMOD_PATTERN = '(Set :)<font size="17"> '
local SET_ALL_RES_PATTERN = '(Set )+[0-9]* to all'
local SET_LIFESTEAL_PATTERN = '(Set )+[0-9]*%% Lifesteal'

-- Remove the word "Set" from scripted deltamods.
function TooltipAdjustments.RemoveSetDeltamodsText(item, tooltip)

    local elements = tooltip:GetElements("ExtraProperties")

    for i,v in pairs(elements) do
        local match = v.Label:match(SET_DELTAMOD_PATTERN) or v.Label:match(SET_ALL_RES_PATTERN) or v.Label:match(SET_LIFESTEAL_PATTERN)
        
        if match then
            v.Label = v.Label:gsub(match, '')

            -- remove trailing dot
            -- local trailingDotMatch = v.Label:match("(.*)%.<font>")
            
            -- if trailingDotMatch then
            --     v.Label = trailingDotMatch
            -- end
            
        end
    end
end

---@param item EclItem
---@param tooltip TooltipData
function TooltipAdjustments.ShowDamageBoost(item, tooltip)
    if not tooltip:IsIdentified() then return nil end
    local dmgType, amount

    for i,deltamodID in ipairs(item:GetDeltaMods()) do
        dmgType, amount = deltamodID:match('^Boost_Weapon_Damage_(.+)_(%d+)$')

        if dmgType then
            break
        end
    end

    if dmgType then
        tooltip:AppendElement({
            Type = "ExtraProperties",
            -- Label = Text.Format("%s Damage (Tier %s/%s)", {
            --     FormatArgs = {
            --         dmgType, Text.RemoveTrailingZeros(tonumber(amount) / 5), Text.RemoveTrailingZeros(35 / 5),
            --     },
            -- })
            Label = Text.Format("+%s%% Weapon %s Damage", {
                FormatArgs = {
                    amount, dmgType
                }
            })
        })
    end
end

-- Show range deltamods as an ExtraProperty
local WEAPON_RANGE_DELTAMOD_PATTERN = "Boost_Weapon_Range_(.*)$"
function TooltipAdjustments.AddRangeDeltamodDisplay(item, tooltip)
    if not tooltip:IsIdentified() then return nil end

    local weaponRangeBoost = nil;

    for i,v in pairs(item:GetDeltaMods()) do
        local match = v:match(WEAPON_RANGE_DELTAMOD_PATTERN)

        if match then
            weaponRangeBoost = match
            break
        end
    end

    if not weaponRangeBoost then return nil end

    -- weapon range is in centimeters within stats
    local weaponBoostString = Text.RemoveTrailingZeros(weaponRangeBoost / 100)

    tooltip:AppendElement({
        Type = "ExtraProperties",
        Label = string.format("+%sm Weapon Range", weaponBoostString) 
    })

    local element = tooltip:GetElement("WeaponRange")
    if not element then return nil end

    local amount = element.Value:gsub("m", "")
    amount = tonumber(amount)
    amount = amount - (weaponRangeBoost / 100)

    element.Value = string.format("%sm + %sm", Text.RemoveTrailingZeros(amount), weaponBoostString)
end

-- Replace damage paramater with the damage multiplier if the modifier key is being held.
function TooltipAdjustments.TranslateSkillMultipliers(event)
    local params = event.Params
    local skill = event.Skill

    if params["1"] ~= "Damage" or not Client.Input.IsHoldingModifierKey() then return nil end

    local isWeapon = skill["UseWeaponDamage"] == "Yes"

    local type = skill["DamageType"]
    if isWeapon then -- weapons not fully supported.
        type = {Name = "weapon-based damage", Color = "#a8a8a8"}
    else
        type = Data.Game.DamageTypes[type]
    end

    event.Description = string.format("<font color='%s'>%s%% %s</font>", type.Color, skill["Damage Multiplier"], type.Name)
end

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

local function OnSkillGetDescription(event)    
    TooltipAdjustments.TranslateSkillMultipliers(event)
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
    TooltipAdjustments.FixTooltipAPCosts(tooltip)
    TooltipAdjustments.ChangeArtifactRarityDisplay(item, tooltip)
    TooltipAdjustments.AddBaseDeltamodTierDisplay(item, tooltip)
    TooltipAdjustments.AddDeltamodsHandledWarning(item, tooltip)
    TooltipAdjustments.RemoveSetDeltamodsText(item, tooltip)
    TooltipAdjustments.AddRangeDeltamodDisplay(item, tooltip)
    TooltipAdjustments.ShowDamageBoost(item, tooltip)

    -- TooltipAdjustments.TestElements(item, tooltip)
end

local function OnSkillAPTooltipRender(char, skill, tooltip)
    if not TooltipAdjustments:IsEnabled() then return nil end
    TooltipAdjustments.ShowAbilityScoresForSI(char, skill, tooltip)
    TooltipAdjustments.FixTooltipAPCosts(tooltip)
end

Ext.Events.StatusGetDescriptionParam:Subscribe(OnStatusGetDescription)
Ext.Events.SkillGetDescriptionParam:Subscribe(OnSkillGetDescription)
Ext.Events.SessionLoaded:Subscribe(function()
    Game.Tooltip.RegisterListener("Stat", nil, OnGenericStatTooltipRender)
    Game.Tooltip.RegisterListener("Ability", nil, OnGenericStatTooltipRender)
    Game.Tooltip.RegisterListener("Skill", nil, OnSkillAPTooltipRender)
    Game.Tooltip.RegisterListener("Item", nil, OnItemTooltipRender)
    Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltipRender)
end)

-- Align tooltips to the top of the screen.
Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.tooltip, "addFormattedTooltip", function(ui, _)
    if not TooltipAdjustments:IsEnabled() then return nil end
    ui:ExternalInterfaceCall("keepUIinScreen", true)
end, "After")