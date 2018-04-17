--[[
	Team UI
]]
local function OpenTeamMenu()
	local btns = {}
	for _,Team in ipairs(MG.Teams) do
		-- Todo add event
		btns[#btns+1] = {
			text = Team.Name,
			col = table.concat(Team.Color,", ")
		}
	end
	btns[#btns+1] = {text = "Spectator", col = "150, 150, 150"}

	SendNUIMessage({
		btns = btns,
		info = {
			name = MG.GameType.name,
			authors = table.concat(MG.GameType.authors,", "),
			desc = table.concat(MG.GameType.desc,"\n")
		}
	})
	SetNuiFocus(true,true)
end

RegisterNUICallback("team", function(data, cb)
	SetNuiFocus(false)
	if data.button == "Spectator" then
		MGLib.LocalPly.State = MG_SPECTATING
	else
		MGLib.LocalPly.State = MG_PLAYING
		MGLib.LocalPly.Team = 
	end
	cb("ok")
end)

function MG.FirstSpawn()
	MGLib.LocalPly.State = MG_TEAM_SELECT
	OpenTeamMenu()
end