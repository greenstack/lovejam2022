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

	return pmc
end

function PlayerMovementComponent:update(entity, dt)
	input:update()
	local x, y = input:get 'move'
	entity.transform.position = entity.transform.position + Vector(x, y).normalized * dt * 100
	
end
