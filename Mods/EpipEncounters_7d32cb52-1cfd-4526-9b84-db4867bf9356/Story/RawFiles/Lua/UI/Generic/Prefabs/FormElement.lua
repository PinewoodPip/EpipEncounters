
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Component = Navigation:GetClass("GenericUI.Navigation.Component")
local LegacyElementNavigation = Navigation:GetClass("GenericUI.Navigation.LegacyElementNavigation")

---Base class for prefabs styled as a form element.
---@class GenericUI_Prefab_FormElement : GenericUI_Prefab, GenericUI_I_Elementable
---@field Background GenericUI_Element_TiledBackground
---@field Label GenericUI_Prefab_Text
local Prefab = {
    DEFAULT_SIZE = Vector.Create(600, 50),
    LABEL_SIDE_MARGIN = 5,
    BACKGROUND_ALPHA = {
        FOCUSED = 1,
        UNFOCUSED = 0.2,
    }
}
Generic:RegisterClass("GenericUI_Prefab_FormElement", Prefab, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI_Prefab_FormElement", Prefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormElement"

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI.Prefabs.FormElement.NavigationComponent : GenericUI.Navigation.Component
---@field __Target GenericUI_Prefab_FormElement
local _NavigationComponent = {
    CONSUMED_IGGY_EVENTS = {
        "UIAccept",
        "UIUp",
        "UIDown",
    }
}
Generic:RegisterClass("GenericUI.Prefabs.FormElement.NavigationComponent", _NavigationComponent, {"GenericUI.Navigation.Component"})

---Creates a navigation component for a form element.
---@param prefabInstance GenericUI_Prefab_FormElement
---@return GenericUI.Prefabs.FormElement.NavigationComponent
function _NavigationComponent.Create(prefabInstance)
    local instance = Component.Create(_NavigationComponent, prefabInstance:GetRootElement()) ---@cast instance GenericUI.Prefabs.FormElement.NavigationComponent

    instance.__Target = prefabInstance

    return instance
end

---@override
function _NavigationComponent:OnIggyEvent(event)
    if event.Timing == "Down" then
        local interactable = self.__Target:GetInteractableElement()
        if interactable then
            if event.EventID == "UIAccept" then
                LegacyElementNavigation.InteractWith(interactable)
                return true
            elseif (event.EventID == "UIUp" or event.EventID == "UIDown") and interactable.Type == "GenericUI_Element_ComboBox" then
                ---@cast interactable GenericUI_Element_ComboBox
                if interactable:IsOpen() then
                    LegacyElementNavigation.ScrollComboBox(interactable, event.EventID == "UIUp" and -1 or 1)
                    return true
                end
            end
        end
    end
end

---@override
function _NavigationComponent:OnFocusChanged(focused)
    local interactable = self.__Target:GetInteractableElement()
    if interactable then
        LegacyElementNavigation.SetFocus(interactable, focused)
    end

    -- Change background opacity to indicate focus.
    -- This is only used for navigation, so as not to make the background seem interactable when using mouse.
    local bg = self.__Target.Background
    local BG_ALPHA = self.__Target.BACKGROUND_ALPHA
    bg:SetAlpha(focused and BG_ALPHA.FOCUSED or BG_ALPHA.UNFOCUSED)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param size Vector2
---@return GenericUI_Prefab_FormElement
function Prefab.Create(ui, id, parent, size)
    local instance = Prefab:_Create(ui, id) ---@cast instance GenericUI_Prefab_FormElement

    instance:__SetupBackground(parent, size)

    return instance
end

---Creates the background and label elements.
---@protected
---@param parent (GenericUI_Element|string)?
---@param size Vector2
function Prefab:__SetupBackground(parent, size)
    local bg = self:CreateElement("Background", "GenericUI_Element_TiledBackground", parent)
    local text = TextPrefab.Create(self.UI, self:PrefixID("Label"), bg, "", "Left", Vector.Create(size[1], 30))
    text:SetWordWrap(false)

    self.Background = bg
    self.Label = text

    Prefab.SetBackgroundSize(self, size) -- Use base class method
    text:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN, 0)

    -- Create a navigation component by default
    -- TODO make this optional? Though I don't think the overhead is but minimum
    _NavigationComponent.Create(self)
end

---Sets the size of the background.
---@param size Vector2
function Prefab:SetBackgroundSize(size)
    local root = self:GetRootElement()

    root:SetBackground("Black", size:unpack())
    root:SetAlpha(self.BACKGROUND_ALPHA.UNFOCUSED)
    root:SetSizeOverride(size) -- Prevent overflowing elements from altering the size of the prefab (for containers)
end

---Returns the label of the element.
---@return string
function Prefab:GetLabel()
    return self.Label:GetMovieClip().text_txt.htmlText
end

---Sets the label.
---@param label string
function Prefab:SetLabel(label)
    self.Label:SetText(label)
end

---Sets whether the element should be centered in lists.
---@param center boolean
function Prefab:SetCenterInLists(center)
    self:GetRootElement():SetCenterInLists(center)
end

---Sets the tooltip of the element.
---@param type TooltipLib_TooltipType
---@param tooltip any TODO document
function Prefab:SetTooltip(type, tooltip)
    self:GetRootElement():SetTooltip(type, tooltip)
end

---Returns the main interactable element within this form entry.
---@virtual
---@return GenericUI_Element?
function Prefab:GetInteractableElement()
    return nil
end

---@override
---@return GenericUI_Element_TiledBackground
function Prefab:GetRootElement()
    return self.Background
end
