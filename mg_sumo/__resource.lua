resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

client_script "@minigame/sh_lib.lua"
server_script "@minigame/sh_lib.lua"
server_script "sh.lua"
client_script "sh.lua"

file "hud.html"

dependency "minigame"

resource_type "gametype" {
	ismg = true, -- Used to identify minigames
	name = "Sumo",
	teams = {
		{name = "Red",  col = {255, 95, 74}},
		{name = "Blue", col = {74, 95, 255}}
	},
	scores = {
		Wins     = {"%d"     ,{0}  },
		Kills    = {"%d (%d)",{0,0}},
		Deaths   = {"%d"     ,{0}  },
		Suicides = {"%d"     ,{0}  }
	},
	authors = {"Kng"},
	desc = {
		"Drive your car into other peoples cars so",
		"they fly off rooftops n stuff.",
		"Apparently there's teams as well."
	},
	hud = "hud.html"
}
