
local NotificationUI = Client.UI.Notification

---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")
Fishing.OPEN_LOG_KEYBIND = "EpipEncounters_Fishing_OpenCollectionLog"

Fishing.Hooks.CanStartFishing = Fishing:AddSubscribableHook("CanStartFishing") ---@type Event<Feature_Fishing_Hook_CanStartFishing>

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_Fishing_Hook_CanStartFishing
---@field Character EclCharacter
---@field Region Feature_Fishing_Region
---@field CanStartFishing boolean Hookable. Defaults to true.
---@field FailureReason string? Will be shown in a notification toast if CanStartFishing is false.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
function Fishing.Start(char)
    local region = Fishing.GetRegionAt(char.WorldPos)
    
    -- Cannot fish in areas with no fishing region.
    if not region then
        NotificationUI.ShowWarning("There don't seem to be any fish here...")
    else
        local hook = Fishing.Hooks.CanStartFishing:Throw({
            Character = char,
            CanStartFishing = true,
            Region = region,
        })

        -- Begin fishing if no listener prevented it.
        if hook.CanStartFishing then
            local fish = Fishing.GetRandomFish(region)

            Fishing._CharactersFishing:Add(char.Handle)

            if Fishing:IsDebug() then
                NotificationUI.ShowNotification("Starting fishing in " .. region.ID)
            end

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
        else -- Otherwise show failure reason (if provided)
            if hook.FailureReason then
                NotificationUI.ShowNotification(hook.FailureReason)
            end
        end
        
    end
end

---@param char EclCharacter?
---@param searchRadius number? Defaults to WATER_SEARCH_RADIUS.
---@return boolean
function Fishing.IsNearWater(char, searchRadius)
    char = char or Client.GetCharacter()
    local position = char.WorldPos

    return Fishing.IsPositionNearWater(Vector.Create(position), searchRadius)
end

---Returns whether a position is near a Deepwater surface.
---@param position Vector3D
---@param searchRadius number? Defaults to WATER_SEARCH_RADIUS.
---@return boolean
function Fishing.IsPositionNearWater(position, searchRadius)
    local grid = Ext.Entity.GetAiGrid()
    local foundCell = grid:SearchForCell(position[1], position[3], searchRadius or Fishing.WATER_SEARCH_RADIUS, "Deepwater", 0)

    return foundCell
end

---@param fishID string
---@return integer
function Fishing.GetTimesCaught(fishID)
    return Fishing:GetSettingValue(Fishing.Settings.FishCaught)[fishID] or 0
end

---@return integer
function Fishing.GetTotalFishCaught()
    local fishes = Fishing.GetFishes()
    local total = 0

    for id,_ in pairs(fishes) do
        total = total + Fishing.GetTimesCaught(id)
    end

    return total
end

---@param char EclCharacter
---@param fish Feature_Fishing_Fish TODO rework param
---@param reason Feature_Fishing_MinigameExitReason
function Fishing.Stop(char, fish, reason)
    Fishing._CharactersFishing:Remove(char.Handle)

    if reason == "Success" then
        Fishing._OnSuccess(fish)
    end

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
        local subTitle = nil

        -- Show a hint on how to open the collection log the first time you catch each type of fish.
        if Fishing.GetTimesCaught(ev.Fish:GetID()) == 1 then
            local keybinds = Client.Input.GetActionBindings(Fishing.OPEN_LOG_KEYBIND)
            local keybind = keybinds[1]

            if keybind then
                subTitle = Text.Format(Fishing.TSK["Toast_Success_Subtitle"], {
                    FormatArgs = {
                        Client.Input.StringifyBinding(keybind, true)
                    }
                })
            end
        end

        NotificationUI.ShowIconNotification(ev.Fish:GetName(), ev.Fish:GetIcon(), nil, Fishing.TSK["Toast_Success"], subTitle, "UI_Notification_ReceiveAbility")
    elseif ev.Reason == "Failure" then
        NotificationUI.ShowWarning("The fish got away...")
    end
end)

-- Default conditions that prevent fishing.
Fishing.Hooks.CanStartFishing:Subscribe(function (ev)
    local char = ev.Character
    local reason

    if Fishing.IsFishing(char) then
        reason = "I'm already fishing!"
    elseif Client.IsInCombat() or Client.IsInDialogue() then
        reason = "Now's not the time for fishing!"
    elseif ev.Region.RequiresWater and not Fishing.IsNearWater(char) then
        reason = "I'm not close enough to water to fish."
    elseif not Fishing.HasFishingRodEquipped(char) then
        reason = "I must have a fishing rod equipped to fish!"
    elseif not Character.IsUnsheathed(char) then
        reason = "I must unsheathe my fishing rod first."
    end

    if reason then
        ev.CanStartFishing = false
        ev.FailureReason = reason
    end
end, {StringID = "DefaultImplementation"})

-- Update fishing rod templates to have a world tooltip.
GameState.Events.ClientReady:Subscribe(function (_)
    if Fishing:IsEnabled() then
        for guid in Fishing.FISHING_ROD_TEMPLATES:Iterator() do
            local template = Ext.Template.GetTemplate(guid) ---@type ItemTemplate

            template.Tooltip = 2
        end
    end
end)
