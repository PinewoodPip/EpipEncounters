
---------------------------------------------
-- Methods for parsing tooltip arrays.
-- Largely taken from Extender's Game.Tooltip,
-- copied for compatibility with mods that for some reason alter it.
---------------------------------------------

local TooltipItemIds = Game.Tooltip.TooltipItemIds
local ParseTooltipSkillProperties = Game.Tooltip.ParseTooltipSkillProperties
local ParseTooltipArmorSet = Game.Tooltip.ParseTooltipArmorSet
local TooltipSpecs = Game.Tooltip.TooltipSpecs
local ParseTooltipElement = Game.Tooltip.ParseTooltipElement

---@class TooltipLib
local Tooltip = Client.Tooltip

---------------------------------------------
-- METHODS
---------------------------------------------

---@param tt table Flash tooltip array
---@return TooltipElement[]
function Tooltip._ParseTooltipArray(tt)
	local index = 1
	local element
	local elements = {}

	while index <= #tt do
		local id = tt[index]
		index = index + 1

		if TooltipItemIds[id] == nil then
            Ext.Dump(tt)
            Ext.PrintError("[Game.Tooltip] Encountered unknown tooltip item type: ", index, id)
			return elements
		end

		local typeName = TooltipItemIds[id]
		if typeName == "SkillProperties" then
			index, element = ParseTooltipSkillProperties(tt, index)
		elseif typeName == "ArmorSet" then
			index, element = ParseTooltipArmorSet(tt, index)
		else
			local spec = TooltipSpecs[typeName]
			if spec == nil then
				Ext.PrintError("No spec available for tooltip item type: ", typeName)
				return elements
			end

			index, element = ParseTooltipElement(tt, index, spec, typeName)
			if element == nil then
				return elements
			end
		end

		table.insert(elements, element)
	end

	return elements
end