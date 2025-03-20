
---------------------------------------------
-- Convolution-based blur tool.
---------------------------------------------

local ICONS = Epip.GetFeature("Feature_GenericUITextures").ICONS
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.Blur : Features.Assprite.Tool
local Blur = {
    ICON = ICONS.EQUIPMENT_SLOTS.WEAPON, -- TODO
    Name = Assprite:RegisterTranslatedString({
        Handle = "h39945451gc551g4ac3ga12ag411c08214331",
        Text = [[AI Regenerate]],
        ContextDescription = [[Name for blur tool]],
    }),
}
Assprite:RegisterClass("Features.Assprite.Tools.Blur", Blur, {"Features.Assprite.Tool"})
Blur:__RegisterInputAction({Keys = {"a"}})

local TSK = {
    Setting_KernelSize_Name = Assprite:RegisterTranslatedString({
        Handle = "hd2856fecgfe75g4187g974dgce318fa7c19b",
        Text = [[Brain Size]],
        ContextDescription = [[Kernel size setting name for blur tool]],
    }),
}

---------------------------------------------
-- SETTINGS
---------------------------------------------

local Settings = {
    AreaOfEffectSize = Assprite:RegisterSetting(Blur:GetClassName() ..  ".AreaOfEffectSize", {
        Type = "ClampedNumber",
        Name = Text.CommonStrings.AreaOfEffect,
        Min = 3,
        Max = 15,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 3,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    KernelSize = Assprite:RegisterSetting(Blur:GetClassName() ..  ".KernelSize", {
        Type = "ClampedNumber",
        Name = TSK.Setting_KernelSize_Name,
        Min = 1, -- Corresponds to a 3x3 kernel.
        Max = 16,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 3,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
}
Blur.Settings = Settings

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Blur:OnUseStarted(context)
    self:_Apply(context)
    return true
end

---Blurs pixel colors near cursor.
---@param context Features.Assprite.Context
function Blur:_Apply(context)
    local area = self:GetArea()
    local cursorPos = context.CursorPos
    local kernelSize = Settings.KernelSize:GetValue()
    local img = context.Image

    -- Apply a blur kernel to all pixels in the area.
    for _,relativePos in ipairs(area) do
        local pos = {cursorPos[1] + relativePos[1], cursorPos[2] + relativePos[2]}
        if pos[1] < 1 or pos[1] > img.Height or pos[2] < 1 or pos[2] > img.Width then -- Skip out of bounds pixels.
            goto continue
        end

        -- Determine convolution bounds; clamp near edges (dubious choice but oh well)
        local convolutionStart, convolutionEnd = {math.max(pos[1] - kernelSize, 1), math.max(pos[2] - kernelSize, 1)}, {math.min(pos[1] + kernelSize, img.Height), math.min(pos[2] + kernelSize, img.Width)}

        -- Sum weighted color values
        local r, g, b = 0, 0, 0
        local totalWeight = 0
        for i=convolutionStart[1],convolutionEnd[1],1 do
            for j=convolutionStart[2],convolutionEnd[2],1 do
                local pixel = img:GetPixel({i, j})
                r = r + pixel.Red
                g = g + pixel.Green
                b = b + pixel.Blue
                totalWeight = totalWeight + 1
            end
        end

        -- Set new convolved color
        local newColor = Color.CreateFromRGB(r / totalWeight, g / totalWeight, b / totalWeight) -- Constructor already floors these.
        img:SetPixel(pos, newColor)

        ::continue::
    end
end

---@override
function Blur:OnCursorChanged(context)
    if context.CursorPos then
        self:_Apply(context)
    end
    return context.CursorPos ~= nil
end

---@override
function Blur:GetSettings()
    return {
        Assprite.Settings.Color,
        Settings.AreaOfEffectSize,
        Settings.KernelSize,
    }
end

---Returns a map of the relative coordinates the tool covers based on the size setting.
---@return vec2[] -- List of coordinates relative to cursor position.
function Blur:GetArea()
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
