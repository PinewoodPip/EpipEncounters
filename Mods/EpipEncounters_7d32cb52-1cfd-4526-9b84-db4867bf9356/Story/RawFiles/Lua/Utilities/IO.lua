
---@class InputOutputLib
IO = {
    ---@enum InputOutputLib_FileContext
    FILE_CONTEXTS = {
        ROOT = "Root", -- Not usable.
        DATA = "Data", -- Use "data" for Ext calls.
        PUBLIC = "Public", -- Not usable.
        MY_DOCUMENTS = "MyDocuments", -- Not usable.
        GAME_STORAGE = "GameStorage", -- Use "user" for Ext calls.
    }
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias InputOutputLib_UserFileContext "user"|"data"

---------------------------------------------
-- METHODS
---------------------------------------------

---Serializes contents into json and saves them to a file.
---@param filename string
---@param contents any
---@param raw boolean? Defaults to false.
---@param clean boolean? Defaults to false. Calls table.clean() on the contents.
function IO.SaveFile(filename, contents, raw, clean)
    if type(contents) == "table" and clean then
        contents = table.clean(contents)
    end
    if not raw then contents = Ext.DumpExport(contents) end
    
    Ext.IO.SaveFile(filename, contents)
end

---Loads a file.
---@param filename string
---@param context (InputOutputLib_UserFileContext)? Defaults to "user"
---@param raw boolean? Defaults to false.
---@return any
function IO.LoadFile(filename, context, raw)
    context = context or "user"
    local contents = Ext.IO.LoadFile(filename, context)

    if contents and not raw then
        contents = Ext.Json.Parse(contents)
    end

    return contents
end