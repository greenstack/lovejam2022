require "ecs.entity"
require "ecs.world"

require "components.collision"
require "components.render.simpleRectRender"
require "components.render.spriteRender"
require "components.player.playerQuakeAbility"

require "player"

local Vector = require "vendor.brinevector.brinevector"
local Baton = require "vendor.baton.baton"
local Color = require "color"

local launchType = arg[2]

require "bar"

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

local world = World:new("test", "assets/map1.lua", 16)
local player

CurrentWorld = world

function love.load()
	local windowTitle = "Magna and Dude"
	if TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	elseif DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	end
	love.window.setTitle(windowTitle)

	player = Player:new(Vector(100, 100))
	world:addEntity(player)
	world:setPlayer(player)

	local enemyComponents = {
		SpriteRender:new("assets/sprites/craggy.json", "assets/sprites/craggy.png", "default")
	}
	local enemy = Entity:new("enemy", Vector(150, 100), enemyComponents)
	enemy:addComponent(CollisionComponent:new(enemy))
	world:addEntity(enemy)
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
	return world.evilCrystalCount
end

enemyCrystalBar.maxValueSource = function()
	return world.totalEvilCrystalCount
end

function love.draw()
	CurrentWorld:draw()
	worldHealthBar:draw()
	enemyCrystalBar:draw()
end

