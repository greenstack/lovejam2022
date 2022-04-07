require "components.collision"
require "ecs.component"

local Color = require "color"

Shockwave = Component:new()

function Shockwave:new(player, owner, startRadius, endRadius, color, obj)
	local eq = Component.new(self, "Shockwave", obj)

	eq.startRadius = startRadius
	eq.currentRadius = startRadius
	eq.endRadius = endRadius
	eq.expansionRate = 100
	eq.owningEntity = player or error("owningEntity cannot be nil")
	eq.color = color or Color()

	return eq;
end

function Shockwave:start(entity)
	local collision = CollisionComponent:new(entity)
	collision.fixture:setSensor(true)
	self.collider = collision
	entity:addComponent(collision)
end

function Shockwave:update(entity, dt)
	if (self.currentRadius > self.endRadius) then
		entity:kill()
		return
	end
	self.currentRadius = self.currentRadius + self.expansionRate * dt
	self.collider.fixture:getShape():setRadius(self.currentRadius)
end

local counter = 0

function Shockwave:beginContact(entity, collision)
	counter = counter + 1
	if counter <= 3 then
		return
	end

	-- don't react to other sensors
	local fixtureA, fixtureB = collision:getFixtures()
	if fixtureA:isSensor() and fixtureB:isSensor() then return end

	if entity == self.owningEntity then return end
	if entity:getTag("enemy") == self.owner:getTag("enemy") then return end
	
	local collision = entity:getComponent("Collider")
	local vec2other = entity.transform.position - self.owningEntity.transform.position
	collision:applyForce(vec2other.normalized * 8000)

	local enemy = entity:getComponent("Enemy")

	if enemy and not enemy:isInvincible() then
		entity:getComponent("Health"):loseHealth(1)
		enemy:activateIFrames()
	end
end

function Shockwave:draw(entity)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("line", 0, 0, self.currentRadius)
	love.graphics.setColor(1, 1, 1, 1)
end
