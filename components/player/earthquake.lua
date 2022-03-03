require "components.collision"
require "ecs.component"
require "trigger"

Shockwave = Component:new()

function Shockwave:new(player, owner, startRadius, endRadius, obj)
	local eq = Component.new(self, "Shockwave", obj)

	eq.startRadius = startRadius
	eq.currentRadius = startRadius
	eq.endRadius = endRadius
	eq.expansionRate = 100
	eq.owningEntity = player or error("owningEntity cannot be nil")

	eq.trigger = Trigger:new(owner, owner.transform.position, startRadius)
	CurrentWorld:addTrigger(eq.trigger)

	return eq;
end

function Shockwave:start(entity)
end

function Shockwave:update(entity, dt)
	if (self.currentRadius > self.endRadius) then
		entity:kill()
		return
	end
	self.currentRadius = self.currentRadius + self.expansionRate * dt
	self.trigger.radius = self.currentRadius
end

function Shockwave:intersectTrigger(entity, startThisFrame)
	if entity == self.owningEntity then return end
	if entity:getTag("crystal") then
		local crystal = entity:getComponent("Crystal") 
		if crystal == nil then 
			crystal = entity:getComponent("EvilCrystal")
		end
		crystal:intersectTrigger(self, startThisFrame)
		return
	end
	local collision = entity:getComponent("Collider")
	local vec2other = entity.transform.position - self.owningEntity.transform.position
	collision:applyForce(vec2other.normalized * 2400)
end

function Shockwave:draw(entity)
	love.graphics.circle("line", 0, 0, self.currentRadius)
end

function Shockwave:onDestroy()
	--self.playerMovement:enable()
	self.trigger.isPendingKill = true
end
