
---------------------------------------------
-- Adds EE's dyes to the Vanity menu.
---------------------------------------------

---@class DyeItem : VanityDye
---@field Template string
---@field Deltamod string
---@field ItemColor string

---@type DyeItem
local _DyeItem = {}

function _DyeItem:Init()
    local stat = Ext.Stats.ItemColor.Get(self.ItemColor)

    self.Color1 = Color.CreateFromDecimal(stat.Color1)
    self.Color2 = Color.CreateFromDecimal(stat.Color2)
    self.Color3 = Color.CreateFromDecimal(stat.Color3)
end

local DyeData = Data.Game.DYES
local Dyes = {
    ---@type DyeItem[]
    DYES = {
        {
            Name = "Abyss Dye",
            Template = "AMER_TOOL_Dye_Abyss_c7cf04d2-1bcf-4223-a245-a32dcb98c457",
            Icon = "AMER_Dyes_Abyss",
            Deltamod = "Dye_Abyss",
            ItemColor = "AMER_Dye_Abyss"
        },
        {
            Name = "Clay Dye",
            Template = "AMER_TOOL_Dye_Clay_95f74ac5-ec9c-4018-b8ac-b5099bcf319a",
            Icon = "AMER_Dyes_Clay",
            Deltamod = "Dye_Clay",
            ItemColor = "AMER_Dye_Clay",
        },
        {
            Name = "Coral Dye",
            Template = "AMER_TOOL_Dye_Coral_4b4b1e09-417b-4319-8e04-b859db48d077",
            Icon = "AMER_Dyes_Coral",
            Deltamod = "Dye_Coral",
            ItemColor = "AMER_Dye_Coral",
        },
        {
            Name = "Earth Dye",
            Template = "AMER_TOOL_Dye_Earth_f60a93bb-0d6c-459f-af62-9a3472d93374",
            Icon = "AMER_Dyes_Earth",
            Deltamod = "Dye_Earth",
            ItemColor = "AMER_Dye_Earth",
        },
        {
            Name = "Fog Dye",
            Template = "AMER_TOOL_Dye_Fog_923c1158-5972-456d-813a-1655fa4c175a",
            Icon = "AMER_Dyes_Fog",
            Deltamod = "Dye_Fog",
            ItemColor = "AMER_Dye_Fog",
        },
        {
            Name = "Lichen Dye",
            Template = "AMER_TOOL_Dye_Lichen_bbe83a2c-9ed9-473a-96ab-0b71809b42a5",
            Icon = "AMER_Dyes_Lichen",
            Deltamod = "Dye_Lichen",
            ItemColor = "AMER_Dye_Lichen",
        },
        {
            Name = "Midnight Dye",
            Template = "AMER_TOOL_Dye_Midnight_41d07754-b3ae-4100-85ed-8d174e940f8a",
            Icon = "AMER_Dyes_Midnight",
            Deltamod = "Dye_Midnight",
            ItemColor = "AMER_Dye_Midnight",
        },
        {
            Name = "Nemesis Dye",
            Template = "AMER_TOOL_Dye_Nemesis_b8324054-f302-4309-a956-82a9f569d3dc",
            Icon = "AMER_Dyes_Nemesis",
            Deltamod = "Dye_Nemesis",
            ItemColor = "AMER_Dye_Nemesis",
        },
        {
            Name = "Saffron Dye",
            Template = "AMER_TOOL_Dye_Saffron_4bd3a715-3688-40b2-9940-4fbd3b4655e7",
            Icon = "AMER_Dyes_Saffron",
            Deltamod = "Dye_Saffron",
            ItemColor = "AMER_Dye_Saffron",
        },
        {
            Name = "Seafoam Dye",
            Template = "AMER_TOOL_Dye_Seafoam_799fe8de-d76f-405e-a0d6-c2481d1a864d",
            Icon = "AMER_Dyes_Seafoam",
            Deltamod = "Dye_Seafoam",
            ItemColor = "AMER_Dye_Seafoam",
        },
        {
            Name = "Smoke Dye",
            Template = "AMER_TOOL_Dye_Smoke_ce1e8c3e-8067-4b96-bf4b-0519521101fd",
            Icon = "AMER_Dyes_Smoke",
            Deltamod = "Dye_Smoke",
            ItemColor = "AMER_Dye_Smoke",
        },
        {
            Name = "Stealth Dye",
            Template = "AMER_TOOL_Dye_Stealth_2e776366-3fd1-4ad9-8002-fc61026c9809",
            Icon = "AMER_Dyes_Stealth",
            Deltamod = "Dye_Stealth",
            ItemColor = "AMER_Dye_Stealth",
        },
        {
            Name = "Verdure Dye",
            Template = "AMER_TOOL_Dye_Verdure_a4f8691b-9d56-4e98-92c7-404e9ec6bfb1",
            Icon = "AMER_Dyes_Verdure",
            Deltamod = "Dye_Verdure",
            ItemColor = "AMER_Dye_Verdure",
        },
        {
            Name = "Void Dye",
            Template = "AMER_TOOL_Dye_Void_a74799d1-d54f-4ad3-bb93-a46ad98ce06b",
            Icon = "AMER_Dyes_Void",
            Deltamod = "Dye_Void",
            ItemColor = "AMER_Dye_Void",
        },
        -- DyeData.ABYSS,
        -- DyeData.CLAY,
        -- DyeData.CORAL,
        -- DyeData.EARTH,
        -- DyeData.FOG,
        -- DyeData.LICHEN,
        -- DyeData.MIDNIGHT,
        -- DyeData.NEMESIS,
        -- DyeData.SAFFRON,
        -- DyeData.SEAFOAM,
        -- DyeData.SMOKE,
        -- DyeData.STEALTH,
        -- DyeData.VERDURE,
        -- DyeData.VOID,
    },
    DYE_DATA = {},
    REQUIRED_MODS = {
        [Mod.GUIDS.EE_CORE] = "Epic Encounters Core",
    },
}
Epip.AddFeature("EE_Dyes", "EE_Dyes", Dyes)

for i,data in ipairs(Dyes.DYES) do
    Inherit(data, _DyeItem)
    data.ID = data.Deltamod
    data.Type = "EE"
    data:Init()

    Dyes.DYE_DATA[data.ID] = data
end

local Vanity = Client.UI.Vanity
local VanityDyes = Epip.Features.VanityDyes

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

function Dyes.IsEEDye(id)
    return Dyes.DYE_DATA[id] ~= nil
end

local function GetCurrentDyeInSlot(char, slot)
    local item = char:GetItemBySlot(slot)
    local dye,data = nil

    if item then
        item = Ext.GetItem(item)
        local id,_t = Item.GetCurrentDye(item)
        data = _t
        if id then
            dye = id
        end
    end

    return dye,data
end

VanityDyes.Events.DyeUsed:RegisterListener(function (dye, item, character)
    if dye.Type == "EE" then

        -- Net.PostToServer("EPIPENCOUNTERS_DYE", {
        --     Character = character.NetID,
        --     Item = item.NetID,
        --     -- DyeID = dye.ID,
        --     DyeData = dye,
        -- })
        VanityDyes.ApplyCustomDye(dye, item)
        VanityDyes.Tab:SetSliderColors(dye)
    end
end)

-- Grey out text for EE dyes if we don't have them.
Vanity.Hooks.GetLabelColor:RegisterHook(function (color, text, tab, entryID)
    if tab.ID == "PIP_Vanity_Dyes" and Dyes.IsEEDye(entryID) then
        local dye = Dyes.DYE_DATA[entryID]
        local hasDye = Item.GetPartyTemplateCount(dye.Template) > 0

        if not hasDye then
            color = "706262"
        end
    end

    return color
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Dyes:__Setup()
    VanityDyes.AddDyeCategory("EpicEncounters", {
        Name = "Epic Encounters Dyes",
    })

    for i,dye in ipairs(Dyes.DYES) do
        VanityDyes.AddDye("EpicEncounters", dye)
    end

    -- Put this category above built-in
    local categories = VanityDyes.DYE_CATEGORY_ORDER
    categories[#categories],categories[#categories-1] = categories[#categories-1],categories[#categories]
end