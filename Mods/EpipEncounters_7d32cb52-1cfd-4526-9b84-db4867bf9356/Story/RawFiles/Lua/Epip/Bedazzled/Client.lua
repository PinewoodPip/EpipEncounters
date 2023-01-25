
---@class Feature_Bedazzled : Feature
local Bedazzled = {
    GEM_TYPES = {
        Blood = "Item_LOOT_Rune_Bloodstone_Medium",
        Emerald = "Item_LOOT_Rune_Emerald_Medium",
        Thunder = "Item_LOOT_Rune_Thunder_Medium",

    },

    _GemStateClasses = {}, ---@type table<string, Feature_Bedazzled_Board_Gem_State>>
    SPAWNED_GEM_INITIAL_VELOCITY = -4.5,
    GRAVITY = 5.5, -- Units per second squared
    MINIMUM_MATCH_GEMS = 3,
    GEM_SIZE = 1,
    _Gems = {}, ---@type table<string, Feature_Bedazzled_Gem>
}
Epip.RegisterFeature("Bedazzled", Bedazzled)

---------------------------------------------
-- CLASSES
---------------------------------------------

---------------------------------------------
-- BOARD COLUMN
---------------------------------------------

---@class Feature_Bedazzled_Board_Column
---@field Index integer
---@field Size integer
---@field Gems Feature_Bedazzled_Board_Gem[] From bottom to top.
local _BoardColumn = {
    Events = {},
}

---@param size integer
---@return Feature_Bedazzled_Board_Column
function _BoardColumn.Create(index, size)
    ---@type Feature_Bedazzled_Board_Column
    local obj = {
        Index = index,
        Size = size,
        Gems = {},
        Events = {},
    }
    Inherit(obj, _BoardColumn)

    -- Initialize events
    for k,_ in pairs(_BoardColumn.Events) do
        obj.Events[k] = SubscribableEvent:New(k)
    end

    return obj
end

---@param gem Feature_Bedazzled_Board_Gem
function _BoardColumn:InsertGem(gem)
    -- Initial position is at the top of the board,
    -- so the gem falls in
    local startingPosition = (self.Size + #self.Gems + 1) * Bedazzled.GEM_SIZE
    gem:SetPosition(startingPosition)

    table.insert(self.Gems, gem)
end

function _BoardColumn:IsFilled()
    return #self.Gems >= self.Size
end

---@param dt number In seconds.
function _BoardColumn:Update(dt)
    -- Remove consumed gems -- TODO fire event
    for i=#self.Gems,1,-1 do
        local gem = self.Gems[i]
        if gem:IsConsumed() then
            table.remove(self.Gems, i)
        end
    end

    for i,gem in ipairs(self.Gems) do
        local targetPosition = (i - 1) * gem:GetSize()
        if gem:IsFalling() then
            local state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Falling
            state.TargetPosition = targetPosition
        elseif gem:GetPosition() ~= targetPosition and not gem:IsBusy() then -- If a gem is not in its target position, cause it to fall
            gem:SetState(Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create())

            local state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Falling
            state.TargetPosition = targetPosition
            state.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY
        end

        gem:Update(dt)
    end
end

---------------------------------------------
-- BOARD GEM
---------------------------------------------

---@class Feature_Bedazzled_Board_Gem
---@field Type string
---@field X number
---@field Y number
---@field State Feature_Bedazzled_Board_Gem_State
local _BoardGem = {
    Events = {
        StateChanged = {}, ---@type Event<Feature_Bedazzled_Board_Gem_Event_StateChanged>
    },
}

---@class Feature_Bedazzled_Board_Gem_Event_StateChanged
---@field NewState Feature_Bedazzled_Board_Gem_StateClassName
---@field OldState Feature_Bedazzled_Board_Gem_State

---@param type string
---@param state Feature_Bedazzled_Board_Gem_State
---@return Feature_Bedazzled_Board_Gem
function _BoardGem:Create(type, state)
    ---@type Feature_Bedazzled_Board_Gem
    local obj = {
        Type = type,
        Y = 0,
        X = 0,
        Events = {},
    }
    Inherit(obj, self)

    for k,_ in pairs(_BoardGem.Events) do
        obj.Events[k] = SubscribableEvent:New(k)
    end

    -- Set initial state
    obj:SetState(state)

    return obj
end

---Delagated to state.
---@param dt number In seconds.
function _BoardGem:Update(dt)
    self.State:Update(dt)
end

function _BoardGem:GetIcon()
    return self:GetDescriptor():GetIcon()
end

---@param state Feature_Bedazzled_Board_Gem_State
function _BoardGem:SetState(state)
    local oldState = self.State
    state:SetGem(self)

    self.State = state

    self.Events.StateChanged:Throw({
        NewState = state.ClassName,
        OldState = oldState,
    })
end

---@return number
function _BoardGem:GetSize()
    return Bedazzled.GEM_SIZE
end

---@return boolean
function _BoardGem:IsFalling()
    return self.State.ClassName == "Feature_Bedazzled_Board_Gem_State_Falling"
end

function _BoardGem:IsConsumed() -- TODO delegate these methods to state interface
    local state = self.State ---@type Feature_Bedazzled_Board_Gem_State_Consuming

    return self.State.ClassName == "Feature_Bedazzled_Board_Gem_State_Consuming" and state:IsConsumed()
end

---Busy gems cannot start falling.
---@return boolean
function _BoardGem:IsBusy()
    local currentStateClass = self.State.ClassName

    return currentStateClass == "Feature_Bedazzled_Board_Gem_State_InvalidSwap" or currentStateClass == "Feature_Bedazzled_Board_Gem_State_Falling" or currentStateClass == "Feature_Bedazzled_Board_Gem_State_Consuming"
end

---@param y number
function _BoardGem:SetPosition(y)
    self.Y = y
end

---@return number
function _BoardGem:GetPosition()
    return self.Y
end

---@return integer, integer
function _BoardGem:GetBoardPosition()
    return self.X, self.Y
end

---@return Feature_Bedazzled_Gem
function _BoardGem:GetDescriptor()
    return Bedazzled.GetGemDescriptor(self.Type)
end

---@return boolean
function _BoardGem:IsMatchable()
    return self.State.ClassName == "Feature_Bedazzled_Board_Gem_State_Idle"
end

---@param otherGem Feature_Bedazzled_Board_Gem
---@return boolean
function _BoardGem:IsAdjacentTo(otherGem)
    local x, y = otherGem:GetBoardPosition()
    local distanceX, distanceY = math.abs(self.X - x), math.abs(self.Y - y)

    return (distanceX == 1 or distanceY == 1) and not (distanceX >= 1 and distanceY >= 1)
end

---------------------------------------------
-- GEM
---------------------------------------------

---@class Feature_Bedazzled_Gem
---@field Type string
---@field Icon string
local _Gem = {}

---@return string
function _Gem:GetIcon()
    return self.Icon
end

---------------------------------------------
-- MATCH
---------------------------------------------

---@class Feature_Bedazzled_Match
---@field OriginPosition Vector2
---@field Gems Feature_Bedazzled_Board_Gem[]
local _Match = {}

---@param originPosition Vector2
---@return Feature_Bedazzled_Match
function _Match.Create(originPosition)
    ---@type Feature_Bedazzled_Match
    local match = {
        OriginPosition = originPosition,
        Gems = {},
    }
    Inherit(match, _Match)

    return match
end

---@param gem Feature_Bedazzled_Board_Gem
function _Match:AddGem(gem)
    if not table.contains(self.Gems, gem) then
        table.insert(self.Gems, gem)
    end
end

---@return integer
function _Match:GetGemCount()
    return #self.Gems
end

---------------------------------------------
-- BOARD
---------------------------------------------

---@class Feature_Bedazzled_Board
---@field Size Vector2
---@field Columns Feature_Bedazzled_Board_Column[]
local _Board = {
    Events = {
        Updated = {}, ---@type Event<Feature_Bedazzled_Board_Event_Updated>
        GemAdded = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemAdded>
    }
}

---@class Feature_Bedazzled_Board_Event_Updated
---@field DeltaTime number In seconds.

---@class Feature_Bedazzled_Board_Event_GemAdded
---@field Column Feature_Bedazzled_Board_Column
---@field Gem Feature_Bedazzled_Board_Gem

---@param size Vector2
---@return Feature_Bedazzled_Board
function _Board.Create(size)
    ---@type Feature_Bedazzled_Board
    local board = {
        Size = size,
        Columns = {},
        Events = {},
    }
    Inherit(board, _Board)

    -- Initialize events
    for k,_ in pairs(_Board.Events) do
        board.Events[k] = SubscribableEvent:New(k)
    end

    -- Initialize columns
    for i=1,size[1],1 do
        local column = _BoardColumn.Create(i, size[2])

        board.Columns[i] = column
    end

    -- Register update event
    GameState.Events.RunningTick:Subscribe(function (ev)
        board:Update(ev.DeltaTime / 1000)
    end)

    return board
end

---@param dt number In seconds.
function _Board:Update(dt)
    for i,column in ipairs(self.Columns) do
        -- Insert new gem
        if not column:IsFilled() then
            local desc = Bedazzled.GetRandomGemDescriptor()
            local startingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create()
            startingState.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY

            local gem = _BoardGem:Create(desc.Type, startingState)
            gem.X = i

            column:InsertGem(gem)

            self.Events.GemAdded:Throw({
                Gem = gem,
                Column = column,
            })
        end

        column:Update(dt)
    end

    -- Search for a match. Only one match is processed per tick.
    local match ---@type Feature_Bedazzled_Match
    -- local match = self:GetMatchAt(1, 1)
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            match = self:GetMatchAt(x, y)

            if match then
                break
            end
        end

        if match then
            break
        end
    end

    if match then
        self:ConsumeMatch(match)
    end

    self.Events.Updated:Throw({DeltaTime = dt})
end

---@param match Feature_Bedazzled_Match
function _Board:ConsumeMatch(match)
    local consumingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Consuming")

    for _,gem in ipairs(match.Gems) do
        gem:SetState(consumingState:Create())    
    end
end

---@param x integer Column index.
---@param y integer Gem index within the column.
---@return Feature_Bedazzled_Board_Gem
function _Board:GetGemAt(x, y)
    local column = self.Columns[x]

    return column and column.Gems[y]
end

---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function _Board:CanSwap(gem1, gem2)
    local canSwap = true

    canSwap = canSwap and gem1 ~= gem2
    canSwap = canSwap and gem1:IsAdjacentTo(gem2)
    canSwap = canSwap and not gem1:IsBusy() and not gem2:IsBusy()

    return canSwap
end

---@param position1 Vector2
---@param position2 Vector2
function _Board:Swap(position1, position2)
    local gem1 = self:GetGemAt(position1:unpack())
    local gem2 = self:GetGemAt(position2:unpack())

    if gem1 and gem2 and self:CanSwap(gem1, gem2) then
        gem1.Type, gem2.Type = gem2.Type, gem1.Type

        local swappingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Swapping")

        gem1:SetState(swappingState:Create(gem2))
        gem2:SetState(swappingState:Create(gem1))
    end
end

---Returns whether 2 gems can be matched.
---@param gem Feature_Bedazzled_Board_Gem
---@param otherGem Feature_Bedazzled_Board_Gem
---@return boolean
function _Board:IsGemMatchableWith(gem, otherGem)
    local matchable = true

    if gem == nil or otherGem == nil then
        Bedazzled:Error("Board:IsGemMatchableWith", "Attempted to compare nil gems")
    end

    matchable = matchable and gem:IsMatchable() and otherGem:IsMatchable()
    matchable = matchable and gem:GetDescriptor().Type == otherGem:GetDescriptor().Type

    return matchable
end

---Returns the match that exists at the coordinates.
---@param x integer
---@param y integer
---@return Feature_Bedazzled_Match?
function _Board:GetMatchAt(x, y)
    local gem = self:GetGemAt(x, y)
    if not gem then return nil end

    local startingX = x
    local startingY = y
    local match = _Match.Create(Vector.Create(x, y))

    -- Find starting X position for the match
    local otherGem = self:GetGemAt(x - 1, startingY)
    while otherGem and self:IsGemMatchableWith(gem, otherGem) do
        startingX = startingX - 1
        otherGem = self:GetGemAt(startingX - 1, y)
    end

    -- Add horizontal gems
    local horizontalGems = {}
    local currentX = startingX
    local horizontalGem = self:GetGemAt(currentX, y)
    while horizontalGem and self:IsGemMatchableWith(gem, horizontalGem) do
        table.insert(horizontalGems, horizontalGem)
        currentX = currentX + 1
        horizontalGem = self:GetGemAt(currentX, y)
    end

    -- Find starting Y position for the match
    otherGem = self:GetGemAt(x, startingY + 1)
    while otherGem and self:IsGemMatchableWith(gem, otherGem) do
        startingY = startingY + 1
        otherGem = self:GetGemAt(x, startingY + 1)
    end

    -- Add vertical gems
    local verticalGems = {}
    local currentY = startingY
    local verticalGem = self:GetGemAt(x, currentY)
    while verticalGem and self:IsGemMatchableWith(gem, verticalGem) do
        table.insert(verticalGems, verticalGem)
        currentY = currentY - 1
        verticalGem = self:GetGemAt(x, currentY)
    end

    -- Only add gems if there were >= MINIMUM_MATCH_GEMS in the row/column
    if #horizontalGems >= Bedazzled.MINIMUM_MATCH_GEMS then
        for _,hgem in ipairs(horizontalGems) do
            match:AddGem(hgem)
        end
    end
    if #verticalGems >= Bedazzled.MINIMUM_MATCH_GEMS then
        for _,vgem in ipairs(verticalGems) do
            match:AddGem(vgem)
        end
    end

    return match:GetGemCount() >= Bedazzled.MINIMUM_MATCH_GEMS and match or nil
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Bedazzled_Gem
function Bedazzled.RegisterGem(data)
    Inherit(data, _Gem)

    Bedazzled._Gems[data.Type] = data
end

---@param type string
---@return Feature_Bedazzled_Gem?
function Bedazzled.GetGemDescriptor(type)
    return Bedazzled._Gems[type]
end

---@return Feature_Bedazzled_Board
function Bedazzled.CreateBoard()
    local board = _Board.Create(Vector.Create(8, 8))

    return board
end

---@return Feature_Bedazzled_Gem
function Bedazzled.GetRandomGemDescriptor()
    local gems = {}
    for _,g in pairs(Bedazzled._Gems) do
        table.insert(gems, g)
    end

    return gems[math.random(#gems)]
end

---@generic T
---@param className `T`|Feature_Bedazzled_Board_Gem_StateClassName
---@return `T`|Feature_Bedazzled_Board_Gem_State
function Bedazzled.GetGemStateClass(className)
    local class = Bedazzled._GemStateClasses[className]
    if not class then
        Bedazzled:Error("GetGemStateClass", "Class is not registered:", className)
    end
    return class
end

---@param className string
---@param class Feature_Bedazzled_Board_Gem_State
function Bedazzled.RegisterGemStateClass(className, class)
    class.ClassName = className
    Bedazzled._GemStateClasses[className] = class
end

---------------------------------------------
-- SETUP
---------------------------------------------

---@type Feature_Bedazzled_Gem[]
local gems = {
    {
        Type = "Bloodstone",
        Icon = "Item_LOOT_Gem_Bloodstone",
    },
    {
        Type = "Jade",
        Icon = "Item_LOOT_Gem_Jade",
    },
    {
        Type = "Sapphire",
        Icon = "Item_LOOT_Gem_Sapphire",
    },
    {
        Type = "Topaz",
        Icon = "Item_LOOT_Gem_Topaz",
    },
    {
        Type = "Onyx",
        Icon = "Item_LOOT_Gem_Onyx",
    },
    {
        Type = "Emerald",
        Icon = "Item_LOOT_Gem_Emerald",
    },
    {
        Type = "Lapis",
        Icon = "Item_LOOT_Gem_Lapis",
    },
    {
        Type = "TigersEye",
        Icon = "Item_LOOT_Gem_TigersEye",
    },
}
for _,gem in ipairs(gems) do
    Bedazzled.RegisterGem(gem)
end