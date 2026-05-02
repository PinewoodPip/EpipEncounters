
local CustomStats = Epip.GetFeature("Feature_CustomStats")

---@class Features.CustomStats.Stat.Tag : Feature_CustomStats_Stat
---@field CharacterTag tag

-- Add stats for each tag that is normally visible in the character sheet
local tagCategory = CustomStats.GetCategory("Tags")
for tagID,tag in pairs(Character.Tags) do
    local statID = "Tag." .. tagID
    CustomStats.RegisterStat(statID, {
        Name = Ext.L10N.GetTranslatedString(tag.NameHandle),
        Description = Ext.L10N.GetTranslatedString(tag.DescriptionHandle),
        Boolean = true,
        DefaultValue = 0,
        CharacterTag = tagID,
    })
    table.insert(tagCategory.Stats, statID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set the stat value based on whether the character has the tag.
CustomStats.Hooks.GetStatValue:Subscribe(function (ev)
    local stat = ev.Stat
    ---@cast stat Features.CustomStats.Stat.Tag
    if stat.CharacterTag then
        ev.Value = ev.Character:HasTag(stat.CharacterTag) and 1 or 0
    end
end)
