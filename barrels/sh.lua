function MG:OnPreRoundStart()
	for _, plr in ipairs(MG.GetPlayers()) do
		plr.Team = MGT.Humans
	end
end


function MG:OnRoundStart()
	MG.HUD["state"] = "Picking barrel(s)"
	local timer = self:Timer(5, nil, true)
	if not timer:Await() then return end


	if SERVER then -- Pick a barrel
		local plrs = MG.GetPlayers()
		local barrel = plrs[math.random(#plrs)]

		MG.Print("%s is the barrel!", barrel)
		barrel.Team = MGT.Barrels
		barrel:Respawn()
	end

	MG.HUD["state"] = "Survive"
	timer = self:Timer(30, nil, true)
	if not timer:Await() then return end

	self:End(MGT.Humans)
end

function MG:OnRoundEnd(winners)
	if not winners then return end -- It's a draw
	for _, plr in pairs(winners) do
		plr:AddScore("Wins")
	end
end

function MG:OnPlayerDeath(victim, killer)
	--victim:AddScore("Deaths")
	-- Only care about kills by players
	if not killer then return end

	if victim.Team == MGT.Humans and killer.Team == MGT.Barrels then
		victim.Team = MGT.Barrels
		--killer:AddScore("Kills",{1,1})

	elseif victim.Team == MGT.Barrels and killer.Team == MGT.Humans then
		--killer:AddScore("Kills",{1,0})
	end

	if #MGT.Humans == 0 then
		self:End(MGT.Barrels)
	end
end

function MG:OnPlayerSpawn(plr)
	if plr.IsLocal and plr.Team == MGT.Barrels then
		MG.HUD["state"] = "Hunting"
	end
end