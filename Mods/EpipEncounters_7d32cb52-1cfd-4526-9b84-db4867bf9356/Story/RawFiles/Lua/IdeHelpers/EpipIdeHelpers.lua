
---@alias Entity EclCharacter|EsvCharacter|EclItem|EsvItem
---@alias Character EsvCharacter|EclCharacter
---@alias Item EclItem|EsvItem
---@alias Status EclStatus|EsvStatus
---@alias GUID string
---@alias PrefixedGUID string
---@alias Context "Client"|"Server" 
---@alias pattern string
---@alias path string
---@alias bitfield integer
---@alias TranslatedStringHandle string
---@alias ModTableID string|"EpipEncounters"
---@alias monotonictimestamp integer
---@alias modtable string
---@alias date string

---@alias UIObjectHandle ComponentHandle

---@alias ClientGameObject EclCharacter|EclItem

---@class Enum
---@field Label string
---@field Value string

Mods = {}

---@alias EquipSlot "Helmet" | "Breast" | "Leggings" | "Weapon" | "Shield" | "Ring" | "Belt" | "Boots" | "Gloves" | "Amulet" | "Ring" | "Ring2" | "Horns" | "Overhead"

---@alias StackType "Battered" | "B" | "Harried" | "H" | "Both"

---@alias Gender "Male" | "Female"
---@alias Race "Human" | "Elf" | "Dwarf" | "Lizard"

---@alias icon string

---@alias Keyword "ViolentStrike" | "VitalityVoid" | "Predator" | "Elementalist" | "Prosperity" | "Paucity" | "IncarnateChampion" | "Defiance" | "Occultist" | "Disintegrate" | "Wither" | "Centurion" | "Abeyance" | "Benevolence" | "Presence" | "Ward" | "Celestial" | "Purity" | "VolatileArmor" | "Voracity"
---@alias KeywordBoonType "Activator" | "Mutator"

---@class NetMessage

---------------------------------------------
-- UI
---------------------------------------------

---@alias UI_InputDevice "Any" | "Controller" | "KeyboardMouse"

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

---------------------------------------------
-- META
---------------------------------------------

---@alias ScriptContext "Shared"|"Client"|"Server"

---------------------------------------------
-- FROM OLD ExtIdeHelpers
---------------------------------------------

---@alias StatsPropertyContext string|"Self"|"SelfOnHit"|"SelfOnEquip"|"AoE"|"Target"
---@alias EsvGameState string|"Idle"|"Sync"|"Running"|"Unknown"|"Save"|"Uninitialized"|"LoadLevel"|"ReloadStory"|"LoadModule"|"LoadSession"|"Init"|"LoadGMCampaign"|"UnloadLevel"|"UnloadModule"|"UnloadSession"|"Disconnect"|"Installation"|"GameMasterPause"|"Exit"|"Paused"|"BuildStory"