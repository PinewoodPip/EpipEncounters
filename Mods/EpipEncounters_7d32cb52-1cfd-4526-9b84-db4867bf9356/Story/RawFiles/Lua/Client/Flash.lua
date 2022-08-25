
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
---@param multipleElementTypes boolean?
---@param forcedElementCount integer?
---@return table<string, any>[]
function Flash.ParseArray(arr, entryTemplate, multipleElementTypes, forcedElementCount)
    local paramCount = #entryTemplate
    local entries = {}

    local i = 0
    while i <= #arr-1 do
        local elementTypeName
        local template = entryTemplate
        local entry = {}
        local startingIndex = 0
        
        if multipleElementTypes then
            local typeValue = arr[i]

            elementTypeName = entryTemplate[typeValue].Name
            template = entryTemplate[typeValue].Template
            startingIndex = 1
            paramCount = #template
        end
        
        for z=1,paramCount,1 do
            local value = arr[i + z - 1 + startingIndex]

            local param = template[z]
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

            entry.EntryTypeID = elementTypeName
        end

        i = i + (forcedElementCount or #template)

        table.insert(entries, entry)
    end

    return entries
end

---@param array FlashArray
---@param template (string|FlashArrayEntryTemplate)[]
---@param data table
function Flash.EncodeArray(array, template, data)
    local elementCount = #data
    local paramCount = #template

    for i=0,elementCount-1,1 do
        local baseIndex = i * paramCount

        for z=0,paramCount-1,1 do
            local param = template[z + 1]
            local paramKey = param
            local value

            value = data[i + 1][paramKey]

            if type(param) == "table" then
                paramKey = param.Name

                if param.Enum then
                    local values = param.Enum
                    value = table.reverseLookup(values, value)
                end
            end

            array[baseIndex + z] = value
        end
    end

    array.length = elementCount * paramCount
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