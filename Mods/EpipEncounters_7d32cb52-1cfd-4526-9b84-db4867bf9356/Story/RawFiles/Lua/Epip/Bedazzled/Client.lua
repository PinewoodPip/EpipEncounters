
---@class Feature_Bedazzled : Feature
local Bedazzled = {
    _Gems = {}, ---@type table<string, Feature_Bedazzled_Gem>
    _GemStateClasses = {}, ---@type table<string, Feature_Bedazzled_Board_Gem_State>>

    TranslatedStrings = {
        GameTitle = {
            Handle = "h833e3d98g6e6bg4cfag9c23g1bcd1c8e9de1",
            Text = "Bedazzled",
        },
        Score = {
            Handle = "h4bc543cag5f19g4e91gbb76gc3a18177874b",
            Text = "Score    %s",
            ContextDescription = "Template string for displaying current score",
        },
        GameOver = {
            Handle = "h3166017ag50b9g4943g8ae9g5335c23c58e4",
            Text = "Game Over",
        },
        GameOverSubTitle = {
            Handle = "h1b460fc0ge72dg4879g9886g1dc640a782cb",
            Text = "No more valid moves on the board!",
            ContextDescription = "Subtitle for game over text",
        }
    },
    DoNotExportTSKs = true,

    SPAWNED_GEM_INITIAL_VELOCITY = -4.5,
    GRAVITY = 5.5, -- Units per second squared
    MINIMUM_MATCH_GEMS = 3,
    GEM_SIZE = 1,
}
Epip.RegisterFeature("Bedazzled", Bedazzled)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Bedazzled_Gem
function Bedazzled.RegisterGem(data)
    local GemClass = Bedazzled:GetClass("Feature_Bedazzled_Gem")

    data = GemClass.Create(data)

    Bedazzled._Gems[data.Type] = data
end

---@param type string
---@return Feature_Bedazzled_Gem?
function Bedazzled.GetGemDescriptor(type)
    return Bedazzled._Gems[type]
end

---Returns all registered gem descriptors.
---@return table<string, Feature_Bedazzled_Gem>
function Bedazzled.GetGemDescriptors()
    return Bedazzled._Gems
end

---@return Feature_Bedazzled_Board
function Bedazzled.CreateBoard()
    local BoardClass = Bedazzled:GetClass("Feature_Bedazzled_Board")

    local board = BoardClass.Create(Vector.Create(8, 8))

    return board
end

---@return Feature_Bedazzled_Gem
function Bedazzled.GetRandomGemDescriptor()
    local totalWeight = 0
    local gems = {} ---@type Feature_Bedazzled_Gem[]
    local chosenGem

    for _,g in pairs(Bedazzled._Gems) do
        totalWeight = totalWeight + g.Weight
        table.insert(gems, g)
    end

    if #gems == 0 then
        Bedazzled:Error("GetRandomGemDescriptor", "No gems are registered.")
    end

    local seed = math.random(0, totalWeight)
    for _,g in ipairs(gems) do
        seed = seed - g.Weight

        if seed <= 0 then
            chosenGem = g
            break
        end
    end

    return chosenGem
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

GameState.Events.ClientReady:Subscribe(function (_)
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
end)