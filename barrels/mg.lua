MG = {}

local registrars = {}

function MG.Register(func)
	table.insert(registrars,func)
end

onGameTypeStart