
---------------------------------------------
-- Utility feature to request the user to select a skill from their skillbook UI.
---------------------------------------------

local Notification = Client.UI.Notification
local Skills = Client.UI.Skills
local PanelSelect = Client.UI.Controller.PanelSelect
local SkillsC = Client.UI.Controller.InventorySkillPanel

---@class Features.SkillPicker : Feature
local Picker = {
    EVENTID_CANCEL_ON_CLOSE = "Features.SkillPicker.CancelOnUIClose",

    _CurrentRequestID = nil, ---@type string?

    TranslatedStrings = {
        Label_Hint = {
            Handle = "hfa698acbg0d00g4441g833eg48ecf14fc04f",
            Text = "Select a skill.",
            ContextDescription = [[Notification]],
        },
    },
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        RequestCompleted = {}, ---@type Event<{RequestID:string, Skill:skill}>
        RequestCancelled = {}, ---@type Event<{RequestID:string}>
    },
}
Epip.RegisterFeature("Features.SkillPicker", Picker)
local TSK = Picker.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests a skill to be picked by the user.
function Picker.Request(requestID)
    Picker.CancelRequest() -- Cancel previous request first
    Picker._CurrentRequestID = requestID
    Picker._SetupUI()
end

---Cancels the current request, if any.
function Picker.CancelRequest()
    if not Picker._CurrentRequestID then return end
    Picker.Events.RequestCancelled:Throw({
        RequestID = Picker._CurrentRequestID
    })
    Picker._CleanupRequest()
end

---Completes the current request.
---@param skillID skill
function Picker.CompleteRequest(skillID)
    Picker.Events.RequestCompleted:Throw({
        RequestID = Picker._CurrentRequestID,
        Skill = skillID,
    })
    Picker._CleanupRequest()
end

---Sets up the UI for a request.
function Picker._SetupUI()
    Notification.ShowNotification(TSK.Label_Hint:GetString())
    if Client.IsUsingController() then
        PanelSelect:Show()
        Ext.OnNextTick(function (_)
            PanelSelect:ExternalInterfaceCall("openPanel", 2)
            PanelSelect:Hide()
            Picker._SetupUIHideListener(SkillsC)
        end)
    else
        Skills:Show()
        Picker._SetupUIHideListener(Skills)
    end
end

---Sets up a listener to cancel the current request when a UI is closed.
---@param ui UI
function Picker._SetupUIHideListener(ui)
    GameState.Events.RunningTick:Subscribe(function (_)
        if not ui:IsVisible() then
            Picker.CancelRequest()
        end
    end, {StringID = Picker.EVENTID_CANCEL_ON_CLOSE})
end

---Updates bookkeeping and removes temporary UI listeners.
function Picker._CleanupRequest()
    Picker._CurrentRequestID = nil
    GameState.Events.RunningTick:Unsubscribe(Picker.EVENTID_CANCEL_ON_CLOSE)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Block skills from being memorized/unmemorized while picking.
---Handles a slot being clicked in the KBM Skills UI.
---@param ev EclLuaUICallEvent
---@param skillID string
local function CompleteRequest(ev, skillID)
    if Picker._CurrentRequestID then
        Picker.CompleteRequest(skillID)
        ev.UI:Hide()
        ev:PreventAction()
    end
end
Skills:RegisterCallListener("applyChanges", CompleteRequest)
Skills:RegisterCallListener("cantUnlearn", CompleteRequest) -- Fired when clicking innate skills.
-- Controller equivalent
SkillsC:RegisterCallListener("useSkill", function (ev, _)
    CompleteRequest(ev, SkillsC.GetSelectedSkill())
end)
