
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Generic = Client.UI.Generic
local V = Vector.Create

local UI = Generic.Create("Feature_Bedazzled")
UI:Hide()

UI._Initialized = false
UI.Board = nil ---@type Feature_Bedazzled_Board
UI.Gems = {} ---@type table<GUID, GenericUI_Prefab_Bedazzled_Gem>
UI.SelectedPosition = nil ---@type Vector2?

UI.CELL_BACKGROUND = "Item_Epic"
UI.CELL_SIZE = V(64, 64)
UI.BACKGROUND_SIZE = V(700, 800)

---------------------------------------------
-- GEM PREFAB
---------------------------------------------

---@class GenericUI_Prefab_Bedazzled_Gem : GenericUI_Prefab, GenericUI_Element
---@field Gem Feature_Bedazzled_Board_Gem
---@field Root GenericUI_Element_Empty
---@field Icon GenericUI_Element_IggyIcon
local GemPrefab = {

}
Generic.RegisterPrefab("GenericUI_Prefab_Bedazzled_Gem", GemPrefab)

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param gem Feature_Bedazzled_Board_Gem
---@return GenericUI_Prefab_Bedazzled_Gem
function GemPrefab.Create(ui, id, parent, gem)
    ---@diagnostic disable-next-line: invisible
    local element = GemPrefab:_Create(ui, id) ---@type GenericUI_Prefab_Bedazzled_Gem

    element.Gem = gem

    local root = element:CreateElement("Container", "GenericUI_Element_Empty", parent)
    element.Root = root
    local icon = element:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
    element.Icon = icon

    icon:SetPosition(-UI.CELL_SIZE[1] / 2, -UI.CELL_SIZE[2]/2)

    root:SetMouseEnabled(false)
    root:SetMouseChildren(false)

    element:UpdateIcon()

    return element
end

---@param tween GenericUI_ElementTween
function GemPrefab:Tween(tween)
    self.Root:Tween(tween)
end

function GemPrefab:Update()
    local gem = self.Gem
    local root = self.Root
    local x, y = UI.GamePositionToUIPosition(self.Gem.X, gem:GetPosition())
    local gemState = gem.State.ClassName

    if gemState == "Feature_Bedazzled_Board_Gem_State_InvalidSwap" or gemState == "Feature_Bedazzled_Board_Gem_State_Swapping" then
        -- Handled by tween
    else
        root:SetPosition(x, y)
    end

    self:UpdateIcon()
end

function GemPrefab:UpdateIcon()
    local iconElement = self.Icon
    local gem = self.Gem
    local icon
    
    icon = gem:GetIcon()

    iconElement:SetIcon(icon, UI.CELL_SIZE:unpack())
end

---Returns the gem's position on the UI grid, in pixels.
function GemPrefab:GetGridPosition()
    local gem = self.Gem
    local x, y = gem.X, gem.Y

    return UI.GamePositionToUIPosition(x, y)
end

---------------------------------------------
-- METHODS
---------------------------------------------

function UI.Setup()
    local board = Bedazzled.CreateBoard()
    UI.Board = board

    UI._Initialize(board)

    -- Update UI when the board updates.
    board.Events.Updated:Subscribe(function (ev)
        UI.Update(ev.DeltaTime)
    end)

    board.Events.GemAdded:Subscribe(function (ev)
        local gem = ev.Gem
        local guid = Text.GenerateGUID()
        local element = GemPrefab.Create(UI, guid, UI.Background, gem)

        -- Forward state change events.
        gem.Events.StateChanged:Subscribe(function (stateChangeEv)
            UI.OnGemStateChanged(gem, stateChangeEv.NewState, stateChangeEv.OldState)
        end)

        UI.Gems[guid] = element
    end)

    UI:Show()
end

---@param gem Feature_Bedazzled_Board_Gem
---@param newState Feature_Bedazzled_Board_Gem_StateClassName
---@param oldState Feature_Bedazzled_Board_Gem_State
function UI.OnGemStateChanged(gem, newState, oldState)
    local element = UI.GetGemElement(gem)
    local state

    if oldState.ClassName == "Feature_Bedazzled_Board_Gem_State_Swapping" then
        element:UpdateIcon()
    end

    if newState == "Feature_Bedazzled_Board_Gem_State_Swapping" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Swapping
        local otherGem = state.OtherGem
        local otherElement = UI.GetGemElement(otherGem)

        element.Gem, otherElement.Gem = otherElement.Gem, element.Gem

        local element1x, element1y = UI.GamePositionToUIPosition(element.Gem:GetBoardPosition())
        local element2x, element2y = UI.GamePositionToUIPosition(otherElement.Gem:GetBoardPosition())

        -- Tween both gems to make it look like they're swapping places
        -- In the game logic, this actually happens instantly.
        -- Match-checks are delayed until the Swapping state ends.
        otherElement:Tween({
            EventID = "Bedazzled_Swap1",
            FinalValues = {
                x = element2x,
                y = element2y,
            },
            StartingValues = {
                x = element1x,
                y = element1y,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
        })
        element:Tween({
            EventID = "Bedazzled_Swap1",
            FinalValues = {
                x = element1x,
                y = element1y,
            },
            StartingValues = {
                x = element2x,
                y = element2y,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
        })
    elseif newState == "Feature_Bedazzled_Board_Gem_State_Consuming" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Consuming

        element:Tween({
            EventID = "Bedazzled_Consume",
            FinalValues = {
                scaleX = 0, -- TODO dispose of elements afterwards
                scaleY = 0,
            },
            StartingValues = {
                scaleX = 1.2,
                scaleY = 1.2,
            },
            Function = "Quadratic",
            Ease = "EaseInOut",
            Duration = state.Duration,
        })
    end
end

---@param x integer
---@param y integer
function UI.SelectGem(x, y)
    local selector = UI.Selector
    local gem = UI.Board:GetGemAt(x, y)
    local element = UI.GetGemElement(gem)

    if gem and element and not gem:IsBusy() and not gem:IsFalling() then
        -- TODO change to idle only
        if UI.SelectedPosition then -- Swap gems
            UI.Board:Swap(UI.SelectedPosition, V(x, y))
            UI.SelectedPosition = nil
            selector:SetVisible(false)
        else -- Select gem
            local visualPositionX, visualPositionY = element:GetGridPosition()
            visualPositionX = visualPositionX - UI.CELL_SIZE[1]/2
            visualPositionY = visualPositionY - UI.CELL_SIZE[2]/2

            selector:SetPosition(visualPositionX, visualPositionY)
            selector:SetVisible(true)

            UI.SelectedPosition = V(x, y)
        end
    end
end

---@param gem Feature_Bedazzled_Board_Gem
---@return GenericUI_Prefab_Bedazzled_Gem
function UI.GetGemElement(gem)
    local element

    for _,gemElement in pairs(UI.Gems) do
        if gemElement.Gem == gem then
            element = gemElement
        end
    end

    return element
end

---@return number, number --Width, height, in pixels.
function UI.GetBoardDimensions()
    return UI.Board.Size[2] * UI.CELL_SIZE[1], UI.Board.Size[1] * UI.CELL_SIZE[2]
end

---@param board Feature_Bedazzled_Board
function UI._Initialize(board)
    if not UI._Initialized then
        local bg = UI:CreateElement("Background", "GenericUI_Element_TiledBackground")
        UI.Background = bg
        bg:SetBackground("Black", UI.BACKGROUND_SIZE:unpack())
        bg:SetAlpha(0.1)

        local grid = bg:AddChild("BackgroundGrid", "GenericUI_Element_Grid")
        grid:SetGridSize(board.Size:unpack())
        grid:SetElementSpacing(0, 0)
        UI.Grid = grid

        for i=1,board.Size[1]*board.Size[2],1 do
            local icon = grid:AddChild("BackgroundGrid_Icon_" .. i, "GenericUI_Element_IggyIcon")
            icon:SetIcon(UI.CELL_BACKGROUND, UI.CELL_SIZE:unpack())
        end

        -- Create clickboxes for selecting gems
        local clickboxGrid = bg:AddChild("ClickboxGrid", "GenericUI_Element_Grid")
        clickboxGrid:SetGridSize(board.Size:unpack())
        -- clickboxGrid:GetMovieClip().gridList.ROW_SPACING = 0
        clickboxGrid:SetElementSpacing(0, 0)
        for i=1,board.Size[1],1 do
            for j=1,board.Size[2],1 do
                local clickbox = clickboxGrid:AddChild("Clickbox_" .. i .. "_" .. j, "GenericUI_Element_Color")
                clickbox:SetColor(Color.Create(255, 128, 128))
                clickbox:SetSize(UI.CELL_SIZE:unpack())
    
                clickbox.Events.MouseDown:Subscribe(function (_)
                    UI.SelectGem(j, board.Size[1] - i + 1)
                end)
            end
        end

        local selector = bg:AddChild("Selector", "GenericUI_Element_IggyIcon")
        selector:SetIcon("Item_Divine", UI.CELL_SIZE:unpack())
        selector:SetVisible(false)
        UI.Selector = selector
    end

    UI._Initialized = true
end

---@param x number
---@param y number
---@return number, number
function UI.GamePositionToUIPosition(x, y)
    local board = UI.Board

    local UIboardHeight = UI.CELL_SIZE[2] * board.Size[1]
    local UIBoardWidth = UI.CELL_SIZE[1] * board.Size[2]
    local gameBoardHeight = Bedazzled.GEM_SIZE * board.Size[1]
    local gameBoardWidth = board.Size[2]

    local translatedPositionY = y / gameBoardHeight * UIboardHeight
    translatedPositionY = UIboardHeight - translatedPositionY - UI.CELL_SIZE[2]

    local translatedPositionX = (x - 1) / gameBoardWidth * UIBoardWidth

    translatedPositionX = translatedPositionX + UI.CELL_SIZE[1] / 2
    translatedPositionY = translatedPositionY + UI.CELL_SIZE[2] / 2

    return translatedPositionX, translatedPositionY
end

---@param dt number In seconds.
---@diagnostic disable-next-line: unused-local
function UI.Update(dt)
    for _,element in pairs(UI.Gems) do
        element:Update()
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add Bedazzled option to gem context menus.
local function IsRuneCraftingMaterial(item) -- TODO move
    local RUNE_MATERIAL_STATS = {
        LOOT_Bloodstone_A = "Bloodstone",
        TOOL_Pouch_Dust_Bone_A = "Bone",
        LOOT_Clay_A = "Clay",
        LOOT_Emerald_A = "Emerald",
        LOOT_Granite_A = "Granite",
        LOOT_OreBar_A_Iron_A = "Iron",
        LOOT_Jade_A = "Jade",
        LOOT_Lapis_A = "Lapis",
        LOOT_Malachite_A = "Malachite",
        LOOT_Obsidian_A = "Obsidian",
        LOOT_Onyx_A = "Onyx",
        LOOT_Ruby_A = "Ruby",
        LOOT_Sapphire_A = "Sapphire",
        LOOT_OreBar_A_Silver_A = "Silver",
        LOOT_OreBar_A_Steel_A = "Steel",
        LOOT_Tigerseye_A = "TigersEye",
        LOOT_Topaz_A = "Topaz",
    }

    return RUNE_MATERIAL_STATS[item.StatsId] ~= nil
end
Client.UI.ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    print(IsRuneCraftingMaterial(item))
    if IsRuneCraftingMaterial(item) then
        Client.UI.ContextMenu.AddElement({
            {id = "epip_Feature_Bedazzled", type = "button", text = "Bedazzle"},
        })
    end
end)

-- Start the game when the context menu option is selected.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_Bedazzled", "buttonPressed", function(_, _)
    UI.Setup()
end)