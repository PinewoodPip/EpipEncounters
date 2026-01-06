
---------------------------------------------
-- Widget that displays a character's talents.
---------------------------------------------

local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local AnchoredText = Generic.GetPrefab("GenericUI.Prefabs.AnchoredText")
local TALENTS = Character.Talents
local Tooltip = Client.Tooltip
local V = Vector.Create

---@type Feature
local Talents = {}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Talents", Talents)

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widget
local Widget = {
    HEADER_LABEL = Text.CommonStrings.Talents,
}
Talents:RegisterClass("Features.QuickExamine.Widgets.Talents.Widget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    if not Entity.IsCharacter(entity) or not Talents:IsEnabled() then return false end
    ---@cast entity EclCharacter
    -- Check if the character has any talent
    for talentType,_ in pairs(TALENTS) do
        if entity.Stats["TALENT_" .. talentType] then
            return true
        end
    end
    return false
end

---@override
function Widget:Render(entity)
    local char = entity ---@type EclCharacter
    local container = QuickExamine.GetContainer()

    -- Create header
    self:CreateHeader("Talents.Header", container, Text.Resolve(self.HEADER_LABEL))

    -- Fetch the character's talents
    local ownedTalents = {} ---@type CharacterLib_Talent[]
    for talentType,talent in pairs(TALENTS) do
        if char.Stats["TALENT_" .. talentType] then
            table.insert(ownedTalents, talent)
        end
    end
    table.sort(ownedTalents, function(a, b)
        return a.ID < b.ID
    end)

    if #ownedTalents > 0 then
        local verticalList = container:AddChild("Talents_RootContainer", "GenericUI_Element_VerticalList")

        local talentNames = {} ---@type string[]
        for _,talent in ipairs(ownedTalents) do
            table.insert(talentNames, Text.HTML.Anchor(talent:GetName(), "Talent." .. talent.NumericID))
        end
        local talentsText = Text.Join(talentNames, ", ")
        local talentsLabel = AnchoredText.Create(QuickExamine.UI, "Talents_Header", verticalList, talentsText, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 30))
        talentsLabel:SetSize(V(QuickExamine.GetContainerWidth(), talentsLabel:GetTextSize()[2]):unpack())

        -- Show talent tooltip on keyword hover.
        talentsLabel.Events.AnchorMouseOver:Subscribe(function (ev)
            local talentID = ev.ID:match("Talent%.(%d+)")
            local posX, posY = Client.GetMousePosition()
            Tooltip.ShowTalentTooltip(talentID, V(posX - QuickExamine.GetWidth() * QuickExamine.UI:GetScaleMultiplier(), posY), nil, "right")
        end)
        talentsLabel.Events.AnchorMouseOut:Subscribe(function (_)
            Tooltip.HideTooltip()
        end)
    end
end
