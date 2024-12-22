
---------------------------------------------
-- A prefab that renders a light using textures from its descriptor.
---------------------------------------------

local Lights = Epip.GetFeature("Features.ProgrammableLights") ---@class Features.ProgrammableLights

---@class Features.ProgrammableLights.UI.Prefabs.Light : GenericUI_Prefab, GenericUI_I_Elementable
---@field Descriptor Features.ProgrammableLights.Light
---@field State "Off"|string
---@field Background GenericUI_Element_Texture
---@field Texture GenericUI_Element_Texture
---@field _Root GenericUI_Element_Empty
local LightPrefab = {}
Lights:RegisterClass("Features.ProgrammableLights.UI.Prefabs.Light", LightPrefab, {"GenericUI_Prefab", "GenericUI_I_Elementable"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a light element from a descriptor.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier
---@param light Features.ProgrammableLights.Light
---@return Features.ProgrammableLights.UI.Prefabs.Light
function LightPrefab.Create(ui, id, parent, light)
    local instance = LightPrefab:_Create(ui, id) ---@cast instance Features.ProgrammableLights.UI.Prefabs.Light
    instance.Descriptor = light
    instance.State = "Off"

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance._Root = root

    -- Use off texture as background
    local background = instance:CreateElement("Background", "GenericUI_Element_Texture", root)
    background:SetTexture(light.OffTexture)
    background:Move(-background:GetWidth() / 2, -background:GetHeight())
    instance.Background = background

    -- The actual state texture
    local texture = instance:CreateElement("Texture", "GenericUI_Element_Texture", root)
    texture:SetTexture(light.OffTexture) -- Default to off.
    texture:Move(-texture:GetWidth() / 2, -texture:GetHeight())
    instance.Texture = texture

    return instance
end

---Sets the state of the light.
---@param state "Off"|string Must be a state supported by the light descriptor.
function LightPrefab:SetState(state)
    local texture ---@type TextureLib_Texture
    if state == "Off" then
        texture = self.Descriptor.OffTexture
    else
        texture = self.Descriptor.StateTextures[state]
        if not texture then
            LightPrefab:__Error("SetState", "Light", self.Descriptor.ID, "does not have state", state)
        end
    end
    self.Texture:SetTexture(texture)
    self.State = state
end

---Sets the light to the "Off" state.
function LightPrefab:TurnOff()
    self:SetState("Off")
end

---@override
function LightPrefab:GetRootElement()
    return self._Root
end
