
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

---@param strList str[]
---@param separator string?
function string.concat(strList, separator)
    local newStr = ""

    for i,str in ipairs(strList) do
        newStr = newStr .. str

        if separator and i ~= #str then
            newStr = newStr .. separator
        end
    end

    return newStr
end

function ParseFlashArray(array, argList, offset)

    local currentElement = nil
    local paramsLeft = -1
    local parsedOptions = {}
    local hasMultipleElementTypes = #argList > 1
    local hasNamedParams = argList[1].params ~= nil
    local elementData = nil

    offset = offset or 0

    for i=offset,#array-1,1 do
        local ignore = false
        if (paramsLeft <= 0) then
            -- Ext.Print("starting element parse")
            -- Ext.Print("type " .. array[i])

            elementData = nil
            if hasMultipleElementTypes then
                elementData = argList[array[i] + 1]
            else
                elementData = argList[1]
            end

            currentElement = {id = elementData.id, name = elementData.name, params = {}}
            paramsLeft = elementData.paramsCount or #elementData.params

            table.insert(parsedOptions, currentElement)

            if hasMultipleElementTypes then
                ignore = true -- skip parsing this index for arrays that are multi-element (this index will indicate element type)
            end
        end
        if not ignore then
            -- Ext.Print("adding element")
            local param = array[i]

            -- Ext.Dump(currentElement)

            if hasNamedParams then
                local paramIndex = (elementData.paramsCount or #elementData.params) - paramsLeft + 1
                local paramName = elementData.params[paramIndex]
                currentElement.params[paramName] = param
            else
                table.insert(currentElement.params, param)
            end

            paramsLeft = paramsLeft - 1
        end
    end

    return parsedOptions
end

function CenterElement(element, parent, axis, elementSizeOverride)
    local elementSize = element.height
    local size = "height"

    if axis == "x" then size = "width" end

    if axis == "x" then
        elementSize = element.width
    end
    if elementSizeOverride then
        elementSize = elementSizeOverride
    end

    element[axis] = parent[size] / 2 - elementSize / 2 
end

-- Incredible technology. The work of a maestro
function CenterText(element, offset)
    element.htmlText = '<p align="center">' .. element.htmlText .. '</p>'
    element.x = element.x + (offset or 0)
end

function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end