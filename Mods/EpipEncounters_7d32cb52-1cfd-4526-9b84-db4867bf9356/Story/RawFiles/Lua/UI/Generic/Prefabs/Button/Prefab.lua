
local Generic = Client.UI.Generic

---Prefab for a button.
---@class GenericUI_Prefab_Button : GenericUI_Prefab, GenericUI_I_Stylable
---@field _State GenericUI_Prefab_Button_InteractionState
---@field _Style GenericUI_Prefab_Button_Style
---@field _Disabled boolean
---@field Root GenericUI_Element_Texture
local Button = {
    DEFAULT_SOUND = "UI_Gen_XButton_Click",

    Events = {
        Pressed = {}, ---@type Event<EmptyEvent>
    },
}
Generic:RegisterClass("GenericUI_Prefab_Button", Button, {"GenericUI_Prefab", "GenericUI_I_Stylable"})
Generic.RegisterPrefab("GenericUI_Prefab_Button", Button)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Button"

---@alias GenericUI_Prefab_Button_InteractionState "Idle"|"Highlighted"|"Pressed"

---@class GenericUI_Prefab_Button_Style : GenericUI_I_Stylable_Style
---@field IdleTexture TextureLib_Texture
---@field HighlightedTexture TextureLib_Texture If not present, `IdleTexture` will be used instead.
---@field PressedTexture TextureLib_Texture? If not present, `IdleTexture` will be used instead.
---@field DisabledTexture TextureLib_Texture? If not present, `IdleTexture` will be used instead.
---@field Size Vector2? Defaults to texture size.
---@field Sound string? Sound effect to play when the button is pressed. Defaults to `DEFAULT_SOUND`.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param style GenericUI_Prefab_Button_Style
---@return GenericUI_Prefab_Button
function Button.Create(ui, id, parent, style)
    local instance = Button:_Create(ui, id) ---@type GenericUI_Prefab_Button
    instance._State = "Idle"
    instance._Disabled = false

    local root = instance:CreateElement(id, "GenericUI_Element_Texture", parent)

    instance.Root = root

    instance:_SetupListeners()

    -- This will implicitly call _UpdateTexture() due to __OnStyleChanged()
    instance:SetStyle(style)

    return instance
end

---Sets the enabled state of the button.
---@param enabled boolean
function Button:SetEnabled(enabled)
    self._Disabled = not enabled
    self:_UpdateTexture()
end

---Returns whether the button is enabled.
---Disabled buttons do not fire the Pressed event.
---@return boolean
function Button:IsEnabled()
    return not self._Disabled
end

---Updates the texture of the button based on its state.
function Button:_UpdateTexture()
    local state = self._State
    local style = self._Style
    local texture = nil

    if not self:IsEnabled() then
        texture = style.DisabledTexture or style.IdleTexture
    else
        if state == "Idle" then
            texture = style.IdleTexture
        elseif state == "Highlighted" then
            texture = style.HighlightedTexture or style.IdleTexture
        elseif state == "Pressed" then
            texture = style.PressedTexture or style.IdleTexture
        else
            Generic:Error("Prefab_Button:_UpdateTexture()", "Invalid state", state)
        end
    end

    self.Root:SetTexture(texture, style.Size)
end

---Sets the state of the button.
---@param state GenericUI_Prefab_Button_InteractionState
function Button:_SetState(state)
    self._State = state
    self:_UpdateTexture()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@override
function Button:__OnStyleChanged()
    self:_UpdateTexture()
end

---------------------------------------------
-- SETUP
---------------------------------------------

---Registers the required event listeners on the root element.
function Button:_SetupListeners()
    local root = self.Root

    -- Pressed event
    root.Events.MouseUp:Subscribe(function (ev)
        if self:IsEnabled() then
            self.Events.Pressed:Throw(ev)

            self:_SetState("Highlighted")
            self.UI:PlaySound(self._Style.Sound or self.DEFAULT_SOUND)
        end
    end)

    root.Events.MouseDown:Subscribe(function (_)
        if self:IsEnabled() then
            self:_SetState("Pressed")
        end
    end)

    root.Events.MouseOver:Subscribe(function (_)
        if self:IsEnabled() then
            self:_SetState("Highlighted")
        end
    end)

    root.Events.MouseOut:Subscribe(function (_)
        self:_SetState("Idle")
    end)
end