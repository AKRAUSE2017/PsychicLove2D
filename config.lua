---@type Config
local config = {
    WINDOW_WIDTH = 1290,
    WINDOW_HEIGHT = 960,
    
    VIRTUAL_WIDTH = 640,
    VIRTUAL_HEIGHT = 360,
    
    PLAYER_SPRITE_WIDTH = 32,
    PLAYER_SPRITE_HEIGHT = 32,
    PLAYER_COLLISION_WIDTH = 16,
    PLAYER_COLLISION_HEIGHT = 31,
    PLAYER_SPRITE_SCALE = 2,
    PLAYER_SPEED = 120,

    MAP = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 1, 2, 3, 4, 0, 0, 0,
        0, 0, 0, 5, 6, 7, 8, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    }
}

return config
