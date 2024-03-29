Vector = require "vendor.brinevector.brinevector"
require "player"
require "ecs.world"

local Baton = require "vendor.baton.baton"
local Color = require "color"

local input = Baton.new
{
	controls = {
		restart = {'key:return', 'button:start'},
		exit = {'key:escape'}
	},
	joystick = love.joystick.getJoysticks()[1]
}

Game = {
	world = nil,
	player = nil,
	drawCallbacks = {}
}

function Game:new(obj)
	local game = obj or {}
	setmetatable(game, self)
	self.__index = self

	game.world = World:new("test", "assets/map1.lua", 16)

	CurrentWorld = game.world

	game.player = Player:new(Vector(100, 100))
	game.world:addEntity(game.player)
	game.world:setPlayer(game.player)
	game.drawCallbacks = {}
	game.gameOverImage = love.graphics.newImage("assets/sprites/gameOver.png")
	game.gameOverImage:setFilter("nearest", "nearest")

	local worldHealthBar = Bar:new("worldHealth", Vector(10, 10), Color(0, 1, 0), 100, 10)

	worldHealthBar.currentValueSource = function()
		local health = 0
		for _, crystal in ipairs(CurrentWorld.worldCrystals) do
			health = health + crystal:getComponent("Health"):getCurrent()
		end
		return health
	end

	worldHealthBar.maxValueSource = function()
		return CurrentWorld.totalCrystalCount * 3
	end

	local enemyCrystalBar = Bar:new("enemyCrystals", Vector(10, 23), Color(1, 0, 0), 100, 10)

	enemyCrystalBar.currentValueSource = function()
		return CurrentWorld.evilCrystalCount
	end

	enemyCrystalBar.maxValueSource = function()
		return CurrentWorld.totalEvilCrystalCount
	end

	game:addPostWorldDrawCallback(
		function ()
			worldHealthBar:draw()
			enemyCrystalBar:draw()
				love.graphics.printf(
				"Score: " .. CurrentWorld.playerScore,
				love.graphics.getWidth() / 2,
				10,
				love.graphics.getWidth() / 4,
				"center"
			)
		end
	)

	return game
end

function Game:update(dt)
	self.world:update(dt)
	if self.world.isGameOver then
		input:update()
		if input:pressed("restart") then
			MainGame = Game:new()
			CurrentGame = MainGame
		end
	end
end

function Game:draw()
	self.world:draw()
	for _, cb in ipairs(self.drawCallbacks) do
		cb()
	end

	if self.world.isGameOver then
		-- draw the game over stuff here		
		love.graphics.setColor(0,0,0,.33)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(1,1,1)
		
		love.graphics.push()
		love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
		love.graphics.scale(2.5, 2.5)
		love.graphics.translate(-self.gameOverImage:getWidth() / 2, -self.gameOverImage:getHeight() /2)
		love.graphics.draw(self.gameOverImage)
		love.graphics.pop()

		love.graphics.push()
		love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
		love.graphics.print("Press escape to quit or return to restart", -120, 40)
		love.graphics.pop()
	end
end

function Game:addPostWorldDrawCallback(func)
	table.insert(self.drawCallbacks, func)
end
