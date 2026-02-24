local C = require("src.utils.constants")

local particles = {}

function particles.new()
    local self = { effects = {} }

    local function push(t, p) table.insert(t, p) end

    local function ring(x, y, maxR, dur, cr, cg, cb)
        return { x=x, y=y, r=0, maxR=maxR, life=dur, maxLife=dur, cr=cr, cg=cg, cb=cb }
    end

    function self.spawnImpact(x, y, nx, ny, speed)
        local parts = {}
        local base  = math.atan2(ny, nx) + math.pi
        local t     = math.min(speed / 400, 1)
        local count = math.floor(t * 6) + 4

        for i = 1, count do
            local a   = base + (math.random() - 0.5) * math.pi * 0.8
            local spd = math.random(40, math.max(80, speed * 0.35))
            push(parts, {
                x=x, y=y, vx=math.cos(a)*spd, vy=math.sin(a)*spd,
                size=math.random()*2+0.8, life=math.random(15,40)/100, maxLife=0.40,
                r=0.85, g=0.92, b=1.0, gravity=160, friction=0.82
            })
        end

        table.insert(self.effects, {
            parts = parts, life = 0.40,
            rings = { ring(x, y, 16*t+6, 0.18, 0.72, 0.88, 1.0) }
        })
    end

    function self.spawnBreak(x, y, w, h, color)
        local parts  = {}
        local cx, cy = x + w/2, y + h/2
        local col    = color or {0.82, 0.62, 0.20}

        for i = 1, 14 do
            local a   = math.random() * math.pi * 2
            local spd = math.random(80, 260)
            push(parts, {
                x=cx+(math.random()-0.5)*w*0.6, y=cy+(math.random()-0.5)*h*0.6,
                vx=math.cos(a)*spd, vy=math.sin(a)*spd - 40,
                size=math.random()*4+1.5, life=math.random(40,80)/100, maxLife=0.80,
                r=col[1], g=col[2], b=col[3], gravity=360, friction=0.87
            })
        end

        for i = 1, 8 do
            local a   = math.random() * math.pi * 2
            local spd = math.random(150, 380)
            push(parts, {
                x=cx, y=cy, vx=math.cos(a)*spd, vy=math.sin(a)*spd - 50,
                size=math.random()*1.5+0.5, life=math.random(12,30)/100, maxLife=0.30,
                r=1.0, g=0.96, b=0.88, gravity=120, friction=0.80
            })
        end

        local maxDim = math.max(w, h)
        table.insert(self.effects, {
            parts = parts, life = 0.80,
            rings = {
                ring(cx, cy, maxDim*0.65, 0.15, col[1], col[2], col[3]),
                ring(cx, cy, maxDim*1.20, 0.28, 1.0, 0.96, 0.85),
            }
        })
    end

    function self.spawnDeath(x, y)
        local parts = {}

        for i = 1, 18 do
            local a   = (i/18)*math.pi*2
            local spd = math.random(80, 280)
            push(parts, {
                x=x, y=y, vx=math.cos(a)*spd, vy=math.sin(a)*spd,
                size=math.random()*3+1.0, life=math.random(30,70)/100, maxLife=0.70,
                r=0.72, g=0.90, b=1.0, gravity=0, friction=0.86
            })
        end

        for i = 1, 6 do
            push(parts, {
                x=x+(math.random()-0.5)*16, y=y,
                vx=(math.random()-0.5)*30, vy=-math.random(40,100),
                size=math.random()*2.5+0.8, life=math.random(40,80)/100, maxLife=0.80,
                r=0.85, g=0.95, b=1.0, gravity=-20, friction=0.92
            })
        end

        table.insert(self.effects, {
            parts = parts, life = 0.80,
            rings = {
                ring(x, y, 26, 0.16, 0.72, 0.90, 1.0),
                ring(x, y, 58, 0.28, 0.45, 0.72, 1.0),
            }
        })
    end

    function self.spawnWarp(x, y, color)
        local parts = {}
        local c     = color or {0.05, 0.60, 1.0}

        for i = 1, 10 do
            local a   = math.random() * math.pi * 2
            local spd = math.random(50, 160)
            push(parts, {
                x=x, y=y, vx=math.cos(a)*spd, vy=math.sin(a)*spd,
                size=math.random()*2.5+1.0, life=math.random(20,50)/100, maxLife=0.50,
                r=c[1], g=c[2], b=c[3], gravity=0, friction=0.80
            })
        end

        table.insert(self.effects, {
            parts = parts, life = 0.50,
            rings = { ring(x, y, 32, 0.22, c[1], c[2], c[3]) }
        })
    end

    function self.spawnActivate(x, y, w, h)
        local parts  = {}
        local cx, cy = x + w/2, y + h/2

        for i = 1, 10 do
            local a   = math.random() * math.pi * 2
            local spd = math.random(50, 160)
            push(parts, {
                x=cx, y=cy, vx=math.cos(a)*spd, vy=math.sin(a)*spd,
                size=math.random()*2.5+1.0, life=math.random(25,55)/100, maxLife=0.55,
                r=0.18, g=0.82, b=0.48, gravity=0, friction=0.80
            })
        end

        table.insert(self.effects, {
            parts = parts, life = 0.55,
            rings = { ring(cx, cy, math.max(w,h)*0.80, 0.24, 0.18, 0.82, 0.48) }
        })
    end

    function self.spawnPalletSmash(x, y, nx, ny, speed)
        local parts = {}
        local base  = math.atan2(ny, nx) + math.pi
        for i = 1, 8 do
            local a   = base + (math.random()-0.5)*math.pi*0.8
            local spd = math.random(60, math.max(100, speed * 0.4))
            push(parts, {
                x=x, y=y, vx=math.cos(a)*spd, vy=math.sin(a)*spd,
                size=math.random()*2.5+1.0, life=math.random(18,45)/100, maxLife=0.45,
                r=0.78, g=0.92, b=0.65, gravity=280, friction=0.85
            })
        end
        table.insert(self.effects, { parts=parts, life=0.45 })
    end

    function self.spawnTrail(x, y, vx, vy)
        local speed = math.sqrt(vx*vx + vy*vy)
        if speed < 150 then return end
        local parts = {}
        local px = -vy/speed
        local py =  vx/speed
        local off = (math.random()-0.5)*5
        push(parts, {
            x = x + px*off - vx*0.022,
            y = y + py*off - vy*0.022,
            vx=(math.random()-0.5)*18, vy=(math.random()-0.5)*18,
            size=math.random()*2+0.6, life=0.06+math.random()*0.07, maxLife=0.13,
            r=0.65, g=0.84, b=1.0, gravity=0, friction=0.58
        })
        table.insert(self.effects, { parts=parts, life=0.13 })
    end

    function self.spawnVictory(x, y)
        local parts  = {}
        local colors = {
            {0.05, 0.60, 1.00}, {0.18, 0.82, 0.46},
            {0.95, 0.44, 0.12}, {1.00, 0.84, 0.20},
        }
        for i = 1, 30 do
            local a   = math.random() * math.pi * 2
            local spd = math.random(100, 380)
            local col = colors[math.random(#colors)]
            push(parts, {
                x=x, y=y, vx=math.cos(a)*spd, vy=math.sin(a)*spd - 100,
                size=math.random()*4+1.5, life=math.random(60,120)/100, maxLife=1.20,
                r=col[1], g=col[2], b=col[3], gravity=240, friction=0.91
            })
        end

        for i = 1, 18 do
            local col = colors[math.random(#colors)]
            push(parts, {
                x=x+(math.random()-0.5)*70, y=y,
                vx=(math.random()-0.5)*90, vy=-math.random(160,380),
                size=math.random()*3+1.5, life=math.random(60,120)/100, maxLife=1.20,
                r=col[1], g=col[2], b=col[3], gravity=300, friction=0.92
            })
        end

        table.insert(self.effects, {
            parts = parts, life = 1.20,
            rings = {
                ring(x, y, 45,  0.18, 1.00, 0.84, 0.20),
                ring(x, y, 95,  0.32, 0.05, 0.60, 1.00),
            }
        })
    end

    function self.update(dt)
        for i = #self.effects, 1, -1 do
            local e = self.effects[i]
            e.life = e.life - dt
            if e.life <= 0 then
                table.remove(self.effects, i)
            else
                for _, p in ipairs(e.parts) do
                    p.x    = p.x + p.vx * dt
                    p.y    = p.y + p.vy * dt
                    p.vy   = p.vy + p.gravity * dt
                    local fr = 1 - (1 - p.friction) * dt * 60
                    p.vx   = p.vx * fr
                    p.vy   = p.vy * fr
                    p.life = p.life - dt
                end
                if e.rings then
                    for _, r in ipairs(e.rings) do
                        r.r    = r.r + (r.maxR / r.maxLife) * dt
                        r.life = r.life - dt
                    end
                end
            end
        end
    end

    function self.draw()
        love.graphics.setBlendMode("add")

        for _, e in ipairs(self.effects) do

            if e.rings then
                for _, r in ipairs(e.rings) do
                    if r.life > 0 then
                        local a = r.life / r.maxLife
                        love.graphics.setLineWidth(1.5)
                        love.graphics.setColor(r.cr, r.cg, r.cb, a * 0.55)
                        love.graphics.circle("line", r.x, r.y, math.max(0.5, r.r))
                    end
                end
            end

            for _, p in ipairs(e.parts) do
                if p.life > 0 then
                    local a  = math.max(0, p.life / p.maxLife)
                    local sz = math.max(0.5, p.size * (a * 0.5 + 0.5))
                    love.graphics.setColor(p.r, p.g, p.b, a * 0.80)
                    love.graphics.circle("fill", p.x, p.y, sz)
                end
            end
        end

        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
    end

    return self
end

return particles
