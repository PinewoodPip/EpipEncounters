
---------------------------------------------
-- Implements programmable RGB lights for the settings menu.
---------------------------------------------

local SettingsMenu = Epip.GetFeature("Feature_SettingsMenuOverlay")
local UI = SettingsMenu.UI
local T = Texture.RegisterTexture

---@class Features.ProgrammableLights : Feature
local Lights = {
    TEXTURES = {
        WIRING = T("PIP_ProgrammableLights_Wiring", {
            GUID = "0bc7b337-d406-4f80-af10-f506b18edaa5",
        }),
        LIGHTS = {
            LIGHT_1 = {
                RED = T("PIP_ProgrammableLights_Light1_Red", {
                    GUID = "00619903-3eb5-418a-83a3-79376e43afb5",
                }),
                GREEN = T("PIP_ProgrammableLights_Light1_Green", {
                    GUID = "fc1ff50f-6dbe-4d79-8751-a55fe34d0106",
                }),
                BLUE = T("PIP_ProgrammableLights_Light1_Blue", {
                    GUID = "4060f776-e118-4074-8616-abb4cb6a8acd",
                }),
                PURPLE = T("PIP_ProgrammableLights_Light1_Purple", {
                    GUID = "b96efc62-6218-451e-93fd-e9ff7d4d9688",
                }),
                OFF = T("PIP_ProgrammableLights_Light1_Off", {
                    GUID = "29da7f92-e2cd-46bb-8691-8746c957714c",
                }),
            },
        },
    },
    _Lights = {}, ---@type table<string, Features.ProgrammableLights.Light>
    _CurrentProgram = nil, ---@type Features.ProgrammableLights.Program?
    _Initialized = false,
}
Epip.RegisterFeature("Features.ProgrammableLights", Lights)

-- Overlay elements for the settings menu.
local Overlay = {
    UI = UI,
    Root = nil, ---@type GenericUI_Element_Empty
    System = nil, ---@type GenericUI_Element_Empty? The current light system.
}
Lights.Overlay = Overlay

---------------------------------------------
-- CLASSES
---------------------------------------------

---Descriptor for a light.
---@class Features.ProgrammableLights.Light
---@field ID string
---@field OffTexture TextureLib_Texture
---@field StateTextures table<string, TextureLib_Texture>

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a light.
---@param light Features.ProgrammableLights.Light
function Lights.RegisterLight(light)
    Lights._Lights[light.ID] = light
end

---Returns a light by its ID.
---@param id string
---@return Features.ProgrammableLights.Light
function Lights.GetLight(id)
    return Lights._Lights[id]
end

---Runs a program on the light system and shows it.
---@param program Features.ProgrammableLights.Program
function Lights.SetProgram(program)
    if not OOP.ImplementsClass(program, "Features.ProgrammableLights.Program") then
        Lights:__Error("SetProgram", "Programs must implement Features.ProgrammableLights.Program")
    end

    -- Clean up previous program
    if Lights._IsRunning() then
        Lights.Shutdown()
    end

    Lights._CurrentProgram = program

    -- Initialize the new light system
    Overlay.System = Overlay.Root:AddChild("Features.ProgrammableLights.System", "GenericUI_Element_Empty")
    program:Initialize(Overlay.System)

    Overlay.Root:SetVisible(true)
end

---Shuts down and hides the light system.
function Lights.Shutdown()
    Overlay.Root:SetVisible(false)
    local program = Lights._CurrentProgram
    if program then
        program:Shutdown()
        Overlay.System:Destroy()
    end
end

---Returns whether the light system is running a program.
---@return boolean
function Lights._IsRunning()
    return Overlay.Root:IsVisible()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Initialize overlayed elements when a tab is rendered for the first time.
SettingsMenu.Events.TabRendered:Subscribe(function (_)
    if Lights._Initialized then return end

    local root = UI:CreateElement("Features.ProgrammableLights.Root", "GenericUI_Element_Texture")
    root:SetTexture(Lights.TEXTURES.WIRING)
    root:SetPosition(270, 10)
    root:SetMouseEnabled(false)
    root:SetMouseChildren(false)
    root:SetVisible(false)
    Overlay.Root = root

    Lights._Initialized = true
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register built-in lights.
local LIGHT1_TEXTURES = Lights.TEXTURES.LIGHTS.LIGHT_1
---@type Features.ProgrammableLights.Light[]
local lights = {
    {
        ID = "Light1",
        OffTexture = LIGHT1_TEXTURES.OFF,
        StateTextures = {
            ["Red"] = LIGHT1_TEXTURES.RED,
            ["Green"] = LIGHT1_TEXTURES.GREEN,
            ["Blue"] = LIGHT1_TEXTURES.BLUE,
            ["Purple"] = LIGHT1_TEXTURES.PURPLE,
        }
    }
}
for _,light in ipairs(lights) do
    Lights.RegisterLight(light)
end
