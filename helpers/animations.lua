local animations = {}

function animations.newAnimation(image, width, height, duration, slice)
    local slice = slice or {x=0, y=0, width=image:getWidth(), height=image:getHeight()}

    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};


    for y = slice.y, slice.y + slice.height - height, height do
        for x = slice.x, slice.x + slice.width - width, width do
            print("quad", x, y, width, height)
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end


function animations.imageToAnimation(path, width, height, duration, slice)
    local image = love.graphics.newImage(path)

    return animations.newAnimation(image, width, height, duration, slice)
end

return animations
