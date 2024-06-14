
local Vanity = Client.UI.Vanity

---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")
local TSK = {
    VanityTab = Auras:RegisterTranslatedString({
        Handle = "hba14c3f1g1d8fg4ddeg935bg2a8189f90d32",
        Text = "Auras",
        ContextDescription = [[Vanity tab name]],
    }),
    Label_RemoveAuras = Auras:RegisterTranslatedString({
        Handle = "h1bbafd1cg0289g47cbga8cdg93e45e2edbdc",
        Text = "Remove Auras",
        ContextDescription = [[Button label]],
    }),
    Label_AttachmentPoint = Auras:RegisterTranslatedString({
        Handle = "h1050422bg60f7g4cfag8a89ge22ef3bcf7c6",
        Text = "Attachment Point",
        ContextDescription = [[Dropdown label for where effects should be placed on the character (arms, legs, head, etc.)]],
    }),
}

Auras.Tab = Vanity.CreateTab({
    Name = TSK.VanityTab:GetString(),
    ID = "PIP_Auras",
    Icon = "hotbar_icon_magic",
})
local Tab = Auras.Tab
Tab.REFRESH_DELAY = 0.2
Tab.SelectedBoneIndex = 1

---------------------------------------------
-- TAB RENDERING
---------------------------------------------

---@return string[]
function Tab:_GetBoneDropdownOptions()
    local options = {}

    for i,data in ipairs(Auras.BONES) do
        options[i] = data.Name
    end

    return options
end

function Tab:Render()
    local open = Vanity.IsCategoryOpen("Auras")
    local char = Client.GetCharacter()

    Vanity.RenderButton("RemoveAuras", TSK.Label_RemoveAuras:GetString(), true)

    Vanity.RenderText("_BoneLabel", TSK.Label_AttachmentPoint:GetString())
    Vanity.RenderDropdown("Auras_Bone", Tab:_GetBoneDropdownOptions(), Tab.SelectedBoneIndex)

    Vanity.RenderEntry("Auras", TSK.VanityTab:GetString(), true, open, false, false, nil, false, nil)
    if open then
        for id,effect in pairs(Auras.GetRegisteredAuras()) do
            local icon = Auras.HasAura(char, id) and "hotbar_icon_charsheet" or nil

            Vanity.RenderEntry(id, effect:GetName(), false, false, false, false, icon, false, nil)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Vanity:RegisterListener("ComboElementSelected", function(id, index, _)
    if id == "Auras_Bone" then
        Tab.SelectedBoneIndex = index
    end
end)

-- Listen for buttons being pressed.
Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RemoveAuras" then
        Auras.RemoveAuras()
    end

    Timer.Start(Tab.REFRESH_DELAY, function (_)
        Vanity.Refresh()
    end)
end)

-- Listen for entries being pressed.
Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Auras.ToggleAura(Client.GetCharacter(), id, Auras.BONES[Tab.SelectedBoneIndex].BoneID)

    Timer.Start(Tab.REFRESH_DELAY, function (_)
        Vanity.Refresh()
    end)
end)