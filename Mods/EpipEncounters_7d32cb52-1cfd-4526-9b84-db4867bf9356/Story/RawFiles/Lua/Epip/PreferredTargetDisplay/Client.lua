
local PreferredTargetDisplay = Epip.Features.PreferredTargetDisplay

---@param char EclCharacter
---@return boolean
function PreferredTargetDisplay.IsPreferred(char)
    return char:HasTag(PreferredTargetDisplay.AI_PREFERRED_TAG)
end

---@param char EclCharacter
---@return string?
function PreferredTargetDisplay.GetPreferredString(char)
    local str

    if Character.IsPreferredByAI(char) then
        str = "Preferred by enemies"
    elseif Character.IsUnpreferredByAI(char) then
        str = "Unpreferred by enemies"
    elseif Character.IsIgnoredByAI(char) then
        str = "Ignored by enemies"
    end

    return str
end

---@param char EclCharacter
---@return string?
function PreferredTargetDisplay.GetTauntString(char)
    local str = "" ---@type string?

    for _,tag in ipairs(char:GetTags()) do
        local tauntSourceGUID = tag:match(PreferredTargetDisplay.TAUNTED_TAG_PREFIX .. "(.+)$")
        local tauntTargetGUID = tag:match(PreferredTargetDisplay.TAUNTING_TAG_PREFIX .. "(.+)$")

        if tauntSourceGUID then
            local enemy = Character.Get(tauntSourceGUID)

            str = str .. "Taunted by " .. enemy.DisplayName
        end

        if tauntTargetGUID then
            local enemy = Character.Get(tauntTargetGUID)

            if str ~= "" then str = str .. "<br>" end
            
            str = str .. "Taunting " .. enemy.DisplayName
        end
    end

    if str == "" then str = nil end
    return str
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.EnemyHealthBar:RegisterHook("GetBottomText", function(text, char, _)
    local settingValue = Settings.GetSettingValue("EpipEncounters", "PreferredTargetDisplay")

    if char and settingValue > 1 then
        local holdingShift = Client.Input.IsShiftPressed()
        local enabled = holdingShift
        if settingValue == 3 then enabled = not holdingShift end

        if enabled then
            local preferredStr = PreferredTargetDisplay.GetPreferredString(char)
            local tauntStr = PreferredTargetDisplay.GetTauntString(char)

            if preferredStr then
                text = text .. "<br>" .. preferredStr
            end

            if tauntStr then
                text = text .. "<br>" .. tauntStr
            end
        end
    end

    return text
end)