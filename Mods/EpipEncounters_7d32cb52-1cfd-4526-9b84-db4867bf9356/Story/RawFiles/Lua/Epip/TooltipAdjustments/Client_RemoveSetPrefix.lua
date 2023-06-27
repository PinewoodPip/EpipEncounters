
---------------------------------------------
-- Removes the "Set :" prefix in deltamods and rune effects.
---------------------------------------------

local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings

-- The inconsistencies are killing me
TooltipAdjustments.SET_PREFIXES = {
    SET_DELTAMOD_PATTERN = '(Set :)<font size="17">',
    SET_ALL_RES_PATTERN = '(Set )+[0-9]* to all',
    SET_LIFESTEAL_PATTERN = '(Set )+[0-9]*%% Lifesteal',
}
TooltipAdjustments.RUNE_EFFECT_LABELS = {
    "Rune1",
    "Rune2",
    "Rune3",
}
---@type table<string, {LabelKeys:string[]}>
TooltipAdjustments.ELEMENTS_WITH_SET_PREFIX = {
    ExtraProperties = {LabelKeys = {"Label"}},
    RuneEffect = {LabelKeys = TooltipAdjustments.RUNE_EFFECT_LABELS},
}

---------------------------------------------
-- TRANSLATED STRINGS
---------------------------------------------

TSK.Adjustment_RemoveSetPrefix_Name = TooltipAdjustments:RegisterTranslatedString("h5e7095b6ga182g4dc0gadfbg198413b93310", {
    Text = "Remove 'Set :' Prefixes",
    ContextDescription = "Adjustment setting name",
})
TSK.Adjustment_RemoveSetPrefix_Description = TooltipAdjustments:RegisterTranslatedString("h979a8059g2ea7g436fg863bgf6b008ad3072", {
    Text = "Removes the redundant 'Set :' prefix that appears in deltamod names and rune effects.",
    ContextDescription = "Adjustment setting description",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipAdjustments:RegisterSetting("RemoveSetPrefixes", {
    Type = "Boolean",
    Name = TSK.Adjustment_RemoveSetPrefix_Name,
    Description = TSK.Adjustment_RemoveSetPrefix_Description,
    DefaultValue = true,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for item tooltips to remove the "Set :" prefix from elements that might have it.
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.RemoveSetPrefixes) then
        local tooltip = ev.Tooltip

        for elementType,data in pairs(TooltipAdjustments.ELEMENTS_WITH_SET_PREFIX) do
            local elements = tooltip:GetElements(elementType)
            for _,element in ipairs(elements) do -- For each element
                for _,key in ipairs(data.LabelKeys) do -- For each label within the element
                    local label = element[key]
                    for _,pattern in pairs(TooltipAdjustments.SET_PREFIXES) do -- For each pattern
                        local match = label:match(pattern)
                        if match then
                            element[key] = label:gsub(match, '')

                            -- We used to remove the trailing dot,
                            -- but it could be deemed inelegant.
                            -- local trailingDotMatch = label:match("(.*)%.<font>")
                            
                            -- if trailingDotMatch then
                            --     element[key] = trailingDotMatch
                            -- end
                        end
                    end
                end
            end
        end
    end
end)