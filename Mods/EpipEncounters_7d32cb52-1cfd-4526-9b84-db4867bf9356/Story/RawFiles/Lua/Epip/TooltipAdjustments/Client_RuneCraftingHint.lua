
local TooltipLib = Client.Tooltip

---@type Feature
local RuneCraftingHint = {
    ---@type table<string, StatsLib_Rune_Material>
    RUNE_MATERIAL_STATS = {
        LOOT_Bloodstone_A = "Bloodstone",
        TOOL_Pouch_Dust_Bone_A = "Bone",
        LOOT_Clay_A = "Clay",
        LOOT_Emerald_A = "Emerald",
        LOOT_Granite_A = "Granite",
        LOOT_OreBar_A_Iron_A = "Iron",
        LOOT_Jade_A = "Jade",
        LOOT_Lapis_A = "Lapis",
        LOOT_Malachite_A = "Malachite",
        LOOT_Obsidian_A = "Obsidian",
        LOOT_Onyx_A = "Onyx",
        LOOT_Ruby_A = "Ruby",
        LOOT_Sapphire_A = "Sapphire",
        LOOT_OreBar_A_Silver_A = "Silver",
        LOOT_OreBar_A_Steel_A = "Steel",
        LOOT_Tigerseye_A = "TigersEye",
        LOOT_Topaz_A = "Topaz",

    },
    -- Runes with complex crafting (category/property) not yet supported
    -- RUNE_RECIPE_CATEGORIES = {
    --     -- Wood = "Flame",
    --     -- Metal = "Frost",
    --     -- Gold = "Gold",
    --     -- Pearl = "Pearl",
    -- },

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "h2b831dbcg0141g444fg86bcg9f2224602030",
           Text = "Display rune crafting hint",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "hdd0f768aged04g4450g8259g62763d810f2f",
           Text = "If enabled, items whose only purpose is to be crafted into runes will display how to do so in their tooltip.<br>%s",
           ContextDescription = "Setting tooltip. Param is the 'Applies only to EE' warning.",
        },
        Label_Header = {
           Handle = "h562b6c73geee1g4d27gb3c3g027f92916d0a",
           Text = "Rune crafting material<br>%s",
           ContextDescription = "Top part of tooltip. Param is lower half ('combine with...')",
        },
        Label_Details = {
           Handle = "h8ed2ccd3g2e36g48bdg98dcg3cbf09c78464",
           Text = "Combine with Pixie Dust to create a small rune of the respective material.",
           ContextDescription = "Second half of tooltip",
        },
    },
}
Epip.RegisterFeature("TooltipAdjustments.RuneCraftingHint", RuneCraftingHint)
local TSK = RuneCraftingHint.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

RuneCraftingHint.Settings.Enabled = RuneCraftingHint:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = Text.Format(TSK.Setting_Enabled_Description:GetString(), {
        FormatArgs = {
            {Text = Text.CommonStrings.AppliesOnlyToEE:GetString(), Color = Color.LARIAN.YELLOW},
        },
    }),
    DefaultValue = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function RuneCraftingHint:IsEnabled()
    return self:GetSettingValue(RuneCraftingHint.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---Returns whether an item is a rune crafting material.
---@param item EclItem
---@return boolean
function RuneCraftingHint.IsRuneCraftingMaterial(item)
    local isMaterial = false

    if RuneCraftingHint.RUNE_MATERIAL_STATS[item.StatsId] ~= nil then
        isMaterial = true
    end

    return isMaterial
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add hint to rune material tooltips.
TooltipLib.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if RuneCraftingHint:IsEnabled() and RuneCraftingHint.IsRuneCraftingMaterial(item) then
        ev.Tooltip:InsertElement({
            Type = "ExtraProperties",
            Label = Text.Format(TSK.Label_Header:GetString(), {
                FormatArgs = {
                    {Text = TSK.Label_Details:GetString(), Size = 16}
                }
            })
        })
    end
end)