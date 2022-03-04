require "ecs.component"

Enemy = Component:new()

function Enemy:new(player, detectionRange, obj)
	local enemy = Component.new(self, "Enemy", obj)
	-- setup defaults
	enemy.player = player or error("enemies need a player to track")
	enemy.detectionRange = detectionRange or 250

	return enemy
end

local once = 0

function Enemy:start()
	self.collision = self.owner:getComponent("Collider")
end

function Enemy:update()
	--if once ~= 0 then return end
	-- lets first blindly pathfind to the player
	--local sgx, sgy = self.owner:getGridPosition()
	--local pgx, pgy = self.player:getGridPosition()
	--local path = CurrentWorld:getPath(sgx, sgy, pgx, pgy)
	--if path then
		--for _, p in ipairs(path) do
			--print(p.x, p.y)
		--end
	--end
	self.collision:applyForce((self.player.transform.position - self.owner.transform.position).normalized * 100)
end
