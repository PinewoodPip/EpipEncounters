
---@class GenericUI
local Generic = Client.UI.Generic
local Tooltip = Client.Tooltip
local V = Vector.Create

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@alias GenericUI_ElementType "GenericUI_Element_Empty"|"GenericUI_Element_TiledBackground"|"GenericUI_Element_Text"|"GenericUI_Element_IggyIcon"|"GenericUI_Element_Button"|"GenericUI_Element_VerticalList"|"GenericUI_Element_HorizontalList"|"GenericUI_Element_ScrollList"|"GenericUI_Element_StateButton"|"GenericUI_Element_Divider"|"GenericUI_Element_Slot"|"GenericUI_Element_ComboBox"|"GenericUI_Element_Slider"|"GenericUI_Element_Grid"|"GenericUI_Element_Color"|"GenericUI_Element_Texture"

---@alias GenericUI_Element_RelativePosition "Center"|"TopLeft"|"TopRight"|"Top"|"Left"|"Right"|"BottomLeft"|"Bottom"|"BottomRight"

---@class GenericUI_ContainerElement : GenericUI_Element
---@field ClearElements fun(self) Removes all elements from the container.

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field ParentID string Empty string for elements in the root.
---@field _Children GenericUI_Element[]
---@field Type GenericUI_ElementType
---@field Tooltip (GenericUI_ElementTooltip|string)? DEPRECATED! Will be rendered upon the element being hovered. Strings are rendered as unformatted tooltips.
---@field Events GenericUI_Element_Events
---@field _Tooltip GenericUI_ElementTooltip
---@field _MovieClip FlashMovieClip? Cached reference to the element's movie clip.
local _Element = Generic._Element
local __Element = _Element

---@class GenericUI_Element_Events
_Element.Events = {
    MouseUp = {}, ---@type Event<GenericUI_Element_Event_MouseUp>
    MouseDown = {}, ---@type Event<GenericUI_Element_Event_MouseDown>
    MouseOver = {}, ---@type Event<GenericUI_Element_Event_MouseOver>
    MouseOut = {}, ---@type Event<GenericUI_Element_Event_MouseOut>
    RightClick = {}, ---@type Event<GenericUI_Element_Event_RightClick>
    MouseMove = {}, ---@type Event<GenericUI_Element_Event_MouseMove>
    TweenCompleted = {}, ---@type Event<GenericUI_Element_Event_TweenCompleted>
    ChildAdded = {}, ---@type Event<GenericUI.Element.Events.ChildAdded>
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

---Thrown when the mouse is moved while within the element.
---Only thrown if explicitly enabled, due to performance concerns.
---@see GenericUI_Element.SetMouseMoveEventEnabled
---@class GenericUI_Element_Event_MouseMove
---@field LocalPos Vector2
---@field StagePos Vector2

---@class GenericUI_Element_Event_TweenCompleted
---@field EventID string

---@class GenericUI.Element.Events.ChildAdded
---@field Child GenericUI_Element

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    local mc = self._MovieClip -- Use cached reference
    if not mc then
        mc = self.UI:GetMovieClipByID(self.ID)
        self._MovieClip = mc
    end
    return mc
end

---@generic T
---@param id string
---@param elementType `T`|GenericUI_ElementType
---@return `T`
function _Element:AddChild(id, elementType)
    return self.UI:CreateElement(id, elementType, self)
end

---Returns the parent element.
---@return GenericUI_Element
function _Element:GetParent()
    return self.UI:GetElementByID(self.ParentID)
end

---Returns the children of the element.
---@return GenericUI_Element[] -- By-reference. Careful with destroying children while iterating.
function _Element:GetChildren()
    return self._Children
end

---@param element GenericUI_Element
function _Element:RemoveChild(element)
    if not element:GetParent() == self then
        Generic:LogWarning("Attempted to remove child from wrong parent. " .. element.ID .. " from wrong parent " .. self.ID)
    end
    self.UI:DestroyElement(element)
end

function _Element:_RegisterEvents()
    local _Templates = self.Events

    self.Events = {}

    for id,tbl in pairs(_Templates) do
        self.Events[id] = SubscribableEvent:New(id, tbl.Preventable)
    end
end

---Called after the element is created in flash. Override to run initialization routines.
function _Element:_OnCreation() end

---Adds a child element to track.
---@package
---@param child GenericUI_Element
function _Element:_RegisterChild(child)
    table.insert(self._Children, child)
    self.Events.ChildAdded:Throw({
        Child = child,
    })
end

---Removes a child element to track.
---@package
---@param child GenericUI_Element
function _Element:_UnregisterChild(child)
    local index, _ = table.getFirst(self._Children, function (_, v)
        return v == child
    end)
    table.remove(self._Children, index)
end

---Updates the order of the internal children table by MC child index.
function _Element:__UpdateChildOrder()
    -- Update internal table
    table.sort(self._Children, function (a, b)
        return a:GetChildIndex() < b:GetChildIndex()
    end)
end

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
    table.destroy(self, nil)
    rawset(self, "IsDestroyed", _Element.IsDestroyed)
end

---Returns whether the element has been destroyed.
---No other calls/operations are valid on destroyed elements, and will throw.
---@return boolean
function _Element:IsDestroyed()
    return table.isdestroyed(self)
end

---@deprecated
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

---Returns the global position of the element within the UI.
---@return Vector2
function _Element:GetGlobalPosition()
    local pos = V(self:GetPosition())
    local parent = self:GetParent()
    while parent do
        pos = pos + V(parent:GetPosition())
        parent = parent:GetParent()
    end
    return pos
end

---Returns the position of the element in screen-space.
---@param floor boolean? If `true`, values returned will be floored. Defaults to `true`.
---@return Vector2 -- With decimals.
function _Element:GetScreenPosition(floor)
    if floor == nil then floor = true end
    local pos = self:GetGlobalPosition()
    local uiObj = self.UI:GetUI()
    pos = Vector.ScalarProduct(pos, uiObj:GetUIScaleMultiplier())
    pos = pos + V(uiObj:GetPosition())
    if floor then
        pos[1], pos[2] = math.floor(pos[1]), math.floor(pos[2])
    end
    return pos
end

---Returns the relative position of the mouse within the element.
---@return Vector2
function _Element:GetMousePosition()
    local mc = self:GetMovieClip()
    return V(mc.mouseX, mc.mouseY)
end

---Returns whether the element is visible.
---@return boolean
function _Element:IsVisible()
    return self:GetMovieClip().visible -- This would need to be changed if any overrides are ever used for SetVisible()
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

---Returns the size override of the element, if any.
---@return Vector2?
function _Element:GetSizeOverride()
    local mc = self:GetMovieClip()
    local override = nil

    if mc.widthOverride or mc.heightOverride then
        override = V(self:GetWidth(), self:GetHeight())
    end

    return override
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
    self:__UpdateChildOrder()
end

---Returns the child index of this element within its parent.
---@return integer -- 1-based.
function _Element:GetChildIndex()
    return self:GetMovieClip().GetChildIndex() + 1
end

---Sets the scale of the element.
---@param scale Vector2
function _Element:SetScale(scale)
    local mc = self:GetMovieClip()
    mc.scaleX, mc.scaleY = scale[1], scale[2]
end

---Returns the size of the element.
---@param considerOverrides boolean? If `true`, width/height overrides will be considered. Defaults to `true`.
---@return Vector2
function _Element:GetSize(considerOverrides)
    return V(self:GetWidth(considerOverrides), self:GetHeight(considerOverrides))
end

---Returns the scale of the element.
---@return Vector2
function _Element:GetScale()
    local mc = self:GetMovieClip()
    return V(mc.scaleX, mc.scaleY)
end

---Gets the size of the element without considering its children.
---@return Vector2
function _Element:GetRawSize()
    return V(self:GetRawWidth(), self:GetRawHeight())
end

---Sets the tooltip of the element.
---@param tooltipType TooltipLib_TooltipType
---@param tooltip any? TODO document
function _Element:SetTooltip(tooltipType, tooltip)
    local targetElement = self

    -- Cleanup previous listeners
    targetElement.Events.MouseOver:Unsubscribe("_Tooltip")
    targetElement.Events.MouseOut:Unsubscribe("_Tooltip")

    if tooltip == nil then return end

    if tooltipType == "Simple" then
        if type(tooltip) == "string" then -- String overload
            tooltip = {
                Label = tooltip,
                TooltipStyle = "Simple",
                MouseStickMode = "None",
                UseDelay = true,
            }
        end

        targetElement.Events.MouseOver:Subscribe(function (_)
            Tooltip.ShowSimpleTooltip(tooltip)
        end, {StringID = "_Tooltip"})
    elseif tooltipType == "Skill" then
        targetElement.Events.MouseOver:Subscribe(function (_)
            Tooltip.ShowSkillTooltip(Client.GetCharacter(), tooltip)
        end, {StringID = "_Tooltip"})
    elseif tooltipType == "Custom" then
        targetElement.Events.MouseOver:Subscribe(function (_)
            Tooltip.ShowCustomFormattedTooltip(tooltip)
        end, {StringID = "_Tooltip"})
    else
        Generic:LogError("Element:SetTooltip: unsupported tooltip type " .. tooltipType)
    end

    targetElement.Events.MouseOut:Subscribe(function (_)
        Tooltip.HideTooltip()
    end)
end

__Element.SetPositionRelativeToParent = Generic.ExposeFunction("SetPositionRelativeToParent")
__Element.Move = Generic.ExposeFunction("Move")
__Element.GetWidth = Generic.ExposeFunction("GetWidth")
__Element.GetHeight = Generic.ExposeFunction("GetHeight")
__Element.GetRawWidth = Generic.ExposeFunction("GetRawWidth")
__Element.GetRawHeight = Generic.ExposeFunction("GetRawHeight")
__Element.SetMouseMoveEventEnabled = Generic.ExposeFunction("SetMouseMoveEventEnabled")