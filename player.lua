require "ecs.entity"
require "components.collision"
require "components.player.earthquake"

local Baton = require "vendor.baton.baton"
local Color = require "color"
local Vector = require "vendor.brinevector.brinevector"
require "util.math"

Player = Entity:new()

local input = Baton.new
{
	controls = {
		left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
		right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
		up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
		down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
		action = {'key:x', 'key:return', 'button:a'},
		cancelAction = { 'key:z', 'key:rshift', 'button:b' },
	},
	pairs = {
		move = {"left", "right", "up", "down"}
	},
	joystick = love.joystick.getJoysticks()[1]
}

function Player:new(position, components, tags, obj)
	local player = Entity.new(self, "player", position, components, tags, obj)
	player:setTag("player", true)
	local playerCollision = CollisionComponent:new(player)
	self.collider = playerCollision
	player:addComponent(playerCollision)
	
	player.defaultSpeed = 300
	player.speed = player.defaultSpeed
	player.chargeWalkSpeed = player.defaultSpeed / 2

	player.facing = 1
	player.render = SpriteRender:new("assets/sprites/magna.json", "assets/sprites/magna.png", "idle")
	player:addComponent(player.render)
	
	player:addComponent(HealthComponent:new(6))

	player.actionQueued = false
	return player
end

local playerQuakesCreated = 0

function Player:update(dt)
	if self.stunned then
		print(dt)
		print(self.stunTime .. " - " .. dt .. "=" .. self.stunTime - dt)
		self.stunTime = self.stunTime - dt
		print("Stun time remaining: " .. self.stunTime)
		if self.stunTime <= 0 then
			self.stunned = false
		end
	end

	if not self.dead and self.collider.body ~= nil and not self.stunned then
		if self.earthquake == nil or self.earthquake.isPendingKill then
			input:update()
			local x, y = input:get 'move'
			self.collider:applyForce(Vector(x, y) * self.speed)
			-- Kill the earthquake if necessary
			if self.earthquake ~= nil then
				self.earthquake = nil
				self.speed = self.defaultSpeed
			end
		end
	
		local velocity = Vector(self.collider.body:getLinearVelocity())
		local speed = velocity.length
	
		-- 16 seems to be the magic number for when to switch between run and idle
		if speed > 16 then
			self.render:setTag("run")
			self.render.flipHorizontal = gs.math.sign(velocity.x) == -1
		else
			self.render:setTag("idle")
		end
	end

	-- update collision and such
	self:updateComponents(dt)

	if not self.dead and not self.stunned then
		if self.actionQueued then
			self.quakeSize = math.min(50, self.quakeSize + 64 * dt)
		end
		if (input:pressed("action")) then
			self.actionQueued = true
			self.quakeSize = 10
			self.speed = self.chargeWalkSpeed
		elseif (input:released("action")) and self.actionQueued then
			self.actionQueued = false
			self.earthquake = Entity:new("shockwave_" .. playerQuakesCreated,
				self.transform.position,
				{}
			)
			playerQuakesCreated = playerQuakesCreated + 1
			self.earthquake:addComponent(Shockwave:new(self, self.earthquake, 0, self.quakeSize, Color(0.18, 1, 0.37)))
			CurrentWorld:addEntity(self.earthquake)
			-- Stop the player: should not be able to move while earthquaking
			self.speed = 0
		end

		if input:pressed("cancelAction") then
			self.speed = self.defaultSpeed
			self.actionQueued = false
		end
	end
end

function Player:die()
	self.dead = true
	self.render:setTag("die")
	self.render.ing:onLoop(function() 
		self.render.ing:stop(true)
		CurrentWorld:gameOver(false)
	end)
end

function Player:draw()
	self:drawComponents()
	if self.actionQueued then
		love.graphics.setColor(0.68, 0.99, 1)
		love.graphics.circle("line", self.transform.position.x, self.transform.position.y, self.quakeSize)
		love.graphics.setColor(1,1,1)
	end
end

function Player:stun()
	if self.dead then return end
	self.stunned = true
	self.stunTime = 1
	self.render:setTag("stunned")
	self.actionQueued = false
end

function Player:__tostring()
	return "Player"
end
