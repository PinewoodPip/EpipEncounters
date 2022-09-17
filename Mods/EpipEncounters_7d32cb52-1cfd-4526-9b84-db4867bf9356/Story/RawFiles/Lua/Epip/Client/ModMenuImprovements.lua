
---------------------------------------------
-- Fixes issues related to the mod selector in the main menu.
-- Mods are no longer automatically deselected if their version has changed.
---------------------------------------------

local Mods = Client.UI.Mods

---@type Feature
local Fixes = {
    opened = false,
}
Epip.RegisterFeature("ModMenuFixes", Fixes)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Re-enable add-ons disabled due to version updates.
-- Only do this the first time the menu is opened (in case the user goes back and wants to tweak things manually).
Mods.Events.Opened:Subscribe(function (ev)
    if not Fixes.opened then
        local mods = Mod.GetLoadOrder()
        local loadedModNames = {}

        for _,mod in ipairs(mods) do
            loadedModNames[mod.Info.Name] = true
        end

        for _,addOn in ipairs(ev.AddOnMods) do
            -- Re-enable mods and update the display
            if (loadedModNames[addOn.Label] and not addOn.Active) or addOn.Label:match("Epip Encounters") then
                Fixes:DebugLog("Re-enabling add-on " .. addOn.Label)

                Mods:ExternalInterfaceCall("checkBoxClicked", addOn.ID, true)
                Mods:GetRoot().addAlterMod(addOn.ID, addOn.Label, true, addOn.Order, addOn.Invalid)
            end
        end

        Fixes.opened = true
    end
end)