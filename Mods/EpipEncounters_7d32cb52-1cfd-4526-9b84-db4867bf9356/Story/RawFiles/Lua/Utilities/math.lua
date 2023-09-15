
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

---Linearly interpolates a value from a starting value to an end value.
---@param startValue number
---@param endValue number
---@param progress number Expected values are from 0.0 to 1.0.
function math.lerp(startValue, endValue, progress)
    local interval = endValue - startValue

    return startValue + (interval * progress)
end

function math.indexmodulo(index, divisor)
    local overshoot = index // divisor
    index = index - overshoot * divisor
    if index > divisor then
        index = index - divisor
    elseif index <= 0 then
        index = index + divisor
    end
    return index
end
