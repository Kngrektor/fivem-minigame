SERVER = IsDuplicityVersion()
CLIENT = not SERVER
RESOURCE = GetCurrentResourceName()
-- Used for proper serverside propagation
HOST = RESOURCE == "minigame"
SVHOST = SERVER and HOST
CLHOST = CLIENT and HOST

MG = { Metas = {} }

MG_NONE = -1
MG_LOBBY = 0
MG_PLAYING = 1

--[[
	Resource Management
		Gamemode Utilities
]]
function MG.GamemodeInfo(res, full)
	local data = GetResourceMetadata(res,"resource_type_extra",0)
	data = json.decode(data or "")

	if not data.ismg then return nil end
	data.res = res

	return full and data or {
		name = data.name,
		authors = data.authors,
		desc = data.desc,
		res = res
	}
end

--[[
	Library loading
]]
local function loadFile(file)
	local code = LoadResourceFile("minigame",file)
	local prefix = "[MG/"..RESOURCE.."] "
	if not code then
		print(prefix.."ERROR: Failed to load '"..file.."'")
		print(prefix.." This will probably end horribly")
		return
	end

	local f, err = load(code, ""..RESOURCE.."@MG/"..file)
	if not f then
		print(prefix.."ERROR: Failed to parse '"..file.."'")
		print(prefix.." "..err)
		print(prefix.." This will probably end horribly")
		return
	end

	local isok -- luacheck complains if I shadow err
	isok, err = pcall(f)
	if not isok then
		print(prefix.."ERROR: Failed to run '"..file.."'")
		print(prefix.." "..err)
		print(prefix.." This will probably end horribly")
		return
	end
end
loadFile("lib/sh_util.lua")
loadFile("lib/sh_hooks.lua")
loadFile("lib/sh_plr.lua")
loadFile("lib/sh_plr_nvs.lua")
loadFile("lib/sh_plr_spectate.lua")
loadFile("lib/sh_team.lua")
loadFile("lib/sh_hud.lua")
loadFile("lib/sh_round.lua")