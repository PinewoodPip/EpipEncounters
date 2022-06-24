from dataclasses import field
from importlib.resources import path
import os, sys, pathlib, re
import random

## TODO define absolute path to functions, ex. Inv - > Client.UI.PartyInventory
## Done? support different implementations across contexts
## TODO aliases
## DONE classes and fields
## TODO hide internal fields
## TODO auto-generate IDE helper

MOD_ROOT = sys.argv[1]
DOCS_ROOT = sys.argv[2]

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
FUNCTION_REGEX = re.compile("^(function .*)$")
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
for root_path, dirs, files in os.walk(MOD_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".lua" and file_name not in LUA_IGNORE:
            parseLua(os.path.join(root_path, file_name))

# Update docs
for root_path, dirs, files in os.walk(DOCS_ROOT):
    for file_name in files:
        if pathlib.Path(file_name).suffix == ".md" and file_name != "patchnotes.md":
            updateFile(os.path.join(root_path, file_name))