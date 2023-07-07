
local Generic = Client.UI.Generic

local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---Prefab for a button.
---@class GenericUI_Prefab_Button : GenericUI_Prefab, GenericUI_I_Stylable, GenericUI_I_Elementable
---@field _State GenericUI_Prefab_Button_InteractionState
---@field _Style GenericUI_Prefab_Button_Style
---@field _ActivatedStyle GenericUI_Prefab_Button_Style If present, the button will be considered a state button.
---@field _Disabled boolean
---@field _Activated boolean
---@field Root GenericUI_Element_Texture
---@field ActivatedOverlay GenericUI_Element_Texture? Only present if using a style that is a state button.
---@field Icon GenericUI_Element_IggyIcon? Only present if an icon was set.
---@field Label GenericUI_Prefab_Text
local Button = {
    DEFAULT_SOUND = "UI_Gen_XButton_Click",

    Events = {
        Pressed = {}, ---@type Event<EmptyEvent> Fires only if the button is enabled.
        RightClicked = {}, ---@type Event<EmptyEvent> Fires even if the button is disabled.
    },
}
Generic:RegisterClass("GenericUI_Prefab_Button", Button, {"GenericUI_Prefab", "GenericUI_I_Stylable", "GenericUI_I_Elementable"})
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
---@field IdleOverlay TextureLib_Texture?
---@field HighlightedOverlay TextureLib_Texture? If not present, `IdleOverlay` will be used instead.
---@field PressedOverlay TextureLib_Texture? If not present, `IdleOverlay` will be used instead.

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
    instance._Activated = false

    local root = instance:CreateElement(id, "GenericUI_Element_Texture", parent)
    local label = TextPrefab.Create(ui, instance:PrefixID("Label"), root, "", "Center", Vector.Create(1, 1))

    instance.Root = root
    instance.Label = label

    instance:_SetupListeners()

    -- This will implicitly call _UpdateTextures() due to __OnStyleChanged()
    instance:SetStyle(style)
    instance:SetLabel("")

    return instance
end

---Sets a style to be used while the button is active.
---**This cannot be used to revert the button to a normal one if it was already a state button.**
---@param style GenericUI_Prefab_Button_Style If background fields are not assigned, the normal style will be used as fallback.
function Button:SetActiveStyle(style)
    self._ActivatedStyle = style or self._ActivatedStyle -- Cannot currently un-set active style - TODO? Investigate implications
    self:_UpdateTextures()
end

---Sets the label of the button.
---@param label string Set to an empty string to hide the label.
---@param align GenericUI_Element_Text_Align? Defaults to `"Center"`.
function Button:SetLabel(label, align)
    local element = self.Label
    align = align or "Center"

    if label ~= "" then
        local textSize
        local mc = element:GetMovieClip().text_txt
        mc.multiline = false
        mc.wordWrap = false -- Necessary.

        element:SetText(label)

        -- Set size of the text element to the minimum size of the text itself, and center it
        textSize = element:GetTextSize()
        element:SetSize(textSize:unpack())
        element:SetPositionRelativeToParent(align, 0, 0)
    end

    element:SetVisible(label ~= "")
end

---Sets an icon for the button.
---@param icon icon
---@param size Vector2
---@param relativePosition GenericUI_Element_RelativePosition? Defaults to `"Center"`.
---@param offset Vector2? Defaults to `(0, 0)`.
function Button:SetIcon(icon, size, relativePosition, offset)
    local element = self.Icon
    if not element then
        element = self:CreateElement("Icon", "GenericUI_Element_IggyIcon", self.Root)
        self.Icon = element
    end
    relativePosition = relativePosition or "Center"
    offset = offset or Vector.Create(0, 0)

    element:SetIcon(icon, size:unpack())
    element:SetPositionRelativeToParent(relativePosition, offset:unpack())
end

---Sets the enabled state of the button.
---@param enabled boolean
function Button:SetEnabled(enabled)
    self._Disabled = not enabled
    self:_UpdateTextures()
end

---Returns whether the button is enabled.
---Disabled buttons do not fire the Pressed event.
---@return boolean
function Button:IsEnabled()
    return not self._Disabled
end

---Returns whether the button is activated.
---Will throw if the button is not a state button.
---@return boolean
function Button:IsActivated()
    if not self:_IsStateButton() then
        Generic:Error("Prefab_Button:IsActivated", "Button is not a state button")
    end
    return self._Activated
end

---Sets the activated state of the button.
---Will throw if the button is not a state button.
---@param activated any
function Button:SetActivated(activated)
    if not self:_IsStateButton() then
        Generic:Error("Prefab_Button:SetActivated", "Button is not a state button")
    end
    self._Activated = activated
    self:_UpdateTextures()
end

---Sets the tooltip of the element.
---@param type TooltipLib_TooltipType
---@param tooltip any TODO document
function Button:SetTooltip(type, tooltip)
    self.Root:SetTooltip(type, tooltip)
end

---@override
function Button:GetRootElement()
    return self.Root
end

---Returns the label element.
---@return GenericUI_Prefab_Text
function Button:GetLabelElement()
    return self.Label
end

---Returns the icon element, if any.
---@return GenericUI_Element_IggyIcon?
function Button:GetIconElement()
    return self.Icon
end

---Updates the texture of the button based on its state.
function Button:_UpdateTextures()
    local state = self._State
    local style = self:_GetCurrentStyle()
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
            Generic:Error("Prefab_Button:_UpdateTextures()", "Invalid state", state)
        end
    end

    self.Root:SetTexture(texture, style.Size)
    self:_UpdateActivatedOverlay()
end

---Returns the style to use for the current state.
---@return GenericUI_Prefab_Button_Style
function Button:_GetCurrentStyle()
    return self._Activated and self._ActivatedStyle or self._Style
end

---Returns the overlay texture to use, if any.
---@return TextureLib_Texture?
function Button:_GetOverlayTexture()
    local style = self:_GetCurrentStyle()
    local texture = nil

    if self._State == "Idle" then
        texture = style.IdleOverlay
    elseif self._State == "Highlighted" then
        texture = style.HighlightedOverlay or style.IdleOverlay
    elseif self._State == "Pressed" then
        texture = style.PressedOverlay or style.IdleOverlay
    end

    return texture
end

---Updates the activated texture overlay.
function Button:_UpdateActivatedOverlay()
    local texture = self:_GetOverlayTexture()
    local overlay = self.ActivatedOverlay
    if not overlay and self:_IsStateButton() then -- Create the overlay if necessary.
        overlay = self:CreateElement("ActivatedOverlay", "GenericUI_Element_Texture", self.Root)
        self.ActivatedOverlay = overlay
        self.Root:SetChildIndex(overlay, 1)
    end

    if self:_IsStateButton() and texture then
        overlay:SetTexture(texture)
        overlay:SetPositionRelativeToParent("Center")
        overlay:SetVisible(true)
    elseif overlay then
        overlay:SetVisible(false)
    end
end

---Sets the state of the button.
---@param state GenericUI_Prefab_Button_InteractionState
function Button:_SetState(state)
    self._State = state
    self:_UpdateTextures()
end

---Returns whether the button is a State Button.
---@return boolean
function Button:_IsStateButton()
    return self._ActivatedStyle ~= nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@override
function Button:__OnStyleChanged()
    self:_UpdateTextures()
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
            self.UI:PlaySound(self:_GetCurrentStyle().Sound or self.DEFAULT_SOUND)

            -- Toggle activated state
            if self:_IsStateButton() then
                self:SetActivated(not self:IsActivated())
            end
        end
    end)

    root.Events.RightClick:Subscribe(function (ev)
        self.Events.RightClicked:Throw(ev)
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