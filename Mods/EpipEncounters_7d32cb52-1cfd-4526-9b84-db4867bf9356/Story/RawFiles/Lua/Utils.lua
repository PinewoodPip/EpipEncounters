
function unpack(t, i)
    i = i or 1
    if t[i] ~= nil then
        return t[i], unpack(t, i + 1)
    end
end

---@return string? Nil if the object is not an extender object.
function GetExtType(obj)
    local objType

    if type(obj) == "userdata" then
        objType = getmetatable(obj)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return objType
end

function GetMetatableType(obj)
    if type(obj) == "table" then
        return obj.__name
    else
        return nil
    end
end

---@param strList string[]
---@param separator string?
function string.concat(strList, separator)
    local newStr = ""

    for i,str in ipairs(strList) do
        newStr = newStr .. str

        if separator and i ~= #strList then
            newStr = newStr .. separator
        end
    end

    return newStr
end

function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end