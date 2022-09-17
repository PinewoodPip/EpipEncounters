

---@class ModsUI : UI
local Mods = {
    _AddOns = {}, ---@type ModsUI_AddOn[]

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Opened = {}, ---@type SubscribableEvent<ModsUI_Event_Opened>
    },
    Hooks = {
        AddMod = {}, ---@type SubscribableEvent<ModsUI_Hook_AddMod>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.mods, "Mods", Mods)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when the UI opens.
---@class ModsUI_Event_Opened
---@field AddOnMods ModsUI_AddOn[]

---Fired when the engine adds a mod (add-on) to the UI.
---Happens before Opened event, once per add-on.
---@class ModsUI_Hook_AddMod
---@field Mod ModsUI_AddOn

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class ModsUI_AddOn
---@field ID number
---@field Label string
---@field Active boolean
---@field Order number
---@field Invalid boolean

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Listen for the UI being opened. The fadeIn call in the swf appears to be unused, so our best bet is a timer after any other invoke.
Mods:RegisterInvokeListener("setModNotice", function (_)
    Timer.StartTickTimer(5, function (_)
        Mods.Events.Opened:Throw({
            AddOnMods = Mods._AddOns
        })
    
        Mods._AddOns = {}
    end)
end)

-- Listen for add-ons being added.
Mods:RegisterInvokeListener("addAlterMod", function (ev, id, label, active, order, invalid)
    local root = ev.UI:GetRoot()
    ---@type ModsUI_AddOn
    local mod = {
        ID = id,
        Label = label,
        Active = active,
        Order = order,
        Invalid = invalid,
    }

    local hook = Mods.Hooks.AddMod:Throw({Mod = mod})
    mod = hook.Mod

    -- Needs a delay for reasons unknown.
    Timer.StartTickTimer(2, function (_)
        root.addAlterMod(mod.ID, mod.Label, mod.Active, mod.Order, mod.Invalid)
    end)

    -- Keep track of added add-ons
    table.insert(Mods._AddOns, mod)
end, "After")