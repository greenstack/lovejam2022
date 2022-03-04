require "ecs.component"

Crystal = Component:new()

function Crystal:new(tileIndex, tileId, gridX, gridY, obj)
	local crystal = Component.new(self, "Crystal", obj)
	crystal.tileIndex = tileIndex
	crystal.tileId = tileId
	crystal.gridX = gridX
	crystal.gridY = gridY
	return crystal
end

function Crystal:start(entity)
	self.healthPool = entity:getComponent("Health")
	self.healthPool:registerDeathListener(function(pool) self:die() end)
end

function Crystal:intersectTrigger(entity, startThisFrame)
	if startThisFrame then
		if self.healthPool:getCurrent() > 0 then
			self.healthPool:loseHealth(1)
			CurrentWorld.map.layers.crystals:setTileAtGridPosition(
				self.gridX,
				self.gridY,
				CurrentWorld.map.layers.crystals.data[self.tileIndex] + 1
			)
		end
	end
end

function Crystal:die() 
	self.owner:kill()
end
