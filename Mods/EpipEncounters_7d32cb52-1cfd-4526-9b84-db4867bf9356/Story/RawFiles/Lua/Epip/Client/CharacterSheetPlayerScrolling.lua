
---------------------------------------------
-- Increases the mouse wheel scroll sensitivity when scrolling player portraits in Character Sheet
-- while the party has >4 members.
---------------------------------------------

local CharacterSheet = Client.UI.CharacterSheet
local Input = Client.Input

---@type Feature
local PlayerScrolling = {
    SENSITIVITY = 65, -- Amount to scroll for each scroll wheel tick.
}
Epip.RegisterFeature("Features.CharacterSheetPlayerScrolling", PlayerScrolling)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add extra scrolling to the player portraits list
-- when mouse wheel is used while hovering over it.
-- The scroll amount is hardcoded in the UI (no constant),
-- so we must add our own additional scroll amount.
Input.Events.KeyPressed:Subscribe(function (ev)
    local inputID = ev.InputID
    local mouseWheelDelta = (inputID == "wheel_ypos" and -1) or (inputID == "wheel_yneg" and 1) or nil
    if mouseWheelDelta then
        local root = CharacterSheet:GetRoot()
        local charHolder = root.stats_mc.charList

        -- Only scroll while the mouse is over the portraits.
        if charHolder.mouseX > 0 and charHolder.mouseY > 0 and charHolder.mouseX < charHolder.width and charHolder.mouseY < charHolder.height then
            local scrollbar = charHolder.m_scrollbar_mc
            scrollbar.adjustScrollHandle(mouseWheelDelta * PlayerScrolling.SENSITIVITY)
        end
    end
end)
