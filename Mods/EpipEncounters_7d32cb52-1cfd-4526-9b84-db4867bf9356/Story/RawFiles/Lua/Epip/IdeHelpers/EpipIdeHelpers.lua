
---@alias Entity EclCharacter | EsvCharacter | EclItem | EsvItem
---@alias Character EsvCharacter | EclCharacter
---@alias Item EclItem | EsvItem
---@alias GUID string
---@alias PrefixedGUID string
---@alias Context "Client" | "Server" 
---@alias pattern string

---@alias EquipSlot "Helmet" | "Breast" | "Leggings" | "Weapon" | "Shield" | "Ring" | "Belt" | "Boots" | "Gloves" | "Amulet" | "Ring" | "Ring2" | "Horns" | "Overhead"
---@alias EquipmentSubType "Platemail" | "Robes" | "Leather" | "Belt" | "Ring" | "Amulet" | "Shield" | "Dagger" | "Sword" | "Axe" | "Mace" | "Sword" | "Spear" | "Staff" | "Bow" | "Crossbow" | "Wand"

---@alias StackType "Battered" | "B" | "Harried" | "H"

---@alias Gender "Male" | "Female"
---@alias Race "Human" | "Elf" | "Dwarf" | "Lizard"

---@alias Keyword "ViolentStrike" | "VitalityVoid" | "Predator" | "Elementalist" | "Prosperity" | "Paucity" | "IncarnateChampion" | "Defiance" | "Occultist" | "Disintegrate" | "Wither" | "Centurion" | "Abeyance" | "Benevolence" | "Presence" | "Ward" | "Celestial" | "Purity" | "VolatileArmor" | "Voracity"
---@alias KeywordBoonType "Activator" | "Mutator"

---------------------------------------------
-- UI
---------------------------------------------

---@alias InputDevice "Any" | "Controller" | "KeyboardMouse"
---@alias MessageBoxType "Message" | "Input"

---------------------------------------------
-- GAME.TOOLTIP
---------------------------------------------

---@class TooltipData
---@field Data table[]

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