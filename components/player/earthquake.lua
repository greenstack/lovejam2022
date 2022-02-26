require "ecs.component"

Earthquake = Component:new()

function Earthquake:new(startRadius, endRadius, obj)
	local eq = Component.new(self, "Earthquake", obj)

	eq.startRadius = startRadius
	eq.currentRadius = startRadius
	eq.endRadius = endRadius
	eq.expansionRate = 100

	return eq;
end

function Earthquake:update(entity, dt)
	if (self.currentRadius > self.endRadius) then
		entity:kill()
		return
	end
	self.currentRadius = self.currentRadius + self.expansionRate * dt
end

function Earthquake:draw(entity)
	love.graphics.circle("line", 0, 0, self.currentRadius)
end
