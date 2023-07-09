
local Generic = Client.UI.Generic
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")

---Prefab for a button that hides the UI.
---@class GenericUI_Prefab_CloseButton : GenericUI_Prefab_Button
local CloseButton = {
    DEFAULT_STYLE = ButtonPrefab:GetStyle("Close"),
}
Generic.RegisterPrefab("GenericUI_Prefab_CloseButton", CloseButton) -- Not necessary to directly inherit from Button as Create() creates a Button

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_CloseButton"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a CloseButton.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param style GenericUI_Prefab_Button_Style? Defaults to `DEFAULT_STYLE`.
---@return GenericUI_Prefab_CloseButton
function CloseButton.Create(ui, id, parent, style)
    local instance = ButtonPrefab.Create(ui, id, parent, style or CloseButton.DEFAULT_STYLE) ---@type GenericUI_Prefab_CloseButton

    instance.Events.Pressed:Subscribe(function (_) -- Hide UI
        Ext.OnNextTick(function (_)
            ui:Hide()
        end)
    end)

    return instance
end