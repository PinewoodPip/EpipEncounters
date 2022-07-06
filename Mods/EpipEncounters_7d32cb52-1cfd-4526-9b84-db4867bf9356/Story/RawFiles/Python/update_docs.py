from dataclasses import field
from importlib.resources import path
import os, sys, pathlib, re
import string
import random
from typing import Type

## TODO define absolute path to functions, ex. Inv - > Client.UI.PartyInventory
## Done? support different implementations across contexts
## TODO aliases
## TODO hide internal fields
## TODO auto-generate IDE helper
## TODO fix lack of spaces breaking it? probably from isFinishingParsing() usage

#MOD_ROOT = sys.argv[1]
#DOCS_ROOT = sys.argv[2]

DOCS_ROOT = r'C:\Users\Usuario\Documents\ActualDocuments\Dev\Docs\epip\docs'
MOD_ROOT = r'C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua'

LUA_IGNORE = {
    "ExtIdeHelpers.lua": True,
    "EpipIdeHelpers.lua": True,
}

# Remaps functions defined on local aliases to their absolute path in the mod. TODO
LIBRARY_PATHS = {
    # "Input": "Client.Input",
    "Inv": "PartyInventory",
}

EVENTS = {
    "Event" : True,
    "Hook" : True,
}

CONTEXT_SUFFIXES = {
    "ContextClient": "Client-only",
    "ContextServer": "Server-only",
    "EE": "EE-related",
    "RequireBothContexts": "Must be called on both contexts"
}

COMMENT_REGEX = re.compile("(^---.*)$")
FUNCTION_REGEX = re.compile("^function (?P<Namespace>[^ .:]+)(?P<SyntacticSugar>\.|:)(?P<Signature>\S+\(.*\))$")
TAGS_REGEX = re.compile("^---@meta (.*)$")
ALIAS_REGEX = re.compile("^---@alias (\S*) (.*)$")
EVENT_REGEX = re.compile("^---@class .*_(.*) : (.*)?$")
CLASS_REGEX = re.compile("^---@class (.*)$")
FIELD_REGEX = re.compile("^---@field (\S*) (.*)$")

DOC_TEMPLATE_REGEX2 = re.compile('^<doc (\w*)="(.*)">')
DOC_FIELDS_REGEX = re.compile('^<doc fields="(.*)">')
EMPTY_LINE_REGEX = re.compile("^ *$")

functions = {}
classes = {}
events = {}

def getTaggedFunctions(dictionary, tags):
    funcs = []

    for func in dictionary.values():
        if "Internal" not in func.tags:
            for tag in tags:
                if tag in func.tags:
                    funcs.append(func)
                    break

    return funcs

def enterCodeBlock(string:str):
    return string + "```lua\n"

def exitCodeBlock(string:str):
    return string + "```\n"

def updateFile(file_path:str):
    template = ""
    removing = False
    replacedSomething = False

    with open(file_path, "r") as f:
        for line in f.readlines():
            openMatch = DOC_TEMPLATE_REGEX.match(line)
            closeMatch = DOC_TEMPLATE_END_REGEX.match(line)

            if closeMatch:
                removing = False
            elif openMatch:
                removing = True
                replacedSomething = True
                template += line + "\n"

                # categories = openMatch.groups()[0].split(", ")
                libName = openMatch.groups()[0]
                symbolTypes = openMatch.groups()[1]
                symbolTypes = symbolTypes.split(",")

                template += gen.libraries[libName].export(symbolTypes)

                # taggedFuncs = getTaggedFunctions(functions, categories)

                # for func in taggedFuncs:
                #     template += "```lua\n"
                #     for line in func.lines:
                #         template += line + "\n"

                #     header = func.name

                #     suffixCount = 0
                #     for tag in CONTEXT_SUFFIXES:
                #         if tag in func.tags:
                #             if suffixCount == 0:
                #                 header += " -- "

                #             if suffixCount > 0:
                #                 header += ", "

                #             header += CONTEXT_SUFFIXES[tag]
                #             suffixCount += 1

                #     template += header + "\n"
                #     template += "```\n"

            # add original content
            if not removing:
                template += line

    if replacedSomething:
        with open(file_path, "w") as f:
            print("Updating " +  file_path)
            f.write(template)

# -----------------
# Metadata Classes
# -----------------

class Data:
    def __str__(self):
        return ""

# Comments  
class Comment(Data):
    def __init__(self, groups):
        self.comment = groups["Comment"]

    def __str__(self):
        return f"---{self.comment}"

class CommentedTag(Data):
    def __init__(self, groups):
        self.comment = groups["Comment"]

    def __str__(self):
        return f"---@{self.TAG} {self.comment}"

class TypedTag(Data):
    TAG = ""

    def __init__(self, groups):
        self.type = groups["Type"]
        self.comment = groups["Comment"]

    def __str__(self):
        return f"---@{self.TAG} {self.type} {self.comment}"

# Parameters
class Parameter(TypedTag):
    TAG = "param"

class Return(TypedTag):
    TAG = "return"

class ClassField(TypedTag):
    TAG = "field"

class Meta(CommentedTag):
    TAG = "meta"

# -----------------
# Symbol Classes
# -----------------

# A symbol is a collection of metadata.
class Symbol:
    def __init__(self, library:str, data:list, groups:list, lib):
        self.data = []
        self.library = lib
        
        self.setLibrary(library)
        self.addData(data)

    def isFinishedParsing(self, nextLine):
        return True
    
    def setLibrary(self, library):
        self.library = library

    def addData(self, data:list):
        # if type(data) == list:
        #     for entry in data:
        #         self.addData(entry)
        # else:
        #     self.data.append(data)
        for entry in data:
            self.data.append(entry)

    def __str__(self):
        pass

# For symbols, the line that defines them is passed as vararg(s)

class Function(Symbol):
    META_TAGS = {
        "ContextClient": "Client-only",
        "ContextServer": "Server-only",
        "EE": "EE-related",
        "RequireBothContexts": "Must be called on both contexts"
    }

    def __init__(self, library:str, data:list, groups:list, lib):
        self.comments = []
        self.parameters = []
        self.returnType = None
        self.signature = groups["Signature"]
        self.nameSpace = groups["Namespace"]
        self.syntacticSugar = groups["SyntacticSugar"]
        self.metaTags = []

        # Parse data
        super().__init__(library, data, groups, lib)
        
    def addData(self, data: list):
        super().addData(data)

        for entry in self.data:
            if type(entry) == Comment:
                self.comments.append(entry)
            elif type(entry) == Parameter:
                self.parameters.append(entry)
            elif type(entry) == Return:
                self.returnType = entry
            elif type(entry) == Meta:
                self.metaTags.append(entry)

    def __str__(self):
        output = ""

        for comment in self.comments:
            output += str(comment) + "\n"

        for param in self.parameters:
            output += str(param) + "\n"

        if self.returnType:
            output += str(self.returnType) + "\n"

        # if self.library:
        #     namespace = self.library.name

            # if self.library.absolutePath:
            #     namespace = self.library.absolutePath

        output += f"function {self.nameSpace}{self.syntacticSugar}{self.signature}"
        # else:
        #     output += "WRONG LIB DEF TODO"

        # append tags to signature
        if len(self.metaTags) > 0:
            output += " --"

            for i in range(len(self.metaTags)):
                output += self.metaTags[i].comment

                if i != len(self.metaTags) - 1:
                    output += ", "

        return output

class LibraryDefinition(Symbol):
    def __init__(self, library, data, groups, lib):
        self.name = groups["Library"]
        self.context = groups["Context"]
        self.absolutePath = groups["AbsolutePath"]

        if "LocalName" in groups:
            self.localName = groups["LocalName"]
        else:
            self.localName = None

        super().__init__(library, data, groups, lib)

    def __str__(self): # Library definition tags do not show
        return f""

class Class(Symbol):
    def __init__(self, library, data, groups, lib):
        self.className = groups["Class"]
        self.comment = None

        super().__init__(library, data, groups, lib)

    def addData(self, data):
        for entry in data:
            if type(entry) == Comment:
                self.comment = entry
            else:
                self.data.append(entry)

    def isFinishedParsing(self, nextLine):
        return type(nextLine) != ClassField and nextLine != None and nextLine != "\n" and nextLine != ""

    def __str__(self):
        output = ""
        if self.comment:
            output = str(self.comment) + "\n"

        output += f"---@class {self.className}" + "\n"

        for field in self.data:
            output += str(field) + "\n"

        return output

class Listenable(Symbol):
    TAG = "listenable"

    def __init__(self, library, data, groups, lib):
        self.className = groups["Class"]
        self.event = groups["Event"]
        self.comments = []
        self.fields = []

        super().__init__(library, data, groups, lib)

    def addData(self, data):
        super().addData(data)

        for entry in data:
            if type(entry) == Comment:
                self.comments.append(entry)
            elif type(entry) == ClassField:
                self.fields.append(entry)

    def isFinishedParsing(self, nextSymbol):
        if nextSymbol:
            if type(nextSymbol) == Comment:
                return len(self.comments) > 0

        return False

    def __str__(self):
        output = ""

        for comment in self.comments:
            output += str(comment) + "\n"

        output += f"---@{self.TAG} {self.event}" + "\n"

        # TODO make fancier?
        for field in self.fields:
            output += str(field) + "\n"

        return output

class Event(Listenable):
    TAG = "event"

class Hook(Listenable):
    TAG = "hook"

# ------------

class Matcher():
    def __init__(self, regex, classType):
        self.regex = regex
        self.classType = classType

DATA_MATCHERS = [
    Matcher(re.compile("^---@param (?P<Type>\S*) (?P<Comment>.*)$"), Parameter),
    Matcher(re.compile("^---@return (?P<Type>\S*) ?(?P<Comment>.*)$"), Return),
    Matcher(re.compile("^---@field (?P<Type>\S*) ?(?P<Comment>.*)$"), ClassField),
    Matcher(re.compile("^---@meta (?P<Comment>.*)$"), Meta),
    Matcher(re.compile("^---(?P<Comment>[^-@].+)$"), Comment),
]

SYMBOL_MATCHERS = [
    Matcher(FUNCTION_REGEX, Function),
    Matcher(re.compile("^---@meta Library: (?P<Library>\S*), (?P<Context>[^,]+)(, )?(?P<AbsolutePath>\S+)?(, )?(?P<LocalName>\S+)?$"), LibraryDefinition),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Hook_(?P<Event>\S*) : Hook$"), Hook),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Event_(?P<Event>\S*) : Event$"), Event),
    Matcher(re.compile("^---@class (?P<Class>.+)$"), Class),
]

DOC_TEMPLATE_REGEX = re.compile('^<epip class="(.+)" symbols="(.+)">')
DOC_TEMPLATE_END_REGEX = re.compile('^<\/epip>')

class Library:
    def __init__(self, name, context, absolutePath):
        self.name = name
        self.context = context
        self.symbols = []
        self.absolutePath = absolutePath

    def addSymbol(self, symbol:Symbol):
        symbol.library = self # TODO fix properly
        self.symbols.append(symbol)

    def __str__(self):
        output = "Library: " + self.name + "\n"
        output += "Context: " + self.context + "\n"

        for symbol in self.symbols:
            output += "Symbol: " + "\n"
            output += str(symbol) + "\n\n"
        
        return output

    def export(self, symbolTypes:list):
        lines = "```lua\n"

        for symbol in self.symbols:
            if len(symbolTypes) == 0 or type(symbol).__name__ in symbolTypes:
                lines += str(symbol) + "\n\n"

        return lines + "```\n"


class DocGenerator:
    libraries = {}

    def getDataOnLine(self, line):
        data = None

        for matcher in DATA_MATCHERS:
            match = matcher.regex.match(line)

            if match:
                dataType = matcher.classType
                data = dataType(match.groupdict())
                break

        return data

    def getSymbolOnLine(self, line, library):
        symbol = None

        for matcher in SYMBOL_MATCHERS:
            match = matcher.regex.match(line)

            if match:
                symbolType = matcher.classType
                symbol = symbolType(None, [], match.groupdict(), library) # TODO
                break

        return symbol

    def getSymbol(self, lines, library):
        dataStack = []
        consumedLines = 0
        symbol = None

        for line in lines:
            match = None

            lineSymbol = self.getSymbolOnLine(line, library)

            if lineSymbol and symbol:
                # found new symbol, stopping data search
                break
            elif lineSymbol and not symbol: # found first symbol, add data found until now
                symbol = lineSymbol
                symbol.addData(dataStack)
                dataStack = []
            else: # search for data
                lineData = self.getDataOnLine(line)

                if lineData:
                    if symbol and symbol.isFinishedParsing(lineData):
                        break
                    elif symbol:
                        symbol.addData([lineData])
                    else:
                        dataStack.append(lineData)

            consumedLines += 1

        # consume lines
        for i in range(consumedLines):
            lines.pop(0)

        # add remaining data
        # if symbol:
        #     symbol.addData(dataStack)

        return symbol

    def findLibrary(self, lines:list):
        # We assume it's the first one
        meta = self.getSymbol(lines, None)

        # And if it isn't, I guess the file does not define any
        if type(meta) != LibraryDefinition:
            meta = None

        return meta

    def parseLuaFile(self, filePath:str):

        with open(filePath, "r") as f:
            lines = f.readlines()
            library = None

            # Find library name first
            # TODO do this some other way? automatic from table declaration?
            libraryDefinition = self.findLibrary(lines)

            if libraryDefinition:
                if libraryDefinition.name in self.libraries:
                    library = self.libraries[libraryDefinition.name]
                else:
                    library = Library(libraryDefinition.name, libraryDefinition.context, libraryDefinition.absolutePath)
                    self.libraries[library.name] = library

                while len(lines) > 0:
                    symbol = self.getSymbol(lines, library)

                    if symbol:
                        library.addSymbol(symbol)
    
# --------------------------------------
gen = DocGenerator()

# QUICK TEST
# gen.parseLuaFile(r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\UI\GiftBagContent.lua")

# print(gen.libraries["GiftBagContentUI"])

# Parse lua
for root_path, dirs, files in os.walk(MOD_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".lua":
            gen.parseLuaFile(os.path.join(root_path, file_name))

# Update docs
for root_path, dirs, files in os.walk(DOCS_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
            updateFile(os.path.join(root_path, file_name))