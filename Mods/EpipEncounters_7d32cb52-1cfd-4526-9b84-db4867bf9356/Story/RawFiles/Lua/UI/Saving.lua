---------------------------------------------
-- Hooks for saving.swf
---------------------------------------------

local Saving = {}
Epip.InitializeUI(Ext.UI.TypeID.saving, "Saving", Saving)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Fire events when saving starts/ends
Saving:RegisterInvokeListener("showSavingAnim", function(ev)
    local visible = ev.Args[1]

    if visible then
        Saving:FireEvent("SavingStarted")
    else
        Saving:FireEvent("SavingFinished")
    end
end)