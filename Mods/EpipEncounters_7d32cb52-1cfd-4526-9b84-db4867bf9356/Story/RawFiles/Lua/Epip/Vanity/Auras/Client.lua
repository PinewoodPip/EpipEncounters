
---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EclCharacter?
---@param aura Feature_Vanity_Auras_Entry|string
---@param boneID string
function Auras.ApplyAura(char, aura, boneID)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end
    char = char or Client.GetCharacter()

    Net.PostToServer("EPIPENCOUNTERS_Vanity_ApplyAura", {
        NetID = char.NetID,
        AuraID = aura:GetID(),
        BoneID = boneID,
    })
end

---@param char EclCharacter?
---@param aura Feature_Vanity_Auras_Entry|string
function Auras.RemoveAura(char, aura)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end
    char = char or Client.GetCharacter()

    Net.PostToServer("EPIPENCOUNTERS_Vanity_RemoveAura", {
        NetID = Client.GetCharacter().NetID,
        AuraID = aura:GetID(),
    })
end

---@param char EclCharacter?
function Auras.RemoveAuras(char)
    char = char or Client.GetCharacter()

    Net.PostToServer("EPIPENCOUNTERS_Vanity_RemoveAuras", {
        NetID = Client.GetCharacter().NetID,
    })
end

---@param char EclCharacter?
---@param aura Feature_Vanity_Auras_Entry|string
---@param boneID string
function Auras.ToggleAura(char, aura, boneID)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end
    char = char or Client.GetCharacter()

    -- Cannot have the same aura applied in different bones at the moment.
    if Auras.HasAura(char, aura:GetID()) then
        Auras.RemoveAura(char, aura)
    else
        Auras.ApplyAura(char, aura, boneID)
    end
end