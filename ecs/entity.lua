local Vector = require "vendor.brinevector.brinevector"
Entity = {
	type = "Entity",
	transform = {
		position = Vector()
	},
	components = {},
	isPendingKill = false,
	tags = {}
}

function Entity:new(name, position, components, tags, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.name = name or ""
	obj.transform = {}
	obj.transform.position = position or Vector()
	obj.components = {}
	for _, comp in ipairs(components) do
		obj:addComponent(comp)
	end
	obj.tags = tags or {}

	return obj
end

function Entity:update(dt)
	for _, component in ipairs(self.components) do
		if not component:Started() and component.enabled then
			component:init(self)
		end
		if component.enabled then
			component:update(self, dt)
		end
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

function Entity:addComponent(component)
	component.owner = self
	table.insert(self.components, component)
end

function Entity:setTag(tag, value)
	self.tags[tag] = value
end

function Entity:intersectTrigger(other)
	for _, v in pairs(self.components) do
		v:intersectTrigger(other)
	end
end

function Entity:kill()
	self.isPendingKill = true
end

function Entity:onDestroy() 
	for _, comp in pairs(self.components) do
		comp:onDestroy()
	end
end

function Entity:__tostring()
	return self.name
end
