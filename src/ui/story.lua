function utf8sub(s, n)
    local count = 0; local i = 1
    while i <= #s and count < n do
        local c = s:byte(i)
        if     c < 0x80 then i = i + 1
        elseif c < 0xE0 then i = i + 2
        elseif c < 0xF0 then i = i + 3
        else                  i = i + 4 end
        count = count + 1
    end
    return s:sub(1, i - 1)
end

function utf8len(s)
    local count = 0; local i = 1
    while i <= #s do
        local c = s:byte(i)
        if     c < 0x80 then i = i + 1
        elseif c < 0xE0 then i = i + 2
        elseif c < 0xF0 then i = i + 3
        else                  i = i + 4 end
        count = count + 1
    end
    return count
end

function drawStory()
    local w, h  = love.graphics.getDimensions()
    local scale = getUIScale()
    local lvl   = levelsModule.get(currentLevel)
    if not lvl then return end

    local text = storyType == "pre" and lvl.storyPre or lvl.storyPost
    if not text then text = "" end

    local fadeIn = math.min(storyTime / 0.5, 1)
    love.graphics.setColor(0.97, 0.96, 0.93, fadeIn)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local charCount  = math.floor(storyTime * 40)
    local displayText = utf8sub(text, charCount)

    local portrait = h > w
    local cy       = h * 0.5
    local unit     = portrait and h * 0.065 or h * 0.075

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.55, 0.55, 0.55, fadeIn)
    love.graphics.printf("ACT " .. (lvl.act or "I") .. "  ·  LEVEL " .. currentLevel, 0, cy - unit * 2.6, w, "center")

    love.graphics.setFont(fonts.options)
    love.graphics.setColor(0.10, 0.10, 0.10, fadeIn)
    love.graphics.printf(lvl.name or "", 0, cy - unit * 1.8, w, "center")

    local ruleW = math.min(280 * scale, w * 0.72)
    love.graphics.setColor(0.55, 0.55, 0.55, fadeIn * 0.6)
    love.graphics.setLineWidth(1)
    love.graphics.line(w/2 - ruleW/2, cy - unit * 0.8, w/2 + ruleW/2, cy - unit * 0.8)

    local textW = math.min(w * 0.86, 480 * scale)
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.25, 0.25, 0.25, fadeIn)
    love.graphics.printf(displayText, w/2 - textW/2, cy - unit * 0.3, textW, "center")

    if charCount >= utf8len(text) then
        local blink    = math.sin(love.timer.getTime() * 2.5) * 0.25 + 0.75
        local isMobile = love.system.getOS() == "iOS" or love.system.getOS() == "Android"
        local hint     = isMobile and "Tap to continue" or "Tap or press Space to continue"
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.55, 0.55, 0.55, blink * fadeIn)
        love.graphics.printf(hint, 0, cy + unit * 2.0, w, "center")
    end
end
