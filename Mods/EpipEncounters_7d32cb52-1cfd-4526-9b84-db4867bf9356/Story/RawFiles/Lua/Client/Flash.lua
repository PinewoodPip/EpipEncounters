
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

---@class FlashArrayMultiElementEntryTemplate
---@field Name string For human/script reference. Does not correspond to internal ID.
---@field Template (string|FlashArrayEntryTemplate)[] 

---Parses an update array. Only works for non-typed arrays (where elements are all of the same "type").
---@param arr FlashArray
---@param entryTemplate (string|FlashArrayEntryTemplate|FlashArrayMultiElementEntryTemplate)[] Parameter names/templates, in order.
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
        local entryFlashID
        
        if multipleElementTypes then
            local typeValue = arr[i]

            elementTypeName = entryTemplate[typeValue].Name
            template = entryTemplate[typeValue].Template
            startingIndex = 1
            paramCount = #template

            entryFlashID = typeValue
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
            entry.EntryTypeFlashID = entryFlashID
        end

        i = i + (forcedElementCount or #template)

        table.insert(entries, entry)
    end

    return entries
end

---@param array FlashArray
---@param entryTemplate (string|FlashArrayEntryTemplate|FlashArrayMultiElementEntryTemplate)[]
---@param data table
---@param multipleEntryTypes boolean? Defaults to false.
---@param forcedElementCount integer?
function Flash.EncodeArray(array, entryTemplate, data, multipleEntryTypes, forcedElementCount)
    local i = 1
    local newArrayLength = 0
    while i <= #data do
        local entry = data[i]
        local template = entryTemplate
        local paramsAdded = 0

        if multipleEntryTypes then
            template = entryTemplate[entry.EntryTypeFlashID].Template

            -- Place entry ID
            array[newArrayLength] = entry.EntryTypeFlashID
            newArrayLength = newArrayLength + 1
            paramsAdded = paramsAdded + 1
        end

        for _,key in ipairs(template) do
            local param = entry[key]
            local value

            if type(param) == "table" then
                local paramName = param.Name

                if param.Enum then
                    local values = param.Enum
                    value = table.reverseLookup(values, entry[paramName])
                end
            else
                value = param
            end

            array[newArrayLength] = value

            newArrayLength = newArrayLength + 1

            paramsAdded = paramsAdded + 1
        end

        -- Pad out element array if necessary
        while paramsAdded < (forcedElementCount or -1) do
            array[newArrayLength] = 0

            newArrayLength = newArrayLength + 1
            paramsAdded = paramsAdded + 1
        end

        i = i + 1
    end

    if forcedElementCount then
        array.length = #data * forcedElementCount
    else
        array.length = newArrayLength
    end
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