
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
    if type(artifact) == "table" then artifactID = artifact.ID end

    equipped = char:HasTag(Artifact.EQUIPPED_TAG_PREFIX .. artifactID)

    return equipped
end

---Returns a list of artifact powers active on char.
---@param char EclCharacter
---@return ArtifactLib_ArtifactDefinition[]
function Artifact.GetEquippedPowers(char)
    local pattern = Artifact.EQUIPPED_TAG_PREFIX .. "(.+)$"
    local artifacts = {}

    for _,tag in ipairs(char:GetTags()) do
        local artifactID = tag:match(pattern)

        if artifactID then
            local def = Artifact.GetData(artifactID)

            if def then
                table.insert(artifacts, def)
            else
                Artifact:LogError("Artifact has no definition: " .. artifactID)
            end
        end
    end

    return artifacts
end