
local Generic = Client.UI.Generic
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu") ---@class SettingsMenu
local SettingsMenuOverlay = Epip.GetFeature("Feature_SettingsMenuOverlay")

---@class Features.PersonalScripts.Prefabs.Entry : GenericUI_Prefab_FormElement
---@field EnabledCheckbox GenericUI_Prefab_Button
---@field LoadOrderButtonsList GenericUI_Element_VerticalList
---@field LoadOrderUpButton GenericUI_Prefab_Button
---@field LoadOrderDownButton GenericUI_Prefab_Button
---@field _ScriptConfig Features.PersonalScripts.Script
local Entry = {
    DEFAULT_SIZE = Vector.Create(SettingsMenuOverlay.UI.FORM_ELEMENT_SIZE),
    MAX_PATH_LENGTH = 40, -- In characters.
}
OOP.SetMetatable(Entry, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("Features.PersonalScripts.Prefabs.Entry", Entry)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param scriptConfig Features.PersonalScripts.Script
---@param index integer?
---@return Features.PersonalScripts.Prefabs.Entry
function Entry.Create(ui, id, parent, scriptConfig, index)
    local size = Entry.DEFAULT_SIZE
    local obj = Entry:_Create(ui, id) ---@cast obj Features.PersonalScripts.Prefabs.Entry

    obj:__SetupBackground(parent, size)

    -- Enabled state button
    local button = ButtonPrefab.Create(ui, obj:PrefixID("EnabledButton"), obj.Background, ButtonPrefab.STYLES.FormCheckbox_Inactive)
    button:SetActiveStyle(ButtonPrefab.STYLES.FormCheckbox_Active)
    obj.EnabledCheckbox = button

    -- Load order buttons
    local loadOrderButtonsList = obj:AddChild("LoadOrderButtonsList", "GenericUI_Element_VerticalList")
    loadOrderButtonsList:SetElementSpacing(0)
    local orderUpButton = ButtonPrefab.Create(ui, obj:PrefixID("LoadOrderUpButton"), loadOrderButtonsList, ButtonPrefab.STYLES.DiamondUp)
    obj.LoadOrderUpButton = orderUpButton
    local orderDownButton = ButtonPrefab.Create(ui, obj:PrefixID("LoadOrderDownButton"), loadOrderButtonsList, ButtonPrefab.STYLES.DiamondDown)
    obj.LoadOrderDownButton = orderDownButton
    loadOrderButtonsList:RepositionElements()
    obj.LoadOrderButtonsList = loadOrderButtonsList

    obj:SetScript(scriptConfig, index)
    obj:SetSize(size:unpack())

    return obj
end

---Sets the size of the form.
---@param width number
---@param height number
function Entry:SetSize(width, height)
    local labelElement = self.Label

    self:SetBackgroundSize(Vector.Create(width, height))

    labelElement:SetSize(width, 30)
    labelElement:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN + self.LoadOrderButtonsList:GetWidth(), 0)
    self.EnabledCheckbox:SetPositionRelativeToParent("Right", -self.LABEL_SIDE_MARGIN, 0)
    self.LoadOrderButtonsList:SetPositionRelativeToParent("Left", -self.LABEL_SIDE_MARGIN, 0)
end

---Updates the element from the script config's fields.
---@param scriptConfig Features.PersonalScripts.Script
---@param index integer?
function Entry:SetScript(scriptConfig, index)
    self._ScriptConfig = scriptConfig
    local pathLabel = scriptConfig.Path
    if #pathLabel > self.MAX_PATH_LENGTH then -- Truncate long paths to show only the end (ex. paths relative to game data dir)
        pathLabel = "..." .. pathLabel:sub(#pathLabel - self.MAX_PATH_LENGTH)
    end
    self:SetLabel(Text.Format("%s (%s, %s) %s", {
        FormatArgs = {
            index and (index .. ".") or "",
            scriptConfig.Context,
            {
                Text = scriptConfig.ModTable,
                FontType = Text.FONTS.ITALIC,
            },
            pathLabel,
        },
    }))
    self.EnabledCheckbox:SetActivated(scriptConfig.Enabled)
end

---Returns the script the instance is displaying.
---@return Features.PersonalScripts.Script
function Entry:GetScript()
    return self._ScriptConfig
end

---@override
function Entry:GetInteractableElement()
    return self.Label -- TODO
end
