
local AI = {
    ACTIONS_LOGGED_COUNT = 3,
    LOGGING_SPACING = 40,
    LOGGED_PROPERTIES = {
        "ActionType",
        "SkillId",
        "_Target",
        "FinalScore",
        "PositionFinalScore",
        "MovementFinalScore",
        "SavingActionPoints",
        "MovementType",
        "Distance",
        "FreeActionMultiplier",
        "UseMovementSkill",
        -- TODO different settings for different types of actions
    },
    PROPERTY_COMMENTS = {
        ["SavingActionPoints"] = "Whether this action saves AP for better actions in the future(?)",
        ["Distance"] = "Distance to target, in cm",
    },

    enabled = false,
}
Epip.RegisterFeature("AI", AI)

local function EqualizeSpace(str1, str2, space)
    local normalLength = #str1 + #str2 - 1
    local output = str1 .. " " -- minimum of 1 space

    while normalLength < space do
        output = output .. " "
        normalLength = normalLength + 1
    end

    return output .. str2
end

function AI.StringifyAction(action)
    local str = "    "

    for _,prop in ipairs(AI.LOGGED_PROPERTIES) do
        local nextStr = AI.StringifyActionProperty(action, prop)

        if nextStr ~= "" then
            str = str .. nextStr .. "\n    "
        end
    end

    return str
end

function AI.StringifyActionProperty(action, prop)
    local str = ""

    str = AI:ReturnFromHooks("StringifyProperty", str, action, prop)

    return str
end

AI:RegisterHook("StringifyProperty", function(_, action, prop)
    if prop == "_Target" then
        local name = "NONE"
        local char = Character.Get(action.TargetHandle)

        if char then
            name = char.DisplayName
        end

        return EqualizeSpace("Target1:", name, AI.LOGGING_SPACING)
    else
        local value = action[prop]
        return EqualizeSpace(prop .. ":", tostring(value), AI.LOGGING_SPACING)
    end
end)

-- Append comments
AI:RegisterHook("StringifyProperty", function(str, action, prop)
    if AI.PROPERTY_COMMENTS[prop] then
        str = str .. "   // " .. AI.PROPERTY_COMMENTS[prop]
    end

    return str
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.ModTable == "Epip_Developer" and setting.ID == "DEBUG_AI" then
        AI.enabled = ev.Value
    end
end)

Ext.Events.OnPeekAiAction:Subscribe(function(ev)
    if not AI.enabled then return end

    local char = Character.Get(ev.CharacterHandle)
    local actionType = ev.ActionType or "UNKNOWN"
    local request = ev.Request
    local finalActionIndex = request.AiActionToExecute
    local finalAction = request.AiActions[finalActionIndex]

    local bestActions = {}

    for _,action in pairs(request.AiActions) do
        local canLog = #bestActions < AI.ACTIONS_LOGGED_COUNT

        if canLog then
            table.insert(bestActions, action)
            table.sort(bestActions, function(a, b) return a.ActionFinalScore > b.ActionFinalScore end)

            if #bestActions == AI.ACTIONS_LOGGED_COUNT then
                break
            end
        end
    end

    print("----------------------------------")
    print("Finished scoring for " .. char.DisplayName)
    print("Actions Count: " .. request.ActionCount)
    print("Top " .. #bestActions .. " actions:")

    for i,action in ipairs(bestActions) do
        print("  " .. i .. ".\n" .. AI.StringifyAction(action))

        -- _D(action.Score1.Score.DamageAmounts) -- Empty
        -- _D(action.Score1.Score.Flags1)
        -- _D(action.Score1.Score.SoftReasonFlags2)
        -- print(#action.Score1.Score.Reason) -- Empty
    end
end)