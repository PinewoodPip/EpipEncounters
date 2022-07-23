
local Flash = {}
Epip.InitializeLibrary("Flash", Flash)
Client.Flash = Flash

---Returns the last element of an array.
---@param array FlashArray
---@return any
function Flash.GetLastElement(array)
    return array[#array - 1]
end

---@class FlashArrayEntryTemplate
---@field Name string
---@field Enum table<integer, string>? Converts number parameters to string.

---Parses an update array. Only works for non-typed arrays (where elements are all of the same "type").
---@param arr FlashArray
---@param entryTemplate (string|FlashArrayEntryTemplate)[] Parameter names/templates, in order.
---@return table<string, any>[]
function Flash.ParseArray(arr, entryTemplate)
    local paramCount = #entryTemplate
    local entries = {}

    for i=0,#arr-1,paramCount do
        local entry = {}
        for z=1,paramCount, 1 do
            local param = entryTemplate[z]
            local value = arr[i + z - 1]
            local paramName

            if type(param) == "string" then
                paramName = param
            else
                paramName = param.Name

                if param.Enum then
                    value = param.Enum[value]
                end
            end

            entry[paramName] = value
        end

        table.insert(entries, entry)
    end

    return entries
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