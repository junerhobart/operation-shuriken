local physics = {}

function physics.circleVsAABB(cx, cy, r, rx, ry, rw, rh)
    local nearestX = math.max(rx, math.min(cx, rx + rw))
    local nearestY = math.max(ry, math.min(cy, ry + rh))
    
    local dx = cx - nearestX
    local dy = cy - nearestY
    local distSq = dx*dx + dy*dy
    
    if distSq < r*r then
        local dist = math.sqrt(distSq)
        local nx, ny
        if dist == 0 then
            local dl = cx - rx
            local dr = (rx + rw) - cx
            local dt = cy - ry
            local db = (ry + rh) - cy
            local min = math.min(dl, dr, dt, db)
            if min == dl then nx, ny = -1, 0; dist = dl
            elseif min == dr then nx, ny = 1, 0; dist = dr
            elseif min == dt then nx, ny = 0, -1; dist = dt
            else nx, ny = 0, 1; dist = db end
        else
            nx, ny = dx/dist, dy/dist
        end
        return true, nx, ny, r - dist
    end
    return false
end

function physics.circleVsCircle(c1x, c1y, r1, c2x, c2y, r2)
    local dx = c2x - c1x
    local dy = c2y - c1y
    local distSq = dx*dx + dy*dy
    local combinedRadius = r1 + r2
    
    if distSq < combinedRadius * combinedRadius then
        local dist = math.sqrt(distSq)
        if dist < 0.00001 then
            return true, 1, 0, combinedRadius
        end
        local nx, ny = dx/dist, dy/dist
        return true, nx, ny, combinedRadius - dist
    end
    return false
end

function physics.lineVsAABB(x1, y1, x2, y2, rx, ry, rw, rh)
    local tmin = 0
    local tmax = 1
    
    local dx = x2 - x1
    local dy = y2 - y1
    
    if math.abs(dx) < 0.00001 then
        if x1 < rx or x1 > rx + rw then return false end
    else
        local t1 = (rx - x1) / dx
        local t2 = (rx + rw - x1) / dx
        if t1 > t2 then t1, t2 = t2, t1 end
        tmin = math.max(tmin, t1)
        tmax = math.min(tmax, t2)
        if tmin > tmax then return false end
    end
    
    if math.abs(dy) < 0.00001 then
        if y1 < ry or y1 > ry + rh then return false end
    else
        local t1 = (ry - y1) / dy
        local t2 = (ry + rh - y1) / dy
        if t1 > t2 then t1, t2 = t2, t1 end
        tmin = math.max(tmin, t1)
        tmax = math.min(tmax, t2)
        if tmin > tmax then return false end
    end
    
    return tmin < 1 and tmax > 0
end

function physics.isPathClear(x1, y1, x2, y2, walls)
    for _, wall in ipairs(walls) do
        if physics.lineVsAABB(x1, y1, x2, y2, wall.x, wall.y, wall.w, wall.h) then
            return false
        end
    end
    return true
end

function physics.isPathClearInflated(x1, y1, x2, y2, walls, padding)
    local p = padding or 0
    for _, wall in ipairs(walls) do
        if physics.lineVsAABB(x1, y1, x2, y2, wall.x - p, wall.y - p, wall.w + p * 2, wall.h + p * 2) then
            return false
        end
    end
    return true
end

function physics.pointAABBDistance(px, py, rx, ry, rw, rh)
    local nearestX = math.max(rx, math.min(px, rx + rw))
    local nearestY = math.max(ry, math.min(py, ry + rh))
    local dx = px - nearestX
    local dy = py - nearestY
    return math.sqrt(dx * dx + dy * dy), dx, dy
end

return physics
