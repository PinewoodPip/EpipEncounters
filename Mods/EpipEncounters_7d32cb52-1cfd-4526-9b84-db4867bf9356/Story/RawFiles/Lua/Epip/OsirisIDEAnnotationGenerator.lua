
---------------------------------------------
-- Exports Osiris symbols to SumnekoLua IDE annotations.
-- Currently only supports Osiris events.
---------------------------------------------

---@class Feature_OsirisIDEAnnotationGenerator : Feature
local Generator = {
    ---@type table<OsirisType, string>
    OSIRIS_TYPE_TO_LUA_TYPE = {
        INTEGER = "integer",
        INTEGER64 = "integer",
        REAL = "number",
        STRING = "string",
        GUIDSTRING = "Guid",
        CHARACTERGUID = "Guid",
        ITEMGUID = "Guid",
        TRIGGERGUID = "Guid",
        SPLINEGUID = "Guid",
        LEVELTEMPLATEGUID = "Guid",
    },
    SYMBOL_PATTERN = "^([^ ]+) ([^(]+)%((.+)%) %(.+", -- Captures symbol type, event name and parameter list.
    PARAMETER_PATTERN = "%((.+)%)_(.+)", -- Captures parameter type and name.
}
Epip.RegisterFeature("OsirisIDEAnnotationGenerator", Generator)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias OsirisBuiltInType "syscall"|"sysquery"|"query"|"event"|"call"

---@class Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter
---@field Name string
---@field OsirisType OsirisType
local _Parameter = {}

---Creates a parameter object.
---@param type OsirisType
---@param name string
---@return Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter
function _Parameter.Create(type, name)
    ---@type Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter
    local param = {
        Name = name,
        OsirisType = type,
    }
    OOP.SetMetatable(param, _Parameter)

    return param
end

function _Parameter.__tostring(self)
    local luaType = Generator.GetLuaTypeForOsirisType(self.OsirisType)

    return string.format("--- @param %s %s", self.Name, luaType)
end

---@class Feature_OsirisIDEAnnotationGenerator_Annotation
---@field SymbolType OsirisBuiltInType
---@field Name string
---@field Parameters Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]
local _Annotation = {}

---Creates an annotation object.
---@param symbolType OsirisBuiltInType
---@param name string
---@param params Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]
---@return Feature_OsirisIDEAnnotationGenerator_Annotation
function _Annotation.Create(symbolType, name, params)
    ---@type Feature_OsirisIDEAnnotationGenerator_Annotation
    local annotation = {
        SymbolType = symbolType,
        Name = name,
        Parameters = {},
    }
    OOP.SetMetatable(annotation, _Annotation)

    for i,param in ipairs(params) do
        annotation.Parameters[i] = _Parameter.Create(param.OsirisType, param.Name)
    end

    return annotation
end

function _Annotation.__tostring(self)
    local lines = {}
    local paramNames = {}
    local signature

    -- Add params
    for _,param in ipairs(self.Parameters) do
        table.insert(paramNames, param.Name)
        table.insert(lines, tostring(param))
    end

    -- Add signature
    signature = string.format("function Osi.%s(%s) end", self.Name, Text.Join(paramNames, ", "))
    table.insert(lines, signature)

    return Text.Join(lines, "\n")
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the lua annotation type for an Osiris type.
---@param typeName string
---@return string
function Generator.GetLuaTypeForOsirisType(typeName)
    return Generator.OSIRIS_TYPE_TO_LUA_TYPE[typeName]
end

---Generates event annotations.
---@param storyHeaderPath path
---@param outputPath path? Defaults to `osi.lua`
function Generator.GenerateEventAnnotations(storyHeaderPath, outputPath)
    local file = IO.LoadFile(storyHeaderPath, "data", true)
    if not file then Generator:Error("GenerateEventAnnotations", "File not found") end
    local lines = Text.Split(file, "\n")
    local annotations = {}

    for _,line in ipairs(lines) do
        local symbolType, symbol, params = line:match(Generator.SYMBOL_PATTERN)

        if symbolType and symbolType == "event" then
            local paramObjects = {}
            params = string.gsub(params, ",", "")
            params = Text.Split(params, " ")

            for _,param in ipairs(params) do
                local paramType, paramName = param:match(Generator.PARAMETER_PATTERN)
                table.insert(paramObjects, _Parameter.Create(paramType, paramName))
            end

            table.insert(annotations, _Annotation.Create(symbolType, symbol, paramObjects))
        end
    end

    local outputFile = ""
    for _,annotation in ipairs(annotations) do
        outputFile = outputFile .. tostring(annotation) .. "\n\n"
    end
    IO.SaveFile(outputPath or "osi.lua", outputFile, true)
end
