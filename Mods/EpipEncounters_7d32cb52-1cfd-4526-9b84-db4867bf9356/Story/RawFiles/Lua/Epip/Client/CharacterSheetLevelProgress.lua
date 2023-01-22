
---------------------------------------------
-- Displays XP progress towards the next level as a percentage
-- in the character sheet.
---------------------------------------------

local CharacterSheet = Client.UI.CharacterSheet

---@type Feature
local LevelProgress = {
    DECIMALS = 1, -- Decimals to show for the percentage.
}
Epip.RegisterFeature("CharacterSheetLevelProgress", LevelProgress)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

CharacterSheet.Hooks.UpdateSecondaryStats:Subscribe(function (ev)
    local char = ev.Character
    local level = Character.GetLevel(char)
    local currentExperience = Character.GetExperience(char)
    local currentLevelReq = Character.GetExperienceRequiredForLevel(level)
    local nextLevelReq = Character.GetExperienceRequiredForLevel(level + 1)
    local progress = (currentExperience - currentLevelReq) / (nextLevelReq - currentLevelReq) * 100

    -- Do not show progress once the level cap is reached.
    if level < Stats.Get("Data", "LevelCap") then
        for _,stat in ipairs(ev.Stats) do
            stat = stat ---@type SecondaryStat
    
            if stat.StatID == 37 then
                stat.ValueLabel = Text.Format("%s (%s%%)", {
                    FormatArgs = {
                        stat.ValueLabel,
                        Text.Round(progress, LevelProgress.DECIMALS),
                    }
                })
            end
        end
    end
end)