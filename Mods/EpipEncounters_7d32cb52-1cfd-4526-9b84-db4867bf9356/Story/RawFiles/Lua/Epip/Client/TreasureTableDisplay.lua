
---------------------------------------------
-- Shows treasure table and artifact chances on the EnemyHealthBar UI.
---------------------------------------------

local Bar = Client.UI.EnemyHealthBar

---@class Feature_TreasureTableDisplay : Feature
local TTD = {
    LABEL_SIZE = 14.5,

    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "hcd9974f8g16cfg4cbfga08agbf28ee5b55eb",
            Text = "Show loot drops in health bar",
            ContextDescription = "Treasure table display setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h9cd1245egdfdeg4cbbgbae7gfa179a954eac",
            Text = "If enabled, the health bar when you hover over characters and items will show their treasure table (if relevant) as well as the chance of getting an artifact. For characters, this requires holding the Show Sneak Cones key (shift by default)",
            ContextDescription = "Treasure table display setting tooltip",
        },

        Label_ArtifactAprilFools = {
            Handle = "ha388e4dfg01b9g4c71g8114g49a1d94a940b",
            Text = "THIS ONE CAN HAVE ARTIFACT !!!!<br>CLICK IT <font size='42'>NOW</font>",
            ContextDescription = [[Label shown on items with artifact treasure tables during April Fools]],
        },

        Label_Treasure = {
            Handle = "h40ce8995g1bbeg40d6gb009g3c9e8a9c7b38",
            Text = "Treasure: %s",
            ContextDescription = [[Label for characters/items with relevant treasure tables. Param is the name of the treasure table.]],
        },
        Label_GuaranteedArtifact = {
            Handle = "h37e691e4g9d5eg4a14g8e9agd76a02fb955f",
            Text = "Guaranteed Artifact",
            ContextDescription = [[Label for treasure tables that always give an artifact]],
        },
        Label_ArtifactChance = {
            Handle = "h55e06232g49d9g42aegbe39g422c9cfa234d",
            Text = "Artifact Chance: %s%%",
            ContextDescription = [[Label for treasure tables with artifacts. Param is artifact chance.]],
        },
        Label_GuaranteedProtean = {
            Handle = "h53d36548g5ce7g460cg8a6fgffe81bdc7cf0",
            Text = "Guaranteed Protean",
            ContextDescription = [[Label for treasure tables that always give a protean]],
        },
        Label_ProteanChance = {
            Handle = "h6f017814g60ffg42cag980ag754cf8a028f4",
            Text = "Protean Chance: %s%%",
            ContextDescription = [[Label for treasure tables with proteans. Param is protean chance.]],
        },

        TreasureTable_TinyBoss = {
            Handle = "h6f1fb76dgb892g44a3gb6ffge807500fd288",
            Text = "Tiny Boss",
            ContextDescription = [[Treasure table name for TinyBoss]],
        },
        TreasureTable_MiniBoss = {
            Handle = "hace7c5feg45c7g4d47ga27cg3d18d2597ffc",
            Text = "Mini Boss",
            ContextDescription = [[Treasure table name for MiniBoss]],
        },
        TreasureTable_Artifact = {
            Handle = "hd82e9005g842cg41daga3efgfc1f0e999e44",
            Text = "Artifact",
            ContextDescription = [[Treasure table name for ST_AMER_UNI]],
        },
        TreasureTable_RewardCombat = {
            Handle = "hacb3ef1bg1d2ag4432g9a4fg060f794c0314",
            Text = "Combat Reward",
            ContextDescription = [[Treasure table name for RewardCombat]],
        },
        TreasureTable_RewardMedium = {
            Handle = "hcce330e6gf2b8g4c49gba57ge8a920543146",
            Text = "Medium Reward",
            ContextDescription = [[Treasure table name for RewardMedium]],
        },
        TreasureTable_RewardBig = {
            Handle = "h167a1cdfg859fg4c05gab86g1acf11a9e62b",
            Text = "Big Reward",
            ContextDescription = [[Treasure table name for RewardBig]],
        },
        TreasureTable_QuestReward_Hard_Choice_6 = {
            Handle = "h37eee33bgb5bdg4ea2g89c7g3553daef3a14",
            Text = "Hard Quest Reward",
            ContextDescription = [[Treasure table name for QuestReward_Hard_Choice_6]],
        },
        TreasureTable_QuestReward_Impossible_Choice_4 = {
            Handle = "h57bd9a78g6f13g42d0gb379g1983838f129d",
            Text = "Impossible Quest Reward",
            ContextDescription = [[Treasure table name for QuestReward_Impossible_Choice_4]],
        },
        TreasureTable_QuestReward_Impossible_Choice_6 = {
            Handle = "h7cd46932ga606g4d18g99dcg3545b9770930",
            Text = "Impossible Quest Reward",
            ContextDescription = [[Treasure table name for QuestReward_Impossible_Choice_6]],
        },
        TreasureTable_MiniBoss_ArtifactAlways = {
            Handle = "h3a8d17fdg5b5fg4014g87f2g1d110bb7a4f2",
            Text = "Mini Boss",
            ContextDescription = [[Treasure table name for MiniBoss_ArtifactAlways]],
        },
        TreasureTable_MiniBoss_ProteanAlways = {
            Handle = "h68a2c359g6d13g4c26g8cf9g4e50f2e815e6",
            Text = "Mini Boss",
            ContextDescription = [[Treasure table name for MiniBoss_ProteanAlways]],
        },
        TreasureTable_MegaBoss = {
            Handle = "h4129a99egbc81g4f46g836eg187fc4e03a73",
            Text = "Mega Boss",
            ContextDescription = [[Treasure table name for Megaboss]],
        },
        TreasureTable_OmegaBoss = {
            Handle = "ha29d7114g7e3ag4ff3g9297g11f7159c2255",
            Text = "Omega Boss",
            ContextDescription = [[Treasure table name for OmegaBoss]],
        },
        TreasureTable_MicroBoss = {
            Handle = "h22488442gbbbcg41efga8e2g3ae781f53b9e",
            Text = "Micro Boss",
            ContextDescription = [[Treasure table name for MicroBoss]],
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetTreasureData = {}, ---@type Event<Feature_TreasureTableDisplay_Hook_GetTreasureData>
    },
}
Epip.RegisterFeature("TreasureTableDisplay", TTD)
local TSK = TTD.TranslatedStrings

-- Treasure tables checked and their display name. Use AddTreasureTable() to add more.
---@type table<string, TreasureTableDisplayEntry>
TTD.TREASURE_TABLES = {
    TinyBoss = {
        Name = TSK.TreasureTable_TinyBoss,
        ArtifactChance = 0.33,
    },
    MiniBoss = {
        Name = TSK.TreasureTable_MiniBoss,
        ArtifactChance = 0.5,
    },
    ST_AMER_UNI = {
        Name = TSK.TreasureTable_Artifact,
        ArtifactChance = 1,
    },
    RewardCombat = {
        Name = TSK.TreasureTable_RewardCombat,
        ArtifactChance = 1/26,
    },
    RewardMedium = {
        Name = TSK.TreasureTable_RewardMedium,
        ArtifactChance = 1/20,
    },
    RewardBig = {
        Name = TSK.TreasureTable_RewardBig,
        ArtifactChance = 1/5,
        ProteanChance = 1/5,
    },
    QuestReward_Hard_Choice_6 = {
        Name = TSK.TreasureTable_QuestReward_Hard_Choice_6,
        ArtifactChance = 0.5,
    },
    QuestReward_Impossible_Choice_4 = {
        Name = TSK.TreasureTable_QuestReward_Impossible_Choice_4,
        ArtifactChance = 0.5,
    },
    QuestReward_Impossible_Choice_6 = {
        Name = TSK.TreasureTable_QuestReward_Impossible_Choice_6,
        ArtifactChance = 0.5,
    },
    MiniBoss_ArtifactAlways = {
        Name = TSK.TreasureTable_MiniBoss_ArtifactAlways,
        ArtifactChance = 1,
    },
    MiniBoss_ProteanAlways = {
        Name = TSK.TreasureTable_MiniBoss_ProteanAlways,
        ProteanChance = 1,
    },
    MegaBoss = {
        Name = TSK.TreasureTable_MegaBoss,
        ProteanChance = 1,
    },
}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_TreasureTableDisplay_Hook_GetTreasureData
---@field Data TreasureTableDisplayEntry
---@field Entity Entity

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TreasureTableDisplayEntry
---@field Name TextLib.String
---@field ArtifactChance number?
---@field ProteanChance number?
local _TreasureTableEntry = {
    GetArtifactChance = function(self) return self.ArtifactChance or 0 end,
    GetProteanChance = function(self) return self.ProteanChance or 0 end,
}

---------------------------------------------
-- SETTINGS
---------------------------------------------

TTD.Settings.Enabled = TTD:RegisterSetting("Enabled", {
    Type = "Boolean",
    NameHandle = TSK.Setting_Enabled_Name,
    DescriptionHandle = TSK.Setting_Enabled_Description,
    RequiredMods = {Mod.GUIDS.EE_CORE}, -- TODO would be nice to have this work in vanilla somehow.
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function TTD:IsEnabled()
    return TTD:GetSettingValue(TTD.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---Add a treasure table to display in the UI.
---@param tableID string
---@param data TreasureTableDisplayEntry
function TTD.AddTreasureTable(tableID, data)
    Inherit(data, _TreasureTableEntry)

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
        for _,treasureTableID in ipairs(treasures) do
            tableData = TTD.TREASURE_TABLES[treasureTableID]

            -- Check subtables
            if not tableData then
                local stat = Ext.GetTreasureTable(treasureTableID)

                for _,subTable in ipairs(stat.SubTables) do
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

    return TTD.Hooks.GetTreasureData:Throw({Data = tableData, Entity = entity}).Data
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
            local addendum = TSK.Label_Treasure:Format(Text.Resolve(treasureData.Name))

            -- Get artifact & protean chances
            local artifactChance = treasureData:GetArtifactChance()
            local proteanChance = treasureData:GetProteanChance()

            -- Add artifact label
            if artifactChance > 0 then
                if artifactChance >= 1 then
                    addendum = addendum .. "\n" .. TSK.Label_GuaranteedArtifact:GetString()
                else
                    local chanceDisplay = Text.Round(artifactChance * 100, 2)

                    addendum = addendum .. "\n" .. TSK.Label_ArtifactChance:Format(chanceDisplay)
                end
            end

            -- Add protean label
            if proteanChance > 0 then
                if proteanChance >= 1 then
                    addendum = addendum .. "\n" .. TSK.Label_GuaranteedProtean:GetString()
                else
                    local chanceDisplay = Text.Round(proteanChance * 100, 2)

                    addendum = addendum .. "\n" .. TSK.Label_ProteanChance:Format(chanceDisplay)
                end
            end

            table.insert(ev.Labels, Text.Format(addendum, {Size = TTD.LABEL_SIZE}))

            -- lmao will keep this one for 2023. See you then
            if item and Epip.IsAprilFools() then
                table.insert(ev.Labels, string.format("\n<font size='30'>%s</font>\n   |\n   |\n   |\n   V", TSK.Label_ArtifactAprilFools:GetString()))
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
    TTD.AddTreasureTable("OmegaBoss", {Name = TSK.TreasureTable_OmegaBoss, ProteanChance = 1})
    TTD.AddTreasureTable("MicroBoss", {Name = TSK.TreasureTable_MicroBoss})
end