TitleScreen = {}

local Baton = require "vendor.baton.baton"

require "ecs.entity"
require "components.render.spriteRender"

local input = Baton.new
{
	controls = {
		start = {'key:x', 'button:a'},
		exit = {'key:escape'},
	},
	joystick = love.joystick.getJoysticks()[1]
}

function TitleScreen:new(obj)
	local ts = obj or {}
	setmetatable(ts, self)
	self.__index = self
	ts.image = love.graphics.newImage("assets/magna_cover.png")

	ts.render = SpriteRender:new("assets/sprites/evil_crystal.json", "assets/sprites/evil_crystal.png", "spin_full_hp")
	ts.entity = Entity:new("", Vector(10, 40), {ts.render})

	self.spriteCycleCurrent = 0
	self.spriteCycle = 1
	self.spriteCycleTime = 3

	return ts
end

function TitleScreen:update(dt)
	input:update(dt)
	self.entity:update(dt)
	if input:pressed "start" then
		CurrentGame = MainGame
	end

	if input:pressed "exit" then
		love.event.quit()
	end
	self.spriteCycleCurrent = self.spriteCycleCurrent + dt
	if self.spriteCycleCurrent > self.spriteCycleTime then
		self.spriteCycleCurrent = 0
		self.spriteCycle = self.spriteCycle + 1
		if self.spriteCycle > 3 then self.spriteCycle = 1 end
		
		if self.spriteCycle == 3 then
			self.render:setTag("spin_critical")
		elseif self.spriteCycle == 2 then
			self.render:setTag("spin_damaged")
		elseif self.spriteCycle == 1 then
			self.render:setTag("spin_full_hp")
		end
	end

end

function TitleScreen:draw()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	love.graphics.translate(-self.image:getWidth() / 2, -self.image:getHeight() /2)
	love.graphics.draw(self.image)
	love.graphics.pop()

	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2, 500)
	love.graphics.setColor(0, 0, 0, .33)
	love.graphics.rectangle("fill", -75, -5, 160, 50, 3, 3)
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("Press action (X) to begin", -70)
	love.graphics.print("Press Escape to quit", -60, 25)
	love.graphics.pop()

	love.graphics.push()
	love.graphics.translate(550, 480)
	love.graphics.setColor(0, 0, 0, .33)
	love.graphics.rectangle("fill", 0, 0, 205, 80, 3, 3)
	love.graphics.setColor(1,1,1,1)
	self.entity:draw()
	love.graphics.print("Destroy these crystals with\nyour earthquake! Be careful\nnot to hit the green ones\nthough - if they're destroyed,\nit's game over!", 25, 3)
	love.graphics.pop()
end
