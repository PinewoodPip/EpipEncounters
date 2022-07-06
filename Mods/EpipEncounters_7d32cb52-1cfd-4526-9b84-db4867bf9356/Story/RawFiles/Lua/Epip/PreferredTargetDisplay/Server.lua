
local PreferredTargetDisplay = Epip.Features.PreferredTargetDisplay

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
    else
        Osi.ClearTag(target.MyGuid, tauntedTag)
        Osi.ClearTag(source.MyGuid, tauntingTag)
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

Ext.Events.BeforeStatusDelete:Subscribe(function(ev)
    local status = ev.Status ---@type EsvStatusConsume
    
    if status.StatusId == "TAUNTED" then
        local source = Character.Get(status.StatusSourceHandle) ---@type EsvCharacter
        local target = Character.Get(status.OwnerHandle) ---@type EsvCharacter

        PreferredTargetDisplay.SetTag(target, source, false)
    end
end)

Ext.Events.BeforeStatusApply:Subscribe(function(ev)
    local status = ev.Status ---@type EsvStatusConsume
    
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