Map = Class{}

function Map:init(data, w, h, cellSize)
    self.data = data
    self.w = w
    self.h = h
    self.cellSize = cellSize

    self.standardTile = love.graphics.newImage("assets/sprites/environment/wood.png")

    self.rug = love.graphics.newImage("assets/sprites/environment/rug.png")
    local rugW, rugH = self.rug:getDimensions()
    self.rugQuads = {}

    local id = 1
    for j = 0, (rugH / cellSize) - 1 do
        for i = 0, (rugW / cellSize) - 1 do
            self.rugQuads[id] = love.graphics.newQuad(
                i * cellSize, j * cellSize,
                cellSize, cellSize,
                rugW, rugH
            )
            id = id + 1
        end
    end
end

function Map:render()
   local globalPosition = 0
   for row=0, self.h-1 do
    for col=0, self.w-1 do
        globalPosition = globalPosition + 1
        local x = col * self.cellSize
        local y = row * self.cellSize
        if self.data[globalPosition] == 0 then 
            love.graphics.setColor(255/255, 255/255, 255/255)
            love.graphics.draw(self.standardTile, x, y)
            love.graphics.rectangle("line", x, y, self.cellSize, self.cellSize)
        elseif self.data[globalPosition] > 0 then
            love.graphics.setColor(255/255, 255/255, 255/255)
            love.graphics.draw(self.rug, self.rugQuads[self.data[globalPosition]], x, y)
            love.graphics.rectangle("line", x, y, self.cellSize, self.cellSize)
        end
    end
   end
end