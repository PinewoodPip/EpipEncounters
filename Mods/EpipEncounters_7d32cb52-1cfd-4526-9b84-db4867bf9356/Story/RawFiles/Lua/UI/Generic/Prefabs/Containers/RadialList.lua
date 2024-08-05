
local Generic = Client.UI.Generic
local V = Vector.Create

---@class GenericUI.Prefabs.Containers.RadialList : GenericUI_I_Container, GenericUI_I_Elementable
---@field __Config GenericUI.Prefabs.Containers.RadialList.Config
local List = {}
Generic:RegisterClass("GenericUI.Prefabs.Containers.RadialList", List, {"GenericUI_I_Container", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.Containers.RadialList", List)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.Containers.RadialList"

---@class GenericUI.Prefabs.Containers.RadialList.Config
---@field Radius number
---@field RotateElements boolean? Defaults to `false`.
---@field CenterElements boolean? Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier
---@param config GenericUI.Prefabs.Containers.RadialList.Config
---@return GenericUI.Prefabs.Containers.RadialList
function List.Create(ui, id, parent, config)
    local instance = List:__CreateRoot(ui, id, parent) ---@cast instance GenericUI.Prefabs.Containers.RadialList
    if config.CenterElements == nil then config.CenterElements = true end
    instance.__Config = config
    return instance
end

---@override
function List:PositionElements()
    local radius, rotateElements, centerElements = self.__Config.Radius, self.__Config.RotateElements, self.__Config.CenterElements
    local children = self:__GetPositionableChildren()
    local childrenCount = #children
    local containerWidth = 0
    local containerHeight = 0

    for i=1,childrenCount,1 do
        local child = children[i]
        local radialPosition = (i - 1) / childrenCount * math.pi * 2 - (math.pi * 2 * 0.25)
        local x, y = math.cos(radialPosition) * radius, math.sin(radialPosition) * radius
        child:SetPosition(x, y)

        if rotateElements then
            child:SetRotation(math.deg(radialPosition) + 90)
        end
        if centerElements then
            child:Move(-child:GetWidth() / 2, -child:GetHeight() / 2)
        end
    end

    self:SetSizeOverride(V(containerWidth, containerHeight)) -- TODO allow setting this by user
end

---@override
function List:GetRootElement()
    return self.Root
end
