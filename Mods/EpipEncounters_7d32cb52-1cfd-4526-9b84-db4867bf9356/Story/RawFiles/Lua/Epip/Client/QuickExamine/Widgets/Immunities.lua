
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@type Feature
local Immunities = {
    TranslatedStrings = {
        Label_ImmuneTo = {
            Handle = "hf8b6a329g25ecg4386g9c9cg6b5596b1b016",
            Text = "Immune to %s",
            ContextDescription = [[Label for status immunities; param is comma-separated list of immunities]],
        },
    }
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Immunities", Immunities)
local TSK = Immunities.TranslatedStrings

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widget
local Widget = {}
Immunities:RegisterClass("Features.QuickExamine.Widgets.Immunities.Widget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(_)
    return Immunities:IsEnabled()
end

---@override
function Widget:Render(entity)
    local char = entity ---@type EclCharacter
    local container = QuickExamine.GetContainer()
    local immunities = {}

    -- Get a list of all immunities's names on the char.
    for id,immunity in pairs(Stats.Immunities) do
        if Character.HasImmunity(char, id) then
            table.insert(immunities, immunity:GetName())
        end
    end

    if #immunities > 0 then
        local immunityLabel
        local verticalList = container:AddChild("Resistances_RootContainer", "GenericUI_Element_VerticalList")

        -- Sort by name
        table.sort(immunities)

        immunityLabel = TSK.Label_ImmuneTo:Format(Text.Join(immunities, ", "), {
            Size = 13,
        })

        local element = TextPrefab.Create(QuickExamine.UI, "Resources_Immunities", verticalList, immunityLabel, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 30))
        local textHeight = element:GetTextSize()[2]
        element:SetSize(QuickExamine.GetContainerWidth(), textHeight) -- Ensure text fits.
    end
end
