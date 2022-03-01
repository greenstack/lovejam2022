require "ecs.entity"
require "components.collision"

local Baton = require "vendor.baton.baton"
local Vector = require "vendor.brinevector.brinevector"

Player = Entity:new()

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

function Player:new(position, components, tags, obj)
	local player = Entity.new(self, "player", position, components, tags, obj)

	local playerCollision = CollisionComponent:new(player)

	player:addComponent(playerCollision)
	self.collider = playerCollision
	return player
end

function Player:update(dt)
	input:update()
	local x, y = input:get 'move'
	self.collider:applyForce(Vector(x, y) * 100)

	self:updateComponents(dt)
end

function Player:draw()
	self:drawComponents()
end
