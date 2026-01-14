
---------------------------------------------
-- Various adjustments for Character Sheet tooltips.
---------------------------------------------

local Tooltip = Client.Tooltip
local CommonStrings = Text.CommonStrings

---@type Feature
local CharacterSheetTooltips = {
    TranslatedStrings = {
        Label_DamageSource = {
            Handle = "h86005331g3694g4492gab07geb96283d7c2a",
            Text = "From %s:",
            ContextDescription = [[Tooltip for weapon damage source; ex. "From Mainhand:"]],
        },
    }
}
Epip.RegisterFeature("Features.TooltipAdjustments.CharacterSheet", CharacterSheetTooltips)
local TSK = CharacterSheetTooltips.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Appends labels for weapon damage ranges to a stat tooltip.
---@param tooltip TooltipLib_FormattedTooltip **Will be mutated**.
---@param char EclCharacter
---@param slot "Weapon"|"Shield"
---@param weapon CDivinityStats_Item
function CharacterSheetTooltips.AddWeaponDamageRanges(tooltip, char, slot, weapon)
    local weaponDamage = Game.Math.CalculateWeaponScaledDamageRanges(char.Stats, weapon)
    local damageElement = tooltip:GetFirstElement("StatsDescription")

    -- Append slot header
    local slotTSK = slot == "Weapon" and CommonStrings.Mainhand or CommonStrings.Offhand
    damageElement.Label = damageElement.Label .. "\n\n" .. TSK.Label_DamageSource:Format( slotTSK:GetString())

    -- Append damage labels
    for damageType,range in pairs(weaponDamage) do
        local damageTypeData = Damage.GetDamageTypeDefinition(damageType)
        local damageTypeName = Text.GetTranslatedString(damageTypeData.TooltipNameHandle)
        local damageLabel = Text.Format("<img src='Icon_BulletPoint'> %d - %d %s", {
            FormatArgs = {range.Min, range.Max, damageTypeName},
            Color = damageTypeData.Color,
        })
        damageElement.Label = damageElement.Label .. "\n" .. damageLabel
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Remove "From X: +0%" lines, common in EE (ex. damage tooltip with Guerrilla).
Tooltip.Hooks.RenderStatTooltip:Subscribe(function (ev)
    local maluses = ev.Tooltip:GetElements("StatsPercentageMalus")
    for i=#maluses,1,-1 do
        local malus = maluses[i]
        if malus.Label:find("+0%%") then
            ev.Tooltip:RemoveElement(malus)
        end
    end
end)

-- Show breakdown of basic attack damage types in the "Damage" stat tooltip.
Tooltip.Hooks.RenderStatTooltip:Subscribe(function (ev)
    if ev.StatID ~= Tooltip.STAT_IDS.DAMAGE then return end

    local char = Client.GetCharacter()
    local weapon = char:GetItemObjectBySlot("Weapon")
    local offhand = char:GetItemObjectBySlot("Shield")
    if weapon then
        CharacterSheetTooltips.AddWeaponDamageRanges(ev.Tooltip, char, "Weapon", weapon.Stats)
    end
    if offhand and Character.CanAttackWithOffhand(char) then
        CharacterSheetTooltips.AddWeaponDamageRanges(ev.Tooltip, char, "Shield", offhand.Stats)
    end
end)
