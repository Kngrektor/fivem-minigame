--[[
	Team Meta
]]
local meta = {}
meta.__index = meta
MG.Metas.Team = meta

 --[[
	Team Meta
		Loading, Contructor & Constants
]]
local teams = {}
MG.Hook.Add("Start",function(res, map)
	if HOST then
		MG.Log(1, "Setting up teams!")
	end
	teams = MG.GameType.teams
	for i, team in ipairs(teams) do
		team.id = i
		team.name = team.name or team[1] or "?????"
		team.col = team.col or team[2] or {255, 0, 127}
		team.internal = team.internal or false
		team.plrs = {}
		teams[team.name] = team
		if HOST then
			MG.Log(2, "  Added Team(%d,'%s')", i, team.name)
		end
	end
end)


function MG.GetTeam(tid)
	tid = tonumber(tid) or tid
	tid = teams[tid] and teams[tid].id -- Make sure it's id and not name
	if not teams[tid] then
		MG.Error("Err: Team %s(%s) doesn't exist",type(tid),tostring(tid))
	end
	return setmetatable({
		_id = tid,
	},meta)
end

function MG.GetTeams()
	local ts = {}

	for _, v in ipairs(teams) do
		ts[#ts + 1] = v
	end

	return ts
end

-- MGT.Alien_Warrior = MG.GetTeam("Alien Warrior")
MGT = setmetatable({},{
	__index = function(self, team)
		return MG.GetTeam(team:gsub("_"," "))
	end
})

--[[
	Team Meta
		Serialization
]]
function meta.Deserialize(tid)
	return MG.GetTeam(tid)
end
function meta:Serialize()
	return self._id
end

--[[
	Team Meta
		Set & Sync
]]

function meta:Add(plr)
	plr.Team = self
end
function meta:Remove(plr)
	plr.Team = nil
end

-- plr.Team
MG.Metas.Player._addProp("Team",function(self)
	local tid = self:GetNetVar("mg:team", 0)
	return tid > 0 and MG.GetTeam(tid) or nil
end, function(self, v)
	if self:GetNetVar("mg:team") ~= v._id then
		self:SetNetVar("mg:team", v._id)
	end
end)

MG.Hook.Add(function(ev, var, plr, old, new)
	if ev == "NetVarChanged" and var == "mg:team" then
		old = old and old > 0 and old or nil
		new = new and new > 0 and new or nil
		if old and not new then
			teams[old][plr._sid] = nil
		end
		if not old and new then
			teams[new][plr._sid] = true
		end
	end
end)


--[[
	Team Meta
		Meta
]]
function meta:GetPlayers()
	local out = {}
	for _, plr in pairs(teams[self._id].plrs) do
		table.insert(out, plr)
	end
	return out
end

function meta:__len()
	return #self:GetPlayers()
end

function meta:__eq(other)
	return self._id == other._id
end

function meta:__pairs()
	return pairs(teams[self._id].plrs)
end

function meta:__tostring()
	return "Team("..self._id..",'"..self:Name().."')"
end

function meta:Name()
	return teams[self._id].name
end

function meta:GetColor()
	return teams[self._id].color
end