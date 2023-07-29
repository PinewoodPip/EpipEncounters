
---------------------------------------------
-- Adds voice acting to the Punisher.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")

---@class Features.PunisherVoiceActing : Feature
local VA = {
    _IsDateRangeValid = false,

    NETMSG_DATERANGE_VALID = "Features.PunisherVoiceActing.NetMsg.DateRangeValid",

    FOLDER = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Assets/Sounds/Voice/Punisher/",
    PUNISHER_GUIDS_SET = Set.Create({}), -- Initialized from PUNISHER_GUIDS
    PUNISHER_GUIDS = {
        TUTORIAL = "1fe33c06-e97a-4baa-92ec-fcb230b89bbf",
        FJ_GATE = "91c9d059-def4-419a-88c7-5a30999c5bfd",
        FJ_TOWER = "5381360b-2b64-4743-b022-b9b8cbd6e46b",
    },
    ---@type table<string, string> Maps CharacterStatusText string to the sound filename.
    CLIPS = {
        ["Back off Dallis! I’m saving them for later!"] = "fj_gate_greeting.wav",
        ["Till we meet again, mortals!"] = "fj_gate_goodbye.wav",

        ["We meet again!"] = "fj_tower_greeting.wav",
        ["Anger..."] = "fj_tower_anger.wav",
        ["Pain..."] = "fj_tower_pain.wav",
        ["AGHHHH!!!"] = "RIP ears.wav", -- Was way too hard for me to make it not sound like moaning; so fuck it
        ["Must calm down..."] = "fj_tower_must_calm_down.wav",
        ["Much better now!"] = "fj_tower_much_better_now.wav",
        ["Fatality!"] = "fj_tower_fatality.wav",
        ["Get over here!"] = "fj_tower_get_over_here.wav",

        ["Greetings mortal!"] = "tutorial_greeting.wav",
        ["This ain't over!"] = "tutorial_goodbye.wav",
    },
    EXTRA_CLIPS = {
        CRINGE_DIFFICULTY_1 = "You have bested me, mortal. But this Encounter wasn't Epic - it was cringe.",
        CRINGE_DIFFICULTY_2 = "Try me again at a real man's difficulty.",
        FACETANKING = "Corner facetanking? Nooooo, my only weakness! Lone Wolf was a mistake!",
        NO_ARTIFACT_TIERS = "How dare you wield artifacts you're unworthy of! Shame on you!",
        NOT_4MAN = "Bro... That is not a 4-man party!",
    }
}
Epip.RegisterFeature("PunisherVoiceActing", VA)
VA:Debug()

-- Add extra voice clips
VA.CLIPS[VA.EXTRA_CLIPS.CRINGE_DIFFICULTY_1] = "fj_tower_extra_cringe_difficulty_1.wav"
VA.CLIPS[VA.EXTRA_CLIPS.CRINGE_DIFFICULTY_2] = "fj_tower_extra_cringe_difficulty_2.wav"
VA.CLIPS[VA.EXTRA_CLIPS.FACETANKING] = "fj_tower_extra_cornertanking.wav"
VA.CLIPS[VA.EXTRA_CLIPS.NO_ARTIFACT_TIERS] = "fj_tower_extra_no_artifact_tiers.wav"
VA.CLIPS[VA.EXTRA_CLIPS.NOT_4MAN] = "fj_tower_extra_not_4man.wav"

-- Add GUIDs to set
for _,guid in pairs(VA.PUNISHER_GUIDS) do
    VA.PUNISHER_GUIDS_SET:Add(guid)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function VA:IsEnabled()
    local base = self:GetClassDefinition() ---@type Feature
    return self._IsDateRangeValid and base.IsEnabled(self)
end