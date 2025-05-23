
---------------------------------------------
-- Shows treasure table and artifact chances on the EnemyHealthBar UI.
---------------------------------------------

local Bar = Client.UI.EnemyHealthBar

---@class Feature_TreasureTableDisplay : Feature
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
---@field Name string
---@field ArtifactChance? number
---@field ProteanChance? number
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