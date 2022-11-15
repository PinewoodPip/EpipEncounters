
---@class ArtifactLib
local Artifact = Artifact

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char has the artifact power active.
---@param char EsvCharacter
---@param artifact ArtifactLib_ArtifactDefinition|string
---@return boolean
function Artifact.IsEquipped(char, artifact)
    local artifactID = artifact
    if type(artifact) == "table" then artifactID = artifact.ID end
    local _, _, amount = Osiris.DB_AMER_Artifacts_EquippedEffects:Get(char.MyGuid, artifactID, nil)

    return amount and amount > 0
end

---Returns a list of artifact powers active on char.
---@param char EsvCharacter
---@return ArtifactLib_ArtifactDefinition[]
function Artifact.GetEquippedPowers(char)
    local tuples = Osiris.DB_AMER_Artifacts_EquippedEffects:GetTuples(char.MyGuid, nil, nil)
    local artifacts = {}

    for _,tuple in ipairs(tuples) do
        local artifactID = tuple[2]
        local def = Artifact.GetData(artifactID)

        if def then
            table.insert(artifacts, def)
        else
            Artifact:LogError("Artifact has no definition: " .. artifactID)
        end
    end

    return artifacts
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