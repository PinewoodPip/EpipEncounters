
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

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

---Returns whether a skill state can be cancelled.
---@param state EsvSkillState
---@return boolean
function AnimCancel.IsSkillStateFinished(state)
    return AnimCancel.Hooks.IsSkillStateFinished:Throw({
        State = state,
        Finished = false,
    }).Finished
end

---Cancels the animation for a character.
---@param char EsvCharacter
---@param skillID string
function AnimCancel.CancelAnimation(char, skillID)
    AnimCancel:DebugLog("Server anim cancelled for", char.DisplayName)
    AnimCancel._SendCancellationNetMessage(char, skillID)
end

---Sends a net message to char notifying them that a skill can be cancelled.
---@param char EsvCharacter
---@param skillID string
function AnimCancel._SendCancellationNetMessage(char, skillID)
    skillID = skillID:gsub("_%-1", "")
    Net.PostToCharacter(char, AnimCancel.NET_MESSAGE, {SkillID = skillID, CharacterNetID = char.NetID})
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for SkillCast event to cancel non-problematic skill types.
Osiris.RegisterSymbolListener("SkillCast", 4, "after", function(charGUID, skillID, _, _)
    local char = Character.Get(charGUID)
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)

    if AnimCancel.SAFE_SKILL_TYPES:Contains(skill.SkillType) then
        AnimCancel.CancelAnimation(char, skillID)
    end
end)

-- Listen for controlled player characters completing spellcasts to notify them that the animation can be cancelled.
-- This requires tracking the progress of the UseSkill action.
Osiris.RegisterSymbolListener("NRD_OnActionStateEnter", 2, "after", function (charGUID, action)
    if action == "UseSkill" then
        local char = Character.Get(charGUID)
        local eventID = string.format("AnimationCancelling_%s", charGUID)

        if Character.IsPlayer(char) then
            GameState.Events.RunningTick:Subscribe(function (_)
                char = Character.Get(charGUID)
                local state = Character.GetSkillState(char)
                local isFinished = state and AnimCancel.IsSkillStateFinished(state)

                if isFinished then
                    AnimCancel.CancelAnimation(char, state.SkillId)
                end

                if state == nil or isFinished then
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

        -- Larian shrinks this list down as they fire the projectiles. Yup.
        ev.Finished = state.CastTextKeyTimeRemaining <= 0
    end
end)