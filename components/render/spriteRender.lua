require "ecs.component"

local peachy = require "vendor.peachy.peachy"
local Color = require "color"

SpriteRender = Component:new()

function SpriteRender:new(jsonPath, imgPath, color, obj)
  local render = Component.new(self, "SpriteRender", obj)
  local image  = love.graphics.newImage(imgPath)
  image:setFilter("nearest", "nearest")
  render.ing = peachy.new(jsonPath, image, "idle")
  render.color = color or Color()

  return render
end

function SpriteRender:update(entity, dt)
  self.ing:update(dt)
end

function SpriteRender:draw(entity)
  self.ing:draw(-8, -8)
end
