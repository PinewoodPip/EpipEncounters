
---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Skillbooks filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Skillbooks" then
        local showLearntSkills = QuickInventory:GetSettingValue(QuickInventory.Settings.LearntSkillbooks) == true
        local school = QuickInventory:GetSettingValue(QuickInventory.Settings.SkillbookSchool)

        visible = visible and Item.HasUseAction(item, "SkillBook")
        
        if visible then
            if not showLearntSkills then
                local skillBookActions = Item.GetUseActions(item, "SkillBook") ---@type SkillBookActionData[]
                local knowsAllSkills = true
    
                for _,action in ipairs(skillBookActions) do
                    if not Character.IsSkillLearnt(Client.GetCharacter(), action.SkillID) then
                        knowsAllSkills = false
                        break
                    end
                end
    
                -- Only filter out the item if all skills from the book are learnt.
                visible = visible and not knowsAllSkills
            end
    
            if school ~= "Any" then
                -- Only checks first skill
                local action = Item.GetUseActions(item, "SkillBook")[1] ---@type SkillBookActionData
                local skillStat = Stats.Get("SkillData", action.SkillID)

                visible = visible and skillStat.Ability == school
            end
        end
    end
    
    ev.Visible = visible
end)