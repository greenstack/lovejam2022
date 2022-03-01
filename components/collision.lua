require "ecs.component"

local Vector = require "vendor.brinevector.brinevector"

CollisionComponent = Component:new()

function CollisionComponent:new(entity, bodyType, world, mass, obj)
	local collider = Component.new(self, "Collider", obj)

	local currentWorld = world or CurrentWorld
	--assert(entity, error("Cannot set up collider without an entity"))
	--assert(currentWorld, "World not set up")

	collider.body = love.physics.newBody(currentWorld.physicsWorld, entity.transform.position.x, entity.transform.position.y, bodyType or "dynamic")
	collider.body:setLinearDamping(8)
	collider.shape = love.physics.newCircleShape(6)
	collider.fixture = love.physics.newFixture(collider.body, collider.shape, mass or 1)

	return collider
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
	self.body:applyForce(vector:split())
end
