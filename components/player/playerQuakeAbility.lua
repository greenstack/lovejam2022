require "components.player.playerAbilityComponent"
require "components.player.earthquake"
require "ecs.entity"

PlayerQuakeAbility = PlayerAbilityComponent:new()

function PlayerQuakeAbility:new(obj)
	local pqa = PlayerAbilityComponent:new(self, "PlayerQuakeAbility", obj)

	pqa.quakesCreated = 0

	return pqa
end

function PlayerQuakeAbility:abilityStart(entity)
end

function PlayerQuakeAbility:abilityEnd(entity)
	local earthquake = Entity:new("earthquake" .. self.quakesCreated,
		entity.transform.position,
		{Earthquake:new(0, 50),}
	)	
	CurrentWorld:addEntity(earthquake)
	self.quakesCreated = self.quakesCreated + 1
end
