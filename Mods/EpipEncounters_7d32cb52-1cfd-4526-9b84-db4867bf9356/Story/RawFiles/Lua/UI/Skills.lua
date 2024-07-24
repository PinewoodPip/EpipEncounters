
---@class SkillsUI : UI
local Skills = {
    FLASH_ENTRY_TEMPLATES = {
        SKILL = {
            "Index",
            "Skill",
            "School",
            "Learnt",
            "MemoryCost",
            "Memorized",
        },
    },
    selectedSkill = nil, ---@type string

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        UpdateSkills = {}, ---@type Hook<UI.Skills.Hooks.UpdateSkills>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.skills, "Skills", Skills)

---------------------------------------------
-- CLASSES & EVENTS
---------------------------------------------

---@class UI.Skills.Entries.Skill
---@field Index integer
---@field Skill skill
---@field School integer
---@field Learnt boolean
---@field MemoryCost integer
---@field Memorized boolean

---@class UI.Skills.Hooks.UpdateSkills
---@field Entries UI.Skills.Entries.Skill Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skill currently being hovered over.
---@return string?
function Skills.GetSelectedSkill()
    -- Exiting the UI without hovering out of a skill will not fire hideTooltip; we must clear the selected skill ourselves.
    if not Skills:IsVisible() then
        Skills.selectedSkill = nil
    end

    return Skills.selectedSkill
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Track the selected skill by listening for the tooltip.
Skills:RegisterCallListener("showSkillTooltip", function(_, _, skillID)
    Skills.selectedSkill = skillID
end)
Skills:RegisterCallListener("hideTooltip", function(_)
    Skills.selectedSkill = nil
end)

-- Hook skill updates.
Skills:RegisterInvokeListener("updateSkills", function (ev, _) -- Boolean param purpose is unknown.
    local root = ev.UI:GetRoot()
    local array = root.skillsUpdateList
    local TEMPLATE = Skills.FLASH_ENTRY_TEMPLATES.SKILL
    local entries = Client.Flash.ParseArray(array, TEMPLATE)

    entries = Skills.Hooks.UpdateSkills:Throw({
        Entries = entries,
    }).Entries

    Client.Flash.EncodeArray(array, TEMPLATE, entries)
end)
