
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
Brush:__RegisterInputAction({Keys = {"b"}})

---@alias Features.Assprite.Tools.Brush.Shape "Square"|"Round"

---------------------------------------------
-- SETTINGS
---------------------------------------------

local Settings = {
    Shape = Assprite:RegisterSetting(Brush:GetClassName() .. ".Shape", {
        Type = "Choice",
        NameHandle = Text.CommonStrings.Shape,
        DefaultValue = "Square", ---@type Features.Assprite.Tools.Brush.Shape
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = Brush.SHAPES.SQUARE, NameHandle = Text.CommonStrings.Shapes.Square.Handle},
            {ID = Brush.SHAPES.ROUND, NameHandle = Text.CommonStrings.Shapes.Round.Handle},
        }
    }),
    Size = Assprite:RegisterSetting(Brush:GetClassName() .. ".Size", {
        Type = "ClampedNumber",
        Name = Text.CommonStrings.Size,
        Min = 1,
        Max = 10,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 1,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    Opacity = Assprite:RegisterSetting(Brush:GetClassName() .. ".Opacity", {
        Type = "ClampedNumber",
        Name = Assprite:RegisterTranslatedString({
            Handle = "hc41596f1gfb56g4814g9b96g50df2a31238a",
            Text = [[Grip]],
            ContextDescription = [[Setting name for brush opacity]],
        }),
        Min = 0.05,
        Max = 1,
        Step = 0.05,
        HideNumbers = false,
        DefaultValue = 1,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
}
Brush.Settings = Settings

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
    local opacity = Settings.Opacity:GetValue()
    local cursorPos = context.CursorPos
    local selectedColor = context.Color
    local img = context.Image
    for _,relativePos in ipairs(area) do -- TODO implement color equality check? for detecting no-ops
        local pos = {cursorPos[1] + relativePos[1], cursorPos[2] + relativePos[2]}
        if pos[1] >= 1 and pos[1] <= img.Height and pos[2] >= 1 and pos[2] <= img.Width then
            local pixel = img:GetPixel(pos)
            local newColor
            if opacity < 1 then
                -- Blend color based on brush opacity
                newColor = Color.Create(
                    math.floor(selectedColor.Red * opacity + pixel.Red * (1 - opacity)),
                    math.floor(selectedColor.Green * opacity + pixel.Green * (1 - opacity)),
                    math.floor(selectedColor.Blue * opacity + pixel.Blue * (1 - opacity))
                )
            else
                -- Fast-path for fully replacing the color
                newColor = selectedColor
            end
            img:SetPixel(pos, newColor)
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

---@override
function Brush:GetSettings()
    return {
        Assprite.Settings.Color,
        Settings.Shape,
        Settings.Size,
        Settings.Opacity,
    }
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
                if math.sqrt(i ^ 2 + j ^ 2) <= size then -- Circular radius check.
                    table.insert(area, {i, j})
                end
            end
        end
    end
    return area
end
