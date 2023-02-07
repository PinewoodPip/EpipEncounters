
---------------------------------------------
-- Improvements to the Examine UI.
-- Shows critical chance and capitalizes the Status Effects header.
-- Optionally, opens the menu on the right side of the screen.
---------------------------------------------

local Examine = Client.UI.Examine

---@type Feature
local ExamineImprovements = {
    POSITION_SETTING = {
        CENTER = 1,
        MIDDLE_RIGHT = 2,
        MIDDLE_LEFT = 3,
    }
}
Epip.RegisterFeature("ExamineImprovements", ExamineImprovements)

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Reposition the menu when it is opened.
Examine.Events.Opened:Subscribe(function (_)
    if ExamineImprovements:IsEnabled() then
        local ui = Examine:GetUI()
        local position = Settings.GetSettingValue("EpipEncounters", "ExaminePosition")
    
        if position == ExamineImprovements.POSITION_SETTING.MIDDLE_RIGHT then
            ui:ExternalInterfaceCall("setPosition", "right", "screen", "right")
        elseif position == ExamineImprovements.POSITION_SETTING.MIDDLE_LEFT then
            ui:ExternalInterfaceCall("setPosition", "left", "screen", "left")
        end
    end
end)

-- Add critical chance
Examine.Hooks.GetUpdateData:Subscribe(function (ev)
    if ExamineImprovements:IsEnabled() then
        local char = Examine.GetCharacter()
        local data = ev.Data
    
        -- Only do this for characters being examined
        if char then
            ---@type ExamineUI_UpdateData_Entry
            local critEntry = {
                StatID = 9,
                Label = Text.CommonStrings.CriticalChance:GetString(),
                IconID = Examine.ICONS.CRITICAL_CHANCE,
                ValueLabel = string.format("%d%%", char.Stats.CriticalChance),
                EntryType = Examine.ENTRY_TYPES.STAT,
            }
        
            -- Insert crit chance after damage
            local _, damageCategoryID, damageIndex = data:GetEntry(6)
            data:AddEntry(damageCategoryID, critEntry, damageIndex + 1)
        end
    end
end)

-- Fix "Status Effects" label not being all capitalized
Examine:RegisterInvokeListener("setStatusTitle", function (ev, unused, label)
    if ExamineImprovements:IsEnabled() then
        ev.UI:GetRoot().setStatusTitle(unused, string.upper(label))
        ev:PreventAction()
    end
end)