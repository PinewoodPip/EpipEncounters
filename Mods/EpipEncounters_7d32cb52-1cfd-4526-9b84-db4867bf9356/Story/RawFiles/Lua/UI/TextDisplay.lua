
---------------------------------------------
-- API for textDisplay UI.
-- Displays mouseover texts and surface tooltips.
---------------------------------------------

---@class TextDisplayUI : UI
local TextDisplay = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TextRemoved = {}, ---@type Event<EmptyEvent>
    },
    Hooks = {
        GetText = {}, ---@type PreventableEvent<TextDisplayUI_Hook_GetText>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.textDisplay, "TextDisplay", TextDisplay)

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when the engine renders text onto the UI.
---@class TextDisplayUI_Hook_GetText
---@field Label string Hookable.
---@field Position Vector2 Hookable. Defaults to mouse position.

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows mouse text on the UI.
---@param label string
---@param pos Vector2
function TextDisplay.ShowText(label, pos)
    TextDisplay:GetRoot().addText(label, pos:unpack())
end

---Clears the mouse text displayed in the UI.
function TextDisplay.RemoveText()
    TextDisplay:GetRoot().removeText()
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Listen for mouse text being displayed and throw hooks.
TextDisplay:RegisterInvokeListener("addText", function (ev, text, mouseX, mouseY)
    local hook = TextDisplay.Hooks.GetText:Throw({
        Label = text,
        Position = Vector.Create(mouseX, mouseY)
    })

    ev:PreventAction()

    if not hook.Prevented then
        -- Hit % label needs a delay for some unknown reason. TODO
        Ext.OnNextTick(function ()
            TextDisplay.ShowText(hook.Label, hook.Position)
        end)
    end
end)

-- Listen for mouse text being removed and forward the event.
TextDisplay:RegisterInvokeListener("removeText", function(_)
    TextDisplay.Events.TextRemoved:Throw()
end)