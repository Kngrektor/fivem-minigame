local GM = {}
GM.Name = "Suicide Barrels"
GM.Authors = {"Kng"}
GM.Teams = {
	Humans  = {
		Color = vector3(55, 212, 100),
		Spawn = function(ply)
			if not CLIENT then return end
			ply:GiveWeapon("barrels_gun")
		end
	},
	Barrels = {
		Color = vector3(255, 95, 74),
		Spawn = function(ply)
			if not CLIENT then return end
			Barrelify(ply)
		end
	}
}

GM.Scores = {
	Wins     = 0,
	Kills    = {"%d (%d)",{0,0}},
	Deaths   = 0,
	Suicides = 0
}

function GM:OnRoundStart()
	self:TimeLimit(150,"Humans")
end

function GM:OnRoundEnd(winners)
	for _, ply in ipairs(winners.Plys) do
		ply:AddScore("Wins")
	end
end

function GM:OnPlayerDeath(ply, killer)
	ply:AddScore("Deaths")
	-- Only care about kills by players
	if not killer then return end

	if ply:Team() == "Humans" and killer:Team() == "Barrels" then
		ply:SetTeam("Barrels")
		killer:AddScore("Kills",{1,1})

	elseif ply:Team() == "Barrels" and killer:Team() == "Humans" then
		killer:AddScore("Kills",{1,0})
	end

	if #Teams.Humans.Plys == 0 then
		self:End("Barrels")
	end
end

--Minigames.Register(function() return GM end)