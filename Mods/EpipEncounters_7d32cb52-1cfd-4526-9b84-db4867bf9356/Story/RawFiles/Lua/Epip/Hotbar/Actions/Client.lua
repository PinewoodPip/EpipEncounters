
local Hotbar = Client.UI.Hotbar

---@class Feature_HotbarActions
local Actions = Epip.GetFeature("Feature_HotbarActions")

---------------------------------------------
-- METHODS
---------------------------------------------

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

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register actions.
for _,action in ipairs(Actions.ACTIONS) do
    if not action.RequiresEE or EpicEncounters.IsEnabled() then
        Hotbar.RegisterAction(action.ID, action)
    
        -- Place the action at a default index
        if action.DefaultIndex then
            Hotbar.SetHotkeyAction(action.DefaultIndex, action.ID)
        end
        
        Hotbar.RegisterActionListener(action.ID, "ActionUsed", function (char, _)
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
        end)
    end
end