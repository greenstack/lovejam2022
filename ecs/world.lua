require "components.health"
require "components.crystal"
require "components.enemy"
require "components.evilCrystal"
require "components.render.spriteRender"

local Cartographer = require "vendor.cartographer.cartographer"
local Gamera = require "vendor.gamera.gamera"
local Vector = require "vendor.brinevector.brinevector"
local Color = require "color"

World = {
	entities = {},
	name = "",
	physicsWorld = nil,
	player = nil,
}

function World:new(name, mapPath, tileSize, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.entities = {}
	obj.name = name
	obj.player = nil
	-- Set up the physical world
	love.physics.setMeter(tileSize)
	obj.physicsWorld = love.physics.newWorld(0, 0, true)
	obj.physicsWorld:setCallbacks(
		function(a, b, coll) obj:beginContact(a, b, coll) end,
		function(a, b, coll) obj:endContact(a, b, coll) end,
		function(a, b, coll) obj:preSolve(a, b, coll) end,
		function(a, b, coll, normalimpulse, tangential) obj:postSolve(a, b, coll, normalimpulse, tangential) end
	)

	-- Set up the map
	obj.map = Cartographer.load(mapPath)
	obj:_initBlockingLayer(tileSize)
	obj:_initCrystalLayer(tileSize)
	obj:_initEvilCrystalWarps()

	obj.camera = Gamera.new(obj.map.layers.blocking:getPixelBounds())
	obj.camera:setScale(2.5)

	obj.playerScore = 0
	obj.isGameOver = false
	return obj
end

function World:setPlayer(player)
	self.player = player
end

function World:_initBlockingLayer(tileWidth, tileHeight)
	tileHeight = tileHeight or tileWidth
	for _, _, _, _, pixelX, pixelY in self.map.layers.blocking:getTiles() do
		local obstacleBody = love.physics.newBody(
			self.physicsWorld,
			pixelX + tileWidth / 2,
			pixelY + tileHeight / 2,
			"static"
		)
		local obstacleShape = love.physics.newRectangleShape(tileWidth, tileHeight)
		love.physics.newFixture(obstacleBody, obstacleShape)
	end
end

function World:_initCrystalLayer(tileSize)
	-- Going to need all this data I think
	local crystalCount = 0
	self.worldCrystals = {}
	for tileIndex, globalId, gridX, gridY, pixelX, pixelY in self.map.layers.crystals:getTiles() do
		local healthComp = HealthComponent:new(3)
		healthComp:registerDeathListener(function(comp) self:onGoodCrystalDead(comp) end)
		-- Set up the good crystal entities
		local crystal = Entity:new("crytal_" .. crystalCount,
			Vector(pixelX + 8, pixelY + 8),
			{
				healthComp,
				Crystal:new(tileIndex, globalId, gridX, gridY),
			},
			{
				crystal = true,
				enemy = false,
			}
		)

		crystal:addComponent(CollisionComponent:new(crystal, "static", self, 1000000000, false))
		crystalCount = crystalCount + 1
		self:addEntity(crystal)
		table.insert(self.worldCrystals, crystal)
	end
	self.crystalCount = crystalCount
	self.totalCrystalCount = crystalCount
end

function World:_initEvilCrystals(tileSize)
	local evilCrystalCount = 0
	for _, _, _, _, pixelX, pixelY in self.map.layers.evilCrystals:getTiles() do
		local healthComp = HealthComponent:new(3)
		healthComp:registerDeathListener(function(comp) self:onEvilCrystalDead(comp) end)
		local crystal = Entity:new("evilCrystal_" .. evilCrystalCount,
			Vector(pixelX + 8, pixelY + 8),
			{
				healthComp,
				SpriteRender:new("assets/sprites/evil_crystal.json", "assets/sprites/evil_crystal.png", "spin_full_hp"),
				EvilCrystal:new(),
			},
			{
				crystal = true,
			}
		)
		crystal:addComponent(CollisionComponent:new(crystal, "static", self, 1000000))
		self:addEntity(crystal)
	end
	self.evilCrystalCount = evilCrystalCount
end

function World:_initEvilCrystalWarps()
	local warpSpotCount = 0
	self.warpSpots = {}
	local evilCrystalCount = 0
	for _, gid, gridX, gridY, pixelX, pixelY in self.map.layers.evilCrystalWarpPoints:getTiles() do
		if gid == 0 then goto continue end
		warpSpotCount = warpSpotCount + 1
		local warpSpot = {
			position = Vector(pixelX + 8, pixelY + 8),
			crystal = nil,
			isOccupied = function(warpSpot) return warpSpot.crystal ~= nil end,
		}
		-- add a spot
		table.insert(self.warpSpots, warpSpot)

		-- If this spot also has a crystal here at the start, create it
		print(string.format("gridX: %d; gridY: %d, tileId: %d", gridX, gridY, self.map.layers.evilCrystals:getTileAtGridPosition(gridX, gridY) or 0))
		if self.map.layers.evilCrystals:getTileAtGridPosition(gridX, gridY) then
			local crystal = self:_spawnEvilCrystal(evilCrystalCount, warpSpot)
			evilCrystalCount = evilCrystalCount + 1
			self:addEntity(crystal)
		end

		::continue::
	end
	self.evilCrystalCount = evilCrystalCount
	self.totalEvilCrystalCount = evilCrystalCount
end

function World:_spawnEvilCrystal(crystalNumber, warpSpot)
	local healthComp = HealthComponent:new(3)
	healthComp:registerDeathListener(function(comp) self:onEvilCrystalDead(comp) end)
	local crystal = Entity:new("evilCrystal_" .. crystalNumber,
		Vector(warpSpot.position.x, warpSpot.position.y),
		{
			healthComp,
			EvilCrystal:new(warpSpot),
			SpriteRender:new("assets/sprites/evil_crystal.json", "assets/sprites/evil_crystal.png", "spin_full_hp"),
		},
		{
			crystal = true,
			enemy = true,
		}
	)
	crystal:addComponent(CollisionComponent:new(crystal, "dynamic", self, 1000000000))

	return crystal
end

function World:beginContact(a, b, coll)
	local colliderA = a:getUserData()
	local colliderB = b:getUserData()

	if DEBUG_MODE then
		local caName, cbName
		if colliderA then
			caName = tostring(colliderA.owner)
		else
			caName = "Unknown (A)"
		end
		if colliderB then
			cbName = tostring(colliderB.owner)
		else
			cbName = "Unknown (B)"
		end
		--print("contact begin between " .. caName .. " and " .. cbName)
	end

	if colliderA and colliderB and colliderA.owner ~= colliderB.owner and colliderA:Started() and colliderB:Started() then
		colliderA.owner:beginContact(colliderB.owner, coll)
		colliderB.owner:beginContact(colliderA.owner, coll)
	end
end

function World:endContact(a, b, coll)
	local colliderA = a:getUserData()
	local colliderB = b:getUserData()
	
	if colliderA and colliderB and colliderA.owner ~= colliderB.owner and colliderA:Started() and colliderB:Started() then
		colliderA.owner:endContact(colliderB.owner, coll)
		colliderB.owner:endContact(colliderA.owner, coll)
	end
end

function World:preSolve(a, b, coll)
	local colliderA = a:getUserData()
	local colliderB = b:getUserData()

	if colliderA and colliderB and colliderA:Started() and colliderB:Started() then
		colliderA.owner:preSolve(colliderB.owner, coll)
		colliderB.owner:preSolve(colliderA.owner, coll)
	end
end

function World:postSolve(a, b, coll, normalimpulse, tangentimpulse)
	local colliderA = a:getUserData()
	local colliderB = b:getUserData()

	if colliderA and colliderB and colliderA:Started() and colliderB:Started() then
		colliderA.owner:postSolve(colliderB.owner, coll, normalimpulse, tangentimpulse)
		colliderB.owner:postSolve(colliderA.owner, coll, normalimpulse, tangentimpulse)
	end
end

function World:update(dt)
	if self.pauseUpdates then return end

	self.physicsWorld:update(dt)
	self.map:update(dt)

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
	end

	self.camera:setPosition(self.player.transform.position.x, self.player.transform.position.y)

	if self.needToSpawnCrystals == true then
		self:spawnEvilCrystalsAtRandom(math.min(self.totalEvilCrystalCount + 1, #self.warpSpots - 1))
		self.needToSpawnCrystals = false
	end
end

function World:draw()
	self.camera:draw(function() self:drawAll() end)
end

function World:drawAll()
	self:drawMap()
	self:drawEntities()
end

function World:drawMap()
	self.map:draw()
end

function World:drawEntities()
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

function World:__tostring()
	return self.name
end

function World:onGoodCrystalDead(healthComp)
	self.crystalCount = self.crystalCount - 1
	if self.crystalCount <= 0 then
		self.player:die()
	end
end

function World:onEvilCrystalDead(healthComp)
	self.evilCrystalCount = self.evilCrystalCount - 1
	if self.evilCrystalCount <= 0 then
		self.needToSpawnCrystals = true
	end
	self.playerScore = self.playerScore + 300
end

function World:spawnEvilCrystalsAtRandom(crystalCount)
	if crystalCount > #self.warpSpots then error("too many crystals requested!") end
	for i = 1, crystalCount, 1 do
		-- get a warp spot
		local warpSpot = self:getRandomWarpSpot()
		while warpSpot:isOccupied() do
			warpSpot = self:getRandomWarpSpot()
		end
		local newCrystal = self:_spawnEvilCrystal(i, warpSpot)
		self:addEntity(newCrystal)
	end
	self.evilCrystalCount = crystalCount
	self.totalEvilCrystalCount = crystalCount
end

function World:getRandomWarpSpot()
	return self.warpSpots[love.math.random(#CurrentWorld.warpSpots)]
end

function World:spawnEnemy(pixelX, pixelY, speed, deathRadius)
	local enemyComponents = {
		SpriteRender:new("assets/sprites/enemy.json", "assets/sprites/enemy.png", "default"),
		Enemy:new(self.player, speed, deathRadius),
		HealthComponent:new(2),
	}
	local enemy = Entity:new("enemy", Vector(pixelX, pixelY), enemyComponents,
		{
			enemy = true,
			crystal = false,
		}
	)
	enemy:addComponent(CollisionComponent:new(enemy, "dynamic", nil, 1))
	self:addEntity(enemy)
	return enemy
end

function World:gameOver(isVictory)
	self.pauseUpdates = true
	self.victory = isVictory
	self.isGameOver = true
	if not isVictory then

	end
end
