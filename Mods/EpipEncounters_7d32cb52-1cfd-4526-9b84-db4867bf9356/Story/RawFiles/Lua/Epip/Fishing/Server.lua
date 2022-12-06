
---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")
Fishing.MINIGAME_ANIMATION = "skill_prepare_weapon_01_loop"
Fishing.ANIMATION_EVENT = "EPIP_FISHING_LOOP"
Fishing.SUCCESS_ANIMATION = "use_loot"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter
function Fishing.PlayAnimation(char)
    Osiris.PlayAnimation(char, Fishing.MINIGAME_ANIMATION, Fishing.ANIMATION_EVENT)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Tag characters when they start fishing and play an animation.
Fishing.Events.CharacterStartedFishing:Subscribe(function (ev)
    Osiris.SetTag(ev.Character, Fishing.FISHING_IN_PROGRESS_TAG)

    Fishing.PlayAnimation(ev.Character)
end)

-- Loop animation if the character is still fishing.
Osiris.RegisterSymbolListener("StoryEvent", 2, "after", function (obj, event)
    if event == Fishing.ANIMATION_EVENT then
        local char = Character.Get(obj)
        if Fishing.IsFishing(char) then
            Fishing.PlayAnimation(char)
        end
    end
end)

-- Untag characters when they finish fishing.
Fishing.Events.CharacterStoppedFishing:Subscribe(function (ev)
    Osiris.ClearTag(ev.Character, Fishing.FISHING_IN_PROGRESS_TAG)

    if ev.Reason == "Success" then
        Osiris.CharacterStatusText(ev.Character, "Success!")
        Osiris.PlayAnimation(ev.Character, Fishing.SUCCESS_ANIMATION)
    end
end)

-- Listen for clients starting to fish and forward the event.
Net.RegisterListener("Feature_Fishing_NetMsg_CharacterStartedFishing", function (payload)
    local region = Fishing.GetRegion(payload.RegionID)
    local fish = Fishing.GetFish(payload.FishID)

    Fishing.Events.CharacterStartedFishing:Throw({
        Character = Character.Get(payload.CharacterNetID),
        Region = region,
        Fish = fish,
    })
end)

-- Listen for clients exiting the minigame and forward the event.
Net.RegisterListener("Feature_Fishing_NetMsg_CharacterStoppedFishing", function (payload)
    Fishing.Events.CharacterStoppedFishing:Throw({
        Character = Character.Get(payload.CharacterNetID),
        Reason = payload.Reason
    })
end)