
local Generic = Client.UI.Generic

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@alias GenericUI_ElementType "Empty"|"TiledBackground"|"Text"|"IggyIcon"|"Button"|"VerticalList"|"HorizontalList"|"ScrollList"|"StateButton"|"Divider"|"Slot"
---@alias FlashMovieClip userdata TODO remove

---@class GenericUI_Element
local _Element = Generic._Element
_Element.Events = {
    ---@type SubscribableEvent<GenericUI_Element_Event_MouseUp>
    MouseUp = {},
    ---@type SubscribableEvent<GenericUI_Element_Event_MouseDown>
    MouseDown = {},
    ---@type SubscribableEvent<GenericUI_Element_Event_MouseOver>
    MouseOver = {},
    ---@type SubscribableEvent<GenericUI_Element_Event_MouseOut>
    MouseOut = {},
}

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field ParentID string Empty string for elements in the root.
---@field Type string
---@field Tooltip TooltipData? Will be rendered upon the element being hovered.
---@field EVENT_TYPES table<string, string>

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Event_MouseOver
---@class GenericUI_Element_Event_MouseOut
---@class GenericUI_Element_Event_MouseUp
---@class GenericUI_Element_Event_MouseDown

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    return self.UI:GetMovieClipByID(self.ID)
end

---@param id string
---@param elementType GenericUI_ElementType
---@return GenericUI_Element?
---@overload fun(self, id:string, elementType:"Empty"):GenericUI_Element_Empty
---@overload fun(self, id:string, elementType:"TiledBackground"):GenericUI_Element_TiledBackground
---@overload fun(self, id:string, elementType:"Text"):GenericUI_Element_Text
---@overload fun(self, id:string, elementType:"IggyIcon"):GenericUI_Element_IggyIcon
---@overload fun(self, id:string, elementType:"Button"):GenericUI_Element_Button
---@overload fun(self, id:string, elementType:"VerticalList"):GenericUI_Element_VerticalList
---@overload fun(self, id:string, elementType:"HorizontalList"):GenericUI_Element_HorizontalList
---@overload fun(self, id:string, elementType:"ScrollList"):GenericUI_Element_ScrollList
---@overload fun(self, id:string, elementType:"StateButton"):GenericUI_Element_StateButton
---@overload fun(self, id:string, elementType:"Divider"):GenericUI_Element_Divider
---@overload fun(self, id:string, elementType:"Slot"):GenericUI_Element_Slot
function _Element:AddChild(id, elementType)
    return self.UI:CreateElement(id, elementType, self)
end

function _Element:_RegisterEvents()
    local _Templates = self.Events
    
    self.Events = {}

    for id,tbl in pairs(_Templates) do
        self.Events[id] = SubscribableEvent:New(id)
    end
end

---Called after the element is created in flash. Override to run initialization routines.
function _Element:_OnCreation() end

---Sets whether the element should be horizontally centered in VerticalList and ScrollList.
---@param center boolean
function _Element:SetCenterInLists(center)
    self:GetMovieClip().SetCenterInLists(center)
end

---Sets this element as the area for dragging the *entire* UI.
function _Element:SetAsDraggableArea()
    self:GetMovieClip().SetAsUIDraggableArea()
end

---@param x number
---@param y number
function _Element:SetPosition(x, y)
    self:GetMovieClip().SetPosition(x, y)
end

---@param width number
---@param height number
function _Element:SetSize(width, height)
    self:GetMovieClip().SetSize(width, height)
end

---@param enabled boolean
function _Element:SetMouseEnabled(enabled)
    self:GetMovieClip().SetMouseEnabled(enabled)
end

---@param enabled boolean
function _Element:SetMouseChildren(enabled)
    self:GetMovieClip().SetMouseChildren(enabled)
end

---@param alpha number
---@param affectChildren boolean? Defaults to not affecting children alpha.
function _Element:SetAlpha(alpha, affectChildren)
    self:GetMovieClip().SetAlpha(alpha, affectChildren)
end

---@param eventType string
---@param handler function
function _Element:RegisterListener(eventType, handler)
    local ui = self.UI
    ui.Events[eventType]:RegisterListener(function(id, ...)
        if id == self.ID then
            handler(...)
        end
    end)
end