require "ecs.world"

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

function love.load()
	local windowTitle = "Magna and Dude"
	if DEBUG_MODE then
		windowTitle = windowTitle .. " (Debug)"
	elseif TEST_MODE then
		windowTitle = windowTitle .. " (Test)"
	end
	love.window.setTitle(windowTitle)

	
end

function love.update(dt)
	world:update(dt)
end

function love.draw()
	world:draw()
end

