
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local LabelledIcon = Generic.GetPrefab("GenericUI_Prefab_LabelledIcon")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class Feature_QuickExamine_Widget_Resources : Feature
local BasicInfo = {
    ICON_SIZE = 20,
    RESOURCE_TEXT_SIZE = 32,
    AP_ICON = "ui_24x_action_point",
    SP_ICON = "ui_24x_source_point",
    INITIATIVE_ICON = "ui_24x_initiative",

    RESISTANCE_COLORS = {
        Fire = "f77c27",
        Water = "27aff6",
        Earth = "aa7840",
        Air = "8f83cb",
        Poison = "5bd42b",
        Physical = "acacac",
        Piercing = "c23c3c",
        Shadow = "5b34ca",
    },

    RESISTANCES_DISPLAYED = {
        "Fire", "Water", "Earth", "Air", "Poison", "Physical", "Piercing",
    },
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
    LabelledIcon.Create(QuickExamine.UI, "Resources_Initiative", horizontalList, BasicInfo.INITIATIVE_ICON, tostring(char.Stats.Initiative), Vector.Create(ICON_SIZE, ICON_SIZE), Vector.Create(32, BasicInfo.RESOURCE_TEXT_SIZE))

    -- Resistances
    local resistanceLabel = ""
    for _,resistanceId in ipairs(BasicInfo.RESISTANCES_DISPLAYED) do
        local amount = char.Stats[resistanceId .. "Resistance"]
        local display = Text.Format("%s%%", {
            Color = BasicInfo.RESISTANCE_COLORS[resistanceId],
            FormatArgs = {amount},
        })

        resistanceLabel = resistanceLabel .. "  " .. display
    end
    TextPrefab.Create(QuickExamine.UI, "Resources_Resistances", verticalList, resistanceLabel, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 40))

    -- Immunities
    local immunities = {}
    for id,immunity in pairs(Stats.Immunities) do
        if Character.HasImmunity(char, id) then
            table.insert(immunities, immunity:GetName())
        end
    end
    table.sort(immunities)
    if #immunities > 0 then
        local immunityLabel = "Immune to " .. Text.Join(immunities, ", ")
        immunityLabel = Text.Format(immunityLabel, {Size = 13})

        TextPrefab.Create(QuickExamine.UI, "Resources_Immunities", verticalList, immunityLabel, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 30))
    end

    verticalList:RepositionElements()
end