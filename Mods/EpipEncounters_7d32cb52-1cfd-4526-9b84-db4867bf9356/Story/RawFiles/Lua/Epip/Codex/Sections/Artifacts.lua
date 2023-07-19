
---------------------------------------------
-- Implements a Codex section that displays artifacts.
---------------------------------------------

local Generic = Client.UI.Generic
local Codex = Epip.GetFeature("Feature_Codex")
local GridSectionClass = Codex:GetClass("Features.Codex.Sections.Grid")
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local Icons = Epip.GetFeature("Feature_GenericUITextures").ICONS
local Set = DataStructures.Get("DataStructures_Set")
local CommonStrings = Text.CommonStrings

---@class Features.Codex.Artifacts : Feature
local Artifacts = {
    ARTIFACT_BLACKLIST = Set.Create({
        "Artifact_Deck",
    }),

    TranslatedStrings = {
        Section_Description = {
           Handle = "h1900a04ag7611g4d34g8975g89a0dac84c56",
           Text = "Displays all Epic Encounters Artifacts.",
           ContextDescription = "Section name",
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsArtifactValid = {}, ---@type Event<Features.Codex.Artifacts.Hooks.IsArtifactValid>
    },
}
Epip.RegisterFeature("Codex.Artifacts", Artifacts)
local TSK = Artifacts.TranslatedStrings

---------------------------------------------
-- EVENTS AND HOOKS
---------------------------------------------

---@class Features.Codex.Artifacts.Hooks.IsArtifactValid
---@field Artifact ArtifactLib_ArtifactDefinition
---@field Valid boolean Hookable. Defaults to `true`.

---------------------------------------------
-- SETTINGS
---------------------------------------------

Artifacts.Settings.SlotFilter = Artifacts:RegisterSetting("SlotFilter", {
    Type = "Choice",
    NameHandle = CommonStrings.ItemSlot,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Helmet", NameHandle = CommonStrings.Helmet.Handle},
        {ID = "Breast", NameHandle = CommonStrings.Breast.Handle},
        {ID = "Gloves", NameHandle = CommonStrings.Gloves.Handle},
        {ID = "Boots", NameHandle = CommonStrings.Boots.Handle},
        {ID = "Weapon", NameHandle = CommonStrings.Weapon.Handle},
        {ID = "Shield", NameHandle = CommonStrings.Shield.Handle},
        {ID = "Amulet", NameHandle = CommonStrings.Amulet.Handle},
        {ID = "Ring", NameHandle = CommonStrings.Ring.Handle},
    }
})

Artifacts.Settings.KeywordFilter = Artifacts:RegisterSetting("KeywordFilter", {
    Type = "Choice",
    NameHandle = CommonStrings.Keyword,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Abeyance", NameHandle = CommonStrings.Abeyance.Handle},
        {ID = "Benevolence", NameHandle = CommonStrings.Benevolence.Handle},
        {ID = "Celestial", NameHandle = CommonStrings.Celestial.Handle},
        {ID = "Centurion", NameHandle = CommonStrings.Centurion.Handle},
        {ID = "Defiance", NameHandle = CommonStrings.Defiance.Handle},
        {ID = "Elementalist", NameHandle = CommonStrings.Elementalist.Handle},
        {ID = "Occultist", NameHandle = CommonStrings.Occultist.Handle},
        {ID = "Paucity", NameHandle = CommonStrings.Paucity.Handle},
        {ID = "Predator", NameHandle = CommonStrings.Predator.Handle},
        {ID = "Presence", NameHandle = CommonStrings.Presence.Handle},
        {ID = "Prosperity", NameHandle = CommonStrings.Prosperity.Handle},
        {ID = "Purity", NameHandle = CommonStrings.Purity.Handle},
        {ID = "ViolentStrike", NameHandle = CommonStrings.ViolentStrikes.Handle},
        {ID = "VitalityVoid", NameHandle = CommonStrings.VitalityVoid.Handle},
        {ID = "VolatileArmor", NameHandle = CommonStrings.VolatileArmor.Handle},
        {ID = "Voracity", NameHandle = CommonStrings.Voracity.Handle},
        {ID = "Ward", NameHandle = CommonStrings.Ward.Handle},
        {ID = "Wither", NameHandle = CommonStrings.Wither.Handle},
        -- {ID = "IncarnateChampion", NameHandle = CommonStrings.IncarnateChampion.Handle}, -- Commented out as it's only a keyword in technicality.
        -- {ID = "Disintegrate", NameHandle = CommonStrings.Disintegrate.Handle}, -- Commented out as it's only a keyword in technicality.
    }
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a list of valid artifacts.
---@see Features.Codex.Artifacts.Hooks.IsArtifactValid
---@return ArtifactLib_ArtifactDefinition[]
function Artifacts.GetArtifacts()
    local artifacts = {} ---@type ArtifactLib_ArtifactDefinition[]
    for _,artifact in pairs(Artifact.ARTIFACTS) do
        local hook = Artifacts.Hooks.IsArtifactValid:Throw({
            Artifact = artifact,
            Valid = true
        })

        if hook.Valid then
            table.insert(artifacts, artifact)
        end
    end

    -- Sort by name
    table.sort(artifacts, function (a, b)
        return a:GetName() < b:GetName()
    end)

    return artifacts
end

---------------------------------------------
-- SECTION
---------------------------------------------

---@class Features.Codex.Skills.Section : Features.Codex.Sections.Grid
local Section = {
    Name = Text.CommonStrings.Artifacts,
    Description = TSK.Section_Description,
    Icon = Icons.TABS.MAGICAL.WHITE,
    Settings = {
        Artifacts.Settings.SlotFilter,
        Artifacts.Settings.KeywordFilter,
    },
}
Codex:RegisterClass("Features.Codex.Skills.Section", Section, {"Features.Codex.Sections.Grid"})
Codex.RegisterSection("Artifacts", Section)

---@override
---@param root GenericUI_Element_Empty
function Section:Render(root)
    GridSectionClass.Render(self, root)
end

---@override
function Section:Update(_)
    local artifacts = Artifacts.GetArtifacts()
    self:__Update(artifacts)
end

---@override
---@param index integer
---@return GenericUI_Prefab_HotbarSlot
function Section:__CreateElement(index)
    local slot = HotbarSlot.Create(Codex.UI, "Artifacts_Slot_" .. tostring(index), self.Grid)
    return slot
end

---@override
---@param _ integer
---@param slot GenericUI_Prefab_HotbarSlot
---@param artifact ArtifactLib_ArtifactDefinition
function Section:__UpdateElement(_, slot, artifact)
    local template = Ext.Template.GetRootTemplate(Text.RemoveGUIDPrefix(artifact.ItemTemplate)) ---@cast template ItemTemplate

    slot:SetIcon(template.Icon)
    slot:SetCanDragDrop(false)
    slot:SetRarityIcon(Item.GetRarityIcon("Unique"))
    slot:SetTooltip("Custom", {
        ID = artifact.ID,
        Elements = artifact:GetPowerTooltip(),
    })

    -- Set slot to be enabled if the party owns the artifact
    slot:SetEnabled(Artifact.IsOwnedByParty(artifact.ID))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation of IsArtifactValid.
Artifacts.Hooks.IsArtifactValid:Subscribe(function (ev)
    local valid = ev.Valid

    if valid then
        local slotFilter = Artifacts:GetSettingValue(Artifacts.Settings.SlotFilter)
        local keywordFilter = Artifacts:GetSettingValue(Artifacts.Settings.KeywordFilter)
        local artifact = ev.Artifact

        if slotFilter ~= "Any" then
            valid = valid and artifact.Slot == slotFilter
        end
        if keywordFilter ~= "Any" then
            valid = valid and artifact:HasKeyword(keywordFilter)
        end

        valid = valid and not Artifacts.ARTIFACT_BLACKLIST:Contains(artifact.ID)

        ev.Valid = valid
    end
end)