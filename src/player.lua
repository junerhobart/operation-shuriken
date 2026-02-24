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

function player.new(x, y)
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
                                    breakSound:stop(); breakSound:play()
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
                                            bounceSound:stop(); bounceSound:play()

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
                                    bounceSound:setVolume(math.min(impactSpeed / 800, 1) * 0.5)
                                    bounceSound:stop()
                                    bounceSound:play()
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

                local broken       = {}
                local svx = -px * dist * C.PLAYER_LAUNCH_POWER
                local svy = -py * dist * C.PLAYER_LAUNCH_POWER
                local spx, spy     = self.x, self.y

                local points       = {{x=spx, y=spy, broke=false, teleport=false}}
                local palletPoints = {}
                local playerAfterPalletPoints = {}
                local breakableTargets = {}
                local spikeHit     = nil
                local hitPallet    = false
                local hitExit      = false
                local simPCooldown = 0

                local simFDt    = 1 / 60
                local maxFrames = 160

                for frame = 1, maxFrames do
                    simPCooldown = math.max(0, simPCooldown - simFDt)

                    local fspeed = math.sqrt(svx*svx + svy*svy)
                    if fspeed < C.PLAYER_STOP_THRESHOLD then break end

                    local substeps = math.max(1, math.ceil(fspeed * simFDt / (self.radius * 0.5)))
                    substeps = math.min(substeps, 12)
                    local subDt = simFDt / substeps

                    local stopSim  = false
                    local brokeThisFrame = false
                    local teleportThisFrame = false

                    for _s = 1, substeps do
                        spx = spx + svx * subDt
                        spy = spy + svy * subDt

                        for wi = #world.walls, 1, -1 do
                            local wall = world.walls[wi]
                            local should_check = true
                            local handled = false

                            if wall.type == "door" and wall.open then should_check = false end
                            if should_check and broken[wall]      then should_check = false end
                            if should_check and wall.type == "button" then should_check = false end

                            if should_check then
                                local hit, nx, ny, mtv = physics.circleVsAABB(
                                    spx, spy, self.radius, wall.x, wall.y, wall.w, wall.h)

                                if hit then
                                    if wall.type == "exit" then
                                        hitExit = true
                                        stopSim = true
                                        handled = true

                                    elseif wall.type == "spikes" then
                                        spikeHit = {x = spx, y = spy}
                                        stopSim  = true
                                        handled  = true

                                    elseif wall.type == "breakable" then
                                        local dot = svx * nx + svy * ny
                                        if math.abs(dot) > C.PLAYER_BREAK_THRESHOLD then
                                            table.insert(breakableTargets,
                                                {x = wall.x + wall.w/2, y = wall.y + wall.h/2})
                                            broken[wall]     = true
                                            brokeThisFrame   = true
                                            handled          = true
                                        end

                                    elseif wall.type == "pallet" then
                                        local dot = svx * nx + svy * ny
                                        local impactSpeed = math.abs(dot)
                                        local transferMult = impactSpeed > 180 and 3.0 or 2.2

                                        if not hitPallet then
                                            hitPallet = true
                                            local pvx = -(nx * impactSpeed * transferMult)
                                            local pvy = -(ny * impactSpeed * transferMult)
                                            local ppx = wall.x
                                            local ppy = wall.y

                                            for pf = 1, 180 do
                                                if math.abs(pvx) < 3 and math.abs(pvy) < 3 then break end
                                                local pspd = math.sqrt(pvx*pvx + pvy*pvy)
                                                local pSubs = math.max(1, math.min(8,
                                                    math.ceil(pspd * simFDt / 10)))
                                                local pSubDt = simFDt / pSubs
                                                for _ = 1, pSubs do
                                                    ppx = ppx + pvx * pSubDt
                                                    ppy = ppy + pvy * pSubDt
                                                end
                                                pvx = pvx * (1 - 1.0 * simFDt)
                                                pvy = pvy * (1 - 1.0 * simFDt)
                                                if pf % 2 == 0 then
                                                    table.insert(palletPoints, ppx + wall.w/2)
                                                    table.insert(palletPoints, ppy + wall.h/2)
                                                end
                                            end
                                        end

                                        spx = spx + nx * mtv
                                        spy = spy + ny * mtv
                                        svx = svx - dot * nx * 0.2
                                        svy = svy - dot * ny * 0.2
                                        handled = true

                                    elseif wall.type == "portal_a" or wall.type == "portal_b" then
                                        if simPCooldown <= 0 then
                                            local tType = wall.type == "portal_a" and "portal_b" or "portal_a"
                                            for _, other in ipairs(world.walls) do
                                                if other.type == tType then
                                                    table.insert(points, {x = spx, y = spy, broke = false, teleport = true})
                                                    spx = other.x + other.w/2
                                                    spy = other.y + other.h/2
                                                    simPCooldown = 0.8
                                                    teleportThisFrame = true
                                                    local hT, tnx, tny, tmtv = physics.circleVsAABB(
                                                        spx, spy, self.radius,
                                                        other.x, other.y, other.w, other.h)
                                                    if hT then
                                                        spx = spx + tnx * tmtv
                                                        spy = spy + tny * tmtv
                                                    end
                                                    table.insert(points, {x = spx, y = spy, broke = false, teleport = true})
                                                    handled = true
                                                    break
                                                end
                                            end
                                        end
                                        handled = true
                                    end

                                    if not handled then
                                        spx = spx + nx * mtv
                                        spy = spy + ny * mtv
                                        local dot = svx * nx + svy * ny
                                        svx = (svx - 2 * dot * nx) * C.PLAYER_BOUNCE_RETENTION
                                        svy = (svy - 2 * dot * ny) * C.PLAYER_BOUNCE_RETENTION
                                    end
                                end
                            end
                        end

                        if stopSim then break end
                    end

                    svx = svx * (1 - C.PLAYER_DAMPING * simFDt)
                    svy = svy * (1 - C.PLAYER_DAMPING * simFDt)

                    if not teleportThisFrame and frame % 3 == 0 then
                        table.insert(points, {x = spx, y = spy, broke = brokeThisFrame, teleport = false})
                    end

                    if hitPallet and frame % 3 == 0 then
                        table.insert(playerAfterPalletPoints, {x = spx, y = spy})
                    end

                    if stopSim then break end
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

                if #playerAfterPalletPoints > 1 then
                    love.graphics.setLineWidth(1.0)
                    love.graphics.setColor(0.10, 0.65, 0.35, 0.25)
                    for j = 1, #playerAfterPalletPoints - 1 do
                        local p1, p2 = playerAfterPalletPoints[j], playerAfterPalletPoints[j+1]
                        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
                    end
                    for j = 1, #playerAfterPalletPoints do
                        local p = playerAfterPalletPoints[j]
                        love.graphics.setColor(0.10, 0.65, 0.35, 0.45)
                        love.graphics.circle("fill", p.x, p.y, 2)
                    end
                    if #playerAfterPalletPoints >= 1 then
                        local ep = playerAfterPalletPoints[#playerAfterPalletPoints]
                        love.graphics.setColor(0.10, 0.65, 0.35, 0.50)
                        love.graphics.setLineWidth(1.5)
                        love.graphics.circle("line", ep.x, ep.y, 5)
                    end
                end

                if #points >= 1 then
                    local ep = points[#points]
                    if hitExit then
                        love.graphics.setColor(0.20, 0.80, 0.40, 0.70)
                        love.graphics.setLineWidth(2)
                        love.graphics.circle("line", ep.x, ep.y, 7)
                        love.graphics.setColor(0.20, 0.80, 0.40, 0.45)
                        love.graphics.circle("fill", ep.x, ep.y, 4)
                    elseif not spikeHit then
                        love.graphics.setColor(0.10, 0.55, 1.0, 0.55)
                        love.graphics.setLineWidth(1.5)
                        love.graphics.circle("line", ep.x, ep.y, 5.5)
                        love.graphics.setColor(0.10, 0.55, 1.0, 0.30)
                        love.graphics.circle("fill", ep.x, ep.y, 3)
                    end
                end

                if spikeHit then
                    local pulse = math.sin(love.timer.getTime() * 10) * 0.5 + 0.5
                    local wx, wy = spikeHit.x, spikeHit.y
                    love.graphics.setColor(1, 0.12, 0.12, 0.75 + pulse * 0.25)
                    love.graphics.setLineWidth(2)
                    love.graphics.circle("line", wx, wy, 11 + pulse * 3)
                    love.graphics.setColor(1, 0.12, 0.12, 1)
                    local d = 7
                    love.graphics.line(wx-d, wy-d, wx+d, wy+d)
                    love.graphics.line(wx+d, wy-d, wx-d, wy+d)
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
