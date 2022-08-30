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
    def __init__(self, library:str, data:list, groups:list):
        self.data = []

        self.addData(data)

    def getLibraryID(self) -> str:
        return "_none"

    def isFinishedParsing(self, nextLine):
        return True

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

    def __init__(self, library:str, data:list, groups:list):
        self.comments = []
        self.parameters = []
        self.returnType = None
        self.signature = groups["Signature"]
        self.nameSpace = groups["Namespace"]
        self.syntacticSugar = groups["SyntacticSugar"]
        self.metaTags = []

        # Parse data
        super().__init__(library, data, groups)

    def getLibraryID(self) -> str:
        return self.nameSpace # TODO translate to global
        
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

class Class(Symbol):
    def __init__(self, library, data, groups):
        self.className = groups["Class"]
        self.comment = None

        super().__init__(library, data, groups)

    def getLibraryID(self) -> str:
        return self.className

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

    def __init__(self, library, data, groups):
        self.className = groups["Class"]
        self.event = groups["Event"]
        self.comments = []
        self.fields = []

        super().__init__(library, data, groups)

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
    Matcher(re.compile("^---@class (?P<Class>\S*)_Hook_(?P<Event>\S*) : Hook$"), Hook),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Event_(?P<Event>\S*) : Event$"), Event),
    Matcher(re.compile("^---@class (?P<Class>.+)$"), Class),
]

DOC_TEMPLATE_REGEX = re.compile('^<epip class="(.+)" symbols="(.+)">')
DOC_TEMPLATE_END_REGEX = re.compile('^<\/epip>')

class Library:
    def __init__(self, name):
        self.name = name
        # self.context = context
        self.symbols = []
        self.absolutePath = "TODO_AbsolutePath"

    def addSymbol(self, symbol:Symbol):
        symbol.library = self # TODO fix properly
        self.symbols.append(symbol)

    def __str__(self):
        output = "Library: " + self.name + "\n"
        # output += "Context: " + self.context + "\n"

        for symbol in self.symbols:
            output += "Symbol: " + type(symbol).__name__ + "\n"
            output += "Library: " + self.name + "\n"
            output += str(symbol) + "\n\n"
        
        return output

    def export(self, symbolTypes:list):
        lines = "```lua\n"

        for symbol in self.symbols:
            if len(symbolTypes) == 0 or type(symbol).__name__ in symbolTypes:
                lines += str(symbol) + "\n\n"

        return lines + "```\n"


class DocParser:
    def __init__(self, file_name) -> None:
        self.file_name = file_name
        self.file = open(file_name, "r")
        self.lines = self.file.readlines()
        self.symbolsPerLibrary = {}

        self.Parse()

    def Parse(self) -> None:
        while not self.isFinished():
            symbol = self.getSymbol()

            libraryName = symbol.getLibraryID()
            if libraryName not in self.symbolsPerLibrary:
                self.symbolsPerLibrary[libraryName] = []

            self.symbolsPerLibrary[libraryName].append(symbol)

    def getDataOnLine(self, line):
        data = None

        for matcher in DATA_MATCHERS:
            match = matcher.regex.match(line)

            if match:
                dataType = matcher.classType
                data = dataType(match.groupdict())
                break

        return data

    def getSymbolOnLine(self, line:str):
        symbol = None

        for matcher in SYMBOL_MATCHERS:
            match = matcher.regex.match(line)

            if match:
                symbolType = matcher.classType
                symbol = symbolType(None, [], match.groupdict()) # TODO
                break

        return symbol

    def getSymbol(self) -> Symbol:
        metadata = []
        lineIndex = 0
        foundSymbol = None

        while lineIndex < len(self.lines):
            line = self.lines[lineIndex]

            lineSymbol = self.getSymbolOnLine(line)

            # Exit if we found a second symbol.
            if lineSymbol and foundSymbol:
                break
            elif lineSymbol: # Add metadata found until now
                foundSymbol = lineSymbol
                foundSymbol.addData(metadata)
            else: # Search for metadata
                lineData = self.getDataOnLine(line)

                if lineData:
                    # Break if we found metadata intended for another symbol
                    if foundSymbol and foundSymbol.isFinishedParsing(lineData):
                        break
                    elif foundSymbol:
                        foundSymbol.addData([lineData])
                    else:
                        metadata.append(lineData)

            lineIndex += 1

        # Consume lines
        self.lines = self.lines[lineIndex+1::]

        return foundSymbol

    def isFinished(self):
        return len(self.lines) == 0

class DocGenerator:
    libraries = {}

    def parseLuaFile(self, filePath:str):
        with open(filePath, "r") as f:
            parser = DocParser(filePath)
            library = None
            
            for key in parser.symbolsPerLibrary:
                if key not in self.libraries:
                    library = Library(key)
                    self.libraries[key] = library
                else:
                    library = self.libraries[key]

                for symbol in parser.symbolsPerLibrary[key]:
                    library.addSymbol(symbol)
    
# --------------------------------------
gen = DocGenerator()

# QUICK TEST
gen.parseLuaFile(r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\Utilities\Text.lua")
gen.parseLuaFile(r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\Utilities\Color.lua")

# print(gen.libraries["_none"])
print(gen.libraries["Text"])
print(gen.libraries["Color"])
print(gen.libraries["RGBColor"])

# Parse lua
for root_path, dirs, files in os.walk(MOD_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".lua" and file_name == "Text.lua":
            # gen.parseLuaFile(os.path.join(root_path, file_name))
            pass

# Update docs
for root_path, dirs, files in os.walk(DOCS_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
            # updateFile(os.path.join(root_path, file_name))
            pass