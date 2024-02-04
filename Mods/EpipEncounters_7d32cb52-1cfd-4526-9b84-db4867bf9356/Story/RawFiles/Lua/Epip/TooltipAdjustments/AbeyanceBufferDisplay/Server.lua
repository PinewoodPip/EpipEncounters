
---@class Features.TooltipAdjustments.AbeyanceBufferDisplay
local BufferDisplay = Epip.GetFeature("Features.TooltipAdjustments.AbeyanceBufferDisplay")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the UserVar when the damage buffer changes.
Osiris.RegisterSymbolListener("PROC_AMER_KeywordStat_Abeyance_Buffer_Update", 2, "after", function (charGUID, totalDamage)
    local char = Character.Get(charGUID)
    BufferDisplay:SetUserVariable(char, BufferDisplay.USERVAR_BUFFERED_DAMAGE, totalDamage)
end)

-- Clear the UserVar when buffered damage is applied.
Osiris.RegisterSymbolListener("PROC_AMER_KeywordStat_Abeyance_EndEffect", 2, "after", function (charGUID, _)
    local char = Character.Get(charGUID)
    BufferDisplay:SetUserVariable(char, BufferDisplay.USERVAR_BUFFERED_DAMAGE, nil)
end)
