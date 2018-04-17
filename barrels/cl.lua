local prop = GetHashKey("prop_barrel_exp_01b")
local zero3 = vector3(0,0,0)

function DisablePedColl(ped)
	for idx = 0, 32 do
		if NetworkIsPlayerActive(idx) then
			SetEntityNoCollisionEntity(GetPlayerPed(idx), ped, false)
		end
	end
end

function Barrelify(ply)
	if ply ~= PlayerId() then return end
	ENT = CreateObjectNoOffset(prop,zero3,true,false,true)

	AttachEntityToEntity(ENT, GetPlayerPed(-1), 0,
		vector3(0,0,-.5), zero3,
		false, false, true, false, 0, false)
end

--[[RegisterNetEvent("barrel:barrelify")
AddEventHandler("barrel:barrelify",function(ply)
	ply = GetPlayerFromServerId(ply)
	print(ply," is gettin' barreled, you are", PlayerId())
	DisablePedColl(GetPlayerPed(ply))
	if ply ~= PlayerId() then return end
	Barrelify()
end)]]

