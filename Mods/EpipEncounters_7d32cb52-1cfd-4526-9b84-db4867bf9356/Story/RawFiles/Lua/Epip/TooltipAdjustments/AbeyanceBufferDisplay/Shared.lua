
---@class Features.TooltipAdjustments.AbeyanceBufferDisplay : Feature
local BufferDisplay = {
    USERVAR_BUFFERED_DAMAGE = "BufferedDamage",
    ABEYANCE_STATUS = "AMER_ABEYANCE",

    TranslatedStrings = {
        Label_BufferedDamage = {
            Handle = "h1c4d0e87g8710g4fb1gb98ag97d35a24bb5b",
            Text = "Abeying %d damage.",
            ContextDescription = [[Tooltip for EE Abeyance status; param is damage abeyed/buffered]],
        },
    },
}
Epip.RegisterFeature("Features.TooltipAdjustments.AbeyanceBufferDisplay", BufferDisplay)

BufferDisplay:RegisterUserVariable(BufferDisplay.USERVAR_BUFFERED_DAMAGE, {
    Persistent = true,
    Client = true,
    Server = true,
    SyncToClient = true,
    WriteableOnServer = true,
})
