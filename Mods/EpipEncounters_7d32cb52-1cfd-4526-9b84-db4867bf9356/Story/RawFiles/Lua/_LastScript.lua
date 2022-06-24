
---------------------------------------------
-- Script for registering events that must run after all others.
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    for i,lib in ipairs(Epip._FeatureRegistrationOrder) do
        if lib.IsEnabled ~= nil and lib:IsEnabled() then -- TODO move everything to lib system
            lib:__Setup()
        end
    end
end)