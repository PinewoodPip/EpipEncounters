
local Generic = Client.UI.Generic

local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---Prefab for a button.
---@class GenericUI_Prefab_Button : GenericUI_Prefab, GenericUI_I_Stylable
---@field _State GenericUI_Prefab_Button_InteractionState
---@field _Style GenericUI_Prefab_Button_Style
---@field _Disabled boolean
---@field _Activated boolean
---@field Root GenericUI_Element_Texture
---@field ActivatedOverlay GenericUI_Element_Texture? Only present if using a style that is a state button.
---@field Label GenericUI_Prefab_Text
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
---@field ActiveOverlay TextureLib_Texture? If present, the button will be considered a state button. Used when the button is activated.

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

---Sets the label of the button.
---@param label string Set to an empty string to hide the label.
function Button:SetLabel(label)
    local element = self.Label

    if label ~= "" then
        local textSize
        local mc = element:GetMovieClip().text_txt
        mc.multiline = false
        mc.wordWrap = false -- Necessary.

        element:SetText(label)

        -- Set size of the text element to the minimum size of the text itself, and center it
        textSize = element:GetTextSize()
        textSize = Vector.Create(textSize[1], textSize[2] / 2) -- No idea why division by 2 is necessary; textHeight just seems to always report +1 line, while width is correct.
        element:SetSize(textSize:unpack())
        element:SetPositionRelativeToParent("Center", 0, 0)
    end

    element:SetVisible(label ~= "")
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
    self:_UpdateActivatedOverlay()
end

---Sets the tooltip of the element.
---@param type TooltipLib_TooltipType
---@param tooltip any TODO document
function Button:SetTooltip(type, tooltip)
    self.Root:SetTooltip(type, tooltip)
end

---Sets the relative position of the button.
---@param position "Center"|"TopLeft"|"TopRight"|"Top"|"Left"|"Right"|"BottomLeft"|"Bottom"|"BottomRight" TODO extract alias
---@param horizontalOffset number?
---@param verticalOffset number?
function Button:SetPositionRelativeToParent(position, horizontalOffset, verticalOffset)
    self.Root:SetPositionRelativeToParent(position, horizontalOffset, verticalOffset)
end

---Updates the texture of the button based on its state.
function Button:_UpdateTextures()
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
            Generic:Error("Prefab_Button:_UpdateTextures()", "Invalid state", state)
        end
    end

    self.Root:SetTexture(texture, style.Size)
    self:_UpdateActivatedOverlay()
end

---Updates the activated texture overlay.
function Button:_UpdateActivatedOverlay()
    local overlay = self.ActivatedOverlay
    if not overlay and self:_IsStateButton() then -- Create the overlay if necessary.
        overlay = self:CreateElement("ActivatedOverlay", "GenericUI_Element_Texture", self.Root)
        self.ActivatedOverlay = overlay
        self.Root:SetChildIndex(overlay, 1)
    end

    if self:_IsStateButton() then
        overlay:SetTexture(self._Style.ActiveOverlay)
        overlay:SetPositionRelativeToParent("Center")
        overlay:SetVisible(self._Activated)
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
    return self._Style.ActiveOverlay ~= nil
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
            self.UI:PlaySound(self._Style.Sound or self.DEFAULT_SOUND)

            -- Toggle activated state
            if self:_IsStateButton() then
                self:SetActivated(not self:IsActivated())
            end
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