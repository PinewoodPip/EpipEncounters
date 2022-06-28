
---------------------------------------------
-- Scripting for the extended combat log.
---------------------------------------------

-- TODO
-- Check last X messages for merging
-- Add more message types
-- Some utility method for concatenating with commas

---@class CombatLogUI
---@field Messages CombatLogSentMessage[]
---@field COLORS table<string, string>
---@field MAX_MESSAGES integer
---@field MAX_MERGING_TIME number Maximum time that can elapse before a message no longer can be merged into, in seconds.
---@field MessageTypes table<string, CombatLogMessage> Templtes for creating messages.
---@field FILTERS table<string, CombatLogFilter>
---@field EnabledFilters table<string, boolean>

---@type CombatLogUI
local Log = {
    Messages = {},
    COLORS = {
        PARTY_MEMBER = "188EDE",
        TEXT = "DBDBDB",
        VITALITY_HEAL = "97FBFF",
    },
    MAX_MESSAGES = 20,
    MAX_MERGING_TIME = 7,
    FILTERS = {},
    MessageTypes = {

    },
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
Epip.InitializeUI(Client.UI.Data.UITypes.combatLog, "CombatLog", Log)
Client.UI.CombatLog = Log
Log:Debug()

---@class CombatLogSentMessage
---@field Filter integer
---@field Message CombatLogMessage
---@field Time integer Monotonic time.

---@class CombatLogFilter
---@field Name string
---@field MessageTypes table<string, boolean>

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class CombatLogUI_Hook_GetMessageObject : Hook
---@field RegisterHook fun(self, handler:fun(obj:CombatLogMessage, message:string))
---@field Return fun(self, obj:CombatLogMessage, message:string)

---@class CombatLogUI_Event_MessageAdded : Event
---@field RegisterListener fun(self, listener:fun(msg:CombatLogSentMessage))
---@field Fire fun(self, msg:CombatLogSentMessage)

---Fired when 2 messages of the same type are attempted to be sent one after another. You're expected to return true if you've edited msg1 to append to its message. If combined is true, msg1 will be re-rendered and msg2 will not be sent to the UI.
---@class CombatLogUI_Hook_CombineMessage : Hook
---@field RegisterHook fun(self, handler:fun(combined:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage))
---@field Return fun(self, combined:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage)

---@class CombatLogUI_Hook_MessageCanMerge : Hook
---@field RegisterHook fun(self, handler:fun(canMerge:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage))
---@field Return fun(self, canMerge:boolean, msg1:CombatLogSentMessage, msg2:CombatLogSentMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

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

    Utilities.SaveJson(file, config)
end

---@param file string?
function Log.LoadConfig(file)
    file = file or Log.SAVE_NAME
    local config = Utilities.LoadJson(file)

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
            for id,f in pairs(Log.FILTERS) do
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
---@param msg CombatLogMessage
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

        if lastMessage.Message.Type == msg.Type and timeElapsed < Log.MAX_MERGING_TIME and Log.Hooks.MessageCanMerge:Return(false, lastMessage, obj) then
            combined = Log.Hooks.CombineMessage:Return(false, lastMessage, obj)
        end
    end

    if combined then
        -- Edit the last message
        local root = Log:GetRoot()
        local filterObj = root.log_mc.filterList.content_array[filter].text_Array
        local msgIndex = filterObj[#filterObj - 1]
        local msg = root.log_mc.textList.content_array[#root.log_mc.textList.content_array - 1]

        Log:DebugLog("Appending messages of type " .. lastMessage.Message.Type)

        lastMessage.Time = Ext.MonotonicTime() -- Update time.

        msg.text = lastMessage.Message:ToString()
        msg.text_txt.htmlText = msg.text
    else

        Log:GetRoot().addTextToFilter(filter, msg:ToString(), msg.Type)

        table.insert(Log.Messages, obj)

        if (#Log.Messages > Log.MAX_MESSAGES) then
            table.remove(Log.Messages, 1)
        end
    end

    Log.Events.MessageAdded:Fire(obj)

    if Log:IsDebug() and obj.Message.Type ~= "Unsupported" then
        Log:DebugLog("Message added: ")
        _D(obj)
    end
end

---Converts a vanilla combat log message to its object form.
---@return CombatLogMessage
function Log.GetData(msg)
    local obj

    obj = Log.Hooks.GetMessageObject:Return(obj, msg)

    --Fallback to a generic message type.
    if not obj then
        obj = Log.MessageTypes.Unsupported.Create(msg)
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
Log:RegisterInvokeListener("setFilterSelection", function(ev, filter, enabled)
    Log:GetRoot().setFilterSelection(filter, true)
    ev:PreventAction()
end)

Log:RegisterInvokeListener("addTextToFilter", function(ev, filter, text)

    if Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "CombatLogImprovements") then

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

Client.UI.ContextMenu.RegisterElementListener("combatLog_Filters_Toggle", "buttonPressed", function(character, params)
    Log.ToggleFilter(params.FilterID)
    Log.SaveConfig()
end)

Client.UI.ContextMenu.RegisterElementListener("combatLog_Clear", "buttonPressed", function(character, params)
    Log.Clear()
end)

-- Clear the log on reset.
Ext.Events.ResetCompleted:Subscribe(function()
    Log.Clear()
    Log:GetRoot().addTextToFilter(0, "Welcome to the combat log. Right-click to access filters.")
end)

Client.UI.ContextMenu.RegisterMenuHandler("combatLog", function()
    local filters = {}

    if not Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "CombatLogImprovements") then
        Client.UI.MessageBox.Open({
            ID = "CombatLog_Disabled",
            Header = "Feature Not Enabled",
            Message = "You must enable 'Combat Log Improvements' in the options menu and reload the savefile to use custom filters.",
        })
        return nil
    end

    for i,id in ipairs(Log.FilterOrder) do
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
    local root = Log:GetRoot()
    local pos = Log:GetUI():GetPosition()
    Client.UI.ContextMenu.SetPosition(Client.UI.ContextMenu.GetActiveUI(), root.stage.mouseX + pos[1], root.stage.mouseY)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Log:__Setup()
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
            Skill = true,
        }
    },
    {
        ID = "Damage",
        Name = "Damage",
        MessageTypes = {
            Damage = true,
            Attack = true,
        },
    },
    {
        ID = "SurfaceDamage",
        Name = "Surface Damage",
        MessageTypes = {
            SurfaceDamage = true,
        },
    },
    {
        ID = "ReflectedDamage",
        Name = "Reflected Damage",
        MessageTypes = {
            ReflectedDamage = true,
        },
    },
    {
        ID = "Healing",
        Name = "Healing",
        MessageTypes = {
            Healing = true,
            -- Lifesteal = true,
        }
    },
    {
        ID = "Lifesteal",
        Name = "Lifesteal",
        MessageTypes = {
            Lifesteal = true,
        }
    },
    {
        ID = "StatusApplication",
        Name = "Statuses",
        MessageTypes = {
            Status = true,
        }
    },
    {
        ID = "SourceGeneration",
        Name = "Source Gen/Infuse",
        MessageTypes = {
            SourceGeneration = true,
            SourceInfusionLevel = true,
        }
    },
    {
        ID = "SystemSpam",
        Name = "Reaction Charges",
        MessageTypes = {
            ReactionCharges = true,
        },
    },
    {
        ID = "APPreservation",
        Name = "AP Preservation",
        MessageTypes = {
            APPreservation = true,
        }
    },
    {
        ID = "Scripted",
        Name = "Generic/Scripted",
        MessageTypes = {
            Scripted = true,
        }
    }
}

for i,filter in pairs(DefaultFilters) do
    Log.RegisterFilter(filter.ID, filter)
end