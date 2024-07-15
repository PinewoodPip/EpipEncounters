
local Camera = Client.Camera
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")

---@class Feature_CameraZoom : Feature
local CameraZoom = {
    POSITIONS = {}, ---@type table<string, Feature_CameraZoom_CameraPosition>
    POSITIONS_REGISTRATION_ORDER = {}, ---@type string[]

    SETTINGS_MODULE_ID = "Feature_CameraZoom",

    EVENTID_TICK_PRESERVE_DIALOGUE_ZOOM = "Features.CameraZoom.PreserveZoomInDialogue",

    TranslatedStrings = {
        ["h54d9066eg87bdg439fg92f9g7027970af6ca"] = {
            Text = "Camera",
            ContextDescription = "Settings tab name",
            LocalKey = "SettingsTabName",
        },
        ["h804e5cefgef0eg4351gb19cge60e92ca4297"] = {
            Text = "General",
            ContextDescription = "Top header of settings menu",
        },
        ["haa0297d1ga978g4be1gb3b4g7295b9451b31"] = {
            Text = "Maximum Distance",
        },
        ["h8403161cgb78fg453fg9676gd4c14f3afd29"] = {
            Text = "Controls the maximum distance the camera can zoom out in regular gameplay.<br>Default is 19.",
            ContextDescription = "Tooltip for max distance setting"
        },
        ["h1ec057edg09a1g413dgaefdgaf7942d579ce"] = {
            Text = "Maximum Distance (tactical view)",
        },
        Setting_MinimumDistance_Name = {
            Handle = "h626d2da2g381eg4536g9bd0g56dd32edbe3e",
            Text = "Minimum Distance",
            ContextDescription = [[Setting name]],
        },
        Setting_MinimumDistance_Description = {
            Handle = "hb0379c8bg24bfg4755ga9b3geb29817de37b",
            Text = "Controls the minimum distance the camera can zoom in during regular gameplay.<br>Default is 5.5.",
            ContextDescription = [[Setting tooltip for "Minimum Distance"]],
        },
        Setting_ControllerMinimumDistance_Name = {
            Handle = "h039c29fag6078g4ff6ga239g9fcb8eb798d1",
            Text = "Minimum Distance (controller mode)",
            ContextDescription = [[Setting name]],
        },
        Setting_ControllerMinimumDistance_Description = {
            Handle = "he80877b1g380eg4e61g8a4ag66d806352679",
            Text = "Controls the minimum distance the camera can zoom in while using a controller.<br>Default is 5.5.",
            ContextDescription = [[Setting tooltip for "Minimum Distance (controller mode)"]],
        },
        Setting_OverheadMinimumDistance_Name = {
            Handle = "h3a28ae91ge8e5g4b54g9542g0d4cd0671198",
            Text = "Minimum Distance (tactical view)",
            ContextDescription = [[Setting name]],
        },
        Setting_OverheadMinimumDistance_Description = {
            Handle = "hb5f81ce7g26cfg4e30gb9ddg1ccf51f78fcd",
            Text = "Controls the minimum distance the camera can zoom in while using the tactical view.<br>Default is 6.",
            ContextDescription = [[]],
        },
        Setting_TargetMinimumDistance_Name = {
            Handle = "h042628degf10fg4e96ga61cgb1a0965dc7e4",
            Text = "Minimum Distance (locked-on)",
            ContextDescription = [[Setting name]],
        },
        Setting_TargetMinimumDistance_Description = {
            Handle = "hd804e90bgd821g475eg845bgd5c3e8363394",
            Text = "Controls the minimum distance the camera can zoom in while it is tracking an entity.<br>Default is 17.",
            ContextDescription = [[]],
        },
        ["h22447dfage02dg4c93gbf2agded54810ce36"] = {
            Text = "Controls the maximum distance the camera can zoom out in tactical view mode.<br>Default is 25.",
        },
        ["h3e9e4282gb66cg4498g83e0g8b79a4cec500"] = {
            Text = "Maximum Distance (controller mode)",
        },
        ["h97ac5f1fg0ae8g490dg9050gb5f8fe4025a4"] = {
            Text = "Controls the maximum distance the camera can zoom out in controller mode.<br>Default is 13.",
        },
        ["h6270c4d7g0531g453agbae3g2503fb8c3c59"] = {
            Text = "Maximum Distance (locked-on)",
        },
        ["h3af2fabcg24ffg4e29ga965g69180c641040"] = {
            Text = "Controls the maximum distance the camera can zoom out while it is tracking an entity.<br>Default is 17.",
        },
        ["h265f89a4g9e80g420egb7adgd27aced5697b"] = {
            Text = "Field of View",
        },
        ["hec25a517g9521g47e3g8f74gfa658861a320"] = {
            Text = "Controls the FOV of the camera. Low/high values may cause issues with dynamic shadows.<br>Default is 45.",
        },
        Setting_PreserveZoomInDialogues_Name = {
            Handle = "h0ea53526g269dg479fgbc83gf068477ed6f6",
            Text = "Preserve zoom level in dialogues",
            ContextDescription = [[Setting name]],
        },
        Setting_PreserveZoomInDialogues_Description = {
            Handle = "h8dbeb996g3d15g4ac0ga45fg8118abe7961d",
            Text = "If enabled, the camera zoom will not change during dialogue.",
            ContextDescription = [[Setting tooltip for "Preserve zoom level in dialogues"]],
        },
        ["h3c77115cga69dg4c67g880bgd314b8072f7c"] = {
            Text = "Camera Angles",
        },
        ["h3ddc3759g3f70g4ac5g9401g76ced6258d7a"] = {
            Text = "Reset to defaults",
        },
        ["h24797af2gde0ag48cdgb741gec2049e1c631"] = {
            Text = "Restores the angle settings to default values.",
            ContextDescription = "Tooltip for reset button"
        },
    },
}
Epip.RegisterFeature("CameraZoom", CameraZoom)
local TSK = CameraZoom.TSK
local TSKs = CameraZoom.TranslatedStrings

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_CameraZoom_CameraPosition
---@field DefaultPositionZoomedIn Vector3
---@field DefaultPositionZoomedOut Vector3
---@field Name string
---@field GlobalSwitchID string
local _CameraPosition = {
    SLIDER_MIN = -2,
    SLIDER_MAX = 2,
    SLIDER_INTERVAL = 0.01,
}

---@param zoomLevel "ZoomedIn"|"ZoomedOut"
---@param valueIndex 1|2|3
function _CameraPosition:GetSettingID(zoomLevel, valueIndex)
    return string.format("Camera_Position_%s_%s_%s", self.GlobalSwitchID, zoomLevel, valueIndex)
end

---@return OptionsSettingsSlider[], OptionsSettingsSlider[] Slider definitions for zoomed in, zoomed out positions.
function _CameraPosition:GetSliderDefinitions()
    local zoomedInSliders = {}
    local zoomedOutSliders = {}

    for i,value in ipairs(self.DefaultPositionZoomedIn) do
        table.insert(zoomedInSliders, {
            ID = self:GetSettingID("ZoomedIn", i),
            ModTable = CameraZoom.SETTINGS_MODULE_ID,
            Type = "ClampedNumber",
            Name = Text.Format("Angle Value %s", {FormatArgs = {i}}),
            Description = "",
            Min = self.SLIDER_MIN,
            Max = self.SLIDER_MAX,
            Step = self.SLIDER_INTERVAL,
            HideNumbers = false,
            DefaultValue = value,
        })
    end

    for i,value in ipairs(self.DefaultPositionZoomedOut) do
        table.insert(zoomedOutSliders, {
            ID = self:GetSettingID("ZoomedOut", i),
            ModTable = CameraZoom.SETTINGS_MODULE_ID,
            Type = "ClampedNumber",
            Name = Text.Format("Angle Value %s", {FormatArgs = {i}}),
            Description = "",
            Min = self.SLIDER_MIN,
            Max = self.SLIDER_MAX,
            Step = self.SLIDER_INTERVAL,
            HideNumbers = false,
            DefaultValue = value,
        })
    end

    return zoomedInSliders, zoomedOutSliders
end

---@return Vector3, Vector3 Settings for zoomed in, zoomed out positions.
function _CameraPosition:GetSettings()
    local zoomedIn = {}
    local zoomedOut = {}

    for i=1,3,1 do
        local zoomedInSettingID = string.format("Camera_Position_%s_ZoomedIn_%s", self.GlobalSwitchID, i)
        local zoomedOutSettingID = string.format("Camera_Position_%s_ZoomedOut_%s", self.GlobalSwitchID, i)

        table.insert(zoomedIn, CameraZoom.GetSetting(zoomedInSettingID))
        table.insert(zoomedOut, CameraZoom.GetSetting(zoomedOutSettingID))
    end

    return Vector.Create(table.unpack(zoomedIn)), Vector.Create(table.unpack(zoomedOut))
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return any
function CameraZoom.GetSetting(id)
    return Settings.GetSettingValue(CameraZoom.SETTINGS_MODULE_ID, id)
end

---@param globalSwitchID string
---@return Feature_CameraZoom_CameraPosition
function CameraZoom.GetPosition(globalSwitchID)
    return CameraZoom.POSITIONS[globalSwitchID]
end

---@param data Feature_CameraZoom_CameraPosition
function CameraZoom.RegisterPosition(data)
    Inherit(data, _CameraPosition)

    CameraZoom.POSITIONS[data.GlobalSwitchID] = data
    table.insert(CameraZoom.POSITIONS_REGISTRATION_ORDER, data.GlobalSwitchID)

    -- Register slider settings
    local zoomedIn, zoomedOut = data:GetSliderDefinitions()
    for _,slider in pairs(table.join(zoomedIn, zoomedOut)) do
        Settings.RegisterSetting(slider)
    end
end

function CameraZoom.LoadSettings()
    local switches = Client.Camera.GetGlobalSwitches()

    switches.MinCameraDistance = CameraZoom.GetSetting("NormalModeZoomInLimit")
    switches.MaxCameraDistance = CameraZoom.GetSetting("Camera_NormalModeZoomLimit")

    switches.MaxCameraDistanceOverhead = CameraZoom.GetSetting("Camera_OverheadModeZoomLimit")
    switches.MinCameraDistanceOverhead = CameraZoom.GetSetting("OverheadModeZoomInLimit")

    switches.MaxCameraDistanceController = CameraZoom.GetSetting("Camera_ControllerModeZoomLimit")
    switches.MinCameraDistanceController = CameraZoom.GetSetting("ControllerModeZoomInLimit")

    switches.MaxCameraDistanceWithTarget = CameraZoom.GetSetting("Camera_TargetModeZoomLimit")
    switches.MinCameraDistanceWithTarget = CameraZoom.GetSetting("TargetModeZoomInLimit")

    switches.FOV = CameraZoom.GetSetting("Camera_FieldOfView")
    -- switches.MoveSpeed = CameraZoom.GetSetting("Camera_MoveSpeed") -- Does not appear to work from here - overwritten by game upon leaving the menu.

    -- Apply position overrides.
    for _,globalSwitchID in ipairs(CameraZoom.POSITIONS_REGISTRATION_ORDER) do
        local position = CameraZoom.GetPosition(globalSwitchID)
        local zoomedInPos, zoomedOutPos = position:GetSettings()
        switches[globalSwitchID .. "2"] = zoomedInPos
        switches[globalSwitchID] = zoomedOutPos
    end
end

---@return Feature_CameraZoom_CameraPosition[]
function CameraZoom.GetPositions()
    local positions = {}

    for _,globalSwitchID in ipairs(CameraZoom.POSITIONS_REGISTRATION_ORDER) do
        table.insert(positions, CameraZoom.GetPosition(globalSwitchID))
    end

    return positions
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Render position settings in settings UI.
SettingsMenu.Hooks.GetTabEntries:Subscribe(function (ev)
    if ev.Tab.ID == CameraZoom.SETTINGS_MODULE_ID then
        local entries = table.deepCopy(ev.Tab.Entries)

        for _,switchID in ipairs(CameraZoom.POSITIONS_REGISTRATION_ORDER) do
            local position = CameraZoom.GetPosition(switchID)
            local zoomedInSliders, zoomedOutSliders = position:GetSliderDefinitions()

            -- Add headers
            table.insert(entries, {
                Type = "Label",
                Label = Text.Format(position.Name, {Color = Color.LARIAN.LIGHT_BLUE, Size = 21}),
            })
            table.insert(entries, {
                Type = "Label",
                Label = Text.Format("Zoomed In Angle", {Color = Color.WHITE, Size = 19})
            })

            for i,slider in ipairs(table.join(zoomedInSliders, zoomedOutSliders)) do
                -- Insert label to separate zoom in/out angle.
                if i == 4 then
                    table.insert(entries, {
                        Type = "Label",
                        Label = Text.Format("Zoomed Out Angle", {Color = Color.WHITE, Size = 19}),
                    })
                end

                table.insert(entries, {Type = "Setting", Module = slider.ModTable, ID = slider.ID})
            end
        end

        ev.Entries = entries
    end
end)

-- Refresh variables when settings are changed.
SettingsMenu.Events.ChangesApplied:Subscribe(function (ev)
    if ev.Changes[CameraZoom.SETTINGS_MODULE_ID] ~= nil then
        CameraZoom.LoadSettings()
    end
end)

-- Refresh variables upon loading in.
function CameraZoom:__Setup()
    CameraZoom.LoadSettings()
end

-- Listen for resetting settings to default from UI.
SettingsMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.Tab.ID == CameraZoom.SETTINGS_MODULE_ID and ev.ButtonID == "Feature_CameraZoom_Reset" then
        CameraZoom:DebugLog("Resetting position settings")

        for _,position in ipairs(CameraZoom.GetPositions()) do
            for i=1,3,1 do
                Settings.SetValue(CameraZoom.SETTINGS_MODULE_ID, position:GetSettingID("ZoomedIn", i), position.DefaultPositionZoomedIn[i])
                Settings.SetValue(CameraZoom.SETTINGS_MODULE_ID, position:GetSettingID("ZoomedOut", i), position.DefaultPositionZoomedOut[i])
            end
        end

        Settings.Save(CameraZoom.SETTINGS_MODULE_ID)
        CameraZoom.LoadSettings()
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register camera positions.
local defaultPos = Camera.GetDefaultPosition("Default")
local overheadPos = Camera.GetDefaultPosition("Overhead")
local controllerPos = Camera.GetDefaultPosition("Controller")
local combatPos = Camera.GetDefaultPosition("Combat")

---@type Feature_CameraZoom_CameraPosition[]
local positions = {
    {
        Name = "Regular Camera",
        GlobalSwitchID = "DefaultPosition",
        DefaultPositionZoomedIn = defaultPos.ZoomedIn,
        DefaultPositionZoomedOut = defaultPos.ZoomedOut,
    },
    {
        Name = "Combat Camera",
        GlobalSwitchID = "DefaultCombatPosition",
        DefaultPositionZoomedIn = combatPos.ZoomedIn,
        DefaultPositionZoomedOut = combatPos.ZoomedOut,
    },
    {
        Name = "Tactical Camera",
        GlobalSwitchID = "DefaultOverheadPosition",
        DefaultPositionZoomedIn = overheadPos.ZoomedIn,
        DefaultPositionZoomedOut = overheadPos.ZoomedOut,
    },
    {
        Name = "Controller Camera",
        GlobalSwitchID = "DefaultControllerPosition",
        DefaultPositionZoomedIn = controllerPos.ZoomedIn,
        DefaultPositionZoomedOut = controllerPos.ZoomedOut,
    },
}

-- Register settings.
SettingsMenu.RegisterTab({
    ID = CameraZoom.SETTINGS_MODULE_ID,
    ButtonLabel = Text.CommonStrings.Camera:GetString(),
    HeaderLabel = Text.CommonStrings.Camera:GetString(),
    Entries = { -- Position settings are dynamically generated and appended.
        {Type = "Label", Label = Text.Format(CameraZoom.TSK["h804e5cefgef0eg4351gb19cge60e92ca4297"], {Color = "7E72D6", Size = 23})},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "Camera_NormalModeZoomLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "NormalModeZoomInLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "Camera_OverheadModeZoomLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "OverheadModeZoomInLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "Camera_ControllerModeZoomLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "ControllerModeZoomInLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "Camera_TargetModeZoomLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "TargetModeZoomInLimit"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "PreserveZoomInDialogues"},
        {Type = "Setting", Module = CameraZoom.SETTINGS_MODULE_ID, ID = "Camera_FieldOfView"},
        {Type = "Label", Label = Text.Format(TSK["h3c77115cga69dg4c67g880bgd314b8072f7c"], {Color = "7E72D6", Size = 22})},
        {Type = "Button", Label = TSK["h3ddc3759g3f70g4ac5g9401g76ced6258d7a"], Tooltip = TSK["h24797af2gde0ag48cdgb741gec2049e1c631"], ID = "Feature_CameraZoom_Reset"},
    },
})

-- Register positions.
for _,position in ipairs(positions) do
    CameraZoom.RegisterPosition(position)
end

-- Register general camera settings.
local cameraSettings = {
    {
        ID = "Camera_NormalModeZoomLimit",
        Type = "ClampedNumber",
        Name = CameraZoom.TSK["haa0297d1ga978g4be1gb3b4g7295b9451b31"],
        Description = TSK["h8403161cgb78fg453fg9676gd4c14f3afd29"],
        Min = 10,
        Max = 40,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 19,
    },
    {
        ID = "NormalModeZoomInLimit",
        Type = "ClampedNumber",
        Name = TSKs.Setting_MinimumDistance_Name,
        Description = TSKs.Setting_MinimumDistance_Description,
        Min = 1,
        Max = 5.5,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 5.5,
    },
    {
        ID = "ControllerModeZoomInLimit",
        Type = "ClampedNumber",
        Name = TSKs.Setting_ControllerMinimumDistance_Name,
        Description = TSKs.Setting_ControllerMinimumDistance_Description,
        Min = 1,
        Max = 5.5,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 5.5,
    },
    {
        ID = "OverheadModeZoomInLimit",
        Type = "ClampedNumber",
        Name = TSKs.Setting_OverheadMinimumDistance_Name,
        Description = TSKs.Setting_OverheadMinimumDistance_Description,
        Min = 1,
        Max = 6,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 6,
    },
    {
        ID = "TargetModeZoomInLimit",
        Type = "ClampedNumber",
        Name = TSKs.Setting_TargetMinimumDistance_Name,
        Description = TSKs.Setting_TargetMinimumDistance_Description,
        Min = 1,
        Max = 17,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 17,
    },
    {
        ID = "Camera_OverheadModeZoomLimit",
        Type = "ClampedNumber",
        Name = TSK["h1ec057edg09a1g413dgaefdgaf7942d579ce"],
        Description = TSK["h22447dfage02dg4c93gbf2agded54810ce36"],
        Min = 10,
        Max = 40,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 25,
    },
    {
        ID = "Camera_ControllerModeZoomLimit",
        Type = "ClampedNumber",
        Name = TSK["h3e9e4282gb66cg4498g83e0g8b79a4cec500"],
        Description = TSK["h97ac5f1fg0ae8g490dg9050gb5f8fe4025a4"],
        Min = 10,
        Max = 40,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 13,
    },
    {
        ID = "Camera_TargetModeZoomLimit",
        Type = "ClampedNumber",
        Name = TSK["h6270c4d7g0531g453agbae3g2503fb8c3c59"],
        Description = TSK["h3af2fabcg24ffg4e29ga965g69180c641040"],
        Min = 10,
        Max = 40,
        Step = 0.5,
        HideNumbers = false,
        DefaultValue = 17,
    },
    {
        ID = "Camera_FieldOfView",
        Type = "ClampedNumber",
        Name = TSK["h265f89a4g9e80g420egb7adgd27aced5697b"],
        Description = TSK["hec25a517g9521g47e3g8f74gfa658861a320"],
        Min = 20,
        Max = 90,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 45,
    },
    {
        ID = "PreserveZoomInDialogues",
        Type = "Boolean",
        Name = TSKs.Setting_PreserveZoomInDialogues_Name,
        Description = TSKs.Setting_PreserveZoomInDialogues_Description,
        DefaultValue = false,
    },
    -- {
    --     ID = "Camera_MoveSpeed",
    --     Type = "Slider",
    --     Label = "Panning Speed",
    --     Tooltip = "Controls the panning speed of the camera. Same as the setting in Gameplay settings, but allows finer tuning and a higher maximum.<br>Default is 5.",
    --     DefaultValue = 5,
    --     MinAmount = 1,
    --     MaxAmount = 20,
    --     Interval = 1,
    --     HideNumbers = false,
    -- },
}
for _,setting in ipairs(cameraSettings) do
    setting.ModTable = CameraZoom.SETTINGS_MODULE_ID
    Settings.RegisterSetting(setting)
end

-- Set target distance in dialogue to the distance before entering dialogue.
Client.Events.InDialogueStateChanged:Subscribe(function (ev)
    if ev.InDialogue then
        local dist = Camera.GetTargetDistance()
        GameState.Events.RunningTick:Subscribe(function (_)
            dist = dist or Camera.GetTargetDistance() -- Refetch distance if we couldn't do it at the start.
            local camera = Camera.GetPlayerCamera()
            if GetExtType(camera) == "ecl::GameCamera" then -- There's dialogue in the game that can occur during cutscenes that use a different camera.
                ---@cast camera EclGameCamera
                camera.TargetCameraDistance = dist
            end
            if not Client.IsInDialogue() then
                GameState.Events.RunningTick:Unsubscribe(CameraZoom.EVENTID_TICK_PRESERVE_DIALOGUE_ZOOM)
            end
        end, {StringID = CameraZoom.EVENTID_TICK_PRESERVE_DIALOGUE_ZOOM})
    end
end, {EnabledFunctor = function ()
    return CameraZoom.GetSetting("PreserveZoomInDialogues") == true and not Ext.Utils.GetGlobalSwitches().GameCameraEnableCloseUpDialog -- Allow close-up dialogue to take priority.
end})
