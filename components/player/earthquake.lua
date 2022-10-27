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
	if entity:getTag("bigQuake") then
		self.bigQuake = true
	end
end

function Shockwave:update(entity, dt)
	if (self.currentRadius > self.endRadius) then
		entity:kill()
		return
	end
	self.currentRadius = self.currentRadius + self.expansionRate * dt

	-- Recreate the collider each frame for the most accurate collision detection
	self.collider.fixture:setUserData(nil)
	self.collider.fixture:destroy()

	self.collider.shape = love.physics.newCircleShape(self.currentRadius)
	self.collider.fixture = love.physics.newFixture(self.collider.body, self.collider.shape)
	self.collider.fixture:setSensor(true)
	self.collider.fixture:setUserData(self.collider)
end

function Shockwave:beginContact(entity, collision)
	-- don't react to other sensors
	local fixtureA, fixtureB = collision:getFixtures()
	if fixtureA:isSensor() and fixtureB:isSensor() then return end

	-- ignore owner
	if entity == self.owningEntity then return end
	-- ignore teammates
	if entity:getTag("enemy") == self.owner:getTag("enemy") then return end

	local me, them
	if fixtureA:isSensor() then
		me = fixtureA; them = fixtureB
	else
		me = fixtureB; them = fixtureA
	end

	-- todo: you are here
	local vec2other = self.owningEntity.transform.position - entity.transform.position
	if (vec2other == nil) then
		print("what")
	end

	local distance = math.sqrt(vec2other.x * vec2other.x + vec2other.y * vec2other.y)

	-- We're actually going to stun the player
	if self.bigQuake then
		if entity.stun and distance > me:getShape():getRadius() and not entity.stunned then
			entity:stun()
		end
		return
	end

	local collider = entity:getComponent("Collider")
	local vec2other = entity.transform.position - self.owningEntity.transform.position
	collider:applyForce(vec2other.normalized * 8000)

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
