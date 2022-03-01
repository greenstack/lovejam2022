require "ecs.component"
require "util.math"

HealthComponent = Component:new()

function HealthComponent:new(max, obj)
	local healthComp = Component.new(self, "Health", obj)
	healthComp.max = max
	healthComp._current = max
	healthComp.deathListeners = {}
	return healthComp
end

function HealthComponent:getMax()
	return self.max
end

function HealthComponent:getCurrent()
	return self._current
end

function HealthComponent:loseHealth(amount)
	self._current = self._current - amount
	self._current = gs.math.clamp(self._current, 0, self.max)
	if self._current == 0 then
		self:die()
	end
end

function HealthComponent:registerDeathListener(func)
	table.insert(self.deathListeners, func)
end

function HealthComponent:die()
	for _, func in pairs(self.deathListeners) do
		func(self)
	end
end
