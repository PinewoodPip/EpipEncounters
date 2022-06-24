
if Ext.Debug.IsDeveloperMode() then

    -- You can query talents through MyMod_Talent_MyTalent tag (ex. EpipEncounters_Talent_Test) or SpecialLogic (AMER_GLO_EpipEncounters_Talent_Test)
    -- Game.Talents:RegisterTalent("EpipEncounters", "Test", {
    --     name = "test",
    --     tooltip = "test2",
    --     icon = "hotbar_icon_journal",
    --     requirements = {
    --         abilities = {
    --             WarriorLore = 1,
    --             WaterSpecialist = 1,
    --         },
    --     },
    -- })
    
    -- Game.Talents:RegisterTalent("EpipEncounters", "Test2", {
    --     name = "test2",
    --     tooltip = "test3",
    --     icon = "hotbar_icon_journal",
    --     requirements = {
    --         abilities = {
    --             -- Sourcery = 3,
    --         },
    --         attributes = {
    --             Strength = 15,
    --         }
    --     },
    -- })
end

if Ext.IsClient() then
    Game.Talents:HideTalent(70)
end