
---------------------------------------------
-- Implements an image editor UI.
---------------------------------------------

---@class Features.Assprite : Feature
local Assprite = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    CURSOR_MOVEMENT_INTERPOLATION_INTERVAL = 0.1, -- Interval to use when interpolating cursor movement. Ex. 0.2 corresponds to trying 5 new positions using 20% "steps" between the old and new position.
    MAX_HISTORY_SNAPSHOTS = 10, -- Maximum image snapshots stored for undo/redo operations.

    _Context = nil, ---@type Features.Assprite.Context

    TranslatedStrings = {
        Assprite = {
            Handle = "he8713dd0g2846g4580g9a44g2f83bd7e6c72",
            Text = "Assprite",
            ContextDescription = [[Feature name; portmanteau of "Ass" and "Aseprite" (a propietary image editing software)]],
        },
        Label_Undo = {
            Handle = "hf41b62a3g4357g4641g836bg0ad425b11c0c",
            Text = "Undo",
            ContextDescription = [[As in, "undo action"]],
        },
        Label_Redo = {
            Handle = "h8317485ag3f62g424dg9171ge5cc69910d77",
            Text = "Redo",
            ContextDescription = [[As in, "re-do action"]],
        },
        Label_File = {
            Handle = "hf1d05cfdg2d04g4637g9dc7g0d68ff88c0dc",
            Text = "File",
            ContextDescription = [[As in, "computer file"]],
        },
        Notification_Save_Success = {
            Handle = "ha8aad9a3ged5cg414dgb649g3b3e18384224",
            Text = "Image saved",
            ContextDescription = [[Notification from save option]],
        },
        Notification_Load_Success = {
            Handle = "h77a50a9dg1123g4fe6ga3fbge3ad69e11c68",
            Text = "Image loaded",
            ContextDescription = [[Notification from load option]],
        },
        Notification_Load_Error = {
            Handle = "hf53ae24bg6559g4552g9149g531488fb0b38",
            Text = "Failed to load image<br>%s",
            ContextDescription = [[Notification from load option. Param is failure reason]],
        },
        Notification_Load_Error_FileDoesntExist = {
            Handle = "hfd190c24g601fg442egacfcg0f5791421973",
            Text = [[File "%s.png" or "%s.dds" doesn't exist.]],
            ContextDescription = [[Notification when loading an image with a non-existent path. Params are file path.]],
        },
        MsgBox_Save_Body = {
            Handle = "h0dee3b84gdb20g4caegbcabga1530c734a20",
            Text = "Enter a path (excluding extension) to save image as DDS, relative to the Osiris Data folder.",
            ContextDescription = [[Message box for save option]],
        },
        MsgBox_Load_Body = {
            Handle = "h37a87c28g91efg42f6g9b13g632167e743c7",
            Text = "Enter a path to load a .PNG or .DDS from (excluding extension), relative to the Osiris Data folder.",
            ContextDescription = [[Message box for load option]],
        },
        MsgBox_Exit_Header = {
            Handle = "hdf193d0fga963g41c6gb531g0df00750848d",
            Text = "Exit Assprite",
            ContextDescription = [[Header for exit message box]],
        },
        MsgBox_Exit_Body = {
            Handle = "h5a24063fga5ebg4ae9gb1c9gc1c197dd3f37",
            Text = "Are you sure you want to exit? Your current image will be discarded.",
            ContextDescription = [[Message box for exit option]],
        },
        MsgBox_About_Body = {
            Handle = "h890ba9d3g02bcg4a69gbc1agfbfaacd0d940",
            Text = "A spriting editor by %s<br>Spring 2025 (for Epip's 4th anniversary)",
            ContextDescription = [["About" message box. Param is creator credit ("Team Pinewood")]],
            FormatOptions = {
                FormatArgs = {
                    Text.CommonStrings.TeamPinewood:Format({
                        Color = Color.LARIAN.GREEN, -- The actual Team Pinewood green was too dark against the message box prompt to use here.
                    })
                }
            }
        },
        InputAction_Undo_Description = {
            Handle = "hc9381a40g9557g4bd0g8e2ag2bfe75c44b66",
            Text = "Undoes the last edit made to the canvas.",
            ContextDescription = [[Tooltip for "Undo" keybind]],
        },
        InputAction_Redo_Description = {
            Handle = "h95fc0085g786cg40a2g959eg2ec7556248be",
            Text = "Redoes the last undo done to the canvas.",
            ContextDescription = [[Tooltip for "Redo" keybind]],
        },
        Label_SelectTool = {
            Handle = "h4de997b3gdc73g4e53g9660g63b24a7a2867",
            Text = "Select %s tool",
            ContextDescription = [[Generic keybind name; param is tool name]],
        },
    },

    Events = {
        EditorRequested = {}, ---@type Event<Features.Assprite.Events.EditorRequested>
        RequestCompleted = {}, ---@type Event<Features.Assprite.Events.RequestCompleted>
        CursorPositionChanged = {}, ---@type Event<Features.Assprite.ContextEvent>
        ToolUseStarted = {}, ---@type Event<Features.Assprite.ContextEvent>
        ToolUseEnded = {}, ---@type Event<Features.Assprite.ContextEvent> Context will still contain the old tool.
        ColorChanged = {}, ---@type Event<Features.Assprite.ContextEvent>
        ImageChanged = {}, ---@type Event<Features.Assprite.ContextEvent>
    },
    Hooks = {
        IsImageValid = {}, ---@type Hook<Features.Assprite.Hooks.IsImageValid>
    },
}
Epip.RegisterFeature("Features.Assprite", Assprite)
local TSK = Assprite.TranslatedStrings
local InputActions = {
    Undo = Assprite:RegisterInputAction("Undo", {
        Name = TSK.Label_Undo,
        Description = TSK.InputAction_Undo_Description,
        DefaultInput1 = {Keys = {"lctrl", "z"}},
    }),
    Redo = Assprite:RegisterInputAction("Redo", {
        Name = TSK.Label_Redo,
        Description = TSK.InputAction_Redo_Description,
        DefaultInput1 = {Keys = {"lctrl", "y"}},
    }),
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Assprite.Context
---@field RequestID string
---@field Image ImageLib_Image
---@field History ImageLib_Image[] Previous iterations of the image, from oldest to newest.
---@field HistoryUndoStackIndex integer Current amount of undo-s done since the last push to the History stack.
---@field LatestImage ImageLib_Image[] Latest image right before beginning to traverse the history stack through an undo.
---@field CursorPos Vector2? Pixel coordinates of the cursor (row and column).
---@field Color RGBColor Selected color.
---@field Tool Features.Assprite.Tool? The tool currently being used.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.Assprite.ContextEvent
---@field Context Features.Assprite.Context

---@class Features.Assprite.Events.EditorRequested
---@field RequestID string
---@field ConfirmLabel TextLib.String?
---@field Image ImageLib_Image

---@class Features.Assprite.Events.RequestCompleted
---@field RequestID string
---@field Image ImageLib_Image? `nil` if the request was cancelled.

---@class Features.Assprite.Hooks.IsImageValid
---@field Image ImageLib_Image
---@field InvalidReason TextLib.String? Hookable. If set, the image is considered invalid. Defaults to `nil`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests the editor to be opened for an image.
---@see Features.Assprite.Events.EditorRequested
---@param requestID string
---@param image ImageLib_Image
---@param purpose TextLib.String? Label used to confirm submission from the UI, ex. "Apply image".
function Assprite.RequestEditor(requestID, image, purpose)
    Assprite._Context = {
        RequestID = requestID,
        Image = image,
        History = {},
        HistoryUndoStackIndex = 0,
        LatestImage = image,
        CursorPos = nil,
        Color = Color.CreateFromHex(Color.WHITE),
        Tool = nil,
    }
    Assprite.Events.EditorRequested:Throw({
        RequestID = requestID,
        Image = image,
        ConfirmLabel = purpose,
    })
end

---Completes the current editing request.
---@see Features.Assprite.Events.RequestCompleted
function Assprite.CompleteRequest()
    if not Assprite.IsEditing() then
        Assprite:__Error("CompleteRequest", "Not currently editing")
    end
    local context = Assprite._Context
    Assprite.Events.RequestCompleted:Throw({
        RequestID = context.RequestID,
        Image = context.Image,
    })
    Assprite._Context = nil
end

---Cancels the current editing request.
function Assprite.CancelRequest()
    local context = Assprite._Context
    context.Image = nil
    Assprite.CompleteRequest()
end

---Requests to start using a tool.
---Will automatically end the previous tool being used, if any.
---@param tool Features.Assprite.Tool
function Assprite.BeginToolUse(tool)
    local context = Assprite._Context
    if not context then
        Assprite:__Error("BeginToolUse", "No active context")
    end
    if context.Tool then
        Assprite.EndToolUse()
    end

    -- Save snapshot before tool uses
    Assprite.SaveSnapshot()

    context.Tool = tool
    local changed = tool:OnUseStarted(context)
    Assprite.Events.ToolUseStarted:Throw({
        Context = context,
    })
    if changed then
        Assprite.Events.ImageChanged:Throw({
            Context = context,
        })
    end
end

---Sets the cursor position.
---@param pos vec2? `nil` to deselect.
function Assprite.SetCursor(pos)
    local context = Assprite._Context
    if not context then
        Assprite:__Error("BeginToolUse", "No active context")
    end
    local oldPos = context.CursorPos
    local imageChanged = false
    if ((oldPos == nil) ~= (pos == nil)) or oldPos[1] ~= pos[1] or oldPos[2] ~= pos[2] then -- Do nothing if the position hasn't changed.
        -- "Interpolate" movement by throwing events for intermediate pixels if the movement was more than one pixel
        if oldPos then
            local posDelta = pos - oldPos
            local prevPos = oldPos
            if posDelta.Length > 1.5 then -- Do not interpolate 1-pixel diagonal movement (sqrt(2) distance).
                local INTERVAL = Assprite.CURSOR_MOVEMENT_INTERPOLATION_INTERVAL
                for i=INTERVAL,1,INTERVAL do
                    local interpolatedPos = oldPos + (posDelta * i)
                    interpolatedPos = Vector.Round(interpolatedPos)
                    if interpolatedPos ~= prevPos then
                        imageChanged = Assprite._SetCursor(interpolatedPos) or imageChanged
                        prevPos = interpolatedPos
                    end
                end
            end
        end
        imageChanged = Assprite._SetCursor(pos) or imageChanged
        if imageChanged then
            Assprite.Events.ImageChanged:Throw({
                Context = context,
            })
        end
        -- Only throw event after all interpolated moves.
        Assprite.Events.CursorPositionChanged:Throw({
            Context = context,
        })
    end
end

---Replaces the image being currently edited.
---@see Features.Assprite.Hooks.IsImageValid
---@param img ImageLib_Image
---@return boolean, string? -- Success and failure reason in case of failure.
function Assprite.SetImage(img)
    local context = Assprite._Context
    local invalidReason = Assprite.Hooks.IsImageValid:Throw({
        Image = img,
        InvalidReason = nil,
    }).InvalidReason

    -- Apply image
    if not invalidReason then
        Assprite.SaveSnapshot() -- Save snapshot first to be able to undo this
        context.Image = img
        Assprite.Events.ImageChanged:Throw({
            Context = context
        })
    end

    return invalidReason == nil, invalidReason
end

---Saves a copy of the image to the History stack.
function Assprite.SaveSnapshot()
    local context = Assprite._Context
    local snapshot = context.Image:Copy()

    -- If we were undoing before, reset the top of the stack
    if context.HistoryUndoStackIndex > 0 then
        for _=1,context.HistoryUndoStackIndex,1 do
            context.History[#context.History] = nil
        end
        context.HistoryUndoStackIndex = 0
        context.LatestImage = snapshot
    end

    table.insert(context.History, snapshot)

    -- Remove oldest entry once the limit is reached.
    if context.History[Assprite.MAX_HISTORY_SNAPSHOTS + 1] then
        table.remove(context.History, 1)
    end
end

---Reverts the image to the previous snapshot, if any.
function Assprite.Undo()
    local context = Assprite._Context
    local snapshot = context.History[#context.History - context.HistoryUndoStackIndex]
    if snapshot then
        -- If we're undoing from the top of the stack, save a copy of the image before undo
        if context.HistoryUndoStackIndex == 0 then
            context.LatestImage = context.Image:Copy()
        end
        context.Image = snapshot
        context.HistoryUndoStackIndex = context.HistoryUndoStackIndex + 1
        Assprite.Events.ImageChanged:Throw({
            Context = context
        })
    end
end

---Redoes the last undone action.
function Assprite.Redo()
    local context = Assprite._Context
    local snapshot = context.HistoryUndoStackIndex == 1 and context.LatestImage or context.History[#context.History - context.HistoryUndoStackIndex + 2]
    if snapshot then
        context.Image = snapshot
        context.HistoryUndoStackIndex = context.HistoryUndoStackIndex - 1
        Assprite.Events.ImageChanged:Throw({
            Context = context
        })
    end
end

---Returns whether the history stack is not empty.
---@return boolean
function Assprite.CanUndo()
    local context = Assprite._Context
    return context and context.History[#context.History - context.HistoryUndoStackIndex] ~= nil
end

---Returns whether the history stack is being traversed.
---@return boolean
function Assprite.CanRedo()
    local context = Assprite._Context
    return context and context.HistoryUndoStackIndex > 0
end

---Sets the cursor position and runs OnCursorChanged for the current tool without interpolation.
---**Does not throw CursorPositionChanged.**
---@param newPos Vector2
---@return boolean -- Whether the image has been altered by any tool as a result.
function Assprite._SetCursor(newPos)
    local context = Assprite._Context
    local imageChanged = false
    context.CursorPos = newPos

    -- Run tool
    if context.Tool then
        imageChanged = context.Tool:OnCursorChanged(context)
    end

    return imageChanged
end

---Sets the selected color.
---@param color RGBColor
function Assprite.SetColor(color)
    local context = Assprite._Context
    if not context then
        Assprite:__Error("BeginToolUse", "No active context")
    end
    context.Color = color
    Assprite.Events.ColorChanged:Throw({
        Context = context,
    })
end

---Returns the current context.
---@return Features.Assprite.Context?
function Assprite.GetContext()
    return Assprite._Context
end

---Returns the tool currently being used, if any.
---@return Features.Assprite.Tool? -- `nil` if no tool is being used or no image is being edited.
function Assprite.GetActiveTool()
    local context = Assprite._Context
    return context and context.Tool or nil
end

---Requests to stop using the current tool.
function Assprite.EndToolUse()
    local context = Assprite._Context
    if not context or not context.Tool then
        Assprite:__Error("EndToolUse", "No active context or tool in use")
    end
    local changed = context.Tool:OnUseEnded(context)
    Assprite.Events.ToolUseEnded:Throw({
        Context = context,
    })
    if changed then
        Assprite.Events.ImageChanged:Throw({
            Context = context,
        })
    end
    context.Tool = nil
end

---Returns the image being edited.
---@return ImageLib_Image? -- `nil` if no image is being edited.
function Assprite.GetImage()
    local context = Assprite._Context
    return context and context.Image or nil
end

---Returns whether an image is currently being edited.
---@return boolean
function Assprite.IsEditing()
    return Assprite._Context ~= nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply keybind effects.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    local action = ev.Action
    if action == InputActions.Undo then
        Assprite.Undo()
    elseif action == InputActions.Redo then
        Assprite.Redo()
    end
end, {EnabledFunctor = function ()
    return Assprite.IsEditing()
end})
