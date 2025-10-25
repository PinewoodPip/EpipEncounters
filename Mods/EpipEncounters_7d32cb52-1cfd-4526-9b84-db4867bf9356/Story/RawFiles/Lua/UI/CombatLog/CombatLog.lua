
---------------------------------------------
-- Scripting for the extended combat log.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@class CombatLogUI : UI
---@field Messages UI.CombatLog.ParsedMessage[]
---@field COLORS table<string, string>
---@field MAX_MESSAGES integer
---@field MAX_MERGING_TIME number Maximum time that can elapse before a message no longer can be merged into, in seconds.
---@field MessageTypes table<classname, UI.CombatLog.Message> Message type handlers.
---@field FILTERS table<string, UI.CombatLog.Filter>
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

    TranslatedStrings = {
        Label_Welcome = {
            Handle = "hfc2baeaeg3443g491cg97e4g895a23400f2d",
            Text = "Welcome to the combat log. Right-click to access filters.",
            ContextDescription = [[Message added when loading into a session]],
        },
        MessageBox_FeatureNotEnabled_Header = {
            Handle = "h68096433g8e54g4a81g9894g4be5096d2cdc",
            Text = "Feature Not Enabled",
            ContextDescription = [[Header for message box shown when trying to use filters without enabling the feature]],
        },
        MessageBox_FeatureNotEnabled_Message = {
            Handle = "hc3d4397fgb1ffg4cd2g8e3bg52b67ec37424",
            Text = [[You must enable "Improved Combat Log" in the options menu and reload the savefile to use custom filters.]],
            ContextDescription = [[Message shown when trying to use filters without the feature enabled]],
        },
        Header_Filters = {
            Handle = "hbfa93b2eg8fa6g4e2fgb241gc64e7c4708ec",
            Text = "———— Filters ————",
            ContextDescription = [[Header for the filters section in context menu. Em-dashes are decorative.]],
        },
        Filter_CriticalsAndDodges = {
            Handle = "h6f3a9d1bg8c7eg4b52ga9d3ge7c1f4b2a8d6",
            Text = "Critical Hits & Dodges",
            ContextDescription = [[Filter name for critical hits and dodges]],
        },
        Filter_SourceGenerationAndSI = {
            Handle = "h2d7f4a9egb1c8g4e47g9a6dgc3f8e1b5d2a7",
            Text = "Source Gen/Infuse",
            ContextDescription = [[Filter name for source generation and infusion (Epic Encounters 2 mechanics)]],
        },
        Filter_ReactionCharges = {
            Handle = "h1c9e3b7dga5f2g4d18g8e7cgf2a6d4c1b9e3",
            Text = "Reaction Charges",
            ContextDescription = [[Filter name for reaction charges (Epic Encounters 2 mechanic)]],
        },
        Filter_APPreservation = {
            Handle = "h3f5d8c2agb9e1g4a74g8d3bgf7c2e5a4b8d1",
            Text = "AP Preservation",
            ContextDescription = [[Filter name for AP preservation messages]],
        },
        Filter_Scripted = {
            Handle = "h7a4b9e2fg1d6cg4895ga2f7gd5e3c8b1a4f9",
            Text = "Generic/Scripted",
            ContextDescription = [[Filter name for generic/scripted messages]],
        },
    },

    Events = {
        MessageAdded = {}, ---@type Event<UI.CombatLog.Events.MessageAdded>
    },
    Hooks = {
        ParseMessage = {}, ---@type Hook<UI.CombatLog.Hooks.ParseMessage>
        CombineMessage = {}, ---@type Hook<UI.CombatLog.Hooks.CombineMessage>
        MessageCanMerge = {}, ---@type Hook<UI.CombatLog.Hooks.MessageCanMerge>
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/combatLog.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/combatLog.swf",
    },
    SAVE_NAME = "Epip_CombatLogConfig.json",
    SAVE_FORMAT = 0,
}
Epip.InitializeUI(Ext.UI.TypeID.combatLog, "CombatLog", Log)
local TSK = Log.TranslatedStrings

---A parsed message present in the UI.
---@class UI.CombatLog.ParsedMessage
---@field Filter integer
---@field Message UI.CombatLog.Message
---@field Time integer Monotonic time at which the message was added.

---@class UI.CombatLog.Filter
---@field Name string
---@field MessageTypes set<classname> Message types that this filter includes.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when a message is added to the log.
---@class UI.CombatLog.Events.MessageAdded
---@field Message UI.CombatLog.ParsedMessage

---@class UI.CombatLog.Hooks.ParseMessage
---@field ParsedMessage UI.CombatLog.Message? Hookable. Defaults to `nil`.
---@field RawMessage string The message being sent to the log by the game, with the base combat log color font tag removed.

---Fired when 2 messages of the same type are attempted to be sent one after another.
---Set `Combined` true to indicate you've edited `Message1` to amend it with the second message's data.
---If combined is true, `Message1` will be re-rendered and `Message2` will not be sent to the UI.
---@class UI.CombatLog.Hooks.CombineMessage
---@field PreviousMessage UI.CombatLog.ParsedMessage The previous message.
---@field NewMessage UI.CombatLog.ParsedMessage The new message being added. If combined, will not be sent to the UI.
---@field Combined boolean Hookable. Indicates whether the messages were combined. Defaults to `false`.

---Fired to determine if two messages can be merged.
---@class UI.CombatLog.Hooks.MessageCanMerge
---@field PreviousMessage UI.CombatLog.ParsedMessage The previous message.
---@field NewMessage UI.CombatLog.ParsedMessage The new message being added.
---@field CanMerge boolean Hookable. Defaults to `false`.

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

---@param filter? UI.CombatLog.Filter
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
---@param filter UI.CombatLog.Filter
function Log.RegisterFilter(id, filter)
    Log.FILTERS[id] = filter

    table.insert(Log.FilterOrder, id)

    Log.ToggleFilter(id, true)
end

---Stringifies a message and applies formatting to display it in the combat log.
---@param msg UI.CombatLog.Message
---@return string
function Log.StringifyMessage(msg)
    return Text.Format(msg:ToString(), {Color = Log.COLORS.TEXT})
end

---Adds a message to the log.
---@param msg UI.CombatLog.Message
---@param filter number? Defaults to 0.
function Log.AddMessage(msg, filter)
    filter = filter or 0

    ---@type UI.CombatLog.ParsedMessage
    local obj = {
        Message = msg,
        Filter = filter,
        Time = Ext.MonotonicTime(),
    }

    ---@type UI.CombatLog.ParsedMessage
    local lastMessage = Log.Messages[#Log.Messages]
    local combined = false

    -- Attempt to merge message with the immediate previous one
    if lastMessage then
        local timeElapsed = Ext.MonotonicTime() - lastMessage.Time
        timeElapsed = timeElapsed / 1000
        if lastMessage.Message:GetClassName() == msg:GetClassName() and timeElapsed < Log.MAX_MERGING_TIME then -- Messages must be of the same type and recent
            local canMerge = Log.Hooks.MessageCanMerge:Throw({
                PreviousMessage = lastMessage,
                NewMessage = obj,
                CanMerge = false,
            }).CanMerge
            if canMerge then
                combined = Log.Hooks.CombineMessage:Throw({
                    PreviousMessage = lastMessage,
                    NewMessage = obj,
                    Combined = false,
                }).Combined
            end
        end
    end

    if combined then
        -- Edit the last message
        local root = Log:GetRoot()
        local msgElement = root.log_mc.textList.content_array[#root.log_mc.textList.content_array - 1]

        Log:DebugLog("Appending messages of type " .. lastMessage.Message:GetClassName())

        lastMessage.Time = Ext.MonotonicTime() -- Update time.

        msgElement.text = Log.StringifyMessage(lastMessage.Message)
        msgElement.text_txt.htmlText = msgElement.text
    else
        Log:GetRoot().addTextToFilter(filter, Log.StringifyMessage(msg), msg:GetClassName())

        table.insert(Log.Messages, obj)

        if (#Log.Messages > Log.MAX_MESSAGES) then
            table.remove(Log.Messages, 1)
        end
    end

    Log.Events.MessageAdded:Throw({
        Message = obj,
    })

    -- Log added message, if it doesn't use the fallback type
    if obj.Message:GetClassName() ~= "UI.CombatLog.Messages.Unsupported" then
        Log:DebugLog("Message added: ")
        Log:Dump(obj)
    end
end

---Converts a vanilla combat log message to its object form.
---@return UI.CombatLog.Message
function Log.GetData(msg)
    local parsedMsg = Log.Hooks.ParseMessage:Throw({
        RawMessage = msg:gsub([[^<font color="#]] .. Log.COLORS.TEXT .. [[">(.+)</font>$]], "%1"), -- Remove base message color
        ParsedMessage = nil
    }).ParsedMessage

    -- Fallback to a generic message type.
    if not parsedMsg then
        local UnsupportedMsg = Log:GetClass("UI.CombatLog.Messages.Unsupported")
        parsedMsg = UnsupportedMsg:Create(msg)
    end

    return parsedMsg
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

Log.Hooks.MessageCanMerge:Subscribe(function (ev)
    if ev.PreviousMessage.Filter == ev.NewMessage.Filter then
        ev.CanMerge = ev.PreviousMessage.Message:CanMerge(ev.NewMessage.Message)
    end
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

    -- Resend welcome message
    Log:GetRoot().addTextToFilter(0, TSK.Label_Welcome:GetString())
end)

Client.UI.ContextMenu.RegisterMenuHandler("combatLog", function()
    local filters = {}

    if not Settings.GetSettingValue("EpipEncounters", "CombatLogImprovements") then
        Client.UI.MessageBox.Open({
            ID = "CombatLog_Disabled",
            Header = TSK.MessageBox_FeatureNotEnabled_Header:GetString(),
            Message = TSK.MessageBox_FeatureNotEnabled_Message:GetString(),
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

    table.insert(filters, {id = "combatLog_Clear", type = "button", text = CommonStrings.Clear:GetString(), requireShiftClick = true})

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "combatLog_Filters_Header", type = "header", text = TSK.Header_Filters:GetString()},

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

---@type UI.CombatLog.Filter[]
local DefaultFilters = {
    {
        ID = "Actions",
        Name = CommonStrings.Skills:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Skill"] = true,
        }
    },
    {
        ID = "Damage",
        Name = CommonStrings.Damage:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Damage"] = true,
            ["UI.CombatLog.Messages.Attack"] = true,
        },
    },
    {
        ID = "SurfaceDamage",
        Name = CommonStrings.SurfaceDamage:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.SurfaceDamage"] = true,
        },
    },
    {
        ID = "ReflectedDamage",
        Name = CommonStrings.ReflectedDamage:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.ReflectedDamage"] = true,
        },
    },
    {
        ID = "Healing",
        Name = CommonStrings.Healing:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Healing"] = true,
            -- Lifesteal is not included as it has its own filter. 
        }
    },
    {
        ID = "Lifesteal",
        Name = CommonStrings.Lifesteal:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Lifesteal"] = true,
        }
    },
    {
        ID = "CriticalHits",
        Name = TSK.Filter_CriticalsAndDodges:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.CriticalHit"] = true,
            ["UI.CombatLog.Messages.Dodge"] = true,
        },
    },
    {
        ID = "StatusApplication",
        Name = CommonStrings.Statuses:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Status"] = true,
        }
    },
    {
        ID = "SourceGeneration",
        Name = TSK.Filter_SourceGenerationAndSI:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.SourceGeneration"] = true,
            ["UI.CombatLog.Messages.SourceInfusionLevel"] = true,
        }
    },
    {
        ID = "SystemSpam",
        Name = TSK.Filter_ReactionCharges:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.ReactionCharges"] = true,
        },
    },
    {
        ID = "APPreservation",
        Name = TSK.Filter_APPreservation:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.APPreservation"] = true,
        }
    },
    {
        ID = "Scripted",
        Name = TSK.Filter_Scripted:GetString(),
        MessageTypes = {
            ["UI.CombatLog.Messages.Scripted"] = true,
        },
    },
}

for _,filter in pairs(DefaultFilters) do
    Log.RegisterFilter(filter.ID, filter)
end