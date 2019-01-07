--[[
	Events
]]
local prefix = SERVER and "on" or "onClient"
AddEventHandler(prefix.."GameTypeStart", function(res)
	local info = MG.GamemodeInfo(res, true)
	if not info then
		MG.Print("Hey that's not a minigame you half inbread fucktard")
	end
	-- Pretty printies
	MG.Print("Starting Minigame\n")
	MG.Print(("'%s' by %s"):format(
		info.name or "Unk",
		table.concat(info.authors or {"Unk"},", ")))
	for _,line in pairs(info.desc or {}) do
		MG.Print(line)
	end
	print()

	TriggerEvent("mg:Start", res, "Lol that's not a map!")

	if CLIENT then
		--MG.UI.TeamSelect()
	end
end)