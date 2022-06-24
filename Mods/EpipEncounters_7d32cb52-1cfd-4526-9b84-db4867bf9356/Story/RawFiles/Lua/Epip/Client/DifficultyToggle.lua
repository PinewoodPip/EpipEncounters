
---------------------------------------------
-- Enables switching between Tactician and other difficulties
-- in the options menu.
---------------------------------------------

local Options = Client.UI.OptionsSettings

Options:RegisterListener("TabRendered", function(tab)
    if tab == Options.TABS.GAMEPLAY then
        local element = Options.GetOptionElement(12)
        local index = element.combo_mc.m_selIndex
        local entries = {
            "Story Mode",
            "Explorer Mode",
            "Classic Mode",
            "Tactician Mode",
        }

        Options.SetElementEnabled(12, true, "Dropdown")
        Options:GetRoot().mainMenu_mc.clearMenuDropDownEntries(12)

        for i,entry in ipairs(entries) do
            Options.RenderDropdownEntry(12, entry)
        end

        Options.SetElementState(12, index + 1, "Dropdown")
    end
end)