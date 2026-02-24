function drawMainMenu()
    local w, h = love.graphics.getDimensions()
    local scale = getUIScale()

    love.graphics.setColor(0.97, 0.96, 0.93, 0.84)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local titleY = h * 0.14
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(0.08, 0.08, 0.08, 1)
    love.graphics.printf("Operation: Shuriken", 0, titleY, w, "center")

    local afterTitle = titleY + fonts.title:getHeight() * 0.82
    local titleW     = math.min(440 * scale, w * 0.70)
    love.graphics.setColor(0.55, 0.55, 0.55, 1)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(w/2 - titleW/2, afterTitle, w/2 + titleW/2, afterTitle)
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.55, 0.55, 0.55, 1)
    love.graphics.printf("D E M O", 0, afterTitle + 6, w, "center")

    drawButton(buttons.play,    "Play",    fonts.play)
    drawButton(buttons.options, "Options", fonts.options)

    if isDevMode then
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.65, 0.65, 0.65, 1)
        love.graphics.printf("E  —  DESIGNER", 0, h - 38 * scale, w, "center")
    end
end
