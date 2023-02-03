
local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.LearntSkillbooks = QuickInventory:RegisterSetting("LearntSkillbooks", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.ShowLearntSkills_Name,
    DefaultValue = false,
})

QuickInventory.Settings.SkillbookSchool = QuickInventory:RegisterSetting("SkillbookSchool", {
    Type = "Choice",
    Name = CommonStrings.AbilitySchool,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = { -- Ordered by appearance in skillbook UI
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Warrior", NameHandle = Text.CommonStrings.Warfare.Handle},
        {ID = "Ranger", NameHandle = Text.CommonStrings.Huntsman.Handle},
        {ID = "Rogue", NameHandle = Text.CommonStrings.Scoundrel.Handle},
        {ID = "Fire", NameHandle = Text.CommonStrings.Pyrokinetic.Handle},
        {ID = "Water", NameHandle = Text.CommonStrings.Hydrosophist.Handle},
        {ID = "Air", NameHandle = Text.CommonStrings.Aerotheurge.Handle},
        {ID = "Earth", NameHandle = Text.CommonStrings.Geomancer.Handle},
        {ID = "Death", NameHandle = Text.CommonStrings.Necromancer.Handle},
        {ID = "Summoning", NameHandle = Text.CommonStrings.Summoning.Handle},
        {ID = "Polymorph", NameHandle = Text.CommonStrings.Polymorph.Handle},
    },
})
local SCHOOL_TO_PRIORITY = {}
local skillBookSchoolSetting = QuickInventory.Settings.SkillbookSchool ---@type SettingsLib_Setting_Choice
for i,choice in ipairs(skillBookSchoolSetting.Choices) do
    SCHOOL_TO_PRIORITY[choice.ID] = i
end

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

-- Sort by school.
QuickInventory.Hooks.SortItems:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Skillbooks" then
        local action1 = Item.GetUseActions(ev.ItemA, "SkillBook")[1] ---@type SkillBookActionData
        local action2 = Item.GetUseActions(ev.ItemB, "SkillBook")[1] ---@type SkillBookActionData

        if action1 and action2 then
            local stat1, stat2 = Stats.Get("SkillData", action1.SkillID), Stats.Get("SkillData", action2.SkillID)

            ev.Result = (SCHOOL_TO_PRIORITY[stat1.Ability] or -1) < (SCHOOL_TO_PRIORITY[stat2.Ability] or -1)
            ev:StopPropagation()
        end
    end
end)