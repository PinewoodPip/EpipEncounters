
---------------------------------------------
-- Holds classes related to keyboard/controller navigation systems.
---------------------------------------------

---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI.Navigation : Library
local Navigation = {}
Epip.InitializeLibrary("GenericUI.Navigation", Navigation)
Generic.Navigation = Navigation
Navigation:Debug()

---------------------------------------------
-- CLASSES
---------------------------------------------

---Mix-in class.
---@class GenericUI.Navigation.UI : GenericUI_Instance
---@field ___NavigationController GenericUI.Navigation.Controller
