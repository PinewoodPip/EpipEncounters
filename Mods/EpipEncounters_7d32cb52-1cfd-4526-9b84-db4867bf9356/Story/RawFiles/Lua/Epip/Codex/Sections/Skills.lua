
---------------------------------------------
-- Implements a Codex section that displays skills,
-- and also functions as an alternative to the vanilla skillbook UI.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local Generic = Client.UI.Generic
local Codex = Epip.GetFeature("Feature_Codex")
local SectionClass = Codex:GetClass("Feature_Codex_Section")
local SearchBarPrefab = Generic.GetPrefab("GenericUI_Prefab_SearchBar")
local SlotPrefab = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Icons = Epip.GetFeature("Feature_GenericUITextures").ICONS
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
    }),
    -- Set of vanilla skills removed in EE.
    EE_SKILL_BLACKLIST = Set.Create({
        "Projectile_DeployMassTraps",
        "Projectile_PyroclasticEruption",
        "Target_FireInfusion",
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

    TranslatedStrings = {
        Section_Description = {
            Handle = "ha5ab3810g9aa9g4168g89fdgbfd0ee2c4c01",
            Text = "Shows skills available to players.",
            ContextDescription = "Description for Skills section",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsSkillValid = {}, ---@type Event<Feature_Codex_Skills_Hook_IsSkillValid>
    },
}
Epip.RegisterFeature("Codex_Skills", Skills)

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
-- METHODS
---------------------------------------------

---Returns the skills to render.
---@return Feature_Codex_Skills_Skill[]
function Skills.GetSkills()
    local allSkills = Ext.Stats.GetStats("SkillData")
    local skills = {}

    for _,id in ipairs(allSkills) do
        if Skills.IsSkillValid(id) then
            table.insert(skills, {Stat = Stats.Get("SkillData", id), ID = id})
        end
    end

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
-- SECTION
---------------------------------------------

---@class Feature_Codex_Skills_Section : Feature_Codex_Section
local Section = {
    _SchoolButtons = {}, ---@type table<string, GenericUI_Prefab_Button>
    _SkillInstances = {}, ---@type GenericUI_Prefab_HotbarSlot[]

    Name = Text.CommonStrings.Skills,
    Description = Skills.TranslatedStrings.Section_Description,
    Icon = "hotbar_icon_skills", -- TODO find a cooler one

    CONTAINER_OFFSET = V(35, 35),
    GRID_OFFSET = V(0, 100),
    GRID_LIST_FRAME = V(Codex.UI.CONTENT_CONTAINER_SIZE[1], 640),
    SCHOOL_BUTTONS_OFFSET = V(170, 0),
    SKILL_SIZE = V(64, 64),
    SEARCH_BAR_SIZE = V(170, 43),
    MAX_SKILLS = 400, -- Maximum amount of skills to show. Failsafe to prevent long freezes.
    SEARCH_DELAY_TIMER_ID = "Feature_Codex_Skills_SearchDelay",
    SEARCH_DELAY = 0.7, -- In seconds.
}
SectionClass.Create(Section)
Codex.RegisterSection("Skills", Section)

---@override
---@param root GenericUI_Element_Empty
function Section:Render(root)
    Section.Root = root
    root:Move(self.CONTAINER_OFFSET:unpack())

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

    local gridScrollList = root:AddChild("Skills_Grid_ScrollList", "GenericUI_Element_ScrollList")
    gridScrollList:SetFrame(self.GRID_LIST_FRAME:unpack())
    gridScrollList:Move(self.GRID_OFFSET:unpack())
    gridScrollList:SetMouseWheelEnabled(true)
    gridScrollList:SetScrollbarSpacing(-80)

    local grid = gridScrollList:AddChild("Skills_Grid", "GenericUI_Element_Grid")
    local columns = math.floor(Codex.UI.CONTENT_CONTAINER_SIZE[1] / self.SKILL_SIZE[1])
    grid:SetRepositionAfterAdding(true) -- No noticeable performance impact
    grid:SetGridSize(columns, -1)

    Section:_SetupSchoolButtons()

    Section.Grid = grid
    Section.GridScrollList = gridScrollList
end

---@override
function Section:Update(_)
    Section:UpdateSkills()
end

---Updates the skills grid.
function Section:UpdateSkills()
    local skills = Skills.GetSkills()

    Skills:DebugLog("Updating skills")

    -- Update all slots; _UpdateSkill() will hide a slot if `nil` is passed.
    -- Therefore excess slots are hidden and reusable as a form of pooling.
    for i=1,math.clamp(#skills, #self._SkillInstances, self.MAX_SKILLS),1 do
        self:_UpdateSkill(i, skills[i])
    end

    Section.GridScrollList:RepositionElements()
end

---Updates a skill element.
---@param index integer The element will be created if there isn't one at the index.
---@param skill Feature_Codex_Skills_Skill? Use `nil` to hide the slot.
function Section:_UpdateSkill(index, skill)
    local instance = self._SkillInstances[index]
    if not instance then
        instance = SlotPrefab.Create(Codex.UI, skill and skill.ID or "", self.Grid)
        instance:SetCanDrop(false)
        instance:SetCanDrag(true, false)
        instance:SetUpdateDelay(-1)
        instance:SetEnabled(true)

        self._SkillInstances[index] = instance
    end

    if skill then
        instance:SetSkill(skill.ID)
    end

    instance:SetVisible(skill ~= nil)
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

---Initializes the buttons for school filters.
function Section:_SetupSchoolButtons()
    local list = Section.Root:AddChild("Skills_SchoolList", "GenericUI_Element_HorizontalList")
    list:Move(self.SCHOOL_BUTTONS_OFFSET:unpack())

    for _,id in ipairs(Skills.SCHOOL_ORDER) do
        local button = ButtonPrefab.Create(Codex.UI, "Skills_" .. id, list, ButtonPrefab:GetStyle("SquareStone"))

        -- Toggle filter and change icon upon click
        button.Events.Pressed:Subscribe(function (_)
            if Skills.IsSchoolFiltered(id) then
                Skills._HiddenSchools:Remove(id)
            else
                Skills._HiddenSchools:Add(id)
            end

            Section:_UpdateSchoolButton(id)

            Section:UpdateSkills()
        end)
        
        -- Set this to be the only school if right-clicked (mimicking vanilla skillbook behaviour)
        button.Events.RightClicked:Subscribe(function (_)
            local set = Skills._HiddenSchools
            for _,otherSchoolID in ipairs(Skills.SCHOOL_ORDER) do
                set:Add(otherSchoolID)
            end
            set:Remove(id)

            Section:_UpdateSchoolButtons()

            Section:UpdateSkills()
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

        -- Filter based on search term
        local searchTerm = Skills._SearchTerm:lower()
        if searchTerm ~= "" then
            local lowercaseName = (Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName) or stat.DisplayNameRef):lower()

            if not lowercaseName:match(searchTerm) and not lowercaseID:match(searchTerm) then
                valid = false
                goto End
            end
        end
    end

    ::End::

    ev.Valid = valid
end, {StringID = "DefaultImplementation"})