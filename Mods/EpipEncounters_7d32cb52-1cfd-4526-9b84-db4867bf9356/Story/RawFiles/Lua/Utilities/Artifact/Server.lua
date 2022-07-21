
---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char has the artifact power active.
---@param char Character
---@param artifact ArtifactDefinition|string
---@return boolean
function Artifact.IsEquipped(char, artifact)
    local artifactID = artifact
    if type(artifact) == "table" then artifactID = artifact.ID end
    local _, _, amount = Osiris.DB_AMER_Artifacts_EquippedEffects(char.MyGuid, artifactID, nil)

    return amount and amount > 0
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener("PROC_AMER_Artifacts_EquipEffects", 3, "after", function(char, artifactID, sourceType)
    -- Apply tag.
    Osi.SetTag(char, Artifact.EQUIPPED_TAG_PREFIX .. artifactID)
end)

Osiris.RegisterSymbolListener("PROC_AMER_Artifacts_UnequipEffects", 3, "after", function(char, artifactID, sourceType)
    -- Remove tag.
    if not Artifact.IsEquipped(Character.Get(char), artifactID) then
        Osi.ClearTag(char, Artifact.EQUIPPED_TAG_PREFIX .. artifactID)
    end
end)