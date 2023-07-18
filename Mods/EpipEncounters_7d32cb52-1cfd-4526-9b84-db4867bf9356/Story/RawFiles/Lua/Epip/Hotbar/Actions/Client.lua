
---@class Feature_HotbarActions
local Actions = Epip.GetFeature("Feature_HotbarActions")

---------------------------------------------
-- METHODS
---------------------------------------------

---Attempts to execute an action.
---@param char EclCharacter
---@param action string|Feature_HotbarActions_Action
function Actions.TryExecuteAction(char, action)
    if type(action) == "string" then -- String overload.
        action = Actions.GetAction(action)
    end

    -- Forward the event if the action is not on cooldown.
    if not Actions.IsActionOnCooldown(action) then
        -- Forward event to server
        Net.PostToServer(Actions.NET_MSG_ACTION_USED, {
            CharacterNetID = char.NetID,
            ActionID = action.ID,
        })

        Actions:DebugLog("Forwarding action event", action.ID)

        Actions.Events.ActionUsed:Throw({
            Action = action,
            Character = char,
        })

        if action.Cooldown then
            Actions.SetActionCooldown(action, action.Cooldown)
        end
    end
end

---Sets the cooldown for a hotkey.
---@param action string|Feature_HotbarActions_Action
---@param cooldown number In seconds.
function Actions.SetActionCooldown(action, cooldown)
    if type(action) == "table" then -- Table overload.
        action = action.ID
    end

    Actions._ActionCooldowns[action] = {
        Time = Ext.Utils.MonotonicTime(),
        Cooldown = cooldown,
    }
end

---Returns whether an action is on cooldown.
---@param action string|Feature_HotbarActions_Action
---@return boolean
function Actions.IsActionOnCooldown(action)
    if type(action) == "table" then -- Table overload.
        action = action.ID
    end
    local lastUse = Actions._ActionCooldowns[action]
    local onCooldown = false

    if lastUse then
        local timePassed = (Ext.Utils.MonotonicTime() - lastUse.Time) / 1000 -- In seconds.

        if timePassed < lastUse.Cooldown then
            onCooldown = true
        end
    end

    return onCooldown
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the action to open the custom journal.
Actions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == "EPIP_Journal" then
        Client.UI.Journal.Setup()
    end
end)

-- Listen for respective Input actions.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    local action = ev.Action.ID
    if action == "EpicEncounters_Meditate" then
        Actions.TryExecuteAction(ev.Character, "EE_Meditate")
    elseif action == "EpipEncounters_SourceInfuse" then
        Actions.TryExecuteAction(ev.Character, "EE_SourceInfuse")
    end
end)