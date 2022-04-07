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

function Crystal:beginContact(entity, contact)
	local fixtureA, fixtureB = contact:getFixtures()
  local myFixture = self.owner:getComponent("Collider").fixture
  local theirFixture
  if fixtureA == myFixture then theirFixture = fixtureB else theirFixture = fixtureA end

  -- We only want to react to quakes for now
  if not theirFixture:isSensor() then
    return
  end

	if self.healthPool:getCurrent() > 0 then
		self.healthPool:loseHealth(1)
		CurrentWorld.map.layers.crystals:setTileAtGridPosition(
			self.gridX,
			self.gridY,
			CurrentWorld.map.layers.crystals.data[self.tileIndex] + 1
		)
	end
end

function Crystal:die() 
	self.owner:kill()
end
