
---@alias Entity EclCharacter | EsvCharacter | EclItem | EsvItem
---@alias Character EsvCharacter | EclCharacter
---@alias Item EclItem | EsvItem
---@alias GUID string
---@alias PrefixedGUID string
---@alias Context "Client" | "Server" 
---@alias pattern string
---@alias TranslatedStringHandle string

---@alias EquipSlot "Helmet" | "Breast" | "Leggings" | "Weapon" | "Shield" | "Ring" | "Belt" | "Boots" | "Gloves" | "Amulet" | "Ring" | "Ring2" | "Horns" | "Overhead"
---@alias EquipmentSubType "Platemail" | "Robes" | "Leather" | "Belt" | "Ring" | "Amulet" | "Shield" | "Dagger" | "Sword" | "Axe" | "Mace" | "Sword" | "Spear" | "Staff" | "Bow" | "Crossbow" | "Wand"

---@alias StackType "Battered" | "B" | "Harried" | "H" | "Both"

---@alias Gender "Male" | "Female"
---@alias Race "Human" | "Elf" | "Dwarf" | "Lizard"

---@alias Keyword "ViolentStrike" | "VitalityVoid" | "Predator" | "Elementalist" | "Prosperity" | "Paucity" | "IncarnateChampion" | "Defiance" | "Occultist" | "Disintegrate" | "Wither" | "Centurion" | "Abeyance" | "Benevolence" | "Presence" | "Ward" | "Celestial" | "Purity" | "VolatileArmor" | "Voracity"
---@alias KeywordBoonType "Activator" | "Mutator"

---@class Vector2D
---@field x number
---@field y number

---------------------------------------------
-- UI
---------------------------------------------

---@alias InputDevice "Any" | "Controller" | "KeyboardMouse"
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