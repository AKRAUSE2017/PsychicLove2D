Portrait = Class{}

local animations = require("helpers.animations")
local config = require("config")

---@param x number
---@param y number
---@param w number
---@param h number
---@param image string
---@param scale? number
function Portrait:init(x, y, w, h, image, scale)
    self.scale = scale or 1

    self.x = x
    self.y = y

    self.image = image
    local i = love.graphics.newImage(image)

    local idleSlice = {x=0, y=0, width=i:getWidth()/3, height=i:getHeight()}
    self.idleAnimation = animations.imageToAnimation(image, w, h, 2.3, idleSlice)

    local blinkSlice = {x=i:getWidth()/3, y=0, width=(i:getWidth()/3), height=i:getHeight()}
    self.blinkAnimation = animations.imageToAnimation(image, w, h, 2.3, blinkSlice)
    self.idleTransitionTimer = 0

    local smileSlice = {x=(i:getWidth()/3)*2, y=0, width=(i:getWidth()/3), height=i:getHeight()}
    self.smileAnimation = animations.imageToAnimation(image, w, h, 1, smileSlice)

    self.currentAnimation = self.idleAnimation
    self.state = "idle"

    self.background = love.graphics.newImage("assets/sprites/environment/background.png")
    self.isVisible = false
end

function Portrait:render()
    -- love.graphics.setColor(200/255, 153/255, 178/255)
    -- love.graphics.rectangle("fill", 0, 0, config.VIRTUAL_WIDTH, config.VIRTUAL_HEIGHT)

    if (not self.isVisible) then return end

    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.draw(self.background, 0, 0)

    local spriteIndex = math.floor(self.currentAnimation.currentTime / self.currentAnimation.duration * #self.currentAnimation.quads) + 1
    love.graphics.draw(self.currentAnimation.spriteSheet, self.currentAnimation.quads[spriteIndex], self.x, self.y, 0, self.scale)
end

---@param key string
function Portrait:keypressed(key)
   if key == "k" then
      self.isVisible = not self.isVisible
   end
end

---@param dt number
function Portrait:update(dt)
    if (not self.isVisible) then return end

    self.currentAnimation.currentTime = self.currentAnimation.currentTime + dt
    self.idleTransitionTimer = self.idleTransitionTimer + dt

    -- time to blink
    if self.state == "idle" and self.idleTransitionTimer > 7 then
        self.state = "blinking"
        self.currentAnimation = self.blinkAnimation
        self.currentAnimation.currentTime = 0

        self.idleTransitionTimer = 0
    end

    if self.currentAnimation.currentTime >= self.currentAnimation.duration then
        if self.state == "blinking" then
             self.state = "idle"
             self.currentAnimation = self.idleAnimation
             self.currentAnimation.currentTime = 0
        else self.currentAnimation.currentTime = self.currentAnimation.currentTime - self.currentAnimation.duration end
    end
end
