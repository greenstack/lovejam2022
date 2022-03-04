Vector = require "vendor.brinevector.brinevector"

Game = {
	world = nil,
	player = nil,
	drawCallbacks = {}
}

function Game:new(obj)
	local game = obj or {}
	setmetatable(obj, self)
	self.__index = self

	game.world = World:new("test", "assets/map1.lua", 16)
	game.player = Player:new(Vector(100, 100))
	game.world:addEntity(game.player)
	game.world:setPlayer(game.player)
	game.drawCallbacks = {}

	return Game
end

function Game:update(dt)
	self.world.update(dt)
end

function Game:draw()
	self.world:draw()
	for _, cb in ipairs(self.drawCallbacks) do
		cb.draw()
	end
end

function Game:addPostWorldDrawCallback(func)
	table.insert(self.drawCallbacks, func)
end
