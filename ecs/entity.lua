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
	for _, comp in ipairs(components or {}) do
		obj:addComponent(comp)
	end
	obj.tags = tags or {}

	return obj
end

function Entity:update(dt)
	self:updateComponents(dt)
end

function Entity:updateComponents(dt)
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
	self:drawComponents()
	--self:drawDebug()
end

function Entity:drawDebug()
	if DEBUG_MODE and DRAW_DEBUG then
		-- calculate string length
		-- draw it where the entity is
		love.graphics.printf(
			self:__tostring(), 
			0, --self.transform.position.x,
			0, --self.transform.position.y,
			100,
			"center"
		)
	end
end

function Entity:drawComponents()
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

function Entity:getTag(tag)
	return self.tags[tag]
end

function Entity:intersectTrigger(other, startThisFrame)
	for _, v in pairs(self.components) do
		v:intersectTrigger(other, startThisFrame)
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

function Entity:getGridPosition()
	return CurrentWorld.map.layers.blocking:pixelToGrid(self.transform.position:split())
end

function Entity:__tostring()
	return self.name
end
