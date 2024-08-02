
---------------------------------------------
-- Appends a warning to mouse tooltips when moving to a position
-- in combat would result in the character exiting combat.
---------------------------------------------

local CombatTurn = Client.UI.CombatTurn
local Tooltip = Client.Tooltip
local V = Vector.Create

---@type Feature
local CombatRange = {
    TranslatedStrings = {
        Label_ExitWarning = {
            Handle = "h3e106820ge677g4e64gae9fgf308a5c93b43",
            Text = "Moving here would exit combat.",
            ContextDescription = [[Tooltip when trying to move too far away in combat]],
        },
    },
}
Epip.RegisterFeature("Features.TooltipAdjustments.CombatRangeWarning", CombatRange)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the warning can be shown for a character.
---Warnings can be shown if the character is in combat and either planning to move or preparing a movement skill.
---@param char EclCharacter
---@return boolean
function CombatRange.CanShowWarning(char)
    local canShow = Character.IsInCombat(char)
    local skillID = Character.GetCurrentSkill(char)
    if canShow and skillID then
        local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
        canShow = canShow and (Stats.MOVEMENT_SKILLS_TYPES[skill.SkillType] or (skill.SkillType == "Projectile" and skill.MovingObject == "Caster")) -- Only show the warning when using movement skills, including "Flight" skills.
    end
    return canShow
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show the warning by the cursor while in combat.
Tooltip.Hooks.RenderMouseTextTooltip:Subscribe(function (ev)
    local char = Client.GetCharacter()
    local combat = Combat.GetCombat(Combat.GetCombatID(char)) ---@cast combat EclTurnManagerCombat
    if combat then
        -- Fetch enemy entries in the UI, as we cannot currently determine hostility relations on the client.
        local enemies = {} ---@type EclCharacter[] Items cannot be enemies(?).
        local combatants = Combat.GetParticipants(combat)
        for _,combatant in ipairs(combatants) do
            local entry = CombatTurn.GetEntityElement(combatant)
            if entry and entry.typeColour == CombatTurn.HIGHLIGHT_COLORS.ENEMY then
                table.insert(enemies, combatant)
            end
        end
        if enemies[1] then
            -- Find closest enemy
            local targetPos = Pointer.GetWalkablePosition()
            local closestEnemy = nil
            local closestDist = nil
            for _,enemy in ipairs(enemies) do
                local dist = (targetPos - V(enemy.WorldPos)).Length
                if not closestEnemy or dist < closestDist then
                    closestEnemy = enemy
                    closestDist = dist
                end
            end
            -- Append the warning if the position is too far away
            if closestDist >= Character.COMBAT_EXIT_RANGE then
                ev.Text = ev.Text .. Text.Format("%s<br>", {
                    FormatArgs = {CombatRange.TranslatedStrings.Label_ExitWarning},
                    Color = Color.LARIAN.YELLOW,
                    Size = 15,
                })
            end
        end
    end
end, {EnabledFunctor = function ()
    return CombatRange.CanShowWarning(Client.GetCharacter())
end})
