
local Notification = Client.UI.Notification
local Input = Client.Input

---@class Features.QuickLoot
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local TSK = QuickLoot.TranslatedStrings
QuickLoot.EVENTID_TICK_SELECTOR_EFFECT = "Features.QuickLoot.SelectorEffect"
QuickLoot.MAX_SEARCH_DISTANCE = 10 -- In meters.
QuickLoot.SEARCH_RADIUS_PER_SECOND = 5 -- How many meters the selector's radius expands per second.
QuickLoot.SEARCH_BASE_RADIUS = 1 -- In meters.
QuickLoot.SEARCH_EFFECT = "RS3_FX_UI_Target_Circle_01" -- TODO is this the controller selection area effect, or is it another?

QuickLoot._Searches = {} ---@type table<CharacterHandle, Features.QuickLoot.Search>

---@class Features.QuickLoot.Search
---@field EffectHandle ComponentHandle
---@field MultiVisualHandle ComponentHandle
---@field StartTime integer
---@field Containers ItemHandle[]? `nil` if the search is in progress.
---@field EndTime integer? `nil` if the search is in progress. 

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the containers and corpses near a position.
---@param pos vec3
---@param radius number In meters.
---@return EclItem[], EclCharacter[] -- Containers and corpses.
function QuickLoot.GetContainers(pos, radius)
    local nearbyContainers = Entity.GetNearbyItems(pos, radius, function (item)
        return Item.IsContainer(item)
    end)
    local nearbyCorpses = Entity.GetNearbyCharacters(pos, radius, function (char)
        return Character.IsLootableCorpse(char) and not Character.IsPlayer(char)
    end)
    return nearbyContainers, nearbyCorpses
end

---Returns items to loot near a position.
---@param pos Vector3
---@param radius number In meters.
---@return EclItem[]
function QuickLoot.GetItems(pos, radius)
    local nearbyContainers, nearbyCorpses = QuickLoot.GetContainers(pos, radius)
    local items = {} ---@type EclItem[]

    -- Fetch items from nearby containers
    QuickLoot:DebugLog(#nearbyContainers, "nearby containers")
    for _,item in ipairs(nearbyContainers) do
        local contents = item:GetInventoryItems()
        for _,contentGUID in ipairs(contents) do
            table.insert(items, Item.Get(contentGUID))
        end
    end

    -- Fetch items from nearby corpses
    QuickLoot:DebugLog(#nearbyCorpses, "nearby corpses")
    for _,char in ipairs(nearbyCorpses) do
        local contents = Character.GetLootableItems(char)
        for _,item in ipairs(contents) do
            table.insert(items, item)
        end
    end

    QuickLoot:DebugLog(#items, "items found")

    return items
end

---Requests an item to be picked up.
---@param char EclCharacter
---@param item EclItem
function QuickLoot.RequestPickUp(char, item)
    Net.PostToServer(QuickLoot.NETMSG_PICKUP_ITEM, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
end

---Begins searching for nearby lootables.
---Throws if char is already performing a search.
---@param char EclCharacter
function QuickLoot.StartSearch(char)
    if QuickLoot.IsRequesting(char) then
        QuickLoot:__Error("StartSearch", "Character is already searching")
    end

    -- Play search effect
    local multiVisual = Ext.Visual.CreateOnCharacter(char.WorldPos, char)
    local multiVisualHandle = multiVisual.Handle
    multiVisual:ParseFromStats(QuickLoot.SEARCH_EFFECT)
    local charHandle = char.Handle
    local effectHandle = multiVisual.Effects[1]
    local effect = Ext.Entity.GetEffect(effectHandle)
    -- Set default radius, then update it per-tick
    effect.WorldTransform.Scale = {QuickLoot.SEARCH_BASE_RADIUS, QuickLoot.SEARCH_BASE_RADIUS, 0}
    GameState.Events.Tick:Subscribe(function (ev)
        local eff = Ext.Entity.GetEffect(effectHandle)
        local scale = eff.WorldTransform.Scale
        local radiusChange = ev.DeltaTime / 1000 * QuickLoot.SEARCH_RADIUS_PER_SECOND
        local newScale = math.min(scale[1] + radiusChange, QuickLoot.MAX_SEARCH_DISTANCE)
        eff.WorldTransform.Scale = {newScale, 1, newScale}

        -- Delete the effect when searching ends.
        if QuickLoot._Searches[charHandle].EndTime then
            eff.WorldTransform.Scale = {0, 0, 0} -- Effects are pooled; we need to reset the scale to avoid a flicker when the effect instance is re-used.
            Ext.Visual.Get(multiVisualHandle):Delete()
            GameState.Events.Tick:Unsubscribe(QuickLoot.EVENTID_TICK_SELECTOR_EFFECT)
        end
    end, {StringID = QuickLoot.EVENTID_TICK_SELECTOR_EFFECT}) -- TODO append some char identifier to listener

    ---@type Features.QuickLoot.Search
    local search = {
        StartTime = Ext.Utils.MonotonicTime(),
        EffectHandle = effectHandle,
        MultiVisualHandle = multiVisualHandle,
    }
    QuickLoot._Searches[char.Handle] = search
end

---Returns whether char is performing a search.
---@param char EclCharacter
---@return boolean
function QuickLoot.IsSearching(char)
    local search = QuickLoot._Searches[char.Handle]
    return search and search.EndTime == nil
end

---Returns whether char has a search request pending completion.
---@param char EclCharacter
---@return boolean
function QuickLoot.IsRequesting(char)
    return QuickLoot._Searches[char.Handle] ~= nil
end

---Returns the current search radius of char.
---@param char EclCharacter Must be searching.
---@return number
function QuickLoot.GetSearchRadius(char)
    local search = QuickLoot._Searches[char.Handle]
    if not search then QuickLoot:__Error("GetSearchRadius", "Character is not searching") end

    local endTime = search.EndTime or Ext.Utils.MonotonicTime()
    local elapsedSeconds = (endTime - search.StartTime) / 1000
    local radius = QuickLoot.SEARCH_BASE_RADIUS + elapsedSeconds * QuickLoot.SEARCH_RADIUS_PER_SECOND
    radius = math.min(QuickLoot.MAX_SEARCH_DISTANCE, radius)
    return radius
end

---Stops a search.
---Note that the search won't be considered completed until the server finishes generating loot
---of nearby characters.
---@see Features.QuickLoot.Events.SearchCompleted
---@param char EclCharacter
function QuickLoot.StopSearch(char)
    if not QuickLoot.IsRequesting(char) then
        QuickLoot:__Error("StopSearch", "Character is not searching")
    end
    local search = QuickLoot._Searches[char.Handle]
    local containers = QuickLoot.GetContainers(char.WorldPos, QuickLoot.GetSearchRadius(char))
    search.EndTime = Ext.Utils.MonotonicTime()
    search.Containers = Entity.EntityListToHandles(containers)
    -- Stopping the effect is handled via tick listener.

    Net.PostToServer(QuickLoot.NETMSG_GENERATE_TREASURE, {
        CharacterNetID = char.NetID,
        ItemNetIDs = Entity.EntityListToNetIDs(containers),
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Start & stop searches when the action is pressed & released.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == QuickLoot.InputActions.Search.ID then
        local char = Client.GetCharacter()
        if not QuickLoot.IsRequesting(char) then
            QuickLoot.StartSearch(char)
            Notification.ShowWarning(TSK.Notification_Searching:GetString(), 0.5)
        end
    end
end)
Input.Events.ActionReleased:Subscribe(function (ev)
    if ev.Action.ID == QuickLoot.InputActions.Search.ID then
        local char = Client.GetCharacter()
        if QuickLoot.IsSearching(char) then
            QuickLoot.StopSearch(char)
        end
    end
end)

-- Fetch lootables and throw search completion events
-- after server has finished generating loot in containers.
Net.RegisterListener(QuickLoot.NETMSG_TREASURE_GENERATED, function (_)
    local char = Client.GetCharacter()
    local radius = QuickLoot.GetSearchRadius(char)
    local containers, corpses = QuickLoot.GetContainers(char.WorldPos, radius)
    local items = QuickLoot.GetItems(char.WorldPos, radius)

    -- Mark corpses as looted.
    -- Can't be done on the server - no accessible equivalent(?)
    -- Unfortunately will not persist.
    for _,corpse in ipairs(corpses) do
        corpse.HasInventory = true
    end

    -- Throw event.
    QuickLoot.Events.SearchCompleted:Throw({
        Character = char,
        Radius = radius,
        LootableItems = items,
        Containers = containers,
        Corpses = corpses,
    })

    -- Dispose of the search.
    QuickLoot._Searches[char.Handle] = nil
end)
