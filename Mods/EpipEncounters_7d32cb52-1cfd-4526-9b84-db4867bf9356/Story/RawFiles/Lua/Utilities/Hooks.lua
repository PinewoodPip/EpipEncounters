
---@meta UtilitiesHooks, ContextShared

---@class UtilitiesHooks
---@field Listeners table<string, function[]>
---@field Hooks table<string, function[]>

---@type UtilitiesHooks
local Hooks = {
    Listeners = {},
    Hooks = {},
}
Utilities.Hooks = Hooks
Epip.InitializeLibrary("Hooks", Hooks)

---Register an event listener.
---@param module string ID of the module raising the event
---@param id string Event ID
---@param handler function
function Hooks.RegisterListener(module, id, handler)
    local id = module .. "_" .. id

    if not Hooks.Listeners[id] then Hooks.Listeners[id] = {} end

    table.insert(Hooks.Listeners[id], {handler = handler})
end

---Fire an event for all listeners.
---@param module string ID of the module raising the event
---@param id string Event ID
---@return integer Amount of listeners.
function Hooks.FireEvent(module, id, ...)
    local id = module .. "_" .. id
    if not Hooks.Listeners[id] then return 0 end

    for i,listener in pairs(Hooks.Listeners[id]) do
        listener.handler(...)
    end

    return #Hooks.Listeners[id]
end

---Register a hook.
---@param module string ID of the module raising the event
---@param id string Event ID
---@param handler function
function Hooks.RegisterHook(module, id, handler)
    local id = module .. "_" .. id

    if not Hooks.Hooks[id] then Hooks.Hooks[id] = {} end

    table.insert(Hooks.Hooks[id], {handler = handler})
end

---Raise a hook event, letting all hook listeners manipulate the value passed.
---@param module string ID of the module raising the event
---@param id string Event ID
---@param value any Default value.
---@return any The modified value, or the default one if no hooks exist.
function Hooks.ReturnFromHooks(module, id, value, ...)
    return Hooks.Return(module, id, value, {First = false}, ...)
end

function Hooks.Return(module, id, value, opts, ...)
    local id = module .. "_" .. id

    if Hooks.Hooks[id] then
        for i,hook in pairs(Hooks.Hooks[id]) do
            local returnedValue = hook.handler(value, ...)
    
            if returnedValue ~= nil then
                value = returnedValue

                if opts and opts.First then
                    break
                end
            end
        end
    end

    return value
end