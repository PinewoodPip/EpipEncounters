
local Generic = Client.UI.Generic
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES

-- Prefab for a loading flower.
---@class GenericUI.Prefabs.LoadingFlower : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field Petals GenericUI_Element_Texture[] From top, clockwise.
local LoadingFlower = {
    TWEEN_POSITION_OFFSET = 15, -- Position offset for petals while tweening outwards.
    TWEEN_DURATION = 0.5, -- In seconds, per petal.
    TWEEN_DELAY = 3.3,

    _PETALS_COUNT = 8,
}
Generic:RegisterClass("GenericUI.Prefabs.LoadingFlower", LoadingFlower, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.LoadingFlower", LoadingFlower)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.LoadingFlower"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@return GenericUI.Prefabs.LoadingFlower
function LoadingFlower.Create(ui, id, parent)
    local instance = LoadingFlower:_Create(ui, id) ---@cast instance GenericUI.Prefabs.LoadingFlower
    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    -- Create petals
    instance.Petals = {}
    for i=1,instance._PETALS_COUNT,1 do
        local petalHolder = instance:CreateElement("PetalHolder" .. tostring(i), "GenericUI_Element_Empty", root)
        local petal = instance:CreateElement("Petal" .. tostring(i), "GenericUI_Element_Texture", petalHolder)

        if i % 2 == 1 then -- Cardinal petals
            petal:SetTexture(Textures.MISC.LOADING_FLOWER.CARDINAL)

            local rotation = (math.ceil(i / 2) - 1) * 720 / instance._PETALS_COUNT
            local yPos = -petal:GetHeight() - 5
            petal:SetPosition(-petal:GetWidth() / 2, yPos)
            petalHolder:SetRotation(rotation)
        else -- Diagonal petals
            petal:SetTexture(Textures.MISC.LOADING_FLOWER.DIAGONAL)
            petal:SetPosition(0, -petal:GetHeight())
            petalHolder:SetRotation((i // 2 - 1) * 720 / instance._PETALS_COUNT)
        end

        instance.Petals[i] = petal
    end

    -- Start the tween loops
    for i=1,instance._PETALS_COUNT,1 do
        local petal = instance.Petals[i]
        Timer.Start(instance.TWEEN_DURATION * (i - 1), function (_)
            ---@diagnostic disable-next-line: invisible
            petal:Tween(instance:_GetOutwardTween(petal, i % 2 == 0))
        end)
    end

    return instance
end

---@override
function LoadingFlower:GetRootElement()
    return self.Root
end

---Returns the outward-moving tween to use for a petal.
---@param petal GenericUI_Element_Texture
---@param isDiagonal boolean
---@return GenericUI_ElementTween
function LoadingFlower:_GetOutwardTween(petal, isDiagonal)
    local xPos, yPos = petal:GetPosition()
    ---@type GenericUI_ElementTween
    local tween = {
        EventID = Text.GenerateGUID(),
        Duration = self.TWEEN_DURATION,
        Ease = "EaseIn",
        FinalValues = {
            y = yPos - self.TWEEN_POSITION_OFFSET,
            x = xPos + (isDiagonal and self.TWEEN_POSITION_OFFSET or 0),
        },
        Type = "To",
        Function = "Quadratic",
        Delay = self.TWEEN_DELAY,
        OnComplete = function (_)
            -- Delay needed to avoid a freeze from some infinite loop - possible bug in Generic? TODO
            Ext.OnNextTick(function ()
                petal:Tween(self:_GetInwardTween(petal, isDiagonal))
            end)
        end
    }
    return tween
end

---Returns the inward-moving tween to use for a petal.
---@param petal GenericUI_Element_Texture
---@param isDiagonal boolean
---@return GenericUI_ElementTween
function LoadingFlower:_GetInwardTween(petal, isDiagonal)
    local xPos, yPos = petal:GetPosition()
    ---@type GenericUI_ElementTween
    local tween = {
        EventID = Text.GenerateGUID(),
        Duration = self.TWEEN_DURATION,
        Ease = "EaseIn",
        FinalValues = {
            y = yPos + self.TWEEN_POSITION_OFFSET,
            x = xPos - (isDiagonal and self.TWEEN_POSITION_OFFSET or 0),
        },
        Type = "To",
        Function = "Quadratic",
        OnComplete = function (_)
            -- Delay needed to avoid a freeze from some infinite loop - possible bug in Generic? TODO
            Ext.OnNextTick(function ()
                petal:Tween(self:_GetOutwardTween(petal, isDiagonal))
            end)
        end
    }
    return tween
end
