SERVER = IsDuplicityVersion()
CLIENT = not SERVER

MGLib = {}
--[[
	Player "Class"
]]
local PlyMeta = { Props = {} }
MGLib.Plys = setmetatable({},{
	__newindex = function() end,
	__index = function(self, _sid)
		return setmetatable({
			_sid = _sid
		},PlyMeta)
	end
})
if CLIENT then
	MGLib.LocalPly = MGLib.Plys[GetPlayerServerId(PlayerId(-1))]
end

function PlyMeta:__index(key)
	local Prop = PlyMeta.Props[key]
	if not Prop then return rawget(self, PlyMeta) end
	if not Prop.Get then return end
	return Prop.Get(self)
end

function PlyMeta:__newindex(key, val) -- Never 
	local Prop = PlyMeta.Props[key]
	if not Prop then
		print("Tried to set invalid property "..key.." on "..tostring(self))
	end
	if not Prop.Set then
		print("Tried to set readonly property "..key.." on "..tostring(self))
	end
	return Prop.Set(self, val)
end


PlyMeta.Props.IsLocal = {}
function PlyMeta.Props.IsLocal:Get()
	if SERVER then return end -- Server has no local
	return GetPlayerServerId(PlayerId()) == self._sid
end

--[[
	Player "Class"
		State
]]
MG_SPECTATING = -2
MG_TEAM_SELECT = -1
MG_UNK = 0
MG_PLAYING = 1
local States = {} -- Actual storage

PlyMeta.Props.State = {}
function PlyMeta.Props.State:Get()
	return States[self._sid]
end
function PlyMeta.Props.State:Set(State)
	States[self._sid] = State
	if SERVER then
		TriggerClientEvent("mg:_updPlyState", -1, SId, State)
	elseif self.IsLocal then
		TriggerServerEvent("mg:_updPlyState", State)
	end
end

RegisterNetEvent("mg:_updPlyState")
AddEventHandler("mg:_updPlyState",function(SId,State)
	if SERVER then
		SId, State = source, SId
		TriggerClientEvent("mg:_updPlyState", -1, SId, State)
	end
	States[SId] = State
end)

--[[
	Team Class
]]
local TeamMeta = {}


local prefix = SERVER and "on" or "onClient"
AddEventHandler(prefix.."GameTypeStart", function(res, d)
	d = d or json.decode(GetResourceMetadata(res, "resource_type_extra", 0))
	MGLib.Teams = {}
	if d == nil then return end
	for _, data in pairs(d) do
		local idx = #MGLib.Teams + 1
		MGLib.Teams[idx] = {
			Name = data[1],
			Color = data[2],
			Plys = {}
		}
		MGLib.Teams[data[1]]  = idx
		_G["MGT_"..data[1]] = idx
	end
end)