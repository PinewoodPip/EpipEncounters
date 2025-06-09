
---------------------------------------------
-- Implements customizable detached groups of additional hotbar-like slots.
---------------------------------------------

---@class Features.HotbarGroups : Feature
local GroupManager = {
    SAVE_FILENAME = "EpipEncounters_HotbarGroups.json",
    SAVE_VERSION = 2,

    TranslatedStrings = {
        CreateGroupHeader = {
            Handle = "h4179a16bg43a5g40bcg88ccg7870114fb6c0",
            Text = "Create Hotbar Group",
            ContextDescription = "Hotbar group creation menu header",
        },
        CreateGroupButton = {
            Handle = "h874faf80g6c2eg4fe8gb908g60bb769b02eb",
            Text = "Create",
            ContextDescription = "Hotbar group creation menu confirm button text",
        },
        ResizeGroupHeader = {
            Handle = "h36e32b84g5373g4711g920cg8d0cedd5fcff",
            Text = "Resize Hotbar Group",
            ContextDescription = "Hotbar group resize menu header",
        },
        ResizeGroupButton = {
            Handle = "hf0192252g5d7ag429eg96a6g21be87bd88cd",
            Text = "Resize",
            ContextDescription = "Hotbar group resize menu confirm button text",
        },
        RowsSpinner = {
            Handle = "h36ba40b2ge76bg4ea9g90ecgde3d4fc01945",
            Text = "Rows",
            ContextDescription = "Hotbar group create/resize menu rows spinner label",
        },
        ColumnsSpinner = {
            Handle = "hb4ca31ecge2ecg44faga2dbg1e1c98c49d30",
            Text = "Columns",
            ContextDescription = "Hotbar group create/resize menu columns spinner label",
        },
        HotbarGroup_DragHandle_Tooltip = {
            Handle = "h3edeba4cg45a9g46f9g8c02g85e9ff956909",
            Text = "Click and hold to drag.",
            ContextDescription = "Tooltip for hotbar group drag area",
        },
        Label_LockPosition = {
            Handle = "h41e08555gac00g4954g91edg9b89f595ca30",
            Text = "Lock position",
            ContextDescription = [[Option in group context menu]],
        },
        Label_SnapToHotbar = {
            Handle = "h37258013g671cg4548g89ebgcd7c144ce710",
            Text = "Snap to Hotbar",
            ContextDescription = [[Option in group context menu]],
        },
    },
}
Epip.RegisterFeature("Features.HotbarGroups", GroupManager)
