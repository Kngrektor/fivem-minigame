print("Hue!")
RegisterCommand("barrel", function(source, args, raw)
	TriggerClientEvent('barrel:barrelify',-1,source)
end)