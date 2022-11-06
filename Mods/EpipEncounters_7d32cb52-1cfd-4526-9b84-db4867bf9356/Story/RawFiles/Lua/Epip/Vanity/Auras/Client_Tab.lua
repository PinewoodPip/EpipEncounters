
local Vanity = Client.UI.Vanity

---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")
Auras.Tab = Vanity.CreateTab({
    Name = "Auras",
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

    Vanity.RenderButton("RemoveAuras", "Remove Auras", true)

    Vanity.RenderText("_BoneLabel", "Attachment Point")
    Vanity.RenderDropdown("Auras_Bone", Tab:_GetBoneDropdownOptions(), Tab.SelectedBoneIndex - 1)

    Vanity.RenderEntry("Auras", "Auras", true, open, false, false, nil, false, nil)
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