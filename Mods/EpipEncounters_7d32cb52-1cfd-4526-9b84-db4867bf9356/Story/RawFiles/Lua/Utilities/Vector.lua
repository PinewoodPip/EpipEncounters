
---@class VectorLib : Library
---@field zero2 Vector Shorthand for Vector.Create(0, 0)
---@field zero3 Vector Shorthand for Vector.Create(0, 0, 0)
---@operator call:Vector Equivalent to Vector.Create()
Vector = {}
Epip.InitializeLibrary("Vector", Vector)

---------------------------------------------
-- VECTOR TABLE
---------------------------------------------

---@alias Vector2 Vector
---@alias Vector2D Vector
---@alias Vector3 Vector
---@alias Vector3D Vector
---@alias Vector4 Vector

---@class Vector
---@field Arity integer Getter. Equivalent to #self.
---@field Length number Getter. Equivalent to Vector.GetLength()
---@field unpack fun(self:Vector):...number Equivalent to table.unpack(self)
---@operator add(Vector):Vector Equivalent to Vector.Sum()
---@operator mul(Vector):number Equivalent to Vector.DotProduct()
---@operator sub(Vector):Vector Equivalent to Vector.Subtract()
---@operator unm:Vector Equivalent to Vector.Negate()
local _Vector = {
    __index = function(self, key)
        -- Alternative way to fetch arity.
        if key == "Arity" then
            return #self
        elseif key == "unpack" then
            return function(vector)
                return table.unpack(vector)
            end
        elseif key == "Length" then
            return Vector.GetLength(self)
        elseif key == "__name" then
            return "Vector"
        end
    end,
    __add = function(self, v) return Vector.Sum(self, v) end,
    __sub = function(self, v) return Vector.Subtract(self, v) end,
    __mul = function(self, v)
        if type(v) == "number" then
            return Vector.ScalarProduct(self, v)
        else
            return Vector.DotProduct(self, v)
        end
    end,
    __unm = function(self) return Vector.Negate(self) end,
    __eq = function (self, v) return Vector.AreEqual(self, v) end,
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a vector of variable length.
---@vararg number|table If using tables, provide one parameter only.
---@return Vector
function Vector.Create(...)
    local vector = {...} ---@type Vector

    -- Unpack table. Only first param is considered in this case.
    if #vector == 1 and type(vector[1]) == "table" then
        vector = {table.unpack(vector[1])}
    end

    setmetatable(vector, _Vector)

    return vector
end

---Performs a dot product between two vectors of the same dimensions.
---@param v1 Vector
---@param v2 Vector
---@return number
function Vector.DotProduct(v1, v2)
    if v1.Arity ~= v2.Arity then Vector:Error("DotProduct", "Vector dimension mismatch") end

    local value = 0

    for i=1,#v1,1 do
        value = value + v1[i] * v2[i]
    end

    return value
end

---Performs a scalar product of a vector, multiplying each of its components.
---@param v Vector
---@param scalar number
---@return Vector
function Vector.ScalarProduct(v, scalar)
    local output = Vector.Clone(v)

    for i=1,#v,1 do
        output[i] = v[i] * scalar
    end

    return output
end

---Sums the components of two vectors of the same dimensions.
---@param v1 Vector
---@param v2 Vector
---@return Vector
function Vector.Sum(v1, v2)
    if v1.Arity ~= v2.Arity then Vector:Error("Sum", "Vector dimension mismatch") end

    local v = Vector.Clone(v1)

    for i=1,#v1,1 do
        v[i] = v1[i] + v2[i]
    end

    return v
end

---Subtracts the components of two vectors of the same dimension.
---@param v1 Vector
---@param v2 Vector
---@return Vector
function Vector.Subtract(v1, v2)
    return Vector.Sum(v1, Vector.Negate(v2))
end

---@param v Vector
---@return Vector
function Vector.Negate(v)
    v = Vector.Clone(v)

    for i=1,#v,1 do
        v[i] = -v[i]
    end

    return v
end

---Returns whether 2 vectors are equal.
---Vectors are equal if they have the same arity and components.
---@param v1 Vector
---@param v2 Vector
function Vector.AreEqual(v1, v2)
    if not v1 or not v2 then
        Vector:Error("Vector:AreEqual", "Parameters must not be nil")
    end
    local equal = v1.Arity == v2.Arity
    if equal then
        for i,value in ipairs(v1) do
            if value ~= v2[i] then
                equal = false
            end
        end
    end
    return equal
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

---Rotates a vector.
---@param vec Vector2
---@param degrees number
function Vector.Rotate(vec, degrees)
    local radians = math.rad(degrees)
    return Vector.Create(math.cos(radians) * vec[1] - math.sin(radians) * vec[2], math.sin(radians) * vec[1] + math.cos(radians) * vec[2])
end

---Returns the angle between 2D vectors.
---@param v1 Vector2
---@param v2 Vector2
function Vector.Angle(v1, v2)
    local x1, y1, x2, y2 = v1[1], v1[2], v2[1], v2[2]
    return math.acos((x1 * x2 + y1 * y2) / (math.sqrt(x1 ^ 2 + y1 ^ 2) * (math.sqrt(x2 ^ 2 + y2 ^ 2))))
end

---Returns a new vector with floored components of another.
---@param vec Vector
---@return Vector
function Vector.Floor(vec)
    local components = {} ---@type number[]
    for i=1,vec.Arity,1 do
        components[i] = math.floor(vec[i])
    end
    return Vector.Create(components)
end

---Returns a new vector with ceiled components of another.
---@param vec Vector
---@return Vector
function Vector.Ceil(vec)
    local components = {} ---@type number[]
    for i=1,vec.Arity,1 do
        components[i] = math.ceil(vec[i])
    end
    return Vector.Create(components)
end

---Returns a new vector with rounded components of another.
---@param vec Vector
---@return Vector
function Vector.Round(vec)
    local components = {} ---@type number[]
    for i=1,vec.Arity,1 do
        components[i] = Ext.Round(vec[i])
    end
    return Vector.Create(components)
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- TODO make these be created on __index again
Vector.zero2 = Vector.Create(0, 0)
Vector.zero3 = Vector.Create(0, 0, 0)
