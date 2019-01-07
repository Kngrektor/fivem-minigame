MG.Map = {}

local handlers = {}
AddEventHandler("getMapDirectives", function(add)
	for k,v in pairs(handlers) do
		add(k,v[1],v[2])
	end
end)

--[[
	Spawnpoints
]]

local spawns = {}
handlers["spawn"] = {
	function(s, pos, opts)
		local id = #spawns+1
		spawns[id] = {
			x = pos.x, y = pos.y,
			z = pos.z, h = pos.h,
			opts = opts
		}
		s.add("id", id)
	end,function(s)
		spawns[s.id] = nil
	end
}

function MG.Map.Spawn(team)
	local potSpawns = {}
	for _, v in pairs(spawns) do
		if not v.opts.team or v.opts.team == team:Name() then
			table.insert(potSpawns, v)
		end
	end

	if #potSpawns == 0 then
		MG.Error("No valid spawnpoint for %s", tostring(team))
	end

	return potSpawns[math.random(#potSpawns)]
end


--[[
	Triggers
]]
local triggers = {}
handlers["trigger"] = {
	function(s, shape, action, options)
		local id = #triggers+1
		triggers[id] = {
			s = MG.Util.Shapes(shape),
			act = action,
			opts = options,
			plrs = {}
		}
		s.add("id", id)
	end,
	function(s)
		triggers[s.id] = nil
	end
}

MG.Util.OnTick(function()
	for _, plr in pairs(MG.GetPlayers()) do
		for _, trig in pairs(triggers) do
			-- If inside and not marked as inside
			if plr.Alive and trig.s:IsInside(plr.Pos) then
				if not trig.plrs[plr._sid] then
					trig.plrs[plr._sid] = true
					MG.Log(1, plr.Name.." entered "..trig.act)
					MG.Hook.Trigger("TriggerEnter", trig.act, plr, trig.opts)
				end
			-- If not inside and marked as inside
			elseif trig.plrs[plr._sid] then
				trig.plrs[plr._sid] = nil
				MG.Log(1, plr.Name.." exited "..trig.act)
					MG.Hook.Trigger("TriggerExit", trig.act, plr, trig.opts)
			end
		end
	end
end)

--[[
	Triggers
		Out of bounds
]]
local timeOfDeath = nil

MG.Util.OnTick(function()
	if timeOfDeath then
		if GetGameTimer() >= timeOfDeath then
			MG.LocalPlayer.Health = 0
		end
		-- Time to live, lol
		local ttl = math.floor((timeOfDeath-GetGameTimer())/100)/10
		local msg = "~r~!!~s~ Out Of Bounds ~r~!!~s~~n~"
		msg = msg .. "Death in ~o~~h~"..ttl.."~s~ seconds"
		BeginTextCommandPrint("STRING")
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandPrint(16, true)
	end
end)

MG.Hook.Add("TriggerEnter", "mg:oob", function(plr, opts)
	if plr.IsLocal then
		timeOfDeath = GetGameTimer() + 5000
	end
end)

MG.Hook.Add("TriggerExit", "mg:oob", function(plr, opts)
	if plr.IsLocal then
		timeOfDeath = nil
	end
end)