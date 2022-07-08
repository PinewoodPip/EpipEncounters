
Client.UI.Generic = {
    SWF_PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf",
    DEFAULT_LAYER = 15,
    _Element = {},
    ELEMENTS = {}, ---@type table<GenericUI_ElementType, GenericUI_Element>
}
local Generic = Client.UI.Generic
Epip.InitializeLibrary("Generic", Generic)
Generic:Debug()

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@alias GenericUI_ElementType "Empty"|"TiledBackground"|"Text"|"IggyIcon"|"Button"
---@alias FlashMovieClip userdata TODO remove

---@type GenericUI_Element
local _Element = Generic._Element

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field ParentID string Empty string for elements in the root.
---@field Type string
---@field GetMovieClip fun(self):FlashMovieClip
---@field SetAsDraggableArea fun(self) Sets this element as the area for dragging the *entire* UI.

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    return self.UI:GetMovieClipByID(self.ID)
end

function _Element:SetAsDraggableArea()
    self:GetMovieClip().SetAsUIDraggableArea()
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
---@field CreateElement fun(self, id:string, elementType:GenericUI_ElementType, parentID:string?):GenericUI_Element?

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
---@param parentID string? Defaults to root of the MainTimeline.
---@return GenericUI_Element? Nil in case of failure (ex. invalid type).
function _Instance:CreateElement(id, elementType, parentID)
    local element = nil ---@type GenericUI_Element
    local elementTable = Generic.ELEMENTS[elementType]
    local root = self:GetRoot()

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
        Elements = {},
    }
    local uiOBject = Ext.UI.Create(id, Generic.SWF_PATH, Generic.DEFAULT_LAYER)
    Epip.InitializeUI(uiOBject:GetTypeId(), id, ui)
    Inherit(ui, _Instance)

    ui:RegisterCallListener("elementMouseUp", Generic.OnElementMouseUp)
    ui:RegisterCallListener("elementMouseDown", Generic.OnElementMouseDown)
    ui:RegisterCallListener("elementMouseOver", Generic.OnElementMouseOver)
    ui:RegisterCallListener("elementMouseOut", Generic.OnElementMouseOut)
    
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

        return mc[call](...)
    end

    return fun
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