local Vector = require "../brinevector/brinevector"

Entity = {
	type = "Entity",
	transform = {
		position = Vector()
	},
	components = {},
}

function Entity:new(name, position, components)
	Obj = Obj or {}
	setmetatable(Obj, self)
	self.__index = self
	self.name = name

	if (position ~= nil) then
		Obj.transform.position = position
	end

	if (components ~= nil) then
		self.components = components
	end

	return Obj
end

function Entity:update(dt)
	for _, component in pairs(self.components) do
		component.update(self, dt)
	end
end

function Entity:draw()
	for _, component in pairs(self.components) do
		if (component["draw"] ~= nil) then
			component:draw()
		end
	end
end
