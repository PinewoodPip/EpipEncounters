
---------------------------------------------
-- Color randomizer tool.
---------------------------------------------

local ICONS = Epip.GetFeature("Feature_GenericUITextures").ICONS
local CommonStrings = Text.CommonStrings
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.Noise : Features.Assprite.Tool
local Noise = {
    ICON = ICONS.EQUIPMENT_SLOTS.WEAPON, -- TODO
    Name = Assprite:RegisterTranslatedString({
        Handle = "hc50b3d14g0d12g482bga339g7a1a51b76e09",
        Text = "AI Degenerate",
        ContextDescription = [[Noise tool name]],
    }),
}
Assprite:RegisterClass("Features.Assprite.Tools.Noise", Noise, {"Features.Assprite.Tool"})
Noise:__RegisterInputAction({Keys = {"d"}})

---------------------------------------------
-- SETTINGS
---------------------------------------------

local Settings = {
    AreaOfEffectSize = Assprite:RegisterSetting(Noise:GetClassName() ..  ".AreaOfEffectSize", {
        Type = "ClampedNumber",
        Name = CommonStrings.AreaOfEffect,
        Min = 3,
        Max = 15,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 3,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    Entropy = Assprite:RegisterSetting(Noise:GetClassName() ..  ".Entropy", {
        Type = "ClampedNumber",
        Name = CommonStrings.Entropy,
        Min = 5,
        Max = 100,
        Step = 5,
        HideNumbers = false,
        DefaultValue = 25,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Noise:OnUseStarted(context)
    self:_Apply(context)
    return true
end

---Randomizes color of pixels near the cursor.
---@param context Features.Assprite.Context
function Noise:_Apply(context)
    local area = self:GetArea()
    local cursorPos = context.CursorPos
    local entropy = Settings.Entropy:GetValue()
    local img = context.Image

    -- Randomize color values within the area.
    for _,relativePos in ipairs(area) do
        local pos = {cursorPos[1] + relativePos[1], cursorPos[2] + relativePos[2]}
        if pos[1] < 1 or pos[1] > img.Height or pos[2] < 1 or pos[2] > img.Width then -- Skip out of bounds pixels.
            goto continue
        end

        -- Randomize pixel color components relative to current
        local pixel = img:GetPixel(pos)
        local newR = self:_RandomizeComponent(pixel.Red, entropy)
        local newG = self:_RandomizeComponent(pixel.Green, entropy)
        local newB = self:_RandomizeComponent(pixel.Blue, entropy)

        -- Set new color
        local newColor = Color.CreateFromRGB(newR, newG, newB)
        img:SetPixel(pos, newColor)

        ::continue::
    end
end

---@override
function Noise:OnCursorChanged(context)
    if context.CursorPos then
        self:_Apply(context)
    end
    return context.CursorPos ~= nil
end


---@override
function Noise:GetSettings()
    return {
        Settings.AreaOfEffectSize,
        Settings.Entropy,
    }
end

---Returns a map of the relative coordinates the tool covers based on the size setting.
---@return vec2[] -- List of coordinates relative to cursor position.
function Noise:GetArea()
    local area = {} ---@type vec2[]
    local size = Settings.AreaOfEffectSize:GetValue() - 1 -- Interpret size as pixel radius ignoring center pixel.
    for i=-size,size,1 do
        for j=-size,size,1 do
            if math.sqrt(i ^ 2 + j ^ 2) <= size then -- Circular radius check.
                table.insert(area, {i, j})
            end
        end
    end
    return area
end

---Applies entropy to a color component.
---@param value integer
---@param entropy integer
---@return integer
function Noise:_RandomizeComponent(value, entropy)
    return math.clamp(value + math.random(-entropy // 2, entropy // 2), 0, 255) -- Integer division is not the best choice but oh well
end
