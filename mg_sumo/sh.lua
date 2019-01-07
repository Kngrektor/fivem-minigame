local mdl = "dune4"
local redDeaths = 0
local blueDeaths = 0
local warmup = false
local veh

function MG.OnStart()
	if CLIENT then
		RequestModel(mdl) -- I'm lazy
	end
end


local cleanupZones = {}
AddEventHandler("getMapDirectives", function(add)
	add("cleanup",function(s, shape)
		local id = #cleanupZones + 1
		cleanupZones[id] = MG.Util.Shapes(shape)
		s.add("id", id)
	end,function(s)
		cleanupZones[s.id] = nil
	end)
end)

function MG.OnPreRoundStart()
	warmup = true
	if CLIENT then
		for v in MG.Util.GetVehicles() do
			for _, shape in pairs(cleanupZones) do
				if shape:IsInside(GetEntityCoords(v)) then
					DeleteEntity(v)
				end
			end
		end
	end
end

function MG.OnRoundStart()
	local timer = MG.Round.Timer(5, true)
	if not timer then return end
	if not timer:Await() then return end
	warmup = false

	redDeaths = 0
	blueDeaths = 0

	if CLIENT and veh then
		FreezeEntityPosition(veh, false)
	end


	timer = MG.Round.Timer(60*3, true)
	if not timer then return end
	if not timer:Await() then return end

	MG.Round.End()
end

function MG.OnPlayerSpawn(plr)
	if not CLIENT then return end
	if not plr.IsLocal then return end
	if veh then -- wtf?
		DeleteEntity(veh)
	end
	veh = CreateVehicle(mdl, plr.Pos, plr.Heading, true, false)
	SetEntityAsNoLongerNeeded(veh)
	SetPedIntoVehicle(plr.Ped, veh, -1)
	SetVehicleDoorsLocked(veh, 4)
	SetVehicleNumberPlateText(veh, "SUMO")
	SetVehicleEngineOn(veh, true, false, false)
	-- Speed
	SetVehicleEnginePowerMultiplier(veh, 20)
	SetVehicleEngineTorqueMultiplier(veh, 20)
	-- Don't actually break
	SetEntityProofs(veh, true, true, true, true, true, true, true, true)
	SetVehicleEngineCanDegrade(veh, false)
	SetVehicleCanBreak(veh, false)
	SetVehicleHasStrongAxles(veh, true)
	SetVehicleWheelsCanBreak(veh, false)
	SetVehicleHandbrake(veh, false)
	-- Team colors
	if plr.Team == MGT.Red then
		SetVehicleColours(veh, 35, 135)
	else
		SetVehicleColours(veh, 64, 70)
	end

	if warmup then
		FreezeEntityPosition(veh, true)
	end
end

--
local function shouldEnd()
	local red = 0
	for _, plr in pairs(MGT.Red) do
		if plr.Alive then red = red + 1 end
	end

	local blue = 0
	for _, plr in pairs(MGT.Blue) do
		if plr.Alive then blue = blue + 1 end
	end

	if red + blue == 0 then
		MG.Round.End()
	elseif red == 0 then
		MG.Round.End(MGT.Blue)
	elseif blue == 0 then
		MG.Round.End(MGT.Red)
	end
end

function MG.OnPlayerDeath(victim, killer)
	if not SERVER then return end
	if warmup then
		return victim:Respawn()
	end
	-- Make the victim a spectator
	shouldEnd()
end


MG.Hook.Add("NetVarChanged","mg:team",function(plr, old, new)
	if not SERVER then return end
	if warmup and new then
		plr:Respawn()
	else
		shouldEnd() -- Try to end so this guy gets to play
	end
end)

MG.Hook.Add("TriggerEnter","sumo:death",function(plr)
	if plr.IsLocal then
		local veh = GetVehiclePedIsIn(plr.Ped, false)
		if veh then
			NetworkExplodeVehicle(veh, true, true, false)
		end
		plr:Kill()
		plr:SetNetVar("mg:spectate", true)
	end
end)