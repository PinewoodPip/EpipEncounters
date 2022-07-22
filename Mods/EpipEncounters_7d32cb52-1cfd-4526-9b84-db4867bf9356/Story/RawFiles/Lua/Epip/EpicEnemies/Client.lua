
---@meta Library: EpicEnemies, ContextClient, Epip.Features.EpicEnemies

local EpicEnemies = Epip.Features.EpicEnemies

---@type EpicEnemies_Hook_GetActivationConditionDescription
EpicEnemies.Hooks.GetActivationConditionDescription = EpicEnemies:AddHook("GetActivationConditionDescription")

---@type OptionsSettingsOption[]
local Settings = {
    {
        ID = "EpicEnemies_Header",
        Type = "Header",
        Label = "Epic Enemies is a randomizer feature that gives enemies in combat<br>random keyword effects, artifacts and other boons.<br><br>The sliders in this menu control the relative chance of each effect being applied; you may set them to 0 to prevent the effect from being applied.<br><br>Every effect has a certain 'point cost', reducing the possibility of enemies appearing with numerous very strong effects. You may configure this points budget to control how many effects enemies gain.<br>Enemies affected by this feature gain 2 free Generic reaction charges per turn.", 
    },
    {
        ID = "EpicEnemies_Toggle",
        Type = "Checkbox",
        Label = "Enabled",
        ServerOnly = true,
        SaveOnServer = true,
        Tooltip = "Enables the Epic Enemies feature.",
        DefaultValue = false,
    },
    {
        ID = "EpicEnemies_PointsBudget",
        Type = "Slider",
        Label = "Points Budget",
        SaveOnServer = true,
        ServerOnly = true,
        MinAmount = 1,
        MaxAmount = 100,
        Interval = 1,
        DefaultValue = 30,
        HideNumbers = false,
        Tooltip = "Controls how many effects enemies affected by Epic Enemies can receive. Effects cost a variable amount of points based on how powerful they are.",
    },
    {
        ID = "EpicEnemies_PointsMultiplier_Bosses",
        Type = "Slider",
        Label = "Boss Enemy Points Multiplier",
        SaveOnServer = true,
        ServerOnly = true,
        MinAmount = 0,
        MaxAmount = 5,
        Interval = 0.01,
        DefaultValue = 1,
        HideNumbers = false,
        Tooltip = "A multiplier for the amount of points boss enemies receive.",
    },
    {
        ID = "EpicEnemies_PointsMultiplier_Normies",
        Type = "Slider",
        Label = "Normal Enemy Points Multiplier",
        SaveOnServer = true,
        ServerOnly = true,
        MinAmount = 0,
        MaxAmount = 5,
        Interval = 0.01,
        DefaultValue = 0,
        HideNumbers = false,
        Tooltip = "A multiplier for the amount of points normal enemies receive.",
    },
}

Client.UI.OptionsSettings.RegisterMod("EpicEnemies", {
    ServerOnly = true,
    SideButtonLabel = "Epic Enemies",
    TabHeader = Text.Format("Epic Enemies", {Color = "7e72d6", Size = 23}),
    -- Options = Settings -- TODO investigate hang ???
})

Client.UI.OptionsSettings.RegisterOptions("EpicEnemies", Settings)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EclCharacter
---@param visibleOnly boolean? Defaults to false.
---@return EpicEnemiesEffect[] -- In order of application(? unconfirmed)
function EpicEnemies.GetAppliedEffects(char, visibleOnly)
    local effects = {}

    -- Grab effects from tags
    for _,tag in ipairs(char:GetTags()) do
        local effectID = tag:match(EpicEnemies.EFFECT_TAG_PREFIX .. "(.+)$")

        if effectID then
            local effectData = EpicEnemies.GetEffectData(effectID)

            if effectData then
                if not visibleOnly or (visibleOnly and effectData.Visible) then
                    table.insert(effects, effectData)
                end
            else
                EpicEnemies:LogError("Found an applied effect with no data registered: " .. effectID)
            end
        end
    end

    return effects
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class EpicEnemies_Hook_GetActivationConditionDescription : Hook
---@field RegisterHook fun(self, handler:fun(text:string, condition:EpicEnemiesActivationCondition, char:EclCharacter))
---@field Return fun(self, text:string, condition:EpicEnemiesActivationCondition, char:EclCharacter)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Render effect info into the status tooltip.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    if status.StatusId == "PIP_OSITOOLS_EpicBossesDisplay" then
        local effects = EpicEnemies.GetAppliedEffects(char)
        local str = ""

        for i,effect in ipairs(effects) do
            if effect.Visible or effect.Visible == nil then
                local activationConditionText = EpicEnemies.Hooks.GetActivationConditionDescription:Return("", effect.ActivationCondition, char)

                str = str .. Text.Format("%s<br>%s<br>%s", {
                    FormatArgs = {
                        Text.Format(Text.Format("• ", {Size = 28}) .. effect.Name, {FontType = Text.FONTS.BOLD, Color = "088cc4"}),
                        Text.Format("      " .. effect.Description, {Size = 17}),
                        Text.Format("      " .. activationConditionText, {Size = 16}),
                    }
                })
                str = str .. "<br>"
            end
        end

        table.insert(tooltip.Data, {
            Label = str,
            Type = "StatusDescription",
            Value = 1,
        })
    end
end)

-- Render category selector.
Client.UI.OptionsSettings.Events.TabRendered:RegisterListener(function (customTab, index)
    if customTab and customTab.Mod == "EpicEnemies" then
        local option = {
            ID = "EpicEnemies_CategorySelector",
            Mod = "EpicEnemies",
            Label = Text.Format("Effect Categories", {FontType = Text.FONTS.BOLD}),
            DefaultValue = 1,
            Type = "Selector",
            Options = {},
            VisibleAtTopLevel = false,
        }

        for i,category in ipairs(EpicEnemies.CATEGORIES) do
            local tab = {
                Label = category.Name,
                SubSettings = {
                    "EpicEnemies_CategoryWeight_" .. category.ID,
                },
            }
        
            for z,effectID in ipairs(category.Effects) do
                table.insert(tab.SubSettings, effectID)
            end
        
            table.insert(option.Options, tab)
        end

        Client.UI.OptionsSettings.RenderOption(option, nil, nil)
    end
end)

-- Render within Quick Examine.
local QuickExamine = Epip.Features.QuickExamine
local Generic = Client.UI.Generic
local _T = Generic.ELEMENTS.Text
QuickExamine.Events.EntityChanged:RegisterListener(function (entity)
    local container = QuickExamine.GetContainer()

    ---@type EpicEnemiesExtendedEffect[]
    local effects = EpicEnemies.GetAppliedEffects(entity, true)

    if #effects > 0 then
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

        local header = container:AddChild("EpicEnemies_Header", "Text")
        header:SetText(Text.Format("Epic Enemies Effects", {Color = "ffffff", Size = 19}))
        header:SetSize(QuickExamine.WIDTH, 30)

        if #sortedEffects.Artifacts > 0 then
            local artifactContainer = container:AddChild("EpicEnemies_Artifacts", "HorizontalList")
            artifactContainer:SetSize(QuickExamine.WIDTH * 0.8, 35)
            artifactContainer:SetCenterInLists(true)

            for _,effect in ipairs(sortedEffects.Artifacts) do
                local artifact = Artifact.ARTIFACTS[effect.Artifact]
                local template = Ext.Template.GetTemplate(string.match(artifact.ItemTemplate, Data.Patterns.GUID)) ---@type ItemTemplate

                local icon = artifactContainer:AddChild(artifact.ID .. "icon", "IggyIcon")
                icon:SetIcon(template.Icon, 32, 32)
                icon.Tooltip = artifact:GetPowerTooltip()
            end
        end

        for _,effect in ipairs(sortedEffects.Other) do
            local entry = container:AddChild(effect.ID, "Text")
            local activationConditionText = EpicEnemies.Hooks.GetActivationConditionDescription:Return("", effect.ActivationCondition, entity)

            local text = Text.Format(Text.Format("• ", {Size = 28}) .. effect.Name, {FontType = Text.FONTS.BOLD, Color = "088cc4"})

            if effect.Description and string.len(effect.Description) > 0 then
                text = text .. "<br>" .. Text.Format("      " .. effect.Description, {Size = 17})
            end

            if effect.ActivationCondition.Type ~= "EffectApplied" then
                text = text .. "<br>" .. Text.Format("      " .. activationConditionText, {Size = 16})
            end

            entry:SetType(_T.TYPES.LEFT_ALIGN)
            entry:SetText(Text.Format(text, {
                Color = "ffffff",
                Size = 17,
            }))
            entry:GetMovieClip().text_txt.width = QuickExamine.WIDTH
            entry:GetMovieClip().text_txt.height = entry:GetMovieClip().text_txt.textHeight
        end

        local div = container:AddChild("MainDiv", "Divider")
        div:SetSize(QuickExamine.DIVIDER_WIDTH, 20)
        div:SetCenterInLists(true)
    end
end)