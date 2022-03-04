local Color = require "color"
local Vector = require "vendor.brinevector.brinevector"

Bar = {
	name = "",
	currentValue = 1,
	maxValue = 1,
	color = Color(),
	position = Vector(),
	width = 10,
	height = 10,
	currentValueSource = function() return 0 end,
	maxValueSource = function() return 100 end,
}

function Bar:new(name, position, color, width, height, obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.name = name or ""
	obj.position = position or Vector()
	obj.color = color or Color()
	obj.width = width or 100
	obj.height = height or 10

	return obj
end

function Bar:draw()
	local dr,dg,db,da = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle(
		"fill",
		self.position.x,
		self.position.y,
		self.width,
		self.height,
		3,
		3
	)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.rectangle(
		"fill",
		self.position.x,
		self.position.y,
		self.currentValueSource() / self.maxValueSource() * self.width,
		self.height,
		3,
		3
	)
	love.graphics.setColor(dr, dg, db, da)
end
