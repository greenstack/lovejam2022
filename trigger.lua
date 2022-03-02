local Vector = require "vendor.brinevector.brinevector"

Trigger = {
	center = Vector(),
	radius = 0,
	owner = nil,
	isPendingKill = false
}

-- A circular trigger
function Trigger:new(owningEntity, center, radius, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	-- owning entity can be nil or otherwise
	self.owner = owningEntity
	self.center = center or Vector()
	self.radius = radius or 0
	return obj
end

function Trigger:intersectsEntity(entity)
	-- Owner can't trigger itself
	if self.owner and self.owner == entity then return end

	local collider = entity:getComponent("Collider")
	if collider == nil or collider.body == nil then
		return
	end

	local fixtures = collider.body:getFixtures()
	local shape
	if fixtures then for _, f in ipairs(fixtures) do
		shape = f:getShape()
		-- only work on the first circle
		if shape:getType() == "circle" then break end
	end	end
	-- if we've gone through the list and found no circles, give up.
	-- (game entities will only have circle colliders)
	if shape:getType() ~= "circle" then return end

	-- aight, now do the collision detection between circles
	-- if the distance between the centra is less than the sum of the radii, then
	-- we've got a collision
	local vec2other = self.center - entity.transform.position
	local distance = vec2other.length
	return distance <= self.radius + shape:getRadius()
end
