from dataclasses import field
from importlib.resources import path
from msilib import datasizemask
import os, sys, pathlib, re
import random
from typing import Type

## TODO define absolute path to functions, ex. Inv - > Client.UI.PartyInventory
## Done? support different implementations across contexts
## TODO aliases
## DONE classes and fields
## TODO hide internal fields
## TODO auto-generate IDE helper

#MOD_ROOT = sys.argv[1]
#DOCS_ROOT = sys.argv[2]

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
FUNCTION_REGEX = re.compile("^(?P<Signature>function .*)$")
TAGS_REGEX = re.compile("^---@meta (.*)$")
ALIAS_REGEX = re.compile("^---@alias (\S*) (.*)$")
EVENT_REGEX = re.compile("^---@class .*_(.*) : (.*)?$")
CLASS_REGEX = re.compile("^---@class (.*)$")
FIELD_REGEX = re.compile("^---@field (\S*) (.*)$")

DOC_TEMPLATE_REGEX2 = re.compile('^<doc (\w*)="(.*)">')
DOC_TEMPLATE_REGEX = re.compile('^<doc lib="(.*)">')
DOC_TEMPLATE_END_REGEX = re.compile('<\/doc>')
DOC_FIELDS_REGEX = re.compile('^<doc fields="(.*)">')
EMPTY_LINE_REGEX = re.compile("^ *$")

functions = {}
classes = {}
events = {}
# aliases = []

# Unnecessary to automate for now
# def parseAliases(file_path:str):
#     with open(file_path, "r") as f:
#         for line in f.readlines():
#             aliasMatch = ALIAS_REGEX.match(line)

#             if aliasMatch:
#                 aliases.append()

class Function:
    def __init__(self):
        self.lines = []
        self.tags = {}
        self.funType = "Function"

    def addLine(self, line):
        self.lines.append(line.replace("\n", ""))

    def addLines(self, lines):
        for line in lines:
            self.addLine(line)

    def setName(self, name):
        self.name = name
    
    def addTag(self, tag):
        self.tags[tag] = True

    def removeTag(self, tag):
        if tag in self.tags:
            del self.tags[tag]

    def setType(self, funType):
        self.type = funType

# def cleanFile(file_path:str):
#     template = ""
#     removing = False

#     with open(file_path, "r") as f:
#         for line in f.readlines():
#             openMatch = DOC_TEMPLATE_REGEX.match(line)
#             closeMatch = DOC_TEMPLATE_END_REGEX.match(line)

#             if closeMatch:
#                 removing = False
#             elif openMatch:
#                 removing = True
#                 template += line + "\n"

#             if not removing:
#                 template += line + "\n"

#     return template

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
    categories = []
    removing = False
    replacedSomething = False

    with open(file_path, "r") as f:
        for line in f.readlines():
            openMatch = DOC_TEMPLATE_REGEX.match(line)
            openMatch2 = DOC_TEMPLATE_REGEX2.match(line)
            fieldMatch = DOC_FIELDS_REGEX.match(line)
            closeMatch = DOC_TEMPLATE_END_REGEX.match(line)

            if closeMatch:
                removing = False
            elif openMatch2 and openMatch2.groups()[0] == "events":
                removing = True
                replacedSomething = True

                template += line + "\n"

                categories = openMatch2.groups()[1].split(", ")

                for tag in categories:
                    evs = getTaggedFunctions(events, [tag])
                    for event in evs:
                        template = enterCodeBlock(template)
                        for line in event.lines:
                            template += line + "\n"

                        template = exitCodeBlock(template)

            elif fieldMatch: # Show a classes's fields
                removing = True
                replacedSomething = True
                template += line + "\n"

                categories = fieldMatch.groups()[0].split(", ")

                template = enterCodeBlock(template)
                for tag in categories:
                    luaClass = classes[tag]

                    for line in luaClass["Lines"]:
                        template += line + "\n"

                template = exitCodeBlock(template)

            elif openMatch:
                removing = True
                replacedSomething = True
                template += line + "\n"

                categories = openMatch.groups()[0].split(", ")

                taggedFuncs = getTaggedFunctions(functions, categories)

                for func in taggedFuncs:
                    template += "```lua\n"
                    for line in func.lines:
                        template += line + "\n"

                    header = func.name

                    suffixCount = 0
                    for tag in CONTEXT_SUFFIXES:
                        if tag in func.tags:
                            if suffixCount == 0:
                                header += " -- "

                            if suffixCount > 0:
                                header += ", "

                            header += CONTEXT_SUFFIXES[tag]
                            suffixCount += 1

                    template += header + "\n"
                    template += "```\n"

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

    def __init__(self, library:str, data:list, groups:list):
        self.comments = []
        self.parameters = []
        self.returnType = None
        self.signature = groups["Signature"]
        self.metaTags = []

        # Parse data
        super().__init__(library, data, groups)
        
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

        output += self.signature

        # append tags to signature
        if len(self.metaTags) > 0:
            output += " --"

            for i in range(len(self.metaTags)):
                output += self.metaTags[i].comment

                if i != len(self.metaTags) - 1:
                    output += ", "

        return output

class LibraryDefinition(Symbol):
    def __init__(self, library, data, groups):
        self.name = groups["Library"]
        self.context = groups["Context"]

        super().__init__(library, data, groups)

    def __str__(self): # Library definition tags do not show
        return f""

class Class(Symbol):
    def __init__(self, library, data, groups):
        self.className = groups["Class"]

        super().__init__(library, data, groups)

    def isFinishedParsing(self, nextLine):
        return type(nextLine) != ClassField and nextLine != None

    def __str__(self):
        output = f"---@class {self.className}" + "\n"

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

        output += f"---@{self.TAG} {self.event}"

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
    Matcher(re.compile("^---(?P<Comment>[^@].*)$"), Comment),
]

SYMBOL_MATCHERS = [
    Matcher(FUNCTION_REGEX, Function),
    Matcher(re.compile("^---@meta Library: (?P<Library>\S*), (?P<Context>\S*)$"), LibraryDefinition),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Hook_(?P<Event>\S*) : Hook$"), Hook),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Event_(?P<Event>\S*) : Event$"), Event),
    Matcher(re.compile("^---@class (?P<Class>\S*)$"), Class),
]

class Library:
    def __init__(self, name, context):
        self.name = name
        self.context = context
        self.symbols = []

    def addSymbol(self, symbol:Symbol):
        self.symbols.append(symbol)

    def __str__(self):
        output = "Library: " + self.name + "\n"
        output += "Context: " + self.context + "\n"

        for symbol in self.symbols:
            output += "Symbol: " + "\n"
            output += str(symbol) + "\n\n"
        
        return output

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

    def getSymbolOnLine(self, line):
        symbol = None

        for matcher in SYMBOL_MATCHERS:
            match = matcher.regex.match(line)

            if match:
                symbolType = matcher.classType
                symbol = symbolType(None, [], match.groupdict()) # TODO
                break

        return symbol

    def getSymbol(self, lines):
        dataStack = []
        consumedLines = 0
        symbol = None
        hasSymbol = False
        currentData = None
        stop = False

        for line in lines:
            match = None

            lineSymbol = self.getSymbolOnLine(line)

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

            # search for symbol definitions
            

        # for line in lines:
        #     if stop:
        #         break

        #     # search for metadata
        #     if not hasSymbol or not symbol.isFinishedParsing(currentData):
        #         for matcher in DATA_MATCHERS:
        #             match = matcher.regex.match(line)

        #             if match:
        #                 dataType = matcher.classType

        #                 data = dataType(match.groupdict())

        #                 if symbol: # add to symbol
        #                     symbol.addData([data])
        #                 else: # otherwise hold it for later       
        #                     dataStack.append(data)

        #                 currentData = data
        #                 break

        #     if hasSymbol and symbol.isFinishedParsing(currentData):
        #         break

        #     # search for symbol definitions
        #     for matcher in SYMBOL_MATCHERS:
        #         match = matcher.regex.match(line)

        #         if match:
        #             if symbol != None:
        #                 stop = True
        #                 consumedLines -= 1
        #                 break

        #             symbolType = matcher.classType

        #             # TODO
        #             symbol = symbolType(None, dataStack, match.groupdict())

        #             hasSymbol = True
        #             dataStack = []
        #             break

        #     consumedLines += 1

        # consume lines
        for i in range(consumedLines):
            lines.pop(0)

        # add remaining data
        # if symbol:
        #     symbol.addData(dataStack)

        return symbol

    def findLibrary(self, lines:list):
        # We assume it's the first one
        meta = self.getSymbol(lines)

        return meta

    def parseLuaFile(self, filePath:str):

        with open(filePath, "r") as f:
            lines = f.readlines()
            library = None

            # Find library name first
            # TODO do this some other way? automatic from table declaration?
            libraryDefinition = self.findLibrary(lines)

            if libraryDefinition.name in self.libraries:
                library = self.libraries[libraryDefinition.name]
            else:
                library = Library(libraryDefinition.name, libraryDefinition.context)
                self.libraries[library.name] = library

            while len(lines) > 0:
                symbol = self.getSymbol(lines)

                if symbol:
                    library.addSymbol(symbol)
    

gen = DocGenerator()
# gen.parseLuaFile("C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\Game\Characters\Shared.lua")
gen.parseLuaFile(r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\UI\GiftBagContent.lua")

print(gen.libraries["GiftBagContentUI"])

def parseLua(file_path:str):
    currentFunction = Function()
    currentClass = None
    currentEvent = None
    context_tags = []
    found = 0

    comments = []

    with open(file_path, "r") as f:
        for line in f.readlines():
            # if line.find("INTERNAL") >= 0:
            #     break
            
            funcMatch = FUNCTION_REGEX.match(line)
            commentMatch = COMMENT_REGEX.match(line)
            tagsMatch = TAGS_REGEX.match(line)
            eventMatch = EVENT_REGEX.match(line)
            classMatch = CLASS_REGEX.match(line)
            fieldMatch = FIELD_REGEX.match(line)
            emptyLineMatch = EMPTY_LINE_REGEX.match(line)

            # Events
            if eventMatch and eventMatch.groups()[1] in EVENTS:
                currentEvent = Function()
                currentEvent.setName(eventMatch.groups()[0])
                currentEvent.setType("event")
                currentEvent.addLines(comments)
                comments = []
                currentEvent.addLine("---@" + eventMatch.groups()[1].lower() + " " + eventMatch.groups()[0])

                for tag in context_tags:
                    currentEvent.addTag(tag)
            elif fieldMatch and currentEvent:
                currentEvent.addLine(line.replace("\n", "").replace("---@field", "---@param"))
            elif emptyLineMatch and currentEvent:
                events[currentEvent.name + str(random.randint(1, 99))] = currentEvent
                currentEvent = None

            # Classes
            if classMatch:
                currentClass = {
                    "Name": classMatch.groups()[0],
                    "Lines": [line.replace("\n", "")],
                }
            elif fieldMatch:
                currentClass["Lines"].append(line.replace("\n", ""))
            elif line == "\n" and currentClass:
                classes[currentClass["Name"]] = currentClass
                currentClass = None

            if not currentClass:
            
                # Functions
                if tagsMatch:
                    if found == 0: # tags for all funcs in file
                        context_tags = tagsMatch.groups()[0].split(", ")
                    else:
                        for tag in tagsMatch.groups()[0].split(", "):
                            currentFunction.addTag(tag)

                elif commentMatch and line.count("---") == 1 and not line.startswith("---@type") and not line.startswith("---@alias"):
                    # currentFunction.addLine(line)
                    comments.append(line)
                    found += 1 # TODO rename

                elif funcMatch:
                    # currentFunction = Function()
                    currentFunction.setName(funcMatch.group())

                    currentFunction.addLines(comments)
                    comments = []

                    for tag in context_tags:
                        currentFunction.addTag(tag)

                    if len(currentFunction.lines) > 0:
                        # if current.name in functions: # For functions that have context-specific implementations, keep only one. If both contexts are implemented, tag it as Shared.
                        dictionary = functions
                        if currentFunction.funType == "event":
                            dictionary = events

                        if currentFunction.name in dictionary:
                            dictionary[currentFunction.name + "_1"] = currentFunction
                        # if False:
                        #     previous = functions[current.name]

                        #     ## TODO check if params are the same
                        #     if (previous.tags["Client"] and current.tags["Server"]) or (previous.tags["Server"] and current.tags["Client"]):
                        #         previous.removeTag("Client")
                        #         previous.removeTag("Server")
                        #         previous.addTag("Shared")
                        else:
                            dictionary[currentFunction.name] = currentFunction

                    currentFunction = Function()

# Parse documentation from lua
# for root_path, dirs, files in os.walk(MOD_ROOT):
#     for file_name in files:
#         if pathlib.Path(file_name).suffix == ".lua" and file_name not in LUA_IGNORE:
#             parseLua(os.path.join(root_path, file_name))

# # Update docs
# for root_path, dirs, files in os.walk(DOCS_ROOT):
#     for file_name in files:
#         if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
#             updateFile(os.path.join(root_path, file_name))