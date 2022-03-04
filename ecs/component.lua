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
	obj.enabled = true
	obj._started = false

	return obj
end

function Component:init(entity)
	self:start(entity)
	self._started = true
end

function Component:Started()
	return self._started
end

function Component:start(entity) end

function Component:update(entity, dt) end

function Component:draw(entity) end

function Component:enable() self.enabled = true end

function Component:disable() self.enabled = false end

function Component:onCollision(entity, collisions) end

function Component:beginContact(other, coll) end
function Component:endContact(other, coll) end
function Component:preSolve(other, coll) end
function Component:postSolve(other, coll, normalImpulse, tangentImpulse) end

function Component:intersectTrigger(entity) end

-- Triggers when either the component or owning entity are destroyed/killed
function Component:onDestroy() end

function Component:endCollision(entity, collisions) end

function Component:__tostring()
	return self.name
end
