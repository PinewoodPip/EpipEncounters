import os, pathlib, re
from collections import defaultdict
from typing import Optional

ALIASES = {}

def aliasToLibraryID(alias):
    if alias in ALIASES:
        return ALIASES[alias]

    return alias

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

ALIAS_REGEX = re.compile("^---@alias (\S*) (.*)$")
EVENT_REGEX = re.compile("^---@class .*_(.*) : (.*)?$")
CLASS_REGEX = re.compile("^---@class (.*)$")
FIELD_REGEX = re.compile("^---@field (\S*) (.*)$")

DOC_FIELDS_REGEX = re.compile('^<doc fields="(.*)">')
EMPTY_LINE_REGEX = re.compile("^ *$")

SUBCLASS_REGEX = re.compile("([^_]+)_.+")
HOOKABLE_REGEX = re.compile("[^_]+_(?:Event|Hook)_.+")

# -----------------
# Lua file Class
# -----------------

class LuaFile:
    def __init__(self, path):
        self.path = path
        self.context = "Shared"

    def setContext(self, context:str):
        self.context = context

class Style:
    TAG_STYLE = {
        "color": "#b04a6e",
    }

    def parse(style:dict[str, any]) -> str:
        output = "".join(["{0}:{1};".format(param, value) for param,value in style.items()])

        return f"style=\"{output}\""

class HTML:
    def paragraph(text, style):
        return f"<p {Style.parse(style)}>{text}</p>"

    def italics(text):
        return f"<i>{text}</i>"

    def bold(text):
        return f"<b>{text}</b>"

    def code(text):
        return f"<code>{text}</code>"
    
    def bold_italics(text):
        return HTML.bold(HTML.italics(text))

    def span(text, style):
        return f"<span {Style.parse(style)}>{text}</span>"

# -----------------
# Doc Section Class
# -----------------

class DocSection():
    def __init__(self, header=None):
        self.header:Optional[str] = header
        self.header_prefix = "#"
        self.infobox:Optional[str] = None
        self.description:Optional[str] = None
        self.subsections:list[DocSection] = []

    def addSubSection(self, section):
        self.subsections.append(section)

    def export(self) -> str:
        text = []

        if self.header:
            text.append(f"{self.header_prefix} {self.header}")

        if self.description:
            text.append(self.description)

        if self.infobox:
            text.append(f"\n!!! info \"{self.infobox}\"")

        if len(self.subsections) > 0:
            for subsection in self.subsections:
                text.append(subsection.export())

        return "\n\n".join(text)

class DocLine(DocSection):
    def __init__(self, text):
        self.text = text

    def export(self) -> str:
        return f"\n\n{self.text}"

# -----------------
# Metadata Classes
# -----------------

class Data:
    def export(self) -> str:
        raise "Not implemented"

    def __str__(self):
        return ""

# Comments  
class Comment(Data):
    def __init__(self, groups):
        self.comment = groups["Comment"]

    def getText(self) -> str:
        return self.comment

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
    PARAGRAPH_STYLE = {"margin-bottom": "0px"}

    def __init__(self, groups):
        self.type = groups["Type"].replace("\n", "")
        self.name = groups["Name"] if "Name" in groups else None
        self.comment = groups["Comment"] if "Comment" in groups else "" # Comment is optional

    def getText(self) -> str:
        return self.comment

    def export(self) -> str:
        if self.name:
            return HTML.paragraph(f"{HTML.span(HTML.bold_italics('@' + self.TAG), Style.TAG_STYLE)} {HTML.bold(self.name)} {HTML.code(self.type)} {self.comment}", self.PARAGRAPH_STYLE)
        else:
            return HTML.paragraph(f"{HTML.span(HTML.bold_italics('@' + self.TAG), Style.TAG_STYLE)} {HTML.code(self.type)} {self.comment}", self.PARAGRAPH_STYLE)

    def __str__(self):
        return f"---@{self.TAG} {self.type} {self.comment}"

# Parameters
class Parameter(TypedTag):
    TAG = "param"

class Overload(TypedTag):
    TAG = "overload"

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
    def __init__(self, groups:list):
        self.data = []
        
        self.setContext("Shared")

    def setLineNumber(self, line_number:int):
        self.line_number = line_number

    # Returns whether this symbol is private: 
    # not intended to be used by other modders, usually used internally
    def isPrivate(self) -> bool:
        return False

    def getContext(self) -> str:
        return self.context

    def setContext(self, context:str):
        self.context = context

    def getLibraryName(self) -> str:
        return "_none"
    
    def getLibraryID(self) -> str:
        raise NotImplemented()

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

    def __init__(self, groups:list):
        self.comments:list[Comment] = []
        self.parameters:list[Parameter] = []
        self.returnType:Optional[Return] = None
        self.signature = groups["Signature"]
        self.nameSpace = groups["Namespace"]
        self.syntacticSugar = groups["SyntacticSugar"]
        self.metaTags = []
        self.overloads = []
        self.parameters_signature:str = groups["Parameters"].replace("(", "").replace(")", "") # TODO bruh
        self.class_name = aliasToLibraryID(self.nameSpace)

        # Parse data
        super().__init__(groups)

    def getLibraryName(self) -> str:
        return self.nameSpace
    
    def getLibraryID(self) -> str:
        return self.class_name

    def isPrivate(self) -> bool:
        return self.signature.startswith("_")
        
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
            elif type(entry) == Overload:
                self.overloads.append(entry)

    def __str__(self):
        output = []

        # Append comments
        output += [str(comment) for comment in self.comments]

        # Append overloads
        output += [str(overload) for overload in self.overloads]

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
    def __init__(self, groups):
        self.className = groups["Class"]
        self.comment = None
        self.subclasses:list[Class] = []
        self.methods:list[Function] = []
        self.events:list[Event] = []
        self.hooks:list[Hook] = []

        super().__init__(groups)
    
    # Returns whether a symbol is a subclass of this one.
    def isSubclass(self, symbol) -> bool:
        regex = re.compile(f'({self.className})_(?P<SubClass>.+)')

        return type(symbol) == Class and regex.match(symbol.className)

    def addSymbol(self, symbol:Symbol):
        if self.isSubclass(symbol): # TODO events, hooks, functions
            self.subclasses.insert(symbol)
        elif type(symbol) == Function:
            self.methods.append(symbol)
        elif type(symbol) == Event:
            self.events.append(symbol)
        elif type(symbol) == Hook:
            self.hooks.append(symbol)

    def getLibraryName(self) -> str:
        return self.className
    
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

    def __init__(self, groups):
        self.className = groups["Class"]
        self.event = groups["Event"]
        self.comments = []
        self.fields = []

        super().__init__(groups)

    def addData(self, data):
        super().addData(data)

        for entry in data:
            if type(entry) == Comment:
                self.comments.append(entry)
            elif type(entry) == ClassField:
                self.fields.append(entry)

    def getLibraryName(self) -> str:
        return self.className
    
    def getLibraryID(self) -> str:
        return self.className

    def getSymbolCategory(self) -> str:
        return "Listenable"

    def isFinishedParsing(self, nextLine):
        return type(nextLine) != ClassField and nextLine != None and nextLine != "\n" and nextLine != "" and type(nextLine) != ClassAlias

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
    def __init__(self, groups):
        self.libraryID = groups["Library"]
        self.eventName = groups["Event"]
        self.signature = groups["Signature"]

        super().__init__(groups)

    def getLibraryName(self) -> str:
        return self.libraryID
    
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
#   DOC EXPORTERS
# ------------

class Exporter():
    def export(symbol):
        raise "Not implemented"

class FancyExporter(Exporter): # TODO consider @see tags
    def __exportClass(symbol:Class):
        section = DocSection() # TODO className var

        # Insert events
        if len(symbol.events) > 0 or len(symbol.hooks) > 0:
            section.addSubSection(DocLine("## Events and Hooks"))
            for event in symbol.events:
                section.addSubSection(FancyExporter.export(event))
            for hook in symbol.hooks:
                section.addSubSection(FancyExporter.export(hook))

        # Insert functions
        if len(symbol.methods) > 0:
            section.addSubSection(DocLine("## Methods"))
            for method in symbol.methods:
                if not method.isPrivate():
                    section.addSubSection(FancyExporter.export(method))

        # Insert subclasses
        if len(symbol.subclasses) > 0:
            section.addSubSection(DocLine("## Subclasses"))
            for subclass in symbol.subclasses:
                section.subsections.append(subclass.export(True))

        return section

    def __exportFunction(symbol:Function):
        section = DocSection(symbol.signature)
        section.header_prefix = "####"
        # section.description = "".join([comment.getText() for comment in symbol.comments])

        # Insert function signature
        return_signature = ""
        if symbol.returnType:
            return_signature = f"\n   -> {symbol.returnType.type}"
        section.addSubSection(DocLine(f"```lua\nfunction {symbol.getLibraryName()}{symbol.syntacticSugar}{symbol.signature}({symbol.parameters_signature}){return_signature}\n```"))

        section.addSubSection(DocLine("\n".join([comment.getText() for comment in symbol.comments])))

        for param in symbol.parameters:
            section.addSubSection(FancyExporter.__exportMetadata(param))

        if symbol.returnType:
            section.addSubSection(FancyExporter.__exportMetadata(symbol.returnType))

        return section

    def __exportMetadata(data:Data) -> DocSection:
        section = DocLine(data.export())

        return section

    def __exportListenable(symbol:Listenable) -> DocSection:
        # TODO include snippet showing how to subscribe, using global path (if available) or classname as fallback
        listenable_type = "event" if type(symbol) == Event else "hook"
        section = DocSection(f"{symbol.event} ({listenable_type})")
        section.header_prefix = "#####"
        section.description = "".join([comment.getText() for comment in symbol.comments])

        for field in symbol.fields:
            section.addSubSection(FancyExporter.__exportMetadata(field))

        return section

    def export(symbol) -> DocSection:
        SYMBOL_TO_FUNC = {
            Class: FancyExporter.__exportClass,
            Function: FancyExporter.__exportFunction,
            Event: FancyExporter.__exportListenable,
            Hook: FancyExporter.__exportListenable,
            # TODO net event
        }

        if type(symbol) in SYMBOL_TO_FUNC:
            return SYMBOL_TO_FUNC[type(symbol)](symbol)
        else:
            raise "Not implemented for type " + str(type(symbol))
        

# ------------
#   MATCHERS
# ------------

class Matcher():
    def __init__(self, regex, classType):
        self.regex = regex
        self.classType = classType

DATA_MATCHERS = [
    Matcher(re.compile("^---@param (?P<Name>\S*) (?P<Type>\S*) ?(?P<Comment>.*)?$"), Parameter),
    Matcher(re.compile("^---@overload (?P<Type>.+)$"), Overload),
    Matcher(re.compile("^---@return (?P<Type>[^-]*) ?(-- ?)?(?P<Comment>.*)?$"), Return),
    Matcher(re.compile("^---@field (?P<Name>\S*) (?P<Type>\S*) ?(?P<Comment>.*)?$"), ClassField),
    Matcher(re.compile("^---@meta (?P<Comment>.*)$"), Meta),
    Matcher(re.compile("^---(?P<Comment>[^-@].+)$"), Comment),
    Matcher(re.compile("^(local )?(?P<Alias>\S+) = {"), ClassAlias),
    Matcher(re.compile("^(local )?(?P<Alias>\S+) = .+$"), ClassAlias),
    Matcher(re.compile("^-- (?P<Region>[[:upper:]]+)$"), FileRegionHeader)
]

# Symbol regex patterns, in order of priority.
SYMBOL_MATCHERS = [
    Matcher(re.compile("^function (?P<Namespace>[^ .:]+)(?P<SyntacticSugar>\.|:)(?P<Signature>\S+)(?P<Parameters>\(.*\))( end)?$"), Function),
    Matcher(re.compile("^---@class (?P<Class>\S*)_Hook_(?P<Event>\S*)(?: : Event)?$"), Hook), # TODO this has a flaw: it will not pick up events that ex. re-use the Empty class
    Matcher(re.compile("^---@class (?P<Class>\S*)_Event_(?P<Event>\S*)(?: : Event)?$"), Event),
    Matcher(re.compile("^---@class (?P<Signature>(?P<Class>EPIPENCOUNTERS_(?P<Library>\S*)_(?P<Event>\S*))(?: : .+))$"), NetMessage), # TODO check for NetLib_Message inheritance instead

    # Generic class should have the lowest priority
    Matcher(re.compile("^---@class (?P<Class>\S+)"), Class),
]

DOC_PACKAGE_REGEX = re.compile('^<doc package="(.+)">$')
DOC_TEMPLATE_REGEX = re.compile('^<doc class="(.+)" symbols="(.+)">')
DOC_TEMPLATE_END_REGEX = re.compile('^<\/doc>')

class Library_deprecated:
    SYMBOL_TYPE_EXPORT_ORDER = [
        "Shared",
        "Client",
        "Server",
    ]

    def __init__(self, name):
        self.name = name
        self.symbols = []

    def addSymbol(self, symbol:Symbol):
        self.symbols.append(symbol)

    def __str__(self):
        output = ""

        for symbol in self.symbols:
            output += "Symbol: " + type(symbol).__name__ + "\n"
            output += "Library: " + symbol.getLibraryName() + "\n"
            # output += "Context: " + self.context + "\n"

            output += str(symbol) + "\n\n"
        
        return output

    # Exports the library's symbols to markdown, optionally sorted.
    def export(self, symbolTypes:list=None):
        lines = ["```lua"]

        symbols_by_context = defaultdict(list)

        for symbol in self.symbols:
            # Include symbols if a list wasn't passed,
            # or if their category is in the list
            can_export = (not symbolTypes) or (symbol.getSymbolCategory() in symbolTypes)

            # Cannot export private symbols
            can_export = can_export and not symbol.isPrivate()

            if can_export:
                symbols_by_context[symbol.getContext()].append(symbol)
        
        for symbol_type in self.SYMBOL_TYPE_EXPORT_ORDER:
            symbols = symbols_by_context[symbol_type]

            for symbol in symbols:
                lines.append(str(symbol) + "\n")

        lines.append("```\n")
        return "\n".join(lines)


class DocParser:
    def __init__(self, lua_file:LuaFile) -> None:
        self.lua_file = lua_file
        self.file = open(self.lua_file.path, "r")
        self.lines = self.file.readlines()
        self.symbols:list[Symbol] = []

        self.Parse()

    def Parse(self) -> None:
        while not self.isFinished():
            symbol = self.getSymbol()

            if symbol:
                self.symbols.append(symbol)

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
                symbol = symbolType(match.groupdict()) # TODO
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

        if foundSymbol:
            foundSymbol.setLineNumber(lastIndex + 1)
            foundSymbol.setContext(self.lua_file.context)

        return foundSymbol

    def isFinished(self):
        return len(self.lines) == 0

class DocGenerator:
    LOAD_ORDER_SCRIPT_REGEX = re.compile("    \"(?P<Script>\S+\.lua)\",")
    SCRIPT_SET_REGEX = re.compile("\"(?P<Script>[^\.]+)\"")

    def __init__(self, mod_root_path:str, docs_root_path:str, annotation_directories:list[str]):
        self.mod_root_path = mod_root_path
        self.docs_root_path = docs_root_path
        self.annotation_directories = annotation_directories
        self.classes:dict[str, Class] = {}
        self.all_symbols:list[Symbol] = []
        self.linked_symbols:set[Symbol] = set() # Symbols that have already been linked to their corresponding classes.

    def getLuaFiles(self) -> list:
        lua_files = {} # Maps path to LuaFile

        CONTEXTS = {
            "Client": "BootstrapClient.lua",
            "Server": "BootstrapServer.lua",
        }

        for context in CONTEXTS:
            bootstrap = CONTEXTS[context]

            with open(os.path.join(self.mod_root_path, bootstrap), "r") as f:
                for line in f.readlines():
                    match = DocGenerator.LOAD_ORDER_SCRIPT_REGEX.search(line)

                    if match != None:
                        script_filename = match.groupdict()["Script"]
                        script_path = os.path.join(self.mod_root_path, script_filename)

                        lua_files[script_path] = LuaFile(script_path)
                        lua_files[script_path].setContext(context)
                    else:
                        match = DocGenerator.SCRIPT_SET_REGEX.search(line)

                        if match != None:
                            script_filename = match.groupdict()["Script"]

                            script_filename_shared = os.path.join(self.mod_root_path, script_filename + "/Shared.lua")
                            script_filename_context_specific = os.path.join(self.mod_root_path, script_filename + "/" + context + ".lua")

                            if os.path.isfile(script_filename_shared):
                                lua_file = LuaFile(script_filename_shared)
                                lua_file.setContext("Shared")

                                lua_files[script_filename_shared] = lua_file
                            if os.path.isfile(script_filename_context_specific):
                                lua_file = LuaFile(script_filename_context_specific)
                                lua_file.setContext(context)

                                lua_files[script_filename_context_specific] = lua_file

        for annotation_dir in self.annotation_directories:
            for root_path, _, files in os.walk(annotation_dir):
                for file_name in files:
                    if pathlib.Path(file_name).suffix == ".lua":
                        lua_file_path = os.path.join(root_path, file_name)
                        lua_files[lua_file_path] = LuaFile(lua_file_path) # Only shared annotations are supported for now. TODO

        return lua_files

    def __linkSymbolsToClasses(self):
        # Insert symbols into appropriate classes
        for symbol in self.all_symbols:
            if symbol not in self.linked_symbols:
                classIdentifier = symbol.getLibraryID()

                if classIdentifier in self.classes:
                    classSymbol = self.classes[classIdentifier]
                    classSymbol.addSymbol(symbol) # TODO make sure one class doesnt get added to itself?
                else:
                    print("Found symbol with no class: " + classIdentifier)

                self.linked_symbols.add(symbol)

    def updateDocs(self) -> None:
        files = self.getLuaFiles()

        # Parse lua
        for absolute_path, lua_file in files.items():
            print("Parsing", absolute_path)
            self.parseLuaFile(lua_file)

        self.__linkSymbolsToClasses()

        # Update markdown docs
        for root_path, _, files in os.walk(self.docs_root_path):
            for file_name in files:
                if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
                    self.updateDocFile(os.path.join(root_path, file_name))

    # Gathers symbols from a lua file.
    def parseLuaFile(self, lua_file:LuaFile):
        parser = DocParser(lua_file)
        
        for symbol in parser.symbols:
            classIdentifier = symbol.getLibraryID()
            if type(symbol) == Class and classIdentifier not in self.classes:
                self.classes[classIdentifier] = symbol

                self.all_symbols.append(symbol)    
            elif type(symbol) != Class:
                self.all_symbols.append(symbol)  

        self.__linkSymbolsToClasses()
    
    def updateDocFile(self, file_path:str):
        template = ""
        removing = False
        replacedSomething = False

        with open(file_path, "r") as f:
            for line in f.readlines():
                closeMatch = DOC_TEMPLATE_END_REGEX.match(line)
                packageMatch = DOC_PACKAGE_REGEX.match(line)

                if closeMatch:
                    removing = False
                    template += "\n"
                elif packageMatch:
                    package_name = packageMatch.groups()[0]
                    class_symbol = self.classes[package_name]

                    removing = True
                    replacedSomething = True
                    template += line + "\n"
                    
                    template += FancyExporter.export(class_symbol).export() # TODO inject factory

                if not removing:
                    template += line

        if replacedSomething:
            with open(file_path, "w") as f:
                print("Updating " +  file_path)
                f.write(template)
