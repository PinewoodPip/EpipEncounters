
local Set = DataStructures.Get("DataStructures_Set")

---@class Features.IDEAnnotations : Feature
local Generator = {
    DEFAULT_PATH = "IDEHelpers/Ext.lua",
    FIELD_TYPES = Set.Create({
        "Array",
        "Integer",
        "Float",
        "Boolean",
        "String",
        "Tuple",
        "Map",
        "Any",
    }),

    TYPE_NAME_TRANSLATION = {
        ["bool"] = "boolean",
        ["uint32"] = "uint32",
        ["vec2"] = "vec2",
        ["vec4"] = "vec4",
        ["float"] = "number",
    },

    BASIC_ALIASES = {
        ["ComponentHandle"] = "userdata",
        ["EntityHandle"] = "userdata",
        ["FixedString"] = "string",
        ["Guid"] = "string",
        ["IggyInvokeDataValue"] = "boolean|number|string",
        ["NetId"] = "integer",
        ["Path"] = "string",
        ["PersistentRef"] = "any",
        ["PersistentRegistryEntry"] = "any",
        ["Ref"] = "any",
        ["RegistryEntry"] = "any",
        ["TemplateHandle"] = "number",
        ["UserId"] = "integer",
        ["UserReturn"] = "any",
        ["int16"] = "integer",
        ["int32"] = "integer",
        ["int64"] = "integer",
        ["int8"] = "integer",
        ["uint16"] = "integer",
        ["uint32"] = "integer",
        ["uint64"] = "integer",
        ["uint8"] = "integer",
        ["Version"] = "int32[]",
        ["ivec2"] = "int32[]",
        ["mat3"] = "number[]",
        ["mat4"] = "number[]",
        ["vec2"] = "number[]",
        ["vec3"] = "number[]",
        ["vec4"] = "number[]",
        ["Mat4x3"] = "number[]", -- TODO confirm
        ["STDString"] = "string",
        ["STDWString"] = "string",
        ["CString"] = "string",
        ["Double"] = "number",
        ["I16vec2"] = "number[]",
        ["EsvTrigger"] = "Trigger",
        ["EclTrigger"] = "Trigger",
        ["Glmvec3"] = "number[]",
        ["Quat"] = "unknown", -- TODO
        ["ObjectHandle"] = "userdata",
    },

    _ExtModules = nil, ---@type string[]
}
Epip.RegisterFeature("IDEAnnotations", Generator)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class DocGenerator.Writer
---@field Lines string[]
local Writer = {}

---@return DocGenerator.Writer
function Writer.Create()
    ---@type DocGenerator.Writer
    local instance = {
        Lines = {},
    }
    Inherit(instance, Writer)
    return instance
end

---@param line string? Defaults to "\n"
function Writer:AddLine(line)
    table.insert(self.Lines, line or "\n")
end

---Writes multiple lines in order.
---@param lines string[]
function Writer:AddLines(lines)
    for _,line in ipairs(lines) do
        self:AddLine(line)
    end
end

function Writer:AddMultilineCode(str)
    self:AddLine("```lua\n" .. str .. "\n```")
end

---@param otherWriter DocGenerator.Writer
function Writer:Merge(otherWriter)
    for _,line in ipairs(otherWriter.Lines) do
        self:AddLine(line)
    end
end

function Writer.__tostring(self)
    return Text.Join(self.Lines, "\n")
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Generates annotations into an output file.
---@param filename path? Defaults to `DEFAULT_PATH`.
function Generator.Generate(filename)
    local types = Ext.Types.GetAllTypes()
    local writer = Writer.Create()
    filename = filename or Generator.DEFAULT_PATH

    local nativeData = Ext.Json.Parse(Ext.Utils.Include(nil, "builtin://Libs/IdeHelpersNativeData.lua"))
    IO.SaveFile("Native.json", nativeData)

    Generator._FunctionFixes = Ext.Utils.Include(nil, "builtin://Libs/HelpersGenerator/FunctionFixes.lua").Regular

    Generator._NativeData = nativeData
    Generator._ExtModules = {}
    Generator._FieldOverrides = RequestScriptLoad("Epip/IDEAnnotations/Overrides/Fields.lua")

    -- Header and globals
    writer:AddLine("---@meta\n")
    writer:AddLine("Ext = {}")
    writer:AddLine("Game = {}\n")

    -- Write aliases
    Generator._WriteBasicAliases(writer)

    -- writer:AddLine(Ext.Utils.Include(nil, "builtin://Libs/HelpersGenerator/CustomEntries.lua").Misc[1])

    for _,typeName in ipairs(types) do
        local type = Ext.Types.GetTypeInfo(typeName)

        if type.Kind == "Object" then
            Generator._AnnotateObject(writer, type)
        elseif type.Kind == "Module" then
            Generator._AnnotateModule(writer, type)
        elseif type.Kind == "Enumeration" then
            Generator._AnnotateEnum(writer, type)
        elseif not Generator.FIELD_TYPES:Contains(type.Kind) then
            Generator:LogWarning("Unknown type kind", type.Kind)
        end
    end

    local customTypeEntries = Ext.Utils.Include(nil, "builtin://Libs/HelpersGenerator/CustomTypeEntries.lua")
    customTypeEntries.Trigger.After = nil -- Bruh
    for _,v in pairs(customTypeEntries) do
        if v.Before then
            writer:AddLine(v.Before)
        end
        if v.After then
            writer:AddLine(v.After)
        end
    end

    local output = tostring(writer)
    IO.SaveFile(filename, output, true)
end

---Annotates a module.
---@param writer DocGenerator.Writer
---@param module TypeInformation
function Generator._AnnotateModule(writer, module)
    local moduleName = module.NativeName

    Generator._AnnotateObject(writer, module)

    local functions = {} ---@type {Name:string, TypeInfo:TypeInformation}[]
    for memberName,member in pairs(module.Methods) do
        table.insert(functions, {Name = memberName, TypeInfo = member})
    end
    table.sort(functions, function (a, b)
        return a.Name < b.Name
    end)

    -- Assign to Ext table
    writer:AddLine(string.format("Ext.%s = %s", module.NativeName, Generator._GetLocalName(Generator._GetClassName(module))))

    table.insert(Generator._ExtModules, moduleName)
end

---Generates annotations for an Object.
---@param writer DocGenerator.Writer
---@param object TypeInformation
function Generator._AnnotateObject(writer, object)
    local parent = object.ParentType and Generator._GetTypeName(object.ParentType) or nil
    local className = Generator._GetClassName(object)
    local header
    if parent then
        header = string.format("---@class %s : %s", className, parent)
    else
        header = string.format("---@class %s", className)
    end
    writer:AddLine(header)

    Generator._AnnotateFields(writer, className, object.Members)

    if not table.isempty(object.Methods) or object.Kind == "Module" then -- Cannot use next()
        writer:AddLine(string.format("local %s = {}\n", Generator._GetLocalName(className)))

        for name,method in pairs(object.Methods) do
            Generator._AnnotateMethod(writer, object.TypeName, name, method, object)
        end
    end

    writer:AddLine("")
end

---Generates annotations for an Enumeration.
---@param writer DocGenerator.Writer
---@param enum TypeInformation
function Generator._AnnotateEnum(writer, enum)
    local aliases = {} ---@type {Name:string, Index:integer}[]
    for k,v in pairs(enum.EnumValues) do
        table.insert(aliases, {
            Name = k,
            Index = v,
        })
    end
    table.sort(aliases, function (a, b)
        return a.Index < b.Index
    end)
    local aliasAnnotations = {} ---@type string
    for _,alias in ipairs(aliases) do
        table.insert(aliasAnnotations, string.format("---|\"%s\" -- %s", alias.Name, alias.Index))
    end

    writer:AddLine(string.format("---@alias %s string|integer\n%s\n", enum.TypeName, Text.Join(aliasAnnotations, "\n")))
end

---Annotates fields of a class.
---@param writer DocGenerator.Writer
---@param className string Parsed class name.
---@param members table<string, TypeInformation>
function Generator._AnnotateFields(writer, className, members)
    local memberAnnotations = {} ---@type string[]
    for fieldName,field in pairs(members) do
        table.insert(memberAnnotations, Generator._AnnotateField(className, fieldName, field))
    end
    table.sort(memberAnnotations)
    writer:AddLines(memberAnnotations)
end

---Annotates a field.
---@param className string Parsed class name.
---@param fieldName string
---@param type TypeInformation
---@return string
function Generator._AnnotateField(className, fieldName, type)
    local comment = ""
    local typeName = Generator._GetTypeName(type)
    local fieldOverrides = Generator._FieldOverrides[className] and Generator._FieldOverrides[className][fieldName] or nil
    if fieldOverrides then
        comment = fieldOverrides.Comment and (" " .. fieldOverrides.Comment) or comment
        typeName = fieldOverrides.Type or typeName
        -- Overriding field name is not supported as it doesn't make sense.
    end

    local annotation = string.format("---@field %s %s%s", fieldName, typeName, comment)
    return annotation
end

---@param module TypeInformation
local function GetNativeData(module)
    local className = module.TypeName
    local data = Generator._NativeData.modules[className] or Generator._NativeData.classes[className]
    data = data or Generator._NativeData.modules["dse::" .. className] or Generator._NativeData.classes["dse::" .. className]
    data = data or Generator._NativeData.modules[module.NativeName] or Generator._NativeData.classes[module.NativeName]
    return data
end

---@class Features.IDEAnnotations.Function.Parameter
---@field Name string
---@field Type string
---@field Comment string? TODO

---@class Features.IDEAnnotations.Function
---@field Params Features.IDEAnnotations.Function.Parameter[]
---@field ReturnValues Features.IDEAnnotations.Function.Parameter[]
---@field IsInstanceMethod boolean
---@field Comment string?

---@param module TypeInformation
---@param type TypeInformation
---@param methodName string
---@return Features.IDEAnnotations.Function
local function GetFunctionData(module, type, methodName)
    ---@type Features.IDEAnnotations.Function
    local data = {
        IsInstanceMethod = module.Kind == "Object",
        Params = {},
        ReturnValues = {},
    }

    local nativeData = GetNativeData(module)
    local funcData = nil
    if nativeData and nativeData.functions then
        funcData = nativeData.functions[methodName] or nativeData.functions["Lua" .. methodName]
    end
    if not funcData and nativeData and nativeData.methods then
        funcData = nativeData.methods[methodName] or nativeData.methods["Lua" .. methodName]
    end

    -- Use comment from source
    if funcData and funcData.description ~= "" then
        data.Comment = funcData.description:gsub("\n", "<br>")
        data.Comment = data.Comment:gsub("\r", "<br>")
    end

    if type.Params[1] then
        for i,param in ipairs(type.Params) do
            local paramName = funcData and funcData.params[i] and funcData.params[i].name or "param" .. tostring(i)
            local paramType = Generator._GetTypeName(param)
            table.insert(data.Params, {Name = paramName, Type = paramType}) -- TODO comments
        end

    elseif funcData then
        for i,param in ipairs(funcData.params) do
            table.insert(data.Params, {Name = funcData and funcData.params[i].name or "param" .. tostring(i), Type = Generator._GetTypeName(param.type or "")}) -- TODO comments
        end
    end

    for i,val in ipairs(type.ReturnValues) do
        data.ReturnValues[i] = {Name = "ret" .. tostring(i), Type = Generator._GetTypeName(val.TypeName)}
    end

    -- Apply overrides
    local moduleName = Generator._GetLocalName(Generator._GetClassName(module))
    local moduleOverrides = Generator._FunctionFixes[moduleName]
    local funcOverrides = moduleOverrides and moduleOverrides[methodName] or nil

    if funcOverrides then
        if funcOverrides.Params then
            data.Params = {}
            for i,param in ipairs(funcOverrides.Params) do
                data.Params[i] = {
                    Name = param.name,
                    Type = param.arg,
                    Comment = param.description,
                }
            end
        end
        if funcOverrides.Return then
            data.ReturnValues = {}
            for i,returnValue in ipairs(funcOverrides.Return) do
                local returnType, returnName = returnValue:match("^.- .-$")
                data.ReturnValues[i] = {
                    Name = returnName,
                    Type = returnType or returnValue,
                }
            end
        end
    end

    return data
end

---Annotates a method.
---@param writer DocGenerator.Writer
---@param _ string
---@param methodName string
---@param type TypeInformation
---@param module TypeInformation
function Generator._AnnotateMethod(writer, _, methodName, type, module)
    local data = GetFunctionData(module, type, methodName)

    if data.Comment then
        writer:AddLine(string.format("---%s", data.Comment))
    end

    for _,param in ipairs(data.Params) do
        writer:AddLine(string.format("---@param %s %s", param.Name, param.Type))
    end

    local inlineParams = {} ---@type string[]
    for i,param in ipairs(data.Params) do
        inlineParams[i] = param.Name
    end

    if data.ReturnValues[1] then
        local returnValues = {} ---@type string[]
        for i,_ in ipairs(data.ReturnValues) do
            returnValues[i] = data.ReturnValues[i].Type
        end
        writer:AddLine(string.format("---@return %s", Text.Join(returnValues, ", ")))
    end

    writer:AddLine(string.format("function %s%s%s(%s) end", Generator._GetLocalName(Generator._GetClassName(module)), data.IsInstanceMethod and ":" or ".", methodName, Text.Join(inlineParams, ", ")))
    writer:AddLine("\n")
end

---Returns the name of a class in the annotation format.
---@param typeInfo TypeInformation|string
---@return string
function Generator._GetClassName(typeInfo)
    local typeName = type(typeInfo) == "string" and typeInfo or typeInfo.TypeName
    local name, _ = string.gsub(typeName, "::", "")
    name = name:sub(1, 1):upper() .. name:sub(2)
    -- Consider generic types as separate classes
    if typeName:match("<.+>") then
        local genericTypeName = typeName:match("<([^>]+)>")
        name = name:gsub("<([^>]+)>", "_" .. Text.Capitalize(genericTypeName))
        name = Generator._GetClassName(name)
    end
    return name
end

---Returns the name of a type in the annotation format.
---@param typeInfo TypeInformation|string
---@return string
function Generator._GetTypeName(typeInfo)
    local typeName = typeInfo
    if type(typeInfo) ~= "string" then -- TypeInformation overload.
        typeName = typeInfo.TypeName
    end
    local name = Generator.TYPE_NAME_TRANSLATION[typeName]

    if Generator.BASIC_ALIASES[typeName] then -- Use alias name rather than raw type
        name = typeName
    elseif typeName:match("^Optional<") then -- Optional types
        name = Generator._GetTypeName(typeName:match("^Optional<([^>]+)>$")) .. "?"
    elseif typeName:match("^Array") then -- List-like types
        name = Generator._GetTypeName(typeName:match("^Array<(.+)>$")) .. "[]"
    elseif typeName:match("^Map") then -- Table-like types
        local keyType, valueType = typeName:match("^Map<([^,]+), (.+)>$")
        keyType = Generator._GetTypeName(keyType)
        valueType = Generator._GetTypeName(valueType)

        name = string.format("table<%s, %s>", keyType, valueType)
    elseif not name then -- Only apply class formatting if the type is not basic and is not an alias
        name = Generator._GetClassName(typeInfo)
    end

    if name == "" then
        name = "unknown"
    end

    return name
end

---Converts a module name to a valid local variable name.
---@param name string
---@return string
function Generator._GetLocalName(name)
    name = name:gsub("%.", "_")
    name = name:gsub("^Module_", "Ext_")
    return name
end

---Writes annotations for basic aliases.
---@param writer DocGenerator.Writer
function Generator._WriteBasicAliases(writer)
    local aliases = {} ---@type string

    writer:AddLine("-- Basic aliases\n")

    for typeName, aliasedType in pairs(Generator.BASIC_ALIASES) do
        table.insert(aliases, string.format("---@alias %s %s", typeName, aliasedType))
    end
    table.sort(aliases)

    writer:AddLines(aliases)

    writer:AddLine()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to generate from a console command.
Ext.RegisterConsoleCommand("ideannotations", function (_, filename)
    Generator.Generate(filename)
end)