MG = {}
--[[
	Teams
]]
function MG.LoadTeams(t)
	MG.Teams = {}
	if t == nil then return end
	for _, data in pairs(t) do
		local idx = #MG.Teams + 1
		MG.Teams[idx] = {
			Name = data[1],
			Color = data[2],
			Plys = {}
		}
		MG.Teams[data[1]] = idx
	end
end

--[[
	Events
]]
local prefix = SERVER and "on" or "onClient"
AddEventHandler(prefix.."GameTypeStart", function(res, d)
	d = d or json.decode(GetResourceMetadata(res, "resource_type_extra", 0))
	if not d.ismg then return end
	MG.GameType = d
	-- Pretty printies
	print("Starting Minigame")
	Citizen.Trace(("'%s' by %s\n"):format(
		d.name or "Unk",
		table.concat(d.authors or {"Unk"},", ")))
	for _,line in pairs(d.desc or {}) do
		Citizen.Trace(line.."\n")
	end
	MG.LoadTeams(d.teams)
end)

AddEventHandler(prefix.."GameTypeStop", function(res)
	MG.Teams = nil
	MG.GameType = nil
	-- Some kind of graceful stop?
end)

AddEventHandler(prefix.."MapStart", function(res, d)
	d = d or json.decode(GetResourceMetadata(res, "resource_type_extra", 0))
	if CLIENT then
		exports.spawnmanager:setAutoSpawn(true)
		exports.spawnmanager:setAutoSpawnCallback(function()
			-- Reset the callback
			exports.spawnmanager:setAutoSpawnCallback(nil)
			exports.spawnmanager:spawnPlayer({
				x = 150.0, y = -751.0, z = 242.5,
				heading = 250.0, model = "a_m_y_skater_02"
			},MG.FirstSpawn)
		end)
		exports.spawnmanager:forceRespawn()
	end
end)

