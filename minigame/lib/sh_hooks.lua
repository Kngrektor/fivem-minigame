--[[
	Just a wrappie around events for (de)serialization
	todo: improve & genericize
]]
MG.Hook = {}
local currentGametype -- ew
local prefix = "mg:"
--[[
	Callbacks
		These are built recursively in such a way that
		MG.Hook.Add("TriggerEnter","mb:oob",function(plr)
			MG.Print("%s is out of bounds :/", plr)
		end)
		is the same as
		MG.Hook.Add(function(event, trigger, plr)
			if event == "TriggerEnter" and trigger == "mg:oob" then
				MG.Print("%s is out of bounds :/", plr)
			end
		end)
]]
do
	local callbacks = {}

	function MG.Hook.Add(...)
		local cbs = callbacks
		for _, arg in pairs({...}) do
			if type(arg) == "function" then
				return table.insert(cbs, arg)
			else
				cbs[arg] = cbs[arg] or {}
				cbs = cbs[arg]
			end
		end
	end

	function MG.Hook.Exec(cbs, arg, ...)
		if type(cbs) ~= "table" then -- This is kinda egh
			return MG.Hook.Exec(callbacks, cbs, arg, ...)
		end

		for _, cb in ipairs(cbs) do -- Callbacks are array-y
			if cb(arg, ...) then
				return true
			end
		end

		local tbl = type(arg) == "string" and cbs[arg]
		if type(tbl) == "table" then
			return MG.Hook.Exec(tbl, ...)
		end
	end
end

--[[
	Add all events
	Flags:
		rep    - Replicate
			Calling the event on the server calls it on all clients
		svnet  - Server net event
			Allows for cl -> sv communication
		clnet  - Client net event
			Allows for sv -> cl communication
		source - Use source, prevent spoofing
			A svnet listener uses source instead of first "Player"
		cltoall - cl -> sv -> every cl
			Basically autogenerates a listener that just broadcasts it
]]
local events = {}
do
	local function event(flags)
		return function(name)
			return function(metas)
				for _,v in ipairs(flags) do
					flags[v] = true
				end

				if CLIENT and (flags["clnet"] or flags["rep"]) then
					RegisterNetEvent(prefix..name)
				end
				if SERVER and (flags["svnet"]) then
					RegisterNetEvent(prefix..name)
				end
				if flags["cltoall"] then
					RegisterNetEvent(prefix..name)
					if SVHOST then
						MG.Hook.Add(name, function(...)
							MG.Hook.TriggerClient(name, -1, ...)
						end)
					end
				end

				events[name] = {
					flags = flags,
					metas = metas
				}
			end
		end
	end

	event {} "Start" {}
	event {} "Stop"  {}

	event {"cltoall","source"} "PlayerDeath" {"Player"}
	event {"cltoall","source"} "PlayerSpawn" {"Player"}
	--event {"cltoall","source"} "PlayerJoinTeam" {"plr"},

	event {}      "PreventRoundStart" {}
	event {"rep"} "PreRoundStart"     {}
	event {"rep"} "RoundStart"        {}
	event {"rep"} "RoundEnd"          {"Team"}
	event {"rep"} "PostRoundEnd"      {}

	event {}      "TriggerEnter"  {nil, "Player"}
	event {}      "TriggerExit"   {nil, "Player"}
	event {"rep"} "NetVarChanged" {nil, "Player"}
	event {}      "HudUpdateVar"  {}
end

--[[
	Execution
]]
function MG.Hook.Call(event, ...)
	local evData = events[event]
	local args = {...}

	MG.Log(3,"Calling hook '%s'", event)
	-- Conversion
	local convSource = SERVER and tonumber(source) and evData.flags["source"]
	for i, meta in pairs(evData.metas) do
		if convSource and meta == "Player" then
			args[i] = MG.GetPlayer(source)
			convSource = false
		else
			args[i] = args[i] and MG.Metas[meta].Deserialize(args[i])
		end
	end

	if MG.Hook.Exec(event, table.unpack(args)) then
		CancelEvent()
	end

	if MG.GameType and MG.GameType.res == RESOURCE and MG["On"..event] then
		if MG["On"..event](table.unpack(args)) then
			CancelEvent()
		end
	end
end

local function processArgs(evData, ...)
	local args = {...}
	for i, meta in pairs(evData.metas) do
		args[i] = args[i] and MG.Metas[meta].Serialize(args[i])
	end
	return table.unpack(args)
end

function MG.Hook.Trigger(event, ...)
	local evData = events[event]
	local args = {processArgs(evData, ...)}

	TriggerEvent(prefix..event, table.unpack(args))
	if SERVER and evData.flags["rep"] then
		TriggerClientEvent(prefix..event, -1, table.unpack(args))
	end
end

function MG.Hook.TriggerServer(event, ...)
	local evData = events[event]
	if SERVER then return end

	if not (evData.flags["svnet"] or evData.flags["cltoall"]) then
		MG.Error("Can't trigger a event without the 'svnet' flag on a server")
	end

	TriggerServerEvent(prefix..event, processArgs(evData, ...))
end

function MG.Hook.TriggerClient(event, sid, ...)
	local evData = events[event]
	if CLIENT then return end

	if evData.flags["clnet"] then
		MG.Error("Can't trigger a event without the 'clnet' flag on a client")
	end

	TriggerClientEvent(prefix..event, sid, processArgs(evData, ...))
end

function MG.Hook.TriggerNet(event, ...)
	if SERVER then
		MG.Hook.TriggerClient(event, -1, ...)
	else
		MG.Hook.TriggerServer(event, ...)
	end
end



--[[
	Initialization
]]
for evName, _ in pairs(events) do
	AddEventHandler(prefix..evName, function(...)
		MG.Hook.Call(evName, ...)
	end)
end

MG.Hook.Add("Start",function(res, map)
	MG.GameType = MG.GamemodeInfo(res, true)
end)

MG.Hook.Add("Stop", function()
	MG.GameType = nil
end)