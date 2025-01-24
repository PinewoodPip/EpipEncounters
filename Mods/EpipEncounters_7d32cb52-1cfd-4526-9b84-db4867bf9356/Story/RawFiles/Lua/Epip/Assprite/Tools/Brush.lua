
---------------------------------------------
-- Basic paint brush tool with support for multiple shapes and sizes.
---------------------------------------------

local ICONS = Epip.GetFeature("Feature_GenericUITextures").ICONS
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.Brush : Features.Assprite.Tool
local Brush = {
    ICON = ICONS.EQUIPMENT_SLOTS.WEAPON, -- TODO?
    Name = Assprite:RegisterTranslatedString({
        Handle = "hbb15b2cegfe6eg4861gaf58g32a0b0cc29f1",
        Text = [[Brush]],
        ContextDescription = [[Tool name]],
    }),

    SHAPES = {
        SQUARE = "Square",
        ROUND = "Round",
    },
}
Assprite:RegisterClass("Features.Assprite.Tools.Brush", Brush, {"Features.Assprite.Tool"})

---@alias Features.Assprite.Tools.Brush.Shape "Square"|"Round"

---------------------------------------------
-- SETTINGS
---------------------------------------------

local Settings = {
    Shape = Assprite:RegisterSetting("Tools.Brush.Shape", {
        Type = "Choice",
        NameHandle = Text.CommonStrings.Shape,
        DefaultValue = "Square", ---@type Features.Assprite.Tools.Brush.Shape
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = Brush.SHAPES.SQUARE, NameHandle = Text.CommonStrings.Shapes.Square.Handle},
            {ID = Brush.SHAPES.ROUND, NameHandle = Text.CommonStrings.Shapes.Round.Handle},
        }
    }),
    Size = Assprite:RegisterSetting("Size", {
        Type = "ClampedNumber",
        Name = Text.CommonStrings.Size,
        Min = 1,
        Max = 5,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 1,
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Brush:OnUseStarted(context)
    self:_Apply(context)
    return true
end

---Paints pixels based on selected shape.
---@param context Features.Assprite.Context
function Brush:_Apply(context)
    local shape = Settings.Shape:GetValue()
    local area = self:GetShapeArea(shape)
    local cursorPos = context.CursorPos
    local color = context.Color
    local img = context.Image
    for _,relativePos in ipairs(area) do -- TODO implement color equality check? for detecting no-ops
        local pos = {cursorPos[2] + relativePos[2], cursorPos[1] + relativePos[1]} -- Convert x & y to row & column coordinates.
        if pos[1] >= 1 and pos[1] <= img.Width and pos[2] >= 1 and pos[2] <= img.Height then
            img:SetPixel(pos, color)
        end
    end
end

---@override
function Brush:OnCursorChanged(context)
    if context.CursorPos then
        self:_Apply(context)
    end
    return context.CursorPos ~= nil
end

---Returns a map of the relative coordinates a shape covers.
---@param shape Features.Assprite.Tools.Brush.Shape
---@return vec2[] -- List of coordinates relative to cursor position.
function Brush:GetShapeArea(shape)
    local area = {} ---@type vec2[]
    local size = Settings.Size:GetValue() - 1 -- Interpret size as pixel radius ignoring center pixel.
    if shape == "Square" then
        for i=-size,size,1 do
            for j=-size,size,1 do
                table.insert(area, {i, j})
            end
        end
    elseif shape == "Round" then
        for i=-size,size,1 do
            for j=-size,size,1 do
                if not (math.abs(i) == size and math.abs(j) == -size) then -- Exclude corners.
                    table.insert(area, {i, j})
                end
            end
        end
    end
    return area
end
