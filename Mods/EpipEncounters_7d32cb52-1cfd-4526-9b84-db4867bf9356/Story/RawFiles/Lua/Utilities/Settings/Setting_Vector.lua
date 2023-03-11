
local Settings = Settings

---@class SettingsLib_Setting_Vector : SettingsLib_Setting
---@field Value Vector
---@field Arity integer? If set, only vectors of the same arity will be accepted for `SetValue()`
local _Vector = {
    Type = "ClampedNumber",
}
Settings:RegisterClass("SettingsLib_Setting_Vector", _Vector, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Vector", _Vector)

---------------------------------------------
-- METHODS
---------------------------------------------

---Override, clamps the value.
---@override
---@param value Vector
function _Vector:SetValue(value)
    if type(value) ~= "table" then
        error("Value is not a vector")
    end

    -- Convert to vector type if a raw table was passed.
    if GetMetatableType(value) ~= "Vector" then
        value = Vector.Create(value)
    end
    
    if self.Arity and value.Arity ~= self.Arity then
        error("Value is not of correct arity")
    end

    self.Value = Vector.Clone(value)
end