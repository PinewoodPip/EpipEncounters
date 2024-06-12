
---------------------------------------------
-- Implements keybinds to control the game camera.
---------------------------------------------

local Input = Client.Input
local Camera = Client.Camera
local V = Vector.Create

---@class Features.CameraControls : Feature
local CameraControls = {
    SENSITIVITY_SCALE_FACTOR = 1 / 400, -- Sensitivty setting is multiplied by this value before being applied. Intended to make the setting value range look more natural within the settings menu.
    REFERENCE_RESOLUTION = 1080, -- Reference vertical resolution (in pixels) for determining the change in pitch per mouse pixel moved.
    MIN_PITCH = 0.1, -- Minimum pitch for when "Limit Pitch" is enabled.

    TranslatedStrings = {
        Setting_Sensitivity_Name = {
            Handle = "h1563a7b9g0998g4e06g82eag75097d9a7b79",
            Text = "Camera Pitch Adjust Sensitivity",
            ContextDescription = "Setting name for sensitivity of the pitch-adjust keybind",
        },
        Setting_Sensitivity_Description = {
            Handle = "h991ec3d1g0162g4b29g8778gc986b7e3be6d",
            Text = [[Determines how rapidly the camera pitch changes as you move the mouse with the "Adjust Camera Pitch" keybind active.]],
            ContextDescription = "Setting tooltip",
        },
        Setting_InvertControls_Name = {
            Handle = "h018412b6gd498g4fc9ga20egbfce71d5a5b8",
            Text = [[Invert "Adjust Camera Pitch" controls]],
            ContextDescription = [[Setting name, related to "Adjust Camera Pitch"]],
        },
        Setting_InvertControls_Description = {
            Handle = "h5484362egdb21g4770g8261g9317f2c365c7",
            Text = [[If enabled, moving the mouse down while the "Adjust Camera Pitch" keybind is active will decrease the pitch instead of increasing it.]],
            ContextDescription = "Setting tooltip",
        },
        Setting_LimitPitch_Name = {
            Handle = "he2feffa4g625dg486fgbcafgd43f6bc7af72",
            Text = "Limit Pitch",
            ContextDescription = [[Setting name; "pitch" refers to camera pitch]],
        },
        Setting_LimitPitch_Description = {
            Handle = "h6902de2eg38f8g4893ga0feged6f278f7ffa",
            Text = [[If enabled, the "Adjust Camera Pitch" keybind will not be able to lower the pitch below a certain threshold, reducing the likelihood of the camera clipping through the ground while using it.]],
            ContextDescription = "Setting tooltip",
        },
        InputAction_AdjustPitch_Name = {
            Handle = "h812ece0eg34adg44eag8c8bg50030a7e66d0",
            Text = "Adjust Camera Pitch",
            ContextDescription = "Keybind name",
        },
        InputAction_AdjustPitch_Description = {
            Handle = "hfbdd1288g3c74g4d2cgb072gceee4bf1f9a0",
            Text = "While held, vertical mouse movement will adjust the pitch (vertical angle) of the game camera.<br><br>Does not affect your default camera angle settings and any changes to the angle from the keybind will not persist across sessions.",
            ContextDescription = "Keybind tooltip",
        },
    },
    Settings = {},
    InputActions = {},
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.RegisterFeature("Features.CameraControls", CameraControls)
local TSK = CameraControls.TranslatedStrings

---------------------------------------------
-- RESOURCES
---------------------------------------------

CameraControls.InputActions.AdjustPitch = CameraControls:RegisterInputAction("AdjustPitch", {
    Name = TSK.InputAction_AdjustPitch_Name,
    Description = TSK.InputAction_AdjustPitch_Description,
})
CameraControls.Settings.Sensitivity = CameraControls:RegisterSetting("Sensitivity", {
    Type = "ClampedNumber",
    Name = TSK.Setting_Sensitivity_Name,
    Description = TSK.Setting_Sensitivity_Description,
    Min = 0.01,
    Max = 2,
    Step = 0.01,
    HideNumbers = false,
    DefaultValue = 1,
})
CameraControls.Settings.InvertControls = CameraControls:RegisterSetting("InvertControls", {
    Type = "Boolean",
    Name = TSK.Setting_InvertControls_Name,
    Description = TSK.Setting_InvertControls_Description,
    DefaultValue = false,
})
CameraControls.Settings.LimitPitch = CameraControls:RegisterSetting("LimitPitch", {
    Type = "Boolean",
    NameHandle = TSK.Setting_LimitPitch_Name,
    DescriptionHandle = TSK.Setting_LimitPitch_Description,
    DefaultValue = true,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Input.Events.MouseMoved:Subscribe(function (ev)
    if Input.GetCurrentAction() == CameraControls.InputActions.AdjustPitch then
        local positionMode = Camera.GetCurrentPositionMode()
        if positionMode then
            local pos1, pos2 = Camera.GetPositionSwitches(nil, positionMode)
            local delta = Vector.ScalarProduct(V(0, ev.Vector[2], 0), CameraControls.Settings.Sensitivity:GetValue() * CameraControls.SENSITIVITY_SCALE_FACTOR) -- The setting's value is rescaled. See comment on the constant.
            local viewportHeight = Client.GetViewportSize()[2]

            -- Normalize pitch change based on vertical resolution
            delta = Vector.ScalarProduct(delta, CameraControls.REFERENCE_RESOLUTION / viewportHeight)

            -- Invert the pitch change if the setting is enabled.
            if CameraControls.Settings.InvertControls:GetValue() then
                delta = Vector.ScalarProduct(delta, -1)
            end

            pos1 = pos1 + delta
            pos2 = pos2 + delta

            -- Prevent the pitch from going below a configurable value.
            if CameraControls.Settings.LimitPitch:GetValue() == true then
                pos1[2] = math.max(pos1[2], CameraControls.MIN_PITCH)
                pos2[2] = math.max(pos2[2], CameraControls.MIN_PITCH)
            end

            Camera.SetPositionSwitches(nil, positionMode, pos1, pos2)
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register settings and keybinds onto the Camera setting tab.
-- TODO extract this settings menu registration to someplace shared
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local CameraZoom = Epip.GetFeature("Feature_CameraZoom")
local tab = SettingsMenu.GetTab(CameraZoom.SETTINGS_MODULE_ID)
local adjustPitchSetting = Input.GetActionBindingSetting(CameraControls.InputActions.AdjustPitch)

table.insert(tab.Entries, 7, {Type = "Setting", Module = adjustPitchSetting.ModTable, ID = adjustPitchSetting:GetID()})
table.insert(tab.Entries, 8, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.Sensitivity:GetID()})
table.insert(tab.Entries, 9, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.InvertControls:GetID()})
table.insert(tab.Entries, 10, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.LimitPitch:GetID()})
