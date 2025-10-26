
---------------------------------------------
-- Highlights unavailable Source Infusions in tooltips while infusing or holding shift and can display current skill ability scores.
---------------------------------------------

local SourceInfusion = EpicEncounters.SourceInfusion
local Tooltip = Client.Tooltip
local Input = Client.Input

---@type Feature
local SourceInfusionTooltips = {
    TranslatedStrings = {
        Pattern_RequiresAbility = {
            Handle = "hdbbcab04g7b36g441egb0fbgbe739effaa33",
            Text = "(requires %d %s):",
            ContextDescription = "Pattern for ability requirements. Params are amount and skill school",
        },
        Pattern_Header = {
            Handle = "h68c538dbgf229g40b5ga826gb23b92c4f5c7",
            Text = "Source Infusions:",
            ContextDescription = "Pattern for text above Source Infusions in skills",
        },
        Label_CurrentAbilityScore = {
            Handle = "he6db6611g97f8g45d3g97afg280b3007ba8d",
            Text = " (current: %d %s)",
            ContextDescription = "Displayed after the 'Source Infusions:' part while holding shift. Params are amount, skill school name. Note the space at the start.",
        },
    },
}
Epip.RegisterFeature("TooltipAdjustments.SourceInfusions", SourceInfusionTooltips)
local TSK = SourceInfusionTooltips.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Appends ability scores and highlights unavailable Source Infusions within a skill tooltip.
---@param char EclCharacter
---@param skillID skill
---@param tooltip TooltipLib_FormattedTooltip
function SourceInfusionTooltips.ProcessTooltip(char, skillID, tooltip)
    local element = tooltip:GetFirstElement("SkillDescription")
    if not element then return end
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
    if not skill then return end -- Can happen with Actions.

    local school = skill.Ability
    if not school or school == "None" then return end -- Though it would be possible to create SIs for no-school skills, this feature would likely not be relevant to them.

    local fieldName = Stats.SKILL_ABILITY_TO_STATISTIC[school]
    if not fieldName then
        SourceInfusionTooltips:LogWarning("Unknown ability", school)
        return
    end
    local schoolName = Text.GetTranslatedString(Character.ABILITY_TSKHANDLES[fieldName], fieldName)
    local englishSchoolName = Character.ABILITY_ENGLISH_NAMES[fieldName]
    local score = char.Stats[fieldName]

    -- Highlight unmet infusion requirements.
    -- Only do this when infusing or holding shift.
    for _,req in pairs(SourceInfusion.INFUSION_ABILITY_REQUIREMENTS) do
        if score < req and (Input.IsShiftPressed() or Client.IsPreparingInfusion()) then
            local translatedReqStr = TSK.Pattern_RequiresAbility:Format(req, schoolName)
            local englishReqStr = TSK.Pattern_RequiresAbility:Format(req, englishSchoolName) -- We cannot know if the user is using an EE translation mod; thus we check for both the translated and untranslated patterns.
            local label = element.Label ---@type string

            local startPos, endPos = label:find(translatedReqStr, nil, true)
            if not startPos then
                startPos, endPos = label:find(englishReqStr, nil, true)
            end

            -- Make the label for unmet requirements red.
            if startPos and endPos then
                local requirementLabel = label:sub(startPos, endPos)
                element.Label = label:sub(1, startPos - 1) .. Text.Format(requirementLabel, {Color = Color.ILLEGAL_ACTION}) .. label:sub(endPos + 1)
            end
        end
    end

    -- Show current score next to SI text if shift is held.
    if Client.Input.IsShiftPressed() then
        ---@diagnostic disable-next-line: unused-local
        local startIndex, sourceInfusionLabelPosition = element.Label:find(TSK.Pattern_Header:GetString(), nil, true)
        if not sourceInfusionLabelPosition then
            ---@diagnostic disable-next-line: unused-local
            startIndex, sourceInfusionLabelPosition = element.Label:find(TSK.Pattern_Header.Text, nil, true)
        end
        if sourceInfusionLabelPosition then
            element.Label = element.Label:insert(TSK.Label_CurrentAbilityScore:Format({Size = 17, FormatArgs = {score, schoolName}}), sourceInfusionLabelPosition)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Modify skill tooltips if shift is being held.
Tooltip.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    SourceInfusionTooltips.ProcessTooltip(ev.Character, ev.SkillID, ev.Tooltip)
end)
