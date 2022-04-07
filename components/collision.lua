require "ecs.component"

local Vector = require "vendor.brinevector.brinevector"

CollisionComponent = Component:new()

function CollisionComponent:new(entity, bodyType, world, mass, destroyColliderOnDestroy, obj)
	local collider = Component.new(self, "Collider", obj)

	collider.startup = {
		bodyType = bodyType or "dynamic",
		mass = mass or 1,
		destroyColliderOnDestroy = destroyColliderOnDestroy,
	}

	local currentWorld = world or CurrentWorld
	collider.body = love.physics.newBody(currentWorld.physicsWorld, entity.transform.position.x, entity.transform.position.y, bodyType or "dynamic")
	collider.body:setLinearDamping(8)
	collider.shape = love.physics.newCircleShape(6)
	collider.fixture = love.physics.newFixture(collider.body, collider.shape, mass or 1)
	if destroyColliderOnDestroy ~= nil then
		collider.destroyColliderOnDestroy = destroyColliderOnDestroy
	else
		collider.destroyColliderOnDestroy = true
	end
	collider.fixture:setUserData(collider)
	
	return collider
end

function CollisionComponent:start(entity)

end

function CollisionComponent:update(entity, dt)
	entity.transform.position = Vector(self.body:getX(), self.body:getY())
end

function CollisionComponent:draw(entity)
	if DEBUG_MODE and DRAW_DEBUG then
		local shape = self.shape:getType()
		if shape == "circle" then
			love.graphics.circle("line", 0, 0, self.shape:getRadius())
		end
	end
end

function CollisionComponent:applyForce(vector)
	if self.body == nil then return end
	self.body:applyForce(vector:split())
end

function CollisionComponent:onDestroy()
	if self.destroyColliderOnDestroy then
		self.fixture:setUserData(nil)
		self.body:destroy()
		self.body = nil
	end
end
