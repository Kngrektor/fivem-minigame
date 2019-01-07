--[[
	Player Meta
]]
local meta = { _props = {} }
MG.Metas.Player = meta

--[[
	Player Meta
		Constructor & Constants
]]
function MG.GetPlayer(sid)
	sid = tonumber(sid) or sid -- This is a kinda meh solution
	MG.ArgCheck("MG.GetPlayer", {"number"}, 1, sid)
	return setmetatable({
		_sid = sid,
		_pid = CLIENT and GetPlayerFromServerId(sid),
		IsLocal = CLIENT and sid == GetPlayerServerId(PlayerId())
	},meta)
end

function MG.GetPlayerByPed(ped, all)
	for _, plr in pairs(MG.GetPlayers(all)) do
		if plr.Ped == ped then
			return plr
		end
	end
end

function MG.GetPlayers(all)
	local plrs = {}

	local function addPlr(sid)
		local plr = MG.GetPlayer(sid)
		if all or plr.Team then
			table.insert(plrs, plr)
		end
	end

	if SERVER then
		for _, sid in pairs(GetPlayers()) do
			addPlr(sid)
		end
	else
		for i = 0,64 do
			if NetworkIsPlayerConnected(i) and NetworkIsPlayerActive(i) then
				addPlr(GetPlayerServerId(i))
			end
		end
	end

	return plrs
end

if CLIENT then
	MG.LocalSid = GetPlayerServerId(PlayerId())
	MG.LocalPlayer = MG.GetPlayer(MG.LocalSid)
end

--[[
	Player Meta
		Basics
]]
function meta:__eq(other)
	return type(self) == "table"
	   and type(self._sid) == "number"
	   and type(other) == "table"
	   and type(other._sid) == "number"
	   and self._sid == other._sid
end

function meta:__index(key)
	return meta[key] and meta[key] or self:GetProp(key)
end

function meta:__newindex(key, val)
	self:SetProp(key, val)
end

function meta:__tostring()
	return "Player("..self._sid..",'"..tostring(self.Name).."')"
end

--[[
	Player Meta
		Serialization
]]
function meta.Deserialize(sid)
	return MG.GetPlayer(sid)
end
function meta.Serialize(plr)
	return plr._sid
end

--[[
	Player Meta
		Properties
]]
function meta:SetProp(prop, val)
	local p = meta._props[prop]
	if not p or not p.Set then
		local str = " property "..prop.." on "..tostring(self)
		error("Tried to set "..(p and "readonly" or "invalid")..str,3)
	end

	return p.Set(self, val)
end

function meta:GetProp(prop)
	local p = meta._props[prop]
	if not p or not p.Get then
		local str = " property "..prop.." on "..tostring(self)
		error("Tried to get "..(p and "writeonly" or "invalid")..str,3)
	end

	return p.Get(self)
end

local function addProp(prop,get,set)
	meta._props[prop] = {
		Get = get,
		Set = set
	}
end
meta._addProp = addProp
local function addPedProp(prop,get,set)
	if SERVER then return end
	addProp(prop,
		get and function(self) return get(self.Ped) end,
		set and function(self,v) return set(self.Ped,v) end)
end

--[[
	Player Meta
		Properties
			Misc
]]
addProp("Name",function(self)
	return GetPlayerName(SERVER and self._sid or self._pid)
end)

if CLIENT then
	addProp("Ped",function(self)
		return GetPlayerPed(self._pid)
	end)
	addProp("Alive", function(self)
		return not IsPedFatallyInjured(self.Ped) and not self:GetNetVar("mg:spectate")
	end)

	addProp("Frozen", nil, function(self, freeze)
		FreezeEntityPosition(self.Ped, freeze)
		SetPlayerInvincible(player, freeze)
	end)
end
-- Still client only
addPedProp("Pos", GetEntityCoords)
addPedProp("Heading", GetEntityHeading)
addPedProp("Forward", GetEntityForwardVector)
addPedProp("Health", GetEntityHealth, SetEntityHealth)
addPedProp("MaxHealth", GetEntityMaxHealth, SetEntityMaxHealth)

--[[
	Player Meta
		Methods
]]
-- These things are because I'm lazy
-- and should probably be improved.
-- Maybe 1s will make these "native" to sv? :O
local clMeta = setmetatable({},{
	__newindex = function(self, k, v)
		if SERVER then return end
		meta[k] = v
	end
})
local function clToSv(name)
	local ev = "mg:__plrMeta"..name
	if CLIENT then
		RegisterNetEvent(ev)
		AddEventHandler(ev, function(...)
			meta[name](MG.LocalPlayer,...)
		end)
	else
		meta[name] = function(self, ...)
			TriggerClientEvent(ev, self._sid, ...)
		end
	end
end

function clMeta:Respawn()
	if self.IsLocal then
		exports.spawnmanager:forceRespawn()
		self.Health = self.MaxHealth
	end
end
clToSv("Respawn")

function meta:Kill()
	self.Health = 0
end
clToSv("Kill")


if not CLHOST then return end

-- This code is based on deathevents.lua
-- and skips a lot of extra sanity checks
-- so it might crash and burn horribly,
-- please don't use it as a reference
local last = false

MG.Util.OnTick(function()
	local plr = MG.LocalPlayer
	local dead = IsPedFatallyInjured(plr.Ped)
	if dead and not last then
		last = true
		if not plr.Team then return end
		local killer = NetworkGetEntityKillerOfPlayer(plr._pid)
		killer = killer and MG.GetPlayerByPed(killer)
		MG.Hook.TriggerServer("PlayerDeath",plr,killer)
	elseif not dead and last then
		last = false
	end
end)