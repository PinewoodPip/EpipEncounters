
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local LabelledIcon = Generic.GetPrefab("GenericUI_Prefab_LabelledIcon")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local BH = EpicEncounters.BatteredHarried

---@class Features.QuickExamine.Widgets.Resources : Feature
local BasicInfo = {
    TSKHANDLE_MOVEMENT_DISTANCE = "hd589d36bg8be6g49ceg90adg6b6b338fa76d", -- "[1]m"

    ICON_SIZE = 22,
    RESOURCE_TEXT_SIZE = 32,
    AP_ICON = "ui_24x_action_point",
    SP_ICON = "ui_24x_source_point",
    INITIATIVE_ICON = "PIP_UI_Icon_CharacterSheet_Initiative",
    MOVEMENT_ICON = "PIP_UI_Icon_CharacterSheet_Movement",
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
    local apLabelledIcon = self:_RenderStat(horizontalList, "Resources_AP", BasicInfo.AP_ICON, apLabel)
    apLabelledIcon.Text:FitSize()

    -- Source points
    local spLabel = Text.Format("%s/%s", {
        FormatArgs = {
            Character.GetSourcePoints(entity),
        }
    })
    local spLabelledIcon = self:_RenderStat(horizontalList, "Resources_SP", BasicInfo.SP_ICON, spLabel)
    spLabelledIcon.Text:FitSize()

    -- Initiative
    local initiativeLabel = self:_RenderStat(horizontalList, "Resources_Initiative", BasicInfo.INITIATIVE_ICON, tostring(char.Stats.Initiative))
    initiativeLabel.Text:FitSize()

    -- Movement
    local movement = Text.Round(Character.GetMovement(char) / 100, 2)
    local movementLabel = self:_RenderStat(horizontalList, "Resources_Movement", BasicInfo.MOVEMENT_ICON, Text.FormatLarianTranslatedString(BasicInfo.TSKHANDLE_MOVEMENT_DISTANCE, movement))
    movementLabel.Text:FitSize()

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

---Renders a labelled stat into the widget.
---@param parent GenericUI_ParentIdentifier
---@param id string
---@param icon icon
---@param valueLabel string
---@return GenericUI_Prefab_LabelledIcon
function Widget:_RenderStat(parent, id, icon, valueLabel)
    local ICON_SIZE = BasicInfo.ICON_SIZE
    if #valueLabel <= 2 then
        valueLabel = valueLabel .. " " -- Workaround for FitSize() cutting off very short text horizontally.
    end
    local element = LabelledIcon.Create(QuickExamine.UI, id, parent, icon, valueLabel, Vector.Create(ICON_SIZE, ICON_SIZE), Vector.Create(64, BasicInfo.RESOURCE_TEXT_SIZE))
    element.Text:FitSize()
    return element
end
