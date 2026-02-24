local C = require("src.utils.constants")
local utils = require("src.utils.utils")
local physics = require("src.utils.physics")

local player = {}
local bounceSound = love.audio.newSource("assets/audio/sound-effects/bounce.wav", "static")
local breakSound = love.audio.newSource("assets/audio/sound-effects/squish.wav", "static")

local whiteShurikenShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 pixel = Texel(tex, tc);
        if (pixel.a < 0.01) discard;
        float lum = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
        // Invert so dark sprite details become bright; add cool blue tint
        float b = 1.0 - lum * 0.55;
        vec3 tinted = vec3(b * 0.82, b * 0.93, b * 1.0);
        return vec4(tinted, pixel.a) * color;
    }
]])

local portalCooldown = 0
local simulating = false

function player.new(x, y)
    portalCooldown = 0
    local self = {
        x = x, y = y,
        vx = 0, vy = 0,
        radius = C.PLAYER_RADIUS,
        angle = 0,

        dragging = false,
        pullX = 0, pullY = 0,

        sprite = love.graphics.newImage("assets/images/sprite.png", {mipmaps = true}),
        trail = {},
        trailTimer = 0,

        visualScale = 1,
        dead = false,
        reachedExit = false
    }

    self.spriteW = self.sprite:getWidth()
    self.spriteH = self.sprite:getHeight()

    function self.getSpeed()
        return math.sqrt(self.vx * self.vx + self.vy * self.vy)
    end

    function self.update(dt, world, ps)
        if self.dead then return end
        portalCooldown = math.max(0, portalCooldown - dt)

        if not self.dragging and ps then
            self._trailTimer = (self._trailTimer or 0) - dt
            if self._trailTimer <= 0 then
                ps.spawnTrail(self.x, self.y, self.vx, self.vy)
                self._trailTimer = 0.022
            end
        end

        if self.dragging then
            self.vx, self.vy = 0, 0
        else
            local speed = self.getSpeed()

            local substeps = math.max(1, math.ceil(speed * dt / (self.radius * 0.5)))
            substeps = math.min(substeps, 12)
            local subDt = dt / substeps

            for _ = 1, substeps do
                self.x = self.x + self.vx * subDt
                self.y = self.y + self.vy * subDt

                for i = #world.walls, 1, -1 do
                    local w = world.walls[i]
                    local should_check = true

                    if w.type == "door" and w.open then
                        should_check = false
                    end

                    if should_check then
                        local hit, nx, ny, mtv = physics.circleVsAABB(self.x, self.y, self.radius, w.x, w.y, w.w, w.h)

                        if hit then
                            if w.type == "spikes" then
                                self.dead = true
                                if ps then ps.spawnDeath(self.x, self.y) end
                                return
                            elseif w.type == "breakable" then
                                local dot = self.vx * nx + self.vy * ny
                                if math.abs(dot) > C.PLAYER_BREAK_THRESHOLD then
                                    if ps then ps.spawnBreak(w.x, w.y, w.w, w.h, C.COLOR_BREAKABLE) end
                                    table.remove(world.walls, i)
                                    if not simulating then breakSound:stop(); breakSound:play() end
                                    should_check = false
                                end
                            elseif w.type == "pallet" then
                                local dot = self.vx * nx + self.vy * ny
                                local impactSpeed = math.abs(dot)
                                local transferMult = impactSpeed > 180 and 3.0 or 2.2

                                w.vx = (w.vx or 0) - nx * impactSpeed * transferMult
                                w.vy = (w.vy or 0) - ny * impactSpeed * transferMult

                                self.x = self.x + nx * mtv
                                self.y = self.y + ny * mtv
                                self.vx = self.vx - dot * nx * 0.2
                                self.vy = self.vy - dot * ny * 0.2
                                if impactSpeed > 160 and ps then
                                    ps.spawnPalletSmash(self.x, self.y, nx, ny, impactSpeed)
                                end
                                should_check = false
                            elseif w.type == "button" then
                                should_check = false
                            elseif (w.type == "portal_a" or w.type == "portal_b") then
                                if portalCooldown <= 0 then
                                    local targetType = (w.type == "portal_a") and "portal_b" or "portal_a"
                                    local srcCol = w.type == "portal_a" and C.COLOR_PORTAL_A or C.COLOR_PORTAL_B
                                    for _, other in ipairs(world.walls) do
                                        if other.type == targetType then
                                            if ps then
                                                ps.spawnWarp(self.x, self.y, srcCol)
                                                local dstCol = other.type == "portal_a" and C.COLOR_PORTAL_A or C.COLOR_PORTAL_B
                                                ps.spawnWarp(other.x + other.w/2, other.y + other.h/2, dstCol)
                                            end
                                            self.x = other.x + other.w/2
                                            self.y = other.y + other.h/2
                                            portalCooldown = 0.8
                                            if not simulating then bounceSound:stop(); bounceSound:play() end

                                            local hitTarget, tnx, tny, tmtv = physics.circleVsAABB(self.x, self.y, self.radius, other.x, other.y, other.w, other.h)
                                            if hitTarget then
                                                self.x = self.x + tnx * tmtv
                                                self.y = self.y + tny * tmtv
                                            end
                                            should_check = false
                                            break
                                        end
                                    end
                                else
                                    should_check = false
                                end
                            elseif w.type == "exit" then
                                self.reachedExit = true
                            end

                            if should_check and w.type ~= "pallet" then
                                self.x = self.x + nx * mtv
                                self.y = self.y + ny * mtv
                                local dot = self.vx * nx + self.vy * ny
                                local impactSpeed = math.abs(dot)
                                if impactSpeed > 80 then
                                    if not simulating then
                                        bounceSound:setVolume(math.min(impactSpeed / 800, 1) * 0.5)
                                        bounceSound:stop()
                                        bounceSound:play()
                                    end
                                    if ps then ps.spawnImpact(self.x, self.y, nx, ny, impactSpeed) end
                                end
                                self.vx = (self.vx - 2 * dot * nx) * C.PLAYER_BOUNCE_RETENTION
                                self.vy = (self.vy - 2 * dot * ny) * C.PLAYER_BOUNCE_RETENTION
                            end
                        end
                    end
                end
            end
        end

        local effectiveDamping = C.PLAYER_DAMPING
        local speed = self.getSpeed()
        if speed > 0 then
            self.vx = self.vx * (1 - effectiveDamping * dt)
            self.vy = self.vy * (1 - effectiveDamping * dt)
            if speed < C.PLAYER_STOP_THRESHOLD then
                self.vx, self.vy = 0, 0
            end
            self.angle = self.angle + speed * C.PLAYER_SPIN_FACTOR * dt

            self.trailTimer = self.trailTimer + dt
            if self.trailTimer > 0.02 and speed > 100 then
                table.insert(self.trail, 1, {x = self.x, y = self.y, angle = self.angle, alpha = 0.4})
                self.trailTimer = 0
            end
        end

        for i = #self.trail, 1, -1 do
            self.trail[i].alpha = self.trail[i].alpha - dt * 2.5
            if self.trail[i].alpha <= 0 then table.remove(self.trail, i) end
        end

        if self.dragging then
            local dist = math.sqrt(self.pullX*self.pullX + self.pullY*self.pullY)
            local ratio = dist / C.PLAYER_MAX_PULL
            self.visualScale = 1 + math.sin(love.timer.getTime() * 15) * 0.1 * ratio
        else
            self.visualScale = self.visualScale + (1 - self.visualScale) * dt * 10
        end
    end

    function self.draw(world, darkMode)
        if self.dead then return end

        if darkMode then love.graphics.setShader(whiteShurikenShader) end

        for _, t in ipairs(self.trail) do
            local fade = math.max(0, t.alpha)
            local trailScale = (self.radius * 4.0) / self.spriteW * (0.5 + fade * 0.5)
            love.graphics.setColor(0.75, 0.90, 1.0, fade * 0.55)
            love.graphics.draw(self.sprite, t.x, t.y, t.angle, trailScale, trailScale, self.spriteW/2, self.spriteH/2)
        end

        if self.dragging then
            local dist = math.sqrt(self.pullX*self.pullX + self.pullY*self.pullY)
            local px, py = utils.normalize(self.pullX, self.pullY)
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 1, 1, 0.35)
            love.graphics.line(self.x, self.y, self.x + self.pullX, self.y + self.pullY)

            if dist > 10 then

                local simFDt    = 1 / 60
                local maxFrames = 160

                local savePX, savePY = self.x, self.y
                local saveVX, saveVY = self.vx, self.vy
                local saveDead = self.dead
                local saveExit = self.reachedExit
                local saveAngle = self.angle
                local saveDragging = self.dragging
                local saveTrail = self.trail
                local saveTrailTimer = self.trailTimer
                local save_trailTimer = self._trailTimer
                local savePCooldown = portalCooldown

                local wallSnap = {}
                for i, w in ipairs(world.walls) do
                    wallSnap[i] = {}
                    for k, v in pairs(w) do wallSnap[i][k] = v end
                end

                simulating = true

                self.vx = -px * dist * C.PLAYER_LAUNCH_POWER
                self.vy = -py * dist * C.PLAYER_LAUNCH_POWER
                self.dead = false
                self.reachedExit = false
                self.dragging = false
                self.trail = {}
                self.trailTimer = 0
                self._trailTimer = 999

                local points       = {{x=self.x, y=self.y, broke=false, teleport=false}}
                local palletPoints = {}
                local breakableTargets = {}
                local spikeHit     = nil
                local hitExit      = false
                local prevWallCount = #world.walls
                local prevPX, prevPY = self.x, self.y

                for frame = 1, maxFrames do
                    local speed = math.sqrt(self.vx*self.vx + self.vy*self.vy)
                    if speed < C.PLAYER_STOP_THRESHOLD then break end

                    prevPX, prevPY = self.x, self.y

                    self.update(simFDt, world, nil)
                    world.update(simFDt, self)

                    if self.dead then
                        spikeHit = {x = self.x, y = self.y}
                        break
                    end
                    if self.reachedExit then
                        hitExit = true
                        break
                    end

                    local newWC = #world.walls
                    local brokeThisFrame = newWC < prevWallCount
                    if brokeThisFrame then
                        for i = newWC + 1, prevWallCount do
                            local snap = wallSnap[i]
                            if snap and snap.type == "breakable" then
                                table.insert(breakableTargets,
                                    {x = snap.x + snap.w/2, y = snap.y + snap.h/2})
                            end
                        end
                    end
                    prevWallCount = newWC

                    local movedFar = math.abs(self.x - prevPX) > 2 or math.abs(self.y - prevPY) > 2
                    if movedFar and (self.x ~= prevPX or self.y ~= prevPY) then
                        local isTeleport = math.abs(self.x - prevPX) > 80 or math.abs(self.y - prevPY) > 80
                        if isTeleport then
                            table.insert(points, {x=prevPX, y=prevPY, broke=false, teleport=true})
                            table.insert(points, {x=self.x, y=self.y, broke=false, teleport=true})
                        elseif frame % 2 == 0 then
                            table.insert(points, {x=self.x, y=self.y, broke=brokeThisFrame, teleport=false})
                        end
                    end

                    for _, w in ipairs(world.walls) do
                        if w.type == "pallet" then
                            local pspd = math.sqrt((w.vx or 0)^2 + (w.vy or 0)^2)
                            if pspd > 5 and frame % 2 == 0 then
                                table.insert(palletPoints, w.x + w.w/2)
                                table.insert(palletPoints, w.y + w.h/2)
                            end
                        end
                    end
                end
                table.insert(points, {x=self.x, y=self.y, broke=false, teleport=false})

                self.x, self.y = savePX, savePY
                self.vx, self.vy = saveVX, saveVY
                self.dead = saveDead
                self.reachedExit = saveExit
                self.angle = saveAngle
                self.dragging = saveDragging
                self.trail = saveTrail
                self.trailTimer = saveTrailTimer
                self._trailTimer = save_trailTimer
                portalCooldown = savePCooldown

                simulating = false

                while #world.walls > 0 do table.remove(world.walls) end
                for i, snap in ipairs(wallSnap) do
                    world.walls[i] = {}
                    for k, v in pairs(snap) do world.walls[i][k] = v end
                end

                local nPts = math.max(1, #points - 1)

                love.graphics.setLineWidth(1.2)
                for j = 1, #points - 1 do
                    local p1, p2 = points[j], points[j+1]
                    if not (p1.teleport and p2.teleport) then
                        local t = (j - 1) / nPts
                        if spikeHit then
                            love.graphics.setColor(0.15 + t*0.85, 0.55*(1-t), 1.0*(1-t), 0.32)
                        elseif hitExit then
                            love.graphics.setColor(0.20, 0.75, 0.40, 0.35)
                        else
                            love.graphics.setColor(0.10, 0.52, 1.0, 0.30)
                        end
                        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
                    end
                end

                for j = 1, #points do
                    local t   = (j - 1) / nPts
                    local dot = points[j]
                    local r, g, b, a
                    if dot.broke then
                        r, g, b, a = 0.95, 0.52, 0.08, 0.78
                    elseif dot.teleport then
                        r, g, b, a = 0.75, 0.30, 0.90, 0.70
                    elseif spikeHit then
                        r = 0.15 + t*0.85; g = 0.55*(1-t); b = 1.0*(1-t); a = 0.60
                    elseif hitExit then
                        r, g, b, a = 0.20, 0.75, 0.40, 0.60
                    else
                        r, g, b, a = 0.10, 0.55, 1.0, 0.55
                    end
                    love.graphics.setColor(r, g, b, a)
                    love.graphics.circle("fill", dot.x, dot.y, 2.5)
                end

                if #points >= 1 then
                    local ep = points[#points]
                    if hitExit then
                        love.graphics.setColor(0.20, 0.80, 0.40, 0.70)
                        love.graphics.setLineWidth(2)
                        love.graphics.circle("line", ep.x, ep.y, 7)
                        love.graphics.setColor(0.20, 0.80, 0.40, 0.45)
                        love.graphics.circle("fill", ep.x, ep.y, 4)
                    elseif spikeHit then
                        local pulse = math.sin(love.timer.getTime() * 10) * 0.5 + 0.5
                        love.graphics.setColor(1, 0.12, 0.12, 0.75 + pulse * 0.25)
                        love.graphics.setLineWidth(2)
                        love.graphics.circle("line", spikeHit.x, spikeHit.y, 11 + pulse * 3)
                        love.graphics.setColor(1, 0.12, 0.12, 1)
                        local d = 7
                        love.graphics.line(spikeHit.x-d, spikeHit.y-d, spikeHit.x+d, spikeHit.y+d)
                        love.graphics.line(spikeHit.x+d, spikeHit.y-d, spikeHit.x-d, spikeHit.y+d)
                    else
                        love.graphics.setColor(0.10, 0.55, 1.0, 0.55)
                        love.graphics.setLineWidth(1.5)
                        love.graphics.circle("line", ep.x, ep.y, 5.5)
                        love.graphics.setColor(0.10, 0.55, 1.0, 0.30)
                        love.graphics.circle("fill", ep.x, ep.y, 3)
                    end
                end

                local bc = C.COLOR_BREAKABLE
                for _, bt in ipairs(breakableTargets) do
                    local pulse = math.sin(love.timer.getTime() * 7) * 0.5 + 0.5
                    love.graphics.setColor(bc[1], bc[2], bc[3], 0.28 + pulse * 0.14)
                    love.graphics.circle("fill", bt.x, bt.y, 16)
                    love.graphics.setColor(bc[1], bc[2], bc[3], 0.88)
                    love.graphics.setLineWidth(2)
                    love.graphics.circle("line", bt.x, bt.y, 16)
                    local d = 10
                    love.graphics.setColor(1, 1, 1, 0.70)
                    love.graphics.setLineWidth(2)
                    love.graphics.line(bt.x-d, bt.y-d, bt.x+d, bt.y+d)
                    love.graphics.line(bt.x+d, bt.y-d, bt.x-d, bt.y+d)
                end

                if #palletPoints > 0 then
                    love.graphics.setColor(C.COLOR_PALLET[1], C.COLOR_PALLET[2], C.COLOR_PALLET[3], 0.65)
                    for i = 1, #palletPoints - 2, 2 do
                        love.graphics.circle("fill", palletPoints[i], palletPoints[i + 1], 3.0)
                    end
                end
            end
        end

        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.angle)
        love.graphics.setColor(1, 1, 1)
        local scale = (self.radius * 4.0) / self.spriteW
        love.graphics.draw(self.sprite, 0, 0, 0, scale, scale, self.spriteW/2, self.spriteH/2)
        love.graphics.pop()

        if darkMode then love.graphics.setShader() end
    end

    function self.startDrag(worldX, worldY)
        if self.getSpeed() > 120 or self.dead then return end
        self.dragging = true
        self.pullX, self.pullY = 0, 0
    end

    function self.updateDrag(worldX, worldY)
        if self.dragging then
            self.pullX = worldX - self.x
            self.pullY = worldY - self.y
            self.pullX, self.pullY = utils.clampVec(self.pullX, self.pullY, C.PLAYER_MAX_PULL)
        end
    end

    function self.releaseDrag()
        if self.dragging then
            local dist = math.sqrt(self.pullX*self.pullX + self.pullY*self.pullY)
            self.dragging = false
            local px, py = utils.normalize(self.pullX, self.pullY)
            self.vx, self.vy = -px * dist * C.PLAYER_LAUNCH_POWER, -py * dist * C.PLAYER_LAUNCH_POWER
            return dist / C.PLAYER_MAX_PULL
        end
        return 0
    end

    return self
end

return player
