
---------------------------------------------
-- Allows fetching templates that have a SkillBook use action.
---------------------------------------------

local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")
local Set = DataStructures.Get("DataStructures_Set")

---@class Features.SkillbookTemplates : Feature
local Skillbooks = {
    _Templates = Set.Create({}), ---@type DataStructures_Set<GUID>
    _SkillToTemplates = DefaultTable.Create({}), ---@type table<string, GUID[]>
    _Initialized = false,
}
Epip.RegisterFeature("SkillbookTemplates", Skillbooks)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns all item templates that have a SkillBook action.
---@return table<GUID, ItemTemplate>
function Skillbooks.GetAll()
    Skillbooks._Initialize()
    local templates = {}

    for guid in Skillbooks._Templates:Iterator() do
        templates[guid] = Ext.Template.GetRootTemplate(guid)
    end 

    return templates
end

---Returns the item templates that teach a skill via a SkillBook action.
---@param skillID any
function Skillbooks.GetForSkill(skillID)
    Skillbooks._Initialize()
    return Skillbooks._SkillToTemplates[skillID]
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Initializes the data structures and searches root templates.
function Skillbooks._Initialize()
    if not Skillbooks._Initialized then
        for guid,template in pairs(Ext.Template.GetAllRootTemplates()) do
            if GetExtType(template) == "ItemTemplate" then
                ---@cast template ItemTemplate
                local actions = Item.GetUseActions(template, "SkillBook")
                if #actions > 0 then
                    ---@cast actions UseSkillActionData[]
                    Skillbooks._Templates:Add(guid)

                    -- Add to list of templates for the skill
                    for _,action in ipairs(actions) do
                        table.insert(Skillbooks._SkillToTemplates[action.SkillID], guid)
                    end
                end
            end
        end

        Skillbooks._Initialized = true
    end
end