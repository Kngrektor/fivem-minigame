resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

server_script "sh_lib.lua"
client_script "sh_lib.lua"

client_script "sh.lua"
server_script "sh.lua"

client_script "cl_map.lua"
client_script "cl_dbg.lua"
client_script "cl_ui.lua"
client_script "cl.lua"

client_script "sh_cmds.lua"
server_script "sh_cmds.lua"

files {
	--"sh_lib.lua",
	"lib/sh_util.lua",
	"lib/cl_map.lua",
	"lib/sh_hooks.lua",
	"lib/sh_plr.lua",
	"lib/sh_plr_nvs.lua",
	"lib/sh_plr_spectate.lua",
	"lib/sh_team.lua",
	"lib/sh_hud.lua",
	"lib/sh_round.lua"
}

file "ui/craziness.js"
file "ui/parser.js"
file "ui/host.html"
ui_page "ui/host.html"