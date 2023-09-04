
---@class Features.PreferredTargetDisplay
local PreferredTargetDisplay = Epip.GetFeature("Features.PreferredTargetDisplay")

---@param target EsvCharacter
---@param source EsvCharacter
---@param enabled boolean
function PreferredTargetDisplay.SetTag(target, source, enabled)
    if not target or not source then return nil end

    local tauntedTag = PreferredTargetDisplay.TAUNTED_TAG_PREFIX .. source.MyGuid
    local tauntingTag = PreferredTargetDisplay.TAUNTING_TAG_PREFIX .. target.MyGuid

    if enabled then
        Osi.SetTag(target.MyGuid, tauntedTag)
        Osi.SetTag(source.MyGuid, tauntingTag)

        Osiris.GetDatabase("DB_PIP_PreferredTargetDisplay_Tagged", 2):Set(source, target)
    else
        Osi.ClearTag(target.MyGuid, tauntedTag)
        Osi.ClearTag(source.MyGuid, tauntingTag)

        Osiris.GetDatabase("DB_PIP_PreferredTargetDisplay_Tagged", 2):Delete(source, target)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener("PROC_AMER_GEN_FilteredStatus_Applied", 4, "after", function(char, source, status, _)
    if status == "TAUNTED" then
        char = Character.Get(char) ---@type EsvCharacter
        source = Character.Get(source) ---@type EsvCharacter

        PreferredTargetDisplay.SetTag(char, source, true)
    end
end)

---@param status EsvStatusConsume
local function RemoveTags(status)
    if status.StatusId == "TAUNTED" then
        local source = Character.Get(status.StatusSourceHandle) ---@type EsvCharacter
        local target = Character.Get(status.OwnerHandle) ---@type EsvCharacter

        PreferredTargetDisplay.SetTag(target, source, false)
    end
end

Ext.Events.BeforeStatusDelete:Subscribe(function(ev)
    RemoveTags(ev.Status)
end)

Osiris.RegisterSymbolListener("CharacterDied", 1, "after", function(targetCharGUID)
    local targetChar = Character.Get(targetCharGUID)

    local tuples = Osiris.GetDatabase("DB_PIP_PreferredTargetDisplay_Tagged", 2):Query(nil, targetCharGUID)
    for _,tuple in ipairs(tuples) do
        local sourceChar = Character.Get(tuple[1])
        PreferredTargetDisplay.SetTag(targetChar, sourceChar, false)
    end
end)

Osiris.RegisterSymbolListener("CharacterStatusRemoved", 3, "after", function(targetCharGUID, status, _)
    if status == "TAUNTED" then
        local char = Character.Get(targetCharGUID)
        local tuples = Osiris.GetDatabase("DB_PIP_PreferredTargetDisplay_Tagged", 2):Query(nil, char)
        for _,tuple in ipairs(tuples) do
            PreferredTargetDisplay.SetTag(char, Character.Get(tuple[1]), false)
        end
    end
end)

Ext.Events.BeforeStatusApply:Subscribe(function(ev)
    local status = ev.Status ---@cast status EsvStatusConsume We only check TAUNTED.
    if status.StatusId == "TAUNTED" then
        local source = Character.Get(status.StatusSourceHandle) ---@type EsvCharacter
        local target = Character.Get(status.OwnerHandle) ---@type EsvCharacter

        -- An character can only be taunted by one other character at a time - we must clear its previous relation.
        for _,tag in pairs(target:GetTags()) do
            local tauntedByGUID = tag:match(PreferredTargetDisplay.TAUNTED_TAG_PREFIX .. "(.+)$")

            if tauntedByGUID then
                local oldTaunter = Character.Get(tauntedByGUID)

                PreferredTargetDisplay.SetTag(target, oldTaunter, false)
            end
        end

        PreferredTargetDisplay.SetTag(target, source, true)
    end
end)