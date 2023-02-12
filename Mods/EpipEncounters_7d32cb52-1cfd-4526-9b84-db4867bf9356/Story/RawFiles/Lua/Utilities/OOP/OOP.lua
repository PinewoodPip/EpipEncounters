
---@class OOPLib
OOP = {
    _Classes = {}, ---@type table<string, table>
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Class
---@field protected __name string
local Class = {}

---Creates a new table with the metatable of the class set.
---@protected
---@param data table?
---@return Class
function Class:__Create(data)
    OOP.SetMetatable(data or {}, self)

    return data
end

---Returns the name of the class.
---@return string
function Class:GetClassName()
    return self.__name
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a class.
---@param className string
---@param class table
function OOP.RegisterClass(className, class)
    for k,v in pairs(Class) do
        if type(v) == "function" then
            class[k] = v -- TODO
        end
    end

    class.__name = class.__name or className

    OOP._Classes[className] = class
end

---Returns the base table for a class.
---@generic T
---@param className `T`
---@return `T`
function OOP.GetClass(className)
    local class = OOP._Classes[className]

    if not class then
        error("Class is not registered: " .. className)
    end

    return class 
end

---Returns whether a table is a class table or instance.
---@param tbl table
---@return boolean
function OOP.IsClass(tbl)
    local isClassed = false
    
    if type(tbl) == "table" then
        if tbl.__name and OOP.GetClass(tbl.__name) ~= nil then
            isClassed = true
        end
    end

    return isClassed
end

---Sets a table's metatable.
---@param table table Mutated.
---@param metatable table
function OOP.SetMetatable(table, metatable)
    setmetatable(table, {
        __index = metatable.__index or metatable,
        __newindex = metatable.__newindex,
        __mode = metatable.__mode,
        __call = metatable.__call,
        __metatable = metatable.__metatable,
        __tostring = metatable.__tostring,
        __len = metatable.__len,
        __pairs = metatable.__pairs,
        __ipairs = metatable.__ipairs,
        __name = metatable.__name,

        __unm = metatable.__unm,
        __add = metatable.__add,
        __sub = metatable.__sub,
        __mul = metatable.__mul,
        __div = metatable.__div,
        __idiv = metatable.__idiv,
        __mod = metatable.__mod,
        __pow = metatable.__pow,
        __concat = metatable.__concat,

        __band = metatable.__band,
        __bor = metatable.__bor,
        __bxor = metatable.__bxor,
        __bnot = metatable.__bnot,
        __shl = metatable.__shl,
        __shr = metatable.__shr,

        __eq = metatable.__eq,
        __lt = metatable.__lt,
        __le = metatable.__le,
    })
end