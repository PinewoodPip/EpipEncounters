
Game.Talents.TalentsToAddAfterCC = {}
local Talents = Game.Talents

function Game.Talents:ValidateTalentRequirements(char)

    if char == nil then return nil end -- todo happens post CC
    
    for id,data in pairs(self.customTalents) do
        if self:HasTalent(char, id) then
            if not self:MeetsRequirements(char, id) then
                Utilities.LogWarning("Server.Talents", string.format("%s lost %s due to requirements having been unmet.", char.DisplayName, id))

                self:RemoveTalent(char, id)
            end
        end
    end
end

Net.RegisterListener("EPIPENCOUNTERS_CharacterSheet_AddTalent", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local talent = payload.Talent

    if not Game.Talents.customTalents[talent] then
        Utilities.LogError("Server.Talents", "Tried to add a talent that is not defined. Make sure you register talents on both server and client: " .. talent)
        return nil
    end

    Net.PostToCharacter(char.MyGuid, "EPIPENCOUNTERS_CharacterSheet_RefreshTalents", {TalentPointsOffset = -1})

    local isCharacterCreation = #Osi.DB_InCharacterCreation:Get(1) > 0
    if isCharacterCreation then
        local id = CharacterGetReservedUserID(char.MyGuid)

        Talents:QueueTalentAddition(id, talent)
        return nil
    end

    local isRespeccing = #Osi.DB_Illusionist:Get(char.MyGuid, nil) > 0
    if isRespeccing then
        Osi.PROC_PIP_Talents_TogglePending(char.MyGuid, talent, 1)
        return nil
    end

    Game.Talents:AddTalent(char, talent)    
end)

Net.RegisterListener("EPIPENCOUNTERS_CharacterSheet_RemoveTalent", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local talent = payload.Talent

    Net.PostToCharacter(char.MyGuid, "EPIPENCOUNTERS_CharacterSheet_RefreshTalents", {TalentPointsOffset = 1})

    local isCharacterCreation = #Osi.DB_InCharacterCreation:Get(1) > 0
    if isCharacterCreation then
        local id = CharacterGetReservedUserID(char.MyGuid)

        Talents:QueueTalentAddition(id, nil)
        return nil
    end

    local isRespeccing = #Osi.DB_Illusionist:Get(char.MyGuid, nil) > 0
    if isRespeccing then
        Osi.PROC_PIP_Talents_TogglePending(char.MyGuid, talent, -1)
        return nil
    end

    Game.Talents:RemoveTalent(char, talent)
end)

-- todo support vanilla
function Game.Talents:HasTalent(char, talent)
    return char:HasTag(talent)
end

function Game.Talents:AddTalent(char, talent, isVanilla)

    local points = Osi.CharacterGetTalentPoints(char.MyGuid)
    if points < 1 then
        Utilities.LogWarning("Talents.Server", "Tried to add custom talent to character with no talent points!")
        return nil
    end

    Osi.SetTag(char.MyGuid, talent)
    Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, talent, 1.0);

    CharacterAddTalentPoint(char.MyGuid, -1)

    Utilities.Log("Talents.Server", char.DisplayName .. " gained " .. talent)
end

function Game.Talents:RemoveTalent(char, talent, isVanilla)

    if not Game.Talents:HasTalent(char, talent) then
        Utilities.LogWarning("Talents.Server", "Tried to remove " .. talent .. " from character that did not have it: " .. char.DisplayName)
        return nil
    end

    Osi.ClearTag(char.MyGuid, talent)
    Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, talent, -1.0);

    CharacterAddTalentPoint(char.MyGuid, 1)

    Utilities.Log("Talents.Server", char.DisplayName .. " lost " .. talent)
end

-- For NRD_ModCall
function TalentsToggle(char, talent, toggle)
    char = Ext.GetCharacter(char)
    if toggle == "1" then
        Game.Talents:AddTalent(char, talent)
    else
        Game.Talents:RemoveTalent(char, talent)
    end
    Utilities.Log("Server.Talents", "Toggled " .. talent .. " on " .. char.DisplayName .. " from mirror.")
end

-- During character creation, we save the chosen talents to add them for real post-creation.
function Game.Talents:QueueTalentAddition(userId, talent)
    self.TalentsToAddAfterCC[userId] = talent -- todo support more
end

Ext.Osiris.RegisterListener("PROC_AMER_GEN_CCFinished_GameStarted", 0, "after", function()
    for user,talent in pairs(Talents.TalentsToAddAfterCC) do
        local char = GetCurrentCharacter(user)

        Game.Talents:AddTalent(Ext.GetCharacter(char), talent)
    end
end)

Ext.Osiris.RegisterListener("CharacterAddToCharacterCreation", 3, "before", function(char, mode, result)

    Utilities.Log("Server.Talents", char .. " added to Character Creation")
    -- Net.PostToCharacter(char, "EPIPENCOUNTERS_Talents_CountAbilities", {})

    -- TODO fix properly
    -- Ext.Print("db:")
    -- Ext.Dump(Osi.DB_InCharacterCreation:Get(1))
    -- if #Osi.DB_InCharacterCreation:Get(1) > 0 then
    --     return nil
    -- end

    local talentsDefined = false

    for i,v in pairs(Talents.customTalents) do
        talentsDefined = true
        break
    end

    if talentsDefined then
        Net.PostToCharacter(char, "EPIPENCOUNTERS_CharacterSheet_RefreshTalents", {TalentPointsOffset = -99})
        Osi.PROC_PIP_Talents_RespecRememberTruePoints(char, 99)
    else
        Net.PostToCharacter(char, "EPIPENCOUNTERS_CharacterSheet_RefreshTalents", {TalentPointsOffset = 0})
        Osi.PROC_PIP_Talents_RespecRememberTruePoints(char, 0)
    end
end)

-- After exiting character creation, double-check requirements of custom talents and remove the ones that can no longer be sustained. An example scenario is All Skilled Up being removed.
Ext.Osiris.RegisterListener("CharacterCreationFinished", 1, "after", function(char)
    Net.PostToCharacter(char, "EPIPENCOUNTERS_Talents_CharacterCreationFinished", {})

    Game.Talents:ValidateTalentRequirements(Ext.GetCharacter(char))
end)

Net.RegisterListener("EPIPENCOUNTERS_Talents_RequestPoints", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local points = CharacterGetTalentPoints(char.MyGuid)
    Net.PostToCharacter(char.MyGuid, "EPIPENCOUNTERS_Talents_SendPoints", {Points = points})
end)