
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local LabelledIcon = Generic.GetPrefab("GenericUI_Prefab_LabelledIcon")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local BH = EpicEncounters.BatteredHarried

---@class Features.QuickExamine.Widgets.Resources : Feature
local BasicInfo = {
    ICON_SIZE = 22,
    RESOURCE_TEXT_SIZE = 32,
    AP_ICON = "ui_24x_action_point",
    SP_ICON = "ui_24x_source_point",
    INITIATIVE_ICON = "ui_24x_initiative",
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Resources", BasicInfo)

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widget
local Widget = {}
BasicInfo:RegisterClass("Features.QuickExamine.Widgets.Resources.Widget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return BasicInfo:IsEnabled() and Entity.IsCharacter(entity)
end

---@override
function Widget:Render(entity)
    local ICON_SIZE = BasicInfo.ICON_SIZE
    local char = entity ---@type EclCharacter
    local UI = QuickExamine.UI
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
    if EpicEncounters.IsEnabled() then
        local battered, harried = BH.GetStacks(char, "Battered"), BH.GetStacks(char, "Harried")
        local batteredIcon = horizontalList:AddChild("BasicInfo_Battered", "GenericUI_Element_IggyIcon")
        local harriedIcon = horizontalList:AddChild("BasicInfo_Harried", "GenericUI_Element_IggyIcon")
        batteredIcon:SetIcon("AMER_Icon_Status_Battered_" .. battered, ICON_SIZE, ICON_SIZE)
        harriedIcon:SetIcon("AMER_Icon_Status_Harried_" .. harried, ICON_SIZE, ICON_SIZE)
        batteredIcon:SetCenterInLists(true)
        harriedIcon:SetCenterInLists(true)

        -- Battered/Harried damage buffered
        local bhProgress = Text.Format("%s%%", {FormatArgs = {Text.Round(EpicEncounters.BatteredHarried.GetBufferedDamage(char) * 100, 2)}})
        TextPrefab.Create(UI, "BasicInfo_BHProgress", horizontalList, bhProgress, "Left", Vector.Create(64, BasicInfo.RESOURCE_TEXT_SIZE)) 
    end

    horizontalList:RepositionElements()
    verticalList:RepositionElements()
end
