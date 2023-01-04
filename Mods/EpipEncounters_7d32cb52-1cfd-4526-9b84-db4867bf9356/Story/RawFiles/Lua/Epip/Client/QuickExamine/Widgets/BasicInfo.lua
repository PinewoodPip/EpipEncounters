
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local LabelledIcon = Generic.GetPrefab("GenericUI_Prefab_LabelledIcon")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class Feature_QuickExamine_Widget_Resources : Feature
local BasicInfo = {
    ICON_SIZE = 22,
    RESOURCE_TEXT_SIZE = 32,
    AP_ICON = "ui_24x_action_point",
    SP_ICON = "ui_24x_source_point",
    INITIATIVE_ICON = "ui_24x_initiative",
}
Epip.RegisterFeature("QuickExamine_Widget_BasicInfo", BasicInfo)

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("BasicInfo")

function Widget:CanRender(entity)
    return BasicInfo:IsEnabled() and Entity.IsCharacter(entity)
end

function Widget:Render(entity)
    local ICON_SIZE = BasicInfo.ICON_SIZE
    local char = entity ---@type EclCharacter
    local container = QuickExamine.GetContainer()
    local verticalList = container:AddChild("Resources_RootContainer", "GenericUI_Element_VerticalList")
    local horizontalList = verticalList:AddChild("ResourcesList", "GenericUI_Element_HorizontalList")
    -- verticalList:SetSize(QuickExamine.GetContainerWidth(), -1)
    local sizingDummy = verticalList:AddChild("_", "GenericUI_Element_TiledBackground") -- A ridiculous hack
    sizingDummy:SetSize(QuickExamine.GetContainerWidth(), 3)
    sizingDummy:SetAlpha(0)
    horizontalList:SetCenterInLists(true)

    -- Action points
    local apLabel = Text.Format("%s/%s", {
        FormatArgs = {
            Character.GetActionPoints(entity)
        }
    })
    LabelledIcon.Create(QuickExamine.UI, "Resources_AP", horizontalList, BasicInfo.AP_ICON, apLabel, Vector.Create(ICON_SIZE, ICON_SIZE), Vector.Create(64, BasicInfo.RESOURCE_TEXT_SIZE))

    -- Source points
    local spLabel = Text.Format("%s/%s", {
        FormatArgs = {
            Character.GetSourcePoints(entity),
        }
    })
    LabelledIcon.Create(QuickExamine.UI, "Resources_SP", horizontalList, BasicInfo.SP_ICON, spLabel, Vector.Create(ICON_SIZE, ICON_SIZE), Vector.Create(64, BasicInfo.RESOURCE_TEXT_SIZE))

    -- Initiative
    LabelledIcon.Create(QuickExamine.UI, "Resources_Initiative", horizontalList, BasicInfo.INITIATIVE_ICON, tostring(char.Stats.Initiative), Vector.Create(ICON_SIZE, ICON_SIZE), Vector.Create(64, BasicInfo.RESOURCE_TEXT_SIZE))

    -- Battered & Harried
    local battered, harried = Character.GetStacks(char, "Battered"), Character.GetStacks(char, "Harried")
    local batteredIcon = horizontalList:AddChild("BasicInfo_Battered", "GenericUI_Element_IggyIcon")
    local harriedIcon = horizontalList:AddChild("BasicInfo_Harried", "GenericUI_Element_IggyIcon")
    batteredIcon:SetIcon("AMER_Icon_Status_Battered_" .. battered, ICON_SIZE, ICON_SIZE)
    harriedIcon:SetIcon("AMER_Icon_Status_Harried_" .. harried, ICON_SIZE, ICON_SIZE)
    batteredIcon:SetCenterInLists(true)
    harriedIcon:SetCenterInLists(true)

    horizontalList:RepositionElements()
    verticalList:RepositionElements()
end