
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_VerticalList : GenericUI_Element
local VerticalList = {

}
Inherit(VerticalList, Generic._Element)
local _VerticalList = VerticalList

---------------------------------------------
-- METHODS
---------------------------------------------

---Removes all elements from the container.
function VerticalList:Clear()
    local children = self:GetChildren()
    for i=#children,1,-1 do
        children[i]:Destroy()
    end
    self:GetMovieClip().Clear() -- TODO is this necessary?
end

---Sorts the elements of the list by child index and repositions them.
function VerticalList:SortByChildIndex()
    local mc = self:GetMovieClip()
    mc.SortByChildIndex()
    self:__UpdateChildOrder()
end

_VerticalList.RepositionElements = Generic.ExposeFunction("Reposition")
_VerticalList.SetTopSpacing = Generic.ExposeFunction("SetTopSpacing")
_VerticalList.SetElementSpacing = Generic.ExposeFunction("SetElementSpacing")
_VerticalList.SetSideSpacing = Generic.ExposeFunction("SetSideSpacing")
_VerticalList.SetRepositionAfterAdding = Generic.ExposeFunction("SetRepositionAfterAdding")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("VerticalList", VerticalList)