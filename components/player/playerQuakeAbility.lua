require "components.collision"
require "components.player.playerAbilityComponent"
require "components.player.earthquake"
require "ecs.entity"

PlayerQuakeAbility = PlayerAbilityComponent:new()

function PlayerQuakeAbility:new(obj)
	local pqa = PlayerAbilityComponent:new(self, "PlayerQuakeAbility", obj)

	return pqa
end

function PlayerQuakeAbility:abilityStart(entity)
end

function PlayerQuakeAbility:abilityEnd(entity)
	local earthquake = Entity:new("earthquake",
		entity.transform.position,
		{}
	)
	earthquake:addComponent(Shockwave:new(entity, earthquake, 0, 50))
	CurrentWorld:addEntity(earthquake)
end
