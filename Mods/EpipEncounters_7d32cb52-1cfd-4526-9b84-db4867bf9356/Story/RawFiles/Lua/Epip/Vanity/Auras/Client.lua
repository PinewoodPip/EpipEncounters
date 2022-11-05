
---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param aura Feature_Vanity_Auras_Entry|string
function Auras.ApplyAura(aura)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end

    Net.PostToServer("EPIPENCOUNTERS_Vanity_ApplyAura", {
        NetID = Client.GetCharacter().NetID,
        AuraID = aura.Effect,
    })
end

function Auras.RemoveCurrentAura()
    Net.PostToServer("EPIPENCOUNTERS_Vanity_RemoveAura", {
        NetID = Client.GetCharacter().NetID,
    })
end