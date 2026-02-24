function drawButton(btn, label, font)
    local x, y, w, h = btn.x, btn.y, btn.w, btn.h
    local s  = btn.scale
    local cx = x + w / 2
    local cy = y + h / 2
    local dw = w * s * btn.squashX
    local dh = h * s * btn.squashY
    local dx = cx - dw / 2
    local dy = cy - dh / 2
    local r  = math.max(6, dh * 0.10)
    local lw = math.max(1.5, dh * 0.028)

    love.graphics.setColor(0.10, 0.10, 0.10, 0.18)
    love.graphics.rectangle("fill", dx + 3, dy + 5, dw, dh, r, r)
    love.graphics.setColor(0.98, 0.97, 0.95, 1)
    love.graphics.rectangle("fill", dx, dy, dw, dh, r, r)
    love.graphics.setColor(0.10, 0.10, 0.10, 1)
    love.graphics.setLineWidth(lw)
    love.graphics.rectangle("line", dx, dy, dw, dh, r, r)

    love.graphics.setFont(font)
    love.graphics.setColor(0.10, 0.10, 0.10, 1)
    local fh    = font:getHeight()
    local textW = dw * 0.80
    local textX = dx + dw * 0.10
    local textY = dy + (dh - fh) / 2
    love.graphics.printf(label, textX, textY, textW, "center")
end

function drawVictoryButton(bx, by, bw, bh, label, alpha, hovered)
    local s  = hovered and 1.06 or 1.0
    local cx = bx + bw / 2; local cy = by + bh / 2
    local sw = bw * s;      local sh = bh * s
    local sx = cx - sw / 2; local sy = cy - sh / 2
    local r  = math.max(5, 6 * (bh / 60))

    love.graphics.setColor(0.10, 0.10, 0.10, 0.18 * alpha)
    love.graphics.rectangle("fill", sx + 3, sy + 4, sw, sh, r, r)
    love.graphics.setColor(0.98, 0.97, 0.95, alpha)
    love.graphics.rectangle("fill", sx, sy, sw, sh, r, r)
    love.graphics.setColor(0.10, 0.10, 0.10, alpha)
    love.graphics.setLineWidth(hovered and 2.0 or 1.5)
    love.graphics.rectangle("line", sx, sy, sw, sh, r, r)
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.10, 0.10, 0.10, alpha)
    love.graphics.printf(label, sx, sy + (sh - fonts.main:getHeight()) / 2, sw, "center")
end

function updateButton(btn, dt, mx, my)
    local t = math.max(0, menuTime - btn.delay)
    if t < 0.4 then
        local progress = t / 0.4
        btn.y        = btn.baseY + btn.offsetY * (1 - easeInQuad(progress))
        btn.rotation = math.sin(progress * 8) * 0.08 * (1 - progress)
    elseif t < 0.9 then
        local bounceT = (t - 0.4) / 0.5
        if not btn.landed then
            btn.landed  = true
            btn.squashX = 1.3; btn.squashY = 0.7
            sounds.drop:stop(); sounds.drop:play()
        end
        btn.y        = btn.baseY
        btn.rotation = btn.rotation * 0.85
        local squashDecay = 1 - easeOutBounce(bounceT)
        btn.squashX = 1 + 0.3 * squashDecay * math.cos(bounceT * math.pi * 3)
        btn.squashY = 1 - 0.3 * squashDecay * math.cos(bounceT * math.pi * 3)
    else
        btn.y        = btn.baseY
        btn.rotation = btn.rotation * 0.9
        btn.squashX  = btn.squashX + (1 - btn.squashX) * dt * 12
        btn.squashY  = btn.squashY + (1 - btn.squashY) * dt * 12
        local hovered = pointInRect(mx, my, btn)
        if hovered and not btn.hovered then sounds.hover:stop(); sounds.hover:play() end
        btn.hovered     = hovered
        btn.targetScale = hovered and 1.08 or 1
    end
    btn.scale = btn.scale + (btn.targetScale - btn.scale) * dt * 14
end
