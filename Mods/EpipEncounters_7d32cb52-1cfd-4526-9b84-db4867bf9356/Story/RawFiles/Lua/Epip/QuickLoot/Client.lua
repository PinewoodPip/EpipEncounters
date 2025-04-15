
local Notification = Client.UI.Notification
local Input = Client.Input

---@class Features.QuickLoot
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local TSK = QuickLoot.TranslatedStrings
QuickLoot.EVENTID_TICK_SELECTOR_EFFECT = "Features.QuickLoot.SelectorEffect"
QuickLoot.EVENTID_TICK_IS_MOVING = "Features.QuickLoot.IsCharacterMoving"
QuickLoot.SEARCH_RADIUS_PER_SECOND = 5 -- How many meters the selector's radius expands per second.
QuickLoot.SEARCH_EFFECT = "RS3_FX_UI_Target_Circle_01" -- TODO is this the controller selection area effect, or is it another?
QuickLoot.CONTAINER_EFFECT = "PIP_FX_PerceptionReveal_OverlayOnly"

QuickLoot._Searches = {} ---@type table<CharacterHandle, Features.QuickLoot.Search>

---@class Features.QuickLoot.Search
---@field EffectHandle ComponentHandle
---@field MultiVisualHandle ComponentHandle
---@field StartTime integer
---@field Containers ItemHandle[]? `nil` if the search is in progress.
---@field EndTime integer? `nil` if the search is in progress. 

---@alias Features.QuickLoot.HandleMap {ItemHandleToContainerHandle:table<ItemHandle, ItemHandle>, ItemHandleToCorpseHandle:table<ItemHandle, CharacterHandle>, GroundItems:set<ItemHandle>}

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the containers and corpses near a position.
---@see Features.QuickLoot.Hooks.IsContainerLootable
---@param pos vec3
---@param radius number In meters.
---@return EclItem[], EclCharacter[] -- Containers and corpses.
function QuickLoot.GetContainers(pos, radius)
    local nearbyContainers = Entity.GetNearbyItems(pos, radius, function (item)
        return Item.IsContainer(item) and QuickLoot.Hooks.IsContainerLootable:Throw({
            Container = item,
            Position = pos,
            Lootable = true,
        }).Lootable
    end, true)
    local nearbyCorpses = Entity.GetNearbyCharacters(pos, radius, function (char)
        return Character.IsLootableCorpse(char) and not Character.IsPlayer(char)
    end, true)
    return nearbyContainers, nearbyCorpses
end

---Returns the lootable non-container items near a position.
---@see Features.QuickLoot.Hooks.IsGroundItemLootable
---@param pos vec3
---@param radius number In meters.
---@return EclItem[]
function QuickLoot.GetGroundItems(pos, radius)
    local items = Entity.GetNearbyItems(pos, radius, function (item)
        return item.CanBePickedUp and QuickLoot.Hooks.IsGroundItemLootable:Throw({
            Item = item,
            RequestPosition = pos,
            Lootable = not Item.IsContainer(item), -- Do not include containers by default.
        }).Lootable
    end, true)
    return items
end

---Returns whether a character can pickup an item.
---@see Features.QuickLoot.Hooks.CanPickupItem
---@param char EclCharacter
---@param item EclItem
---@return boolean
function QuickLoot.CanPickUp(char, item)
    return QuickLoot.Hooks.CanPickupItem:Throw({
        Character = char,
        Item = item,
        CanPickup = true,
    }).CanPickup
end

---Returns items to loot near a position.
---@param pos Vector3
---@param radius number In meters.
---@param applyFilters boolean? Defaults to `true`.
---@return EclItem[], Features.QuickLoot.HandleMap
function QuickLoot.GetItems(pos, radius, applyFilters)
    if applyFilters == nil then applyFilters = true end
    local nearbyContainers, nearbyCorpses = QuickLoot.GetContainers(pos, radius)
    local groundItems = QuickLoot.GetGroundItems(pos, radius)
    local itemHandleToContainerHandle = {}
    local itemHandleToCorpseHandle = {}
    local includedGroundItems = {} ---@type set<ItemHandle>
    local items = {} ---@type EclItem[]

    -- Fetch items from nearby containers
    QuickLoot:DebugLog(#nearbyContainers, "nearby containers")
    for _,container in ipairs(nearbyContainers) do
        local contents = container:GetInventoryItems()
        for _,contentGUID in ipairs(contents) do
            local item = Item.Get(contentGUID)
            if not applyFilters or not QuickLoot.IsItemFilteredOut(item) then
                table.insert(items, item)
                itemHandleToContainerHandle[item.Handle] = container.Handle
            end
        end
    end

    -- Fetch items from nearby corpses
    QuickLoot:DebugLog(#nearbyCorpses, "nearby corpses")
    for _,char in ipairs(nearbyCorpses) do
        local contents = Character.GetLootableItems(char)
        for _,item in ipairs(contents) do
            if not applyFilters or not QuickLoot.IsItemFilteredOut(item) then
                table.insert(items, item)
                itemHandleToCorpseHandle[item.Handle] = char.Handle
            end
        end
    end

    -- Filter ground items
    QuickLoot:DebugLog(#groundItems, "nearby ground items")
    for _,item in ipairs(groundItems) do
        if not applyFilters or not QuickLoot.IsItemFilteredOut(item) then
            table.insert(items, item)
            includedGroundItems[item.Handle] = true
        end
    end

    QuickLoot:DebugLog(#items, "items found")

    return items, {ItemHandleToContainerHandle = itemHandleToContainerHandle, ItemHandleToCorpseHandle = itemHandleToCorpseHandle, GroundItems = includedGroundItems}
end

---Requests an item to be picked up.
---@see Features.QuickLoot.Hooks.CanPickupItem
---@param char EclCharacter
---@param item EclItem
---@return boolean -- Whether the request succeeded.
function QuickLoot.RequestPickUp(char, item)
    local canPickup = QuickLoot.CanPickUp(char, item)
    if canPickup then
        Net.PostToServer(QuickLoot.NETMSG_PICKUP_ITEM, {
            CharacterNetID = char.NetID,
            ItemNetID = item.NetID,
            PlayLootingEffect = QuickLoot.Settings.LootingEffect:GetValue() == true,
        })
    end
    return canPickup
end

---Returns whether an item should be filtered out.
---@see Features.QuickLoot.Hooks.IsItemFilteredOut
---@param item any
function QuickLoot.IsItemFilteredOut(item)
    return QuickLoot.Hooks.IsItemFilteredOut:Throw({
        Item = item,
        FilteredOut = false,
    }).FilteredOut
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

    -- Set default effect radius, update it per-tick and play effects on found containers
    local charHandle = char.Handle
    local effectHandle = multiVisual.Effects[1]
    local effect = Ext.Entity.GetEffect(effectHandle)
    local highlightEffectHandlers = {} ---@type table<ItemHandle, ComponentHandle>
    local baseRadius = QuickLoot.GetBaseSearchRadius()
    effect.WorldTransform.Scale = {baseRadius, baseRadius, 0}
    GameState.Events.Tick:Subscribe(function (_)
        char = Character.Get(charHandle)
        local eff = Ext.Entity.GetEffect(effectHandle)

        -- Delete the effect when searching ends.
        if not QuickLoot.IsSearching(char) then
            eff.WorldTransform.Scale = {0, 0, 0} -- Effects are pooled; we need to reset the scale to avoid a flicker when the effect instance is re-used.
            Ext.Visual.Get(multiVisualHandle):Delete()
            GameState.Events.Tick:Unsubscribe(QuickLoot.EVENTID_TICK_SELECTOR_EFFECT)
        else
            local newScale = QuickLoot.GetSearchRadius(char)
            eff.WorldTransform.Scale = {newScale, 1, newScale}

            -- Play an effect on containers and corpses within range.
            local containers, corpses = QuickLoot.GetContainers(char.WorldPos, newScale)
            local groundItems = table.filter(QuickLoot.GetGroundItems(char.WorldPos, newScale), function (item)
                return not QuickLoot.IsItemFilteredOut(item) -- Must apply filter here to not show the effect for ground items when the setting is disabled.
            end)
            local allItems = table.join(table.join(containers, corpses), groundItems)
            for _,entity in ipairs(allItems) do
                local entityHandle = entity.Handle
                if not highlightEffectHandlers[entity.Handle] then
                    local containerMultiVisual = Entity.IsItem(entity) and Ext.Visual.CreateOnItem(entity.WorldPos, entity) or Ext.Visual.CreateOnCharacter(entity.WorldPos, entity)
                    local handle = containerMultiVisual.Handle
                    highlightEffectHandlers[entity.Handle] = handle
                    containerMultiVisual:ParseFromStats(QuickLoot.CONTAINER_EFFECT)
                    Timer.Start(3, function (_)
                        Ext.Visual.Get(handle):Delete()
                    end)
                else -- Highlight target containers each subsequent tick.
                    Entity.SetHighlight(entityHandle, Entity.HIGHLIGHT_TYPES.SELECTED)
                end
            end
        end
    end, {StringID = QuickLoot.EVENTID_TICK_SELECTOR_EFFECT}) -- TODO append some char identifier to listener

    -- Cancel the search when the character begins to move or dies.
    GameState.Events.RunningTick:Subscribe(function (_)
        char = Character.Get(charHandle)
        if QuickLoot.IsSearching(char) then
            if Character.IsMoving(char) or Character.IsDead(char) then
                QuickLoot.CancelSearch(char)
                GameState.Events.RunningTick:Unsubscribe(QuickLoot.EVENTID_TICK_IS_MOVING)
            end
        else
            GameState.Events.RunningTick:Unsubscribe(QuickLoot.EVENTID_TICK_IS_MOVING)
        end
    end, {StringID = QuickLoot.EVENTID_TICK_IS_MOVING})

    ---@type Features.QuickLoot.Search
    local search = {
        StartTime = Ext.Utils.MonotonicTime(),
        EffectHandle = effectHandle,
        MultiVisualHandle = multiVisualHandle,
    }
    QuickLoot._Searches[char.Handle] = search

    QuickLoot.Events.SearchStarted:Throw({
        Character = char,
    })
end

---Returns whether char can start searches.
---@see Features.QuickLoot.Hooks.CanSearch
---@param char EclCharacter
---@return boolean
function QuickLoot.CanSearch(char)
    return QuickLoot.Hooks.CanSearch:Throw({
        Character = char,
        CanSearch = not QuickLoot.IsRequesting(char),
    }).CanSearch
end

---Returns the search char is currently performing, if any.
---@param char EclCharacter
---@return Features.QuickLoot.Search?
function QuickLoot.GetSearch(char)
    return QuickLoot._Searches[char.Handle]
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
    local radius = QuickLoot.GetBaseSearchRadius() + elapsedSeconds * QuickLoot.SEARCH_RADIUS_PER_SECOND
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
    local searchRadius = QuickLoot.GetSearchRadius(char)
    local containers, corpses = QuickLoot.GetContainers(char.WorldPos, searchRadius)
    local groundItems = QuickLoot.GetGroundItems(char.WorldPos, searchRadius)
    search.EndTime = Ext.Utils.MonotonicTime()
    search.Containers = Entity.EntityListToHandles(containers)
    -- Stopping the effect is handled via tick listener.

    Net.PostToServer(QuickLoot.NETMSG_GENERATE_TREASURE, {
        CharacterNetID = char.NetID,
        ItemNetIDs = Entity.EntityListToNetIDs(containers),
    })

    -- Remove highlights
    if Ext.Entity.SetHighlight ~= nil then -- This used to be exclusive to the fork.
        for _,container in ipairs(containers) do
            Entity.SetHighlight(container, Entity.HIGHLIGHT_TYPES.NONE)
        end
        for _,corpse in ipairs(corpses) do
            Entity.SetHighlight(corpse, Entity.HIGHLIGHT_TYPES.NONE)
        end
        for _,item in ipairs(groundItems) do
            Entity.SetHighlight(item, Entity.HIGHLIGHT_TYPES.NONE)
        end
    end
end

---Cancels a character's current search.
---@param char EclCharacter
function QuickLoot.CancelSearch(char)
    local search = QuickLoot.GetSearch(char)
    if not search then
        QuickLoot:__Error("StopSearch", "Character is not searching")
    end
    QuickLoot._Searches[char.Handle] = nil
end

---Returns the default search radius based on user settings.
---@return number -- In meters.
function QuickLoot.GetBaseSearchRadius()
    return QuickLoot.Settings.BaseRadius:GetValue()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Prevent looting certain containers and items.
QuickLoot.Hooks.IsContainerLootable:Subscribe(function (ev)
    local item, lootable = ev.Container, ev.Lootable
    lootable = lootable and Item.IsLegal(item) -- Can't steal with Quick Loot
    lootable = lootable and not Item.IsLocked(item) -- Can't loot locked containers
    lootable = lootable and item.Activated and not item.Invisible -- Can't loot hidden containers
    ev.Lootable = lootable
end, {StringID = "DefaultImplementation"})
QuickLoot.Hooks.IsGroundItemLootable:Subscribe(function (ev)
    local item, lootable = ev.Item, ev.Lootable
    lootable = lootable and Item.IsLegal(item) -- Can't steal with Quick Loot
    lootable = lootable and item.Activated and not item.Invisible -- Can't loot hidden treasures
    ev.Lootable = lootable
end)

-- Prevent looting containers out of sight.
-- This appears to be perfectly in-sync with the check for whether an item displays a world tooltip.
-- TODO also implement for corpses?
QuickLoot.Hooks.IsContainerLootable:Subscribe(function (ev)
    local item = ev.Container
    local characterHeight = Client.GetCharacter().Height -- Appears to be the same (1.8m) for all races.
    local visionFlags = 0
    if item.AI then
        local offsetPos = Vector.Create(ev.Position) + Vector.Create({0, characterHeight, 0})
        visionFlags = Entity.GetLevel().VisionGrid:RaycastToObject(offsetPos, item.AI, "VisionBlock").__Value
    end
    ev.Lootable = ev.Lootable and visionFlags == 0
end, {StringID = "DefaultImplementation.LineOfSight"})

-- Start & stop searches when the action is pressed & released.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == QuickLoot.InputActions.Search.ID then
        local char = Client.GetCharacter()
        if QuickLoot.CanSearch(char) then
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

-- Start & stop searches when holding the world tooltips toggle on a controller,
-- as a temporary solution to Input Actions not being easily usable.
GameState.Events.GameReady:Subscribe(function (_)
    Ext.Events.InputEvent:Subscribe(function (ev)
        if Input.IsAcceptingInput() and Input.GetInputEventDefinition(ev.Event.EventId).EventName == "ShowWorldTooltips" and ev.Event.DeviceId == "Unknown" then -- Only do this if the input event is from a controller.
            local char = Client.GetCharacter()
            if ev.Event.Press and QuickLoot.CanSearch(char) and Input.IsKeyPressed("leftshoulder") then -- Require holding the shoulder buttons before the world tooltip toggle to make it less likely for users to use the feature by accident.
                QuickLoot.StartSearch(char)
            elseif ev.Event.Release and QuickLoot.IsSearching(char) then
                QuickLoot.StopSearch(char)
            end
        end
    end)
end, {EnabledFunctor = Client.IsUsingController})

-- Prevent searching while dead, in combat or while moving.
QuickLoot.Hooks.CanSearch:Subscribe(function (ev)
    local char, canSearch = ev.Character, ev.CanSearch
    ev.CanSearch = canSearch and not Character.IsDead(char) and not Character.IsInCombat(char) and not Character.IsMoving(char)
end, {StringID = "DefaultImplementation"})

-- Fetch lootables and throw search completion events
-- after server has finished generating loot in containers.
Net.RegisterListener(QuickLoot.NETMSG_TREASURE_GENERATED, function (ev)
    local char = Client.GetCharacter()
    if not QuickLoot.IsRequesting(char) then return end -- Do nothing if the request was cancelled before resolving.
    local radius = QuickLoot.GetSearchRadius(char)
    local containers, corpses
    local items, handleMap

    -- If any containers had their loot generated during the search,
    -- we must delay opening the UI until all of the items have been synched
    -- to the client.
    -- Items appear to be synched in batches,
    -- thus checking if the amount of items has changed seems reliable.
    local remainingSyncAttempts = 20
    local unsynchedContainers = {} ---@type table<NetId, integer>
    for netID,expectedItemsAmount in pairs(ev.GeneratedContainerNetIDs) do
        netID = tonumber(netID) -- Keys arrive stringified.
        local itemsAmount = #Item.Get(netID):GetInventoryItems()
        if itemsAmount < expectedItemsAmount then
            unsynchedContainers[netID] = itemsAmount
        end
    end
    Coroutine.Create(function (inst)
        -- Keep checking whether all containers have had their contents synched.
        while next(unsynchedContainers) do
            char = Client.GetCharacter()

            -- Mark containers as synched if their item count has changed.
            for containerHandle,oldItemsAmount in pairs(unsynchedContainers) do
                local container = Item.Get(containerHandle)
                if #container:GetInventoryItems() > oldItemsAmount then
                    unsynchedContainers[container.NetID] = nil
                end
            end

            -- Wait and try again if any containers are still missing their items.
            if next(unsynchedContainers) then
                remainingSyncAttempts = remainingSyncAttempts - 1
                if remainingSyncAttempts <= 0 then -- Give up after X tries.
                    break
                else
                    inst:Sleep(0.05)
                end
            end
        end

        -- Fetch final items.
        char = Client.GetCharacter()
        containers, corpses = QuickLoot.GetContainers(char.WorldPos, radius)
        items, handleMap = QuickLoot.GetItems(char.WorldPos, radius)

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
            HandleMaps = handleMap,
        })

        -- Dispose of the search.
        QuickLoot._Searches[char.Handle] = nil
    end):Continue()
end)

-- Apply default filters.
QuickLoot.Hooks.IsItemFilteredOut:Subscribe(function (ev)
    local item = ev.Item
    local filtered = ev.FilteredOut
    local settings = QuickLoot.Settings
    local minRarity = settings.MinEquipmentRarity:GetValue()

    -- Rarity filter
    if minRarity ~= "Common" and Item.IsEquipment(item) and item.Stats.Rarity ~= "Unique" then -- Always show unique items
        local rarityValue = Ext.Enums.ItemDataRarity[item.Stats.Rarity]
        local minRarityValue = Ext.Enums.ItemDataRarity[minRarity]
        filtered = filtered or (rarityValue.Value < minRarityValue.Value)
    end

    -- Consumables filter
    if settings.ShowConsumables:GetValue() == false then
        filtered = filtered or Item.IsPotion(item) or Item.IsScroll(item) or Item.IsGrenade(item)
    end

    -- Food and drink filter
    if settings.ShowFoodAndDrinks:GetValue() == false then
        filtered = filtered or (Item.IsFood(item) and not Item.IsIngredient(item)) -- Do not consider items like potion mushroom ingredients as food.
    end

    -- Ingredients filter
    if settings.ShowIngredients:GetValue() == false then
        filtered = filtered or Item.IsIngredient(item)
    end

    -- Books filter
    if settings.ShowBooks:GetValue() == false then
        filtered = filtered or Item.IsBook(item)
    end

    -- Clutter filter
    if settings.ShowClutter:GetValue() == false then
        local hasUses = Item.HasUseActions(item) and not Item.IsLight(item) -- Do not consider lights as having a use. TODO are there any edgecases of lights with extra uses?
        filtered = filtered or (not Item.IsEquipment(item) and not hasUses and not Item.IsIngredient(item) and not Item.IsRune(item) and not Item.IsGold(item) and not Item.IsKey(item))
    end

    -- Ground item filter
    if settings.ShowGroundItems:GetValue() == false then
        filtered = filtered or not Item.IsInInventory(item)
    end

    ev.FilteredOut = filtered
end, {StringID = "DefaultImplementation"})

-- Do not allow picking up items if they were to overencumber the character.
QuickLoot.Hooks.CanPickupItem:Subscribe(function (ev)
    if not ev.CanPickup then return end
    local char, item = ev.Character, ev.Item
    ev.CanPickup = not Character.ItemWouldOverencumber(char, item)
end)
