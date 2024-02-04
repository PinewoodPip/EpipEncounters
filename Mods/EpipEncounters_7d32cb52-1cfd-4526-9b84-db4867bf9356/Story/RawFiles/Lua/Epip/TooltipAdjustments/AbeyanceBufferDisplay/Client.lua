
local Tooltip = Client.Tooltip

---@class Features.TooltipAdjustments.AbeyanceBufferDisplay
local BufferDisplay = Epip.GetFeature("Features.TooltipAdjustments.AbeyanceBufferDisplay")
local TSK = BufferDisplay.TranslatedStrings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Append buffered damage to the Abeyance status tooltip.
Tooltip.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    if ev.Status.StatusId == BufferDisplay.ABEYANCE_STATUS then
        local damageBuffered = BufferDisplay:GetUserVariable(ev.Character, BufferDisplay.USERVAR_BUFFERED_DAMAGE)
        if not damageBuffered then
            BufferDisplay:__LogError("Displaying an abeyance status with no damage buffered in uservar?")
            return
        end

        -- StatusDescription should exist.
        local statusDescription = ev.Tooltip:GetFirstElement("StatusDescription")
        statusDescription.Label = Text.Format("%s<br>%s", {
            FormatArgs = {
                statusDescription.Label,
                TSK.Label_BufferedDamage:Format(damageBuffered),
            },
        })
    end
end, {EnabledFunctor = BufferDisplay:GetEnabledFunctor()})
