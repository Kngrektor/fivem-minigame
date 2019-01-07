--[[MGR_WARMUP = 1
MGR_PRE = 2
MGR_ACTIVE = 3
MGR_POST = 4]]

MG.Round = {}

--[[
	Round
		Methods?
]]
local cur

MG.Hook.Add("PreRoundStart",function()
	cur = { timers = {} }
end)

MG.Hook.Add("RoundEnd",function()
	for _, timer in pairs(cur.timers) do
		timer:Destroy()
	end
	cur = nil
end)

function MG.Round.End(winners)
	if cur and SERVER then
		MG.Hook.Trigger("RoundEnd", winners)
		MG.Hook.Trigger("PostRoundEnd", winners)
	end
end

-- A timer with automatic cleanup
function MG.Round.Timer(time, hud)
	if not cur then return nil end
	local timer = MG.Util.Timer(time)

	if CLIENT and hud then
		MG.HUD["mg:RoundTimer"] = timer
	end

	cur.timers[#cur.timers+1] = timer
	return timer
end

-- Minigame only code
if not HOST then return end

function MG.Round.Start()
	if not SERVER then return end
	if cur then return end

	MG.Hook.Trigger("PreRoundStart")
	MG.Hook.Trigger("RoundStart")
end

MG.Hook.Add("RoundEnd",function(winners)
	if winners then
		MG.Print("%s won the round", winners)
	else
		MG.Print("Round ended with a draw")
	end
end)
MG.Hook.Add("PostRoundEnd",function()
	MG.HUD["mg:RoundTimer"] = MG.Util.Timer(5,MG.Round.Start)
end)

if SERVER then
	MG.Hook.Add("PreRoundStart",function()
		for _, plr in pairs(MG.GetPlayers()) do
			plr:SetNetVar("mg:spectate", false)
			plr:Respawn()
		end
	end)
	MG.Hook.Add("NetVarChanged",function(var, plr, old, new)
		if var == "mg:team" then
			if (old or 0) > 0 or new < 1 then return end

			TriggerEvent("mg:PreventRoundStart")
			if WasEventCanceled() then return end
			MG.Round.Start()
		end
	end)
end