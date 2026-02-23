local utils = {}

function utils.dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function utils.normalize(x, y)
    local d = math.sqrt(x*x + y*y)
    if d == 0 then return 0, 0 end
    return x/d, y/d
end

function utils.clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function utils.clampVec(x, y, maxLen)
    local len = math.sqrt(x*x + y*y)
    if len > maxLen then
        local nx, ny = utils.normalize(x, y)
        return nx * maxLen, ny * maxLen
    end
    return x, y
end

function utils.angleDiff(a, b)
    return (a - b + math.pi) % (math.pi * 2) - math.pi
end

return utils
