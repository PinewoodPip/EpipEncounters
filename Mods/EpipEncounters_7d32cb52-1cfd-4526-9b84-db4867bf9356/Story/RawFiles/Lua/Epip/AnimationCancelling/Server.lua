
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")
AnimCancel._TIMERID_NPC_CANCELLING = "Features.AnimationCancelling.NPCCancelling"

---Skill types that can be cancelled right on the SkillCast event,
---needing no special consideration.
---@type DataStructures_Set<SkillType>
AnimCancel.SAFE_SKILL_TYPES = Set.Create({
    "Zone",
    "Cone",
    "Quake",
    "Rain",
    "Rush",
    "Shout",
    "Teleportation",
    "Tornado",
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired each tick for eligible characters in a skill state to decide if the
---skill state has progressed enough to be cancelled.
---Server-only.
---@class Feature_AnimationCancelling_Hook_IsSkillStateFinished
---@field State EsvSkillState
---@field Finished boolean Hookable. Defaults to `false`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether character has finished their current cancellable action state (attack or skill state).
---@param char EsvCharacter
---@return boolean, EsvActionState? -- Whether the state is finished, and the state itself. First return value is `false` if char has no action state.
function AnimCancel.IsActionFinished(char)
    local state = Character.GetActionState(char)
    local finished = false
    if state then
        if state.Type == "Attack" then
            ---@cast state EsvASAttack
            finished = AnimCancel.IsAttackFinished(state)
        elseif state.Type == "UseSkill" then
            local skillState = Character.GetSkillState(char)
            finished = AnimCancel.IsSkillStateFinished(skillState)
        else
            state = nil -- Do not return state if it's not a cancellable one.
        end
    end
    return finished, state
end

---Returns whether a skill state can be cancelled.
---@param state EsvSkillState
---@return boolean
function AnimCancel.IsSkillStateFinished(state)
    return AnimCancel.Hooks.IsSkillStateFinished:Throw({
        State = state,
        Finished = false,
    }).Finished
end

---Returns whether an attack state has finished dealing all hits.
---@param state EsvASAttack
---@return boolean
function AnimCancel.IsAttackFinished(state)
    local mainHandHitsFinished = state.HitCount >= state.TotalHits
    local offhandHitsFinished = state.HitCountOffHand >= state.TotalHitOffHand
    local shootsFinished = state.ShootCount >= state.TotalShoots
    local offhandShootsFinished = state.ShootCountOffHand >= state.TotalShootsOffHand
    return mainHandHitsFinished and offhandHitsFinished and shootsFinished and offhandShootsFinished
end

---Cancels the animation for a character's current action state.
---@param char EsvCharacter
function AnimCancel.CancelAnimation(char)
    AnimCancel:DebugLog("Server anim cancelled for", char.DisplayName)
    if Character.IsPlayer(char) then
        -- Players cancel their animations from their client to avoid issues with skillstate authority (if cancelled from server, it could occur before effects are fully executed), as well as to respect client-side settings.
        AnimCancel._SendCancellationNetMessage(char, Character.GetActionState(char))
    else
        local charGUID = char.MyGuid
        if Osiris.GetFirstFact("DB_ObjectTimer", charGUID, charGUID .. AnimCancel._TIMERID_NPC_CANCELLING, AnimCancel._TIMERID_NPC_CANCELLING) == nil then
            Osi.ProcObjectTimer(charGUID, AnimCancel._TIMERID_NPC_CANCELLING, 80) -- TODO is the timer necessary? Faster AI Spells used it, but it was not commented why.
        end
    end
end

---Returns whether a character can have their animation cancelled.
---@see Feature_AnimationCancelling.IsEnemyCancellingEnabled
---@param char EsvCharacter
---@return boolean
function AnimCancel.IsCharacterEligible(char)
    return Character.IsPlayer(char) or AnimCancel.IsEnemyCancellingEnabled()
end

---Returns whether NPC animations can be cancelled.
---@return boolean
function AnimCancel.IsEnemyCancellingEnabled()
    return AnimCancel.Settings.CancelNPCAnimations:GetValue() == true
end

---Sends a net message to char notifying them that an action state can be cancelled.
---@param char EsvCharacter
---@param actionState EsvActionState
function AnimCancel._SendCancellationNetMessage(char, actionState)
    ---@type Epip_Feature_AnimationCancelling
    local msg = {
        CharacterNetID = char.NetID,
        ActionType = actionState.Type,
        SkillID = nil,
    }
    if actionState.Type == "UseSkill" then -- Fetch skill ID
        ---@cast actionState EsvASUseSkill
        local skillID = actionState.Skill.SkillId
        skillID = Stats.RemoveLevelSuffix(skillID)
        msg.SkillID = skillID
    end
    Net.PostToCharacter(char, AnimCancel.NET_MESSAGE, msg)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for SkillCast event to cancel non-problematic skill types.
Osiris.RegisterSymbolListener("SkillCast", 4, "after", function(charGUID, skillID, _, _)
    local char = Character.Get(charGUID)
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
    if AnimCancel.SAFE_SKILL_TYPES:Contains(skill.SkillType) and AnimCancel.IsCharacterEligible(char) then
        AnimCancel.CancelAnimation(char)
    end
end)

-- Listen for characters completing spellcasts to notify them that the animation can be cancelled.
-- This requires tracking the progress of the UseSkill action.
Osiris.RegisterSymbolListener("NRD_OnActionStateEnter", 2, "after", function (charGUID, action)
    if action == "UseSkill" or action == "Attack" then
        local char = Character.Get(charGUID)
        local eventID = string.format("AnimationCancelling_%s", charGUID)
        if AnimCancel.IsCharacterEligible(char) then
            GameState.Events.RunningTick:Subscribe(function (_)
                char = Character.Get(charGUID)
                local isFinished, state = AnimCancel.IsActionFinished(char)
                if state and isFinished then
                    AnimCancel.CancelAnimation(char)
                end
                if not state or isFinished then -- Remove the listener once no longer necessary
                    GameState.Events.RunningTick:Unsubscribe(eventID)
                end
            end, {StringID = eventID})
        end
    end
end)

-- Broadcast item pick up state being entered.
Osiris.RegisterSymbolListener("NRD_OnActionStateEnter", 2, "before", function (charGUID, action)
    if action == "PickUp" and Osiris.GetFirstFact("DB_IsPlayer", charGUID) ~= nil then
        Net.PostToCharacter(charGUID, AnimCancel.NETMSG_ITEM_PICKUP)
    end
end)

-- Cancel NPC animations after a short delay.
Osiris.RegisterSymbolListener("ProcObjectTimerFinished", 2, "after", function(charGUID, event)
    if event == AnimCancel._TIMERID_NPC_CANCELLING then
        Osi.PlayAnimation(charGUID, "noprepare")
    end
end)

---------------------------------------------
-- Default implementations of IsSkillStateFinished hook.
---------------------------------------------

local hook = AnimCancel.Hooks.IsSkillStateFinished

-- Summon skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "Summon" then
        ---@cast state EsvSkillStateSummon
        ev.Finished = state.CastTextKeyTimeRemaining <= 0
    end
end)

-- Projectile skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "Projectile" then
        ---@cast state EsvSkillStateProjectile
        if state.CastTimeRemaining <= 0 then
            local targetsReady = 0
            for _,target in ipairs(state.Targets) do
                if target.NumProjectiles == 0 then
                    targetsReady = targetsReady + 1
                end
            end

            ev.Finished = targetsReady == #state.Targets
        end
    end
end)

-- Jump skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "Jump" then
        ---@cast state EsvSkillStateJump
        ev.Finished = state.NextTextKeyTimeRemaining <= 0
    end
end)

-- MultiStrike skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "MultiStrike" then
        ---@cast state EsvSkillStateMultiStrike
        ev.Finished = state.CastTextKeyTimeRemaining <= 0
    end
end)

-- ProjectileStrike skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "ProjectileStrike" then
        ---@cast state EsvSkillStateProjectileStrike

        -- Larian shrinks this list down as they fire the projectiles. Yup.
        ev.Finished = #state.ProjectileTimers == 0 and state.NextProjectileTimeRemaining <= 0
    end
end)

-- Target skills
hook:Subscribe(function (ev)
    local state = ev.State
    if state.Type == "Target" then
        ---@cast state EsvSkillStateTarget
        ev.Finished = state.CastTextKeyTimeRemaining <= 0
    end
end)
