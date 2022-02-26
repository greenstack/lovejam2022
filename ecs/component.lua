Component = {
	name = "",
}

function Component:new(componentName)
	Obj = Obj or {}
	setmetatable(Obj, self)
	self.__index = self
	Obj.name = componentName
	return Obj
end

function Component:update(entity, dt)
end
