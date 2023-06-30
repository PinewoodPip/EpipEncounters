
---------------------------------------------
-- Implements an ingame knowledgebase for various topics,
-- using a Generic UI.
-- 26/06/23 Pip
---------------------------------------------

---@class Feature_Codex : Feature
---@field UI Feature_Codex_UI
local Codex = {
    _Sections = {}, ---@type table<string, Feature_Codex_Section>
    _SectionRegistrationOrder = {}, ---@type string[]

    TranslatedStrings = {
        Title = {
           Handle = "hc31a7649g3a59g4595gbfecg3fdc812c0c1f",
           Text = "Codex",
           ContextDescription = "Shown at the top of the UI",
        },
        InputAction_Open_Name = {
           Handle = "h52c8465ag5bf7g4420g93b7ge555e6acb172",
           Text = "Open Codex",
           ContextDescription = "Keybind name",
        },
    },
}
Epip.RegisterFeature("Codex", Codex)

Codex.InputActions.Open = Codex:RegisterInputAction("Open", {
    Name = Codex.TranslatedStrings.InputAction_Open_Name:GetString(),
    DefaultInput1 = {Keys = {"lctrl", "g"}},
})

---------------------------------------------
-- CLASSES
---------------------------------------------

---Interface for a section.
---I_Describable is used to provide the name of the section for the index,
---as well as a description of the section shown in a tooltip.
---@class Feature_Codex_Section : I_Describable, I_Identifiable, Class
---@field Icon icon? Shown on the index button.
local Section = {}
Interfaces.Apply(Section, "I_Identifiable")
Interfaces.Apply(Section, "I_Describable")
Codex:RegisterClass("Feature_Codex_Section", Section)

---Creates a section.
---@param data Feature_Codex_Section
---@return Feature_Codex_Section
function Section.Create(data)
    local instance = Section:__Create(data) ---@cast instance Feature_Codex_Section
    return instance
end

---Called to render the core static elements of the section.
---Used to initialize the UI. **Only called once.**
---@param root GenericUI_Element_Empty Root element for your section. For correct bookkeeping, keep all of your section's hierarchy within this element.
---@diagnostic disable-next-line: unused-local
function Section:Render(root) end

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the Codex UI.
function Codex.Open()
    if not Codex.UI then
        Codex:Error("Open", "UI not set")
    end

    Codex.UI:Show()
end

---Registers a section.
---@param id string
---@param section Feature_Codex_Section
function Codex.RegisterSection(id, section)
    if not OOP.IsClass(section) or not section:ImplementsClass("Feature_Codex_Section") then
        Codex:Error("RegisterSection", "Passed table does not implement Feature_Codex_Section")
    end
    section.ID = id
    Codex._Sections[id] = section
    table.insert(Codex._SectionRegistrationOrder, id)
end

---Returns a section by its ID.
---@param id string
---@return Feature_Codex_Section
function Codex.GetSection(id)
    return Codex._Sections[id]
end

---Returns a list of registered sections.
---@return Feature_Codex_Section[]
function Codex.GetSections()
    local sections = {}
    for i,id in ipairs(Codex._SectionRegistrationOrder) do
        sections[i] = Codex.GetSection(id)
    end
    return sections
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Toggle the UI when the input action is used.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action == Codex.InputActions.Open and Codex.UI then
        Codex.UI:ToggleVisibility()
    end
end)