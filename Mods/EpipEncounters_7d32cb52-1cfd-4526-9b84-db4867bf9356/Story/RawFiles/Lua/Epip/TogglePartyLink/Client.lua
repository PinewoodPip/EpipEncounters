
local PlayerInfo = Client.UI.PlayerInfo
local HotbarActions = Epip.GetFeature("Feature_HotbarActions")

---@class Features.PartyLinking
local PartyLinking = Epip.GetFeature("Features.PartyLinking")

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests the character's link to their other controlled characters to be toggled.
---If the requester is grouped with anyone, all characters of the group will be unlinked.
---If requester is not grouped with anyone, they will be grouped with other party members nearby.
---@param requester EclCharacter
function PartyLinking.RequestToggle(requester)
    local playerMC = PlayerInfo.GetPlayerElement(requester)
    local players = PlayerInfo:GetRoot().player_array
    -- Copy the players array to prevent ExternalInterface calls we use from affecting their order in this call.
    local temp = {}
    local playerCount = #players
    for i=0,playerCount-1,1 do
        temp[i + 1] = players[i]
    end
    players = temp

    local shouldUnlink = false
    for _,player in ipairs(players) do
        if player.characterHandle ~= playerMC.characterHandle and player.groupId == playerMC.groupId then
            shouldUnlink = true
        end
    end

    if shouldUnlink then
        PartyLinking._Unlink(requester, players)
    else
        PartyLinking._Link(requester, players)
    end
end

---Links a character with other valid ones within the party.
---@param requester EclCharacter
---@param players FlashMovieClip[]
function PartyLinking._Link(requester, players)
    local characters = {} ---@type EclCharacter[]
    for i,player in ipairs(players) do
        characters[i] = Character.Get(player.characterHandle, true)
    end

    -- Chain characters starting from top,
    -- chaining them to the closest previous character (in UI order).
    for i=2,#players,1 do
        local player = players[i]
        local currentChar = characters[i]
        local previousPlayer = nil

        -- Do not attempt to chain characters that are too far away from requester or uncontrolled.
        -- This also prevents creating groups that would not include the requester, as per the original Osiris implementation of this feature.
        if player.controlled and not Character.IsInPartyLinkingRange(requester, currentChar) then
            goto continue
        end

        -- Find the closest player before this one that can be chained.
        -- We want to avoid invalid chain requests to avoid the "Target group is too far away" notification.
        for j=i-1,1,-1 do
            local previousChar = characters[j]
            if players[j].controlled and Character.IsInPartyLinkingRange(previousChar, currentChar) then
                previousPlayer = players[j]
                break
            end
        end

        if previousPlayer then
            -- Linking requires a timer, as group IDs of characters can change as they are linked.
            -- 2 ticks is inconsistent.
            local flashHandle = player.characterHandle
            local previousFlashHandle = previousPlayer.characterHandle
            Timer.StartTickTimer(4 * (i - 1), function (_)
                local previousCharMC = PlayerInfo.GetPlayerElement(Character.Get(previousFlashHandle, true))
                PlayerInfo:ExternalInterfaceCall("piAddToGroupUnder", flashHandle, previousCharMC.groupId, previousFlashHandle)
            end)
        end
        ::continue::
    end
end

---Unlinks all characters within requester's party group.
---@param requester EclCharacter
---@param players FlashMovieClip[]
function PartyLinking._Unlink(requester, players)
    -- Get the characters that are grouped with the requester
    local requesterMC = PlayerInfo.GetPlayerElement(requester)
    local playerGroup = {}
    for _,player in ipairs(players) do
        if player.groupId == requesterMC.groupId then -- Needs to not have a self check
            table.insert(playerGroup, player)
        end
    end
    for i=#playerGroup,1,-1 do
        local player = playerGroup[i]
        PlayerInfo:ExternalInterfaceCall("piDetachUnder", player.characterHandle, player.groupId) -- Will keep the character's position, unlike the Osiris call, which always detaches to the bottom.
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle the Hotbar action being executed.
HotbarActions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == PartyLinking.HOTBAR_ACTION_ID then
        local char = ev.Character
        PartyLinking.RequestToggle(char)
    end
end)
