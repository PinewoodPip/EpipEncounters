
---------------------------------------------
-- Extensions to the math table.
---------------------------------------------

---Clamps a value to a range. Returned value is always a float.
---@param value number
---@param min number
---@param max number
---@return number
function math.clamp(value, min, max)
    return Ext.Math.Clamp(value, min, max)
end

---@return 1|-1
function math.randomSign()
    if Ext.Random(0, 1) == 1 then
        return 1
    else
        return -1
    end
end