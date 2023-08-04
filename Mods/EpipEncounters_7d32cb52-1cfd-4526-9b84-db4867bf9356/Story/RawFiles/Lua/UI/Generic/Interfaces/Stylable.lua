
local Generic = Client.UI.Generic

---@class GenericUI_I_Stylable : Class
---@field __Style GenericUI_I_Stylable_Style
---@field _RegisteredStyles table<string, GenericUI_I_Stylable_Style>
local Stylable = {}
Generic:RegisterClass("GenericUI_I_Stylable", Stylable)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI_I_Stylable_Style

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a style.
---**Styles are stored per-class, not globally.**
---@param id string
---@param style GenericUI_I_Stylable_Style
function Stylable:RegisterStyle(id, style)
    local def = self:GetClassDefinition()
    ---@cast def GenericUI_I_Stylable

    if not def._RegisteredStyles then
        def._RegisteredStyles = {}
    end

    def._RegisteredStyles[id] = style
end

---Returns a style by its ID.
---Throws if the style is not registered.
---@param id string
---@return GenericUI_I_Stylable_Style
function Stylable:GetStyle(id)
    local def = self:GetClassDefinition() ---@cast def GenericUI_I_Stylable
    local style = def._RegisteredStyles[id]
    if not style then
        Generic:Error("Stylable:GetStyle", "Style not registered", id)
    end
    return style
end

---Returns the registered styles for the class.
---@return table<string, GenericUI_I_Stylable_Style>
function Stylable:GetStyles()
    local def = self:GetClassDefinition() ---@cast def GenericUI_I_Stylable
    local styles = {}
    for k,v in pairs(def._RegisteredStyles) do styles[k] = v end
    return styles
end

---Sets the style.
---@param style GenericUI_I_Stylable_Style
function Stylable:SetStyle(style)
    self.__Style = style
    self:__OnStyleChanged()
end

---Called when the style is changed.
---@abstract
function Stylable:__OnStyleChanged() end