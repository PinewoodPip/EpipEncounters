
---@class UI.Controller.InventorySkillPanel : UI
local SkillPanel = {
    _CurrentSkill = nil, ---@type skill?
}
Epip.InitializeUI(Ext.UI.TypeID.inventorySkillPanel_c, "InventorySkillPanelC", SkillPanel, false)
Client.UI.Controller.InventorySkillPanel = SkillPanel

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skill selected in the panel.
---@return skill? -- `nil` if the UI is not open.
function SkillPanel.GetSelectedSkill()
    return SkillPanel:IsVisible() and SkillPanel._CurrentSkill or nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Track the selected skill.
-- The useSkill UI call appears to be bugged and not pass the skill ID.
SkillPanel:RegisterCallListener("selectSkill", function (_, skill)
    SkillPanel._CurrentSkill = skill
end)