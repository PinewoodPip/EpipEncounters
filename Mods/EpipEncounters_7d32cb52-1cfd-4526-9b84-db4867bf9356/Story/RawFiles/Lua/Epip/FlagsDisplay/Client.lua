
local EnemyHealthBar = Client.UI.EnemyHealthBar

---@class Feature_FlagsDisplay
local FlagsDisplay = Epip.GetFeature("Feature_FlagsDisplay")

---------------------------------------------
-- SETTINGS
---------------------------------------------

-- Setting to enable/disable the feature.
FlagsDisplay.Settings.Enabled = FlagsDisplay:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = FlagsDisplay.TranslatedStrings.Setting_Name,
    Description = FlagsDisplay.TranslatedStrings.Setting_Description,
    Context = "Client",
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the flags that should be shown for an entity.
---@param entity EclItem|EsvItem
---@return string[]
function FlagsDisplay.GetFlags(entity)
    local hook = FlagsDisplay.Hooks.GetFlags:Throw({
        Entity = entity,
        Flags = {},
    })

    return hook.Flags
end

---@override
function FlagsDisplay:IsEnabled()
    return FlagsDisplay:GetSettingValue(FlagsDisplay.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Render flags in the EnemyHealthBar when shift is held.
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    if Client.Input.IsShiftPressed() and FlagsDisplay:IsEnabled() and (ev.Character or ev.Item) then
        local flags = FlagsDisplay.GetFlags(ev.Character or ev.Item)

        FlagsDisplay:DebugLog("Rendering flags:")
        FlagsDisplay:Dump(flags)

        for _,flag in ipairs(flags) do
            table.insert(ev.Labels, flag)
        end
    end
end)

-- Default implementation of GetFlags.
FlagsDisplay.Hooks.GetFlags:Subscribe(function (ev)
    local isChar = Entity.IsCharacter(ev.Entity)

    if isChar then
        local char = ev.Entity ---@cast char EclCharacter
        local combatComponent = Ext.Entity.GetCombatComponent(char.Base.Entity:GetComponent("Combat"))
        local flags = FlagsDisplay:GetUserVariable(char, FlagsDisplay.USERVAR)

        if not Character.IsDead(char) then
            if char.Stats.TALENT_ResistDead and flags.CanUseResistDeadTalent then
                table.insert(ev.Flags, FlagsDisplay.TranslatedStrings.DeathResist:GetString())
            end
    
            if combatComponent then
                -- Attack of opportunity
                if char.Stats.TALENT_AttackOfOpportunity and combatComponent.HasAttackOfOpportunity > 0 then
                    table.insert(ev.Flags, FlagsDisplay.TranslatedStrings.AttackOfOpportunity:GetString())
                end
    
                -- Cannot fight.
                if not combatComponent.CanFight then
                    table.insert(ev.Flags, FlagsDisplay.TranslatedStrings.CannotFight:GetString())
                end
            end

            -- AI archetype.
            if not Character.IsPlayer(char) then
                table.insert(ev.Flags, string.format(FlagsDisplay.TranslatedStrings.AI_Archetype:GetString(), Text.Capitalize(char.Archetype)))
            end
        end
    end
end)