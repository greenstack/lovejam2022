require "game"
require "titleScreen"

local Baton = require "vendor.baton.baton"
Audio = require "audio"

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


---@diagnostic disable-next-line: undefined-field
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

function love.load()
	local windowTitle = "Magna Classic"
	if TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	elseif DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	end
	love.window.setTitle(windowTitle)

	CurrentGame = TitleScreen:new()
	Title = CurrentGame
	MainGame = Game:new()
	CurrentWorld = MainGame.world

	local iconData = love.image.newImageData("assets/magna_icon.png")
	love.window.setIcon(iconData);

	Audio.music:setLooping(true)
	love.audio.play(Audio.music)
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

function love.keypressed(key, scancode)
	if key == "m" then Audio:toggleMute() end
end
