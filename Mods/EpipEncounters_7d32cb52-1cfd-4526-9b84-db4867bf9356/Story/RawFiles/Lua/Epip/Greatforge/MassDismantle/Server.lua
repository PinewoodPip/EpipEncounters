
---@class Feature_MassDismantle
local MassDismantle = Epip.GetFeature("Feature_MassDismantle")
MassDismantle.DELAY = 0.8 -- In seconds.

MassDismantle._CurrentCharacterHandle = nil ---@type EntityHandle
MassDismantle._CurrentQueue = nil ---@type EntityHandle[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether any container is currently being mass-dismantled.
---@return boolean
function MassDismantle.IsRunning()
    return MassDismantle._CurrentQueue ~= nil and MassDismantle._CurrentCharacterHandle ~= nil
end

---Begins mass-dismantling a container's items.
---@param char EsvCharacter The character who will receive the resulting item rewards.
---@param container EsvItem
function MassDismantle.DismantleContainerItems(char, container)
    if MassDismantle.IsRunning() then
        MassDismantle:Error("DismantleContainerItems", "Cannot run multiple mass-dismantles at a time.")
    end

    local items = MassDismantle.GetEligibleItems(container) ---@cast items EntityHandle[]
    for i,item in ipairs(items) do
        items[i] = item.Handle
    end

    if #items > 0 then
        MassDismantle._CurrentCharacterHandle = char.Handle
        MassDismantle._CurrentQueue = items
        MassDismantle._DismantleNextItem()
    end
end

---Dismantles the next item in the queue.
function MassDismantle._DismantleNextItem()
    local item = MassDismantle._PopFromQueue()
    local char = Character.Get(MassDismantle._CurrentCharacterHandle)

    Osiris.PROC_PIP_QuickReduce(char, item)

    if #MassDismantle._CurrentQueue > 0 then
        -- Uses a timer to avoid possible, but unexplored, issues with running multiple off the required behaviour hooks at once
        Timer.Start(MassDismantle.DELAY, function (_)
            MassDismantle._DismantleNextItem()
        end)
    else -- Queue finished
        MassDismantle._CurrentCharacterHandle = nil
        MassDismantle._CurrentQueue = nil
    end
end

---Returns the next queued item and removes it from the queue.
---@return Item
function MassDismantle._PopFromQueue()
    if not MassDismantle.IsRunning() then
        MassDismantle:Error("_PopFromQueue", "Attempted to pop while not mass-dismantling")
    end

    return Item.Get(table.remove(MassDismantle._CurrentQueue, 1))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to mass-dismantle.
Net.RegisterListener(MassDismantle.REQUEST_NET_MSG, function(payload)
    local container = Item.Get(payload.ItemNetID)
    local char = Character.Get(payload.CharacterNetID)

    -- Don't allow multiple people to use this at once
    -- TODO maybe add a message?
    if not MassDismantle.IsRunning() then
        MassDismantle.DismantleContainerItems(char, container)
    else
        MassDismantle:LogWarning("Attempted to mass-dismantle while one is already running")
    end
end)