Structure = Class{}

---@param image love.Image
---@param x number
---@param y number
---@param scale? number
---@param front SegmentDef
---@param behind SegmentDef
---@param collision SegmentDef
function Structure:init(image, x, y, scale, front, behind, collision)
    scale = scale or 1

    self.x = x
    self.y = y
    self.scale = scale

    self.image = image

    self.front = front
    self.behind = behind

    self.collision = {
        x = self.x + collision.xOffset * self.scale,
        y = self.y + collision.yOffset * self.scale,
        w = collision.w * self.scale,
        h = collision.h * self.scale
    }

    if self.front and self.behind then
        self.frontQuad = love.graphics.newQuad(front.xOffset, front.yOffset, front.w, front.h, image:getDimensions())
        self.behindQuad = love.graphics.newQuad(behind.xOffset, behind.yOffset, behind.w, behind.h, image:getDimensions())
    end
end

function Structure:renderFrontSegment()
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.draw(self.image, self.frontQuad, self.x + self.front.xOffset * self.scale, self.y + self.front.yOffset * self.scale, 0, self.scale)
    -- love.graphics.setColor(255/255, 0/255, 0/255)
    -- love.graphics.rectangle("line", self.collision.x, self.collision.y, self.collision.w, self.collision.h)
end

function Structure:renderBehindSegment()
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.draw(self.image, self.behindQuad, self.x + self.behind.xOffset * self.scale, self.y + self.behind.yOffset * self.scale, 0, self.scale)
end
