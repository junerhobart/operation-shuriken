function drawVictory()
    local w, h  = love.graphics.getDimensions()
    local scale = getUIScale()
    local vt    = victoryTime or 0

    local overlayAlpha = math.min(vt * 2.5, 0.55)
    love.graphics.setColor(0, 0, 0, overlayAlpha)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local lvl  = levelsModule.get(currentLevel)
    local cy   = h / 2

    local levelText  = "LEVEL " .. currentLevel .. "  " .. (lvl and lvl.name or "")
    local levelChars = math.min(math.floor((vt - 0.2) * 35), #levelText)
    if levelChars > 0 then
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.80, 0.80, 0.80, math.min(vt * 3, 1))
        love.graphics.printf(levelText:sub(1, levelChars), 0, cy - 70 * scale, w, "center")
    end

    local titleP = math.min((vt - 0.3) * 3.5, 1)
    if titleP > 0 then
        local bounce = 1 + (1 - titleP) * math.sin(titleP * math.pi) * 0.12
        love.graphics.setFont(fonts.large)
        love.graphics.setColor(0.97, 0.96, 0.93, titleP)
        love.graphics.push()
        love.graphics.translate(w/2, cy - 18 * scale)
        love.graphics.scale(bounce, bounce)
        love.graphics.printf("COMPLETE", -w/2, 0, w, "center")
        love.graphics.pop()
    end

    local ruleP = math.min((vt - 0.5) * 4, 1)
    if ruleP > 0 then
        local ruleW = 300 * scale * ruleP
        love.graphics.setColor(0.97, 0.96, 0.93, 0.35 * ruleP)
        love.graphics.setLineWidth(1)
        love.graphics.line(w/2 - ruleW/2, cy + 56 * scale, w/2 + ruleW/2, cy + 56 * scale)
    end

    local btnA = math.min((vt - 0.7) * 3, 1)
    if btnA > 0 then
        local isLast = currentLevel >= levelsModule.totalLevels
        local vb     = victoryButtons
        local labels = { isLast and "CREDITS" or "CONTINUE", "LEVEL SELECT", "RESTART" }
        local keys   = {"continue", "map", "restart"}

        love.graphics.setFont(fonts.main)
        for i, lbl in ipairs(labels) do
            local btn = vb[keys[i]]
            local hov = btn.hovered
            local tw  = fonts.main:getWidth(lbl)
            local tx  = btn.x + btn.w/2 - tw/2
            local ty  = btn.y + (btn.h - fonts.main:getHeight()) / 2
            love.graphics.setColor(0.97, 0.96, 0.93, btnA * (hov and 1 or 0.72))
            love.graphics.print(lbl, tx, ty)
            if hov then
                love.graphics.setColor(0.97, 0.96, 0.93, btnA * 0.55)
                love.graphics.setLineWidth(1)
                love.graphics.line(tx, ty + fonts.main:getHeight() + 1,
                                   tx + tw, ty + fonts.main:getHeight() + 1)
            end
        end
    end
end
