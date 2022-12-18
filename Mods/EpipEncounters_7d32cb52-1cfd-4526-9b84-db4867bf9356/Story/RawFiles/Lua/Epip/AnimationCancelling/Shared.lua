
---@class Feature_AnimationCancelling : Feature
local AnimCancel = {
    NET_MESSAGE = "Epip_Feature_AnimationCancelling",

    Settings = {
        Enabled = {
            Type = "Boolean",
            Name = "Animation Cancelling",
            Description = "Cancels your controlled character's spell animations after their effects execute.",
            DefaultValue = false,
            Context = "Client",
        },
    },
}
Epip.RegisterFeature("AnimationCancelling", AnimCancel)