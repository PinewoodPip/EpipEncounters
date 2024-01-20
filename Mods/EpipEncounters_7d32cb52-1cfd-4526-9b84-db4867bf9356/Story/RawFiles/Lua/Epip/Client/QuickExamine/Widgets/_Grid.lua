
---------------------------------------------
-- Implements a Quick Examine widget with a grid layout.
---------------------------------------------

local QuickExamine = Epip.GetFeature("Feature_QuickExamine")

---@class Features.QuickExamine.Widgets.Grid : Features.QuickExamine.Widget
---@field HEADER_LABEL TextLib_TranslatedString|string
---@field Grid GenericUI_Element_Grid Created automatically.
local Widget = {}
QuickExamine:RegisterClass("Features.QuickExamine.Widgets.Grid", Widget, {"Features.QuickExamine.Widget"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the size of the grid to use.
---@abstract
---@return Vector2
---@diagnostic disable-next-line: missing-return
function Widget:GetGridSize() QuickExamine:Error("Widgets.Grid:GetGridSize", "Not implemented") end

---Renders the elements onto the grid.
---Called after initializing the header and grid of the widget.
---@param entity Feature_QuickExamine_Entity
---@abstract
---@diagnostic disable-next-line: unused-local
function Widget:RenderGridElements(entity)
    QuickExamine:Error("Widgets.Grid:RenderGridElements", "Not implemented")
end

---@override
function Widget:Render(entity)
    local container = QuickExamine.GetContainer()

    self:CreateHeader(self:_PrefixID("Header"), container, Text.Resolve(self.HEADER_LABEL))

    local grid = container:AddChild(self:_PrefixID("Grid"), "GenericUI_Element_Grid")
    grid:SetGridSize(self:GetGridSize():unpack())
    grid:SetCenterInLists(true)
    self.Grid = grid

    self:RenderGridElements(entity)

    self:CreateDivider(self:_PrefixID("Divider"), container)
end

---Prefixes an ID with the instance's class name.
---@param id string
---@return string
function Widget:_PrefixID(id)
    return self:GetClassName() .. "." .. id
end
