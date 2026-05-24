local config = require('config')

require('classes.structure.structure')

love.graphics.setDefaultFilter("nearest", "nearest")

local image = love.graphics.newImage("assets/sprites/environment/table.png")
local front =  {xOffset=0, yOffset=0, w=image:getWidth(), h=image:getHeight()*0.35}
local behind =  {xOffset=0, yOffset=image:getHeight()*0.35, w=image:getWidth(), h=image:getHeight()*0.65}
local collision = {xOffset=0, yOffset=image:getHeight()*0.25, w=image:getWidth(), h=image:getHeight()*0.25}
local scale = 2

local x = config.VIRTUAL_WIDTH/2 - (image:getWidth()*scale)/2
local y = config.VIRTUAL_HEIGHT/2 - (image:getHeight()*scale)/2
print(x,y)
local table = Structure(image, x, y, scale, front, behind, collision)

---@type Structure[]
local structures = {
    table
}

return structures