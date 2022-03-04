require "components.health"
require "components.crystal"
require "components.evilCrystal"

local Cartographer = require "vendor.cartographer.cartographer"
local Gamera = require "vendor.gamera.gamera"
local Vector = require "vendor.brinevector.brinevector"

World = {
	entities = {},
	name = "",
	physicsWorld = nil,
	triggers = {},
}

function World:new(name, mapPath, tileSize, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.name = name

	-- Set up the physical world
	love.physics.setMeter(tileSize)
	self.physicsWorld = love.physics.newWorld(0, 0, true)
	
	-- Set up the map
	self.map = Cartographer.load(mapPath)
	self:_initBlockingLayer(tileSize)
	self:_initCrystalLayer(tileSize)
	--self:_initEvilCrystals(tileSize)
	self:_initEvilCrystalWarps()

	self.camera = Gamera.new(self.map.layers.blocking:getPixelBounds())
	self.camera:setScale(2.5)

	self.playerScore = 0
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
			-- Because of collision stuff, the collisions aren't in the right
			-- place! TODO: Fix this!
			-- TODO: When all crystals are destroyed, game over!
			Vector(pixelX + 8, pixelY + 8),
			{
				healthComp,
				Crystal:new(tileIndex, globalId, gridX, gridY),
			},
			{
				crystal = true,
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
			SpriteRender:new("assets/sprites/evil_crystal.json", "assets/sprites/evil_crystal.png", "spin_full_hp"),
			EvilCrystal:new(warpSpot),
		},
		{
			crystal = true,
		}
	)
	crystal:addComponent(CollisionComponent:new(crystal, "static", self, 1000000))
	return crystal
end

function World:update(dt)
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
		-- Check if entity is in any triggers

		self:updateTriggers(dt, entity)
	end

	self.camera:setPosition(self.player.transform.position.x, self.player.transform.position.y)
end

function World:updateTriggers(dt, entity)
	local ti = 1
	while ti <= #self.triggers do
		local trigger = self.triggers[ti]
		-- some triggers will be removed
		if trigger.isPendingKill then
			table.remove(self.triggers, ti)
		else
			-- It should be entity:startIntersection(trigger)
			-- entity:continueIntersection(trigger)
			-- entity:endIntersection(trigger)
			if (trigger:intersectsEntity(entity)) then
				if entity:getTag("intersecting") == false then
					trigger.owner:intersectTrigger(entity, true)
					entity:setTag("intersecting", true)
				else
					trigger.owner:intersectTrigger(entity, false)
				end
			else
				-- TODO: End intersection trigger?
				entity:setTag("intersecting", false)
			end
			ti = ti + 1
		end
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

function World:addTrigger(trigger)
	table.insert(self.triggers, trigger)
end

function World:__tostring()
	return self.name
end

function World:onGoodCrystalDead(healthComp)
	self.crystalCount = self.crystalCount - 1
	if self.crystalCount <= 0 then
		error("game over!")
	end
end

function World:onEvilCrystalDead(healthComp)
	self.evilCrystalCount = self.evilCrystalCount - 1
	if self.evilCrystalCount <= 0 then
		self:spawnEvilCrystalsAtRandom(2)
	end
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
