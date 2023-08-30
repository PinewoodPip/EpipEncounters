
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
    OUT_PARAMETER_PATTERN = "%[out%]",
    DEFAULT_OUTPUT_PATH = "IDEHelpers/Osiris.lua",
    DEFAULT_HEADER_PATH = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/story_header.div",
}
Epip.RegisterFeature("OsirisIDEAnnotationGenerator", Generator)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias OsirisBuiltInType "syscall"|"sysquery"|"query"|"event"|"call"

---@class Features.OsirisIDEAnnotationGenerator.Request
---@field OutputPath path? Defaults to `DEFAULT_OUTPUT_PATH`.
---@field HeaderPath path? Relative to data directory. Defaults to `DEFAULT_HEADER_PATH`.
---@field IncludeEvents boolean? Defaults to `false`.

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

    return string.format("---@param %s %s", self.Name, luaType)
end

---@class Feature_OsirisIDEAnnotationGenerator_Annotation
---@field SymbolType OsirisBuiltInType
---@field Name string
---@field Parameters Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]
---@field ReturnTypes Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]
local _Annotation = {}

---Creates an annotation object.
---@param symbolType OsirisBuiltInType
---@param name string
---@param params Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]
---@param returnTypes Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]?
---@return Feature_OsirisIDEAnnotationGenerator_Annotation
function _Annotation.Create(symbolType, name, params, returnTypes)
    ---@type Feature_OsirisIDEAnnotationGenerator_Annotation
    local annotation = {
        SymbolType = symbolType,
        Name = name,
        Parameters = params,
        ReturnTypes = returnTypes or {},
    }
    OOP.SetMetatable(annotation, _Annotation)

    return annotation
end

function _Annotation.__tostring(self)
    local lines = {}
    local paramNames = {}
    local signature
    local returnNames = {} ---@type string[]
    local returnTypes = {} ---@type string[]

    -- Add params
    for _,param in ipairs(self.Parameters) do
        table.insert(paramNames, param.Name)
        table.insert(lines, tostring(param))
    end

    -- Add return values
    for _,returnType in ipairs(self.ReturnTypes) do
        table.insert(returnNames, returnType.Name)
        table.insert(returnTypes, Generator.GetLuaTypeForOsirisType(returnType.OsirisType))
    end

    if self.ReturnTypes[1] then
        table.insert(lines, string.format("---@return %s -- %s", Text.Join(returnTypes, ", "), Text.Join(returnNames, ", ")))
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
---@param request Features.OsirisIDEAnnotationGenerator.Request
function Generator.GenerateEventAnnotations(request)
    request.HeaderPath = request.HeaderPath or Generator.DEFAULT_HEADER_PATH
    request.OutputPath = request.OutputPath or Generator.DEFAULT_OUTPUT_PATH

    local file = IO.LoadFile(request.HeaderPath, "data", true)
    if not file then Generator:Error("GenerateEventAnnotations", "File not found") end

    local lines = Text.Split(file, "\n")
    local annotations = {}
    for _,line in ipairs(lines) do
        local symbolType, symbol, params = line:match(Generator.SYMBOL_PATTERN)

        if symbolType then
            local paramObjects = {}
            params = string.gsub(params, ",", "")
            params = Text.Split(params, " ")

            local returnTypes = {} ---@type Feature_OsirisIDEAnnotationGenerator_Annotation_Parameter[]

            for _,param in ipairs(params) do
                local paramType, paramName = param:match(Generator.PARAMETER_PATTERN)
                local isReturn = param:match(Generator.OUT_PARAMETER_PATTERN)
                local paramObject = _Parameter.Create(paramType, paramName)

                if isReturn then
                    table.insert(returnTypes, paramObject)
                else
                    table.insert(paramObjects, paramObject)
                end
            end

            table.insert(annotations, _Annotation.Create(symbolType, symbol, paramObjects, returnTypes))
        end
    end

    local outputFile = "---@meta\n\n"
    for _,annotation in ipairs(annotations) do
        outputFile = outputFile .. tostring(annotation) .. "\n\n"
    end
    IO.SaveFile(request.OutputPath, outputFile, true)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for console command to generate annotations.
Ext.RegisterConsoleCommand("osirisannotations", function (_, outputPath, includeEvents, headerPath)
    ---@type Features.OsirisIDEAnnotationGenerator.Request
    local request = {
        IncludeEvents = includeEvents,
        OutputPath = outputPath,
        HeaderPath = headerPath,
    }
    Generator.GenerateEventAnnotations(request)
    print("Generated annotations")
end)