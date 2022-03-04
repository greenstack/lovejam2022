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
	self.collision:applyForce((self.player.transform.position - self.owner.transform.position).normalized * 100)
end
