local C = require("src.utils.constants")
local physics = require("src.utils.physics")

local world = {}

local function drawEllipse(mode, cx, cy, rx, ry, segs)
    segs = segs or 32
    local v = {}
    for i = 0, segs - 1 do
        local a = (i / segs) * math.pi * 2
        v[#v + 1] = cx + math.cos(a) * rx
        v[#v + 1] = cy + math.sin(a) * ry
    end
    love.graphics.polygon(mode, v)
end

function world.new(levelData)
    local self = {}

    self.walls = levelData or {
        {x = 280, y = 400, w = 20, h = 400, type = "normal"},
        {x = 180, y = 400, w = 100, h = 20, type = "normal"},
        {x = 180, y = 300, w = 20, h = 100, type = "normal"},
        {x = 180, y = 280, w = 100, h = 20, type = "normal"},
        {x = 280, y = -100, w = 20, h = 400, type = "normal"},
        {x = 300, y = -100, w = 940, h = 20, type = "normal"},
        {x = 300, y = 780, w = 920, h = 20, type = "normal"},
        {x = 1240, y = 400, w = 120, h = 20, type = "normal"},
        {x = 1340, y = 280, w = 20, h = 120, type = "normal"},
        {x = 1240, y = 280, w = 100, h = 20, type = "normal"},
        {x = 300, y = 180, w = 220, h = 20, type = "normal"},
        {x = 500, y = 200, w = 20, h = 320, type = "breakable"},
        {x = 520, y = 180, w = 80, h = 20, type = "normal"},
        {x = 600, y = 180, w = 80, h = 20, type = "door", id = "door_16", open = false},
        {x = 680, y = 180, w = 100, h = 20, type = "normal"},
        {x = 760, y = 200, w = 20, h = 400, type = "normal"},
        {x = 300, y = 580, w = 460, h = 20, type = "normal"},
        {x = 500, y = 520, w = 20, h = 60, type = "normal"},
        {x = 620, y = 260, w = 60, h = 60, type = "pallet"},
        {x = 600, y = 420, w = 160, h = 160, type = "button", target = "door_16"},
        {x = 760, y = -80, w = 20, h = 260, type = "normal"},
        {x = 340, y = -40, w = 60, h = 60, type = "portal_a"},
        {x = 340, y = 660, w = 60, h = 60, type = "portal_b"},
        {x = 760, y = 620, w = 20, h = 160, type = "breakable"},
        {x = 760, y = 600, w = 20, h = 20, type = "breakable"},
        {x = 1250, y = 310, w = 80, h = 80, type = "exit"},
        {x = 780, y = -80, w = 20, h = 640, type = "spikes", facing = "right"},
        {x = 780, y = 560, w = 460, h = 40, type = "breakable"},
        {x = 1240, y = 420, w = 20, h = 380, type = "normal"},
        {x = 1220, y = 780, w = 20, h = 20, type = "normal"},
        {x = 1240, y = -100, w = 20, h = 380, type = "normal"},
        {x = 1180, y = 280, w = 60, h = 140, type = "pallet"}
    }

    self.tutorialTexts = {
        {x = 100, y = 350, text = "DRAG TO LAUNCH"},
        {x = 400, y = 250, text = "SMASH THROUGH\nBREAKABLE WALLS"},
        {x = 600, y = 350, text = "PUSH PALLETS\nONTO BUTTONS"},
        {x = 340, y = 100, text = "TRAVERSE VIA PORTALS"},
        {x = 1000, y = 300, text = "AVOID DEADLY SPIKES"},
        {x = 1200, y = 350, text = "REACH THE FINISH"},
    }

    self.tutorialFont = love.graphics.newFont("assets/fonts/Jersey25.ttf", 20)

    function self.update(dt, player)
        for _, p in ipairs(self.walls) do
            if p.type == "pallet" then
                p.vx = p.vx or 0
                p.vy = p.vy or 0

                local speed = math.sqrt(p.vx * p.vx + p.vy * p.vy)
                if speed > 0 then
                    local substeps = math.max(1, math.ceil(speed * dt / 10))
                    substeps = math.min(substeps, 8)
                    local subDt = dt / substeps

                    for step = 1, substeps do
                        local nextX = p.x + p.vx * subDt
                        local nextY = p.y + p.vy * subDt

                        local hitWall = false
                        for _, other in ipairs(self.walls) do
                            if other ~= p and other.type ~= "button" and other.type ~= "exit" and other.type ~= "portal_a" and other.type ~= "portal_b" then
                                if not (other.type == "door" and other.open) then
                                    if nextX < other.x + other.w and nextX + p.w > other.x and nextY < other.y + other.h and nextY + p.h > other.y then
                                        local overlapX = math.min(nextX + p.w, other.x + other.w) - math.max(nextX, other.x)
                                        local overlapY = math.min(nextY + p.h, other.y + other.h) - math.max(nextY, other.y)

                                        if overlapX < overlapY then
                                            p.vx = 0
                                            if nextX < other.x then p.x = other.x - p.w else p.x = other.x + other.w end
                                        else
                                            p.vy = 0
                                            if nextY < other.y then p.y = other.y - p.h else p.y = other.y + other.h end
                                        end
                                        hitWall = true
                                        break
                                    end
                                end
                            end
                        end

                        if not hitWall then
                            p.x = nextX
                            p.y = nextY
                        end
                    end
                end

                p.vx = p.vx * (1 - 1.0 * dt)
                p.vy = p.vy * (1 - 1.0 * dt)
                if math.abs(p.vx) < 3 then p.vx = 0 end
                if math.abs(p.vy) < 3 then p.vy = 0 end
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "button" then w.active = false end
        end

        for _, b in ipairs(self.walls) do
            if b.type == "button" then
                if physics.circleVsAABB(player.x, player.y, player.radius, b.x, b.y, b.w, b.h) then
                    b.active = true
                end
                for _, p in ipairs(self.walls) do
                    if p.type == "pallet" then
                        if p.x < b.x + b.w and p.x + p.w > b.x and p.y < b.y + b.h and p.y + p.h > b.y then
                            b.active = true
                        end
                    end
                end
            end
        end

        for _, d in ipairs(self.walls) do
            if d.type == "door" then
                local shouldOpen = false
                for _, b in ipairs(self.walls) do
                    if b.type == "button" and b.target == d.id and b.active then
                        shouldOpen = true; break
                    end
                end
                d.open = shouldOpen
            end
        end
    end

    function self.release()
        if self.tutorialFont then self.tutorialFont:release() end
    end

    function self.draw()
        local T = love.timer.getTime()

        love.graphics.setLineWidth(1)
        love.graphics.setColor(0, 0, 0, 0.038)
        local mgs = 100
        for gx = 0, C.WORLD_WIDTH + mgs, mgs do
            local sx = math.floor(gx / mgs) * mgs
            love.graphics.line(sx, -200, sx, C.WORLD_HEIGHT + 200)
        end
        for gy = -200, C.WORLD_HEIGHT + 200, mgs do
            local sy = math.floor(gy / mgs) * mgs
            love.graphics.line(0, sy, C.WORLD_WIDTH + 200, sy)
        end

        love.graphics.setColor(0, 0, 0, 0.10)
        local gs = 40
        for gx = 0, C.WORLD_WIDTH, gs do
            for gy = -200, C.WORLD_HEIGHT + 100, gs do
                love.graphics.rectangle("fill", gx - 1, gy - 1, 2, 2)
            end
        end

        love.graphics.setColor(C.COLOR_WALL)
        for _, w in ipairs(self.walls) do
            if w.type == "normal" then
                love.graphics.rectangle("fill", w.x, w.y, w.w, w.h)
            end
        end

        local wc = C.COLOR_WALL
        love.graphics.setColor(wc[1] * 1.22 + 0.10, wc[2] * 1.18 + 0.09, wc[3] * 1.12 + 0.08, 0.70)
        for _, w in ipairs(self.walls) do
            if w.type == "normal" and w.w > w.h then
                love.graphics.rectangle("fill", w.x, w.y, w.w, 3)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "breakable" then
                love.graphics.setColor(C.COLOR_BREAKABLE)
                love.graphics.rectangle("fill", w.x, w.y, w.w, w.h)
                local cx, cy = w.x + w.w / 2, w.y + w.h / 2
                local cr = math.min(w.w, w.h) * 0.28
                local dc = C.COLOR_BREAKABLE
                love.graphics.setColor(dc[1]*0.40, dc[2]*0.40, dc[3]*0.40, 0.82)
                love.graphics.setLineWidth(2)
                love.graphics.line(cx - cr, cy - cr, cx + cr, cy + cr)
                love.graphics.line(cx + cr, cy - cr, cx - cr, cy + cr)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "button" then
                local col   = w.active and C.COLOR_BUTTON_ACTIVE or C.COLOR_BUTTON
                local pulse = w.active and (math.sin(T * 4) * 0.5 + 0.5) or 0
                local cx, cy = w.x + w.w / 2, w.y + w.h / 2
                local ip     = 6
                local r1     = math.min(w.w, w.h) * 0.20
                local r2     = r1 * 0.40

                love.graphics.setColor(col[1] * 0.30, col[2] * 0.30, col[3] * 0.30, 1)
                love.graphics.rectangle("fill", w.x, w.y, w.w, w.h)

                local padAlpha = w.active and (0.78 + pulse * 0.18) or 0.38
                love.graphics.setColor(col[1], col[2], col[3], padAlpha)
                love.graphics.rectangle("fill", w.x + ip, w.y + ip, w.w - ip * 2, w.h - ip * 2)

                love.graphics.setColor(col[1] * 0.68, col[2] * 0.68, col[3] * 0.68, w.active and 0.90 or 0.50)
                love.graphics.setLineWidth(1.5)
                love.graphics.rectangle("line", w.x + ip, w.y + ip, w.w - ip * 2, w.h - ip * 2)

                if w.active then
                    love.graphics.setColor(1, 1, 1, 0.45 + pulse * 0.30)
                    love.graphics.circle("fill", cx, cy, r2)
                    love.graphics.setColor(1, 1, 1, 0.78)
                    love.graphics.setLineWidth(1.5)
                    love.graphics.circle("line", cx, cy, r1)
                else

                    love.graphics.setColor(col[1] * 0.80, col[2] * 0.80, col[3] * 0.80, 0.55)
                    love.graphics.setLineWidth(1.5)
                    love.graphics.circle("line", cx, cy, r1)
                    love.graphics.setColor(col[1] * 0.60, col[2] * 0.60, col[3] * 0.60, 0.40)
                    love.graphics.circle("line", cx, cy, r2)
                end

                local cs  = math.min(w.w, w.h) * 0.11
                local bx, by = w.x + ip + 3, w.y + ip + 3
                local ex, ey = w.x + w.w - ip - 3, w.y + w.h - ip - 3
                local ta = w.active and 0.70 or 0.35
                love.graphics.setColor(col[1] * 0.80, col[2] * 0.80, col[3] * 0.80, ta)
                love.graphics.setLineWidth(1.5)

                love.graphics.line(bx, by + cs, bx, by, bx + cs, by)

                love.graphics.line(ex - cs, by, ex, by, ex, by + cs)

                love.graphics.line(bx, ey - cs, bx, ey, bx + cs, ey)

                love.graphics.line(ex - cs, ey, ex, ey, ex, ey - cs)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "pallet" then
                love.graphics.setColor(C.COLOR_PALLET)
                love.graphics.rectangle("fill", w.x, w.y, w.w, w.h)
                local cx, cy = w.x + w.w / 2, w.y + w.h / 2
                local a  = math.min(w.w, w.h) * 0.18
                local dc = C.COLOR_PALLET
                love.graphics.setColor(dc[1]*0.48, dc[2]*0.48, dc[3]*0.48, 0.68)

                love.graphics.polygon("fill", cx, cy - a*1.7,  cx - a*0.62, cy - a*0.82,  cx + a*0.62, cy - a*0.82)

                love.graphics.polygon("fill", cx, cy + a*1.7,  cx - a*0.62, cy + a*0.82,  cx + a*0.62, cy + a*0.82)

                love.graphics.polygon("fill", cx - a*1.7, cy,  cx - a*0.82, cy - a*0.62,  cx - a*0.82, cy + a*0.62)

                love.graphics.polygon("fill", cx + a*1.7, cy,  cx + a*0.82, cy - a*0.62,  cx + a*0.82, cy + a*0.62)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "spikes" then
                local col    = C.COLOR_SPIKES
                local facing = w.facing

                if w.w <= w.h then

                    local cx    = w.x + w.w / 2
                    local pitch = math.max(10, math.min(18, w.h / math.max(2, math.floor(w.h / 14))))
                    local n     = math.floor(w.h / pitch)
                    local depth = w.w * 0.55 + 5

                    love.graphics.setColor(col[1], col[2], col[3], 0.35)
                    love.graphics.setLineWidth(1)
                    love.graphics.line(cx, w.y, cx, w.y + w.h)

                    love.graphics.setColor(col)
                    for i = 0, n - 1 do
                        local ty   = w.y + (i + 0.5) * pitch
                        local half = pitch * 0.43
                        if facing ~= "right" then
                            love.graphics.polygon("fill", cx, ty - half,  w.x - depth, ty,  cx, ty + half)
                        end
                        if facing ~= "left" then
                            love.graphics.polygon("fill", cx, ty - half,  w.x + w.w + depth, ty,  cx, ty + half)
                        end
                    end
                else

                    local pitch = math.max(10, math.min(18, w.w / math.max(2, math.floor(w.w / 14))))
                    local n     = math.floor(w.w / pitch)

                    if facing == "down" then

                        local baseY = w.y + w.h * 0.40
                        love.graphics.setColor(col[1], col[2], col[3], 0.45)
                        love.graphics.rectangle("fill", w.x, w.y, w.w, w.h - (w.y + w.h - baseY - (w.y + w.h * 0.40 - w.y)))
                        love.graphics.setColor(col)
                        for i = 0, n - 1 do
                            local tx   = w.x + (i + 0.5) * pitch
                            local half = pitch * 0.43
                            love.graphics.polygon("fill", tx - half, baseY,  tx, w.y + w.h,  tx + half, baseY)
                        end
                    else

                        local baseY = w.y + w.h * 0.60
                        love.graphics.setColor(col[1], col[2], col[3], 0.45)
                        love.graphics.rectangle("fill", w.x, baseY, w.w, w.h - (baseY - w.y))
                        love.graphics.setColor(col)
                        for i = 0, n - 1 do
                            local tx   = w.x + (i + 0.5) * pitch
                            local half = pitch * 0.43
                            love.graphics.polygon("fill", tx - half, baseY,  tx, w.y,  tx + half, baseY)
                        end
                    end
                end

                love.graphics.setColor(col[1], col[2], col[3], 0.50)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", w.x, w.y, w.w, w.h)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "portal_a" or w.type == "portal_b" then
                local col     = w.type == "portal_a" and C.COLOR_PORTAL_A or C.COLOR_PORTAL_B
                local cx, cy  = w.x + w.w / 2, w.y + w.h / 2
                local rx, ry  = w.w * 0.50, w.h * 0.50
                local shimmer = math.sin(T * 3.5) * 0.5 + 0.5

                love.graphics.setColor(0.04, 0.04, 0.08, 0.93)
                drawEllipse("fill", cx, cy, rx - 2, ry - 2)

                love.graphics.setColor(col[1], col[2], col[3], 0.07 + shimmer * 0.10)
                drawEllipse("fill", cx, cy, (rx - 6) * 0.85, (ry - 6) * 0.85)

                love.graphics.setColor(col)
                love.graphics.setLineWidth(4.5)
                drawEllipse("line", cx, cy, rx - 1, ry - 1)

                love.graphics.setColor(1, 1, 1, 0.55 + shimmer * 0.38)
                love.graphics.circle("fill", cx, cy, 1.8 + shimmer * 1.2)
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "door" then
                if w.open then
                    love.graphics.setColor(C.COLOR_DOOR[1], C.COLOR_DOOR[2], C.COLOR_DOOR[3], 0.14)
                    love.graphics.rectangle("fill", w.x, w.y, w.w, w.h, 2, 2)
                else
                    love.graphics.setColor(C.COLOR_DOOR)
                    love.graphics.rectangle("fill", w.x, w.y, w.w, w.h, 2, 2)

                    love.graphics.setColor(1, 1, 1, 0.07)
                    if w.h > w.w then
                        local n = math.floor(w.h / 18)
                        for i = 1, n - 1 do
                            local ly = w.y + i * 18
                            love.graphics.setLineWidth(1)
                            love.graphics.line(w.x + 3, ly, w.x + w.w - 3, ly)
                        end
                    end
                    love.graphics.setColor(C.COLOR_WALL_OUTLINE)
                    love.graphics.setLineWidth(1)
                    love.graphics.rectangle("line", w.x, w.y, w.w, w.h, 2, 2)
                end
            end
        end

        for _, w in ipairs(self.walls) do
            if w.type == "exit" then
                local cx, cy = w.x + w.w / 2, w.y + w.h / 2
                local pulse  = math.sin(T * 3.2) * 0.5 + 0.5

                love.graphics.setColor(0.18, 0.82, 0.46, 0.13 + pulse * 0.06)
                love.graphics.rectangle("fill", w.x, w.y, w.w, w.h, 8, 8)

                for ring = 1, 2 do
                    local phase = (T * 0.75 + ring * 0.5) % 1.0
                    local scale = 0.50 + phase * 0.65
                    local rw = w.w * scale
                    local rh = w.h * scale
                    love.graphics.setColor(0.18, 0.82, 0.46, (1 - phase) * 0.32)
                    love.graphics.setLineWidth(1.5)
                    love.graphics.rectangle("line", cx - rw/2, cy - rh/2, rw, rh, 8, 8)
                end

                love.graphics.setColor(0.18, 0.82, 0.46, 0.70 + pulse * 0.30)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", w.x, w.y, w.w, w.h, 8, 8)
            end
        end

        love.graphics.setLineWidth(1)
        for _, w in ipairs(self.walls) do
            if w.type == "breakable" then
                love.graphics.setColor(C.COLOR_BREAKABLE[1]*0.62, C.COLOR_BREAKABLE[2]*0.62, C.COLOR_BREAKABLE[3]*0.62, 0.8)
                love.graphics.rectangle("line", w.x, w.y, w.w, w.h)
            elseif w.type == "pallet" then
                love.graphics.setColor(C.COLOR_PALLET[1]*0.65, C.COLOR_PALLET[2]*0.65, C.COLOR_PALLET[3]*0.65, 0.75)
                love.graphics.rectangle("line", w.x, w.y, w.w, w.h, 5, 5)
            end
        end

        love.graphics.setFont(self.tutorialFont)
        for _, t in ipairs(self.tutorialTexts) do
            local lumBG = C.COLOR_BG[1] * 0.299 + C.COLOR_BG[2] * 0.587 + C.COLOR_BG[3] * 0.114
            local onDark = lumBG < 0.5
            love.graphics.setColor(onDark and 1 or 0, onDark and 1 or 0, onDark and 1 or 0, onDark and 0.28 or 0.45)
            love.graphics.printf(t.text, t.x - 100, t.y, 200, "center")
        end
    end

    return self
end

return world
