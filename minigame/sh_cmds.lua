if CLIENT then
	RegisterCommand("mg_team_join", function(s, as, raw)
		local t = MG.GetTeam(tonumber(as[1]) or as[1])
		MG.Print("Joining %s", tostring(t))
		MG.LocalPlayer.Team = t
	end)
	RegisterCommand("mg_kill", function(s, as, raw)
		MG.LocalPlayer.Health = 0
	end)

	RegisterCommand("mg_respawn", function(s, as, raw)
		MG.LocalPlayer:Respawn()
	end)

	RegisterCommand("mg_getpos",function()
		local plr = MG.LocalPlayer
		local str = "pos=%s\nhead=%s\nforward=%s"
		str = str:format(plr.Pos, plr.Heading, plr.Forward)
		MG.Print(str)
	end)
end