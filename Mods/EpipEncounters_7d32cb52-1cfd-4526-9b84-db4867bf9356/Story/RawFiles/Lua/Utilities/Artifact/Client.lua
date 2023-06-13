
---@class ArtifactLib
local Artifact = Artifact

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char has the artifact power active.
---@param char EclCharacter
---@param artifact ArtifactLib_ArtifactDefinition|string
---@return boolean
function Artifact.IsEquipped(char, artifact)
    local equipped = false
    local artifactID = artifact
    local userVar = Artifact:GetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR)
    if type(artifact) == "table" then artifactID = artifact.ID end

    equipped = userVar[artifactID] == true

    return equipped
end

---Returns a list of artifact powers active on char.
---@param char EclCharacter
---@return ArtifactLib_ArtifactDefinition[]
function Artifact.GetEquippedPowers(char)
    local artifacts = {}
    local userVar = Artifact:GetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR)

    for artifactID,_ in pairs(userVar) do
        local def = Artifact.GetData(artifactID)

        if def then
            table.insert(artifacts, def)
        else
            Artifact:LogWarning("Artifact has no definition: " .. artifactID)
        end
    end

    return artifacts
end