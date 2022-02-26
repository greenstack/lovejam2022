local Vector = require "vendor.brinevector.brinevector"
local Entity = {
	type = "Entity",
	transform = {
		position = Vector()
	},
	components = {},
}
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

function Entity:update(dt)
	for _, component in ipairs(self.components) do
		component:update(self, dt)
	end
end

function Entity:draw()
	for _, component in ipairs(self.components) do
		love.graphics.push()
		love.graphics.translate(self.transform.position.x, self.transform.position.y)
		component:draw(self)
		love.graphics.pop()
	end
end

function Entity:getComponent(componentType)
	for _, component in pairs(self.components) do
		if (component.type == componentType) then
			return component
		end
	end
	return nil
end

return Entity
