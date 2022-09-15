
local OptionsSettings = Client.UI.OptionsSettings
local Camera = Client.Camera

---@class Feature_CameraZoom : Feature
local CameraZoom = {
    POSITIONS = {}, ---@type table<string, Feature_CameraZoom_CameraPosition>
    POSITIONS_REGISTRATION_ORDER = {} ---@type string[]
}
Epip.RegisterFeature("CameraZoom", CameraZoom)

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
            Type = "Slider",
            Label = Text.Format("Angle Value %s", {FormatArgs = {i}}),
            Tooltip = "",
            DefaultValue = value,
            MinAmount = self.SLIDER_MIN,
            MaxAmount = self.SLIDER_MAX,
            Interval = self.SLIDER_INTERVAL,
            HideNumbers = false,
            Mod = "EpipEncounters",
        })
    end

    for i,value in ipairs(self.DefaultPositionZoomedOut) do
        table.insert(zoomedOutSliders, {
            ID = self:GetSettingID("ZoomedOut", i),
            Type = "Slider",
            Label = Text.Format("Angle Value %s", {FormatArgs = {i}}),
            Tooltip = "",
            DefaultValue = value,
            MinAmount = self.SLIDER_MIN,
            MaxAmount = self.SLIDER_MAX,
            Interval = self.SLIDER_INTERVAL,
            HideNumbers = false,
            Mod = "EpipEncounters",
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
    return OptionsSettings.GetOptionValue("EpipEncounters", id)
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
end

function CameraZoom.LoadSettings()
    local switches = Client.Camera.GetGlobalSwitches()

    switches.MaxCameraDistance = CameraZoom.GetSetting("Camera_NormalModeZoomLimit")
    switches.MaxCameraDistanceOverhead = CameraZoom.GetSetting("Camera_OverheadModeZoomLimit")
    switches.MaxCameraDistanceController = CameraZoom.GetSetting("Camera_ControllerModeZoomLimit")
    switches.MaxCameraDistanceWithTarget = CameraZoom.GetSetting("Camera_TargetModeZoomLimit")
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
OptionsSettings:RegisterListener("ElementRenderRequest", function(_, data, _)
    if data.ID == "Camera_Positions_Reset" then
        for _,switchID in ipairs(CameraZoom.POSITIONS_REGISTRATION_ORDER) do
            local position = CameraZoom.GetPosition(switchID)
            local zoomedInSliders, zoomedOutSliders = position:GetSliderDefinitions()

            OptionsSettings.RenderOption({
                ID = Text.GenerateGUID(),
                Type = "Header",
                Mod = "EpipEncounters",
                Label = Text.Format(position.Name, {Color = Color.LARIAN.LIGHT_BLUE, Size = 21}),
            })

            OptionsSettings.RenderOption({
                ID = Text.GenerateGUID(),
                Type = "Header",
                Mod = "EpipEncounters",
                Label = Text.Format("Zoomed In Angle", {Color = Color.WHITE, Size = 19})
            })

            for i,slider in ipairs(table.join(zoomedInSliders, zoomedOutSliders)) do
                if i == 4 then
                    OptionsSettings.RenderOption({
                        ID = Text.GenerateGUID(),
                        Type = "Header",
                        Mod = "EpipEncounters",
                        Label = Text.Format("Zoomed Out Angle", {Color = Color.WHITE, Size = 19})
                    })
                end

                OptionsSettings.RenderOption(slider)
            end
        end
    end
end)

-- Refresh variables when settings are changed.
OptionsSettings:RegisterListener("ChangeApplied", function(_, _)
    CameraZoom.LoadSettings()
end)

-- Refresh variables upon loading in.
function CameraZoom:__Setup()
    CameraZoom.LoadSettings()
end

-- Listen for resetting settings to default from UI.
Client.UI.OptionsSettings:RegisterListener("ButtonClicked", function(element)
    if element.ID == "Camera_Positions_Reset" then
        CameraZoom:DebugLog("Resetting position settings")
        
        for _,position in ipairs(CameraZoom.GetPositions()) do
            for i=1,3,1 do
                OptionsSettings.SetOptionValue("EpipEncounters_Camera", position:GetSettingID("ZoomedIn", i), position.DefaultPositionZoomedIn[i])
                OptionsSettings.SetOptionValue("EpipEncounters_Camera", position:GetSettingID("ZoomedOut", i), position.DefaultPositionZoomedOut[i])
            end
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register camera positions.
local switches = Client.Camera.GetGlobalSwitches()
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
for _,position in ipairs(positions) do
    CameraZoom.RegisterPosition(position)
end

-- Register settings tab.
OptionsSettings.RegisterMod("EpipEncounters_Camera", {
    TabHeader = Text.Format("Camera", {Color = "7e72d6", Size = 23}),
    SideButtonLabel = "Camera",
})
local cameraSettings = {
    {
        ID = "Camer_Header",
        Type = "Header",
        Label = Text.Format("General", {Color = "7E72D6", Size = 23})
    },
    {
        ID = "Camera_NormalModeZoomLimit",
        Type = "Slider",
        Label = "Maximum Distance",
        Tooltip = "Controls the maximum distance the camera can zoom out in regular gameplay.<br>Default is 19.",
        DefaultValue = 19,
        MinAmount = 10,
        MaxAmount = 40,
        Interval = 0.5,
        HideNumbers = false,
    },
    {
        ID = "Camera_OverheadModeZoomLimit",
        Type = "Slider",
        Label = "Maximum Distance (tactical view)",
        Tooltip = "Controls the maximum distance the camera can zoom out in tactical view mode.<br>Default is 25.",
        DefaultValue = 25,
        MinAmount = 10,
        MaxAmount = 40,
        Interval = 0.5,
        HideNumbers = false,
    },
    {
        ID = "Camera_ControllerModeZoomLimit",
        Type = "Slider",
        Label = "Maximum Distance (controller mode)",
        Tooltip = "Controls the maximum distance the camera can zoom out in controller mode.<br>Default is 13.",
        DefaultValue = 13,
        MinAmount = 10,
        MaxAmount = 40,
        Interval = 0.5,
        HideNumbers = false,
    },
    {
        ID = "Camera_TargetModeZoomLimit",
        Type = "Slider",
        Label = "Maximum Distance (locked-on)",
        Tooltip = "Controls the maximum distance the camera can zoom out while it is tracking an entity.<br>Default is 17.",
        DefaultValue = 17,
        MinAmount = 10,
        MaxAmount = 40,
        Interval = 0.5,
        HideNumbers = false,
    },
    {
        ID = "Camera_FieldOfView",
        Type = "Slider",
        Label = "Field of View",
        Tooltip = "Controls the FOV of the camera. Low/high values may cause issues with dynamic shadows.<br>Default is 45.",
        DefaultValue = 45,
        MinAmount = 20,
        MaxAmount = 90,
        Interval = 1,
        HideNumbers = false,
    },
    {
        ID = "Camera_SubHeader_Positions",
        Type = "Header",
        Label = Text.Format("Camera Angles", {Color = "7E72D6", Size = 22})
    },
    {
        ID = "Camera_Positions_Reset",
        Type = "Button",
        Label = "Reset to defaults",
        Tooltip = "Restores the angle settings to default values.",
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
    OptionsSettings.RegisterOption("EpipEncounters_Camera", setting)
end