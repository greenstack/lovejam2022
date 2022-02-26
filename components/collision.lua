require "ecs.component"

local Vector = require "vendor.brinevector.brinevector"

CollisionComponent = Component:new()

function CollisionComponent:new(entity, obj)
	local collider = Component.new(self, "Collider", obj)

	collider.body = love.physics.newBody(CurrentWorld.physicsWorld, entity.transform.position.x, entity.transform.position.y, "dynamic")
	collider.shape = love.physics.newCircleShape(10)
	collider.fixture = love.physics.newFixture(collider.body, collider.shape, 1)

	return collider
end

function CollisionComponent:update(entity, dt)
	entity.transform.position = Vector(self.body:getX(), self.body:getY())
end

function CollisionComponent:applyForce(vector)
	self.body:applyForce(vector:split())
end
