UI_BASE_W, UI_BASE_H = 1024, 768
UI_MAX_ASPECT = 21/9

function isPortraitScreen()
    local w, h = love.graphics.getDimensions()
    return h > w
end

function getUIScale()
    local w, h = love.graphics.getDimensions()
    local portrait = h > w
    local s
    if portrait then

        s = w / UI_BASE_W
    else

        s = math.min(w / UI_BASE_W, h / UI_BASE_H)
    end

    return math.max(0.38, math.min(s, 2.2))
end

function getUIViewport()
    local w, h = love.graphics.getDimensions()
    local aspect = w / h
    local vw, vh = w, h
    local ox, oy = 0, 0

    if aspect > UI_MAX_ASPECT then
        vw = h * UI_MAX_ASPECT
        ox = (w - vw) / 2
    end
    return ox, oy, vw, vh
end

function getUIScaleCentered()
    local ox, oy, vw, vh = getUIViewport()
    local scale = math.min(vw / UI_BASE_W, vh / UI_BASE_H)
    return scale, ox, oy, vw, vh
end

function drawLetterbox()
    local w, h = love.graphics.getDimensions()
    local aspect = w / h

    if aspect > UI_MAX_ASPECT then
        local vw = h * UI_MAX_ASPECT
        local barW = (w - vw) / 2
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, barW, h)
        love.graphics.rectangle("fill", w - barW, 0, barW, h)
    end
end

function easeOutBounce(t)
    if t < 1/2.75 then return 7.5625 * t * t
    elseif t < 2/2.75 then t = t - 1.5/2.75; return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then t = t - 2.25/2.75; return 7.5625 * t * t + 0.9375
    else t = t - 2.625/2.75; return 7.5625 * t * t + 0.984375 end
end

function easeInQuad(t) return t * t end

function pointInRect(px, py, btn)
    local x, y, w, h = btn.x, btn.y, btn.w, btn.h
    local s = btn.scale
    local cx, cy = x + w/2, y + h/2
    local sw, sh = w * s, h * s
    local sx, sy = cx - sw/2, cy - sh/2
    return px >= sx and px <= sx + sw and py >= sy and py <= sy + sh
end

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
    local fh      = font:getHeight()
    local textW   = dw * 0.80
    local textX   = dx + dw * 0.10
    local textY   = dy + (dh - fh) / 2
    love.graphics.printf(label, textX, textY, textW, "center")
end

function drawVictoryButton(bx, by, bw, bh, label, alpha, hovered)
    local s   = hovered and 1.06 or 1.0
    local cx  = bx + bw / 2
    local cy  = by + bh / 2
    local sw  = bw * s
    local sh  = bh * s
    local sx  = cx - sw / 2
    local sy  = cy - sh / 2
    local r   = math.max(5, 6 * (bh / 60))

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
        btn.y = btn.baseY + btn.offsetY * (1 - easeInQuad(progress))
        btn.rotation = math.sin(progress * 8) * 0.08 * (1 - progress)
    elseif t < 0.9 then
        local bounceT = (t - 0.4) / 0.5
        if not btn.landed then btn.landed = true; btn.squashX = 1.3; btn.squashY = 0.7; sounds.drop:stop(); sounds.drop:play() end
        btn.y = btn.baseY; btn.rotation = btn.rotation * 0.85
        local squashDecay = 1 - easeOutBounce(bounceT)
        btn.squashX = 1 + 0.3 * squashDecay * math.cos(bounceT * math.pi * 3)
        btn.squashY = 1 - 0.3 * squashDecay * math.cos(bounceT * math.pi * 3)
    else
        btn.y = btn.baseY; btn.rotation = btn.rotation * 0.9
        btn.squashX = btn.squashX + (1 - btn.squashX) * dt * 12
        btn.squashY = btn.squashY + (1 - btn.squashY) * dt * 12
        local hovered = pointInRect(mx, my, btn)
        if hovered and not btn.hovered then sounds.hover:stop(); sounds.hover:play() end
        btn.hovered = hovered; btn.targetScale = hovered and 1.08 or 1
    end
    btn.scale = btn.scale + (btn.targetScale - btn.scale) * dt * 14
end

function levelSelectPanelGeom(sw, sh)
    local portrait   = sh > sw
    local nodeRadius = math.max(math.min(
        portrait and math.floor(sw * 0.055) or math.floor(sh * 0.038), 30), 16)
    local rowH   = nodeRadius * 3.8

    local topPad = math.floor(portrait and sh * 0.18 or sh * 0.20)
    local botPad = math.floor(portrait and sh * 0.08 or sh * 0.07)
    return 0, topPad, sw, sh - topPad - botPad, nodeRadius, 1, rowH, 0, 0
end

function levelSelectNodePositions(panelX, panelY, panelH, nodeRadius, _npr, rowH, _spX, _hPad, scroll, cx)
    local sw, sh = love.graphics.getDimensions()
    if not cx then
        love.graphics.setFont(fonts.main)
        local maxNameW = 0
        for i = 1, levelsModule.totalLevels do
            local lvl = levelsModule.get(i)
            if lvl and lvl.name then
                local nw = fonts.main:getWidth(lvl.name)
                if nw > maxNameW then maxNameW = nw end
            end
        end
        local blockW = nodeRadius * 2 + 14 + maxNameW
        cx = math.floor(sw / 2 - blockW / 2 + nodeRadius)
    end
    local sway  = math.min(sw * 0.05, 28)
    local baseY = panelY + panelH - nodeRadius - 16 + scroll

    local positions = {}
    for i = 1, levelsModule.totalLevels do
        local row = i - 1
        local nx  = cx + math.sin(row * 0.72) * sway
        local ny  = baseY - row * rowH
        positions[i] = {x = nx, y = ny}
    end
    local contentH = (levelsModule.totalLevels - 1) * rowH + nodeRadius * 2
    return positions, contentH
end

function levelSelectLayout(sw, sh)
    local panelX, panelY, panelW, panelH, nodeRadius, _, rowH = levelSelectPanelGeom(sw, sh)
    return 1, nodeRadius, 0, rowH, panelX, panelY, panelW, panelH, 0
end

local function drawLockIcon(cx, cy, s, col, alpha)
    love.graphics.setColor(col[1], col[2], col[3], alpha)

    local bw = s * 1.05
    local bh = s * 0.72
    local bx = cx - bw / 2
    local by = cy - s * 0.08
    love.graphics.rectangle("fill", bx, by, bw, bh, s * 0.16, s * 0.16)

    local arcCY  = by - s * 0.02
    local arcR   = s * 0.34
    local lw     = math.max(2.5, s * 0.20)
    love.graphics.setLineWidth(lw)
    love.graphics.arc("line", "open", cx, arcCY, arcR, math.pi, 0)
end

function drawLevelSelect()
    local sw, sh    = love.graphics.getDimensions()
    local scale     = getUIScale()
    local portrait  = sh > sw
    local t         = levelSelectTime
    local scroll    = levelSelectScroll or 0

    local panelX, panelY, panelW, panelH, nodeRadius, _, rowH = levelSelectPanelGeom(sw, sh)

    local contentH  = (levelsModule.totalLevels - 1) * rowH + nodeRadius * 2
    local maxScroll = math.max(0, contentH - panelH + nodeRadius * 2)
    scroll = math.max(0, math.min(scroll, maxScroll))
    levelSelectScroll = scroll

    -- Compute cx so the whole [circle + gap + longest name] block is centered on screen
    love.graphics.setFont(fonts.main)
    local maxNameW = 0
    for i = 1, levelsModule.totalLevels do
        local lvl = levelsModule.get(i)
        if lvl and lvl.name then
            local nw = fonts.main:getWidth(lvl.name)
            if nw > maxNameW then maxNameW = nw end
        end
    end
    local blockW = nodeRadius * 2 + 14 + maxNameW
    local cx     = math.floor(sw / 2 - blockW / 2 + nodeRadius)

    local positions = levelSelectNodePositions(panelX, panelY, panelH, nodeRadius, 1, rowH, 0, 0, scroll, cx)

    love.graphics.setColor(0.97, 0.96, 0.93, math.min(t * 6, 0.92))
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local pageA = math.min(t * 5, 1)

    local titleOff = (1 - easeOutBounce(math.min(t * 2.8, 1))) * -50
    local titleY   = portrait and sh * 0.045 or sh * 0.055
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(0.08, 0.08, 0.08, pageA)
    love.graphics.printf("Select Mission", 0, titleY + titleOff, sw, "center")

    local ruleY = titleY + fonts.large:getHeight() + 10 + titleOff
    local ruleW = math.min(320 * scale, sw * 0.82)
    love.graphics.setColor(0.55, 0.55, 0.55, pageA * 0.8)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(sw / 2 - ruleW / 2, ruleY, sw / 2 + ruleW / 2, ruleY)

    local scissorTop = panelY
    local footerH    = portrait and sh * 0.07 or sh * 0.065
    love.graphics.setScissor(0, scissorTop, sw, sh - scissorTop - footerH)

    for i = 1, levelsModule.totalLevels - 1 do
        local p1 = positions[i]
        local p2 = positions[i + 1]
        if p1 and p2 then
            local delay = 0.12 + (i - 1) * 0.022
            local prog  = math.max(0, math.min((t - delay) * 5, 1))
            if prog > 0 then
                local ex = p1.x + (p2.x - p1.x) * prog
                local ey = p1.y + (p2.y - p1.y) * prog
                love.graphics.setColor(0.72, 0.72, 0.72, 0.65 * prog)
                love.graphics.setLineWidth(1.5)
                love.graphics.line(p1.x, p1.y, ex, ey)
            end
        end
    end

    local mx, my = love.mouse.getPosition()

    love.graphics.setFont(fonts.main)
    local fh = fonts.main:getHeight()

    for i = 1, levelsModule.totalLevels do
        local lvl       = levelsModule.get(i)
        local pos       = positions[i]
        if not pos then break end
        local unlocked  = isLevelUnlocked(i)
        local completed = completedLevels[i] == true

        local delay = 0.10 + (i - 1) * 0.030
        local prog  = math.max(0, math.min((t - delay) * 4.5, 1))
        if prog <= 0 then break end

        local bounce = easeOutBounce(prog)
        local nx, ny = pos.x, pos.y
        local dist   = math.sqrt((mx - nx)^2 + (my - ny)^2)
        local hov    = unlocked and dist < nodeRadius + 12
        local r      = nodeRadius * bounce * (hov and 1.10 or 1.0)

        love.graphics.setColor(0.10, 0.10, 0.10, 0.10 * bounce)
        love.graphics.circle("fill", nx + 2, ny + 3, r)

        if completed then
            love.graphics.setColor(0.87, 0.96, 0.87, bounce)
        elseif not unlocked then
            love.graphics.setColor(0.91, 0.90, 0.89, bounce * 0.75)
        elseif hov then
            love.graphics.setColor(1.0, 1.0, 0.98, bounce)
        else
            love.graphics.setColor(0.98, 0.97, 0.95, bounce)
        end
        love.graphics.circle("fill", nx, ny, r)

        love.graphics.setLineWidth(2)
        if completed then
            love.graphics.setColor(0.22, 0.65, 0.35, bounce)
        elseif unlocked then
            love.graphics.setColor(0.10, 0.10, 0.10, (hov and 1 or 0.75) * bounce)
        else
            love.graphics.setColor(0.68, 0.68, 0.68, 0.5 * bounce)
        end
        love.graphics.circle("line", nx, ny, r)

        if unlocked then

            love.graphics.setFont(fonts.main)
            if completed then
                love.graphics.setColor(0.18, 0.55, 0.30, bounce)
            else
                love.graphics.setColor(0.10, 0.10, 0.10, (hov and 1 or 0.85) * bounce)
            end
            love.graphics.printf(tostring(i), nx - 50, ny - fh/2 + 1, 100, "center")

            local nameX = nx + r + 14
            love.graphics.setColor(0.28, 0.28, 0.28, (hov and 1 or 0.85) * bounce)
            love.graphics.print(lvl and lvl.name or "", nameX, ny - fh/2)

            if completed then
                local bx2, by2 = nx + r * 0.60, ny - r * 0.60
                love.graphics.setColor(0.22, 0.65, 0.35, bounce)
                love.graphics.circle("fill", bx2, by2, r * 0.28)
                love.graphics.setColor(1, 1, 1, bounce)
                love.graphics.setLineWidth(1.5)
                local cs = r * 0.12
                love.graphics.line(bx2 - cs, by2 + cs*0.1,
                                   bx2 - cs*0.1, by2 + cs*0.9,
                                   bx2 + cs, by2 - cs*0.7)
            end
        else

            love.graphics.setFont(fonts.main)
            love.graphics.setColor(0.62, 0.62, 0.62, 0.65 * bounce)
            love.graphics.printf("?", nx - 50, ny - fh / 2 + 1, 100, "center")

            love.graphics.setFont(fonts.main)
            local nameX = nx + r + 14
            love.graphics.setColor(0.72, 0.72, 0.72, 0.42 * bounce)
            love.graphics.print("· · · · ·", nameX, ny - fh / 2)
        end
    end

    love.graphics.setScissor()

    if maxScroll > 0 then
        local sbX   = sw - (portrait and 6 or 8)
        local sbW   = portrait and 3 or 4
        local barH  = sh - scissorTop - footerH - 12
        local thmH  = math.max(28, barH * panelH / (contentH + nodeRadius * 2))
        local thmY  = scissorTop + 6 + (scroll / maxScroll) * (barH - thmH)
        love.graphics.setColor(0.10, 0.10, 0.10, 0.06)
        love.graphics.rectangle("fill", sbX, scissorTop + 4, sbW, barH, 2, 2)
        love.graphics.setColor(0.10, 0.10, 0.10, 0.20)
        love.graphics.rectangle("fill", sbX, thmY, sbW, thmH, 2, 2)
    end

    local footerA = math.min(math.max(t - 0.3, 0) / 0.25, 1)
    local isMobile = love.system.getOS() == "iOS" or love.system.getOS() == "Android"
    local hint = isMobile and "Tap a level to play" or "Click a level  ·  ESC to go back"
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.58, 0.58, 0.58, footerA)
    love.graphics.printf(hint, 0, sh - footerH * 0.55, sw, "center")
end

function drawStory()
    local w, h = love.graphics.getDimensions()
    local scale = getUIScale()
    local lvl = levelsModule.get(currentLevel)
    if not lvl then return end

    local text = storyType == "pre" and lvl.storyPre or lvl.storyPost
    if not text then return end

    local fadeIn = math.min(storyTime / 0.5, 1)
    love.graphics.setColor(0.97, 0.96, 0.93, fadeIn)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local charCount = math.floor(storyTime * 40)
    local displayText = utf8sub(text, charCount)

    local portrait = h > w
    local cy = h * 0.5
    local unit = portrait and h * 0.065 or h * 0.075

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.55, 0.55, 0.55, fadeIn)
    love.graphics.printf("ACT " .. (lvl.act or "I") .. "  ·  LEVEL " .. currentLevel, 0, cy - unit * 2.6, w, "center")

    love.graphics.setFont(fonts.options)
    love.graphics.setColor(0.10, 0.10, 0.10, fadeIn)
    love.graphics.printf(lvl.name, 0, cy - unit * 1.8, w, "center")

    local ruleW = math.min(280 * scale, w * 0.72)
    love.graphics.setColor(0.55, 0.55, 0.55, fadeIn * 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.line(w/2 - ruleW/2, cy - unit * 0.8, w/2 + ruleW/2, cy - unit * 0.8)

    local textW = math.min(w * 0.86, 480 * scale)
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.25, 0.25, 0.25, fadeIn)
    love.graphics.printf(displayText, w/2 - textW/2, cy - unit * 0.3, textW, "center")

    if charCount >= utf8len(text) then
        local blink = math.sin(love.timer.getTime() * 2.5) * 0.25 + 0.75
        local isMobile = love.system.getOS() == "iOS" or love.system.getOS() == "Android"
        local hint = isMobile and "Tap to continue" or "Tap or press Space to continue"
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.55, 0.55, 0.55, blink * fadeIn)
        love.graphics.printf(hint, 0, cy + unit * 2.0, w, "center")
    end
end

function utf8sub(s, n)
    local count = 0
    local i = 1
    while i <= #s and count < n do
        local c = s:byte(i)
        if c < 0x80 then i = i + 1
        elseif c < 0xE0 then i = i + 2
        elseif c < 0xF0 then i = i + 3
        else i = i + 4 end
        count = count + 1
    end
    return s:sub(1, i - 1)
end

function utf8len(s)
    local count = 0
    local i = 1
    while i <= #s do
        local c = s:byte(i)
        if c < 0x80 then i = i + 1
        elseif c < 0xE0 then i = i + 2
        elseif c < 0xF0 then i = i + 3
        else i = i + 4 end
        count = count + 1
    end
    return count
end

function drawEditorUI()
    local w, h = love.graphics.getDimensions()
    local TH  = editor.TOPBAR_H
    local LW  = editor.LEFT_W
    local RW  = editor.RIGHT_W

    love.graphics.push()
    love.graphics.translate(w/2, h/2)
    love.graphics.scale(camZoom)
    love.graphics.translate(-math.floor(camX), -math.floor(camY))

    if editor.showGrid then
        local startX = (camX - w/2) - ((camX - w/2) % editor.gridSize)
        local startY = (camY - h/2) - ((camY - h/2) % editor.gridSize)
        local ext = math.ceil(math.max(w, h) / camZoom) + editor.gridSize * 2
        love.graphics.setLineWidth(0.5 / camZoom)
        love.graphics.setColor(1, 1, 1, 0.07)
        for gx = startX - ext, startX + ext * 2, editor.gridSize do
            love.graphics.line(gx, startY - ext, gx, startY + ext * 2)
        end
        for gy = startY - ext, startY + ext * 2, editor.gridSize do
            love.graphics.line(startX - ext, gy, startX + ext * 2, gy)
        end
    end

    if editor.isDrawing and editor.curX then
        local rx  = math.min(editor.startX, editor.curX)
        local ry  = math.min(editor.startY, editor.curY)
        local rw2 = math.abs(editor.curX - editor.startX)
        local rh2 = math.abs(editor.curY - editor.startY)
        local tc  = EDITOR_COLORS[editor.selectedType] or {1, 1, 1}
        love.graphics.setColor(tc[1], tc[2], tc[3], 0.22)
        love.graphics.rectangle("fill", rx, ry, rw2, rh2)
        love.graphics.setColor(tc[1], tc[2], tc[3], 1)
        love.graphics.setLineWidth(1.5 / camZoom)
        love.graphics.rectangle("line", rx, ry, rw2, rh2)
        if rw2 > 30 and rh2 > 20 then
            love.graphics.setFont(fonts.main)
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.print(rw2 .. " × " .. rh2, rx + 4/camZoom, ry + 4/camZoom, 0, 1/camZoom, 1/camZoom)
        end
    end

    if editor.selectedWall and world.walls[editor.selectedWall] then
        local sw = world.walls[editor.selectedWall]
        love.graphics.setColor(0.05, 0.60, 1.0, 0.18)
        love.graphics.rectangle("fill", sw.x, sw.y, sw.w, sw.h)
        love.graphics.setColor(0.05, 0.60, 1.0, 1)
        love.graphics.setLineWidth(2 / camZoom)
        love.graphics.rectangle("line", sw.x, sw.y, sw.w, sw.h)
        local hw = 5 / camZoom
        for _, cp in ipairs({{sw.x, sw.y},{sw.x+sw.w, sw.y},{sw.x, sw.y+sw.h},{sw.x+sw.w, sw.y+sw.h}}) do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("fill", cp[1]-hw/2, cp[2]-hw/2, hw, hw)
            love.graphics.setColor(0.05, 0.60, 1.0, 1)
            love.graphics.setLineWidth(1.5 / camZoom)
            love.graphics.rectangle("line", cp[1]-hw/2, cp[2]-hw/2, hw, hw)
        end
    end

    if world.tutorialTexts then
        local r = 7 / camZoom
        for i, t in ipairs(world.tutorialTexts) do
            local isSel = (editor.selectedText == i)

            if isSel then
                love.graphics.setColor(0.05, 0.60, 1.0, 0.22)
                love.graphics.circle("fill", t.x, t.y, r * 2.4)
                love.graphics.setColor(0.05, 0.60, 1.0, 1)
                love.graphics.setLineWidth(1.8 / camZoom)
                love.graphics.circle("line", t.x, t.y, r * 2.4)
            end

            love.graphics.setColor(isSel and 0.05 or 0.92, isSel and 0.60 or 0.82, isSel and 1.0 or 0.28, 1)
            love.graphics.circle("fill", t.x, t.y, r)
            love.graphics.setColor(0, 0, 0, 0.30)
            love.graphics.setLineWidth(1.2 / camZoom)
            love.graphics.circle("line", t.x, t.y, r)

            local firstLine = (t.text:match("([^\n]+)") or t.text):sub(1, 26)
            if editor.editingText and isSel then

                if math.floor(love.timer.getTime() * 2) % 2 == 0 then
                    firstLine = firstLine .. "|"
                end
            end
            love.graphics.setFont(fonts.main)
            love.graphics.setColor(0.90, 0.90, 0.90, 0.70)
            love.graphics.print(firstLine, t.x + r + 5/camZoom, t.y - fonts.main:getHeight()/(2*camZoom), 0, 1/camZoom, 1/camZoom)
        end
    end

    love.graphics.pop()

    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", 0, 0, w, TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(0, TH, w, TH)

    love.graphics.setFont(fonts.main)

    love.graphics.setColor(0.42, 0.42, 0.44, 1)
    love.graphics.printf("DESIGNER", 0, (TH - fonts.main:getHeight())/2, w, "center")

    love.graphics.setColor(0.30, 0.30, 0.32, 1)
    love.graphics.printf(math.floor(camZoom * 100) .. "%", 0, (TH - fonts.main:getHeight())/2, w - RW - 16, "right")

    love.graphics.setColor(0.28, 0.28, 0.30, 1)
    local undoLabel = #editor.undoStack > 0 and (#editor.undoStack .. " undo" .. (#editor.undoStack ~= 1 and "s" or "")) or "no undos"
    love.graphics.printf(undoLabel, LW + 8, (TH - fonts.main:getHeight())/2, 140, "left")

    local notifAge = love.timer.getTime() - editor.saveNotifTime
    if notifAge < 2.0 then
        local a = math.min(1, (2.0 - notifAge) / 0.4)
        love.graphics.setColor(0.15, 0.85, 0.45, a)
        love.graphics.printf("Saved to clipboard!", LW + 160, (TH - fonts.main:getHeight())/2, 220, "center")
    end

    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", 0, TH, LW, h - TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(LW, TH, LW, h)

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("TILES", 0, TH + 10, LW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(8, TH + 33, LW - 8, TH + 33)

    local itemH  = 32
    local listY  = TH + 41
    for i, typeName in ipairs(editor.types) do
        local isSel = (editor.selectedType == typeName)
        local iy    = listY + (i - 1) * itemH
        if isSel then
            love.graphics.setColor(0.05, 0.60, 1.0, 0.13)
            love.graphics.rectangle("fill", 0, iy, LW, itemH)
            love.graphics.setColor(0.05, 0.60, 1.0, 1)
            love.graphics.rectangle("fill", 0, iy, 3, itemH)
        end
        local tc = EDITOR_COLORS[typeName] or {0.5, 0.5, 0.5}
        love.graphics.setColor(tc[1], tc[2], tc[3], 1)
        love.graphics.rectangle("fill", 13, iy + (itemH - 12)/2, 12, 12, 2, 2)
        love.graphics.setColor(isSel and 0.88 or 0.46, isSel and 0.88 or 0.46, isSel and 0.88 or 0.48, 1)
        love.graphics.print(typeName, 33, iy + (itemH - fonts.main:getHeight())/2)
        if i <= 9 then
            love.graphics.setColor(0.34, 0.34, 0.36, 1)
            love.graphics.printf(tostring(i), 0, iy + (itemH - fonts.main:getHeight())/2, LW - 9, "right")
        end
    end

    local txSectY = listY + #editor.types * itemH + 6
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(8, txSectY, LW - 8, txSectY)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("TEXT NODES", 0, txSectY + 7, LW, "center")

    local txItemH = 26
    local txListY = txSectY + 27
    if world.tutorialTexts then
        for i, t in ipairs(world.tutorialTexts) do
            local isSel = (editor.selectedText == i)
            local iy    = txListY + (i - 1) * txItemH
            if isSel then
                love.graphics.setColor(0.05, 0.60, 1.0, 0.13)
                love.graphics.rectangle("fill", 0, iy, LW, txItemH)
                love.graphics.setColor(0.05, 0.60, 1.0, 1)
                love.graphics.rectangle("fill", 0, iy, 3, txItemH)
            end
            love.graphics.setColor(0.92, 0.82, 0.28, 1)
            love.graphics.circle("fill", 20, iy + txItemH/2, 4)
            local preview = (t.text:match("([^\n]+)") or t.text):sub(1, 15)
            love.graphics.setColor(isSel and 0.88 or 0.44, isSel and 0.88 or 0.44, isSel and 0.88 or 0.46, 1)
            love.graphics.print(preview, 32, iy + (txItemH - fonts.main:getHeight())/2)
        end
    end

    love.graphics.setColor(0.28, 0.28, 0.30, 1)
    love.graphics.printf("T — Add text", 0, h - 48, LW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.printf("Ctrl+Z  Undo     G  Grid", 0, h - 28, LW, "center")

    local rpx = w - RW
    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", rpx, TH, RW, h - TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(rpx, TH, rpx, h)

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("PROPERTIES", rpx, TH + 10, RW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(rpx + 8, TH + 33, w - 8, TH + 33)

    local py2  = TH + 44
    local lx   = rpx + 13
    local rowH = 25
    local function propRow(label, val, ry)
        love.graphics.setColor(0.32, 0.32, 0.34, 1)
        love.graphics.print(label, lx, ry)
        love.graphics.setColor(0.78, 0.78, 0.80, 1)
        love.graphics.printf(tostring(val), rpx, ry, RW - 10, "right")
    end

    if editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then

        local t = world.tutorialTexts[editor.selectedText]
        propRow("X", t.x, py2)
        propRow("Y", t.y, py2 + rowH)
        love.graphics.setColor(0.22, 0.22, 0.24, 1)
        love.graphics.line(rpx + 8, py2 + rowH * 2 + 2, w - 8, py2 + rowH * 2 + 2)
        love.graphics.setColor(0.32, 0.32, 0.34, 1)
        love.graphics.print("text", lx, py2 + rowH * 2 + 10)

        local boxY = py2 + rowH * 3 + 2
        local boxH = 84
        love.graphics.setColor(0.09, 0.09, 0.10, 1)
        love.graphics.rectangle("fill", rpx + 10, boxY, RW - 20, boxH, 4, 4)
        if editor.editingText then
            love.graphics.setColor(0.05, 0.60, 1.0, 0.55)
        else
            love.graphics.setColor(0.24, 0.24, 0.26, 1)
        end
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", rpx + 10, boxY, RW - 20, boxH, 4, 4)

        local cursor = (editor.editingText and math.floor(love.timer.getTime() * 2) % 2 == 0) and "|" or ""
        love.graphics.setColor(0.80, 0.80, 0.82, 1)
        love.graphics.printf(t.text .. cursor, rpx + 14, boxY + 6, RW - 28, "left")

        love.graphics.setColor(0.34, 0.34, 0.36, 1)
        if editor.editingText then
            love.graphics.printf("Esc — stop editing", rpx, boxY + boxH + 8, RW, "center")
        else
            love.graphics.printf("Enter — edit text", rpx, boxY + boxH + 8, RW, "center")
        end

        love.graphics.setColor(0.60, 0.12, 0.12, 1)
        love.graphics.rectangle("fill", rpx + 12, h - 46, RW - 24, 28, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("DELETE  Del", rpx, h - 46 + (28 - fonts.main:getHeight())/2, RW, "center")

    elseif editor.selectedWall and world.walls[editor.selectedWall] then

        local sw = world.walls[editor.selectedWall]
        propRow("X", sw.x, py2)
        propRow("Y", sw.y, py2 + rowH)
        propRow("W", sw.w, py2 + rowH * 2)
        propRow("H", sw.h, py2 + rowH * 3)
        love.graphics.setColor(0.22, 0.22, 0.24, 1)
        love.graphics.line(rpx + 8, py2 + rowH * 4 + 2, w - 8, py2 + rowH * 4 + 2)
        propRow("type",   sw.type,   py2 + rowH * 4 + 10)
        if sw.id     then propRow("id",     sw.id,     py2 + rowH * 5 + 10) end
        if sw.target then propRow("target", sw.target, py2 + rowH * 6 + 10) end

        love.graphics.setColor(0.60, 0.12, 0.12, 1)
        love.graphics.rectangle("fill", rpx + 12, h - 46, RW - 24, 28, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("DELETE  Del", rpx, h - 46 + (28 - fonts.main:getHeight())/2, RW, "center")

    else

        love.graphics.setColor(0.26, 0.26, 0.28, 1)
        love.graphics.printf(
            "Click  —  select\nDrag  —  draw new\nDrag corner  —  resize\nDel  —  delete\n\nT  —  add text\nTab  —  next tile\n1–9  —  tile type\nF  —  fit view\nG  —  grid",
            rpx, TH + 52, RW, "center")
    end

    if editor.isDragging then
        love.graphics.setColor(0.05, 0.60, 1.0, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.05, 0.60, 1.0, 1)
        love.graphics.printf("MOVING", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    elseif editor.isResizing then
        love.graphics.setColor(0.68, 0.28, 0.92, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.68, 0.28, 0.92, 1)
        love.graphics.printf("RESIZING", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    elseif editor.editingText then
        love.graphics.setColor(0.92, 0.82, 0.28, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.92, 0.82, 0.28, 1)
        love.graphics.printf("EDITING TEXT", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    end

    love.graphics.setColor(0.24, 0.24, 0.26, 1)
    local txCount = (world.tutorialTexts and #world.tutorialTexts or 0)
    love.graphics.printf(#world.walls .. " walls  " .. txCount .. " texts", rpx, h - 26, RW, "center")
end

function drawOptions()
    local w, h = love.graphics.getDimensions()
    local scale = getUIScale()
    local cx = w / 2

    local dropDist = 60 * scale
    local function drop(delay, dur)
        local p = easeOutBounce(math.min(math.max(optionsTime - delay, 0) / dur, 1))
        return -dropDist * (1 - p)
    end

    love.graphics.setColor(0.97, 0.96, 0.93, math.min(optionsTime * 6, 0.92))
    love.graphics.rectangle("fill", 0, 0, w, h)

    local titleOff = drop(0, 0.28)
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(0.08, 0.08, 0.08, 1)
    love.graphics.printf("Options", 0, 60 * scale + titleOff, w, "center")

    local ruleW = 320 * scale
    local ruleY = 140 * scale + titleOff
    love.graphics.setColor(0.55, 0.55, 0.55, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(cx - ruleW/2, ruleY, cx + ruleW/2, ruleY)

    local tabs = {"General", "Audio", "Display"}
    local tabSpacing = math.min(140 * scale, w * 0.28)
    local tabY = math.min(165 * scale, h * 0.22) + drop(0.05, 0.28)
    local tabStartX = cx - tabSpacing

    love.graphics.setFont(fonts.main)
    for i, tab in ipairs(tabs) do
        local tx = tabStartX + (i - 1) * tabSpacing
        local tw = fonts.main:getWidth(tab)
        local sel = optionsTab == tab

        love.graphics.setColor(sel and 0.08 or 0.55, sel and 0.08 or 0.55, sel and 0.08 or 0.55, 1)
        love.graphics.print(tab, tx - tw/2, tabY)

        if sel then
            love.graphics.setColor(0.08, 0.08, 0.08, 0.8)
            love.graphics.setLineWidth(1.5)
            love.graphics.line(tx - tw/2 - 4, tabY + fonts.main:getHeight() + 4,
                               tx + tw/2 + 4, tabY + fonts.main:getHeight() + 4)
        end
    end

    local cOff = drop(0.10, 0.28)
    local contentW = math.min(420 * scale, w * 0.88)
    local contentX = cx - contentW / 2
    local contentY = math.min(240 * scale, h * 0.32) + cOff
    local rowH = math.min(90 * scale, h * 0.14)

    if optionsTab == "General" then
        drawSlider("Field of View",    settings.fov,            70, 120, contentX, contentY,          contentW, function(v) settings.fov = v end)
        drawSlider("Screen Shake",     settings.shakeIntensity,  0, 2.0, contentX, contentY + rowH,    contentW, function(v) settings.shakeIntensity = v end)
        drawSlider("Drag Sensitivity", settings.dragSense,      0.5, 2.0, contentX, contentY + rowH*2, contentW, function(v) settings.dragSense = v end)
    elseif optionsTab == "Audio" then
        drawSlider("Music Volume", settings.musicVol, 0, 1.0, contentX, contentY,       contentW, function(v) settings.musicVol = v end)
        drawSlider("SFX Volume",   settings.sfxVol,   0, 1.0, contentX, contentY + rowH, contentW, function(v) settings.sfxVol = v end)
    elseif optionsTab == "Display" then
        drawSwitch("Fullscreen", settings.fullscreen, contentX, contentY, contentW,
            function(v) settings.fullscreen = v; if love.system.getOS() ~= "Web" then love.window.setFullscreen(v) end end)
    end

    local footerA = math.min(math.max(optionsTime - 0.25, 0) / 0.20, 1)
    local isMobile = love.system.getOS() == "iOS" or love.system.getOS() == "Android"
    local closeHint = isMobile and "Tap outside to close" or "ESC — close"
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.55, 0.55, 0.55, footerA)
    love.graphics.printf(closeHint, 0, h - math.max(44 * scale, h * 0.06), w, "center")
end

function drawSlider(label, val, min, max, x, y, w, callback)
    love.graphics.setFont(fonts.main)

    love.graphics.setColor(0.18, 0.18, 0.18, 1)
    love.graphics.print(label, x, y - 28)

    local valStr = string.format(max <= 2 and "%.2f" or "%.0f", val)
    love.graphics.setColor(0.52, 0.52, 0.50, 1)
    love.graphics.printf(valStr, x, y - 28, w, "right")

    love.graphics.setColor(0.78, 0.77, 0.74, 1)
    love.graphics.rectangle("fill", x, y - 1, w, 4, 2, 2)

    local fillW = math.max(0, (val - min) / (max - min) * w)
    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.rectangle("fill", x, y - 1, fillW, 4, 2, 2)

    love.graphics.setColor(0.98, 0.97, 0.95, 1)
    love.graphics.circle("fill", x + fillW, y + 1, 8)
    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x + fillW, y + 1, 8)

    local mx, my = love.mouse.getPosition()
    if mx > x - 12 and mx < x + w + 12 and my > y - 18 and my < y + 22 and love.mouse.isDown(1) then
        callback(math.max(min, math.min(max, min + (mx - x) / w * (max - min))))
    end
end

function drawSwitch(label, val, x, y, contentW, callback)
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.18, 0.18, 0.18, 1)
    love.graphics.print(label, x, y + 5)
    local sw, sh = 48, 26
    local sx = x + contentW - sw

    if val then love.graphics.setColor(0.10, 0.10, 0.10, 1)
    else love.graphics.setColor(0.78, 0.77, 0.74, 1) end
    love.graphics.rectangle("fill", sx, y, sw, sh, sh/2, sh/2)

    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", sx, y, sw, sh, sh/2, sh/2)

    love.graphics.setColor(0.98, 0.97, 0.95, 1)
    local knobR = sh/2 - 3
    local kx = val and sx + sw - knobR - 3 or sx + knobR + 3
    love.graphics.circle("fill", kx, y + sh/2, knobR)
    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.circle("line", kx, y + sh/2, knobR)

    local mx, my = love.mouse.getPosition()
    if mx > sx and mx < sx + sw and my > y and my < y + sh then
        if love.mouse.isDown(1) and not _switchLock then
            callback(not val); _switchLock = true
            sounds.click:stop(); sounds.click:play()
        end
    end
end
