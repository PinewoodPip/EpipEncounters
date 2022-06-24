
local EpicEnemies = Epip.Features.EpicEnemies

---@type table<NetId, EpicEnemiesEffect[]>
EpicEnemies.APPLIED_EFFECTS = {}

---@type OptionsSettingsOption[]
local Settings = {
    {
        ID = "EpicEnemies_Header",
        Type = "Header",
        Label = "Epic Enemies is a randomizer feature that gives enemies in combat<br>random keyword effects, artifacts and other boons.",
    },
    {
        ID = "EpicEnemies_Header2",
        Type = "Header",
        Label = "random keyword effects, artifacts and other boons.",
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
                -- str = str .. Text.Format("<img src=\'Icon_BulletPoint\'> %s<br>%s", {
                str = str .. Text.Format("%s<br>%s", {
                    FormatArgs = {
                        Text.Format(Text.Format("• ", {Size = 28}) .. effect.Name, {FontType = Text.FONTS.BOLD, Color = "088cc4"}),
                        Text.Format("      " .. effect.Description, {Size = 17}),
                    }
                })
                str = str .. "<br>"
            end

            print(str)

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