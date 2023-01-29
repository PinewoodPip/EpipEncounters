
local Shortcuts = Epip.GetFeature("Feature_AscensionShortcuts")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to pop the UI page.
Net.RegisterListener(Shortcuts.POP_PAGE_NET_MSG, function(payload)
    local char = Character.Get(payload.CharacterNetID)
    local instance, ui, _ = Osiris.DB_AMER_UI_UsersInUI(nil, nil, char.MyGuid)

    if instance ~= nil then
        local _, stackCount = Osiris.DB_AMER_UI_PageStack_Count(instance, nil)

        -- Pop page if there are any. We don't call the method directly as there are some special listeners for it to manipulate the stack in the Greatforge UI.
        if stackCount and stackCount > 0 and ui ~= "AMER_UI_ModSettings" then
            Osi.CharacterItemEvent(char.MyGuid, NULLGUID, "AMER_UI_GEN_PagePop")
        else -- Exit UI otherwise
            Osi.PROC_AMER_UI_ExitUI(char.MyGuid)
        end
    end
end)