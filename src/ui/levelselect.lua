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
    local bw = s * 1.05; local bh = s * 0.72
    local bx = cx - bw / 2; local by = cy - s * 0.08
    love.graphics.rectangle("fill", bx, by, bw, bh, s * 0.16, s * 0.16)
    local arcCY = by - s * 0.02; local arcR = s * 0.34
    local lw    = math.max(2.5, s * 0.20)
    love.graphics.setLineWidth(lw)
    love.graphics.arc("line", "open", cx, arcCY, arcR, math.pi, 0)
end

function drawLevelSelect()
    local sw, sh   = love.graphics.getDimensions()
    local scale    = getUIScale()
    local portrait = sh > sw
    local t        = levelSelectTime
    local scroll   = levelSelectScroll or 0

    local panelX, panelY, panelW, panelH, nodeRadius, _, rowH = levelSelectPanelGeom(sw, sh)

    local contentH  = (levelsModule.totalLevels - 1) * rowH + nodeRadius * 2
    local maxScroll = math.max(0, contentH - panelH + nodeRadius * 2)
    scroll = math.max(0, math.min(scroll, maxScroll))
    levelSelectScroll = scroll

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

    local pageA    = math.min(t * 5, 1)
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
        local p1 = positions[i]; local p2 = positions[i + 1]
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
            local nameX = nx + r + 14
            love.graphics.setColor(0.72, 0.72, 0.72, 0.42 * bounce)
            love.graphics.print("· · · · ·", nameX, ny - fh / 2)
        end
    end

    love.graphics.setScissor()

    if maxScroll > 0 then
        local sbX  = sw - (portrait and 6 or 8)
        local sbW  = portrait and 3 or 4
        local barH = sh - scissorTop - footerH - 12
        local thmH = math.max(28, barH * panelH / (contentH + nodeRadius * 2))
        local thmY = scissorTop + 6 + (scroll / maxScroll) * (barH - thmH)
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
