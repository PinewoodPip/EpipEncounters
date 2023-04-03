
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

Osiris.RegisterSymbolListener("PROC_AMER_Artifacts_EquipEffects", 3, "after", function(charGUID, artifactID, _)
    local char = Character.Get(charGUID)

    -- Update user var.
    local userVar = Artifact:GetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR) or {}
    userVar[artifactID] = true
    Artifact:SetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR, userVar)
end)

Osiris.RegisterSymbolListener("PROC_AMER_Artifacts_UnequipEffects", 3, "after", function(charGUID, artifactID, _)
    local char = Character.Get(charGUID)

    if not Artifact.IsEquipped(char, artifactID) then
        -- Update user var.
        local userVar = Artifact:GetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR) or {}
        userVar[artifactID] = nil
        Artifact:SetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR, userVar)
    end
end)

-- Update equipped artifacts user var upon load.
-- This exists for (limited) backwards compatibility,
-- and only checks for player characters.
GameState.Events.GameReady:Subscribe(function (_)
    local playerGUIDs = Osiris.QueryDatabase("DB_IsPlayer", nil)

    for _,tuple in ipairs(playerGUIDs) do
        local guid = tuple:Unpack()
        local char = Character.Get(guid)
        local powers = Artifact.GetEquippedPowers(char)
        local powersVar = {}

        for _,power in ipairs(powers) do
            powersVar[power.ID] = true
        end

        Artifact:SetUserVariable(char, Artifact.EQUIPPED_POWERS_USERVAR, powersVar)
    end
end)