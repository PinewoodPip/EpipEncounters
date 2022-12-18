
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_Fishing : Feature
local Fishing = {
    _Fish = {}, ---@type table<string, Feature_Fishing_Fish>
    _RegionsByLevel = DefaultTable.Create({}), ---@type DataStructures_DefaultTable<string, Feature_Fishing_Region[]>
    _RegionsByID = {}, ---@type table<string, Feature_Fishing_Region>
    _CharactersFishing = Set.Create(), -- Not synchronized across clients!

    FISHING_ROD_TEMPLATES = Set.Create({
        "81cbf17f-cc71-4e09-9ab3-ca2a5cb0cefc", -- HAR_FishingRod_A, green fish-shaped lure
        "90cdb693-3564-415a-a8fa-4027b7f76f41", -- HAR_FishingRod_B, classic red/white bobber
        "9fc3cb5f-894e-4783-9eef-fbceef0104b0", -- HAR_FishingRod_C, red/yellow lure
    }),
    WATER_SEARCH_RADIUS = 3.5,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Settings = {
        Enabled = {
            Type = "Boolean",
            Name = "Enabled",
            Description = "Controls whether fishing is enabled.",
            DefaultValue = false,
            Context = "Client",
        },
        FishCaught = {
            Type = "Map",
            Name = "Fish Caught",
            Description = "Fish caught.",
            Context = "Client",
        },
    },

    TranslatedStrings = {
        ["hcced1bb7ge818g4803gbf45gf0644370163f"] = {
            Text = "Hold left-click to raise the bar,\nlet go to have it fall.\n\nKeep the bar by the fish until the yellow bar fills up!",
            ContextDescription = "Tutorial message",
            LocalKey = "MinigameTutorialHint",
        },
        ["h25bb86bcge5edg4a61g9ebdgce438fa04de1"] = {
            Text = "Fish Caught!",
            ContextDescription = "Toast notification for minigame success",
            LocalKey = "Toast_Success",
        },
        ["h13c51b21g9d2bg4489g9e4bg460b162e8b3c"] = {
            Text = "Press %s to open the collection log.",
            ContextDescription = "Toast notification for minigame success, when catching new types of fish",
            LocalKey = "Toast_Success_Subtitle",
        },
        ["h26c81552g4b40g4f9bg88c5g0380578c6964"] = {
            Text = "Click to start fishing.",
            ContextDescription = "Mouseover text for fishable areas",
            LocalKey = "CharacterTask_MouseTextTooltip",
        },

        ["h467929cdge276g4833gbcffg7294c0a60514"] = {
            Text = "Fish A",
            ContextDescription = "TODO",
            LocalKey = "FishA_Name",
        },
        ["hb651eb42g5092g4ed5g96faga5ba0df7d284"] = {
            Text = "Fish A",
            ContextDescription = "TODO",
            LocalKey = "FishA_Description",
        },
        ["h96c20d10g5931g4cddga3c0ge24d8188da43"] = {
            Text = "Fish B",
            ContextDescription = "TODO",
            LocalKey = "FishB_Name",
        },
        ["h2fd692d7g6559g4775gbd79g85956021916a"] = {
            Text = "Fish B",
            ContextDescription = "TODO",
            LocalKey = "FishB_Description",
        },
        ["h3cb365d5gcc3fg4031gafccga6ce52313d17"] = {
            Text = "Fish C",
            ContextDescription = "TODO",
            LocalKey = "FishC_Name",
        },
        ["h4502abf5g22d2g479bgb078g6619dcc1dfdb"] = {
            Text = "Fish C",
            ContextDescription = "TODO",
            LocalKey = "FishC_Description",
        },
        ["h4c7b5054gd964g4252g944eg534a8979a1a5"] = {
            Text = "Fish D",
            ContextDescription = "TODO",
            LocalKey = "FishD_Name",
        },
        ["h1f160d38g7650g411bg8ddcg730de9bd44c2"] = {
            Text = "Fish D",
            ContextDescription = "TODO",
            LocalKey = "FishD_Description",
        },
        ["h66ec8f55g6a04g4a80ga160g1e71b2bb2e15"] = {
            Text = "Fish E",
            ContextDescription = "TODO",
            LocalKey = "FishE_Name",
        },
        ["h154469f8g092dg4780g9b98g903799adfb8f"] = {
            Text = "Fish E",
            ContextDescription = "TODO",
            LocalKey = "FishE_Description",
        },

        -- Fish
        ["h141d4a29g7c4fg4f1fgb731g041599f3bed1"] = {
            Text = "Bluefish",
            ContextDescription = "Bluefish name",
            LocalKey = "Bluefish_Name",
        },
        ["h76a85cf9gf73fg4872g9af8gf7669011a879"] = {
            Text = "Known as \"tailors\" in foreign lands, the bluefish favor temperate, subtropical waters.",
            ContextDescription = "Bluefish description",
            LocalKey = "Bluefish_Description",
        },

        ["h38178e46g2bd2g4a6eg8fdbgac07a828b84e"] = {
            Text = "Perch",
            ContextDescription = "Perch name",
            LocalKey = "Perch_Name",
        },
        ["h1cb6821fgd35eg4186g9898gda566c626444"] = {
            Text = "Though small, perches have become a fisherman's favorite for the fight they put up - and the tasty dinner that results afterwards.",
            ContextDescription = "Perch description",
            LocalKey = "Perch_Description",
        },

        ["h11ccc999gf9b1g4f84gb988g336d5fef8867"] = {
            Text = "Swordfish",
            ContextDescription = "Swordfish name",
            LocalKey = "Swordfish_Name",
        },
        ["he360edb5g6cddg442dgaaf0g09f9862ee688"] = {
            Text = "Despite their impressively pointed bill, the swordfish are not particularly popular swords.",
            ContextDescription = "Swordfish description",
            LocalKey = "Swordfish_Description",
        },

        ["h74cbecd6gf6f6g466dgae10ga62172e84861"] = {
            Text = "Wolffish",
            ContextDescription = "Wolffish name",
            LocalKey = "Wolffish_Name",
        },
        ["h972baf77g22c3g43c3gb406gda7196bad1e8"] = {
            Text = "Known by many terrifying names, the wolffish patrol the seabed, staying warm through a natural antifreeze in their blood.",
            ContextDescription = "Wolffish description",
            LocalKey = "Wolffish_Description",
        },

        ["h0b82f63cg83b4g4284g922agba1c2cbac71f"] = {
            Text = "Moi",
            ContextDescription = "Moi name",
            LocalKey = "Moi_Name",
        },
        ["h51d2668dg4b4ag43bdg819bg68b66dd9070d"] = {
            Text = "Distinguished by their silver scales and whiskers, the Moi traditionally used to be delicacies reserved for only the finest chefs.",
            ContextDescription = "Moi description",
            LocalKey = "Moi_Description",
        },

        ["h77c88602gcf61g48ffg99cdg058e686dab45"] = {
            Text = "Mahi-mahi",
            ContextDescription = "Mahi-mahi name",
            LocalKey = "Mahimahi_Name",
        },
        ["h83c4f9cegcc30g4fafg9071g62fac5469f3d"] = {
            Text = "Despite being carnivorous, the mahi-mahi like to scour the surface waters for sargassum algae.",
            ContextDescription = "Mahi-mahi description",
            LocalKey = "Mahimahi_Description",
        },

        ["hf0de72a5gf56bg4f02g8b8cg064de7a27c43"] = {
            Text = "Starfish",
            ContextDescription = "Starfish name",
            LocalKey = "Starfish_Name",
        },
        ["h11236241g8b34g4b56g9ce6g43656ffa7e47"] = {
            Text = "TODO",
            ContextDescription = "Starfish description",
            LocalKey = "Starfish_Description",
        },
    },

    Events = {
        CharacterStartedFishing = {}, ---@type Event<Feature_Fishing_Event_CharacterStartedFishing>
        CharacterStoppedFishing = {}, ---@type Event<Feature_Fishing_Event_CharacterStoppedFishing>
    },
    Hooks = {
        IsFishingRod = {}, ---@type Event<Feature_Fishin_Hook_IsFishingRod>
    },
}
Epip.RegisterFeature("Fishing", Fishing)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_Fishing_NetMsg_CharacterStartedFishing : Net_SimpleMessage_Character
---@field RegionID string
---@field FishID string

---@class Feature_Fishing_NetMsg_CharacterStoppedFishing : Net_SimpleMessage_Character
---@field Reason Feature_Fishing_MinigameExitReason
---@field FishID string

---@class Feature_Fishin_Hook_IsFishingRod
---@field Character Character
---@field Item Item
---@field IsFishingRod boolean Hookable. Defaults to false.

---@class Feature_Fishing_Event_CharacterStartedFishing
---@field Character Character
---@field Region Feature_Fishing_Region
---@field Fish Feature_Fishing_Fish

---@class Feature_Fishing_Event_CharacterStoppedFishing
---@field Character Character
---@field Reason Feature_Fishing_MinigameExitReason
---@field Fish Feature_Fishing_Fish

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Feature_Fishing_MinigameExitReason "Success"|"Failure"|"Cancelled"

---@class Feature_Fishing_Fish : I_Identifiable, I_Describable
---@field Icon string? Defaults to the template's icon.
---@field TemplateID GUID
local _Fish = {}

---@return string
function _Fish:GetIcon()
    local itemTemplate = Ext.Template.GetTemplate(self.TemplateID) ---@type ItemTemplate

    return self.Icon or itemTemplate.Icon
end

---@return TooltipLib_FormattedTooltip
function _Fish:GetTooltip()
    ---@type TooltipLib_FormattedTooltip
    local tooltip = {
        Elements = {
            {
                Type = "ItemName",
                Label = self:GetName(), -- TODO rarity color
            },
            -- Multiple SkillDescriptions are ordered inversely, lol TODO fix?
            {
                Type = "SkillDescription",
                Label = Text.Format("Total caught: %s", {
                    FormatArgs = {
                        Fishing.GetTimesCaught(self.ID),
                    },
                    Color = Color.LARIAN.GREEN,
                }),
            },
            {
                Type = "SkillDescription",
                Label = self:GetDescription(),
            },
            {
                Type = "ItemRarity",
                Label = "Fish", -- TODO
            }
        }
    }

    return tooltip
end

---@class Feature_Fishing_Region : I_Identifiable
---@field LevelID string
---@field Bounds Vector4 X, Y, width, height.
---@field Fish Feature_Fishing_Region_FishEntry[]
---@field RequiresWater boolean? Defaults to true.
---@field Priority integer? Defaults to 0.
local _Region = {
    RequiresWater = true,
    Priority = 0,
}

---@class Feature_Fishing_Region_FishEntry
---@field ID string ID of the fish.
---@field Weight number Relative chance for the fish to be picked.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Fishing_Fish
function Fishing.RegisterFish(data)
    if not data.ID then Fishing:Error("RegisterFish", "Data must include ID.") end
    Inherit(data, _Fish)
    Interfaces.Apply(data, "I_Identifiable")
    Interfaces.Apply(data, "I_Describable")

    Fishing._Fish[data.ID] = data
end

---@param data Feature_Fishing_Region
function Fishing.RegisterRegion(data)
    if not data.ID then Fishing:Error("RegisterRegion", "Data must include ID.") end
    if #data.Fish == 0 then Fishing:Error("RegisterRegion", "Regions must have at least one fish entry.") end
    Inherit(data, _Region)
    Interfaces.Apply(data, "I_Identifiable")
    
    table.insert(Fishing._RegionsByLevel[data.LevelID], data)
end

---@param levelID string
---@return Feature_Fishing_Region[]
function Fishing.GetRegions(levelID)
    return Fishing._RegionsByLevel[levelID]
end

---@param id string
---@return Feature_Fishing_Region?
function Fishing.GetRegion(id)
    return Fishing._RegionsByID[id]
end

---@param char Character
---@return boolean
function Fishing.IsFishing(char)
    return Fishing._CharactersFishing:Contains(char.Handle)
end

---@param id string
---@return Feature_Fishing_Fish?
function Fishing.GetFish(id)
    return Fishing._Fish[id]
end

---@return table<string, Feature_Fishing_Fish>
function Fishing.GetFishes()
    return Fishing._Fish
end

---@param pos Vector3D
---@return Feature_Fishing_Region?
function Fishing.GetRegionAt(pos)
    local levelID = Entity.GetLevel().LevelDesc.LevelName
    local regions = Fishing.GetRegions(levelID)
    local region = nil ---@type Feature_Fishing_Region

    for _,levelRegion in ipairs(regions) do
        local bounds = levelRegion.Bounds

        -- Boundaries go from north-west to south-east.
        if pos[1] >= bounds[1] and pos[1] <= bounds[1] + bounds[3] and pos[3] <= bounds[2] and pos[3] >= bounds[2] - bounds[4] then
            
            -- Higher-priority regions take priority.
            if not region or levelRegion.Priority > region.Priority then
                region = levelRegion
            end
        end
    end

    return region
end

---@param region Feature_Fishing_Region
---@return Feature_Fishing_Fish
function Fishing.GetRandomFish(region)
    local totalWeight = 0
    local fishID
    local seed

    for _,entry in ipairs(region.Fish) do
        local fish = Fishing.GetFish(entry.ID)
        if not fish then Fishing:Error("GetRandomFish", "Found unregistered fish " .. entry.ID) end -- TODO move to registerregion

        totalWeight = totalWeight + entry.Weight
    end

    seed = totalWeight * math.random()

    for _,entry in ipairs(region.Fish) do
        seed = seed - entry.Weight

        if seed <= 0 then
            fishID = entry.ID
            break
        end
    end

    return Fishing.GetFish(fishID)
end

---@param char Character
---@return boolean
function Fishing.HasFishingRodEquipped(char)
    local item = Item.GetEquippedItem(char, "Weapon")
    local hasRod = false

    if item then
        local event = Fishing.Hooks.IsFishingRod:Throw({
            Character = char,
            Item = item,
            IsFishingRod = hasRod,
        })

        hasRod = event.IsFishingRod
    end

    return hasRod
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Check for fishing rod template.
Fishing.Hooks.IsFishingRod:Subscribe(function (ev)
    if Fishing.FISHING_ROD_TEMPLATES:Contains(ev.Item.RootTemplate.Id) then
        ev.IsFishingRod = true
    end
end)