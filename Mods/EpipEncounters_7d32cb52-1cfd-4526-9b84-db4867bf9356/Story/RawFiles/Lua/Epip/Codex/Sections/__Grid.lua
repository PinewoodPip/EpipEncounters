
local Codex = Epip.GetFeature("Feature_Codex")
local V = Vector.Create

---Implements a Codex section with a Grid-based layout and element pooling.
---Element fields are initialized by the classes's methods.
---Be sure to call the base class methods when overriding.
---Override constants at your leisure.
---@class Features.Codex.Sections.Grid : Feature_Codex_Section
---@field Root GenericUI_Element_Empty
---@field Grid GenericUI_Element_Grid
---@field GridScrollList GenericUI_Element_ScrollList
---@field _GridElements (GenericUI_Element|GenericUI_I_Elementable)[]
local GridSection = {
    CONTAINER_OFFSET = V(35, 35),
    GRID_LIST_FRAME = V(Codex.UI.CONTENT_CONTAINER_SIZE[1], 640),
    GRID_OFFSET = V(0, 100),
    ICON_SIZE = V(58, 58),
}
Codex:RegisterClass("Features.Codex.Sections.Grid", GridSection, {"Feature_Codex_Section"})

---@override
---@param root GenericUI_Element_Empty
function GridSection:Render(root)
    self._GridElements = {}

    root:Move(self.CONTAINER_OFFSET:unpack())

    local gridScrollList = root:AddChild(self:_PrefixElement("ScrollList"), "GenericUI_Element_ScrollList")
    gridScrollList:SetFrame(self.GRID_LIST_FRAME:unpack())
    gridScrollList:Move(self.GRID_OFFSET:unpack())
    gridScrollList:SetMouseWheelEnabled(true)
    gridScrollList:SetScrollbarSpacing(-80)

    local grid = gridScrollList:AddChild(self:_PrefixElement("Grid"), "GenericUI_Element_Grid")
    local columns = math.floor(self.GRID_LIST_FRAME[1] / (self.ICON_SIZE[1] + 5))
    grid:SetRepositionAfterAdding(false)
    grid:SetGridSize(columns, -1)

    self.Root = root
    self.Grid = grid
    self.GridScrollList = gridScrollList
end

---Called when a new grid element needs to be created.
---@abstract
---@param index integer
---@return GenericUI_Element|GenericUI_I_Elementable
---@diagnostic disable-next-line: missing-return, unused-local
function GridSection:__CreateElement(index) end

---Called from `__Update()`, passing the index of the element to update as well as its new data.
---You are expected to call this from `Section:Update()`.
---@abstract
---@param index integer
---@param element GenericUI_Element|GenericUI_I_Elementable
---@param data any
---@diagnostic disable-next-line: unused-local
function GridSection:__UpdateElement(index, element, data) end

---Call to update the grid with new object data.
---The objects will be passed onto `__UpdateElement()`.
---@see Features.Codex.Sections.Grid.__UpdateElement
---@param data any[]
function GridSection:__Update(data)
    for i=1,#data,1 do
        local element = self._GridElements[i]
        if not element then -- Create element if necessary
            element = self:__CreateElement(i)
            self._GridElements[i] = element
        end
        self:__UpdateElement(i, element, data[i])
        self._GridElements[i]:SetVisible(true)
    end
    for i=#data+1,#self._GridElements,1 do
        self._GridElements[i]:SetVisible(false)
    end
    self.Grid:RepositionElements()

    self.GridScrollList:RepositionElements()
    self.GridScrollList:GetMovieClip().list.resetScroll() -- TODO public API
end

---Prefixes an ID with the section's ID.
---@param id string
---@return string
function GridSection:_PrefixElement(id)
    return self.ID .. "_" .. id
end