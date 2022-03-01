require "ecs.component"

Crystal = Component:new()

function Crystal:new(obj)
	local crystal = Component.new(self, "Crystal", obj)

	return crystal
end

function Crystal:start(entity)
	self.healthPool = entity:getComponent("Health")
	self.healthPool:registerDeathListener(function(pool) self:die() end)
end

function Crystal:intersectTrigger(entity, startThisFrame)
	if startThisFrame then
		self.healthPool:loseHealth(1)
	end
	-- TODO: set sprite according to damage
end

function Crystal:die() 
	--TODO: implement this
end
