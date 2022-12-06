
---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
function Fishing.Start(char)
    local region = Fishing.GetRegionAt(char.WorldPos)

    if Fishing.IsFishing(char) then
        Client.UI.Notification.ShowNotification("I'm already fishing!")
    elseif not Fishing.HasFishingRodEquipped(char) then
        Client.UI.Notification.ShowNotification("I must have a fishing rod equipped to fish!")
    elseif not region then
        Client.UI.Notification.ShowWarning("There don't seem to be any fish here...")
    else
        local fish = Fishing.GetRandomFish(region)

        Fishing.Events.CharacterStartedFishing:Throw({
            Character = char,
            Region = region,
            Fish = fish,
        })

        Net.PostToServer("Feature_Fishing_NetMsg_CharacterStartedFishing", {
            CharacterNetID = char.NetID,
            RegionID = region.ID,
            FishID = fish.ID,
        })
    end
end

---@param char EclCharacter
---@param reason Feature_Fishing_MinigameExitReason
function Fishing.Stop(char, reason)
    Fishing.Events.CharacterStoppedFishing:Throw({
        Character = char,
        Reason = reason,
    })

    Net.PostToServer("Feature_Fishing_NetMsg_CharacterStoppedFishing", {
        CharacterNetID = char.NetID,
        Reason = reason,
    })
end