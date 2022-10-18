require "ecs.component"

local Color = require "color"

Enemy = Component:new()

function Enemy:new(player, speed, deathRadius, obj)
	local enemy = Component.new(self, "Enemy", obj)
	-- setup defaults
	enemy.player = player or error("enemies need a player to track")
	enemy.speed = speed or error("set a speed")
	enemy.deathRadius = deathRadius

	enemy._iframes = 0

	return enemy
end

function Enemy:start()
	self.collision = self.owner:getComponent("Collider")
	self.owner:getComponent("Health"):registerDeathListener(function(pool)
		self.owner:kill()
	end)
end

function Enemy:update(entity, dt)
	self.collision:applyForce((self.player.transform.position - self.owner.transform.position).normalized * self.speed)

	if self:isInvincible() then
		self._iframes = self._iframes - dt
	end
end

function Enemy:onDestroy()
	if not self.notPlayerKill then
		CurrentWorld.playerScore = CurrentWorld.playerScore + 30
	end
end

local quakes_created = 0

function Enemy:beginContact(other, coll)
	if other:getTag("enemy") or other:getTag("crystal") then return end
	if other:getTag("player") then self.notPlayerKill = true end
	self.owner:kill()

	local fixtureA, fixtureB = coll:getFixtures()
  local myFixture = self.owner:getComponent("Collider").fixture
  local theirFixture
  if fixtureA == myFixture then theirFixture = fixtureB else theirFixture = fixtureA end

  -- We only want to react to players for now
  if theirFixture:isSensor() then
    return
  end

	-- create shockwave
	local earthquake = Entity:new(
		"enemyQuake_" .. quakes_created,
		self.owner.transform.position,
		{
			enemy = true,
		}
	)
	quakes_created = quakes_created + 1
	earthquake:addComponent(Shockwave:new(self.owner, earthquake, 0, self.deathRadius, Color(1, 0, 1)))
	earthquake:setTag("enemy", true)
	CurrentWorld:addEntity(earthquake)
end

function Enemy:intersectTrigger(entity, startThisFrame)
	--should've done a team tag instead... oh well, too late now!
	if entity.owner.tags.enemy or not startThisFrame then return end

	-- remove 1 hp
	self.owner:getComponent("Health").loseHealth(1)
end

function Enemy:isInvincible()
	return self._iframes > 0
end

function Enemy:activateIFrames()
	self._iframes = 0.25
end
