local Color = require "color"
require "ecs.component"

SimpleRectRender = Component:new()

function SimpleRectRender:new(color, obj)
	local render = Component.new(self, "SimpleRectRender", obj)

	render.color = color or Color()

	return render
end

function SimpleRectRender:draw(entity)
	-- cache colors
	local r,g,b,a = love.graphics.getColor()
	--local lr, lg, lb, la = self.color:values()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.rectangle("fill", -5, -5, 10, 10)
	-- reset colors
	love.graphics.setColor(r,g,b,a)
end
