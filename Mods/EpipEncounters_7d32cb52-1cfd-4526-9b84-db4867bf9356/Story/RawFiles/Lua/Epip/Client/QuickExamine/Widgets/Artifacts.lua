
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")

---@class Features.QuickExamine.Widgets.Artifacts : Feature
local ArtifactsDisplay = {
    TranslatedStrings = {
        Header = {
            Handle = "h10e9e7c4g9c41g4cf2ga7f5g59052b73ae8d",
            Text = "Artifact Powers",
            ContextDescription = "Header for UI widget",
            FormatOptions = {{Color = Color.WHITE, Size = 19}},
        },
        Setting_Enabled_Name = {
            Handle = "h8dfa476cg4121g429dga2cdgd6b3de72ee98",
            Text = "Show Artifacts",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h92f5ec36g9d74g4eccg951eg9d9620dda934",
            Text = "If enabled, the Quick Examine UI will show the equipped artifacts of characters.",
            ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Artifacts", ArtifactsDisplay)
local TSK = ArtifactsDisplay.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

ArtifactsDisplay.Settings.Enabled = ArtifactsDisplay:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widget
local Widget = {
    ID = "ArtifactsDisplay",
    Setting = ArtifactsDisplay.Settings.Enabled,
}
ArtifactsDisplay:RegisterClass("Features.QuickExamine.Widgets.Artifacts.Widget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return Entity.IsCharacter(entity) and #Artifact.GetEquippedPowers(entity) > 0
end

---@override
function Widget:Render(entity)
    local container = QuickExamine.GetContainer()
    local artifacts = Artifact.GetEquippedPowers(entity)

    self:CreateHeader("QuickExamine_Artifacts_Header", container, TSK.Header:GetString())

    local artifactContainer = container:AddChild("QuickExamine_Artifacts", "GenericUI_Element_HorizontalList")
    artifactContainer:SetSize(QuickExamine.GetContainerWidth(), 35)
    artifactContainer:SetCenterInLists(true)

    for _,artifact in ipairs(artifacts) do
        local template = Ext.Template.GetTemplate(string.match(artifact.ItemTemplate, Data.Patterns.GUID)) ---@cast template ItemTemplate

        local icon = artifactContainer:AddChild(artifact.ID .. "icon", "GenericUI_Element_IggyIcon")
        icon:SetIcon(template.Icon, 32, 32)
        icon.Tooltip = {
            Type = "Custom",
            Data = artifact:GetPowerTooltip(),
        }
    end

    self:CreateDivider("ArtifactsDivider", container)
end