
Game.Talents = {
    customTalents = {},

    -- IDs of custom talents follow the format MyMod_Talent_MyTalent
    TALENT_ID_INFIX = "_Talent_",
}

local Talents = Game.Talents

-- Needs to be called on both contexts!
function Talents.RegisterTalent(self, mod, id, data)
    local fullId = mod .. self.TALENT_ID_INFIX .. id

    if not data.requirements then 
        data.requirements = {}
    end
    if not data.requirements.abilities then data.requirements.abilities = {} end
    if not data.requirements.attributes then data.requirements.attributes = {} end

    self.customTalents[fullId] = data
end

function Talents.GetCustomTalentData(self, fullId)
    return self.customTalents[fullId]
end

function Talents:MeetsRequirements(char, talent)
    local data = Talents:GetCustomTalentData(talent)

    for req,amount in pairs(data.requirements.abilities) do
        if char.Stats.DynamicStats[1][req] < amount then
            -- Ext.Print(req)
            -- Ext.Print(char.Stats.DynamicStats[1][req])
            return false
        end
    end

    for req,amount in pairs(data.requirements.attributes) do
        if char.Stats.DynamicStats[1][req] < amount then
            return false
        end
    end

    return true
end