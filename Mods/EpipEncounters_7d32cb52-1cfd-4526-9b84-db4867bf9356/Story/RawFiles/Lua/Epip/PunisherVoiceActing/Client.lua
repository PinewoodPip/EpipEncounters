
local Overhead = Client.UI.Overhead

---@class Features.PunisherVoiceActing
local VA = Epip.GetFeature("Features.PunisherVoiceActing")

---------------------------------------------
-- METHODS
---------------------------------------------

---Plays a sound on an object.
---@param targetObject ComponentHandle? Defaults to `"Player1"`
---@param sound path Relative to `FOLDER`.
function VA.PlaySound(targetObject, sound)
    VA:DebugLog("Playing clip", sound)
	Ext.Audio.PlayExternalSound(targetObject, "VO_P2_VoiceBark_AD", VA.FOLDER .. sound, 7)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for Punisher overhead dialogue to play voice acting.
Overhead.Hooks.RequestOverheads:Subscribe(function (ev)
    for _,overhead in ipairs(ev.Overheads) do
        if overhead.Type == Overhead.FLASH_OVERHEAD_TYPES.OVERHEAD then
            local char = Character.Get(overhead.CharacterHandle, true)
            if VA.PUNISHER_GUIDS_SET:Contains(char.MyGuid) then
                local label = Text.StripFontTags(overhead.Label)
                local clip = VA.CLIPS[label]
                if clip then
                    VA.PlaySound(Character.Get(overhead.CharacterHandle, true).Handle, clip)
                else
                    VA:LogWarning("Missing voice acting for status text: " .. label)
                end
            end
        end
    end
end, {EnabledFunctor = VA:GetEnabledFunctor()})

-- Notify the server if the date range is valid.
Client:RegisterListener("DeterminedAsHost", function()
    local date = Client.GetDate()
    local isCorrectDateRange = date.Month == 7 and (date.Day == 29 or date.Day == 30 or date.Day == 31)
    isCorrectDateRange = isCorrectDateRange or Epip.IsAprilFools()

    VA._IsDateRangeValid = isCorrectDateRange

    if isCorrectDateRange then
        VA:DebugLog("Date range is valid")
        Net.PostToServer(VA.NETMSG_DATERANGE_VALID)
    end
end)

-- Listen for confirmation from server that the host's date is valid.
Net.RegisterListener(VA.NETMSG_DATERANGE_VALID, function (_)
    VA._IsDateRangeValid = true
end)