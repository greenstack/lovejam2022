require "game"
require "titleScreen"

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

CurrentWorld = nil
CurrentGame = nil
MainGame = nil
Title = nil

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

function love.load()
	local windowTitle = "Magna and Dude"
	if TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	elseif DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	end
	love.window.setTitle(windowTitle)

	CurrentGame = TitleScreen:new()
	Title = CurrentGame
	MainGame = Game:new()
	MainGame:addPostWorldDrawCallback(
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
	CurrentWorld = MainGame.world
end

function love.update(dt)
	if debugControls then
		debugControls:update()

		-- Toggles debug drawing
		if debugControls:pressed("drawDebug") then
			DRAW_DEBUG = not DRAW_DEBUG
		end
	end

	CurrentGame:update(dt)
end

function love.draw()
	CurrentGame:draw()
end

