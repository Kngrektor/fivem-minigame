--[[
	NetVar
		Sync
]]
local nvs = {} -- Local store

MG.Hook.Add("NetVarChanged",function(var, plr, old, new)
	if HOST then
		MG.Log(2,"%s.NetVars['%s'] = %s",tostring(plr),var,tostring(new))
	end

	nvs[plr._sid] = nvs[plr._sid] or {}
	nvs[plr._sid][var] = new
end)

if SVHOST then
	RegisterNetEvent("mg:_updPlrNetVar")
	AddEventHandler("mg:_updPlrNetVar", function(var, new, sid)
		sid = sid or source

		-- Kinda egh to send the old val in events but it makes the code nicer
		local old = nvs[sid] and nvs[sid][var] or nil

		TriggerEvent("mg:NetVarChanged", var, sid, old, new)
		TriggerClientEvent("mg:NetVarChanged", -1, var, sid, old, new)
	end)
end

--[[
	NetVar
		PlayerMeta
]]
function MG.Metas.Player:SetNetVar(var, val)
	if self:GetNetVar(var) == val then return end

	if SERVER then
		TriggerEvent("mg:_updPlrNetVar", var, val, self._sid)
	elseif self.IsLocal then
		TriggerServerEvent("mg:_updPlrNetVar", var, val)
	end
end

function MG.Metas.Player:GetNetVar(var, def)
	if type(nvs[self._sid]) ~= "table" then return def end
	if nvs[self._sid][var]  == nil then return def end
	return nvs[self._sid][var]
end

MG.Metas.Player._addProp("NetVars",function(self)
	return MG.Util.ReadOnly(nvs[self._sid] or {})
end)

--[[
	NetVar
		Initial sync and cleanup
]]
-- Minigame only code
if not HOST then return end

local function setPlrNetVars(sid, sidnvs)
	for var, old in pairs(nvs[sid] or {}) do -- any -> nil
		if not sidnvs or sidnvs[var] == nil then
			TriggerEvent("mg:NetVarChanged", var, sid, old, nil)
		end
	end

	if sidnvs then
		for var, new in pairs(sidnvs) do -- any -> !nil
			local old = nvs[sid] and nvs[sid][var] or nil
			TriggerEvent("mg:NetVarChanged", var, sid, old, new)
		end
	end
end

if SERVER then
	RegisterNetEvent("mg:_updPlrNetVars")
	AddEventHandler("mg:_updPlrNetVars", function()
		for sid, v in pairs(nvs) do
			MG.Print("  Sending sid %s = %s", tostring(sid), tostring(v))
			TriggerClientEvent("mg:_updPlrNetVars", source, sid, v)
		end
	end)

	AddEventHandler("playerDropped", function()
		TriggerClientEvent("mg:_updPlrNetVars", -1, source, nil)
		setPlrNetVars(source, nil)
	end)
elseif CLIENT then
	RegisterNetEvent("mg:_updPlrNetVars")
	AddEventHandler("mg:_updPlrNetVars", setPlrNetwVars)

	-- Initial sync, as soon as possible
	MG.Hook.Add("Start",function()
		Citizen.Wait(0)
		TriggerServerEvent("mg:_updPlrNetVars")
	end)
end


RegisterCommand("mg_dumpnvs", function(s, as, raw)
	for sid, sidnvs in pairs(nvs) do
		MG.Print("%s:", MG.GetPlayer(sid))
		for k, v in pairs(sidnvs) do
			MG.Print("  %s - %s(%s)",k,type(v),tostring(v))
		end
	end
end)

if not CLIENT then return end

local function text(x,y,str)
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(str)
	SetTextFont(6)
	SetTextDropShadow()
	SetTextDropshadow(2,50,50,50,200)
	EndTextCommandDisplayText(x,y)
end
MG.Util.OnTick(function()
	if GetConvarInt("mg_debuglevel", 1) > 1 then
		local y = -.04
		for sid, sidnvs in pairs(nvs) do
			y = y + .05
			text(.01, y, tostring(MG.GetPlayer(sid)))
			for k, v in pairs(sidnvs) do
				y = y + .04
				text(.05, y, k.." - "..type(v).."("..tostring(v)..")")
			end
		end
	else
		Citizen.Wait(1000)
	end
end)