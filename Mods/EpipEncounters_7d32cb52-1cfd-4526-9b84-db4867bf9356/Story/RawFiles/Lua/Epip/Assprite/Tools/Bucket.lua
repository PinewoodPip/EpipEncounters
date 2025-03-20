
---------------------------------------------
-- Fill bucket tool.
---------------------------------------------

local ICONS = Epip.GetFeature("Feature_GenericUITextures").ICONS
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.Bucket : Features.Assprite.Tool
local Bucket = {
    ICON = ICONS.FRAMED_GEMS.YELLOW, -- TODO
    Name = Assprite:RegisterTranslatedString({
        Handle = "h1189e170g0d10g4bffga7a0g300c8d491098",
        Text = [[Bucket Fill]],
        ContextDescription = [[Tool name]],
    }),

    SIMILARITY_THRESHOLD = 24, -- TODO extract setting
}
Assprite:RegisterClass("Features.Assprite.Tools.Bucket", Bucket, {"Features.Assprite.Tool"})
Bucket:__RegisterInputAction({Keys = {"f"}})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Bucket:OnUseStarted(context)
    local img = context.Image
    local pixelsToReplace = {} ---@type table<integer, set<integer>> Maps row to used columns.
    local pixelQueue = {context.CursorPos} ---@type vec2[]
    local backgroundColor = img:GetPixel(context.CursorPos)
    local newColor = context.Color

    -- Queue-based flood fill
    while pixelQueue[1] do
        local pos = table.remove(pixelQueue)

        -- Track covered pixels
        if not pixelsToReplace[pos[1]] then
            pixelsToReplace[pos[1]] = {}
        end
        pixelsToReplace[pos[1]][pos[2]] = true
        img:SetPixel(pos, newColor)

        -- Cardinal adjacent pixels.
        local neighbours = {
            {pos[1] - 1, pos[2]},
            {pos[1] + 1, pos[2]},
            {pos[1], pos[2] - 1},
            {pos[1], pos[2] + 1},
        }
        for _,neighPos in ipairs(neighbours) do
            local i, j = neighPos[1], neighPos[2]
            if i >= 1 and j >= 1 and i <= img.Height and j <= img.Width then
                -- Queue neighbour
                local neighPixel = img:GetPixel(neighPos)
                if (not pixelsToReplace[i] or not pixelsToReplace[i][j]) and self:_AreColorsSimilar(backgroundColor, neighPixel) then
                    table.insert(pixelQueue, neighPos)
                end
            end
        end
    end

    return true
end

---@override
function Bucket:GetSettings()
    return {
        Assprite.Settings.Color,
    }
end

---Returns whether 2 colors are similar enough to each other for the fill tool to cover them.
---@param color1 RGBColor
---@param color2 RGBColor
function Bucket:_AreColorsSimilar(color1, color2)
    local r1, g1, b1 = color1:Unpack()
    local r2, g2, b2 = color2:Unpack()
    local diff = math.abs(r1 - r2) + math.abs(g1 - g2) + math.abs(b1 - b2)
    return diff <= self.SIMILARITY_THRESHOLD
end
