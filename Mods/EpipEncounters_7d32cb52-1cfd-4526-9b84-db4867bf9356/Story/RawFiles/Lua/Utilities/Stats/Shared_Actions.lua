
---@class StatsLib
local Stats = Stats

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias StatsLib_Action_ID "ActionSkillSneak"|"ActionAttackGround"|"ActionSkillDisarm"|"ActionSkillFlee"|"ActionSkillGuard"|"ActionSkillLockpick"|"ActionSkillSheathe"|"ActionSkillRepair"|"ActionSkillIdentify"|"ActionSkillEndTurn"

---@class StatsLib_Action
---@field ID string
---@field Icon string
---@field NameHandle TranslatedStringHandle
---@field NameHandleAlt TranslatedStringHandle? Alternative name. Used by ActionSkillSneak and ActionSkillSheathe.
---@field DescriptionHandle TranslatedStringHandle
local _Action = {}

---Returns the name of the action.
---@param useAltName boolean? Defaults to false. Not all actions have an alternative name.
---@return string
function _Action:GetName(useAltName)
    local handle = self.NameHandle

    if useAltName then
        handle = self.NameHandleAlt or self.NameHandle
    end

    return Ext.L10N.GetTranslatedString(handle, "Wrong handle for " .. self.ID)
end

---Returns the description of the action, used in tooltips.
---@return string
function _Action:GetDescription()
    return Ext.L10N.GetTranslatedString(self.DescriptionHandle, "Wrong handle for " .. self.ID)
end

---------------------------------------------
-- SETUP
---------------------------------------------

---@type table<StatsLib_Action_ID, StatsLib_Action>
Stats.Actions = {
    ActionSkillSneak = {
        Icon = "Action_Sneak",
        NameHandle = "h7ccd039age7f6g4022g9078g4b8d3749c956", -- "Enter Sneak Mode"
        NameHandleAlt = "hc0d5bf50g6523g4779g9b2egb772480114c7", -- "Exit Sneak Mode"
        DescriptionHandle = "h194329edgd348g46eagad00gd185ec228296",
    },
    ActionAttackGround = {
        Icon = "Action_AttackGround",
        NameHandle = "hbdac34fdg43b6g4439g9947g6676e9c03294",
        DescriptionHandle = "hcacb94cbg4737g4a52g8b07gc5af8628eff5",
    },
    ActionSkillDisarm = {
        Icon = "Action_Disarm",
        NameHandle = "h0caaedadg4d07g4378g9cd1ge13fee7703e7",
        DescriptionHandle = "h52103f4bga860g4afeg8cefgefede098fc9d",
    },
    ActionSkillFlee = {
        Icon = "Action_Flee",
        NameHandle = "hb399d83eg5ae8g48d0g8f7eg1a89d707f7f9",
        DescriptionHandle = "hc157fadagf8a7g4707g9886g1b75941156f4",
    },
    ActionSkillGuard = {
        Icon = "Action_Guard",
        NameHandle = "hcf2cc556g6779g4605g95a8g23ded44b1e7c",
        DescriptionHandle = "h71f64c4eg1fe2g4448g9c00gcec4adc5b5d5",
    },
    ActionSkillLockpick = {
        Icon = "Action_LockPick",
        NameHandle = "h12379ad5g2d06g43b0g8bb2gae030cc52b8a",
        DescriptionHandle = "h584bafc1g62bag4b08g84a8gc37ca5056c2d",
    },
    ActionSkillSheathe = {
        Icon = "Action_Sheath",
        NameHandle = "h14dec5c1g0fa6g4abag8219gba6727c227d8", -- "Unsheathe"
        NameHandleAlt = "hbb510089g3d5bg434dga929gcb697fcaf656", -- "Sheathe"
        DescriptionHandle = "h8cd2fa76g3210g4b1egade2g8bb2d0db3bcd",
    },
    ActionSkillRepair = {
        Icon = "Action_Repair",
        NameHandle = "hfb0ab865gb8dfg4e35g9c8dg0a8bb9445348",
        DescriptionHandle = "hddfc0e25g59b8g417dgaa75g3a971bc2012c",
    },
    ActionSkillIdentify = {
        Icon = "Action_Identify",
        NameHandle = "ha3f5e4ecg662eg457fg95b5g4b37cf12028b",
        DescriptionHandle = "hc62e8bd3g4ad7g4a54g8486ga7756db3c444",
    },
    ActionSkillEndTurn = {
        Icon = "Action_EndOfTurn",
        NameHandle = "ha17c1b4bgc146g4897g8cfeg8e379b560530",
        DescriptionHandle = "h2c4c2857g4d73g4012g862agf598785f348d",
    },
}

for id,action in pairs(Stats.Actions) do
    action.ID = id
    
    Inherit(action, _Action)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Gets the data for an action.
---@param id StatsLib_Action_ID
---@return StatsLib_Action
function Stats.GetAction(id)
    return Stats.Actions[id]
end