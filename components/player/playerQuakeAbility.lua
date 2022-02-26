require "components.player.playerAbilityComponent"
require "components.player.earthquake"
local Entity = require "ecs.entity"

PlayerQuakeAbility = PlayerAbilityComponent:new()

function PlayerQuakeAbility:new(obj)
	local pqa = PlayerAbilityComponent:new(self, "PlayerQuakeAbility", obj)
	return pqa
end

function PlayerQuakeAbility:abilityStart(entity)
	
end

function PlayerQuakeAbility:abilityEnd(entity)
	CurrentWorld:addEntity(
		Entity("earthquake",
		entity.transform.position,
		{Earthquake:new(0, 10),}
	))
end
