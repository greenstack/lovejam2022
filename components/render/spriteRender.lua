require "ecs.component"

local peachy = require "vendor.peachy.peachy"
local Color = require "color"

SpriteRender = Component:new()

function SpriteRender:new(jsonPath, imgPath, initialTag, color, obj)
  local render = Component.new(self, "SpriteRender", obj)
  local image  = love.graphics.newImage(imgPath)
  image:setFilter("nearest", "nearest")
  render.ing = peachy.new(jsonPath, image, initialTag)
  render.xOffset = -render.ing:getWidth() / 2
  render.yOffset = -render.ing:getHeight() / 2
  render.color = color or Color()
  render.flipHorizontal = false

  return render
end

function SpriteRender:update(entity, dt)
  self.ing:update(dt)
end

function SpriteRender:draw(entity)
  love.graphics.push()

  local xScale = 1
  if self.flipHorizontal then
    xScale = -1
  end
  love.graphics.scale(xScale, 1)
  self.ing:draw(self.xOffset, self.yOffset)
  love.graphics.pop()
end

function SpriteRender:setTag(tagName)
  self.ing:setTag(tagName)
end

function SpriteRender:getTag()
  return self.ing.tagName
end
