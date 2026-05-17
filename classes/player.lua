Player = Class{}

local animations = require("helpers.animations")
local utils = require("helpers.utils")
local config = require('config')

function Player:init(x, y, w, h, scale)
    scale = scale or 1

    self.x = x
    self.y = y
    self.w = w*scale
    self.h = h*scale
    self.scale = scale

    self.state = "move"

    self.direction = "down"

    self.dx = 0
    self.dy = 0

    self.idle = animations.imageToAnimation("assets/sprites/player/idle_S.png", w, h, 1)
    self.walkDown = animations.imageToAnimation("assets/sprites/player/walk_S.png", w, h, 0.7)

    self.walkRight = animations.imageToAnimation("assets/sprites/player/walk_E.png", w, h, 0.7)
    self.idleRight = animations.imageToAnimation("assets/sprites/player/idle_E.png", w, h, 1)

    self.walkLeft = animations.imageToAnimation("assets/sprites/player/walk_W.png", w, h, 0.7)
    self.idleLeft = animations.imageToAnimation("assets/sprites/player/idle_W.png", w, h, 1)

    self.walkUp = animations.imageToAnimation("assets/sprites/player/walk_N.png", w, h, 0.7)
    self.idleUp = animations.imageToAnimation("assets/sprites/player/idle_N.png", w, h, 1)

    self.currentAnimation = self.idle

    self.collision = {
        x=8*scale,
        y=2*scale,
        w=16*scale,
        h=30*scale
    }
end

function Player:render()
    love.graphics.setColor(255/255, 255/255, 255/255)
    local spriteIndex = math.floor(self.currentAnimation.currentTime / self.currentAnimation.duration * #self.currentAnimation.quads) + 1
    love.graphics.draw(self.currentAnimation.spriteSheet, self.currentAnimation.quads[spriteIndex], self.x, self.y, 0, self.scale)
    
    -- love.graphics.setColor(255/255, 0/255, 255/255)
    -- love.graphics.rectangle("line", self.collision.x, self.collision.y, self.collision.w, self.collision.h)
end

function Player:update(dt)
    self.dx = 0
    self.dy = 0

    if self.direction == "down" then self.currentAnimation = self.idle
    elseif self.direction == "up" then self.currentAnimation = self.idleUp
    elseif self.direction == "right" then self.currentAnimation = self.idleRight
    else self.currentAnimation = self.idleLeft end
    
    if love.keyboard.isDown('w') or love.keyboard.isDown("up") then
        self.dy = -config.PLAYER_SPEED
        self.currentAnimation = self.walkUp
        self.direction = "up"
        if self.state == "stop-bottom" then self.dy = 0 end
    elseif love.keyboard.isDown('s') or love.keyboard.isDown("down") then
        self.dy = config.PLAYER_SPEED
        self.currentAnimation = self.walkDown
        self.direction = "down"
        if self.state == "stop-top" then self.dy = 0 end
    end 

    if love.keyboard.isDown('d') or love.keyboard.isDown("right") then
        self.dx = config.PLAYER_SPEED
        self.currentAnimation = self.walkRight
        self.direction = "right"
        if self.state == "stop-left" then self.dx = 0 end
    elseif love.keyboard.isDown('a') or love.keyboard.isDown("left") then
        self.dx = -config.PLAYER_SPEED
        self.currentAnimation = self.walkLeft
        self.direction = "left"
        if self.state == "stop-right" then self.dx = 0 end
    end

    self.currentAnimation.currentTime = self.currentAnimation.currentTime + dt
    if self.currentAnimation.currentTime >= self.currentAnimation.duration then
        self.currentAnimation.currentTime = self.currentAnimation.currentTime - self.currentAnimation.duration
    end

    -- normalize movement so that diagonal movement is not x2 speed
    local length = math.sqrt(self.dx^2+self.dy^2)
    if length > 0 then self.dx, self.dy = (self.dx/length) * config.PLAYER_SPEED, (self.dy/length) * config.PLAYER_SPEED end

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- TODO: maybe make this not hard coded
    self.collision = {
        x=self.x + 8*self.scale,
        y=self.y + 2*self.scale,
        w=16*self.scale,
        h=30*self.scale
    }
    -- if self.direction == 'right' then self.collision.w = self.collision.w - 6 end
    -- if self.direction == 'left' then self.collision.x = self.collision.x + 6 end
end 

function Player:handleStructureCollisions(structures) 
    self.state = "move"
    for _, structure in pairs(structures) do
        local collisionType = utils.collisionType(self.collision, structure.collision)
        if collisionType then
            self.state = "stop-"..collisionType
        end
    end
    
end