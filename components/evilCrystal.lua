require "components.crystal"

local Vector = require "vendor.brinevector.brinevector"

EvilCrystal = Component:new()

function EvilCrystal:new(warpSpot, obj)
  local eCrystal = Component.new(self, "EvilCrystal", obj)
  eCrystal.children = {
    north = {
      alive = false,
      canSpawn = false,
      entity = nil,
      timeTilSpawn = 5,
      spawnDelta = Vector.dir("up"),
    },
    west = {
      alive = false,
      canSpawn = false,
      entity = nil,
      timeTilSpawn = 5,
      spawnDelta = Vector.dir("left"),
    },
    south = {
      alive = false,
      canSpawn = false,
      entity = nil,
      timeTilSpawn = 5,
      spawnDelta = Vector.dir("down"),
    },
    east = {
      alive = false,
      canSpawn = false,
      entity = nil,
      timeTilSpawn = 5,
      spawnDelta = Vector.dir("right"),
    }
  }
  eCrystal.warpSpot = warpSpot
  return eCrystal
end

function EvilCrystal:_isValidSpawn(spawnDelta)
  local layer = CurrentWorld.map.layers.blocking
  local positionX, positionY = self:_getGridLocation()
  positionX = positionX + spawnDelta.x
  positionY = positionY + spawnDelta.y

  return layer:getTileAtGridPosition(positionX, positionY) == 0
end

function EvilCrystal:start(entity)
  self.healthPool = entity:getComponent("Health")
  self.healthPool:registerDeathListener(function(pool)
    self:die()
  end)
  self.render = entity:getComponent("SpriteRender")

  self.children.north.canSpawn = self:_isValidSpawn(self.children.north.spawnDelta)
  self.children.south.canSpawn = self:_isValidSpawn(self.children.south.spawnDelta)
  self.children.east.canSpawn = self:_isValidSpawn(self.children.east.spawnDelta)
  self.children.west.canSpawn = self:_isValidSpawn(self.children.west.spawnDelta)
end

function EvilCrystal:update(entity, dt)
  self:handleChild(self.children.north, dt)
  self:handleChild(self.children.west, dt)
  self:handleChild(self.children.south, dt)
  self:handleChild(self.children.east, dt)
end

function EvilCrystal:handleChild(child, dt)
  if child.entity and child.entity.isPendingKill then
    child.entity = nil
    child.timeTilSpawn = 5
  elseif child.entity == nil and child.canSpawn then
    -- We need to spawn them if time's not expired
    child.timeTilSpawn = child.timeTilSpawn - dt
    if (child.timeTilSpawn <= 0) then
      child.entity = self:spawnChild(child)
    end
  end
end

function EvilCrystal:_getGridLocation()
  return CurrentWorld.map.layers.crystals:pixelToGrid(self.owner.transform.position:split())
end

function EvilCrystal:spawnChild(childData)
  local layer = CurrentWorld.map.layers.crystals
  local tilePosX, tilePosY = self:_getGridLocation()
  tilePosX = tilePosX + childData.spawnDelta.x
  tilePosY = tilePosY + childData.spawnDelta.y
  local pixelX, pixelY = layer:gridToPixel(tilePosX, tilePosY)

  local enemy = Entity:new("ecchild", Vector(pixelX + 8, pixelY + 8), {
    SpriteRender:new("assets/sprites/craggy.json", "assets/sprites/craggy.png", "default")
  }, {enemy = true})
  local collision = CollisionComponent:new(enemy, "dynamic", CurrentWorld, 1)
  enemy:addComponent(collision)
  CurrentWorld:addEntity(enemy)
  return enemy
end

function EvilCrystal:die()
  self.owner:kill()
end

function EvilCrystal:intersectTrigger(entity, startThisFrame)
	-- update animation
  if startThisFrame then
		self.healthPool:loseHealth(1)
		if self.healthPool:getCurrent() == 2 then
      self.render:setTag("spin_damaged")
    elseif self.healthPool:getCurrent() == 1 then
      self.render:setTag("spin_critical")
    end

    print "trying to warp"
    -- now to warp to a valid location for safety's sake
    local nextWarp = CurrentWorld.warpSpots[love.math.random(#CurrentWorld.warpSpots)]
    while nextWarp:isOccupied() do
      print "warp was occupied"
      nextWarp = CurrentWorld.warpSpots[love.math.random(#CurrentWorld.warpSpots)]
    end
    self:setWarpLocation(nextWarp)
    
	end
end

function EvilCrystal:setWarpLocation(warpSpot)
  self.warpSpot.crystal = nil
  self.warpSpot = warpSpot
  warpSpot.crystal = self
  self.owner.transform.position = warpSpot.position
  self.owner:getComponent("Collider").body:setPosition(warpSpot.position:split())
end
