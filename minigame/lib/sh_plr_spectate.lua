-- Make this actually do stuff
-- It's kinda hard to test spectating with only 1 client

if not CLHOST then return end

MG.Hook.Add("NetVarChanged","mg:spectate",function(plr, old, new)
	if not plr.IsLocal then return end

	if not old and new then
		NetworkSetInSpectatorMode(true, 0)
		plr:Kill()
	elseif old and not new then
		NetworkSetInSpectatorMode(false, 0)
	end
end)