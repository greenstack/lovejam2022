require "components.crystal"
require "util.math"

local Vector = require "vendor.brinevector.brinevector"
local Color = require "color"

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
  warpSpot.crystal = eCrystal
  eCrystal.timeBetweenQuakes = 10
  eCrystal:_startOrResetQuakeTimer()
  return eCrystal
end

function EvilCrystal:_isValidSpawn(spawnDelta)
  local layer = CurrentWorld.map.layers.blocking
  local positionX, positionY = self:_getGridLocation()
  positionX = positionX + spawnDelta.x
  positionY = positionY + spawnDelta.y

  return layer:getTileAtGridPosition(positionX, positionY) == false
end

function EvilCrystal:start(entity)
  self.healthPool = entity:getComponent("Health")
  self.healthPool:registerDeathListener(function(pool)
    self:die()
  end)
  self.render = entity:getComponent("SpriteRender")

  self:_validateSpawns()
  self:_startOrResetQuakeTimer()
end

function EvilCrystal:update(entity, dt)
  if self.nextWarp then
    self:setWarpLocation(self.nextWarp)
    self.nextWarp = nil
  end

  self:handleChild(self.children.north, dt)
  self:handleChild(self.children.west, dt)
  self:handleChild(self.children.south, dt)
  self:handleChild(self.children.east, dt)

  --self.timeToQuake = self.timeToQuake - dt
  if self.timeToQuake <= 0 then
    print("big quake time")
    self:_startOrResetQuakeTimer()
    -- spawn a quake here
    local bigQuake = Entity:new(
      "crystalQuake",
      self.owner.transform.position,
      {
        enemy = true
      }
    )
    bigQuake:addComponent(Shockwave:new(self.owner, bigQuake, 0, 2048, Color(1, 0, 0)))
    bigQuake:setTag("enemy", true)
    CurrentWorld:addEntity(bigQuake)
  end
end

function EvilCrystal:draw(entity)
  love.graphics.arc("line", 0, 0, 8, -gs.math.piOver2, gs.math.twoPi * self.timeToQuake / self.timeBetweenQuakes - gs.math.piOver2)
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

  local healthLost = 4 - self.healthPool:getCurrent()
  local speed = 100 * healthLost
  local deathRadius = 15 * (healthLost + 1)
  return CurrentWorld:spawnEnemy(pixelX, pixelY, speed, deathRadius)
end

function EvilCrystal:die()
  self.owner:kill()
end

function EvilCrystal:onDestroy() end

function EvilCrystal:beginContact(entity, collision)
  -- ignore all enemy contact
  if entity.tags.enemy then
    return
  end

  local fixtureA, fixtureB = collision:getFixtures()
  local myFixture = self.owner:getComponent("Collider").fixture
  local theirFixture
  if fixtureA == myFixture then theirFixture = fixtureB else theirFixture = fixtureA end

  -- We only want to react to quakes for now
  if not theirFixture:isSensor() then
    return
  end

  -- update animation
  self.healthPool:loseHealth(1)
  if self.healthPool:getCurrent() == 2 then
    self.render:setTag("spin_damaged")
  elseif self.healthPool:getCurrent() == 1 then
    self.render:setTag("spin_critical")
  end

  -- don't warp if dead
  if self.owner.isPendingKill then
    self.warpSpot.crystal = nil
    self.warpSpot = nil
    return
  end

  print "trying to warp"
  -- now to warp to a valid location for safety's sake
  local nextWarp = CurrentWorld.warpSpots[love.math.random(#CurrentWorld.warpSpots)]
  while nextWarp:isOccupied() do
    print "warp was occupied"
    nextWarp = CurrentWorld.warpSpots[love.math.random(#CurrentWorld.warpSpots)]
  end
  -- set this. When the post-resolve methods for collisions are called, we will
  -- then check if this is nil. If it isn't, then we'll warp to that location.
  self.nextWarp = nextWarp
  self:_startOrResetQuakeTimer()
end

function EvilCrystal:setWarpLocation(warpSpot)
  self.warpSpot.crystal = nil
  self.warpSpot = warpSpot
  warpSpot.crystal = self
  self.owner.transform.position = warpSpot.position
  -- TODO: This is where we are breaking now. Can't warp while the collision is
  -- locked - perhaps post-resolve?
  self.owner:getComponent("Collider").body:setPosition(warpSpot.position:split())

  self:_validateSpawns()
end

function EvilCrystal:_validateSpawns()
  self.children.north.canSpawn = self:_isValidSpawn(self.children.north.spawnDelta)
  self.children.south.canSpawn = self:_isValidSpawn(self.children.south.spawnDelta)
  self.children.east.canSpawn = self:_isValidSpawn(self.children.east.spawnDelta)
  self.children.west.canSpawn = self:_isValidSpawn(self.children.west.spawnDelta)
end

function EvilCrystal:_startOrResetQuakeTimer()
  self.timeToQuake = self.timeBetweenQuakes
end
