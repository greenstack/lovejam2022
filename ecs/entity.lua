local Vector = require "vendor.brinevector.brinevector"
local Entity = {}
setmetatable(Entity, Entity)

function Entity.__call(t, name, position, components)
	return setmetatable({
		type = "Entity",
		name = name or "",
		transform = {
			position = position or Vector()
		},
		components = components or {}
	}, Entity)
end

function Entity:__tostring()
	return self.name
end

function Entity.update(e, dt)
	for _, component in ipairs(e.components) do
		component:update(e, dt)
	end
end

function Entity.draw(e)
	for _, component in ipairs(e.components) do
		love.graphics.push()
		love.graphics.translate(e.transform.position.split())
		component:draw(e)
		love.graphics.pop()
	end
end

function Entity.getComponent(e, componentType)
	for _, component in pairs(e.components) do
		if (component.type == componentType) then
			return component
		end
	end
	return nil
end

return Entity
