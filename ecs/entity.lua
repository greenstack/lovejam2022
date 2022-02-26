local Vector = require "vendor.brinevector.brinevector"
Entity = {
	type = "Entity",
	transform = {
		position = Vector()
	},
	components = {},
	isPendingKill = false,
}

function Entity:new(name, position, components, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.name = name or ""
	obj.transform = {}
	obj.transform.position = position or Vector()
	obj.components = components or {}

	return obj
end

function Entity:update(dt)
	for _, component in ipairs(self.components) do
		component:update(self, dt)
		-- TODO: Enable component removal
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

function Entity:kill()
	self.isPendingKill = true
end

function Entity:__tostring()
	return self.name
end
