
---------------------------------------------
-- Shows treasure table and artifact chances on the EnemyHealthBar UI.
---------------------------------------------

---@class Feture_TreasureTableDisplay : Feature
local TTD = {
    -- Treasure tables checked and their display name. Use AddTreasureTable() to add more.
    ---@type table<string, TreasureTableDisplayEntry>
    TREASURE_TABLES = {
        TinyBoss = {
            Name = "Tiny Boss",
            ArtifactChance = 0.33,
        },
        MiniBoss = {
            Name = "Mini Boss",
            ArtifactChance = 0.5,
        },
        ST_AMER_UNI = {
            Name = "Artifact",
            ArtifactChance = 1,
        },
        AMER_UNI_Cheat = {
            Name = "All Artifacts",
            ArtifactChance = 1,
        },
        RewardCombat = {
            Name = "Combat Reward",
            ArtifactChance = 1/26,
        },
        RewardMedium = {
            Name = "Medium Reward",
            ArtifactChance = 1/20,
        },
        RewardBig = {
            Name = "Big Reward",
            ArtifactChance = 1/5,
            ProteanChance = 1/5,
        },
        QuestReward_Hard_Choice_6 = {
            Name = "Hard Quest Reward",
            ArtifactChance = 0.5,
        },
        QuestReward_Impossible_Choice_4 = {
            Name = "Impossible Quest Reward",
            ArtifactChance = 0.5,
        },
        QuestReward_Impossible_Choice_6 = {
            Name = "Impossible Quest Reward",
            ArtifactChance = 0.5,
        },
        MiniBoss_ArtifactAlways = {
            Name = "Mini Boss",
            ArtifactChance = 1,
        },
        MiniBoss_ProteanAlways = {
            Name = "Mini Boss",
            ProteanChance = 1,
        },
        MegaBoss = {
            Name = "Mega Boss",
            ProteanChance = 1,
        },
    },
    Hooks = {
        ---@type TreasureTableDisplay_Hook_GetTreasureData
        GetTreasureData = {},
    },
}
Epip.AddFeature("TreasureTableDisplay", "TreasureTableDisplay", TTD)
Epip.Features.TreasureTableDisplay = TTD

---@class TreasureTableDisplay_Hook_GetTreasureData : Hook
---@field RegisterHook fun(self, handler:fun(data:TreasureTableDisplayEntry, char:EclCharacter))
---@field Return fun(self, data:TreasureTableDisplayEntry, char:EclCharcter)

---@class TreasureTableDisplayEntry
---@field Name string
---@field ArtifactChance? number
---@field ProteanChance? number
local _TreasureTableEntry = {
    GetArtifactChance = function(self) return self.ArtifactChance or 0 end,
    GetProteanChance = function(self) return self.ProteanChance or 0 end,
}

local Bar = Client.UI.EnemyHealthBar

function TTD:IsEnabled()
    return not self.Disabled and Settings.GetSettingValue("EpipEncounters", "TreasureTableDisplay")
end

---Add a treasure table to display in the UI.
---@param tableID string
---@param data TreasureTableDisplayEntry
function TTD.AddTreasureTable(tableID, data)
    setmetatable(data, {__index = _TreasureTableEntry})

    data.Name = data.Name or tableID

    TTD.TREASURE_TABLES[tableID] = data
end


---Get the display data for a treasure table, if it is tracked.
---@param entity Entity
---@return TreasureTableDisplayEntry
function TTD.GetTreasureData(entity)
    local treasures = entity.RootTemplate.Treasures
    local tableData
    
    if #treasures > 0 then
        for i,treasureTableID in ipairs(treasures) do
            tableData = TTD.TREASURE_TABLES[treasureTableID]

            -- Check subtables
            if not tableData then
                local stat = Ext.GetTreasureTable(treasureTableID)

                for z,subTable in ipairs(stat.SubTables) do
                    if tableData then
                        break
                    end

                    for _,category in ipairs(subTable.Categories) do

                        if category.TreasureTable then
                            tableData = TTD.TREASURE_TABLES[category.TreasureTable]

                            if tableData then
                                break
                            end
                        end
                    end
                end
            end

            if tableData then
                break
            end
        end
    end

    return TTD.Hooks.GetTreasureData:Return(tableData, entity)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Bar.Hooks.GetBottomLabel:Subscribe(function (ev)
    local char, item = ev.Character, ev.Item

    -- Chars require shift, items do not.
    if TTD:IsEnabled() and (item or (char and Client.Input.IsShiftPressed())) then
        local entity = char or item
        local treasureData = TTD.GetTreasureData(entity)

        if treasureData then
            local addendum = "Treasure: " .. treasureData.Name
            
            local artifactChance = treasureData:GetArtifactChance()
            local proteanChance = treasureData:GetProteanChance()

            if artifactChance > 0 then
                if artifactChance >= 1 then
                    addendum = addendum .. "\nGuaranteed Artifact"
                else
                    local chanceDisplay = Text.Round(artifactChance * 100, 2)

                    addendum = addendum .. "\nArtifact Chance: " .. chanceDisplay .. "%"
                end
            end

            if proteanChance > 0 then
                if proteanChance >= 1 then
                    addendum = addendum .. "\nGuaranteed Protean"
                else
                    local chanceDisplay = Text.Round(proteanChance * 100, 2)

                    addendum = addendum .. string.format("\nProtean Chance: %s%%", chanceDisplay)
                end
            end

            table.insert(ev.Labels, "<font size='14.5'>" ..  addendum .. "</font>")

            -- lmao will keep this one for 2023. See you then
            if item and Epip.IsAprilFools() then
                table.insert(ev.Labels, "\n<font size='30'>THIS ONE CAN HAVE ARTIFACT !!!!\nCLICK IT <font size='42'>NOW</font></font>\n           |\n           |\n           |\n           V")
            end
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

for id,t in pairs(TTD.TREASURE_TABLES) do
    TTD.AddTreasureTable(id, t)
end

-- Derpy compatibility
if Mod.IsLoaded(Mod.GUIDS.EE_DERPY) then
    TTD.AddTreasureTable("OmegaBoss", {Name = "Omega Boss", ProteanChance = 1})
    TTD.AddTreasureTable("MicroBoss", {Name = "Micro Boss"})
end