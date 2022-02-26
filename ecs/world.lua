World = {
	entities = {},
	name = ""
}

function World:new(name)
	Obj = Obj or {}
	setmetatable(Obj, self)
	self.__index = self
	self.name = name
	return Obj
end

function World:update(dt)
	for _, entity in ipairs(self.entities) do
		entity:update(dt)
	end
end

function World:draw()
	for _, entity in ipairs(self.entities) do
		entity:draw()
	end
end

function World:addEntity(entity)
	if entity.type == nil or entity.type ~= "Entity" then
		error("Tried to add non-entity to world")
	end

	table.insert(self.entities, entity)
end

function World:__tostring()
	return self.name
end
