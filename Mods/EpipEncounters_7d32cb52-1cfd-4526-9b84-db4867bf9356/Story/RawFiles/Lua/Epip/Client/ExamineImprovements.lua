
---------------------------------------------
-- Improvements to the Examine UI.
-- Shows critical chance and capitalizes the Status Effects header.
-- Optionally, opens the menu on the right side of the screen.
-- Uses Client.UI.Examine.
---------------------------------------------

Epip.Features.ExamineImprovements = {

    POSITION_SETTING = {
        CENTER = 1,
        MIDDLE_RIGHT = 2,
        MIDDLE_LEFT = 3,
    }
}
local ExamineImprovements = Epip.Features.ExamineImprovements
local Examine = Client.UI.Examine

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Reposition the menu when it is opened.
Examine:RegisterListener("ExamineOpened", function(examineData)
    local ui = Examine:GetUI()
    local position = Settings.GetSettingValue("EpipEncounters", "ExaminePosition")

    if position == ExamineImprovements.POSITION_SETTING.MIDDLE_RIGHT then
        ui:ExternalInterfaceCall("setPosition", "right", "screen", "right")
    elseif position == ExamineImprovements.POSITION_SETTING.MIDDLE_LEFT then
        ui:ExternalInterfaceCall("setPosition", "left", "screen", "left")
    end
end)

-- Add critical chance
Examine:RegisterHook("Update", function(examineData)
    local char = Examine.GetCharacter()

    -- Only do this for characters being examined
    if char then
        local critEntry = {
            id = 9,
            label = "Critical Chance",
            iconID = Examine.ICONS.CRITICAL_CHANCE,
            value = string.format("%d%%", char.Stats.CriticalChance),
            type = Examine.ENTRY_TYPES.STAT,
        }
    
        -- Insert crit chance after damage
        local damageElement,damageIndex,damageCategory = examineData:GetElement(4, 6)
    
        examineData:InsertElement(damageCategory.id, critEntry, damageIndex + 1)
    end

    return examineData
end)

-- Fix Status Effects not being all capitalized - TODO fix
Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.examine, "setStatusTitle", function(ui, method, param1, title)
    ui:GetRoot().examine_mc.statusContainer_mc.label_txt.htmlText = "STATUS EFFECTS"
end, "After")


-- Preview all icons and stat enums
-- Examine.RegisterHook("Update", function(examineData)

    -- Icons
    -- for i=0,99,1 do
    --     local entry = {
    --         id = 99 + i,
    --         label = "Icon #" .. i,
    --         iconID = i,
    --         value = "",
    --         type = 1
    --     }

    --     examineData:InsertElement(4, entry)
    -- end

    -- Stat enums
    -- for i=0,99,1 do
    --     local entry = {
    --         id = i,
    --         label = "Stat #" .. i,
    --         iconID = i,
    --         value = "",
    --         type = 1
    --     }

    --     examineData:InsertElement(4, entry)
    -- end

    -- return examineData
-- end)