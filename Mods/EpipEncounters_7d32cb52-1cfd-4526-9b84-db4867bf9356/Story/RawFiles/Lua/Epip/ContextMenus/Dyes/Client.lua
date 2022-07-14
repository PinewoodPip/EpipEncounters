
---------------------------------------------
-- Context menu options for dyeing items.
---------------------------------------------

local ContextMenu = Client.UI.ContextMenu

-- Generate all context menu entries
local entries = {}
for index,data in pairs(Data.Game.DYES_ORDERED) do
    table.insert(entries, {
        id = "PIP_Dye_" .. data.ID,
        type = "button",
        text = data.Name,
        icon = data.Icon,
        eventIDOverride = "PIP_Dye",
        params = {
            ID = data.ID,
            Name = data.Name,
        },
    })
end

-- Post to server when we want to dye an item.
ContextMenu.RegisterElementListener("PIP_Dye", "buttonPressed", function(item, params)
    Net.PostToServer("EPIPENCOUNTERS_DYE", {
        Character = Client.GetCharacter().NetID,
        Item = item.NetID,
        DyeID = params.ID,
    })
end)

-- Add dye option to all equipment.
-- ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
--     if Item.IsDyeable(item) then
--         ContextMenu.AddElement({
--             {id = "epip_DyeSubMenu", type = "subMenu", text = "Dye...", subMenu = "epip_DyeMenu"},
--         })
--     end
-- end)

-- Register submenu contents.
ContextMenu.RegisterMenuHandler("epip_DyeMenu", function()

    -- Check if we own each of the dyes - disable button for unowned dyes.
    for i,entry in pairs(entries) do
        local dye = Data.Game.DYES[entry.params.ID]
        local count = Item.GetPartyTemplateCount(dye.Template)
        -- entry.text = string.format("%s (%d)", entry.params.Name, count)

        entry.faded = count == 0
        entry.selectable = count ~= 0
    end

    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_DyeMenu",
            entries = entries,
        }
    })
end)