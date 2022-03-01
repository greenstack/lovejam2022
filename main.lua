require "ecs.entity"
require "ecs.world"

require "components.collision"
require "components.render.simpleRectRender"
require "components.render.spriteRender"
require "components.player.playerQuakeAbility"

require "player"

local Vector = require "vendor.brinevector.brinevector"
local Color = require "color"
local Baton = require "vendor.baton.baton"

local launchType = arg[2]

DEBUG_MODE = false
TEST_MODE = false
RELEASE = false

local debugControls = nil

if launchType == "test" or launchType == "debug" then
	require "lldebugger"
	DEBUG_MODE = true

	if launchType == "debug" then
		lldebugger.start()
		debugControls = Baton.new
		{
			controls = {
				drawDebug = {'key:f12'},
			}
		}
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
	if TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	elseif DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	end
	love.window.setTitle(windowTitle)

	local playerComponents = {
		SpriteRender:new("assets/magna.json", "assets/magna.png"),
		PlayerQuakeAbility:new(),
	}
	local player = Player:new(Vector(100, 100), playerComponents)
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
	if debugControls then
		debugControls:update()

		-- Toggles debug drawing
		if debugControls:pressed("drawDebug") then
			DRAW_DEBUG = not DRAW_DEBUG
		end
	end

	CurrentWorld:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(2, 2)
	CurrentWorld:draw()
	love.graphics.pop()
end

