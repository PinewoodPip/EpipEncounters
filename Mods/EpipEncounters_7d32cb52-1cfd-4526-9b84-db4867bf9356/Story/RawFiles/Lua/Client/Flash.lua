
local V = Vector.Create

local Flash = {
    REFERENCE_RESOLUTION = V(1920, 1080), -- Design resolution used by various vanilla UIs.
}
Epip.InitializeLibrary("Flash", Flash)
Client.Flash = Flash
Flash.REFERENCE_ASPECT_RATIO = Flash.REFERENCE_RESOLUTION[1] / Flash.REFERENCE_RESOLUTION[2] -- Design aspect ratio used by various vanilla UIs.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias FlashObjectHandle int64

---@class FlashArrayEntryTemplate
---@field Name string
---@field Enum table<integer, string>? Converts number parameters to string.

---@class FlashArrayMultiElementEntryTemplate
---@field Name string For human/script reference. Does not correspond to internal ID.
---@field Template (string|FlashArrayEntryTemplate)[] 

---------------------------------------------
-- METHODS
---------------------------------------------

---Converts coordinates from screen space to stretched stage space -
---the space where the window is considered to be always 1080 units tall.
---@param pos Vector2
---@return Vector2
function Flash.ScreenSpaceToStretchedStage(pos)
    local viewport = Client.GetViewportSize()
    local aspectRatio = viewport[1] / viewport[2]
    local stageResolution = Vector.Create(Flash.REFERENCE_RESOLUTION[1] * (aspectRatio / Flash.REFERENCE_ASPECT_RATIO), Flash.REFERENCE_RESOLUTION[2])
    local relativeCursorPos = Vector.Create(pos[1] / viewport[1], pos[2] / viewport[2])

    return Vector.Create(relativeCursorPos[1] * stageResolution[1], relativeCursorPos[2] * stageResolution[2])
end

---Returns the last element of an array.
---@param array FlashArray
---@return any
function Flash.GetLastElement(array)
    return array[#array - 1]
end

---Parses an update array.
---@param arr FlashArray
---@param entryTemplate (string|FlashArrayEntryTemplate|FlashArrayMultiElementEntryTemplate)[] Parameter names/templates, in order.
---@param multipleElementTypes boolean?
---@param forcedElementCount integer? If present, should include the type ID.
---@param startingIndex integer? 0-based. Defaults to 0.
---@return table<string, any>[]
function Flash.ParseArray(arr, entryTemplate, multipleElementTypes, forcedElementCount, startingIndex)
    local paramCount = #entryTemplate
    local entries = {}
    startingIndex = startingIndex or 0

    local i = startingIndex
    while i <= #arr-1 do
        local elementTypeName
        local template = entryTemplate
        local entry = {}
        local entryStartingIndex = 0 -- Offset for when the entry data starts; used to discard the type discriminator.
        local entryFlashID

        if multipleElementTypes then
            local typeValue = arr[i]

            elementTypeName = entryTemplate[typeValue].Name
            template = entryTemplate[typeValue].Template
            entryStartingIndex = 1
            paramCount = #template

            entryFlashID = typeValue
        end

        for z=1,paramCount,1 do
            local value = arr[i + z - 1 + entryStartingIndex]

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

        i = i + (forcedElementCount or (#template + entryStartingIndex))

        table.insert(entries, entry)
    end

    return entries
end

---@param array FlashArray
---@param entryTemplate (string|FlashArrayEntryTemplate|FlashArrayMultiElementEntryTemplate)[]
---@param data table
---@param multipleEntryTypes boolean? Defaults to false.
---@param forcedElementCount integer?
---@param startingIndex integer? 0-based. Defaults to 0.
function Flash.EncodeArray(array, entryTemplate, data, multipleEntryTypes, forcedElementCount, startingIndex)
    startingIndex = startingIndex or 0

    local i = 1
    local newArrayLength = startingIndex
    while i <= #data do
        local entry = data[i]
        local template = entryTemplate
        local paramsAdded = 0

        if multipleEntryTypes then
            local entryFlashID = entry.EntryTypeFlashID 

            -- Search within templates. This is used if a hook adds entries but does not define this internal type, instead using the user-friendly string ID.
            if entryFlashID == nil then
                for key,tbl in pairs(entryTemplate) do
                    if tbl.Name == entry.EntryTypeID then
                        entryFlashID = key
                        break
                    end
                end
            end

            template = entryTemplate[entryFlashID].Template

            -- Place entry ID
            array[newArrayLength] = entryFlashID
            newArrayLength = newArrayLength + 1
            paramsAdded = paramsAdded + 1
        end

        for _,key in ipairs(template) do
            local param = entry[key]
            local value

            if type(key) == "table" then
                local paramName = key.Name

                if key.Enum then
                    local values = key.Enum
                    local stringValue = entry[paramName]

                    value = table.reverseLookup(values, stringValue)
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
---@return FlashObject?
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

---Converts a handle to its flash representation.
---@param handle EntityHandle
---@return FlashObjectHandle
function Flash.ToFlashHandle(handle)
    return Ext.UI.HandleToDouble(handle)
end

---Converts a flash handle to its engine counterpart.
---@param flashHandle FlashObjectHandle
---@return EntityHandle
function Flash.ToEngineHandle(flashHandle)
    return Ext.UI.DoubleToHandle(flashHandle)
end

---Copies the elements of a list to a flash array.
---@param list LuaFlashCompatibleType[]
---@param arr FlashArray Will have its length truncated.
function Flash.ListToArray(list, arr)
    local arrLength = #arr
    local listLength = #list
    for i,v in ipairs(list) do
        arr[i-1] = v
    end
    -- Truncate array
    if listLength < arrLength then
        arr.length = listLength
    end
end
