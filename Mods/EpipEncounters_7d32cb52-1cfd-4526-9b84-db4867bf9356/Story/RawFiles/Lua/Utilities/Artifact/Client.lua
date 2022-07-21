
---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char has the artifact power active.
---@param char Character
---@param artifact ArtifactDefinition|string
---@return boolean
function Artifact.IsEquipped(char, artifact)
    local equipped = false
    local artifactID = artifact
    if type(artifact) == "table" then artifactID = artifact.ID end

    equipped = char:HasTag(Artifact.EQUIPPED_TAG_PREFIX .. artifactID)

    return equipped
end