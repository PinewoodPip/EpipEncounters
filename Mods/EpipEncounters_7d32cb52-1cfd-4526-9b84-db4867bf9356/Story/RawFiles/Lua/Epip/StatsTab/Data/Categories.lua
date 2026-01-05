
local CustomStats = Epip.GetFeature("Feature_CustomStats")
local CommonStrings = Text.CommonStrings
local CATEGORY_HEADER_SIZE = 21

---@param template string
---@param tsk TextLib_TranslatedString
---@return string
local function FormatHeader(template, tsk)
    return Text.Format(template, {
        Size = CATEGORY_HEADER_SIZE,
        FormatArgs = {
            tsk:GetString(),
        },
    })
end

---@type table<string, Feature_CustomStats_Category>
local Categories = {
    Vitals = {
        Header = FormatHeader("————— %s —————", CommonStrings.Vitals),
        Name = CommonStrings.Vitals,
        Behaviour = "GreyOut",
        Stats = {
            "LifeSteal",
        },
    },
    Misc = {
        Header = FormatHeader("———— %s ————", CommonStrings.Misc),
        Name = CommonStrings.Miscellaneous,
        Behaviour = "GreyOut",
        Stats = {
            "PartyFunds_Gold",
            "PartyFunds_Splinters",
        },
    },
    CurrentCombat = {
        Header = FormatHeader("———— %s ————", CommonStrings.Combat),
        Name = CommonStrings.Combat,
        Behaviour = "GreyOut",
        Stats = {
            "CurrentCombat_DamageDealt",
            "CurrentCombat_DamageReceived",
            "CurrentCombat_HealingDone",
        },
    },
}

local CategoriesOrder = {
    "Vitals",
    "CurrentCombat",
    "Misc",
}

-- Register categories in order.
for _,id in ipairs(CategoriesOrder) do
    local category = Categories[id]

    CustomStats.RegisterCategory(id, category)
end