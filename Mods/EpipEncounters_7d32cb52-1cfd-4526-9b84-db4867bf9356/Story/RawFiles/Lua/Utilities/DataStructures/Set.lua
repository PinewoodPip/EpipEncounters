
---@class DataStructures_Set : Class
local Set = {
    _Elements = {},
}
DataStructures.Register("DataStructures_Set", Set)
OOP.RegisterClass("DataStructures_Set", Set)

---@class DataStructures_Set<T> : Class, {( Create:fun(elements:T[]?) ), ( Add:fun(self, element:T):boolean ), ( Contains:fun(self, element:T):boolean ), ( Remove:fun(self, element:T):boolean ), ( Iterator:fun(self):fun():T,T )}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param elements any[]?
function Set.Create(elements)
    ---@type DataStructures_Set
    local tbl = {
        _Elements = {}
    }
    -- Inherit(tbl, Set)
    setmetatable(tbl, {
        __index = Set,
        __pairs = Set.__pairs,
        __ipairs = Set.__ipairs,
        __len = Set.__len,
    })

    for _,element in ipairs(elements or {}) do
        tbl:Add(element)
    end

    return tbl
end

---@param element any
---@return boolean -- True if the element was not already in the set.
function Set:Add(element)
    local present = self:Contains(element)

    if not present then
        self._Elements[element] = true
    end

    return not present
end

---@param element any
---@return boolean
function Set:Contains(element)
    return self._Elements[element] == true
end

---@param element any
---@return boolean -- True if the element was in the set.
function Set:Remove(element)
    local present = self:Contains(element)

    if present then
        self._Elements[element] = nil
    end

    return present
end

---Removes all elements from the set.
function Set:Clear()
    for element in self:Iterator() do
        self:Remove(element)
    end
end

---@iterator
function Set.Iterator(self)
    local key
    local generator = function ()
        if key then
            key, _ = next(self._Elements, key)
        else -- Start with the first key.
            key = pairs(self._Elements)(self._Elements)
        end

        return key
    end

    return generator
end

function Set.__len(self)
    return table.getKeyCount(self._Elements)
end

function Set.__pairs(_)
    error("pairs is not implemented. Use Iterator() to iterate elements.")
end

function Set.__ipairs(_)
    error("ipairs is not implemented. Use Iterator() to iterate elements.")
end

---------------------------------------------
-- TESTS
---------------------------------------------

Ext.RegisterConsoleCommand("test_set", function (_)
    local setClass = DataStructures.Get("DataStructures_Set")
    local set = setClass.Create({7, 1, 3})

    assert(not set:Contains(2))
    assert(set:Contains(3))
    assert(set:Contains(1))

    set:Remove(3)
    assert(not set:Contains(3))

    set:Add(5)
    for element in set:Iterator() do
        assert(type(element) == "number")
        print(element)
    end

    print("All good.")
end)