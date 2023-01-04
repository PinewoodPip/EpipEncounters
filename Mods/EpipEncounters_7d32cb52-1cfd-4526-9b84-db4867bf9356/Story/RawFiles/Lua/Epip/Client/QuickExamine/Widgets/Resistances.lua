
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@type Feature
local Resistances = {
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
Epip.RegisterFeature("QuickExamine_Widget_Resistances", Resistances)

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("Resistances")

function Widget:CanRender(_)
    return Resistances:IsEnabled()
end

function Widget:Render(entity)
    local char = entity ---@type EclCharacter
    local container = QuickExamine.GetContainer()
    local verticalList = container:AddChild("Resistances_RootContainer", "GenericUI_Element_VerticalList")

    local resistanceLabels = {}
    for _,resistanceId in ipairs(Resistances.RESISTANCES_DISPLAYED) do
        local amount = char.Stats[resistanceId .. "Resistance"]
        local display = Text.Format("%s%%", {
            Color = Resistances.RESISTANCE_COLORS[resistanceId],
            FormatArgs = {amount},
        })

        table.insert(resistanceLabels, display)
    end
    local resistanceLabel = Text.Join(resistanceLabels, "   ")
    local resistancesText = TextPrefab.Create(QuickExamine.UI, "Resources_Resistances", verticalList, resistanceLabel, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 40))
    resistancesText:SetStroke(Color.Create(0, 0, 0), 1, 1, 1, 1)
end