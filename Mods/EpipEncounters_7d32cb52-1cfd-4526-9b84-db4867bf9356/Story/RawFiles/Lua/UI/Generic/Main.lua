
Client.UI.Generic = {
    SWF_PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf",
    DEFAULT_LAYER = 15,
    _Element = {},
    ELEMENTS = {}, ---@type table<GenericUI_ElementType, GenericUI_Element>
    INSTANCES = {} ---@type table<integer, GenericUI_Instance>
}
local Generic = Client.UI.Generic
Epip.InitializeLibrary("Generic", Generic)
Generic:Debug()

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

-- Note that these are bound to each UI! They are not "global" events - you can't listen for an event happening across all instances.

---@class GenericUI_Event_Button_Pressed : Event
---@field RegisterListener fun(self, listener:fun(stringID:string))
---@field Fire fun(self, stringID:string)

---@class GenericUI_Event_StateButton_StateChanged : Event
---@field RegisterListener fun(self, listener:fun(stringID:string, active:boolean))
---@field Fire fun(self, stringID:string, active:boolean)

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@alias GenericUI_ElementType "Empty"|"TiledBackground"|"Text"|"IggyIcon"|"Button"|"VerticalList"|"HorizontalList"|"ScrollList"|"StateButton"
---@alias FlashMovieClip userdata TODO remove

---@type GenericUI_Element
local _Element = Generic._Element

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field ParentID string Empty string for elements in the root.
---@field Type string
---@field EVENT_TYPES table<string, string>
---@field GetMovieClip fun(self):FlashMovieClip
---@field AddChild fun(self, id:string, elementType:GenericUI_ElementType):GenericUI_Element
---@field SetAsDraggableArea fun(self) Sets this element as the area for dragging the *entire* UI.
---@field SetPosition fun(self, x:number, y:number)
---@field SetSize fun(self, width:number, height:number)
---@field RegisterListener fun(self, eventType:string, handler:function)
---@field SetMouseEnabled fun(self, enabled:boolean)
---@field SetMouseChildren fun(self, enabled:boolean)

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    return self.UI:GetMovieClipByID(self.ID)
end

function _Element:AddChild(id, elementType)
    return self.UI:CreateElement(id, elementType, self)
end

function _Element:SetAsDraggableArea()
    self:GetMovieClip().SetAsUIDraggableArea()
end

function _Element:SetPosition(x, y)
    self:GetMovieClip().SetPosition(x, y)
end

function _Element:SetSize(width, height)
    self:GetMovieClip().SetSize(width, height)
end

function _Element:SetMouseEnabled(enabled)
    self:GetMovieClip().SetMouseEnabled(enabled)
end

function _Element:SetMouseChildren(enabled)
    self:GetMovieClip().SetMouseChildren(enabled)
end

function _Element:RegisterListener(eventType, handler)
    local ui = self.UI
    ui.Events[eventType]:RegisterListener(function(id, ...)
        if id == self.ID then
            handler(...)
        end
    end)
end

---------------------------------------------
-- INSTANCE
---------------------------------------------

---@class GenericUI_Instance : UI
---@field ID string
---@field Root GenericUI_Element
---@field Elements table<string, GenericUI_Element>
---@field GetElementByID fun(self, id:string):GenericUI_Element?
---@field GetMovieClipByID fun(self, id:string):FlashMovieClip
---@field CreateElement fun(self, id:string, elementType:GenericUI_ElementType, parentID:string|GenericUI_Element?):GenericUI_Element?

---@type GenericUI_Instance
local _Instance = {
    ID = "UNKNOWN",
    Elements = {},
}
Inherit(_Instance, Client.UI._BaseUITable)

---@param id string
---@return GenericUI_Element?
function _Instance:GetElementByID(id)
    return self.Elements[id]
end

---@param id string
---@return FlashMovieClip?
function _Instance:GetMovieClipByID(id)
    return self:GetRoot().elements[id]
end

---@param id string
---@param elementType GenericUI_ElementType
---@param parentID string|GenericUI_Element? Defaults to root of the MainTimeline.
---@return GenericUI_Element? Nil in case of failure (ex. invalid type).
function _Instance:CreateElement(id, elementType, parentID)
    local element = nil ---@type GenericUI_Element
    local elementTable = Generic.ELEMENTS[elementType]
    local root = self:GetRoot()
    if type(parentID) == "table" then parentID = parentID.ID end

    if not elementTable then
        _Instance:LogError("Tried to instantiate an element of unknown type: " .. elementType)
        return nil
    end

    -- Create element in flash
    root.AddElement(id, elementType, parentID or "")

    element = {
        UI = self,
        ID = id,
        Type = elementType,
        ParentID = parentID or "",
    }
    Inherit(element, elementTable)

    -- Map ID to lua element
    self.Elements[id] = element

    return element
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return GenericUI_Instance
function Client.UI.Generic.Create(id)
    ---@type GenericUI_Instance
    local ui = {
        ID = id,
        Name = id,
        Elements = {},
        Events = {
            ---@type GenericUI_Event_Button_Pressed
            Button_Pressed = {},
            ---@type GenericUI_Event_StateButton_StateChanged
            StateButton_StateChanged = {},
        },
        TRACE_LEVELS = {
            INFO = 0,
            WARNING = 1,
            ERROR = 2,
        },
    }
    local uiOBject = Ext.UI.Create(id, Generic.SWF_PATH, Generic.DEFAULT_LAYER)
    Epip.InitializeUI(uiOBject:GetTypeId(), id, ui)
    Inherit(ui, _Instance)

    Generic.INSTANCES[uiOBject:GetTypeId()] = ui

    ui:RegisterCallListener("elementMouseUp", Generic.OnElementMouseUp)
    ui:RegisterCallListener("elementMouseDown", Generic.OnElementMouseDown)
    ui:RegisterCallListener("elementMouseOver", Generic.OnElementMouseOver)
    ui:RegisterCallListener("elementMouseOut", Generic.OnElementMouseOut)

    -- Button
    ui:RegisterCallListener("Button_Pressed", Generic.OnButtonPressed)

    -- StateButton
    ui:RegisterCallListener("StateButton_StateChanged", Generic.OnStateButtonStateChanged)

    -- Logging
    ui:RegisterCallListener("GenericLog", function(ev, elementID, elementType, msg, msgType)
        msg = string.format("TRACE %s (%s): %s", elementID, elementType, msg)

        if msgType == ui.TRACE_LEVELS.WARNING then
            ui:LogWarning(msg)
        elseif msgType == ui.TRACE_LEVELS.ERROR then
            ui:LogError(msg)
        else
            ui:Log(msg)
        end
    end)
    
    return ui
end

---@param elementType string
---@param elementTable GenericUI_Element
function Client.UI.Generic.RegisterElementType(elementType, elementTable)
    Generic.ELEMENTS[elementType] = elementTable
end

---@param call string
---@vararg LuaFlashCompatibleType
---@return fun(self:GenericUI_Element, ...):any?
function Client.UI.Generic.ExposeFunction(call, ...)
    local fun = function(obj, ...)
        local mc = obj:GetMovieClip()

        local success, error, result = pcall(mc[call], ...)

        if not success then
            Generic:LogError("Error while calling exposed function on " .. obj.ID .. ": " .. error)
        end

        return result
    end

    return fun
end

---@param id integer
---@return GenericUI_Instance
function Client.UI.Generic.GetInstance(id)
    return Generic.INSTANCES[id]
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Generic.OnElementMouseUp = function(ev, id)
    Generic:DebugLog("CALL onElementMouseUp: ", id)
end

Generic.OnElementMouseDown = function(ev, id)
    Generic:DebugLog("CALL onElementMouseDown: ", id)
end

Generic.OnElementMouseOver = function(ev, id)
    Generic:DebugLog("CALL onElementMouseOver: ", id)
end

Generic.OnElementMouseOut = function(ev, id)
    Generic:DebugLog("CALL onElementMouseOut: ", id)
end

Generic.OnButtonPressed = function(ev, id)
    Generic:DebugLog("CALL Button_Pressed: ", id)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.Button_Pressed:Fire(id)
end

Generic.OnStateButtonStateChanged = function(ev, id, active)
    Generic:DebugLog("CALL StateButton_StateChanged: ", id, active)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.StateButton_StateChanged:Fire(id, active)
end