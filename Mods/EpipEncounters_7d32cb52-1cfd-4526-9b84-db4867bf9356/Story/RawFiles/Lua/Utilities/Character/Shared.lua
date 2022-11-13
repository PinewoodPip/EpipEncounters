
---@class CharacterLib : Library
Character = {
    AI_PREFERRED_TAG = "AI_PREFERRED_TARGET",
    AI_UNPREFERRED_TAG = "AI_UNPREFERRED_TARGET",
    AI_IGNORED_TAG = "AI_IGNORED_TARGET",

    ---@enum ItemSlot
    EQUIPMENT_SLOTS = {
        HELMET = "Helmet",
        BREAST = "Breast",
        LEGGINGS = "Leggings",
        WEAPON = "Weapon",
        SHIELD = "Shield",
        RING = "Ring",
        BELT = "Belt",
        BOOTS = "Boots",
        GLOVES = "Gloves",
        AMULET = "Amulet",
        RING2 = "Ring2",
        WINGS = "Wings",
        HORNS = "Horns",
        OVERHEAD = "Overhead",
    },

    EQUIPMENT_VISUAL_CLASS = {
        HUMAN_MALE = 1,
        HUMAN_FEMALE = 2,
        DWARF_MALE = 3,
        DWARF_FEMALE = 4,
        ELF_MALE = 5,
        ELF_FEMALE = 6,
        LIZARD_MALE = 7,
        LIZARD_FEMALE = 8,

        NONE = 9,
        
        UNDEAD_HUMAN_MALE = 10,
        UNDEAD_HUMAN_FEMALE = 11,
        UNDEAD_DWARF_MALE = 12,
        UNDEAD_DWARF_FEMALE = 13,
        UNDEAD_ELF_MALE = 14,
        UNDEAD_ELF_FEMALE = 15,
        UNDEAD_LIZARD_MALE = 16,
        UNDEAD_LIZARD_FEMALE = 17,

    },

    ---@enum CharacterLib_EquipmentVisualMask
    EQUIPMENT_VISUAL_MASKS = {
        NONE = 0,
        HELMET = 1,
        BREAST = 2,
        LEGGINGS = 4,
        WEAPON = 8,
        SHIELD = 16,
        RING = 32,
        BELT = 64,
        BOOTS = 128,
        GLOVES = 256,
        AMULET = 512,
        RING_2 = 1024,
        WINGS = 2048,
        HORNS = 4096,
        OVERHEAD = 8192,
        SENTINEL = 16384,
        -- Unknown if more exist
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {},
    Hooks = {
        CreateEquipmentVisuals = {}, ---@type Event<CharacterLib_Hook_CreateEquipmentVisuals> Client-only.
    },
}
Game.Character = Character
Epip.InitializeLibrary("Character", Character)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class CharacterLib_StatusFromItem
---@field Status Status
---@field ItemSource Item

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the current stacks on char, as well as lifetime. Queries the related status effects.
---@meta EE
---@param char Character
---@param type StackType
---@return number,number Stack count, duration left (as seconds)
function Character.GetStacks(char, type)
    local stacks = 0
    local lifetime = 0
    local pattern = Data.Patterns.BATTERED_STATUS -- Default to Battered

    if type == "Harried" or type == "H" then
        pattern = Data.Patterns.HARRIED_STATUS
    end

    -- Search statuses
    for _,status in pairs(char:GetStatuses()) do
        local amount = status:match(pattern)

        if amount then
            stacks = tonumber(amount)
            lifetime = char:GetStatus(status).CurrentLifeTime
            break
        end
    end

    return stacks,lifetime
end

---Returns the combat ID and team ID of char, if any.
---@param char Character
---@return integer?, integer? -- The combat ID and team ID. Nil if the character is not in combat. This is different from the osi query, which returns a reserved value.
function Character.GetCombatID(char)
    local status = char:GetStatusByType("COMBAT") ---@type EclStatusCombat
    local id, teamID

    if status then
        id, teamID = status.CombatTeamId.CombatId, status.CombatTeamId.CombinedId
    end

    return id, teamID
end

---Returns whether char has their weapon(s) unsheathed.
---@param char Character
---@return boolean
function Character.IsUnsheathed(char)
    return char:GetStatusByType("UNSHEATHED") ~= nil
end

---Returns whether char has an owner.
---@param char Character
---@return boolean
function Character.HasOwner(char)
    return char.HasOwner
end

---Returns the character's owner, if it is a summon or party follower(?).
---@param char Character
---@return Character?
function Character.GetOwner(char)
    local ownerHandle

    -- Unfortunate inconsistency.
    if char.HasOwner then
        if Ext.IsClient() then
            ownerHandle = char.OwnerCharacterHandle
        else
            ownerHandle = char.OwnerHandle
        end
    end

    return ownerHandle and Character.Get(ownerHandle)
end

---Returns whether a skill is innate to a character.
---Returns false if the character doesn't have the skill in any way.
---@param char Character
---@param skillID string
---@return boolean
function Character.IsSkillInnate(char, skillID)
    local playerData = char.SkillManager.Skills[skillID]
    local stat = Stats.Get("SkillData", skillID)
    local innate = false

    if stat and playerData then
        innate = stat["Memory Cost"] == 0 or playerData.ZeroMemory
    end

    return innate
end

---@param char Character
---@return table<ItemSlot, EclItem>
function Character.GetEquippedItems(char)
    local items = {}

    for _,slot in pairs(Character.EQUIPMENT_SLOTS) do
        local item

        if Ext.IsClient() then
            item = char:GetItemBySlot(slot)
            if item then
                item = Item.Get(item)
            end
        else
            item = Osiris.CharacterGetEquippedItem(char, slot)
            if item then
                item = Item.Get(item)
            end
        end

        table.insert(items, item)
    end

    return items
end

---@param char Character
---@param statName string
function Character.GetDynamicStat(char, statName)
    local total = 0
    local dynStats = char.Stats.DynamicStats

    for i=1,#dynStats,1 do
        local dynStat = dynStats[i]

        total = total + dynStat[statName]
    end

    return total
end

---Returns the maximum carry weight of char.
---@param char Character
---@return integer In "grams"
function Character.GetMaxCarryWeight(char)
    local base = Stats.ExtraData.CarryWeightBase:GetValue()
    local strScaling = Stats.ExtraData.CarryWeightPerStr:GetValue()
    local strength = char.Stats.Strength

    return base + (strength * strScaling)
end

---@param char Character
---@return integer, integer --Current, maximum
function Character.GetActionPoints(char)
    return char.Stats.CurrentAP, char.Stats.APMaximum
end

---@param identifier GUID|PrefixedGUID|NetId|EntityHandle
---@param isFlashHandle boolean? If true, the identifier will be passed through DoubleToHandle() first.
---@return Character
function Character.Get(identifier, isFlashHandle)
    if isFlashHandle then
        identifier = Ext.UI.DoubleToHandle(identifier)
    end

    return Ext.Entity.GetCharacter(identifier)
end

---@param char Character
---@return boolean
function Character.IsPreferredByAI(char)
    return char:HasTag(Character.AI_PREFERRED_TAG)
end

---Returns whether char is unpreferred by AI.
---@param char Character
---@return boolean
function Character.IsUnpreferredByAI(char)
    return char:HasTag(Character.AI_UNPREFERRED_TAG)
end

---Returns whether char is ignroed by AI.
---@param char Character
---@return boolean
function Character.IsIgnoredByAI(char)
    return char:HasTag(Character.AI_IGNORED_TAG)
end

---Get the infusion level that char is currently preparing (how many times they've cast Source Infuse).
---@meta EE
---@param char Character
---@return number Infusion count.
function Character.GetPreparedInfusionLevel(char)
    local level = 0

    for _,status in pairs(char:GetStatuses()) do
        local match = status:match(Data.Patterns.SOURCE_INFUSING_STATUS)
        if match then
            level = tonumber(match)
            break
        end
    end

    return level
end

---Returns true if char is preparing a Source Infusion.
---@meta EE
---@param char Character
---@return boolean
function Character.IsPreparingInfusion(char)
    return Character.GetPreparedInfusionLevel(char) > 0
end

---Get the stack amount this character needs to apply a T3 to someone else.
---**This only takes into account the bonus from infusing!**
---@meta EE
---@param char Character
---@return number Stacks needed
function Character.GetStacksNeededToInflictTier3(char)
    local amount = Data.Game.T3_STACKS_REQUIREMENT

    if Character.IsPreparingInfusion(char) then
        amount = amount - Data.Game.T3_STACKS_REQUIREMENT_INFUSING_REDUCTION
    end

    return amount
end

---Returns true if char is a summon.
---@param char Character
---@return boolean
function Character.IsSummon(char)
    return char:HasTag("SUMMON") -- Summon flag does not do what's expected.
end

---Returns true if the character is dead.
---@param char Character
---@return boolean
function Character.IsDead(char)
    return char:GetStatus("DYING") ~= nil
end

---Returns the gender of char.
---@param char Character
---@return Gender
function Character.GetGender(char)
    local gender = "Male"

    if not Character.IsMale(char) then
        gender = "Female"
    end

    return gender
end

---Returns true if char is male.
---@param char Character
---@return boolean
function Character.IsMale(char)
    return char:HasTag("MALE")
end

---Returns true if char is undead.
---@param char Character
---@return boolean
function Character.IsUndead(char)
    return char:HasTag("UNDEAD")
end

---Returns the current race of char.
---@param char Character
---@return Race
function Character.GetRace(char)
    local racialTags = {
        HUMAN = "Human",
        ELF = "Elf",
        DWARF = "Dwarf",
        LIZARD = "Lizard",
    }

    local characterRace = nil

    for tag,race in pairs(racialTags) do
        if char:HasTag(tag) then
            characterRace = race
            break
        end
    end

    return characterRace
end

---Returns the original race of a player char, before any transforms.
---@param char Character Must be tagged with "REALLY_{Race}"
---@return Race
function Character.GetRealRace(char)
    local pattern = "^REALLY_(.+)$"
    local race = nil

    for _,tag in ipairs(char:GetTags()) do
        local match = tag:match(pattern)

        if match then
            race = match
            break
        end
    end

    if race then
        race = race:lower()
        race = race:sub(1, 1):upper() .. race:sub(2)
    end

    return race
end

---Returns whether the character is in a combat.
---@param char EclCharacter
---@return boolean
function Character.IsInCombat(char)
    return char:GetStatus("COMBAT") ~= nil
end

---@param char Character
---@return number In centimeters.
function Character.GetMovement(char)
    local movement = 0
    local movementBoost = 100
    local dynStats = char.Stats.DynamicStats

    -- Character
    for i=1,#dynStats,1 do
        -- TODO general function for tallying dynstats
        local dynStat = dynStats[i]
        movement = movement + dynStat.Movement
        movementBoost = movementBoost + dynStat.MovementSpeedBoost
    end

    -- Items
    for _,slot in ipairs(Data.Game.EQUIP_SLOTS) do
        local statItem = char.Stats:GetItemBySlot(slot)

        if statItem then
            dynStats = statItem.DynamicStats
            for i=1,#dynStats,1 do
                local dynStat = dynStats[i]
                movement = movement + dynStat.Movement
                movementBoost = movementBoost + dynStat.MovementSpeedBoost
            end
        end
    end

    -- Add scoundrel bonus
    movement = movement + char.Stats.RogueLore * Stats.ExtraData.SkillAbilityMovementSpeedPerPoint:GetValue()

    return movement * (movementBoost / 100)
end

---Returns whether char can enter preparation state for a skill.
---@param char Character
---@param skillID string
---@param itemSource Item?
---@return boolean
function Character.CanUseSkill(char, skillID, itemSource)
    return Game.Stats.MeetsRequirements(char, skillID, false, itemSource)
end

---Returns whether char has a melee weapon equipped in either slot.
---@param char Character
---@return boolean
function Character.HasMeleeWeapon(char)
    local weapon = char:GetItemBySlot("Weapon")
    if weapon then weapon = Ext.Entity.GetItem(weapon) end
    
    local offhand = char:GetItemBySlot("Shield")
    if offhand then offhand = Ext.Entity.GetItem(offhand) end
    
    return Item.IsMeleeWeapon(weapon) or Item.IsMeleeWeapon(offhand)
end

---Returns whether char has a bow or crossbow equipped.
---@param char Character
---@return boolean
function Character.HasRangedWeapon(char)
    local weapon = char:GetItemBySlot("Weapon")
    if weapon then weapon = Ext.Entity.GetItem(weapon) end

    return Item.IsRangedWeapon(weapon)
end

---Returns the current and maximum source points of char.
---@param char Character
---@return integer, integer Current and maximum points.
function Character.GetSourcePoints(char)
    local current, max = char.Stats.MPStart, char.Stats.MaxMp
    if char.Stats.MaxMpOverride ~= -1 then max = char.Stats.MaxMpOverride end

    return current, max
end

---Returns whether char has a shield equipped.
---@param char Character
---@return boolean
function Character.HasShield(char)
    local offhand = char:GetItemBySlot("Shield")
    if offhand then offhand = Ext.Entity.GetItem(offhand) end

    return Item.IsShield(offhand)
end

---Returns whether char has a dagger equipped in either slot.
---@param char Character
---@return boolean
function Character.HasDagger(char)
    local weapon = char:GetItemBySlot("Weapon")
    if weapon then weapon = Ext.Entity.GetItem(weapon) end
    
    local offhand = char:GetItemBySlot("Shield")
    if offhand then offhand = Ext.Entity.GetItem(offhand) end

    return Item.IsDagger(weapon) or Item.IsDagger(offhand)
end

---Returns whether char is muted.
---@param char Character
---@return boolean
function Character.IsMuted(char)
    return char:GetStatusByType("MUTED") ~= nil
end

---Returns whether char is disarmed.
---@param char Character
---@return boolean
function Character.IsDisarmed(char)
    return char:GetStatusByType("DISARMED") ~= nil
end

---Gets the highest stat score of all characters in char's party.
---@param char Character
---@param ability string Needs to be a property indexable in char.Stats
---@return integer
function Character.GetHighestPartyAbility(char, ability)
    local highest = 0

    for _,member in ipairs(Character.GetPartyMembers(char)) do
        local score = member.Stats[ability]

        if score > highest then
            highest = score
        end
    end

    return highest
end