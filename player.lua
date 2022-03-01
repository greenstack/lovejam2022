require "ecs.entity"
require "components.collision"
require "components.player.earthquake"

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
		action = {'key:x', 'button:a'},
	},
	pairs = {
		move = {"left", "right", "up", "down"}
	},
	joystick = love.joystick.getJoysticks()[1]
}

function Player:new(position, components, tags, obj)
	local player = Entity.new(self, "player", position, components, tags, obj)

	local playerCollision = CollisionComponent:new(player)
	player.actionQueued = false

	player:addComponent(playerCollision)
	self.collider = playerCollision
	return player
end

function Player:update(dt)
	if self.earthquake == nil or self.earthquake.isPendingKill then
		input:update()
		local x, y = input:get 'move'
		self.collider:applyForce(Vector(x, y) * 150)
		-- Kill the earthquake if necessary
		if self.earthquake ~= nil then
			self.earthquake = nil
		end
	end


	-- update collision and such
	self:updateComponents(dt)

	if (input:pressed("action")) then
		self.actionQueued = true
	elseif (input:released("action")) and self.actionQueued then
		self.actionQueued = false
		self.earthquake = Entity:new("shockwave",
			self.transform.position,
			{}
		)
		self.earthquake:addComponent(Shockwave:new(self, self.earthquake, 0, 50))
		CurrentWorld:addEntity(self.earthquake)
		-- Stop the player: should not be able to move while earthquaking
		self.collider.body:setLinearVelocity(0, 0)
	end
end

function Player:draw()
	self:drawComponents()
end
