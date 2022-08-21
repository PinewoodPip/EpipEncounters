
local SkillBook = Client.UI.Skills
local MessageBox = Client.UI.MessageBox

---@class Feature_UnlearnSkills
local Unlearn = Epip.GetFeature("UnlearnSkills")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EclCharacter? Defaults to client character.
---@param skillID string
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
        local skill = SkillBook.GetSelectedSkill()

        if skill then
            local canUnlearn, _ = Unlearn.CanUnlearn(Client.GetCharacter(), skill)

            if canUnlearn then
                ev.Tooltip:InsertElement({Type = "Engraving", Label = Text.Format("Right-click to unlearn.", {Color = Color.GREEN}), 1})
            end
        end
    end
end)

-- Open unlearn prompt upon right-clicking a skill, or an error message if the skill cannot be unlearnt.
Client.Input.Events.MouseButtonPressed:Subscribe(function (e)
    if e.InputID == "right2" then
        local skillID = SkillBook.GetSelectedSkill()

        if skillID then
            local stat = Stats.Get("SkillData", skillID)
            local canUnlearn, reason = Unlearn.CanUnlearn(Client.GetCharacter(), skillID)
            
            if canUnlearn then
                local skillName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)

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
            else
                MessageBox.Open({
                    Header = "",
                    Message = reason,
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