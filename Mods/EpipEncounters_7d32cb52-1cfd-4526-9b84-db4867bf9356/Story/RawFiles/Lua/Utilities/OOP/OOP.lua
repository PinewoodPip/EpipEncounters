
local Print = Ext.Utils.Print
local PrintWarning = Ext.Utils.PrintWarning
local PrintError = Ext.Utils.PrintError

---@class OOPLib
OOP = {
    ---@enum OOPLib.LoggingLevel
    LOGGING_LEVELS = {
        ALL = 0,
        WARN = 1,
        MUTED = 2, -- Errors only.
    },
    _Classes = {}, ---@type table<string, table>
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias classname string

---@class Class
---@field __name string
---@field __ParentClasses string[]
---@field __ClassDefinition Class
---@field __LoggingLevel OOPLib.LoggingLevel
---@field ___DeprecatedKeyRedirects table<any, Class.DeprecatedKeyRedirect>? `nil` if none are registered.
local Class = {}

---@class Class.DeprecatedKeyRedirect
---@field WarningMessage string? Warning to log when the redirect is used, in addition to a default "Field X is deprecated" message.
---@field Value fun(self:Class):any Will be invoked to get the return value for indexing with the key.

---Creates a new instance of the class.
---@protected
---@param data table? Table with the initial fields of the instance.
---@return Class
function Class:__Create(data)
    local classTable = self ---@cast classTable table|Class
    data = data or {}
    ---@cast data Class

    setmetatable(data, {
        __index = function (instance, key)
            -- Check field presence in class definition
            local classDefinitionValue = classTable[key] -- Uses a local to avoid indexing it twice.
            if classDefinitionValue ~= nil then
                return classDefinitionValue
            end

            -- Check presence in parent classes
            for _,tbl in ipairs(instance:GetParentClasses()) do
                if tbl[key] ~= nil then
                    return tbl[key]
                end
            end

            -- Check dedicated __index method in class definition
            if classTable.__index ~= nil then
                return classTable.__index(instance, key)
            end
        end,
        -- TODO support multiple inheritance for these
        __newindex = classTable.__newindex,
        __mode = classTable.__mode,
        __call = classTable.__call,
        __metatable = classTable.__metatable,
        __tostring = classTable.__tostring,
        __len = classTable.__len,
        __pairs = classTable.__pairs,
        __ipairs = classTable.__ipairs,
        __name = classTable.__name,

        __unm = classTable.__unm,
        __add = classTable.__add,
        __sub = classTable.__sub,
        __mul = classTable.__mul,
        __div = classTable.__div,
        __idiv = classTable.__idiv,
        __mod = classTable.__mod,
        __pow = classTable.__pow,
        __concat = classTable.__concat,

        __band = classTable.__band,
        __bor = classTable.__bor,
        __bxor = classTable.__bxor,
        __bnot = classTable.__bnot,
        __shl = classTable.__shl,
        __shr = classTable.__shr,

        __eq = classTable.__eq,
        __lt = classTable.__lt,
        __le = classTable.__le,
    })

    return data
end

---Returns the name of the class.
---@return string
function Class:GetClassName()
    return self.__name
end

---Returns whether this class implements another.
---Hierarchies are considered.
---Will return `true` if this class is the queried one.
---@param class string|Class
---@return boolean
function Class:ImplementsClass(class)
    local className = type(class) == "table" and class:GetClassName() or class -- Class overload.
    local implements = self:GetClassName() == className

    if not implements then
        for _,parentClass in ipairs(self:GetParentClasses()) do
            if parentClass:GetClassName() == className or parentClass:ImplementsClass(className) then
                implements = true
                break
            end
        end
    end

    return implements
end

---Returns the parent classes of the class.
---@return Class[]
function Class:GetParentClasses()
    local classes = {}

    for i,className in ipairs(self.__ParentClasses) do
        classes[i] = OOP.GetClass(className)
    end

    return classes
end

---Returns the main table that defines this class instance.
---@return Class
function Class:GetClassDefinition()
    return self.__ClassDefinition
end

---Logs a message.
---@param ... any
function Class:__Log(...)
    if self.__LoggingLevel <= OOP.LOGGING_LEVELS.ALL then
        Print(self:__GetLoggingPrefix(), ...)
    end
end

---Logs a warning.
---Requires logging level to be set to WARN or lower.
---@param ... any
function Class:__LogWarning(...)
    if self.__LoggingLevel <= OOP.LOGGING_LEVELS.WARN then
        PrintWarning(self:__GetLoggingPrefix(), ...)
    end
end

---Logs a "Not implemented" warning. Use as a placeholder.
---@param methodName string
function Class:__LogNotImplemented(methodName)
    self:__LogWarning("Not implemented: " .. methodName)
end

---Throws a "Not implemented" error. Use as a placeholder.
---@param methodName string
function Class:__ThrowNotImplemented(methodName)
    self:__Error(methodName, "Not implemented")
end

---Logs an error without halting execution.
---@param ... any
function Class:__LogError(...)
    PrintError(self:__GetLoggingPrefix(), ...)
end

---Throws an error prefixed with the class and method name, blaming the third-level function in the stack - usually user code.
---@param ... any
---@param method string
function Class:__Error(method, ...)
    -- This code duplication is intentional to reduce impact on the call stack, offering a larger traceback.
    local params = {...}
    local str = Text.Join(params, " ")
    error(string.format("%s %s(): %s",
        self:__GetLoggingPrefix(),
        method,
        str
    ), 3)
end

---Throws an error prefixed with the class and method name caused at the callee function.
---@param method string
---@param ... any
function Class:__InternalError(method, ...)
    -- This code duplication is intentional to reduce impact on the call stack, offering a larger traceback.
    local params = {...}
    local str = Text.Join(params, " ")
    error(string.format("%s %s(): %s",
        self:__GetLoggingPrefix(),
        method,
        str
    ), 2)
end

---Returns the prefix to use for logging messages.
---@return string
function Class:__GetLoggingPrefix()
    return " [" .. self:GetClassName():upper() .. "]" -- Extra space at start to quickly tell Epip logging apart from others
end

---Marks a key as deprecated, logging a warning when it is indexed
---and redirecting to a function's evaluation.
---Intended for implementing backwards-compatibility. 
---@param key any Must be `nil` within class definition.
---@param redirect Class.DeprecatedKeyRedirect
function Class:__RegisterDeprecatedKeyRedirect(key, redirect)
    local tbl = self:GetClassDefinition()
    -- Registering a redirect for a field still in-use by the class definition
    -- is most likely not intended by user.
    if tbl[key] ~= nil then
        tbl:__Error("__RegisterDeprecatedKeyRedirect", key, "is not nil in class definition")
    end
    -- Create table on first registration.
    if tbl.___DeprecatedKeyRedirects == nil then
        tbl.___DeprecatedKeyRedirects = {}
    end
    tbl.___DeprecatedKeyRedirects[key] = redirect
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a class.
---@generic T
---@param className string|`T`
---@param class table
---@param parentClasses string[]? Classes this one inherits from.
---@return `T`
function OOP.RegisterClass(className, class, parentClasses)
    ---@cast class Class

    -- Copy Class methods onto the class definition table
    for k,v in pairs(Class) do
        if type(v) == "function" then
            class[k] = v -- TODO proper inheritance
        end
    end

    ---@diagnostic disable invisible
    class.__ClassDefinition = class
    class.__ParentClasses = parentClasses or {}
    class.__LoggingLevel = OOP.LOGGING_LEVELS.ALL
    class.__name = class.__name or className

    OOP._Classes[className] = class

    local indexmethod = class.__index
    
    -- Set metatable for static access
    setmetatable(class, {
        __index = function (instance, key)
            ---@cast instance Class

            -- Check if the field is deprecated
            if rawget(instance, "___DeprecatedKeyRedirects") and instance.___DeprecatedKeyRedirects[key] then
                local redirect = instance.___DeprecatedKeyRedirects[key]
                instance:__LogWarning("The field", key, "is deprecated.", redirect.WarningMessage or "")
                return redirect.Value(instance)
            end

            -- Check presence in parent classes
            for _,tbl in ipairs(Class.GetParentClasses(class)) do
                if tbl[key] ~= nil then
                    return tbl[key]
                end
            end

            if indexmethod ~= nil then
                return indexmethod(instance, key)
            end
        end,
    })

    ---@diagnostic enable invisible

    return class
end

---Returns the base table for a class.
---Throws if the class is not registered.
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
---@param tbl table|Class
---@param class (string|Class)? If present, `true` will only be returned if the table *is* the exact requested class.
---@return boolean
function OOP.IsClass(tbl, class)
    local className = type(class) == "table" and class:GetClassName() or class -- Class overload.
    local isClass = false
    ---@diagnostic disable: invisible
    if type(tbl) == "table" and tbl.__name then
        local result, tableClass = pcall(OOP.GetClass, tbl.__name)
        if result then
            local isCorrectClass = className == nil or tableClass.__name == className
            if isCorrectClass then
                isClass = true
            end
        end
    end
    ---@diagnostic enable: invisible
    return isClass
end

---Returns whether a table implements a class.
---@param tbl table|Class
---@param class string|Class
function OOP.ImplementsClass(tbl, class)
    return OOP.IsClass(tbl) and tbl:ImplementsClass(class)
end

---Sets a table's metatable. __index is set to index the metatable itself, using the metatable's __index as a fallback.
---@param table table Mutated.
---@param metatable table
function OOP.SetMetatable(table, metatable)
    local indexTable = metatable
    if metatable.__index then
        indexTable = function(tbl, key) -- TODO cleaner declaration for classes
            if metatable[key] ~= nil then -- TODO consider multiple inheritance
                return metatable[key]
            else
                return metatable.__index(tbl, key)
            end
        end
    end

    setmetatable(table, {
        __index = indexTable, -- Can't assign `.__index or metatable` because inheriting fields in metatable would break
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