
---------------------------------------------
-- Implements settings to improve contrast of keywords in the Combat Log.
---------------------------------------------

local DamageLib = Damage
local Log = Client.UI.CombatLog

---@type Feature
local CombatLogTweaks = {
    ---@type table<htmlcolor, htmlcolor> Maps original colors used by the combat log to higher-contrast alternatives.
    COLOR_REMAPS = {
        [DamageLib.HEALING_TYPES.MagicArmor.Color] = Color.TOOLTIPS.SKILL_SCHOOLS.HYDROSOPHIST, -- Light-blue used by magic armor restoration skill tooltips is actually too bright for the log.
        [Color.TOOLTIPS.SKILL_SCHOOLS.GEOMANCER] = "BD5C02", -- Geomancer skills
        [Color.TOOLTIPS.SKILL_SCHOOLS.NECROMANCER] = "C835DB",
        [Color.TOOLTIPS.SKILL_SCHOOLS.SUMMONING] = "8830DB",
        [Color.TOOLTIPS.STAT_RED] = "DB214E", -- Used for enemy color & critical hits (and possibly more)
    },

    TranslatedStrings = {
        Setting_ImproveDamageTypeContrast_Name = {
            Handle = "had871e76g2f2eg46eeg98cegf12bca05d7e3",
            Text = "Improved Keyword Color Contrast",
            ContextDescription = [[Combat log setting name]],
        },
        Setting_ImproveDamageTypeContrast_Description = {
            Handle = "ha02014dfg8648g443agb83agf6fbe7a05e1c",
            Text = "If enabled, the colors of low-contrast keywords in Combat Log messages will be adjusted to lighter ones to improve readability.<br>Affects Magic Armor restoration, Geomancer/Necromancer/Summoning skills, and enemy & critical hit colors.",
            ContextDescription = [[Setting tooltip for "Improve damage type color contrast"]],
        },
    }
}
Epip.RegisterFeature("Features.CombatLogTweaks", CombatLogTweaks)
local TSK = CombatLogTweaks.TranslatedStrings

local Settings = {
    ImproveDamageTypeContrast = CombatLogTweaks:RegisterSetting("ImproveDamageTypeContrast", {
        Type = "Boolean",
        Name = TSK.Setting_ImproveDamageTypeContrast_Name,
        Description = TSK.Setting_ImproveDamageTypeContrast_Description,
        DefaultValue = false,
    })
}

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Adjust color of damage types to improve contrast.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local message = ev.ParsedMessage
    if not message then return end

    -- Remap healing & skill colors
    if message:GetClassName() == "UI.CombatLog.Messages.Healing" then
        ---@cast message UI.CombatLog.Messages.Healing
        for _,hit in ipairs(message.Damage) do
            hit.Color = CombatLogTweaks.COLOR_REMAPS[hit.Color] or hit.Color
        end
    elseif message:GetClassName() == "UI.CombatLog.Messages.Skill" then
        ---@cast message UI.CombatLog.Messages.Skill
        if message.Target ~= message.TARGET_TYPES.SUMMON then
            message.SkillColor = CombatLogTweaks.COLOR_REMAPS[message.SkillColor] or message.SkillColor
        else
            message.TargetCharacterColor = CombatLogTweaks.COLOR_REMAPS[message.TargetCharacterColor] or message.TargetCharacterColor
        end
    end

    -- Remap character colors
    if message:ImplementsClass("UI.CombatLog.Messages.Character") then
        ---@cast message UI.CombatLog.Messages.Character
        message.CharacterColor = CombatLogTweaks.COLOR_REMAPS[message.CharacterColor] or message.CharacterColor
    end
    if message:ImplementsClass("UI.CombatLog.Messages.CharacterInteraction") or message:GetClassName() == "UI.CombatLog.Messages.CriticalHit" then
        ---@cast message UI.CombatLog.Messages.CharacterInteraction|UI.CombatLog.Messages.CriticalHit
        message.TargetColor = CombatLogTweaks.COLOR_REMAPS[message.TargetColor] or message.TargetColor
    end
    if message:GetClassName() == "UI.CombatLog.Messages.Attack" then
        ---@cast message UI.CombatLog.Messages.Attack
        message.TargetCharacterColor = CombatLogTweaks.COLOR_REMAPS[message.TargetCharacterColor] or message.TargetCharacterColor
    end
end, {
    Priority = -math.maxinteger,
    EnabledFunctor = function ()
        return Settings.ImproveDamageTypeContrast:GetValue() == true
    end
})