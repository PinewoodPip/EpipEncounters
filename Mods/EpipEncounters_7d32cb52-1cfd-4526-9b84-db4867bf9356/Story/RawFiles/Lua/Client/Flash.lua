
local Flash = {}
Epip.InitializeLibrary("Flash", Flash)
Client.Flash = Flash

---Returns the last element of an array.
---@param array FlashArray
---@return any
function Flash.GetLastElement(array)
    return array[#array - 1]
end

---Returns the first element of an array whose field value matches the one passed as parameter.
---@param array FlashArray Must be of objects.
---@param field string
---@param value any
---@return FlashObject
function Flash.GetElementByField(array, field, value)
    local element = nil

    for i=0,#array-1,1 do
        local el = array[i]

        if el[field] == value then
            element = el
            break
        end
    end

    return element
end