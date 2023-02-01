
---------------------------------------------
-- Displays resistances at the bottom of the
-- enemy health bar, or AP/SP/Init info if shift is held.
-- Additionally, moves the level display to the header.
---------------------------------------------

local EnemyHealthBar = Client.UI.EnemyHealthBar

---@type Feature
local ExtraInfo = {
    -- These are not the 'official' colors,
    -- they're lightly modified for readability.
    RESISTANCE_COLORS = {
        Fire = "f77c27",
        Water = "27aff6",
        Earth = "aa7840",
        Air = "8f83cb",
        Poison = "5bd42b",
        Physical = "acacac",
        Piercing = "c23c3c",
        Shadow = "5b34ca",
    },
    RESISTANCES_DISPLAYED = {
        "Fire", "Water", "Earth", "Air", "Poison", "Physical", "Piercing",
    },
}
Epip.RegisterFeature("EnemyHealthBarExtraInfo", ExtraInfo)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set bottom text of the bar.
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    if ExtraInfo:IsEnabled() then
        -- Show resistances for chars, or alternative info if shift is being held.
        local char, item = ev.Character, ev.Item
        local text = ""

        if char then
            if Client.Input.IsShiftPressed() then -- Show alternate info.
                local level = Character.GetLevel(char)
                local sp, maxSp = Character.GetSourcePoints(char)
                local ap, maxAp = Character.GetActionPoints(char)
                local init = Character.GetInitiative(char)
    
                if maxSp == -1 then
                    maxSp = 3
                end
    
                text = string.format("Level %s  %s/%s AP  %s/%s SP  %s INIT", level, ap, maxAp, sp, maxSp, init)
            else -- Show resistances.
                local resistances = {}
    
                for _,resistanceId in ipairs(ExtraInfo.RESISTANCES_DISPLAYED) do
                    local amount = Character.GetResistance(char, resistanceId)
                    local color = ExtraInfo.RESISTANCE_COLORS[resistanceId]
                    local display = Text.Format("%s%%", {
                        Color = color,
                        FormatArgs = {
                            amount,
                        },
                    })
    
                    table.insert(resistances, display)
                end

                -- Insert some padding at the start
                text = " " .. Text.Join(resistances, "  ")
            end
        elseif item and item.Stats then -- Show item level.
            text = string.format("Level %s", item.Stats.Level)
        end
    
        -- Make text smaller.
        text = Text.Format(text, {Size = 14.5})
    
        table.insert(ev.Labels, text)
    end
end)


-- Display level by character name and hide it from the footer.
EnemyHealthBar.Hooks.GetHeader:Subscribe(function (ev)
    if ExtraInfo:IsEnabled() then
        local char, item = ev.Character, ev.Item
        local level = (char and Character.GetLevel(char)) or (item and Item.GetLevel(item))
    
        if level then
            ev.Header = string.format("%s - Lvl %s", ev.Header, level)
        end
    end
end)
EnemyHealthBar.Hooks.GetBottomLabel:Subscribe(function (ev)
    if ExtraInfo:IsEnabled() then
        table.remove(ev.Labels, 1)
    end
end, {Priority = -9999999})