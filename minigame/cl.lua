AddEventHandler("onClientMapStart", function()
	exports.spawnmanager:setAutoSpawn(false)
	exports.spawnmanager:setAutoSpawnCallback(function()
		local plr = MG.LocalPlayer
		local team = plr.Team
		if team and not plr:GetNetVar("mg:spectate") then
			local spawn = MG.Map.Spawn(team)
			exports.spawnmanager:spawnPlayer({
				x = spawn.x, y = spawn.y, z = spawn.z,
				heading = spawn.h or 0, model = "a_m_y_skater_02"
			},function()
				MG.Hook.TriggerServer("PlayerSpawn", plr)
			end)
		else
			exports.spawnmanager:spawnPlayer({
				x = 150.0, y = -751.0, z = 242.5,
				heading = 250.0, model = "a_m_y_skater_02"
			},function() end)
		end
	end)
	exports.spawnmanager:forceRespawn()
end)
