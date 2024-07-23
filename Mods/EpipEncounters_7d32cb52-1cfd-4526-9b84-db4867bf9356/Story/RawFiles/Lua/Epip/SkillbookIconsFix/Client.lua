
---------------------------------------------
-- Renders individual iggy icons for each skill,
-- working around the 7 texture atlases limit.
---------------------------------------------

local SkillBook = Client.UI.Skills

---@class Features.SkillbookIconsFix : Feature
local Fix = {
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h165ef29eg55a7g4148g920eg6505ada99b29",
            Text = "Render icons individually",
            ContextDescription = [[Setting name]],
        },
        Setting_Enabled_Description = {
            Handle = "h020cf6bbgd57ag41eag801fg538b7b9901fc",
            Text = "If enabled, skill icons in the skills UI will be rendered individually rather than as a single texture.<br>This fixes the issue of icons disappearing when using many mods.",
            ContextDescription = [[Setting tooltip for "Render icons individually"]],
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.SkillbookIconsFix", Fix)
local TSK = Fix.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Fix.Settings.Enabled = Fix:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Renders an icon onto a skill element.
---@param uiObj UIObject
---@param mc FlashMovieClip
function Fix._RenderIcon(uiObj, mc)
    local skillID = mc.tooltipID -- tooltipID is used for learnt skills, id is used for memorySegment.
    local element = mc.hit_mc -- Cooldown element cannot be used - it might not have any width/height normally?
    element.scaleX, element.scaleY = 1, 1 -- Default scale is non-1.
    element.x, element.y = element.x + 5, element.y + 5

    local skill = Stats.GetSkillData(skillID)
    local icon = skill.Icon
    element.name = "iggy_" .. icon
    uiObj:SetCustomIcon(icon, icon, 56, 56)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create iggy icons for all skills.
SkillBook:RegisterInvokeListener("updateSkills", function (_, _)
    local uiObj, root = SkillBook:GetUI(), SkillBook:GetRoot()
    local enabled = Fix.Settings.Enabled:GetValue()

    root.skillPane_mc.iggy_grid.visible = not enabled
    -- root.skillPane_mc.iggy_memory.visible = not enabled -- TODO

    if enabled then
        -- Cannot be done right afterwards for unknown reasons.
        Ext.OnNextTick(function ()
            -- Add icons to learnt skills.
            local skillLists = root.skillPane_mc.skillLists.content_array
            for i=0,#skillLists-1,1 do
                local skillList = skillLists[i].list.content_array
                for j=0,#skillList-1,1 do
                    local entry = skillList[j]
                    Fix._RenderIcon(uiObj, entry)
                end
            end
            -- TODO also support memorized skills panel
        end)
    end
end, "After")
