require "ecs.component"

local peachy = require "vendor.peachy.peachy"
local Color = require "color"

SpriteRender = Component:new()

function SpriteRender:new(jsonPath, imgPath, color, obj)
  local render = Component.new(self, "SpriteRender", obj)
  local image  = love.graphics.newImage(imgPath)
  image:setFilter("nearest", "nearest")
  render.ing = peachy.new(jsonPath, image, "idle")
  render.xOffset = -render.ing:getWidth() / 2
  render.yOffset = -render.ing:getHeight() / 2
  render.color = color or Color()

  return render
end

function SpriteRender:update(entity, dt)
  self.ing:update(dt)
end

function SpriteRender:draw(entity)
  self.ing:draw(self.xOffset, self.yOffset)
end
