
local Generic = Client.UI.Generic
local V = Vector.Create

---@class GenericUI.Prefabs.Containers.VerticalList : GenericUI_I_Container
---@field _ElementSpacing number
local VerticalList = {

}
Generic:RegisterClass("GenericUI.Prefabs.Containers.VerticalList", VerticalList, {"GenericUI_I_Container"})
Generic.RegisterPrefab("GenericUI.Prefabs.Containers.VerticalList", VerticalList)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.Containers.VerticalList"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@return GenericUI.Prefabs.Containers.VerticalList
function VerticalList.Create(ui, id, parent)
    local instance = VerticalList:__CreateRoot(ui, id, parent) ---@cast instance GenericUI.Prefabs.Containers.VerticalList

    instance._ElementSpacing = 0

    return instance
end

---Sets the spacing to use between elements.
---@param spacing number
function VerticalList:SetElementSpacing(spacing)
    self._ElementSpacing = spacing
end

---@override
function VerticalList:PositionElements()
    local children = self:__GetPositionableChildren()
    local childrenCount = #children
    local containerWidth = 0
    local containerHeight = 0

    for i=1,childrenCount,1 do
        local child = children[i]
        local childHeight = child:GetHeight()

        child:SetPosition(0, containerHeight) -- TODO centering options?

        containerHeight = containerHeight + childHeight
        if i ~= childrenCount then -- Add element spacing
            containerHeight = containerHeight + self._ElementSpacing
        end
    end

    self:SetSizeOverride(V(containerWidth, containerHeight)) -- TODO allow setting this by user
end
