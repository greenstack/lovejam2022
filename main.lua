require "ecs.entity"
require "ecs.world"

require "components.collision"
require "components.render.simpleRectRender"
require "components.render.spriteRender"
require "components.input.playerMovementComponent"
require "components.player.playerQuakeAbility"

local Vector = require "vendor.brinevector.brinevector"
local Color = require "color"

local launchType = arg[2]

DEBUG_MODE = false
TEST_MODE = false
RELEASE = false

if launchType == "test" or launchType == "debug" then
	require "lldebugger"
	DEBUG_MODE = true

	if launchType == "debug" then
		lldebugger.start()
	else
		TEST_MODE = true
	end
else
	RELEASE = true
end

local love_errorhandler = love.errhand

function love.errorhandler(msg)
	if lldebugger then
		lldebugger.start()
		error(msg, 2)
	else
		return love_errorhandler(msg)
	end
end

local world = World:new("test")

CurrentWorld = world

function love.load()
	local windowTitle = "Magna and Dude"
	if DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	elseif TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	end
	love.window.setTitle(windowTitle)

	local playerComponents = {
		--SimpleRectRender:new(Color.Predefined.green),
		SpriteRender:new("assets/magna.json", "assets/magna.png"),
		PlayerMovementComponent:new(),
		PlayerQuakeAbility:new(),
	}
	local player = Entity:new("player", Vector(100, 100), playerComponents)
	player:addComponent(CollisionComponent:new(player))
	world:addEntity(player)

	local enemyComponents = {
		SimpleRectRender:new(Color.Predefined.yellow),
	}
	local enemy = Entity:new("enemy", Vector(150, 100), enemyComponents)
	enemy:addComponent(CollisionComponent:new(enemy))
	world:addEntity(enemy)

	-- configure image scaling properties
end

function love.update(dt)
	CurrentWorld:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(2, 2)
	CurrentWorld:draw()
	love.graphics.pop()
end

