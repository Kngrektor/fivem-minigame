MG.HUD = {}

if SERVER then return end -- Just do nothing on server

--[[
	Load HTML/CSS/JS defined UI
	Crawl document finding placeholders/variables
		Allow basic formatting: Number, String, Percentage [0.0 - 1.0], Lists
		Expose basic api (onUpdate(var, cb)) to JS
		MG.Hud.Set("Placeholder", [Number, Timer, String])
	Bidirectional events
]]

MG.HUD = setmetatable({},{
	__newindex = function(self,k,v)
		if type(v) == "table" then
			local left = v._end - GetGameTimer()
			local len  = v._end - v._start
			MG.Log(3, "Set HUD variable %s to Timer(%d)",k,left)
			MG.Hook.Trigger("HudUpdateVar", k,
				{type = "timer", len = len, left = left + 500}) -- + 500 is a hack
		else
			MG.Log(3, "Set HUD variable %s to '%s'",k,v)
			MG.Hook.Trigger("HudUpdateVar", k, v)
		end
	end
})

if not HOST then return end

MG.Hook.Add("HudUpdateVar",function(prop, val)
	SendNUIMessage({
		type = "updHud",
		prop = prop,
		value = val
	})
end)

MG.Hook.Add("Start", function(res)
	local data = GetResourceMetadata(res,"resource_type_extra",0)
	local content = LoadResourceFile(res, json.decode(data).hud)
	SendNUIMessage({
		type = "loadHud",
		content = content
	})
end)