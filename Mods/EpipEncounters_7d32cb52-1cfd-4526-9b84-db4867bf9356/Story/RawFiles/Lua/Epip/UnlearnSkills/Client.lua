
local SkillBook = Client.UI.Skills
local MessageBox = Client.UI.MessageBox

---@class Feature_UnlearnSkills
local Unlearn = Epip.GetFeature("UnlearnSkills")
local REASONS = Unlearn.CANNOT_UNLEARN_REASONS
local TSK = Unlearn.TranslatedStrings

---@type table<Features.UnlearnSkills.CannotUnlearnReason, TextLib_TranslatedString>
Unlearn.CANNOT_UNLEARN_REASON_TO_TSK = {
    [REASONS.SKILL_DOESNT_EXIST] = TSK.CannotUnlearnReason_SkillDoesntExist,
    [REASONS.GRANTED_BY_EXTERNAL_SOURCE] = TSK.CannotUnlearnReason_ExternalSource,
    [REASONS.ZERO_MEMORY] = TSK.CannotUnlearnReason_ZeroMemory,
    [REASONS.IN_COMBAT] = TSK.CannotUnlearnReason_InCombat,
    [REASONS.BLACKLISTED] = TSK.CannotUnlearnReason_Blacklisted,
    [REASONS.EE_SPECIAL_NEXUS_MEDITATE] = TSK.CannotUnlearnReason_EE_NexusMeditate,
    [REASONS.EE_SPECIAL_SOURCE_INFUSE] = TSK.CannotUnlearnReason_EE_SourceInfuse,
    [REASONS.INNATE] = TSK.CannotUnlearnReason_Innate,
    [REASONS.NOT_IN_SKILLMANAGER] = TSK.CannotUnlearnReason_NotInSkillManager,
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Force-unlearns a skill, bypassing all checks.
---@param char EclCharacter? Defaults to client character.
---@param skillID skill
function Unlearn.UnlearnSkill(char, skillID)
    char = char or Client.GetCharacter()

    Net.PostToServer("EPIPENCOUNTERS_UnlearnSkill", {
        CharacterNetID = char.NetID,
        SkillID = skillID,
    })

    -- Refresh the UI. The memorized spell window does not update if a skill is unlearnt while the UI is open.
    if SkillBook:IsVisible() then
        SkillBook:Hide()
        Timer.Start(0.1, function (_)
            SkillBook:Show()
        end)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show tooltip hint on how to use the feature. Only appears for skills that can be unlearnt.
Client.Tooltip.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    if ev.UI.Type == Ext.UI.TypeID.skills then
        local skill = ev.SkillID
        local canUnlearn, _ = Unlearn.CanUnlearn(Client.GetCharacter(), skill)
        if canUnlearn then
            ev.Tooltip:InsertElement({Type = "Engraving", Label = TSK.Tooltip_HintLabel:GetString(), 1})
        end
    end
end)

-- Open unlearn prompt upon right-clicking a skill, or an error message if the skill cannot be unlearnt.
Client.Input.Events.MouseButtonPressed:Subscribe(function (e)
    if e.InputID == "right2" then
        local skillID = SkillBook.GetSelectedSkill()

        if skillID then
            local stat = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
            local canUnlearn, reason = Unlearn.CanUnlearn(Client.GetCharacter(), skillID)

            if canUnlearn then
                local skillName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)

                MessageBox.Open({
                    ID = "PIP_UnlearnSkill",
                    SkillID = skillID,
                    Header = TSK.MsgBox_Title:GetString(),
                    Message = TSK.MsgBox_Confirmation:Format(skillName),
                    Buttons = {
                        {Type = 1, ID = 1, Text = TSK.MsgBox_Button_Unlearn:GetString()},
                        {Type = 1, ID = 2, Text = Text.CommonStrings.Cancel:GetString()},
                    },
                })
            else
                local reasonLabel = Unlearn.CANNOT_UNLEARN_REASON_TO_TSK[reason]:GetString()
                if reason == Unlearn.CANNOT_UNLEARN_REASONS.INNATE then -- This particular reason includes skill name in the warning.
                    local skillName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)
                    reasonLabel = reasonLabel:format(skillName)
                end

                MessageBox.Open({
                    Header = "",
                    Message = reasonLabel,
                })
            end
        end
    end
end)

-- Listen for prompt being accepted.
MessageBox.RegisterMessageListener("PIP_UnlearnSkill", MessageBox.Events.ButtonPressed, function(buttonId, data)
    if buttonId == 1 then
        Unlearn.UnlearnSkill(nil, data.SkillID)
    end
end)
