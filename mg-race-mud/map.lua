local count = 1
local function point(pos)
	waypoint(count,pos)
end

local function createStartPoints(pos, heading, forward)
	local side = vector3(forward.y, foward.x, 0)*2
	for i=0, 64 do
		local p = pos + side - forward*4*i
		spawn {x=p.x, y=p.y, z=p.z, h=heading}
		side = -side
	end
end


createStartPoints(
	vector3(1137.398, 2154.73, 53.2),
	272.63531494141,
	vector3(0.9987772, 0.04589809, 0))

point(vector3(1131.998, 2222.868, 48.64828))
point(vector3(928.4988, 2366.052, 46.21272))
point(vector3(1128.239, 2393.563, 50.09921))
point(vector3(1165.145, 2367.236, 57.55267))
point(vector3(903.4848, 2476.213, 50.90158))
point(vector3(1137.398, 2154.73, 53.2))