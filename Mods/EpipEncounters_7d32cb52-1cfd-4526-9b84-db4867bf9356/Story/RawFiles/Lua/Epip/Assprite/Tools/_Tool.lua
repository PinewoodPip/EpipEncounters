
---------------------------------------------
-- Base class for Assprite tools that modify the canvas on cursor interactions.
---------------------------------------------
---@meta

local Assprite = Epip.GetFeature("Features.Assprite")
local Input = Client.Input

---@class Features.Assprite.Tool : Class
---@field ICON icon
---@field Name TextLib.String
---@field Description TextLib.String
local Tool = {}
Assprite:RegisterClass("Features.Assprite.Tool", Tool)

---------------------------------------------
-- METHODS
---------------------------------------------

---Called when the tool begins being used on the canvas.
---@virtual
---@param context Features.Assprite.Context
---@return boolean -- Whether the tool affected the image in any way.
---@diagnostic disable-next-line: unused-local
function Tool:OnUseStarted(context)
    return false
end

---Called when the cursor position changes while the tool is being used.
---@virtual
---@param context Features.Assprite.Context
---@return boolean -- Whether the tool affected the image in any way.
---@diagnostic disable-next-line: unused-local
function Tool:OnCursorChanged(context)
    return false
end

---Called when the tool ends being used on the canvas.
---@virtual
---@param context Features.Assprite.Context
---@return boolean -- Whether the tool affected the image in any way.
---@diagnostic disable-next-line: unused-local
function Tool:OnUseEnded(context)
    return false
end

---Returns the settings related to the tool.
---@virtual
---@return SettingsLib_Setting[]
function Tool:GetSettings()
    return EMPTY
end

---Returns the primary keybind for the tool.
---@return InputLib_Action_KeyCombination?
function Tool:GetKeybind()
    local action = Assprite.InputActions[self:GetClassName() .. ".Apply"]
    if not action then return nil end -- The tool might have no input action.
    local bindings = Input.GetActionBindings(action.ID)
    return bindings[1]
end

---Registers the input action to select the tool in the UI.
---@param defaultKeys InputLib_Action_KeyCombination
function Tool:__RegisterInputAction(defaultKeys)
    local action = Assprite:RegisterInputAction(self:GetClassName() .. ".Apply", {
        Name = Assprite.TranslatedStrings.Label_SelectTool:Format(self.Name:GetString()),
        DefaultInput1 = defaultKeys,
    })

    -- Bruh doing this here is so fucking dirty lmao TODO
    Input.Events.ActionExecuted:Subscribe(function (ev)
        if ev.Action == action then
            Assprite.UI.SelectTool(self)
        end
    end, {EnabledFunctor = function ()
        return Assprite.UI:IsVisible()
    end})
end
