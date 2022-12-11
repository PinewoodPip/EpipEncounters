
---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")

Fishing.MINIGAME_ANIMATION = "skill_prepare_weapon_01_loop"
Fishing.ANIMATION_EVENT = "EPIP_FISHING_LOOP"
Fishing.SUCCESS_ANIMATION = "use_loot"
Fishing.FAILURE_ANIMATION = "emotion_sad"

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
    Fishing._CharactersFishing:Add(ev.Character.Handle)

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
    local char = ev.Character

    Osiris.CharacterFlushQueue(char)
    Fishing._CharactersFishing:Remove(char.Handle)

    if ev.Reason == "Success" then
        Osiris.CharacterStatusText(char, "Success!")
        Osiris.PlayAnimation(char, Fishing.SUCCESS_ANIMATION, "")
        Osiris.ItemTemplateAddTo(ev.Fish.TemplateID, char, 1, 1)
    elseif ev.Reason == "Failure" then
        Osiris.PlayAnimation(char, Fishing.FAILURE_ANIMATION, "")
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
        Reason = payload.Reason,
        Fish = Fishing.GetFish(payload.FishID),
    })
end)