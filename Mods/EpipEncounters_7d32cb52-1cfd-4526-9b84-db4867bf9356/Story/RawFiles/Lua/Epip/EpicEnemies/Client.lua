
local EpicEnemies = Epip.Features.EpicEnemies

---@type table<NetId, EpicEnemiesEffect[]>
EpicEnemies.APPLIED_EFFECTS = {}

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
}

Client.UI.OptionsSettings.RegisterMod("EpicEnemies", {
    ServerOnly = true,
    SideButtonLabel = "Epic Enemies",
    TabHeader = Text.Format("Epic Enemies", {Color = "7e72d6", Size = 23}),
    -- Options = Settings -- TODO investigate hang ???
})

Client.UI.OptionsSettings.RegisterOptions("EpicEnemies", Settings)

for id,effect in pairs(EpicEnemies.EFFECTS) do
    local option = EpicEnemies.GenerateOptionData(effect)

    Client.UI.OptionsSettings.RegisterOption("EpicEnemies", option)
end
-- TODO do this later
---@type OptionsSettingsSelector
local option = {
    ID = "EpicEnemies_CategorySelector",
    Label = Text.Format("Epic Enemies Categories", {FontType = Text.FONTS.BOLD}),
    DefaultValue = 1,
    Type = "Selector",
    Options = {},
}
for i,category in ipairs(EpicEnemies.CATEGORIES) do
    local tab = {
        Label = category.Name,
        SubSettings = {},
    }

    for z,effectID in ipairs(category.Effects) do
        table.insert(tab.SubSettings, effectID)
    end

    table.insert(option.Options, tab)
end
Client.UI.OptionsSettings.RegisterOption("EpicEnemies", option)

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

        local effects = EpicEnemies.APPLIED_EFFECTS[char.NetID]
        if effects then
            local str = ""

            for i,effect in ipairs(effects) do
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

            table.insert(tooltip.Data, {
                Label = str,
                Type = "StatusDescription",
                Value = 1,
            })
        end
    end
end)

Game.Net.RegisterListener("EPIPENCOUNTERS_EpicEnemies_EffectsApplied", function(cmd, payload)
    local char = Ext.GetCharacter(payload.CharacterNetID)
    local effects = payload.Effects

    EpicEnemies.APPLIED_EFFECTS[char.NetID] = effects
end)

Game.Net.RegisterListener("EPIPENCOUNTERS_EpicEnemies_EffectsRemoved", function(cmd, payload)
    local char = Ext.GetCharacter(payload.CharacterNetID)

    EpicEnemies.APPLIED_EFFECTS[char.NetID] = nil
end)