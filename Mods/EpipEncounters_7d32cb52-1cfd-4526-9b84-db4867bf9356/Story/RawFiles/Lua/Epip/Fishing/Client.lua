
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
    elseif not Fishing.IsNearWater(char) then
        Client.UI.Notification.ShowNotification("I'm not close enough to water to fish.")
    elseif not Fishing.HasFishingRodEquipped(char) then
        Client.UI.Notification.ShowNotification("I must have a fishing rod equipped to fish!")
    elseif not Character.IsUnsheathed(char) then
        Client.UI.Notification.ShowNotification("I must unsheathe my fishing rod first.")
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

---@param char EclCharacter?
---@return boolean
function Fishing.IsNearWater(char)
    char = char or Client.GetCharacter()
    local grid = Ext.Entity.GetAiGrid()
    local position = char.WorldPos
    local foundCell = grid:SearchForCell(position[1], position[3], Fishing.WATER_SEARCH_RADIUS, "Deepwater", 0)

    return foundCell
end

---@param fishID string
---@return integer
function Fishing.GetTimesCaught(fishID)
    return Fishing:GetSettingValue(Fishing.Settings.FishCaught)[fishID] or 0
end

---@param char EclCharacter
---@param fish Feature_Fishing_Fish TODO rework param
---@param reason Feature_Fishing_MinigameExitReason
function Fishing.Stop(char, fish, reason)
    Fishing.Events.CharacterStoppedFishing:Throw({
        Character = char,
        Reason = reason,
        Fish = fish,
    })

    Net.PostToServer("Feature_Fishing_NetMsg_CharacterStoppedFishing", {
        CharacterNetID = char.NetID,
        Reason = reason,
        FishID = fish.ID,
    })

    if reason == "Success" then
        Fishing._OnSuccess(fish)
    end
end

---@param fish Feature_Fishing_Fish
function Fishing._OnSuccess(fish)
    local setting = Fishing:GetSettingValue(Fishing.Settings.FishCaught)

    -- Increment catch counter.
    if not setting[fish.ID] then
        setting[fish.ID] = 1
    else
        setting[fish.ID] = setting[fish.ID] + 1
    end

    Fishing:SaveSettings()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show notifications for success or failure.
Fishing.Events.CharacterStoppedFishing:Subscribe(function (ev)
    if ev.Reason == "Success" then
        Client.UI.Notification.ShowIconNotification(ev.Fish:GetName(), ev.Fish:GetIcon(), nil, "Fish Caught!", nil, "UI_Notification_ReceiveAbility") -- TODO notify about new catches and show how to open the journal
    elseif ev.Reason == "Failure" then
        Client.UI.Notification.ShowWarning("The fish got away...")
    end
end)