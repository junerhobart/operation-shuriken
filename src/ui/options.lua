function drawOptions()
    local w, h  = love.graphics.getDimensions()
    local scale = getUIScale()
    local cx    = w / 2

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

    local tabs       = {"General", "Audio", "Display"}
    local tabSpacing = math.min(140 * scale, w * 0.28)
    local tabY       = math.min(165 * scale, h * 0.22) + drop(0.05, 0.28)
    local tabStartX  = cx - tabSpacing

    love.graphics.setFont(fonts.main)
    for i, tab in ipairs(tabs) do
        local tx  = tabStartX + (i - 1) * tabSpacing
        local tw  = fonts.main:getWidth(tab)
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

    local cOff     = drop(0.10, 0.28)
    local contentW = math.min(420 * scale, w * 0.88)
    local contentX = cx - contentW / 2
    local contentY = math.min(240 * scale, h * 0.32) + cOff
    local rowH     = math.min(90 * scale, h * 0.14)

    if optionsTab == "General" then
        drawSlider("Field of View",    settings.fov,            70, 120, contentX, contentY,           contentW, function(v) settings.fov = v end)
        drawSlider("Screen Shake",     settings.shakeIntensity,  0,  2.0, contentX, contentY + rowH,    contentW, function(v) settings.shakeIntensity = v end)
        drawSlider("Drag Sensitivity", settings.dragSense,      0.5, 2.0, contentX, contentY + rowH*2,  contentW, function(v) settings.dragSense = v end)
    elseif optionsTab == "Audio" then
        drawSlider("Music Volume", settings.musicVol, 0, 1.0, contentX, contentY,        contentW, function(v) settings.musicVol = v end)
        drawSlider("SFX Volume",   settings.sfxVol,   0, 1.0, contentX, contentY + rowH, contentW, function(v) settings.sfxVol = v end)
    elseif optionsTab == "Display" then
        drawSwitch("Fullscreen", settings.fullscreen, contentX, contentY, contentW,
            function(v) settings.fullscreen = v; if love.system.getOS() ~= "Web" then love.window.setFullscreen(v) end end)
    end

    local footerA  = math.min(math.max(optionsTime - 0.25, 0) / 0.20, 1)
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
    else        love.graphics.setColor(0.78, 0.77, 0.74, 1) end
    love.graphics.rectangle("fill", sx, y, sw, sh, sh/2, sh/2)
    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", sx, y, sw, sh, sh/2, sh/2)

    love.graphics.setColor(0.98, 0.97, 0.95, 1)
    local knobR = sh/2 - 3
    local kx    = val and sx + sw - knobR - 3 or sx + knobR + 3
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
