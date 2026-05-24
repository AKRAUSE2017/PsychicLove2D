local utils = {}

---@param obj1 CollisionBox
---@param obj2 CollisionBox
---@return boolean
function utils.collision(obj1, obj2)
    local obj1_rightEdge = obj1.x + obj1.w
    local obj1_leftEdge = obj1.x

    local obj2_rightEdge = obj2.x + obj2.w
    local obj2_leftEdge = obj2.x

    local obj1_bottomEdge = obj1.y + obj1.h
    local obj1_topEdge = obj1.y
    
    local obj2_bottomEdge = obj2.y + obj2.h
    local obj2_topEdge = obj2.y

    local collX = obj1_rightEdge >= obj2_leftEdge and obj2_rightEdge >= obj1_leftEdge
    local collY = obj1_topEdge <= obj2_bottomEdge and obj2_topEdge <= obj1_bottomEdge

    return collX and collY
end

---@param obj CollisionBox
---@param against CollisionBox
---@return "left"|"right"|"top"|"bottom"|false
function utils.collisionType(obj, against)
    local obj1_rightEdge = obj.x + obj.w
    local obj1_leftEdge = obj.x

    local obj2_rightEdge = against.x + against.w
    local obj2_leftEdge = against.x

    local obj1_bottomEdge = obj.y + obj.h
    local obj1_topEdge = obj.y
    
    local obj2_bottomEdge = against.y + against.h
    local obj2_topEdge = against.y

    local collX = obj1_rightEdge >= obj2_leftEdge and obj2_rightEdge >= obj1_leftEdge
    local collY = obj1_topEdge <= obj2_bottomEdge and obj2_topEdge <= obj1_bottomEdge

    if not (collX and collY) then
        return false
    end

    -- Calculate overlap on each side
    local overlapLeft = obj1_rightEdge - obj2_leftEdge
    local overlapRight = obj2_rightEdge - obj1_leftEdge
    local overlapTop = obj1_bottomEdge - obj2_topEdge
    local overlapBottom = obj2_bottomEdge - obj1_topEdge

    -- Find the smallest overlap
    local minOverlap = math.min(overlapLeft, overlapRight, overlapTop, overlapBottom)

    local collisionSide
    if minOverlap == overlapLeft then
        collisionSide = "left"
    elseif minOverlap == overlapRight then
        collisionSide = "right"
    elseif minOverlap == overlapTop then
        collisionSide = "top"
    elseif minOverlap == overlapBottom then
        collisionSide = "bottom"
    end

    return collisionSide
end

return utils
