import os, pathlib, re
from collections import defaultdict

## TODO define absolute path to functions, ex. Inv - > Client.UI.PartyInventory
## Done? support different implementations across contexts
## TODO aliases
## TODO hide internal fields
## TODO auto-generate IDE helper
## TODO fix lack of spaces breaking it? probably from isFinishingParsing() usage

ALIASES = {}

def aliasToLibraryID(alias):
    if alias in ALIASES:
        return ALIASES[alias]

    return alias

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

FUNCTION_REGEX = re.compile("^function (?P<Namespace>[^ .:]+)(?P<SyntacticSugar>\.|:)(?P<Signature>\S+\(.*\))$")
TAGS_REGEX = re.compile("^---@meta (.*)$")
ALIAS_REGEX = re.compile("^---@alias (\S*) (.*)$")
EVENT_REGEX = re.compile("^---@class .*_(.*) : (.*)?$")
CLASS_REGEX = re.compile("^---@class (.*)$")
FIELD_REGEX = re.compile("^---@field (\S*) (.*)$")

DOC_TEMPLATE_REGEX2 = re.compile('^<doc (\w*)="(.*)">')
DOC_FIELDS_REGEX = re.compile('^<doc fields="(.*)">')
EMPTY_LINE_REGEX = re.compile("^ *$")

SUBCLASS_REGEX = re.compile("([^_]+)_.+")
HOOKABLE_REGEX = re.compile("[^_]+_(?:Event|Hook)_.+")

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

class ClassAlias(Data):
    def __init__(self, groups):
        self.alias = groups["Alias"]

    def __str__(self):
        return ""

class FileRegionHeader(Data):
    def __init__(self, groups:dict):
        self.region = groups["Region"]

    def __str__(self):
        return ""

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
        
        self.setContext("Shared")

        self.addData(data)

    def getContext(self) -> str:
        return self.context

    def setContext(self, context:str):
        self.context = context

    def getLibraryID(self) -> str:
        return "_none"

    # Returns the category this symbol belongs to,
    # used to group symbols while exporting.
    def getSymbolCategory(self) -> str:
        return type(self).__name__

    def isFinishedParsing(self, nextLine):
        return True

    def addData(self, data:list):
        for entry in data:
            self.data.append(entry)

    # Returns all of this symbol's metadata stringified,
    # in a list.
    def getDataStrings(self) -> list[str]:
        return [str(field) for field in self.data]

    def __str__(self):
        pass

# For symbols, the line that defines them is passed as vararg(s)

class Function(Symbol):
    META_TAGS = { # TODO fix
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
        return aliasToLibraryID(self.nameSpace)
        
    def addData(self, data: list):
        super().addData(data)

        for entry in data:
            if type(entry) == Comment:
                self.comments.append(entry)
            elif type(entry) == Parameter:
                self.parameters.append(entry)
            elif type(entry) == Return:
                self.returnType = entry
            elif type(entry) == Meta:
                self.metaTags.append(entry)

    def __str__(self):
        output = []

        # Append comments
        output += [str(comment) for comment in self.comments]

        # Append parameters
        output += [str(param) for param in self.parameters]

        # Append return type
        if self.returnType:
            output.append(str(self.returnType))

        # Append signature
        signature_output = f"function {self.nameSpace}{self.syntacticSugar}{self.signature}"
        if len(self.metaTags) > 0: # Append tags to signature
            signature_output += " -- "
            signature_output += ", ".join([metaTag.comment for metaTag in self.metaTags])
        output.append(signature_output)

        return "\n".join(output)

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
            elif type(entry) == ClassAlias:
                ALIASES[entry.alias] = self.getLibraryID()
            else:
                self.data.append(entry)

    def isFinishedParsing(self, nextLine):
        return type(nextLine) != ClassField and nextLine != None and nextLine != "\n" and nextLine != "" and type(nextLine) != ClassAlias

    def __str__(self):
        output = []

        # Append comment
        if self.comment: # TODO why is there only one?
            output.append(str(self.comment))

        # Append signature
        output.append(f"---@class {self.className}")

        # Append fields
        output += [str(field) for field in self.data]

        return "\n".join(output)

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

    def getLibraryID(self) -> str:
        return aliasToLibraryID(self.className)

    def getSymbolCategory(self) -> str:
        return "Listenable"

    def isFinishedParsing(self, nextSymbol):
        # Any comment after the symbol is found is guaranteed to be unrelated.
        return nextSymbol and type(nextSymbol) == Comment

    def __str__(self):
        output = []

        # Append comments
        output += [str(comment) for comment in self.comments]

        # Append signature
        output.append(f"---@{self.TAG} {self.event}")

        # Append fields
        output += [str(field) for field in self.fields]

        return "\n".join(output)

class Event(Listenable):
    TAG = "event"

class Hook(Listenable):
    TAG = "hook"

class NetMessage(Class):
    def __init__(self, library, data, groups):
        self.libraryID = groups["Library"]
        self.eventName = groups["Event"]
        self.signature = groups["Signature"]

        super().__init__(library, data, groups)

    def getLibraryID(self) -> str:
        return self.libraryID

    def getSymbolCategory(self) -> str:
        return "Listenable"
    
    def __str__(self):
        output = []

        # Preppend comment TODO why is it only one?
        if self.comment:
            output.append(str(self.comment))

        # Append signature
        output.append(f"---@netmsg {self.signature}")

        # Append metadata
        output += self.getDataStrings()

        return "\n".join(output)

# ------------
#   MATCHERS
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
    Matcher(re.compile("^(local )?(?P<Alias>\S+) = {"), ClassAlias),
    Matcher(re.compile("^(local )?(?P<Alias>\S+) = \S+$"), ClassAlias),
    Matcher(re.compile("^-- (?P<Region>[[:upper:]]+)$"), FileRegionHeader)
]

# Symbol regex patterns, in order of priority.
SYMBOL_MATCHERS = [
    Matcher(FUNCTION_REGEX, Function),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Hook_(?P<Event>\S*)(?: : Event)?$"), Hook),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Event_(?P<Event>\S*)(?: : Event)?$"), Event),
    Matcher(re.compile("^---@class (?P<Signature>(?P<Class>EPIPENCOUNTERS_(?P<Library>\S*)_(?P<Event>\S*))(?: : .+))$"), NetMessage),

    # Generic class should have the lowest priority
    Matcher(re.compile("^---@class (?P<Class>\S+)"), Class),
]

DOC_TEMPLATE_REGEX = re.compile('^<doc class="(.+)" symbols="(.+)">')
DOC_TEMPLATE_END_REGEX = re.compile('^<\/doc>')

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
        output = ""

        for symbol in self.symbols:
            output += "Symbol: " + type(symbol).__name__ + "\n"
            output += "Library: " + symbol.getLibraryID() + "\n"
            # output += "Context: " + self.context + "\n"

            output += str(symbol) + "\n\n"
        
        return output

    # Exports the library's symbols to markdown, optionally sorted.
    def export(self, symbolTypes:list=None):
        lines = ["```lua"]

        for symbol in self.symbols:
            # Include symbols if a list wasn't passed,
            # or if their category is in the list
            can_export = (not symbolTypes) or (symbol.getSymbolCategory() in symbolTypes)

            if can_export:
                lines.append(str(symbol) + "\n")

        lines.append("```\n")
        return "\n".join(lines)


class DocParser:
    def __init__(self, file_name) -> None:
        self.file_name = file_name
        self.file = open(file_name, "r")
        self.lines = self.file.readlines()
        self.symbolsPerLibrary = defaultdict(list)

        self.Parse()

    def Parse(self) -> None:
        while not self.isFinished():
            symbol = self.getSymbol()

            if symbol:
                libraryID = symbol.getLibraryID()

                self.symbolsPerLibrary[libraryID].append(symbol)

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
        lastIndex = 0
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
                lastIndex = lineIndex
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

                    lastIndex = lineIndex

            lineIndex += 1

        # Consume lines up until the last metadata found
        self.lines = self.lines[lastIndex+1::]

        return foundSymbol

    def isFinished(self):
        return len(self.lines) == 0

class DocGenerator:
    LOAD_ORDER_SCRIPT_REGEX = re.compile("    \"(?P<Script>\S+\.lua)\",")
    SCRIPT_SET_REGEX = re.compile("\"(?P<Script>[^\.]+)\"")
    libraries = {} # TODO don't make this static

    def getLuaFiles(self) -> list:
        lua_files = set()

        CONTEXTS = {
            "Client": "BootstrapClient.lua",
            "Server": "BootstrapServer.lua",
        }

        for context in CONTEXTS:
            bootstrap = CONTEXTS[context]

            with open(os.path.join(MOD_ROOT, bootstrap), "r") as f:
                for line in f.readlines():
                    match = DocGenerator.LOAD_ORDER_SCRIPT_REGEX.match(line)

                    if match != None:
                        script_filename = match.groupdict()["Script"]

                        lua_files.add(os.path.join(MOD_ROOT, script_filename))
                    else:
                        match = DocGenerator.SCRIPT_SET_REGEX.search(line)

                        if match != None:
                            script_filename = match.groupdict()["Script"]

                            script_filename_shared = os.path.join(MOD_ROOT, script_filename + "/Shared.lua")
                            script_filename_context_specific = os.path.join(MOD_ROOT, script_filename + "/" + context + ".lua")

                            if os.path.isfile(script_filename_shared):
                                lua_files.add(script_filename_shared)
                            if os.path.isfile(script_filename_context_specific):
                                lua_files.add(script_filename_context_specific)

        return lua_files

    def updateDocs(self) -> None:
        files = self.getLuaFiles()

        # Parse lua
        for absolute_path in files:
            print("Parsing", absolute_path)
            self.parseLuaFile(absolute_path)

        # Update markdown docs
        for root_path, dirs, files in os.walk(DOCS_ROOT):
            for file_name in files:
                if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
                    self.updateDocFile(os.path.join(root_path, file_name))

    def getLibrary(self, id:str) -> Library:
        return self.libraries[id]

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
    
    def updateDocFile(self, file_path:str):
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

                    # Export subclasses
                    if "_SubClasses" in symbolTypes:
                        libs_to_export = []

                        for _,lib in gen.libraries.items():
                            match = SUBCLASS_REGEX.match(lib.name)
                            is_hookable = HOOKABLE_REGEX.match(lib.name) != None

                            if match and match.groups()[0] == libName and not is_hookable:
                                libs_to_export.append(lib)

                        for lib in libs_to_export:
                            template += lib.export(["Class", "Function"])
                    else:
                        template += gen.libraries[libName].export(symbolTypes)

                if not removing:
                    template += line

        if replacedSomething:
            with open(file_path, "w") as f:
                print("Updating " +  file_path)
                f.write(template)

# --------------------------------------
gen = DocGenerator()

gen.updateDocs()

# QUICK TEST
# gen.parseLuaFile(r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Mods\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Story\RawFiles\Lua\Utilities\GameState\Shared.lua")

# for lib in gen.libraries:
#     print(gen.libraries[lib])