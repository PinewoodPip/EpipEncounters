
local Set = DataStructures.Get("DataStructures_Set")
local CommonStrings = Text.CommonStrings

---@class Feature_IconPicker : Feature
local Picker = {
    _CurrentRequest = nil, ---@type string
    _UI = nil, ---@type GenericUI_Instance

    TranslatedStrings = {
        UI_Header = {
           Handle = "h94b55185g6055g42b9gac5bgc6bedbffdfef",
           Text = "Choose an icon...",
           ContextDescription = "UI header text",
        },
        Setting_IconType_Name = {
           Handle = "hcb827408g8ce1g41ffg8145gca288912cfb1",
           Text = "Icon Type",
           ContextDescription = "Icon type setting name",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        IconPicked = {}, ---@type Event<Feature_IconPicker_Event_IconPicked>
    },
    Hooks = {
        IsTemplateValid = {}, ---@type Event<Feature_IconPicker_Hook_IsTemplateValid>
    }
}
Epip.RegisterFeature("IconPicker", Picker)

---------------------------------------------
-- CLASSES
---------------------------------------------

---Default icon types implemented for GetIcons()
---@alias Feature_IconPicker_IconType "Armor"|"Weapon"|"Jewelry"

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when an icon is picked.
---@class Feature_IconPicker_Event_IconPicked
---@field RequestID string
---@field Icon icon

---@class Feature_IconPicker_Hook_IsTemplateValid
---@field Template ItemTemplate
---@field RequestedIconType Feature_IconPicker_IconType
---@field IsValid boolean Hookable. Defaults to `false`.

---------------------------------------------
-- SETTINGS
---------------------------------------------

Picker:RegisterSetting("IconType", {
    Type = "Choice",
    Name = Picker.TranslatedStrings.Setting_IconType_Name,
    DefaultValue = "Armor",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Armor", NameHandle = CommonStrings.Armor.Handle},
        {ID = "Weapon", NameHandle = CommonStrings.Weapon.Handle},
        {ID = "Jewelry", NameHandle = CommonStrings.Jewelry.Handle},
    },
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the picker.
---@see Feature_IconPicker.SetDefaultUI
---@param requestID string
---@param ui GenericUI_Instance? Defaults to the default UI.
function Picker.Open(requestID, ui)
    Picker._CurrentRequest = requestID
    ui = ui or Picker._UI

    if ui then
        Picker:DebugLog("Opening picker UI")
        ui:Show()
    else
        Picker:Error("Open", "No picker UI has been set")
    end
end

---Sets the default UI used.
---@param ui GenericUI_Instance
function Picker.SetDefaultUI(ui)
    Picker._UI = ui
end

---Returns the icon choices based on an icon type.
---Icons are gathered from Root Templates.
---@see Feature_IconPicker_Hook_IsTemplateValid
---@param iconType Feature_IconPicker_IconType
---@return DataStructures_Set<icon>
function Picker.GetIcons(iconType)
    ---@diagnostic disable-next-line: undefined-field
    local templates = Ext.Template.GetAllRootTemplates() ---@type EoCGameObjectTemplate[]
    local icons = Set.Create()

    for _,template in pairs(templates) do
        if GetExtType(template) == "ItemTemplate" then
            ---@cast template ItemTemplate
            local hook = Picker.Hooks.IsTemplateValid:Throw({
                Template = template,
                RequestedIconType = iconType,
                IsValid = false
            })

            if hook.IsValid then
                icons:Add(template.Icon)
            end
        end
    end

    return icons
end

---Chooses an icon for the current request.
---Intended to be called by the UI handling the request.
---@param icon icon
function Picker.PickIcon(icon)
    if not Picker._CurrentRequest then
        Picker:Error("PickIcon", "Called when no request is active")
    end

    Picker.Events.IconPicked:Throw({
        RequestID = Picker._CurrentRequest,
        Icon = icon,
    })

    -- End the request
    Picker._CurrentRequest = nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Armor and weapons icon type filters.
-- There really isn't a fool-proof way of filtering some of them,
-- we rely on Larian being generally pretty consistent at their naming.
Picker.Hooks.IsTemplateValid:Subscribe(function (ev)
    local icon = ev.Template.Icon

    if ev.RequestedIconType == "Armor" then
        icon = string.lower(icon) -- GB5 armors use lowercase

        if (icon:match("_arm_.*") or icon:match("_armor_.*") or icon:match("^arm_.*")) and not icon:match("bodypart") then
            ev.IsValid = true
        end
    elseif ev.RequestedIconType == "Weapon" then
        if icon:match("WPN") then
            ev.IsValid = true
        end
    elseif ev.RequestedIconType == "Jewelry" then
        if icon:match("Ring_") or icon:match("Amulet") then
            ev.IsValid = true
        end
    end
end)