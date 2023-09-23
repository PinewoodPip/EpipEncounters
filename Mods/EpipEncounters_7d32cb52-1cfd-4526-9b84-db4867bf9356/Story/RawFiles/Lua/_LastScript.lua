
---------------------------------------------
-- Script for registering events that must run after all others.
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    for _,lib in ipairs(Epip._FeatureRegistrationOrder) do
        if lib.IsEnabled ~= nil and lib:IsEnabled() then -- TODO move everything to lib system
            local success, msg = pcall(function ()
                lib:__Setup()

                if lib:IsDebug() and Epip.IsDeveloperMode(true) then
                    Timer.Start(2, function (_)
                        lib:__Test()
                    end)
                end
            end)
            if not success then
                Ext.Utils.PrintError("Error during _LastScript:", msg)
            end
        end
    end
end)