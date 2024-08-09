
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
    EVENTID_TICK_PRESERVE_POSITION = "Features.CameraControls.PreservePositionInDialogues",

    _CachedLeftRotationKeybinds = nil, ---@type InputLib_InputEventBinding[]?
    _CachedRightRotationKeybinds = nil, ---@type InputLib_InputEventBinding[]?

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
        Setting_KeybindRotationRate_Name = {
            Handle = "hb0debfabg884fg4dd2gb69cgd0c6aff725ab",
            Text = "Keybind Rotation Speed",
            ContextDescription = [[Setting name]],
        },
        Setting_KeybindRotationRate_Description = {
            Handle = "h40f15b62g4243g45abgb642g1ae9df4dc9ff",
            Text = "Controls the rotation speed of the camera while using the corresponding keybinds.<br>Default is 1.",
            ContextDescription = [[Tooltip for "Keybind Rotation Rate"]],
        },
        Setting_PreservePositionInDialogues_Name = {
            Handle = "h4a3eccd2g468ag4ff9g8f3dg561219508669",
            Text = "Preserve position in dialogues",
            ContextDescription = [[Setting name]],
        },
        Setting_PreservePositionInDialogues_Description = {
            Handle = "h31a7cef1gf8d7g4565gad91g0e02b9e8ab04",
            Text = "If enabled, the camera will no longer center on the character(s) being spoken to in dialogues.",
            ContextDescription = [[Setting tooltip for "Preserve position in dialogues"]],
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
CameraControls.Settings.KeybindRotationRate = CameraControls:RegisterSetting("KeybindRotationRate", {
    Type = "ClampedNumber",
    Name = TSK.Setting_KeybindRotationRate_Name,
    Description = TSK.Setting_KeybindRotationRate_Description,
    Min = 1,
    Max = 5,
    Step = 0.1,
    HideNumbers = false,
    DefaultValue = 1,
})
CameraControls.Settings.PreservePositionInDialogue = CameraControls:RegisterSetting("PreservePositionInDialogue", {
    Type = "Boolean",
    Name = TSK.Setting_PreservePositionInDialogues_Name,
    Description = TSK.Setting_PreservePositionInDialogues_Description,
    DefaultValue = false,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update camera pitch when moving the mouse with the Input Action active.
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

            -- Add a minimum amount of camera rotation to force the camera to update,
            -- fixing "stuttering" when changing the pitch by large increments.
            local camera = Camera.GetPlayerCamera() 
            if GetExtType(camera) == "ecl::GameCamera" then
                ---@cast camera EclGameCamera
                local EPSILON = 0.001
                if math.abs(camera.InputRotationRateMode1) < EPSILON then
                    camera.InputRotationRateMode1 = EPSILON
                end
            end
        end
    end
end)

-- Modify camera rotation speed when using the vanilla keybinds.
GameState.Events.RunningTick:Subscribe(function (_)
    -- Cache keybinds - TODO update these if rebound mid-session
    if not CameraControls._CachedLeftRotationKeybinds or not CameraControls._CachedRightRotationKeybinds then
        CameraControls._CachedLeftRotationKeybinds = {
            Input.GetBinding("CameraRotateLeft", "Key", 1, nil),
            Input.GetBinding("CameraRotateLeft", "Key", 2, nil),
            Input.GetBinding("CameraRotateLeft", "Mouse", 1, nil), -- Also check mouse binds for scenarios like binding to M4 & M5.
            Input.GetBinding("CameraRotateLeft", "Mouse", 2, nil),
        }
        CameraControls._CachedRightRotationKeybinds = {
            Input.GetBinding("CameraRotateRight", "Key", 1, nil),
            Input.GetBinding("CameraRotateRight", "Key", 2, nil),
            Input.GetBinding("CameraRotateRight", "Mouse", 1, nil), -- See note above.
            Input.GetBinding("CameraRotateRight", "Mouse", 2, nil),
        }
    end
    -- Determine rotation direction (if the user is currently rotating the camera)
    local rotationDirection = nil ---@type (1|-1)?
    for _,binding in pairs(CameraControls._CachedLeftRotationKeybinds) do
        if Input.HasInputEventModifiersPressed(binding) and Input.IsKeyPressed(binding.InputID) then
            rotationDirection = -1
            break
        end
    end
    if not rotationDirection then
        for _,binding in pairs(CameraControls._CachedRightRotationKeybinds) do
            if Input.HasInputEventModifiersPressed(binding) and Input.IsKeyPressed(binding.InputID) then
                rotationDirection = 1
                break
            end
        end
    end
    -- Adjust rotation speed
    if rotationDirection then
        local camera = Camera.GetPlayerCamera()
        if camera and GetExtType(camera) == "ecl::GameCamera" then
            ---@cast camera EclGameCamera
            camera.InputRotationRate = rotationDirection * CameraControls.Settings.KeybindRotationRate:GetValue()
        end
    end
end, {EnabledFunctor = function ()
    -- Only run the listener if the rotation rate would be different from the vanilla one.
    return CameraControls.Settings.KeybindRotationRate:GetValue() ~= 1
end})

-- Prevent the camera from moving to the dialogue target(s).
Client.Events.InDialogueStateChanged:Subscribe(function (ev)
    if ev.InDialogue then
        local camera = Camera.GetPlayerCamera()
        if GetExtType(camera) == "ecl::GameCamera" then
            ---@cast camera EclGameCamera
            local previousLookAt = camera.TargetLookAt
            GameState.Events.RunningTick:Subscribe(function (_)
                camera = Camera.GetPlayerCamera()
                if GetExtType(camera) == "ecl::GameCamera" then -- There's dialogue in the game that can occur during cutscenes that use a different camera.
                    ---@cast camera EclGameCamera
                    camera.TargetLookAt = previousLookAt
                    -- Dummy-out all LookAt targets; necessary to avoid stuttering from the game trying to move the camera back
                    for i,_ in ipairs(camera.Targets) do
                        camera.Targets[i] = Ext.Entity.NullHandle()
                    end
                end
                if not Client.IsInDialogue() then
                    GameState.Events.RunningTick:Unsubscribe(CameraControls.EVENTID_TICK_PRESERVE_POSITION)
                end
            end, {StringID = CameraControls.EVENTID_TICK_PRESERVE_POSITION})
        end
    end
end, {EnabledFunctor = function ()
    return CameraControls.Settings.PreservePositionInDialogue:GetValue() == true
end})

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register settings and keybinds onto the Camera setting tab.
-- TODO extract this settings menu registration to someplace shared
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local CameraZoom = Epip.GetFeature("Feature_CameraZoom")
local tab = SettingsMenu.GetTab(CameraZoom.SETTINGS_MODULE_ID)
local adjustPitchSetting = Input.GetActionBindingSetting(CameraControls.InputActions.AdjustPitch)

table.insert(tab.Entries, 11, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.PreservePositionInDialogue:GetID()})
table.insert(tab.Entries, 12, {Type = "Setting", Module = adjustPitchSetting.ModTable, ID = adjustPitchSetting:GetID()})
table.insert(tab.Entries, 13, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.Sensitivity:GetID()})
table.insert(tab.Entries, 14, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.InvertControls:GetID()})
table.insert(tab.Entries, 15, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.LimitPitch:GetID()})
table.insert(tab.Entries, 16, {Type = "Setting", Module = CameraControls:GetNamespace(), ID = CameraControls.Settings.KeybindRotationRate:GetID()})
