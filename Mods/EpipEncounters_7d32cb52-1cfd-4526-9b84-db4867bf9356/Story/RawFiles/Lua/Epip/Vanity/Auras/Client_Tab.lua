
local Vanity = Client.UI.Vanity

---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")
Auras.Tab = Vanity.CreateTab({
    Name = "Auras",
    ID = "PIP_Auras",
    Icon = "hotbar_icon_magic",
})
local Tab = Auras.Tab

---------------------------------------------
-- TAB RENDERING
---------------------------------------------

function Tab:Render()
    Vanity.RenderButton("RemoveAura", "Remove Auras", true)

    local open = Vanity.IsCategoryOpen("Auras")
    Vanity.RenderEntry("Auras", "Auras", true, open, false, false, nil, false, nil)

    if open then
        for id,effect in pairs(Auras.GetRegisteredAuras()) do
            Vanity.RenderEntry(id, effect.Name, false, false, false, false, nil, false, nil)
        end
    end
end

-- Listen for buttons being pressed.
Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RemoveAura" then
        Auras.RemoveCurrentAura()
    end
end)

-- Listen for entries being pressed.
Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Auras.ApplyAura(id)
end)