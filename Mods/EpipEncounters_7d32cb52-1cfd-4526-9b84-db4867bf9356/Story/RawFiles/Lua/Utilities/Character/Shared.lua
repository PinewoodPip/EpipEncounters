
---@class CharacterLib : Library
Character = {
    AI_PREFERRED_TAG = "AI_PREFERRED_TARGET",
    AI_UNPREFERRED_TAG = "AI_UNPREFERRED_TARGET",
    AI_IGNORED_TAG = "AI_IGNORED_TARGET",

    ---@type table<string, ItemSlot>
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

    ---@type table<tag, Race>
    RACIAL_TAGS = {
        HUMAN = "Human",
        ELF = "Elf",
        DWARF = "Dwarf",
        LIZARD = "Lizard",
    },

    -- TODO Shield, Reflexes, PhysicalArmorMastery, MagicArmorMastery, VitalityMaster, Crafting, Charm, Intimidate, Reason, Wand, Runecrafting, Brewmaster, Sulfurology
    ---@type table<AbilityType, TranslatedStringHandle>
    ABILITY_TSKHANDLES = {
        ["WarriorLore"] = "h8e4bebcbg21c7g43dag8b05gd3b13c1be651",
        ["RangerLore"] = "h3d3dc89dgd286g418eg8134g2eb65d063514",
        ["RogueLore"] = "hed591025g5c39g48ccga899gc9b1569716c1",
        ["SingleHanded"] = "ha74334b1gd56bg49c2g8738g44da4decd00a",
        ["TwoHanded"] = "h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a",
        ["PainReflection"] = "h591d7502gb8c3g443cg86ebga0b3a903155a",
        ["Ranged"] = "hdda30cb9g17adg433ag9071g867e97c09c3a",
        ["Sourcery"] = "ha8b343fbg4ebbg4e72gb58fg633850ad0580",
        ["FireSpecialist"] = "hf0a5a77dg132ag4517g8701g9d2ca3057a28",
        ["WaterSpecialist"] = "h21354580g6870g411dgbef4g52f34942686a",
        ["AirSpecialist"] = "hf8056089g5b06g4a54g8dd5gf1fb9a796b53",
        ["EarthSpecialist"] = "h814e6bb5g3f51g4549gb3e4ge99e1d0017e1",
        ["Necromancy"] = "hb7ea4cc5g2a18g416bg9b95g51d928a60398",
        ["Summoning"] = "hac10f374gf9dbg4ee5gb5d0g7b1d3cb6d1fe",
        ["Polymorph"] = "h70714d89g196eg4affga165gaa9d72a61368",
        ["Telekinesis"] = "h455eb073g28abg4f3bgae9dga8a592a30cdb",
        ["Sneaking"] = "h6bf7caf0g7756g443bg926dg1ee5975ee133",
        ["Pickpocket"] = "h1ae6ac78gb2d3g4232g8910g2f26c76e5d62",
        ["Thievery"] = "h1633e511g35e3g4e22gb999gbbf3b0d5ce5e",
        ["Loremaster"] = "hb8aa942egbeaag4452gbfbcg31b493bead6e",
        ["Barter"] = "hcc404653ga10ag4f56g8119g11162e60f81d",
        ["Persuasion"] = "h257372d3g6f98g4450g813bg190e19aecce4",
        ["Luck"] = "h2f9ec5acgbcbeg45b8g8058gee363e6875d5",
        ["DualWielding"] = "h03d68693g35e7g4721ga1b3g9f9882f08b12",
        ["Perseverance"] = "h5b61fccfg5d2ag4a81g9cacg068403d61b5c",
    },
    -- Don't use these without a good reason! See the `ABILITY_TSKHANDLES` table instead.
    -- TODO Shield, Reflexes, PhysicalArmorMastery, MagicArmorMastery, VitalityMaster, Crafting, Charm, Intimidate, Reason, Wand, Runecrafting, Brewmaster, Sulfurology
    ---@type table<AbilityType, string>
    ABILITY_ENGLISH_NAMES = {
        ["WarriorLore"] = "Warfare",
        ["RangerLore"] = "Huntsman",
        ["RogueLore"] = "Scoundrel",
        ["SingleHanded"] = "Single-Handed",
        ["TwoHanded"] = "Two-Handed",
        ["PainReflection"] = "Retribution",
        ["Ranged"] = "Ranged",
        ["Sourcery"] = "Sourcery",
        ["FireSpecialist"] = "Pyrokinetic",
        ["WaterSpecialist"] = "Hydrosophist",
        ["AirSpecialist"] = "Aerotheurge",
        ["EarthSpecialist"] = "Geomancer",
        ["Necromancy"] = "Necromancer",
        ["Summoning"] = "Summoning",
        ["Polymorph"] = "Polymorph",
        ["Telekinesis"] = "Telekinesis",
        ["Sneaking"] = "Sneaking",
        ["Pickpocket"] = "Pickpocket",
        ["Thievery"] = "Thievery",
        ["Loremaster"] = "Loremaster",
        ["Barter"] = "Bartering",
        ["Persuasion"] = "Persuasion",
        ["Luck"] = "Lucky Charm",
        ["DualWielding"] = "Dual Wielding",
        ["Perseverance"] = "Perseverance",
    },

    -- Unfortunate, but we do not currently know how exactly the game keeps track of these.
    ---@type table<Race, skill[]>
    _RACIAL_SKILLS = {
        Human = {"Shout_InspireStart"},
        Elf = {"Shout_FleshSacrifice"},
        Dwarf = {"Target_PetrifyingTouch"},
        Lizard = {"Cone_Flamebreath"},
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        StatusApplied = {}, ---@type Event<CharacterLib_Event_StatusApplied>
        ItemEquipped = {}, ---@type Event<CharacterLib_Event_ItemEquipped>
    },
    Hooks = {
        CreateEquipmentVisuals = {}, ---@type Event<CharacterLib_Hook_CreateEquipmentVisuals> Client-only.
    },
}
Game.Character = Character -- Legacy alias.
Epip.InitializeLibrary("Character", Character)

---------------------------------------------
-- EVENTS
---------------------------------------------

---TODO move somewhere else, since victim could be an item
---@class CharacterLib_Event_StatusApplied
---@field SourceHandle EntityHandle
---@field Victim Character|Item
---@field Status EclStatus|EsvStatus

---@class CharacterLib_Event_ItemEquipped
---@field Character Character
---@field Item Item
---@field Slot ItemSlot

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIP_CharacterLib_StatusApplied : NetLib_Message
---@field OwnerNetID NetId
---@field StatusNetID NetId

---@class EPIP_CharacterLib_ItemEquipped : NetLib_Message_Character, NetLib_Message_Item

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class CharacterLib_StatusFromItem
---@field Status Status
---@field ItemSource Item

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char has a skill memorized. Returns true for innate skills.
---@param char Character
---@param skillID string
---@return boolean
function Character.IsSkillMemorized(char, skillID)
    local state = char.SkillManager.Skills[skillID]

    return state and state.IsLearned or Character.IsSkillInnate(char, skillID)
end

---Returns whether char has a skill learnt. Returns true for innate skills.
---@param char Character
---@param skillID string
---@return boolean
function Character.IsSkillLearnt(char, skillID)
    local state = char.SkillManager.Skills[skillID]

    return state and state.IsActivated or Character.IsSkillInnate(char, skillID)
end

---Returns the record for a skill.
---@param char Character
---@param skillID skill
---@return (EclSkill|EsvSkill)? -- `nil` if the character does not have the skill in any way.
function Character.GetSkill(char, skillID)
    local manager = char.SkillManager
    return manager.Skills[skillID]
end

---Returns the combat ID and team ID of char, if any.
---@param char Character
---@return integer?, integer? -- The combat ID and team ID. `nil` if the character is not in combat. This is different from the osi query, which returns a reserved value.
function Character.GetCombatID(char)
    local status = char:GetStatusByType("COMBAT") ---@cast status EclStatusCombat|EsvStatusCombat
    local id, teamID

    if status then
        local teamInfo = status.OwnerTeamId

        id, teamID = teamInfo.CombatId, teamInfo.CombinedId
    end

    return id, teamID
end

---Returns whether char has their weapon(s) unsheathed.
---@param char Character
---@return boolean
function Character.IsUnsheathed(char)
    return char:GetStatusByType("UNSHEATHED") ~= nil
end

---Returns whether char is currently the active character of any player.
---@return boolean
function Character.IsActive(char)
    return Osiris.CharacterIsControlled(char) == 1
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

---Returns wether char has a certain immunity.
---@param char Character
---@param immunityName StatsLib_ImmunityID
---@return boolean
function Character.HasImmunity(char, immunityName)
    return char.Stats[immunityName .. "Immunity"]
end

---Returns the equipped items of char, per slot.
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

        if item then
            items[slot] = item
        end
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
---@return integer --In "grams"
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

---Returns the initiative of char.
---@param char Character
---@return integer
function Character.GetInitiative(char)
    return char.Stats.Initiative
end

---Returns the computed resistance value of char.
---@param char Character
---@param damageType DamageType
---@param baseValuesOnly boolean? If `true`, base value will be returned. Defaults to `false`.
---@return integer
function Character.GetResistance(char, damageType, baseValuesOnly)
    return Ext.Stats.Math.GetResistance(char.Stats, damageType, baseValuesOnly)
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

---Returns whether char is ignored by AI.
---@param char Character
---@return boolean
function Character.IsIgnoredByAI(char)
    return char:HasTag(Character.AI_IGNORED_TAG)
end

---Returns whether char is a player.
---A player is any character that is controllable by the users,
---including summons and party followers.
---@param char Character
---@return boolean
function Character.IsPlayer(char)
    return char.IsPlayer
end

---Returns whether char is a non-generic origin.
---@param char Character
---@return boolean
function Character.IsOrigin(char)
    local isOrigin = false

    if char.PlayerCustomData then
        local originName = char.PlayerCustomData.OriginName

        isOrigin = string.match(originName, "Generic%d+") == nil
    end

    return isOrigin
end

---Returns true if char is a summon.
---@param char Character
---@return boolean
function Character.IsSummon(char)
    return char:HasTag("SUMMON") -- Summon flag does not do what's expected.
end

---Returns whether char is sneaking.
---@param char Character
---@return boolean
function Character.IsSneaking(char)
    return char:GetStatus("SNEAKING") ~= nil
end

---Returns whether char is invisible - as in, has the INVISIBLE status.
---@param char Character
---@return boolean
function Character.IsInvisible(char)
    return char:GetStatus("INVISIBLE") ~= nil
end

---Returns whether char is sneaking or invisible.
---@param char Character
---@return boolean
function Character.IsInStealth(char)
    return Character.IsSneaking(char) or Character.IsInvisible(char)
end

---Returns true if the character is dead.
---@param char Character
---@return boolean
function Character.IsDead(char)
    return char:GetStatus("DYING") ~= nil
end

---Returns a status by handle.
---@param char Character
---@param handle EntityHandle
---@return EclStatus|EsvStatus
function Character.GetStatusByHandle(char, handle)
    return Ext.Entity.GetStatus(char.Handle, handle)
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
---Checks racial tags.
---@param char Character
---@return Race?
function Character.GetRace(char)
    local characterRace = nil
    for tag,race in pairs(Character.RACIAL_TAGS) do
        if char:HasTag(tag) then
            characterRace = race
            break
        end
    end
    return characterRace
end

---Returns the original race of a player char, before any transforms.
---@param char Character Must be tagged with "REALLY_{Race}"
---@return Race?
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
---@param char Character
---@return boolean
function Character.IsInCombat(char)
    return char:GetStatus("COMBAT") ~= nil
end

---Returns the calculated movement stat of a character.
---@param char Character
---@return number -- In centimeters.
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
    for slot in Item.ITEM_SLOTS:Iterator() do
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
    if weapon then weapon = Item.Get(weapon) end
    
    local offhand = char:GetItemBySlot("Shield")
    if offhand then offhand = Item.Get(offhand) end
    
    return Item.IsMeleeWeapon(weapon) or Item.IsMeleeWeapon(offhand)
end

---Returns whether char has a bow or crossbow equipped.
---@param char Character
---@return boolean
function Character.HasRangedWeapon(char)
    local weapon = char:GetItemBySlot("Weapon")
    if weapon then weapon = Item.Get(weapon) end

    return Item.IsRangedWeapon(weapon)
end

---Returns the current and maximum source points of char.
---@param char Character
---@return integer, integer --Current and maximum points.
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
    if offhand then offhand = Item.Get(offhand) end

    return Item.IsShield(offhand)
end

---Returns whether char has a dagger equipped in either slot.
---@param char Character
---@return boolean
function Character.HasDagger(char)
    local weapon = char:GetItemBySlot("Weapon")
    if weapon then weapon = Item.Get(weapon) end
    
    local offhand = char:GetItemBySlot("Shield")
    if offhand then offhand = Item.Get(offhand) end

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

---Returns the level of char.
---@param char Character
---@return integer
function Character.GetLevel(char)
    return char.Stats.Level
end

---Returns the current experience points of char.
---@param char Character
---@return integer
function Character.GetExperience(char)
    return char.Stats.Experience
end

---Returns the **cumulative** experience required to reach a level.
---@param targetLevel integer
---@return integer --Experience points.
function Character.GetExperienceRequiredForLevel(targetLevel)
    local levelCap = Stats.Get("Data", "LevelCap") or 1
    local totalXp = 0

    for level=1,targetLevel - 1,1 do
        local levelXp 

        if level <= 0 or level >= levelCap then
            levelXp = 0
        else
            local v8
            local v9 = 1
            local over8Scaler = math.min(level, 8)
            local levelsOver8 = level - over8Scaler

            v8 = over8Scaler * (over8Scaler + 1)

            if level - over8Scaler > 0 then
                v9 = 1.39 ^ levelsOver8 -- This part has had a compiler pow() optimization removed.
            end

            v8 = Ext.Round(v8 * v9)

            levelXp = 25 * ((1000 * v8 + 24) // 25)
        end

        totalXp = totalXp + levelXp
    end

    return totalXp
end

---Returns the contents of a character's skillbar row.
---@param char Character Must be a player.
---@param row integer
---@param slotsPerRow integer? Defaults to 29.
---@return EocSkillBarItem[]
function Character.GetSkillBarRowContents(char, row, slotsPerRow)
    slotsPerRow = slotsPerRow or 29
    local skillBar = char.PlayerData.SkillBarItems
    local items = {}

    local startingIndex = (row - 1) * slotsPerRow
    for i=1,slotsPerRow,1 do
        local slotIndex = startingIndex + i
        local slot = skillBar[slotIndex]

        table.insert(items, slot)
    end

    return items
end

---Returns a status on char by its net ID.
---@param char Character
---@param netID NetId
---@return EclStatus|EsvStatus
function Character.GetStatusByNetID(char, netID)
    local statuses = char:GetStatusObjects() ---@type (EclStatus|EsvStatus)[]
    local status

    for _,obj in ipairs(statuses) do
        if obj.NetID == netID then
            status = obj
            break
        end
    end

    return status
end

---Returns the current skill state of char.
---**On the server, this can only return the state while using the skill. Preparation state cannot be accessed.**
---@param char Character
---@return (EclSkillState|EsvSkillState)?
function Character.GetSkillState(char)
    local state

    if Ext.IsClient() then
        state = char.SkillManager.CurrentSkill
    else
        local layers = char.ActionMachine.Layers
        local actionState = layers[1] and layers[1].State

        if actionState and (actionState.Type == "UseSkill") then
            ---@cast actionState EsvASUseSkill
            state = actionState.Skill
        end
    end

    return state
end

---Returns the ID of the skill that char is preparing or casting.
---@param char Character
---@return string? --`nil` if the character has no active skill state.
function Character.GetCurrentSkill(char)
    local state = Character.GetSkillState(char)
    local skill = nil

    if state then
        skill = state.SkillId
        skill = string.sub(skill, 0, #skill - 3)
    end

    return skill
end

---Returns whether char is preparing a skill.
---@param char Character
---@return boolean
function Character.IsPreparingSkill(char)
    local state = Character.GetSkillState(char)

    ---@diagnostic disable-next-line: undefined-field
    return state and (state.State.Value == Ext.Enums.SkillStateType.PickTargets.Value or state.State.Value == Ext.Enums.SkillStateType.Preparing.Value)
end

---Returns whether char is casting a skill.
---@param char Character
---@return boolean
function Character.IsCastingSkill(char)
    local state = Character.GetSkillState(char)

    ---@diagnostic disable-next-line: undefined-field
    return state and state.State.Value >= Ext.Enums.SkillStateType.Casting.Value
end

---Throws the ItemEquipped event.
---@param character Character
---@param item Item
function Character._ThrowItemEquippedEvent(character, item)
    local equippedSlot

    -- Prevent firing the event if the item was destroyed
    if item then
        if Ext.IsServer() then
            equippedSlot = item.Slot
        else
            equippedSlot = item.CurrentSlot
        end

        Character.Events.ItemEquipped:Throw({
            Character = character,
            Item = item,
            Slot = Ext.Enums.ItemSlot[equippedSlot],
        })
    end
end
