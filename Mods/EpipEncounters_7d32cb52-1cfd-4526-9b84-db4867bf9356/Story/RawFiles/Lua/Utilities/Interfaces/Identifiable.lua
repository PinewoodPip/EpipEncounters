
local Interfaces = Interfaces

---@class I_Identifiable : InterfaceLib_Interface
local _Identifiable = {
    ID = nil, ---@type string
}
Interfaces.RegisterInterface("I_Identifiable", _Identifiable)

---@return string
function _Identifiable:GetID()
    return self.ID
end