
local Ascension = Game.Ascension

function Ascension.IsMeditating(char)
    -- default to client character
    if not char then char = Client.GetCharacter() end

    return char and char:GetStatus(Ascension.MEDITATING_STATUS)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_MeditateStateChanged", function(payload)
    Ascension:FireEvent("ClientToggledMeditating", payload.State)
end)