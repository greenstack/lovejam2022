local Baton = require "vendor.baton.baton"

require "ecs.component"

local input = Baton.new
{
	controls = {
		action = {'key:x', 'button:a'},
	},
	joystick = love.joystick.getJoysticks()[1]
}

PlayerAbilityComponent = Component:new()

function PlayerAbilityComponent:new(base, name, obj)
	local pac = Component.new(base or self, name or "PlayerAbilityComponent", obj)

	return pac
end

function PlayerAbilityComponent:abilityStart(entity)
	error(self.type .. " has not implemented abilityStart")
end

function PlayerAbilityComponent:abilityEnd(entity)
	error(self.type .. " has not implemented abilityEnd")
end

function PlayerAbilityComponent:update(entity, dt)
	input:update()
	if (input:pressed("action")) then
		self:abilityStart(entity)
	elseif (input:released("action")) then
		self:abilityEnd(entity)
	end
end
