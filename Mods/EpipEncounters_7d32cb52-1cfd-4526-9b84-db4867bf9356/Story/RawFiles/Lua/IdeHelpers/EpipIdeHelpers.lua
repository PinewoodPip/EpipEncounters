
---@meta

---@alias Entity EclCharacter|EsvCharacter|EclItem|EsvItem
---@alias Character EsvCharacter|EclCharacter
---@alias Item EclItem|EsvItem
---@alias Status EclStatus|EsvStatus
---@alias GUID string
---@alias GUID.Character GUID
---@alias GUID.ItemTemplate GUID
---@alias GUID.Mod GUID
---@alias PrefixedGUID string
---@alias Context "Client"|"Server" -- TODO replace with lowercase
---@alias context "Client"|"Server"
---@alias pattern string
---@alias path string
---@alias bitfield integer
---@alias TranslatedStringHandle string
---@alias ModTableID string|"EpipEncounters"
---@alias monotonictimestamp integer
---@alias modtable string
---@alias date string
---@alias skill string Skill ID.
---@alias tag string
---@alias htmlcolor string May be prefixed with "#"
---@alias listenabletype "Event"|"Hook"
---@alias language string
---@alias inputdevice "KeyboardAndMouse"|"Controller"

---@alias UIObjectHandle ComponentHandle

---@alias ClientGameObject EclCharacter|EclItem

---@alias CharacterHandle ComponentHandle
---@alias ItemHandle ComponentHandle
---@alias FlashCharacterHandle FlashObjectHandle
---@alias FlashItemHandle FlashObjectHandle

---@alias iggyevent string -- In the format "IE EventName"

---@class set<T> : {[T]:true}

---@class Empty

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