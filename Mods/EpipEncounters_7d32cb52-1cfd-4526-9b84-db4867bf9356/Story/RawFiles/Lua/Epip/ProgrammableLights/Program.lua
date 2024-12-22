
---------------------------------------------
-- Interface for a program that defines and drives lights.
---------------------------------------------

local Lights = Epip.GetFeature("Features.ProgrammableLights") ---@class Features.ProgrammableLights

---@class Features.ProgrammableLights.Program
local Program = {}
Lights:RegisterClass("Features.ProgrammableLights.Program", Program)

---------------------------------------------
-- METHODS
---------------------------------------------

---Called when the program is mounted onto the light system.
---Lights and other elements should be created here, alongside with any listeners needed for the program's update loop.
---@abstract
---@param root GenericUI_Element Container where elements should be created.
---@diagnostic disable-next-line: unused-local
function Program:Initialize(root) end

---Thrown when the light system is removed or the program is being changed.
---Cleanup routines should be executed here (ex. removing subscribers), however manually destroying elements is not necessary.
---@virtual
function Program:Shutdown() end

---Creates an element for a light.
---@param light Features.ProgrammableLights.Light
---@param pos vec2? Defaults to origin.
---@param rotation number? In degrees. Defaults to `0`.
---@param scale number? Defaults to `1`.
---@return Features.ProgrammableLights.UI.Prefabs.Light
function Program:CreateLight(root, light, pos, rotation, scale)
    local LightPrefab = Lights:GetClass("Features.ProgrammableLights.UI.Prefabs.Light")
    local instance = LightPrefab.Create(Lights.Overlay.UI, "Features.ProgrammableLights.Light." .. light.ID .. "." .. Text.GenerateGUID(), root, light)
    if pos then
        instance:SetPosition(pos[1], pos[2])
    end
    if rotation then
        instance:SetRotation(rotation)
    end
    if scale then
        instance:SetScale(Vector.Create(scale, scale))
    end
    return instance
end
