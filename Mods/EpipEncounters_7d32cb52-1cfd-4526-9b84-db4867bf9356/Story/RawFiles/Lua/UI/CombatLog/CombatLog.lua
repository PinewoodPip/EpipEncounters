
---------------------------------------------
-- Scripting for the extended combat log.
---------------------------------------------

-- TODO
-- Check last X messages for merging
-- Add more message types
-- Some utility method for concatenating with commas

---@class CombatLogUI : UI
---@field Messages CombatLogSentMessage[]
---@field COLORS table<string, string>
---@field MAX_MESSAGES integer
---@field MAX_MERGING_TIME number Maximum time that can elapse before a message no longer can be merged into, in seconds.
---@field MessageTypes table<classname, UI.CombatLog.Message> Message type handlers.
---@field FILTERS table<string, CombatLogFilter>
---@field EnabledFilters table<string, boolean>
local Log = {
    CHARACTER_ACTION_TSKHANDLE = "hddc42b8dg6456g4b7eg98d1gea65bc929fed", -- "[1] [2] [3], for [4]"; multiple message types use this structure; params 1 & 3 tend to be attacker & defender (optional)
    CHARACTER_RECEIVED_ACTION_TSKHANDLE = "h3cc306cdg95b4g4803g803ag2dd33a722d6c", -- "[1] was [2] for [3]"; used for ex. "X was hit for Y damage"
    DAMAGE_TSKHANDLE = "h784f42a9g95e6g4a55gb2b5g3ef52f6bbee6", -- "[1] Damage"

    Messages = {},
    COLORS = {
        PARTY_MEMBER = "188EDE",
        TEXT = "DBDBDB",
        VITALITY_HEAL = "97FBFF",
    },
    MAX_MESSAGES = 20,
    MAX_MERGING_TIME = 7,
    FILTERS = {},
    MessageTypes = {},
    EnabledFilters = {},
    FilterOrder = {},
    Hooks = {
        ---@type CombatLogUI_Hook_GetMessageObject
        GetMessageObject = {Options = {First = false}},
        ---@type CombatLogUI_Hook_CombineMessage
        CombineMessage = {},
        ---@type CombatLogUI_Hook_MessageCanMerge
        MessageCanMerge = {},
    },
    Events = {
        ---@type CombatLogUI_Event_MessageAdded
        MessageAdded = {},
    },
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/combatLog.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/combatLog.swf",
    },
    SAVE_NAME = "Epip_CombatLogConfig.json",
    SAVE_FORMAT = 0,
}
Epip.InitializeUI(Ext.UI.TypeID.combatLog, "CombatLog", Log)

---@class CombatLogSentMessage
---@field Filter integer
---@field Message UI.CombatLog.Message
---@field Time integer Monotonic time.

---@class CombatLogFilter
---@field Name string
---@field MessageTypes set<classname> Message types that this filter includes.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class CombatLogUI_Hook_GetMessageObject : LegacyHook
---@field RegisterHook fun(self, handler:fun(obj:UI.CombatLog.Message, message:string):UI.CombatLog.Message)
---@field Return fun(self, obj:UI.CombatLog.Message, message:string):UI.CombatLog.Message

---@class CombatLogUI_Event_MessageAdded : Event
---@field RegisterListener fun(self, listener:fun(msg:CombatLogSentMessage))
---@field Fire fun(self, msg:CombatLogSentMessage)

---Fired when 2 messages of the same type are attempted to be sent one after another. You're expected to return true if you've edited msg1 to append to its message. If combined is true, msg1 will be re-rendered and msg2 will not be sent to the UI.
---@class CombatLogUI_Hook_CombineMessage : LegacyHook
---@field RegisterHook fun(self, handler:fun(combined:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage):boolean)
---@field Return fun(self, combined:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage):boolean

---@class CombatLogUI_Hook_MessageCanMerge : LegacyHook
---@field RegisterHook fun(self, handler:fun(canMerge:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage):boolean)
---@field Return fun(self, canMerge:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage):boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a message handler.
---@param handler UI.CombatLog.Message
function Log.RegisterMessageHandler(handler)
    Log.MessageTypes[handler:GetClassName()] = handler
end

---@param filter string
---@return boolean
function Log.IsFilterEnabled(filter)
    return Log.EnabledFilters[filter] or Log.EnabledFilters[filter] == nil
end

---@param file string?
function Log.SaveConfig(file)
    local config = {
        Filters = Log.EnabledFilters,
        Format = Log.SAVE_FORMAT,
    }
    file = file or Log.SAVE_NAME

    IO.SaveFile(file, config)
end

---@param file string?
function Log.LoadConfig(file)
    file = file or Log.SAVE_NAME
    local config = IO.LoadFile(file)

    if config then
        Log.EnabledFilters = config.Filters

        -- Newly-added filters default to true
        -- for id,filter in pairs(Log.FILTERS) do
        --     if Log.EnabledFilters[id] == nil then
        --         Log.ToggleFilter(id, true)
        --     end
        -- end
    end
end

---@param filter string
---@param state? boolean Defaults to toggling.
function Log.ToggleFilter(filter, state)
    if state == nil then state = not Log.IsFilterEnabled(filter) end

    Log.EnabledFilters[filter] = state

    Log.RefreshFilters(filter)
end

---@param filter? CombatLogFilter
function Log.RefreshFilters(filter)
    if Log:Exists() then
        if filter then
            for msgType,_ in pairs(Log.FILTERS[filter].MessageTypes) do
                Log:GetRoot().log_mc.toggleFilter(msgType, not Log.IsMessageTypeFiltered(msgType))
            end
        else
            for _,f in pairs(Log.FILTERS) do
                for msgType,_ in pairs(f.MessageTypes) do
                    Log:GetRoot().log_mc.toggleFilter(msgType, not Log.IsMessageTypeFiltered(msgType))
                end
            end
        end

        Log:GetRoot().log_mc.refreshText()

        Log:GetRoot().log_mc.textList.m_scrollbar_mc.resetHandleToBottom()
    end
end

---@param id string
---@param filter CombatLogFilter
function Log.RegisterFilter(id, filter)
    Log.FILTERS[id] = filter

    table.insert(Log.FilterOrder, id)

    Log.ToggleFilter(id, true)
end

---Adds a message to the log.
---@param msg UI.CombatLog.Message
---@param filter number? Defaults to 0.
function Log.AddMessage(msg, filter)
    filter = filter or 0

    ---@type CombatLogSentMessage
    local obj = {
        Message = msg,
        Filter = filter,
        Time = Ext.MonotonicTime(),
    }

    ---@type CombatLogSentMessage
    local lastMessage = Log.Messages[#Log.Messages]
    local combined = false

    if lastMessage then
        local timeElapsed = Ext.MonotonicTime() - lastMessage.Time
        timeElapsed = timeElapsed / 1000

        if lastMessage.Message:GetClassName() == msg:GetClassName() and timeElapsed < Log.MAX_MERGING_TIME and Log.Hooks.MessageCanMerge:Return(false, lastMessage, obj) then
            combined = Log.Hooks.CombineMessage:Return(false, lastMessage, obj)
        end
    end

    if combined then
        -- Edit the last message
        local root = Log:GetRoot()
        local msgElement = root.log_mc.textList.content_array[#root.log_mc.textList.content_array - 1]

        Log:DebugLog("Appending messages of type " .. lastMessage.Message:GetClassName())

        lastMessage.Time = Ext.MonotonicTime() -- Update time.

        msgElement.text = lastMessage.Message:ToString()
        msgElement.text_txt.htmlText = msgElement.text
    else
        Log:GetRoot().addTextToFilter(filter, msg:ToString(), msg:GetClassName())

        table.insert(Log.Messages, obj)

        if (#Log.Messages > Log.MAX_MESSAGES) then
            table.remove(Log.Messages, 1)
        end
    end

    Log.Events.MessageAdded:Fire(obj)

    -- Log added message, if it doesn't use the fallback type
    if obj.Message:GetClassName() ~= "UI.CombatLog.Messages.Unsupported" then
        Log:DebugLog("Message added: ")
        Log:Dump(obj)
    end
end

---Converts a vanilla combat log message to its object form.
---@return UI.CombatLog.Message
function Log.GetData(msg)
    local obj

    obj = Log.Hooks.GetMessageObject:Return(obj, msg)

    --Fallback to a generic message type.
    if not obj then
        local UnsupportedMsg = Log:GetClass("UI.CombatLog.Messages.Unsupported")
        obj = UnsupportedMsg:Create(msg)
    end

    return obj
end

function Log.IsMessageTypeFiltered(messageType)
    local filtered = false

    for k,filter in pairs(Log.FILTERS) do
        if filter.MessageTypes[messageType] and not Log.IsFilterEnabled(k) then
            filtered = true
        elseif filter.MessageTypes[messageType] and Log.IsFilterEnabled(k) then
            filtered = false -- If multiple filters affect the same message types, showing takes priority over filtering out.
            break
        end
    end

    return filtered
end

function Log.Clear()
    local root = Log:GetRoot()

    -- root.clearAll()
    root.clearAllTexts()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Log.Hooks.MessageCanMerge:RegisterHook(function (canMerge, msg1, msg2)
    if msg1.Filter == msg2.Filter then
        canMerge = msg1.Message:CanMerge(msg2.Message)
    end

    return canMerge
end)

-- Force hardcoded filters to always be enabled.
Log:RegisterInvokeListener("setFilterSelection", function(ev, filter, _)
    Log:GetRoot().setFilterSelection(filter, true)
    ev:PreventAction()
end)

Log:RegisterInvokeListener("addTextToFilter", function(ev, filter, text)

    if Settings.GetSettingValue("EpipEncounters", "CombatLogImprovements") then

        -- The engine sometimes sends these empty messages which confuse the system. Fuck em.
        if text == '<font size="16"></font>' then
            ev:PreventAction()
        else
            local obj = Log.GetData(text)

            if obj then
                Log:DebugLog("Message sent from engine: " .. text)
                Log.AddMessage(obj, filter)

                ev:PreventAction()
            end
        end
    end
end)

--Don't send calls for our custom filters
Log:RegisterCallListener("selectFilter", function(ev, id)
    if id > 4 then
        ev:PreventAction()
    end
end)

Client.UI.ContextMenu.RegisterElementListener("combatLog_Filters_Toggle", "buttonPressed", function(_, params)
    Log.ToggleFilter(params.FilterID)
    Log.SaveConfig()
end)

Client.UI.ContextMenu.RegisterElementListener("combatLog_Clear", "buttonPressed", function(_, _)
    Log.Clear()
end)

-- Clear the log on reset.
Ext.Events.ResetCompleted:Subscribe(function()
    if Client.IsUsingController() then return end
    Log.Clear()
    Log:GetRoot().addTextToFilter(0, "Welcome to the combat log. Right-click to access filters.")
end)

Client.UI.ContextMenu.RegisterMenuHandler("combatLog", function()
    local filters = {}

    if not Settings.GetSettingValue("EpipEncounters", "CombatLogImprovements") then
        Client.UI.MessageBox.Open({
            ID = "CombatLog_Disabled",
            Header = "Feature Not Enabled",
            Message = "You must enable 'Combat Log Improvements' in the options menu and reload the savefile to use custom filters.",
        })
        return nil
    end

    for _,id in ipairs(Log.FilterOrder) do
        local filter = Log.FILTERS[id]

        table.insert(filters, {
            id = "combatLog_Filters_" .. id,
            text = filter.Name,
            type = "checkbox",
            checked = Log.IsFilterEnabled(id),
            eventIDOverride = "combatLog_Filters_Toggle",
            params = {
                FilterID = id,
            }
        })
    end

    table.insert(filters, {id = "combatLog_Clear", type = "button", text = "Clear", requireShiftClick = true})

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "combatLog_Filters_Header", type = "header", text = "———— Filters ————"},

                table.unpack(filters),
            }
        }
    })

    Client.UI.ContextMenu.Open()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Log:__Setup()
    if Client.IsUsingController() then return end
    Log:GetRoot().log_mc.filterHolder_mc.visible = false

    Log.LoadConfig()
    Log.RefreshFilters()
end

---------------------------------------------
-- TEST FILTERS
---------------------------------------------

---@type CombatLogFilter[]
local DefaultFilters = {
    {
        ID = "Actions",
        Name = "Skills",
        MessageTypes = {
            ["UI.CombatLog.Messages.Skill"] = true,
        }
    },
    {
        ID = "Damage",
        Name = "Damage",
        MessageTypes = {
            ["UI.CombatLog.Messages.Damage"] = true,
            ["UI.CombatLog.Messages.Attack"] = true,
        },
    },
    {
        ID = "SurfaceDamage",
        Name = "Surface Damage",
        MessageTypes = {
            ["UI.CombatLog.Messages.SurfaceDamage"] = true,
        },
    },
    {
        ID = "ReflectedDamage",
        Name = "Reflected Damage",
        MessageTypes = {
            ["UI.CombatLog.Messages.ReflectedDamage"] = true,
        },
    },
    {
        ID = "Healing",
        Name = "Healing",
        MessageTypes = {
            ["UI.CombatLog.Messages.Healing"] = true,
            -- Lifesteal is not included as it has its own filter. 
        }
    },
    {
        ID = "Lifesteal",
        Name = "Lifesteal",
        MessageTypes = {
            ["UI.CombatLog.Messages.Lifesteal"] = true,
        }
    },
    {
        ID = "CriticalHits",
        Name = "Critical Hits & Dodges",
        MessageTypes = {
            ["UI.CombatLog.Messages.CriticalHit"] = true,
            ["UI.CombatLog.Messages.Dodge"] = true,
        },
    },
    {
        ID = "StatusApplication",
        Name = "Statuses",
        MessageTypes = {
            ["UI.CombatLog.Messages.Status"] = true,
        }
    },
    {
        ID = "SourceGeneration",
        Name = "Source Gen/Infuse",
        MessageTypes = {
            ["UI.CombatLog.Messages.SourceGeneration"] = true,
            ["UI.CombatLog.Messages.SourceInfusionLevel"] = true,
        }
    },
    {
        ID = "SystemSpam",
        Name = "Reaction Charges",
        MessageTypes = {
            ["UI.CombatLog.Messages.ReactionCharges"] = true,
        },
    },
    {
        ID = "APPreservation",
        Name = "AP Preservation",
        MessageTypes = {
            ["UI.CombatLog.Messages.APPreservation"] = true,
        }
    },
    {
        ID = "Scripted",
        Name = "Generic/Scripted",
        MessageTypes = {
            ["UI.CombatLog.Messages.Scripted"] = true,
        },
    },
}

for _,filter in pairs(DefaultFilters) do
    Log.RegisterFilter(filter.ID, filter)
end