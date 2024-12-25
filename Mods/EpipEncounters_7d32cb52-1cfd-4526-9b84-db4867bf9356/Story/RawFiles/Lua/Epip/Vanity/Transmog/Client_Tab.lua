
local Vanity = Client.UI.Vanity
local VanityFeature = Epip.GetFeature("Feature_Vanity")
local IconPicker = Epip.GetFeature("Feature_IconPicker")

---@class Feature_Vanity_Transmog
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")
local TSK = Transmog.TranslatedStrings
Transmog.ICON_PICKER_REQUEST_ID = "Vanity_Transmog_SetIcon"

---------------------------------------------
-- STRINGS
---------------------------------------------

TSK.Label_ElementalEffects = Transmog:RegisterTranslatedString({
    Handle = "hc48f3629g9abag4fe7g816ag4c06d2780870",
    Text = "Elemental Effects",
    ContextDescription = [[Checkbox for weapon elemental GFX]],
})
TSK.Label_SetIcon = Transmog:RegisterTranslatedString("h19773400g8de1g46d7g9901g779b750ebddd", {
   Text = "Set Icon",
   ContextDescription = "Override icon button",
})
TSK.Label_KeepIcon = Transmog:RegisterTranslatedString({
    Handle = "h07513bd6ge8a4g4509g9c95g13e56a5eac03",
    Text = "Keep Icon",
    ContextDescription = [[Checkbox for preserving icon when transmogging]],
})
TSK.Label_KeepAppearance = Transmog:RegisterTranslatedString({
    Handle = "h98e054f2g9d91g481agb967g51a1873b4a78",
    Text = "Lock Appearance",
    ContextDescription = [[Checkbox to keep appearance when new items are equipped]],
})
TSK.Label_ForceShowHair = Transmog:RegisterTranslatedString({
    Handle = "h984069e2gd55ag4627g9031g1f19dfa0064f",
    Text = [[Force show hair]],
    ContextDescription = [[Checkbox in helmet transmog to have hair always show]],
})
TSK.Label_RevertAppearance = Transmog:RegisterTranslatedString({
    Handle = "hca179321g5478g4decga9fagc7b3bd11ca9a",
    Text = "Revert Appearance",
    ContextDescription = [[Button to remove transmog]],
})
TSK.Label_WeaponAnimationType = Transmog:RegisterTranslatedString({
    Handle = "h6a8b2c24ga258g4bf3gbb12gbab3c37c0d8e",
    Text = "Weapon Animations",
    ContextDescription = [[Dropdown to swap weapon animations]],
})
TSK.Label_InvalidItem = Transmog:RegisterTranslatedString({
    Handle = "hde9528cfg0189g45b2gbe7cg8d7bd5637012",
    Text = "This item is too brittle to transmog.",
    ContextDescription = [[Warning for items that cannot be transmogged]],
})

---------------------------------------------
-- VANITY TAB
---------------------------------------------

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    Name = TSK.VanityTabName:GetString(),
    ID = "PIP_Vanity_Transmog",
    Icon = "hotbar_icon_magic",
})
Transmog.Tab = Tab

function Tab:Render()
    -- Only clear template override if the item changed
    -- TODO revise
    -- if item ~= Vanity.currentItem then
    --     Vanity.currentItemTemplateOverride = nil
    -- end
    local item = Vanity.GetCurrentItem()

    Vanity.RenderItemDropdown()

    if item then
        local itemSlot = Item.GetItemSlot(item)

        -- Don't show the visibility option for helms,
        -- as they already have one in the vanilla UI.
        if itemSlot ~= "Helmet" then
            Vanity.RenderCheckbox("Vanity_MakeInvisible", Text.CommonStrings.Visible:Format({Color = Color.BLACK}), not item:HasTag(Transmog.INVISIBLE_TAG), true)
        end

        local canTransmog = Transmog.CanTransmogItem(item)

        -- Can toggle weapon overlay effects regardless of whether the item can be transmogged.
        if Item.IsWeapon(item) then
            Vanity.RenderCheckbox("Vanity_OverlayEffects", TSK.Label_ElementalEffects:Format({Color = Color.BLACK}), not item:HasTag("DISABLE_WEAPON_EFFECTS"), true)
            self:_RenderWeaponAnimationDropdown()
        end

        if canTransmog then
            Vanity.RenderCheckbox("Vanity_KeepIcon", TSK.Label_KeepIcon:Format({Color = Color.BLACK}), Transmog.keepIcon, true)
            Vanity.RenderButton("Transmog_SetIcon", TSK.Label_SetIcon:Format({Color = Color.WHITE}), true)

            local categories = Transmog.GetCategories(item)

            -- TODO fix disabled button item:HasTag("PIP_Vanity_Transmogged")
            -- if item:HasTag("PIP_Vanity_Transmogged") or (Vanity.currentItemTemplateOverride and item.RootTemplate.Id ~= Vanity.currentItemTemplateOverride) then
            -- end

            Vanity.RenderCheckbox("Vanity_KeepAppearance", TSK.Label_KeepAppearance:Format({Color = "000000"}), Transmog.ShouldKeepAppearance(item), true)

            Vanity.RenderButton("RevertTemplate", TSK.Label_RevertAppearance:GetString(), true)

            -- "Force show hair" option for helmets
            if itemSlot == "Helmet" then
                Vanity.RenderCheckbox("Vanity_ForceShowHair", TSK.Label_ForceShowHair:Format({Color = "000000"}), Transmog.ShouldForceShowHair(item))
            end

            for _,data in ipairs(categories) do
                -- Render category collapse button
                local categoryID = data.Data.ID
                local isOpen = Vanity.IsCategoryOpen(categoryID)
                Vanity.RenderEntry(categoryID, data.Data.Name, true, isOpen)

                if isOpen then
                    for _,templateData in ipairs(data.Templates) do
                        local icon = nil
                        local isEquipped = Vanity.IsTemplateEquipped(templateData.GUID)

                        if isEquipped then
                            icon = "hotbar_icon_charsheet"
                        end

                        Vanity.RenderEntry(templateData.GUID, templateData.Name, false, isEquipped, true, Transmog.favoritedTemplates[templateData.GUID], icon)
                    end
                end
            end
        else
            Vanity.RenderText("InvalidItem", TSK.Label_InvalidItem:GetString())
        end
    else
        Vanity.RenderText("NoItem", VanityFeature.TranslatedStrings.Label_NoItemEquipped:GetString())
    end
end

---Renders the weapon animation dropdown.
---**Does nothing if the extender fork is not installed.**
function Tab:_RenderWeaponAnimationDropdown()
    if not Transmog._SupportsWeaponAnimationOverrides() then return end -- This feature requires the fork.
    local options = {}
    local currentOverride = Transmog.GetWeaponAnimationOverride(Client.GetCharacter())
    local selectedIndex = currentOverride and Transmog._WEAPON_ANIM_TYPE_TO_OPTION_INDEX[currentOverride] + 1 or 1

    Vanity.RenderText("WeaponAnimationTypeLabel", TSK.Label_WeaponAnimationType:GetString())

    table.insert(options, Text.CommonStrings.Default:GetString())
    for _,option in ipairs(Transmog.WEAPON_ANIMATION_OVERRIDE_OPTIONS) do -- Will exclude NONE (0 in 1-based index)
        table.insert(options, option.Name:GetString())
    end

    Vanity.RenderDropdown("WeaponAnimationType", options, selectedIndex)
end

-- Request weapon animation overrides when interacting with the dropdown.
Vanity:RegisterListener("ComboElementSelected", function(id, index, _)
    if id == "WeaponAnimationType" then
        local animType ---@type CharacterLib.WeaponAnimationType
        if index == 1 then -- "Default" option; ie. no override
            animType = Character.WEAPON_ANIMATION_TYPES.NONE
        else
            animType = Transmog.WEAPON_ANIMATION_OVERRIDE_OPTIONS[index - 1].AnimType
        end
        Transmog.RequestWeaponAnimationOverride(Client.GetCharacter(), animType)
    end
end)

Tab:RegisterListener(Vanity.Events.EntryFavoriteToggled, function(id, active)
    if active then
        Transmog.favoritedTemplates[id] = active
    else
        Transmog.favoritedTemplates[id] = nil
    end

    Vanity.Refresh()
end)

-- Handle buttons being pressed.
Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RevertTemplate" then
        local char, item = Client.GetCharacter(), Vanity.GetCurrentItem()
        Transmog.RevertAppearance(char, item)
    elseif id == "Transmog_SetIcon" then
        IconPicker.Open(Transmog.ICON_PICKER_REQUEST_ID)
    end
end)

Tab:RegisterListener(Vanity.Events.CheckboxPressed, function(id, state)
    if id == "Vanity_KeepAppearance" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_Transmog_KeepAppearance", {
            NetID = Client.GetCharacter().NetID,
            Slot = Vanity.currentSlot,
            State = state,
        })

        Transmog.UpdateActiveCharacterTemplates()
    elseif id == "Vanity_KeepIcon" then
        Transmog.keepIcon = state
    elseif id == "Vanity_MakeInvisible" then
        Transmog.ToggleVisibility()
    elseif id == "Vanity_OverlayEffects" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_Transmog_ToggleWeaponOverlayEffects", {
            ItemNetID = Vanity.GetCurrentItem().NetID,
        })

        Timer.Start(0.4, function()
            Vanity.RefreshAppearance(true)
        end)
    elseif id == "Vanity_ForceShowHair" then -- Sent request to toggle forcing hair to be shown for helmets.
        Net.PostToServer(Transmog.NETMSG_SET_FORCE_SHOW_HAIR, {
            ItemNetID = Vanity.GetCurrentItem().NetID,
            ShowHair = state,
        })
        Timer.Start(0.4, function()
            Vanity.RefreshAppearance(true)
        end)
    end
end)

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Transmog.TransmogItem(nil, id)
end)

-- Listen for icon picker requests completing.
IconPicker.Events.IconPicked:Subscribe(function (ev)
    if ev.RequestID == Transmog.ICON_PICKER_REQUEST_ID then
        Transmog:DebugLog("Setting icon", ev.Icon)
        Transmog.SetItemIcon(Vanity.GetCurrentItem(), ev.Icon)
    end
end)