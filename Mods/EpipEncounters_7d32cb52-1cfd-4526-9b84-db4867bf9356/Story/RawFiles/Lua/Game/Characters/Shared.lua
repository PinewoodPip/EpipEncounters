
---@meta Library: GameCharacter, ContextShared, Game.Character
 

Game.Character = {
    AI_PREFERRED_TAG = "AI_PREFERRED_TARGET",
    AI_UNPREFERRED_TAG = "AI_UNPREFERRED_TARGET",
    AI_IGNORED_TAG = "AI_IGNORED_TARGET",
}
Character = Game.Character
Epip.InitializeFeature("Character", "Game.Character", Character)

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
    for i,status in pairs(char:GetStatuses()) do
        local amount = status:match(pattern)

        if amount then
            stacks = tonumber(amount)
            lifetime = char:GetStatus(status).CurrentLifeTime
            break
        end
    end

    return stacks,lifetime
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

    for i,status in pairs(char:GetStatuses()) do
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
    return char:HasTag("SUMMON")
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

    for i,tag in ipairs(char:GetTags()) do
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