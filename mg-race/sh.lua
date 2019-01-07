--[[
	Checkpoints
]]
local current = 0
AddEventHandler("getMapDirectives", function(add)
	add("waypoint",v[1],v[2])
end)

function MG:OnRoundStart()
	MG.HUD["lights"] = "red"
	MG.HUD["state"] = "lights"
	if not self:Timer(3):Await() then return end
	MG.HUD["lights"] = "first"
	if not self:Timer(1):Await() then return end
	MG.HUD["lights"] = "first second"
	if not self:Timer(1):Await() then return end
	MG.HUD["lights"] = "first second third"
	MG.HUD["state"] = "race"

	timer = self:Timer(60, nil, true)
	if not timer:Await() then return end

	self:End()
end

function MG:OnRoundEnd(winners) end

function MG:OnPlayerDeath(victim, killer)
end

function MG:OnPlayerSpawn(plr)
	if plr.IsLocal then

	end
end