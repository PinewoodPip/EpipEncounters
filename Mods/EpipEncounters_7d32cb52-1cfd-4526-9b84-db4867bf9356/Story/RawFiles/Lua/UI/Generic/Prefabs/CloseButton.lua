
local Generic = Client.UI.Generic

---Prefab for a button that hides the UI.
---@class GenericUI_Prefab_CloseButton : GenericUI_Prefab
---@field Button GenericUI_Element_Button
local CloseButton = {
    DEFAULT_SIZE = Vector.Create(32, 32),
    Events = {
        Pressed = {}, ---@type Event<GenericUI_Element_Button_Event_Pressed>
    },
}
Generic.RegisterPrefab("GenericUI_Prefab_CloseButton", CloseButton)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param size Vector2? Defaults to `DEFAULT_SIZE`.
---@return GenericUI_Prefab_CloseButton
function CloseButton.Create(ui, id, parent, size)
    local instance = CloseButton:_Create(ui, id) ---@type GenericUI_Prefab_CloseButton
    size = size or CloseButton.DEFAULT_SIZE

    local button = instance:CreateElement(id, "GenericUI_Element_Button", parent)
    button:SetType("Close")
    button.Events.Pressed:Subscribe(function (ev) -- Forward Pressed event and hide UI
        instance.Events.Pressed:Throw(ev)
        ui:Hide()
    end)

    instance.Button = button

    return instance
end

---Sets the relative position of the button.
---@param position "Center"|"TopLeft"|"TopRight"|"Top"|"Left"|"Right"|"BottomLeft"|"Bottom"|"BottomRight" TODO extract alias
---@param horizontalOffset number?
---@param verticalOffset number?
function CloseButton:SetPositionRelativeToParent(position, horizontalOffset, verticalOffset)
    self.Button:SetPositionRelativeToParent(position, horizontalOffset or 0, verticalOffset or 0)
end