local function notify(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

MG.Hook.Add("Start",function(res, map)
	Citizen.Wait(1000)
	notify("Loaded minigame "..MG.GameType.name)
	for _, team in pairs(MG.GetTeams()) do
		notify('/mg_team_join "'..team.name..'"')
	end
end)

MG.Hook.Add("RoundStart",function()
	notify("New round started")
end)

MG.Hook.Add("PlayerDeath",function(plr)
	notify((plr.Name or "?").." died")
end)

MG.Hook.Add("RoundEnd",function(winners)
	if winners then
		notify(winners:Name().." won the round!")
	else
		notify("Round ended in a draw!")
	end
end)