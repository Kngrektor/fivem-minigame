resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

client_script "@minigame/sh_lib.lua"
server_script "@minigame/sh_lib.lua"
client_script "sh.lua"
server_script "sh.lua"
client_script "cl.lua"

dependency "minigame"

resource_type "gametype" {
	name = "Suicide Barrels",
	ismg = true, -- Used to identify minigames
	teams = {
		{"Humans", {55, 212, 100}},
		{"Barrels", {255, 95, 74}}
	},
	authors = {"Kng"},
	desc = {
		"A old GMod Fretta gamemode ported to GTA.",
		"As a human you try to survive, and as a barrel",
		"you kill humans. Dead humans turn into barrels"
	}
}