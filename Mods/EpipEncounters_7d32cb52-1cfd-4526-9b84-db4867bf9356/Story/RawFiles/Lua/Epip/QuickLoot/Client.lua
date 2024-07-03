
---@class Features.QuickLoot
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
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

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns items to loot near a position.
---@param pos Vector3
---@param radius number In meters.
---@return EclItem[]
function QuickLoot.GetItems(pos, radius)
    local items = {} ---@type EclItem[]

    -- Fetch items from nearby containers
    local nearbyContainers = Entity.GetNearbyItems(pos, radius, function (item)
        return Item.IsContainer(item)
    end)
    QuickLoot:DebugLog(#nearbyContainers, "nearby containers")
    for _,item in ipairs(nearbyContainers) do
        local contents = item:GetInventoryItems()
        for _,contentGUID in ipairs(contents) do
            table.insert(items, Item.Get(contentGUID))
        end
    end

    -- Fetch items from nearby corpses
    local nearbyCorpses = Entity.GetNearbyCharacters(pos, radius, function (char)
        return Character.IsLootableCorpse(char) and not Character.IsPlayer(char)
    end)
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
    if QuickLoot.IsSearching(char) then
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
        if not QuickLoot.IsSearching(Character.Get(charHandle)) then
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
    return QuickLoot._Searches[char.Handle] ~= nil
end

---Stops a search and returns its final radius.
---@param char EclCharacter
---@return number -- Radius in meters.
function QuickLoot.StopSearch(char)
    if not QuickLoot.IsSearching(char) then
        QuickLoot:__Error("StopSearch", "Character is not searching")
    end
    local search = QuickLoot._Searches[char.Handle]
    local elapsedSeconds = (Ext.Utils.MonotonicTime() - search.StartTime) / 1000
    local radius = QuickLoot.SEARCH_BASE_RADIUS + elapsedSeconds * QuickLoot.SEARCH_RADIUS_PER_SECOND
    radius = math.min(QuickLoot.MAX_SEARCH_DISTANCE, radius)
    QuickLoot._Searches[char.Handle] = nil -- Stopping the effect is handled via tick listener.
    return radius
end
