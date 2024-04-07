
local Vanity = Client.UI.Vanity
local IconPicker = Epip.GetFeature("Feature_IconPicker")

---@class Feature_Vanity_Transmog
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")
Transmog.ICON_PICKER_REQUEST_ID = "Vanity_Transmog_SetIcon"

Transmog.TranslatedStrings.Transmog_SetIcon = Transmog:RegisterTranslatedString("h19773400g8de1g46d7g9901g779b750ebddd", {
   Text = "Set Icon",
   ContextDescription = "Override icon button",
})

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    Name = "Transmog",
    ID = "PIP_Vanity_Transmog",
    Icon = "hotbar_icon_magic",
})
Transmog.Tab = Tab

---------------------------------------------
-- TAB FUNCTIONALITY
---------------------------------------------

function Tab:Render()
    -- Only clear template override if the item changed
    -- TODO revise
    -- if item ~= Vanity.currentItem then
    --     Vanity.currentItemTemplateOverride = nil
    -- end
    local item = Vanity.GetCurrentItem()

    Vanity.RenderItemDropdown()

    -- Don't show the visibility option for helms,
    -- as they already have one in the vanilla UI.
    if Item.GetItemSlot(item) ~= "Helmet" then
        Vanity.RenderCheckbox("Vanity_MakeInvisible", Text.Format("Visible", {Color = Color.BLACK}), not item:HasTag(Transmog.INVISIBLE_TAG), true)
    end

    if item then
        local canTransmog = Transmog.CanTransmogItem(item)

        -- Can toggle weapon overlay effects regardless of whether the item can be transmogged.
        if Item.IsWeapon(item) then
            Vanity.RenderCheckbox("Vanity_OverlayEffects", Text.Format("Elemental Effects", {Color = Color.BLACK}), not item:HasTag("DISABLE_WEAPON_EFFECTS"), true)
        end

        if canTransmog then
            Vanity.RenderCheckbox("Vanity_KeepIcon", Text.Format("Keep Icon", {Color = Color.BLACK}), Transmog.keepIcon, true)
            Vanity.RenderButton("Transmog_SetIcon", Text.Format(Transmog.TranslatedStrings.Transmog_SetIcon:GetString(), {Color = Color.WHITE}), true)

            local categories = Transmog.GetCategories(item)

            -- TODO fix disabled button item:HasTag("PIP_Vanity_Transmogged")
            -- if item:HasTag("PIP_Vanity_Transmogged") or (Vanity.currentItemTemplateOverride and item.RootTemplate.Id ~= Vanity.currentItemTemplateOverride) then
            -- end

            Vanity.RenderCheckbox("Vanity_KeepAppearance", Text.Format("Lock Appearance", {Color = "000000"}), Transmog.ShouldKeepAppearance(item), true)

            Vanity.RenderButton("RevertTemplate", "Revert Appearance", true)

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
            Vanity.RenderText("InvalidItem", "This item is too brittle to transmog.")
        end
    else
        Vanity.RenderText("NoItem", "You don't have an item equipped in that slot!")
    end
end

Tab:RegisterListener(Vanity.Events.EntryFavoriteToggled, function(id, active)
    if active then
        Transmog.favoritedTemplates[id] = active
    else
        Transmog.favoritedTemplates[id] = nil
    end

    Vanity.Refresh()
end)

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RevertTemplate" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_RevertTemplate", {
            CharNetID = Client.GetCharacter().NetID,
            ItemNetID = Vanity.GetCurrentItem().NetID,
        })
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