
---------------------------------------------
-- Enables switching between Tactician and other difficulties
-- in the options menu.
---------------------------------------------

local Options = Client.UI.OptionsSettings

local DifficultyToggle = {
    DIFFICULTY_TSKHANDLES = {
        STORY = "hc7f35cc5gc74eg4624g824fg427c58cc29f2", -- "Story mode"
        EXPLORER = "hc77a3c38g67beg46e3g99aag625bd2b93a6d", -- "Explorer mode"
        CLASSIC = "h2481fd99g022dg4150gb33bg4bfb108ec624", -- "Classic mode"
        TACTICIAN = "h2405233ega34fg4443gbc8bg69a29b9e7919", -- "Tactician mode"
        HONOUR = "h3bc72102g9b47g435fgaec8ga45b31d79bc5", -- "Honour mode"; not selectable due to unknown side-effects.
    }
}
Epip.RegisterFeature("Features.DifficultyToggle", DifficultyToggle)

Options.Events.TabRendered:RegisterListener(function (_, index)
    local isHonour = Ext.Utils.GetDifficulty() == 4

    -- Only edit the dropdown if we're not in Honour Mode.
    if index == Options.TABS.GAMEPLAY and not isHonour then
        local element = Options.GetOptionElement(12)
        local currentIndex = element.combo_mc.m_selIndex
        ---@type TranslatedStringHandle[]
        local entries = {
            DifficultyToggle.DIFFICULTY_TSKHANDLES.STORY,
            DifficultyToggle.DIFFICULTY_TSKHANDLES.EXPLORER,
            DifficultyToggle.DIFFICULTY_TSKHANDLES.CLASSIC,
            DifficultyToggle.DIFFICULTY_TSKHANDLES.TACTICIAN,
        }

        -- Enable the dropdown and re-render the dropdown entries
        Options.SetElementEnabled(12, true, "Dropdown")
        Options:GetRoot().mainMenu_mc.clearMenuDropDownEntries(12)

        for _,entry in ipairs(entries) do
            local label = Text.GetTranslatedString(entry)
            Options.RenderDropdownEntry(12, label)
        end

        Options.SetElementState(12, currentIndex + 1, "Dropdown")
    end
end)