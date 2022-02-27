--local Breezefield = require "vendor.breezefield.init"

World = {
	entities = {},
	name = "",
	physicsWorld = nil,
	triggers = {},
}

function World:new(name, Obj)
	Obj = Obj or {}
	setmetatable(Obj, self)
	self.__index = self
	self.name = name

	love.physics.setMeter(64)

	self.physicsWorld = love.physics.newWorld(0, 0, true)

	return Obj
end

function World:update(dt)
	self.physicsWorld:update(dt)

	local ei=1
	while ei <= #self.entities do
		local entity = self.entities[ei]
		entity:update(dt)
		-- All of the components should have updated
		-- Might want to move this to a post-update method
		if (entity.isPendingKill) then
			table.remove(self.entities, ei)
			entity:onDestroy()
		else
			ei = ei + 1
		end
		-- Check if entity is in any triggers

		local ti = 1
		while ti <= #self.triggers do
			local trigger = self.triggers[ti]
			-- some triggers will be removed
			if trigger.isPendingKill then
				table.remove(self.triggers, ti)
			else
				if (trigger:intersectsEntity(entity)) then
					trigger.owner:intersectTrigger(entity)
				end
				ti = ti + 1
			end
		end
	end
end

function World:draw()
	for _, entity in ipairs(self.entities) do
		entity:draw()
	end
end

function World:addEntity(entity)
	if entity.type == nil or entity.type ~= "Entity" then
		error("Tried to add non-entity to world")
	end

	table.insert(self.entities, entity)
end

function World:addTrigger(trigger)
	table.insert(self.triggers, trigger)
end

function World:__tostring()
	return self.name
end
