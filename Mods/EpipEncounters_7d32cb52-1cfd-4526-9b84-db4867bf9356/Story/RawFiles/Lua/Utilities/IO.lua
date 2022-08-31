
---@class InputOutputLib
IO = {
    ---@enum InputOutputLib_FileContext
    FILE_CONTEXTS = {
        ROOT = "Root", -- Not usable.
        DATA = "Data",
        PUBLIC = "Public", -- Not usable.
        MY_DOCUMENTS = "MyDocuments", -- Not usable.
        GAME_STORAGE = "GameStorage",
    }
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Serializes contents into json and saves them to a file.
---@param filename string
---@param contents any
function IO.SaveFile(filename, contents)
    Ext.IO.SaveFile(filename, Ext.DumpExport(contents))
end

---Loads a file.
---@param filename string
---@param context InputOutputLib_FileContext
---@return any
function IO.LoadFile(filename, context)
    local contents = Ext.IO.LoadFile(filename, context)

    if contents then
        contents = Ext.Json.Parse(contents)
    end

    return contents
end