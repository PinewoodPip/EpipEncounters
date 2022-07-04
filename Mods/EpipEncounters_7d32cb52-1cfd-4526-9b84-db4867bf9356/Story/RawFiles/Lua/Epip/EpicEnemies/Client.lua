
local EpicEnemies = Epip.Features.EpicEnemies

---@type EpicEnemies_Hook_GetActivationConditionDescription
EpicEnemies.Hooks.GetActivationConditionDescription = EpicEnemies:AddHook("GetActivationConditionDescription")

---@type OptionsSettingsOption[]
local Settings = {
    {
        ID = "EpicEnemies_Header",
        Type = "Header",
        Label = "Epic Enemies is a randomizer feature that gives enemies in combat<br>random keyword effects, artifacts and other boons.<br><br>The sliders in this menu control the relative chance of each effect being applied; you may set them to 0 to prevent the effect from being applied.<br><br>Every effect has a certain 'point cost', reducing the possibility of enemies appearing with numerous very strong effects. You may configure this points budget to control how many effects enemies gain.", 
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
        local effects = {}

        -- Grab effects from tags
        for i,tag in ipairs(char:GetTags()) do
            local effectID = tag:match(EpicEnemies.EFFECT_TAG_PREFIX .. "(.+)$")

            if effectID then
                table.insert(effects, EpicEnemies.GetEffectData(effectID))
            end
        end

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