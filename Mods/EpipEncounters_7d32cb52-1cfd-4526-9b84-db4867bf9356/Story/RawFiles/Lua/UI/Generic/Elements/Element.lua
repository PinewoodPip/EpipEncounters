
local Generic = Client.UI.Generic

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@alias GenericUI_ElementType "GenericUI_Element_Empty"|"GenericUI_Element_TiledBackground"|"GenericUI_Element_Text"|"GenericUI_Element_IggyIcon"|"GenericUI_Element_Button"|"GenericUI_Element_VerticalList"|"GenericUI_Element_HorizontalList"|"GenericUI_Element_ScrollList"|"GenericUI_Element_StateButton"|"GenericUI_Element_Divider"|"GenericUI_Element_Slot"|"GenericUI_Element_ComboBox"|"GenericUI_Element_Slider"|"GenericUI_Element_Grid"|"GenericUI_Element_Color"|"GenericUI_Element_Texture"

---@class GenericUI_ContainerElement : GenericUI_Element
---@field ClearElements fun(self) Removes all elements from the container.

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field ParentID string Empty string for elements in the root.
---@field Type string
---@field Tooltip (GenericUI_ElementTooltip|string)? Will be rendered upon the element being hovered. Strings are rendered as unformatted tooltips.
---@field SetPositionRelativeToParent fun(self:GenericUI_Element, position:"Center"|"TopLeft"|"TopRight"|"Top"|"Left"|"Right"|"BottomLeft"|"Bottom"|"BottomRight", horizontalOffset:number?, verticalOffset:number?)
---@field Move fun(self:GenericUI_Element, x:number, y:number) Moves the element a certain amount of pixels from its current position.
---@field Events GenericUI_Element_Events
---@field _Tooltip GenericUI_ElementTooltip
local _Element = Generic._Element

---@class GenericUI_Element_Events
_Element.Events = {
    MouseUp = {}, ---@type Event<GenericUI_Element_Event_MouseUp>
    MouseDown = {}, ---@type Event<GenericUI_Element_Event_MouseDown>
    MouseOver = {}, ---@type Event<GenericUI_Element_Event_MouseOver>
    MouseOut = {}, ---@type Event<GenericUI_Element_Event_MouseOut>
    RightClick = {}, ---@type Event<GenericUI_Element_Event_RightClick>
    TweenCompleted = {}, ---@type Event<GenericUI_Element_Event_TweenCompleted>
}

---TODO!
---@class GenericUI_ElementTooltip
---@field Type TooltipLib_TooltipType

---@class GenericUI_ElementTween
---@field EventID string
---@field Duration number
---@field Type "To"
---@field StartingValues table<string, any> Maps property to starting value.
---@field FinalValues table<string, any> Maps property to final value.
---@field Function "Linear"|"Quadratic"|"Cubic"|"Quartic"|"Sine"|"Elastic"
---@field Ease "EaseNone"|"EaseIn"|"EaseOut"|"EaseInOut"
---@field Delay number? Defaults to 0 seconds.
---@field OnComplete fun(ev:GenericUI_Element_Event_TweenCompleted)? Shorthand for registering a TweenCompleted listener. Will run only once, then be unsubscribed.

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Event_MouseOver
---@class GenericUI_Element_Event_MouseOut
---@class GenericUI_Element_Event_MouseUp
---@class GenericUI_Element_Event_MouseDown
---@class GenericUI_Element_Event_RightClick

---@class GenericUI_Element_Event_TweenCompleted
---@field EventID string

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    return self.UI:GetMovieClipByID(self.ID)
end

---@generic T
---@param id string
---@param elementType `T`|GenericUI_ElementType
---@return `T`
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

---@param degrees number
function _Element:SetRotation(degrees)
    self:GetMovieClip().SetRotation(degrees)
end

function _Element:Destroy()
    self.UI:DestroyElement(self)
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

---@return number, number -- X and Y coordinates in local space.
function _Element:GetPosition()
    local mc = self:GetMovieClip()

    return mc.GetPositionX(), mc.GetPositionY()
end

---@param visible boolean
function _Element:SetVisible(visible)
    self:GetMovieClip().SetVisible(visible)
end

---@param tween GenericUI_ElementTween
function _Element:Tween(tween)
    if not tween.Function or not tween.Ease then
        Generic:Error("Element:Tween", "Tweens must define Function and Ease")
    end
    if not tween.FinalValues or table.getKeyCount(tween.FinalValues) == 0 then
        Generic:Error("Element:Tween", "Tweens must define at least one final property value")
    end

    local mc = self:GetMovieClip()
    local tweenFunction = tween.Function .. "_" .. tween.Ease

    -- Set starting and final values of each property
    for key,value in pairs(tween.StartingValues or {}) do
        mc.addTweenProperty(key, "From", value)
    end
    for key,value in pairs(tween.FinalValues) do
        mc.addTweenProperty(key, "To", value)
    end

    if tween.OnComplete then
        self.Events.TweenCompleted:Subscribe(tween.OnComplete, {Once = true})
    end

    mc.startTween(tween.EventID, tween.Duration, tweenFunction, tween.Delay or 0)
end

---Sets the size override, used to override the element size within list-like elements.
---@overload fun(self:GenericUI_Element, size:Vector2)
---@param width number
---@param height number
function _Element:SetSizeOverride(width, height)
    if type(width) == "table" then width, height = width:unpack() end

    self:GetMovieClip().SetSizeOverride(width, height)
end

---Sets the scroll rect of the element.
---@param position Vector2
---@param size Vector2
function _Element:SetScrollRect(position, size)
    local x, y = position:unpack()
    local w, h = size:unpack()

    self:GetMovieClip().SetScrollRect(x, y, w, h)
end

---Removes the scroll rect from the element, if any.
function _Element:RemoveScrollRect()
    self:GetMovieClip().RemoveScrollRect()
end

---Sets the Z-order index of a child element.
---@param child string|GenericUI_Element
---@param index integer
function _Element:SetChildIndex(child, index)
    if type(child) == "table" then -- Table overload
        child = child.ID
    end
    self:GetMovieClip().SetChildIndex(child, index)
end

---Returns the calculated width of the element.
---@return number
function _Element:GetWidth()
    return self:GetMovieClip().width
end

---Returns the calculated height of the element.
---@return number
function _Element:GetHeight()
    return self:GetMovieClip().height
end

---Sets the scale of the element.
---@param scale Vector2
function _Element:SetScale(scale)
    local mc = self:GetMovieClip()

    mc.scaleX, mc.scaleY = scale[1], scale[2]
end

---Returns the scale of the element.
---@return Vector2
function _Element:GetScale()
    local mc = self:GetMovieClip()

    return Vector.Create(mc.scaleX, mc.scaleY)
end

_Element.SetPositionRelativeToParent = Generic.ExposeFunction("SetPositionRelativeToParent")
_Element.Move = Generic.ExposeFunction("Move")