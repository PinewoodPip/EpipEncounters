
---------------------------------------------
-- Base class for Assprite tools that modify the canvas on cursor interactions.
---------------------------------------------
---@meta

local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tool : Class
---@field ICON icon
---@field Name TextLib.String
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
