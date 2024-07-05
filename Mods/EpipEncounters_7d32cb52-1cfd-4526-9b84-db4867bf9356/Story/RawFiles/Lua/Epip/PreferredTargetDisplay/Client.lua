
---@class Features.PreferredTargetDisplay
local PreferredTargetDisplay = Epip.GetFeature("Features.PreferredTargetDisplay")
local TSK = PreferredTargetDisplay.TranslatedStrings

---Returns a label showing the AI preference of a character.
---@param char EclCharacter
---@return string? -- `nil` if the character has no special general consideration to the AI.
function PreferredTargetDisplay.GetPreferredString(char)
    local str = nil

    if Character.IsPreferredByAI(char) then
        str = TSK.AggroEffect_Preferred:GetString()
    elseif Character.IsUnpreferredByAI(char) then
        str = TSK.AggroEffect_Unpreferred:GetString()
    elseif Character.IsIgnoredByAI(char) then
        str = TSK.AggroEffect_Ignored:GetString()
    end

    return str
end

---Returns a label indicating taunted/taunting status of a character.
---@param char EclCharacter
---@return string?
function PreferredTargetDisplay.GetTauntString(char)
    local str = "" ---@type string?

    for _,tag in ipairs(char:GetTags()) do
        local tauntSourceGUID = tag:match(PreferredTargetDisplay.TAUNTED_TAG_PREFIX .. "(.+)$")
        local tauntTargetGUID = tag:match(PreferredTargetDisplay.TAUNTING_TAG_PREFIX .. "(.+)$")

        if tauntSourceGUID then
            local enemy = Character.Get(tauntSourceGUID)
            local enemyName = Character.GetDisplayName(enemy)
            str = str .. TSK.AggroEffect_TauntedBy:Format(enemyName)
        end

        if tauntTargetGUID then
            local enemy = Character.Get(tauntTargetGUID)
            local enemyName = Character.GetDisplayName(enemy)
            if str ~= "" then str = str .. "<br>" end -- Add a line break if the character is both taunting and being taunted.
            str = str .. TSK.AggroEffect_Taunting:Format(enemyName)
        end
    end

    if str == "" then str = nil end
    return str
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    local settingValue = Settings.GetSettingValue("EpipEncounters", "PreferredTargetDisplay")
    local char = ev.Character

    if char and settingValue > 1 then
        local holdingShift = Client.Input.IsShiftPressed()
        local enabled = holdingShift
        if settingValue == 3 then enabled = not holdingShift end

        if enabled then
            local preferredStr = PreferredTargetDisplay.GetPreferredString(char)
            local tauntStr = PreferredTargetDisplay.GetTauntString(char)

            if preferredStr then
                table.insert(ev.Labels, preferredStr)
            end

            if tauntStr then
                table.insert(ev.Labels, tauntStr)
            end
        end
    end
end)