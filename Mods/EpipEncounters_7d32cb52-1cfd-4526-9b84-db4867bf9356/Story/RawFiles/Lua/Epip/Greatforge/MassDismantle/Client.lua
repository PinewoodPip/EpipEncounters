
local ContextMenu = Client.UI.ContextMenu

---@class Feature_MassDismantle
local MassDismantle = Epip.GetFeature("Feature_MassDismantle")
MassDismantle.CONTEXT_MENU_BUTTON_ID = "Epip_Feature_MassDismantle"

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    -- Only show this option if the container has at least one piece of equipment
    local equipment = MassDismantle.GetEligibleItems(item)
    if #equipment > 0 then
        ContextMenu.AddElements(nil, {
            id = "main",
            entries = {
                {
                    id = MassDismantle.CONTEXT_MENU_BUTTON_ID,
                    type = "button",
                    text = MassDismantle.TranslatedStrings.ContextMenuButtonLabel:GetString(),
                },
            },
        }) 
    end
end)

-- Listen for the mass dismantle button being pressed and forward requests to the server.
ContextMenu.RegisterElementListener(MassDismantle.CONTEXT_MENU_BUTTON_ID, "buttonPressed", function(item)
    Net.PostToServer(MassDismantle.REQUEST_NET_MSG, {
        CharacterNetID = Client.GetCharacter().NetID,
        ItemNetID = item.NetID,
    })
end)