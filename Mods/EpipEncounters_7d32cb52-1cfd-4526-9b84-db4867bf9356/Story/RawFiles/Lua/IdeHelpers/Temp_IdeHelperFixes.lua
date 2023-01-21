---@diagnostic disable

--- @class Ext_Json
local Ext_Json = {}

--- @param obj string
--- @return table
function Ext_Json.Parse(obj) end

--- @param obj table
--- @return string
function Ext_Json.Stringify(obj) end

--- @class Ext_ClientEntity
local Ext_ClientEntity = {}

--- @param handle EntityHandle
--- @return IEoCClientObject
function Ext_ClientEntity.GetGameObject(handle) end

--- @alias FlashMovieClip unknown

--- @class Ext_ServerOsiris
local Ext_ServerOsiris = {}

--- @param name CString 
--- @param arity int32 
--- @param typeName CString 
--- @param handler function
function Ext_ServerOsiris.RegisterListener(name, arity, typeName, handler) end

---@param fun function
function Ext.OnNextTick(fun) end

Game = {}

--- @class UIObject
--- @field AnchorId STDString
--- @field AnchorObjectName FixedString
--- @field AnchorPos STDString
--- @field AnchorTPos STDString
--- @field AnchorTarget STDString
--- @field ChildUIHandle ComponentHandle
--- @field CustomScale float
--- @field Flags UIObjectFlags
--- @field FlashMovieSize vec2
--- @field FlashSize vec2
--- @field HasAnchorPos bool
--- @field InputFocused bool
--- @field IsDragging bool
--- @field IsDragging2 bool
--- @field IsMoving2 bool
--- @field IsUIMoving bool
--- @field Layer int32
--- @field Left float
--- @field MinSize vec2
--- @field MovieLayout int32
--- @field ParentUIHandle ComponentHandle
--- @field Path Path
--- @field PlayerId int16
--- @field RenderDataPrepared bool
--- @field RenderOrder int32
--- @field Right float
--- @field SysPanelPosition ivec2
--- @field SysPanelSize vec2
--- @field Top float
--- @field Type int32
--- @field UIObjectHandle ComponentHandle
--- @field UIScale float
--- @field UIScaling bool
--- @field CaptureExternalInterfaceCalls fun(self: UIObject)
--- @field CaptureInvokes fun(self: UIObject)
--- @field ClearCustomIcon fun(self: UIObject, element: STDWString)
--- @field Destroy fun(self: UIObject)
--- @field EnableCustomDraw fun(self: UIObject)
--- @field ExternalInterfaceCall fun(self: UIObject, method: STDString, ...)
--- @field GetHandle fun(self: UIObject):ComponentHandle
--- @field GetPlayerHandle fun(self: UIObject):ComponentHandle|nil
--- @field GetPosition fun(self: UIObject):ivec2|nil
--- @field GetRoot fun(self: UIObject)
--- @field GetTypeId fun(self: UIObject):int32
--- @field GetUIScaleMultiplier fun(self: UIObject):float
--- @field GetValue fun(self: UIObject, path: STDString, typeName: STDString|nil, arrayIndex: int32|nil):IggyInvokeDataValue|nil
--- @field GotoFrame fun(self: UIObject, frame: int32, force: bool|nil)
--- @field Invoke fun(self: UIObject, method: STDString):bool
--- @field Resize fun(self: UIObject, a1: float, a2: float, a3: float|nil)
--- @field SetCustomIcon fun(self: UIObject, element: STDWString, icon: STDString, width: int32, height: int32, materialGuid: STDString|nil)
--- @field SetPosition fun(self: UIObject, x: int32, y: int32)
--- @field SetValue fun(self: UIObject, path: STDString, value: IggyInvokeDataValue, arrayIndex: int32|nil)
local UIObject = {}

--- Hides the UI element.
--- Location: Lua/Client/ClientUI.cpp:686

function UIObject:Hide() end

--- Displays the UI element.
--- Location: Lua/Client/ClientUI.cpp:678

function UIObject:Show() end

--- @class Ext_ClientEntity
local Ext_ClientEntity = {}

---@param identifier NetId|ObjectHandle|GUID
---@return EclCharacter
function Ext_ClientEntity.GetCharacter(identifier) end

---@param entityHandle EntityHandle
---@param statusHandle EntityHandle
---@return EclStatus
function Ext_ClientEntity.GetStatus(entityHandle, statusHandle) end

--- @class Ext_Utils
--- @field RegisterUserVariable fun(a1: FixedString, a2:table)

---------------------------------------------
-- Visual
---------------------------------------------

--- @class Ext_ClientVisual
local Ext_ClientVisual = {}

--- @param position vec3 
--- @param char EclCharacter
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.CreateOnCharacter(position, char) end

--- @param position vec3 
--- @param item EclItem
--- @return EclLuaVisualClientMultiVisual
function Ext_ClientVisual.CreateOnItem(position, item) end