
local EpicEnemies = Epip.GetFeature("Feature_EpicEnemies")

---------------------------------------------
-- QUICK EXAMINE WIDGET
---------------------------------------------

local Generic = Client.UI.Generic
local _T = Generic.ELEMENTS.Text

local QuickExamine = Epip.GetFeature("Feature_QuickExamine")

---@type Features.QuickExamine.Widget
local Widget = {}
EpicEnemies:RegisterClass("Features.EpicEnemies.QuickExamineWidget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return #EpicEnemies.GetAppliedEffects(entity, true) > 0
end

---@override
function Widget:Render(entity)
    local container = QuickExamine.GetContainer()

    ---@type EpicEnemiesExtendedEffect[]
    local effects = EpicEnemies.GetAppliedEffects(entity, true)

    -- Sort effects
    local sortedEffects = {
        Artifacts = {},
        Other = {},
    }

    for _,effect in ipairs(effects) do
        if effect.Artifact then
            table.insert(sortedEffects.Artifacts, effect)
        else
            table.insert(sortedEffects.Other, effect)
        end
    end

    effects = {}
    for _,eff in pairs(sortedEffects.Artifacts) do table.insert(effects, eff) end
    for _,eff in pairs(sortedEffects.Other) do table.insert(effects, eff) end

    self:CreateHeader("EpicEnemies_Header", container, "Epic Enemies Effects")

    -- Artifact powers are already handled through the base QuickExamine script

    for _,effect in ipairs(sortedEffects.Other) do
        local entry = container:AddChild(effect.ID, "GenericUI_Element_Text")
        local activationConditionText = EpicEnemies.Hooks.GetActivationConditionDescription:Return("", effect.ActivationCondition, entity)

        local text = Text.Format(Text.Format("• ", {Size = 28}) .. Text.Resolve(effect.Name), {FontType = Text.FONTS.BOLD, Color = "088cc4"})

        if effect.Description and string.len(Text.Resolve(effect.Description)) > 0 then
            text = text .. "<br>" .. Text.Format("      " .. Text.Resolve(effect.Description), {Size = 17})
        end

        if effect.ActivationCondition.Type ~= "EffectApplied" then
            text = text .. "<br>" .. Text.Format("      " .. activationConditionText, {Size = 16})
        end

        entry:SetType(_T.TYPES.LEFT_ALIGN)
        entry:SetText(Text.Format(text, {
            Color = "ffffff",
            Size = 17,
        }))
        entry:GetMovieClip().text_txt.width = QuickExamine.GetContainerWidth()
        entry:GetMovieClip().text_txt.height = entry:GetMovieClip().text_txt.textHeight
    end

    self:CreateDivider("EpicEnemiesDivider", container)
end