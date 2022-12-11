
---@class InterfaceLib : Library
Interfaces = {
    _Interfaces = {}, ---@type table<string, InterfaceLib_Interface>
}
Epip.InitializeLibrary("InterfaceLib", Interfaces)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias InterfaceLib_InterfaceClassName "I_Identifiable"|"I_Describable"

---@class InterfaceLib_Interface

---------------------------------------------
-- METHODS
---------------------------------------------

---@param className string
---@param interface InterfaceLib_Interface
function Interfaces.RegisterInterface(className, interface)
    Interfaces._Interfaces[className] = interface
end

---@generic T
---@param className `T`|InterfaceLib_InterfaceClassName
---@return T
function Interfaces.Get(className)
    local tbl = Interfaces._Interfaces[className]
    if not tbl then Interfaces:Error("Get", "Unregistered interface", className) end

    return tbl
end

---@generic T
---@param tbl table
---@param className `T`|InterfaceLib_InterfaceClassName
---@return T
function Interfaces.Apply(tbl, className)
    local interface = Interfaces.Get(className)

    -- Copy over fields and methods.
    -- Interfaces do not use metatables.
    for key,field in pairs(interface) do
        if not tbl[key] then
            tbl[key] = field
        end
    end

    return tbl
end