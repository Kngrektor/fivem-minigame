MG.Util = {}
-- This file is kinda messy and
-- serves as a "unsorted" for code

-- Makes tables read only
function MG.Util.ReadOnly(tbl)
	return setmetatable({},{
		__index = tbl,
		__newindex = function() error("Tried to write to read only table") end,
		__pairs = function() return pairs(tbl) end,
		__ipairs = function() return ipairs(tbl) end,
		__len = function() return #tbl end
	})
end

-- Make tables n stuff into vectors
function MG.Util.Vectorify(x, y, z)
	if y then return vector3(x,y,z) end
	if type(x) == "table" then
		return vector3(x.x, x.y, x.z)
	end
	return x
end
MG.Util.Vecify = MG.Util.Vectorify

-- Citizen.CreateThread + while loop
function MG.Util.OnTick(fn, delay)
	Citizen.CreateThread(function()
		while true do
			fn()
			Citizen.Wait(delay or 0)
		end
	end)
end

--[[
	Prefixed erroring & debuggies
]]
function MG.Log(lvl, fmt, ...) -- Do fancier shit
	local curLvl = GetConvarInt("mg_debuglevel", 1)
	if curLvl >= lvl then
		print(("[MG/"..RESOURCE.."] "..fmt):format(...))
	end
end
function MG.Print(...) MG.Log(1, ...) end

function MG.Error(fmt, ...)
	error(("[MG/"..RESOURCE.."] Err: "..fmt):format(...), 2)
end

-- The reason this function is only used once
-- is because everything is retardedly insecure
function MG.ArgCheck(name, expected, arg, var)
	local t = type(var)
	for _, t2 in pairs(expected) do
		if t == t2 then return end
	end

	local fmt = "%s expected %s as arg %s, got %s(%s)"
	expected = table.concat(expected, ", ")
	error(fmt:format(name, expected, tostring(arg), t, tostring(var)), 3)
end

--[[
	Timer

	todo: Make it a seperate thingie
]]
local timers = {}
local timerMeta = {}
function MG.Util.Timer(secs, cb, repeats)

	local start = GetGameTimer()
	local stop  = start + secs * 1000

	local i = #timers + 1
	local timer = setmetatable({
		_start = start,
		_end  = stop,
		_reps  = repeats or 1,
		_idx   = i,
		_cb    = cb
	},{
		__index = timerMeta
	})

	timers[i] = timer

	return timer
end
MG.Util.OnTick(function()
	local time = GetGameTimer()
	for k, v in pairs(timers) do
		if time > v._end then
			timers[k] = nil
			v._fin = true
			v._fail = false
			if v._cb then v._cb() end
		end
	end
end, 500)

function timerMeta:Destroy()
	if self._fin then return end

	self._fin = true
	self._fail = true

	timers[self._idx] = nil
end

function timerMeta:Await()
	if self.reps then
		MG.Error("Awaiting a repeating timer is not a good idea")
	end

	while not self._fin do
		Citizen.Wait(500)
	end
	return not self._fail
end

--[[
	Shapes
		Just allows you to see if
		a point is inside of stuff

	todo: Make it a seperate thingie
]]
MG.Util.Shapes = setmetatable({},{
	__call = function(self, tbl)
		-- todo: Less if spaghetti
		if tbl["p"] and tbl["n"] then
			local p = MG.Util.Vecify(tbl["p"])
			local n = MG.Util.Vecify(tbl["n"])
			return self.Plane(p, n)
		elseif tbl["p1"] and tbl["p2"] and tbl["p3"] and tbl["p4"] then
			local p1 = MG.Util.Vecify(tbl["p1"])
			local p2 = MG.Util.Vecify(tbl["p2"])
			local p3 = MG.Util.Vecify(tbl["p3"])
			local p4 = MG.Util.Vecify(tbl["p4"])
			return self.Box(p1, p2, p3, p4)
		elseif tbl["min"] and tbl["max"] then
			local min = MG.Util.Vecify(tbl["min"])
			local max = MG.Util.Vecify(tbl["max"])
			return self.AABB(min, max)
		end
	end
})


local function addShape(name, cons, isInside)
	MG.Util.Shapes[name] = function(...)
		local self = {}
		cons(self,...)
		self.IsInside = isInside
		return self
	end
end

--[[
	Shapes
		Plane
]]
addShape("Plane",
	-- Constructor
	function(self, point, normal)
		self.p, self.n = point, normal
	end,
	-- IsInside
	function(self, pos)
		return dot(pos - self.p, self.n) <= 0
	end
)
--[[
	Shapes
		Box
	todo: Make it actually work, seems bork
]]
addShape("Box",
	-- Constructor
	function(self, p1, p2, p3, p4)
		self.u = p1 - p2
		self.u1 = dot(self.u, p1)
		self.u2 = dot(self.u, p2)
		self.v = p1 - p3
		self.v1 = dot(self.v, p1)
		self.v2 = dot(self.v, p3)
		self.w = p1 - p4
		self.w1 = dot(self.w, p1)
		self.w2 = dot(self.w, p4)
	end,
	-- IsInside
	function(self, pos)
		local up = dot(self.u, pos)
		local vp = dot(self.v, pos)
		local wp = dot(self.w, pos)
		return up >= self.u1 and up <= self.u2
		   and vp >= self.v1 and vp <= self.v2
		   and wp >= self.w1 and wp <= self.w2
	end
)
--[[
	Shapes
		Axis Aligned Bounding Box
]]
addShape("AABB",
	-- Constructor
	function(self, min, max)
		self.min, self.max = min, max
	end,
	-- IsInside
	function(self, pos)
		return pos.x > self.min.x
			and pos.y > self.min.y
			and pos.z > self.min.z
			and pos.x < self.max.x
			and pos.y < self.max.y
			and pos.z < self.max.z
	end
)

--[[
	Enumerators

	Usage:
		for x in MG.Util.GetX() do
			x
		end
	https://gist.github.com/IllidanS4/9865ed17f60576425369fc1da70259b2
]]

local entEnum = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function enumEnts(initFunc, moveFunc, disposeFunc)
	return function()
		return coroutine.wrap(function()
			local iter, id = initFunc()
			if not id or id == 0 then
				disposeFunc(iter)
				return
			end

			local enum = {handle = iter, destructor = disposeFunc}
			setmetatable(enum, entEnum)

			local next
			repeat
			  coroutine.yield(id)
			  next, id = moveFunc(iter)
			until not next

			enum.destructor, enum.handle = nil, nil
			disposeFunc(iter)
		end)
	end
end

MG.Util.GetObjects  = enumEnts(FindFirstObject, FindNextObject, EndFindObject)
MG.Util.GetPeds     = enumEnts(FindFirstPed,    FindNextPed,    EndFindPed)
MG.Util.GetVehicles = enumEnts(FindFirstVehicle,FindNextVehicle,EndFindVehicle)
MG.Util.GetPickups  = enumEnts(FindFirstPickup, FindNextPickup, EndFindPickup)