
local SkillBook = Client.UI.Skills
local MessageBox = Client.UI.MessageBox

---@class Feature_UnlearnSkills
local Unlearn = Epip.GetFeature("UnlearnSkills")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open unlearn prompt upon right-clicking a skill.
Client.Input.Events.MouseButtonPressed:Subscribe(function (e)
    if e.InputID == "right2" then
        local skillID = SkillBook.GetSelectedSkill()
        local playerData = Client.GetCharacter().SkillManager.Skills[skillID]

        if skillID and playerData.CauseListSize == 0 and not playerData.ZeroMemory then
            local stat = Stats.Get("SkillData", skillID)
            local skillName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)

            if Unlearn.BLOCKED_SKILLS[skillID] then -- Cannot unlearn explicitly blocked skills.
                local msg = "I cannot unlearn this skill."

                -- Easter egg messages.
                if skillID == "Shout_NexusMeditate" then
                    msg = "I would lose my special spark if I were to give that up."
                elseif skillID == "Shout_SourceInfusion" then
                    msg = "Sourcery is an innate part of who I am; I cannot get rid of it."
                end

                MessageBox.Open({
                    Header = "",
                    Message = msg,
                })
            elseif stat["Memory Cost"] == 0 then -- Cannot unlearn innate spells.
                local msg = Text.Format("%s is an innate skill; it might be unwise to rid myself of it.", {FormatArgs = {skillName}})

                MessageBox.Open({
                    Header = "",
                    Message = msg,
                })
            else
                MessageBox.Open({
                    ID = "PIP_UnlearnSkill",
                    SkillID = skillID,
                    Header = "Unlearn Skill",
                    Message = Text.Format("Are you sure you want to unlearn %s?", {FormatArgs = {skillName}}),
                    Buttons = {
                        {Type = 1, ID = 1, Text = "Unlearn"},
                        {Type = 1, ID = 2, Text = "Cancel"},
                    },
                })
            end
        end
    end
end)

-- Listen for prompt being accepted.
MessageBox.RegisterMessageListener("PIP_UnlearnSkill", MessageBox.Events.ButtonPressed, function(buttonId, data)
    if buttonId == 1 then
        Net.PostToServer("EPIPENCOUNTERS_UnlearnSkill", {
            CharacterNetID = Client.GetCharacter().NetID,
            SkillID = data.SkillID,
        })

        -- Refresh the UI. The memorized spell window does not update if a skill is unlearnt while the UI is open.
        SkillBook:Hide()
        Timer.Start(0.1, function (_)
            SkillBook:Show()
        end)
    end
end)