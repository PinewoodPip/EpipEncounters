
Vector = {}
Epip.InitializeLibrary("Vector", Vector)

---------------------------------------------
-- VECTOR TABLE
---------------------------------------------

---@alias Vector2D Vector
---@alias Vector3D Vector

---@class Vector
---@field Arity integer Getter. Equivalent to #self.
---@field Length number Getter. Equivalent to Vector.GetLength()
local _Vector = {
    __index = function(self, key)
        -- Alternative way to fetch arity.
        if key == "Arity" then
            return #self
        elseif key == "Length" then
            return Vector.GetLength(self)
        end
    end,
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a vector of variable length.
---@vararg number
---@return Vector
function Vector.Create(...)
    local vector = {...} ---@type Vector
    setmetatable(vector, _Vector)

    return vector
end

---@param vector Vector
---@return Vector
function Vector.Clone(vector)
    local values = {}

    for i=1,#vector,1 do
        table.insert(values, vector[i])
    end

    return Vector.Create(table.unpack(values))
end 

---@param vector Vector
---@return Vector New instance; does not mutate.
function Vector.GetNormalized(vector)
    vector = Vector.Clone(vector)
    local length = vector.Length

    for i=1,#vector,1 do
        vector[i] = vector[i] / length
    end

    return vector
end

---@param vector Vector
---@return number
function Vector.GetLength(vector)
    local length = 0

    for i=1,#vector,1 do
        length = length + vector[i] ^ 2
    end

    length = math.sqrt(length)

    return length
end