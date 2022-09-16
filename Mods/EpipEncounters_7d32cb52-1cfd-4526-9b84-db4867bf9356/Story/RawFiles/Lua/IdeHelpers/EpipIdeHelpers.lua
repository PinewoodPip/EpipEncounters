
---@alias Entity EclCharacter|EsvCharacter|EclItem|EsvItem
---@alias Character EsvCharacter|EclCharacter
---@alias Item EclItem|EsvItem
---@alias Status EclStatus|EsvStatus
---@alias GUID string
---@alias PrefixedGUID string
---@alias Context "Client"|"Server" 
---@alias pattern string
---@alias TranslatedStringHandle string
---@alias ModTableID string|"EpipEncounters"

---@class NetMessage_Character
---@field CharacterNetID NetId

---@class NetMessage_Item
---@field ItemNetID NetId

Mods = {}

---Temporary alias.
---@class Library: Feature

---@alias EquipSlot "Helmet" | "Breast" | "Leggings" | "Weapon" | "Shield" | "Ring" | "Belt" | "Boots" | "Gloves" | "Amulet" | "Ring" | "Ring2" | "Horns" | "Overhead"
---@alias EquipmentSubType "Platemail" | "Robes" | "Leather" | "Belt" | "Ring" | "Amulet" | "Shield" | "Dagger" | "Sword" | "Axe" | "Mace" | "Sword" | "Spear" | "Staff" | "Bow" | "Crossbow" | "Wand"

---@alias StackType "Battered" | "B" | "Harried" | "H" | "Both"

---@alias Gender "Male" | "Female"
---@alias Race "Human" | "Elf" | "Dwarf" | "Lizard"

---@alias Keyword "ViolentStrike" | "VitalityVoid" | "Predator" | "Elementalist" | "Prosperity" | "Paucity" | "IncarnateChampion" | "Defiance" | "Occultist" | "Disintegrate" | "Wither" | "Centurion" | "Abeyance" | "Benevolence" | "Presence" | "Ward" | "Celestial" | "Purity" | "VolatileArmor" | "Voracity"
---@alias KeywordBoonType "Activator" | "Mutator"

---@class ScriptDefinition
---@field WIP boolean If true, the script will only load in the "sudo" developer mode.
---@field Developer boolean If true, the script will only load in developer mode.
---@field ScriptSet string Folder to load a set of scripts from (Shared.lua, Client.lua and Server.lua)
---@field Script string Filename
---@field Scripts string[] Extra scripts to load after the main script or scriptset.

---@class NetMessage

---------------------------------------------
-- UI
---------------------------------------------

---@alias UI_InputDevice "Any" | "Controller" | "KeyboardMouse"
---@alias FlashObjectHandle int64

---------------------------------------------
-- GAME.TOOLTIP
---------------------------------------------

---@class TooltipData
---@field Data table[]

---@type unknown
Osi = {}

---@class TooltipData
TooltipData = {}

---@param data table[]
---@return TooltipData
function TooltipData:Create(data) end

---@param type string
---@return table
function TooltipData:GetElement(type) end

---@param type string
---@return table[]
function TooltipData:GetElements(type) end

---@param type string
function TooltipData:RemoveElements(type) end

---@param type string
function TooltipData:RemoveElement(type) end

---@param ele table
function TooltipData:AppendElement(ele) end

---@param ele table
---@param appendAfter table
function TooltipData:AppendElementAfter(ele, appendAfter) end