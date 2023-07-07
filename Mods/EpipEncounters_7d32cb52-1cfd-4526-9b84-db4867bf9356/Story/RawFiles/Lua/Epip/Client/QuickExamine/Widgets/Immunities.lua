
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@type Feature
local Immunities = {}
Epip.RegisterFeature("QuickExamine_Widget_Immunities", Immunities)

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("Immunities")

function Widget:CanRender(_)
    return Immunities:IsEnabled()
end

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

        table.sort(immunities) -- Sort by name.

        immunityLabel = "Immune to " .. Text.Join(immunities, ", ")
        immunityLabel = Text.Format(immunityLabel, {Size = 13})

        local element = TextPrefab.Create(QuickExamine.UI, "Resources_Immunities", verticalList, immunityLabel, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 30))
        local textHeight = element:GetTextSize()[2]
        element:SetSize(QuickExamine.GetContainerWidth(), textHeight) -- Ensure text fits.
    end
end