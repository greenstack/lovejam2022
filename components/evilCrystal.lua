require "components.crystal"

EvilCrystal = Component:new()

function EvilCrystal:new(obj)
  local eCrystal = Component.new(self, "EvilCrystal", obj)
  return eCrystal
end

function EvilCrystal:start(entity)
  self.healthPool = entity:getComponent("Health")
  self.healthPool:registerDeathListener(function(pool)
    self:die()
  end)
  self.render = entity:getComponent("SpriteRender")
end

function EvilCrystal:die()
  self.owner:kill()
end

function EvilCrystal:intersectTrigger(entity, startThisFrame)
	if startThisFrame then
		self.healthPool:loseHealth(1)
		if self.healthPool:getCurrent() == 2 then
      self.render:setTag("spin_damaged")
    elseif self.healthPool:getCurrent() == 1 then
      self.render:setTag("spin_critical")
    end
	end
end
