
---------------------------------------------
-- Based on v56's event system.
---------------------------------------------

--- @class SubscribableEvent<T>:{ (Subscribe:fun(self:SubscribableEvent, callback:fun(e:T|SubscribableEventParams), opts:SubscribableEventOptions|nil, stringID:string|nil):integer), Unsubscribe:fun(self:SubscribableEvent, index:integer|string), (Throw:fun(self:SubscribableEvent, event:T|SubscribableEventParams|nil))}
SubscribableEvent = {}

---@class SubscribableEventOptions
---@field Priority number? Defaults to 100.
---@field Once boolean? If true, the listener will only fire once, then be unsubscribed.

---@class SubscribableEventParams
---@field StopPropagation fun(self:SubscribableEventParams) Stop the event from continuing on to other registered listeners.
---@field Stopped boolean?

local SubscribableEventParams = {
	Stopped = false,
	StopPropagation = function(self) self.Stopped = true end,
}

---@param name string
---@return SubscribableEvent
function SubscribableEvent:New(name)
	local o = {
		First = nil,
		NextIndex = 1,
		Name = name
	}
	setmetatable(o, self)
    self.__index = self
    return o
end

function SubscribableEvent:Subscribe(handler, opts, stringID)
	opts = opts or {}
	local index = self.NextIndex
	self.NextIndex = self.NextIndex + 1

	local sub = {
		Handler = handler,
		Index = index,
		Priority = opts.Priority or 100,
		Once = opts.Once or false,
		Options = opts,
        StringID = stringID,
	}

	self:DoSubscribe(sub)
	return index
end

function SubscribableEvent:DoSubscribeBefore(node, sub)
	sub.Prev = node.Prev
	sub.Next = node
	
	if node.Prev ~= nil then
		node.Prev.Next = sub
	else
		self.First = sub
	end

	node.Prev = sub
end

function SubscribableEvent:DoSubscribe(sub)
	if self.First == nil then
		self.First = sub
		return
	end

	local cur = self.First
	local last

	while cur ~= nil do
		last = cur
		if sub.Priority > cur.Priority then
			self:DoSubscribeBefore(cur, sub)
			return
		end

		cur = cur.Next
	end

	last.Next = sub
	sub.Prev = last
end

function SubscribableEvent:RemoveNode(node)
	if node.Prev ~= nil then
		node.Prev.Next = node.Next
	end

	if node.Next ~= nil then
		node.Next.Prev = node.Prev
	end

	if self.First == node then
		self.First = node.Next
	end

	node.Prev = nil
	node.Next = nil
end

function SubscribableEvent:Unsubscribe(handlerIndex) -- TODO string ID
	local cur = self.First
    local useStringIDs = type(handlerIndex) == "string"

	while cur ~= nil do
        local shouldRemove = false

        if useStringIDs then
            shouldRemove = cur.StringID == handlerIndex
        else
            shouldRemove = cur.Index == handlerIndex
        end

		if shouldRemove then
			self:RemoveNode(cur)
			return true
		end

		cur = cur.Next
	end
	
	Ext.PrintWarning("Attempted to remove subscriber ID " .. handlerIndex .. " for event '" .. self.Name .. "', but no such subscriber exists (maybe it was removed already?)")
	return false
end

function SubscribableEvent:Throw(event)
	local cur = self.First

	if type(event) == "table" then
		Inherit(event, SubscribableEventParams)
	end

	while cur ~= nil do
		if event and event.Stopped then
			break
		end

        local ok, result = xpcall(cur.Handler, debug.traceback, event)
        if not ok then
            Ext.PrintError("Error while dispatching event " .. self.Name .. ": ", result)
        end

		if cur.Once then
			local last = cur
			cur = last.Next
			self:RemoveNode(last)
		else
			cur = cur.Next
		end
	end
end