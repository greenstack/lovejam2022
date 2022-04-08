require "ecs.component"

Crystal = Component:new()

function Crystal:new(tileIndex, tileId, gridX, gridY, obj)
	local crystal = Component.new(self, "Crystal", obj)
	crystal.tileIndex = tileIndex
	crystal.tileId = tileId
	crystal.gridX = gridX
	crystal.gridY = gridY
	crystal.immunities = {}
	return crystal
end

function Crystal:start(entity)
	self.healthPool = entity:getComponent("Health")
	self.healthPool:registerDeathListener(function(pool) self:die() end)
end

function Crystal:beginContact(entity, contact)
	-- Only let this guy hit us once
	if self.immunities[entity.name] == nil then
		self.immunities[entity.name] = true
	else
		return
	end

	local fixtureA, fixtureB = contact:getFixtures()
  local myFixture = self.owner:getComponent("Collider").fixture
  local theirFixture
	print("checking if their fixture is a sensor")
  if fixtureA == myFixture then theirFixture = fixtureB else theirFixture = fixtureA end

  -- We only want to react to quakes for now
  if not theirFixture:isSensor() then
    return
  end

	if self.healthPool:getCurrent() > 0 then
		-- If the quake is a big quake, we want to add the owner of the
		-- shockwave to an "immunity" list. For a time, the crystal is immune to
		-- shockwaves emitted by crystals in that immunity list.
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
