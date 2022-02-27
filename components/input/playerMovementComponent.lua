local Baton = require "vendor.baton.baton"
local Vector = require "vendor.brinevector.brinevector"
require "ecs.component"

local input = Baton.new
{
	controls = {
		left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
		right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
		up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
		down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
	},
	pairs = {
		move = {"left", "right", "up", "down"}
	},
	joystick = love.joystick.getJoysticks()[1]
}

PlayerMovementComponent = Component:new()

function PlayerMovementComponent:new(obj)
	local pmc = Component.new(self, "PlayerControllerComponent", obj)

	pmc.inputEnabled = true

	return pmc
end

function PlayerMovementComponent:start(entity)
	self.collider = entity:getComponent("Collider")
	if self.collider == nil then
		error("Entity did not have a collider")
	end
end

function PlayerMovementComponent:update(entity, dt)
	input:update()
	local x, y = input:get 'move'
	self.collider:applyForce(Vector(x, y) * 100)
end

-- Stops the entity's movement altogether
function PlayerMovementComponent:stop()
	self.collider.body:setLinearVelocity(0, 0)
end
