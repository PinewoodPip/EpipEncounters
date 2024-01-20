
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")

local ArtifactsDisplay = {}
Epip.RegisterFeature("QuickExamine_ArtifactsDisplay", ArtifactsDisplay)

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("ArtifactsDisplay", {Setting = {
    ID = "Widget_Artifacts",
    Type = "Boolean",
    Name = "Show Artifacts",
    Description = "Shows the equipped artifacts of characters.",
    DefaultValue = true,
}})

function Widget:CanRender(entity)
    return Entity.IsCharacter(entity) and #Artifact.GetEquippedPowers(entity) > 0
end

function Widget:Render(entity)
    local container = QuickExamine.GetContainer()
    local artifacts = Artifact.GetEquippedPowers(entity)

    local header = container:AddChild("QuickExamine_Artifacts_Header", "GenericUI_Element_Text")
    header:SetText(Text.Format("Artifact Powers", {Color = "ffffff", Size = 19}))
    header:SetSize(QuickExamine.GetContainerWidth(), 30)

    local artifactContainer = container:AddChild("QuickExamine_Artifacts", "GenericUI_Element_HorizontalList")
    artifactContainer:SetSize(QuickExamine.GetContainerWidth(), 35)
    artifactContainer:SetCenterInLists(true)

    for _,artifact in ipairs(artifacts) do
        local template = Ext.Template.GetTemplate(string.match(artifact.ItemTemplate, Data.Patterns.GUID)) ---@type ItemTemplate

        local icon = artifactContainer:AddChild(artifact.ID .. "icon", "GenericUI_Element_IggyIcon")
        icon:SetIcon(template.Icon, 32, 32)
        icon.Tooltip = {
            Type = "Custom",
            Data = artifact:GetPowerTooltip(),
        }
    end

    self:CreateDivider("ArtifactsDivider", container)
end