
---------------------------------------------
-- Implements a Codex section that displays skills,
-- and also functions as an alternative to the vanilla skillbook UI.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local Generic = Client.UI.Generic
local Codex = Epip.GetFeature("Feature_Codex")
local GridSectionClass = Codex:GetClass("Features.Codex.Sections.Grid")
local SearchBarPrefab = Generic.GetPrefab("GenericUI_Prefab_SearchBar")
local SlotPrefab = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Icons = Epip.GetFeature("Feature_GenericUITextures").ICONS
local SkillbookTemplates = Epip.GetFeature("Features.SkillbookTemplates")
local V = Vector.Create

---@type Feature
local Skills = {
    _SearchTerm = "",
    _HiddenSchools = Set.Create({}),

    -- Set of patterns to filter out invalid skills. Use lowercase only, as the matching is performed on the IDs in lowercase.
    KEYWORD_BLACKLIST = Set.Create({
        "script",
        "dummy",
        "infus_",
        "_enemy",
        "insectshockingtouch", -- GB5 bugged skill
        "_empowered_?%d?$", -- "..._Empowered_2", etc.
        "_empowered_",
        "_test_",
        "_lldt_",
        "_meta_",
        "_quest_",
        "_grenade_",
    }),
    SKILL_BLACKLIST = Set.Create({
        "Shout_SpiritForm_Lucian",
        "Shout_CON00_ActivateSpores",
        "Shout_Shout_Toggle_Sprint",
        "Shout_LLSPRINT_ToggleSprint",
        "Shout_DEV06_ConsumeSpirits",
        "Jump_DEV06_DevourerJump",
        "Projectile_CON00_SetBonus",
    }),
    -- Set of vanilla skills removed in EE.
    EE_SKILL_BLACKLIST = Set.Create({
        "Projectile_DeployMassTraps",
        "Projectile_PyroclasticEruption",
        "Target_FireInfusion",
        "Target_WaterInfusion",
        "Target_IceInfusion",
        "Target_ElectricInfusion",
        "Target_PoisonInfusion",
        "Target_NecrofireInfusion",
        "Target_AcidInfusion",
        "Target_CursedElectricInfusion",
        "Target_BlessedSmokeCloud",
        "Target_Enrage",
        "Shout_MassOilyCarapace",
        "Shout_MassCryotherapy",
        "Shout_JellyfishSkin",
        "Shout_VenomousAura",
        "Shout_MassBreathingBubbles",
        "Shout_EvasiveAura",
        "Shout_VampiricHungerAura",
        "Shout_MassCleanseWounds",
        "Shout_SmokeCover",
        "Shout_Taunt",
        "Shout_MassCorpseExplosion",
        "Shout_Cryotherapy",
        "Shout_OilyCarapace",
        "Shout_PoisonousSkin",
        "Shout_FlamingSkin",
        "Shout_IceSkin",
        "Target_MassSabotage",
        "Target_MasterOfSparks",
        "Projectile_DustBlast",
        "Storm_Ethereal",
        "Storm_Lightning",
        "Storm_Blood",

        "Target_IncarnateGagOrder",
        "Target_IncarnateTerrifyingCruelty",
        "MultiStrike_IncarnateVault",
        "Shout_SlugSparkingSwings",
        "Target_AMER_Storm_Blizzard_Move",
        "Target_AMER_Storm_Lightning_Move",
        "Shout_ElectricFence_NEW",
        "Teleportation_IncarnateNetherswap",
        "Teleportation_IncarnateFreeFall",
        "Target_AMER_Storm_Scourge_Move",
        "Target_AMER_Storm_Ethereal_Move",

        "Shout_TESTDayNight",
        "Target_AMER_Artifact_Deck",
    }),

    -- TODO move elsewhere
    STATABILITY_TO_SCHOOL = {
        None = "Special",
        Warrior = "Warfare",
        Ranger = "Huntsman",
        Rogue = "Scoundrel",
        Source = "Sourcery",
        Fire = "Pyrokinetic",
        Water = "Hydrosophist",
        Air = "Aerotheurge",
        Earth = "Geomancer",
        Death = "Necromancer",
        Summoning = "Summoning",
        Polymorph = "Polymorph",
    },

    -- Same order as vanilla skillbook. Other schools added at the end.
    SCHOOL_ORDER = {
        "Warfare",
        "Huntsman",
        "Scoundrel",
        "Pyrokinetic",
        "Hydrosophist",
        "Aerotheurge",
        "Geomancer",
        "Necromancer",
        "Summoning",
        "Polymorph",

        "Special",
        "Sourcery",
    },

    SKILLBOOK_FILTER_SETTING_VALUES = {
        OFF = "Off",
        HAS_SKILLBOOK = "HasSkillbook",
        NO_SKILLBOOK = "NoSkillbook",
    },

    Settings = {},
    TranslatedStrings = {
        Section_Description = {
            Handle = "ha5ab3810g9aa9g4168g89fdgbfd0ee2c4c01",
            Text = "Shows skills available to players.",
            ContextDescription = "Description for Skills section",
        },
        Setting_ShowLearnt_Name = {
           Handle = "h7eaa3d1dg94a2g4136g969dg1ba9f6796fca",
           Text = "Show Learnt",
           ContextDescription = "Setting name",
        },
        Setting_ShowMemorized_Name = {
           Handle = "hb1aa6659g9385g4966g9b9fga77082927a94",
           Text = "Show Memorized",
           ContextDescription = "Setting name",
        },
        Setting_ShowNotLearnt_Name = {
           Handle = "h254f04a8gbaceg4970g97bdga522f285b929",
           Text = "Show Not Learnt",
           ContextDescription = "Setting name",
        },
        Setting_SkillbookFilter_Name = {
           Handle = "he415fd76g51bfg4b25g955cg59c3165c73ba",
           Text = "Skillbook",
           ContextDescription = "Setting name",
        },
        Setting_SkillbookFilter_Option_HasSkillbook = {
           Handle = "h5e83b5f4g33f8g45e6ga968gecd0cad8d465",
           Text = "Has Skillbook",
           ContextDescription = "Setting value",
        },
        Setting_SkillbookFilter_Option_NoSkillbook = {
           Handle = "he6042694g235ag4c68gbcccgb1a4769ae7bd",
           Text = "No Skillbook",
           ContextDescription = "Setting value",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsSkillValid = {}, ---@type Event<Feature_Codex_Skills_Hook_IsSkillValid>
    },
}
Epip.RegisterFeature("Codex_Skills", Skills)
local TSK = Skills.TranslatedStrings

-- Map for stat ability -> integer
Skills._StatAbilityToIndex = {} ---@type table<StatsLib_Enum_SkillAbility, integer>
for i,id in ipairs(Skills.SCHOOL_ORDER) do
    local statAbility = table.reverseLookup(Skills.STATABILITY_TO_SCHOOL, id)
    Skills._StatAbilityToIndex[statAbility] = i
end

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Codex_Skills_Skill
---@field ID string
---@field Stat StatsLib_StatsEntry_SkillData

---------------------------------------------
-- EVENTS AND HOOKS
---------------------------------------------

---@class Feature_Codex_Skills_Hook_IsSkillValid
---@field Stat StatsLib_StatsEntry_SkillData
---@field ID string
---@field Valid boolean Hookable. Defaults to `true`.

---------------------------------------------
-- SETTINGS
---------------------------------------------

-- Learnt/memorized filters
Skills.Settings.ShowNotLearnt = Skills:RegisterSetting("ShowNotLearnt", {
    Type = "Boolean",
    Name = TSK.Setting_ShowNotLearnt_Name,
    DefaultValue = true,
})
Skills.Settings.ShowLearnt = Skills:RegisterSetting("ShowLearnt", {
    Type = "Boolean",
    Name = TSK.Setting_ShowLearnt_Name,
    DefaultValue = true,
})
Skills.Settings.ShowMemorized = Skills:RegisterSetting("ShowMemorized", {
    Type = "Boolean",
    Name = TSK.Setting_ShowMemorized_Name,
    DefaultValue = true,
})

Skills.Settings.SkillbookFilter = Skills:RegisterSetting("SkillbookFilter", {
    Type = "Choice",
    NameHandle = TSK.Setting_SkillbookFilter_Name,
    DefaultValue = Skills.SKILLBOOK_FILTER_SETTING_VALUES.OFF,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = Skills.SKILLBOOK_FILTER_SETTING_VALUES.OFF, NameHandle = Text.CommonStrings.NoFilter.Handle},
        {ID = Skills.SKILLBOOK_FILTER_SETTING_VALUES.NO_SKILLBOOK, NameHandle = TSK.Setting_SkillbookFilter_Option_NoSkillbook.Handle},
        {ID = Skills.SKILLBOOK_FILTER_SETTING_VALUES.HAS_SKILLBOOK, NameHandle = TSK.Setting_SkillbookFilter_Option_HasSkillbook.Handle},
    }
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skills to render.
---@return Feature_Codex_Skills_Skill[]
function Skills.GetSkills()
    local allSkills = Ext.Stats.GetStats("SkillData")
    local skills = {} ---@type Feature_Codex_Skills_Skill[]

    for _,id in ipairs(allSkills) do
        if Skills.IsSkillValid(id) then
            table.insert(skills, {Stat = Stats.Get("SkillData", id), ID = id})
        end
    end

    -- Sort skills by school and ID
    table.sort(skills, function (a, b)
        local schoolA = Skills._StatAbilityToIndex[a.Stat.Ability]
        local schoolB = Skills._StatAbilityToIndex[b.Stat.Ability]

        if schoolA ~= schoolB then -- Sort by school
            return schoolA < schoolB
        else -- Sort alphabetically by display name
            local displayNameA = Skills._GetSkillDisplayName(a.Stat)
            local displayNameB = Skills._GetSkillDisplayName(b.Stat)
            return displayNameA < displayNameB
        end
    end)

    return skills
end

---Returns whether a skill is valid to be shown in the UI.
---@see Feature_Codex_Skills_Hook_IsSkillValid
---@param id string
---@return boolean
function Skills.IsSkillValid(id)
    return Skills.Hooks.IsSkillValid:Throw({
        Stat = Stats.Get("StatsLib_StatsEntry_SkillData", id),
        ID = id,
        Valid = true,
    }).Valid
end

---Returns whether a skill school is filtered out.
---@param schoolID string TODO type
---@return boolean
function Skills.IsSchoolFiltered(schoolID)
    return Skills._HiddenSchools:Contains(schoolID)
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Returns the display name of a skill.
---@param stat StatsLib_StatsEntry_SkillData
---@return string
function Skills._GetSkillDisplayName(stat) -- TODO move elsewhere
    return Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName) or stat.DisplayNameRef
end

---------------------------------------------
-- SECTION
---------------------------------------------

---@class Feature_Codex_Skills_Section : Features.Codex.Sections.Grid
local Section = {
    _SchoolButtons = {}, ---@type table<string, GenericUI_Prefab_Button>

    Name = Text.CommonStrings.Skills,
    Description = TSK.Section_Description,
    Icon = "hotbar_icon_skills", -- TODO find a cooler one
    Settings = {
        Skills.Settings.ShowNotLearnt,
        Skills.Settings.ShowLearnt,
        Skills.Settings.ShowMemorized,

        Skills.Settings.SkillbookFilter,
    },

    SCHOOL_BUTTONS_OFFSET = V(170, 0),
    SKILL_SIZE = V(58, 58),
    SEARCH_BAR_SIZE = V(170, 43),
    MAX_SKILLS = 400, -- Maximum amount of skills to show. Failsafe to prevent long freezes.
    SEARCH_DELAY_TIMER_ID = "Feature_Codex_Skills_SearchDelay",
    SEARCH_DELAY = 0.7, -- In seconds.
}
Codex:RegisterClass("Feature_Codex_Skills_Section", Section, {"Features.Codex.Sections.Grid"})
Codex.RegisterSection("Skills", Section)

---@override
---@param root GenericUI_Element_Empty
function Section:Render(root)
    GridSectionClass.Render(self, root)

    -- Set up search bar
    local searchBar = SearchBarPrefab.Create(Codex.UI, "Skills_SearchBar", root, self.SEARCH_BAR_SIZE)
    searchBar.Events.SearchChanged:Subscribe(function (ev)
        Skills._SearchTerm = ev.Text

        -- Update the grid only after a delay.
        local existingTimer = Timer.GetTimer(self.SEARCH_DELAY_TIMER_ID)
        if existingTimer then
            existingTimer:Cancel()
        end
        Timer.Start(self.SEARCH_DELAY_TIMER_ID, self.SEARCH_DELAY, function (_)
            Section:UpdateSkills()
        end)
    end)

    -- Set up school buttons
    Section:_SetupSchoolButtons()
end

---@override
function Section:Update(_)
    Section:UpdateSkills()
end

---Updates the skills grid.
function Section:UpdateSkills()
    local skills = Skills.GetSkills()

    Skills:DebugLog("Updating skills")

    self:__Update(skills)
end

---@override
---@param index integer
---@return GenericUI_Prefab_HotbarSlot
function Section:__CreateElement(index)
    local instance = SlotPrefab.Create(Codex.UI, "Skills_Skill_" .. index, self.Grid)

    instance.SlotElement:SetSizeOverride(Section.SKILL_SIZE) -- Required to fix a positioning issue.
    instance:SetCanDrop(false)
    instance:SetCanDrag(true, false)
    instance:SetUpdateDelay(-1)

    return instance
end

---Updates a skill element.
---@override
---@param _ integer
---@param instance GenericUI_Prefab_HotbarSlot
---@param skill Feature_Codex_Skills_Skill
function Section:__UpdateElement(_, instance, skill)
    instance:SetSkill(skill.ID)
    instance:SetEnabled(Character.IsSkillLearnt(Client.GetCharacter(), skill.ID))

    -- Highlight memorized skills with a border
    if Character.IsSkillMemorized(Client.GetCharacter(), skill.ID) then
        instance:SetRarityIcon("Unique")
    else
        instance:SetRarityIcon("Common")
    end
end

---Updates a skill school button.
---@param id string
function Section:_UpdateSchoolButton(id)
    local button = self._SchoolButtons[id]
    local iconTemplate = (not Skills.IsSchoolFiltered(id)) and Icons.SKILL_SCHOOL_COLORED_TEMPLATE or Icons.SKILL_SCHOOL_WHITE_TEMPLATE

    button:SetIcon(string.format(iconTemplate, id), V(32, 32))
end

---Updates all skill school buttons.
function Section:_UpdateSchoolButtons()
    for id,_ in pairs(self._SchoolButtons) do
        self:_UpdateSchoolButton(id)
    end
end

---Returns whether all schools should be toggled back on after a school button press.
---If so, toggles them back on.
---@param id string School button that was pressed.
---@return boolean
function Section:_CheckToggleAllSchools(id)
    -- If this is the only enabled school, toggle all schools on and update the UI.
    local shouldToggle = #Skills._HiddenSchools == (#Skills.SCHOOL_ORDER - 1) and not Skills.IsSchoolFiltered(id)
    if shouldToggle then
        Skills._HiddenSchools:Clear()
        Section:_UpdateSchoolButtons()
        Section:UpdateSkills()
    end
    return shouldToggle
end

---Initializes the buttons for school filters.
function Section:_SetupSchoolButtons()
    local list = Section.Root:AddChild("Skills_SchoolList", "GenericUI_Element_HorizontalList")
    list:Move(self.SCHOOL_BUTTONS_OFFSET:unpack())

    for _,id in ipairs(Skills.SCHOOL_ORDER) do
        local button = ButtonPrefab.Create(Codex.UI, "Skills_" .. id, list, ButtonPrefab:GetStyle("SquareStone"))

        -- Set this to be the only school if clicked (mimicking vanilla skillbook behaviour)
        button.Events.Pressed:Subscribe(function (_)
            if not Section:_CheckToggleAllSchools(id) then
                local set = Skills._HiddenSchools
                for _,otherSchoolID in ipairs(Skills.SCHOOL_ORDER) do
                    set:Add(otherSchoolID)
                end
                set:Remove(id)

                Section:_UpdateSchoolButtons()
                Section:UpdateSkills()
            end
        end)

        -- Toggle filter upon right-click
        button.Events.RightClicked:Subscribe(function (_)
            if not Section:_CheckToggleAllSchools(id) then
                if Skills.IsSchoolFiltered(id) then
                    Skills._HiddenSchools:Remove(id)
                else
                    Skills._HiddenSchools:Add(id)
                end

                Section:_UpdateSchoolButton(id)
                Section:UpdateSkills()
            end
        end)

        self._SchoolButtons[id] = button
        Section:_UpdateSchoolButton(id)
    end

    list:RepositionElements()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation of IsSkillValid.
Skills.Hooks.IsSkillValid:Subscribe(function (ev)
    local valid = ev.Valid
    local stat = ev.Stat

    if valid then
        valid = valid and stat.IsEnemySkill == "No"
        if not valid then goto End end

        -- Check school filter
        local school = Skills.STATABILITY_TO_SCHOOL[stat.Ability]
        if Skills.IsSchoolFiltered(school) then
            valid = false
            goto End
        end

        -- Check for blacklisted keywords in ID
        local lowercaseID = ev.ID:lower()
        for pattern in Skills.KEYWORD_BLACKLIST:Iterator() do
            if lowercaseID:match(pattern) then
                valid = false
                goto End
            end
        end

        -- Filter out deprecated skills
        if EpicEncounters.IsEnabled() then
            for skillID in Skills.EE_SKILL_BLACKLIST:Iterator() do
                if skillID == ev.ID then
                    valid = false
                    goto End
                end
            end
        end

        -- Filter out blacklisted skills
        for skillID in Skills.SKILL_BLACKLIST:Iterator() do
            if skillID == ev.ID then
                valid = false
                goto End
            end
        end

        -- Filter based on settings
        local showNotLearnt = Skills:GetSettingValue(Skills.Settings.ShowNotLearnt)
        local showMemorized = Skills:GetSettingValue(Skills.Settings.ShowMemorized)
        local showLearnt = Skills:GetSettingValue(Skills.Settings.ShowLearnt)
        local skillbookFilter = Skills:GetSettingValue(Skills.Settings.SkillbookFilter)
        local char = Client.GetCharacter()

        if not showNotLearnt and not Character.IsSkillLearnt(char, ev.ID) then
            valid = false
            goto End
        end
        if not showMemorized and (Character.IsSkillMemorized(char, ev.ID) and not Character.IsSkillInnate(char, ev.ID)) then
            valid = false
            goto End
        end
        if not showLearnt and (Character.IsSkillLearnt(char, ev.ID) and not Character.IsSkillMemorized(char, ev.ID)) then
            valid = false
            goto End
        end

        local hasSkillbook = #SkillbookTemplates.GetForSkill(ev.ID) > 0
        if skillbookFilter == Skills.SKILLBOOK_FILTER_SETTING_VALUES.HAS_SKILLBOOK and not hasSkillbook then
            valid = false
            goto End
        elseif skillbookFilter == Skills.SKILLBOOK_FILTER_SETTING_VALUES.NO_SKILLBOOK and hasSkillbook then
            valid = false
            goto End
        end

        local lowercaseName = Skills._GetSkillDisplayName(ev.Stat):lower()

        -- Filter out skills with no display name or icon - these tend to be unobtainable skills that are not properly marked as such by the developer.
        if ev.Stat.DisplayName == "" then -- We cannot check for valid handles here as there are mods like Derpy's which set the text directly to this field.
            valid = false
            goto End
        elseif stat.Icon == "unknown" or stat.Icon == "" then
            valid = false
            goto End
        end

        -- Filter based on search term - should be done last for performance reasons
        local searchTerm = Skills._SearchTerm:lower()
        if searchTerm ~= "" then
            if not lowercaseName:match(searchTerm) and not lowercaseID:match(searchTerm) then
                valid = false
                goto End
            end
        end
    end

    ::End::

    ev.Valid = valid
end, {StringID = "DefaultImplementation"})