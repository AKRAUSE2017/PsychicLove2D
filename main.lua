Push = require('modules.push')
Class = require('modules.class')

local config = require('config')
local structures = require('helpers.env')
require('classes.player')
require('classes.structure')
require('classes.map')
require('classes.portrait')

-- Scale factors needed to extract mouse click positions
local SCALE_X = config.VIRTUAL_WIDTH/config.WINDOW_WIDTH
local SCALE_Y = config.VIRTUAL_HEIGHT/config.WINDOW_HEIGHT

local player
local tilemap
local character

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Push:setupScreen(config.VIRTUAL_WIDTH, config.VIRTUAL_HEIGHT, config.WINDOW_WIDTH, config.WINDOW_HEIGHT, {
        vsync = false,
        fullscreen = false,
        resizable = true
    })

    tilemap = Map(config.MAP, 10, 6, 64)
    player = Player(0, 0, config.PLAYER_SPRITE_WIDTH, config.PLAYER_SPRITE_HEIGHT, config.PLAYER_SPRITE_SCALE, config.PLAYER_COLLISION_WIDTH, config.PLAYER_COLLISION_HEIGHT)
    character = Portrait(64, 40, 78, 161,"assets/sprites/portraits/lady.png", 2)
end

function love.resize(w,h)
    SCALE_X = config.VIRTUAL_WIDTH/w
    SCALE_Y = config.VIRTUAL_HEIGHT/h
    Push:resize(w,h)
end


function love.draw()
    Push:start() 
    love.graphics.setColor(80/255, 119/255, 154/255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    tilemap:render()

    -- Render objects behind player
    for _, structure in pairs(structures) do
        if structure.behind then
            structure:renderBehindSegment()
        end
    end

    player:render()
    
    -- Render objects in front of player
    for _, structure in pairs(structures) do
        if structure.front then
            structure:renderFrontSegment()
        end
    end

    character:render()

    Push:finish()
end

function love.keypressed(key)
    character:keypressed(key)
end

function love.update(dt)
    player:update(dt)
    player:handleStructureCollisions(structures)

    character:update(dt)
end