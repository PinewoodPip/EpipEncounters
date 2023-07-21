
-- Epip does not work in-editor.
if Ext.Utils.GameVersion() ~= "v3.6.51.9303" then
    for _,script in ipairs(LOAD_ORDER) do
        RequestScriptLoad(script)
    end
end