
local TooltipAdjustments = Epip.GetFeature("TooltipAdjustments")
local TooltipLib = Client.Tooltip

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
}

---------------------------------------------
-- METHODS
---------------------------------------------

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

    if TooltipAdjustments:IsEnabled() and RuneCraftingHint.IsRuneCraftingMaterial(item) then
        ev.Tooltip:InsertElement({
            Type = "ExtraProperties",
            Label = Text.Format("Rune crafting material<br>%s", {
                FormatArgs = {
                    {Text = "Combine with Pixie Dust to create a small rune of the respective material.", Size = 16}
                }
            })
        })
    end
end)