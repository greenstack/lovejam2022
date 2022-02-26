Component = {
	type = "",
	name = "",
	enabled = true,
}

local componentRegistry = {}

local function getComponentName(componentType)
	if componentType == nil then return "" end

	local componentIndex = componentRegistry[componentType] or 0
	componentRegistry[componentType] = componentIndex + 1
	return componentType .. "_" .. componentIndex
end

function Component:new(componentName, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.type = componentName
	obj.name = getComponentName(componentName)

	return obj
end

function Component:update(entity, dt) end

function Component:draw(entity) end

function Component:enable() self.enabled = true end

function Component:disable() self.enabled = false end

function Component:__tostring()
	return self.name
end
