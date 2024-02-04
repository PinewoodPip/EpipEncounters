
---------------------------------------------
-- Based on v56's event system.
---------------------------------------------

---@class Event<T>:{ (Subscribe:fun(self:Event, callback:fun(ev:T|Event_Params), opts:Event_Options|nil, stringID:string|nil):integer), Unsubscribe:fun(self:Event, index:integer|string), (Throw:fun(self:Event, event:T|Event_Params|nil):Event_Params|T), (RemoveNodes:fun(self:Event, predicate:(fun(node:table):boolean)?))}
---@field Preventable false
---@field Name string
SubscribableEvent = {}

---@alias Hook<T> Event<T>

---@class Event_Options
---@field Priority number? Defaults to 100.
---@field Once boolean? If true, the listener will only fire once, then be unsubscribed.
---@field StringID string Identifier for this listener. For use with `:Unsubscribe()`. 
---@field EnabledFunctor (fun():boolean)? If present, the listener will only run if the functor returns `true`.

---@class Event_Params
---@field StopPropagation fun(self:Event_Params) Stop the event from continuing on to other registered listeners.
---@field Stopped boolean?
local SubscribableEventParams = {
	Stopped = false,
	Preventable = false,
	StopPropagation = function(self) self.Stopped = true end,
}

---An event whose consequences can be prevented.
---@class PreventableEvent<T>:{ (Subscribe:fun(self:Event, callback:fun(ev:T|PreventableEventParams), opts:Event_Options|nil, stringID:string|nil):integer), Unsubscribe:fun(self:Event, index:integer|string), (Throw:fun(self:Event, event:T|PreventableEventParams|nil):PreventableEventParams|T)}
---@field Preventable true

---@class PreventableEventParams : Event_Params
local PreventableEventParams = {
	Preventable = true,
	Prevented = false,
	Prevent = function(self)
		if self.Preventable then
			self.Prevented = true
		end
	end,
}
setmetatable(PreventableEventParams, {__index = SubscribableEventParams})

---------------------------------------------
-- COMMON EVENT PARAMETER CLASSES
---------------------------------------------

---@class Event_CharacterEventParams
---@field Character Character

---@class Event_ItemEventParams
---@field Item Item

---@class Event_EntityEventParams
---@field Entity Entity

---@class Events.ValueEvent
---@field Value number

---------------------------------------------
-- METHODS
---------------------------------------------

---@param name string
---@param preventable boolean? Defaults to false.
---@return Event
function SubscribableEvent:New(name, preventable)
	---@type Event
	local o = {
		First = nil,
		NextIndex = 1,
		Name = name,
		Preventable = preventable or false,
	}
	setmetatable(o, self)
    self.__index = self
    return o
end

---Initializes a `table<string, Event>` table.
---@param tbl table<string, table> TODO option annotations
---@return table<string, Event>
function SubscribableEvent.InitializeEventTable(tbl)
	local events = {}
	for k,v in pairs(tbl) do
		events[k] = SubscribableEvent:New(k, v.Preventable)
	end
	return events
end

---Creates a table filled with events from a template.
---@param template table<string, {Preventable:boolean?}>
---@return table<string, Event>
function SubscribableEvent.CreateEventsTable(template)
	local events = {}
	for id,opts in pairs(template) do
		events[id] = SubscribableEvent:New(id, opts.Preventable)
	end
	return events
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
        StringID = stringID or opts.StringID,
		EnabledFunctor = opts.EnabledFunctor,
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
	-- Needs not be removed in order for Throw() to work properly when a listener unsubscribes itself while running.
	-- node.Next = nil
end

---Unsubscribe all listeners based on a predicate.
---@param fun (fun(node:unknown):boolean)? Should return `true` for nodes to be removed. If `nil`, all nodes will be removed.
function SubscribableEvent:RemoveNodes(fun)
	local node = self.First
	while node do
		if fun == nil or fun(node) then
			local nextNode = node.Next

			self:RemoveNode(node)

			node = nextNode
		else
			node = node.Next
		end
	end
end

function SubscribableEvent:Unsubscribe(handlerIndex) -- TODO allow unsubcribing only 1?
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
			local node = cur
			cur = node.Next
			self:RemoveNode(node)
		else
			cur = cur.Next
		end
	end

	return false
end

function SubscribableEvent:Throw(event)
	local cur = self.First
	event = event or {}

	if type(event) == "table" then
		if self.Preventable then
			Inherit(event, PreventableEventParams)
		else
			Inherit(event, SubscribableEventParams)
		end
	end

	while cur ~= nil do
		if event and event.Stopped then
			break
		end

		if cur.EnabledFunctor == nil or cur.EnabledFunctor() then
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
		else
			cur = cur.Next
		end
	end

	return event
end