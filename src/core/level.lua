function saveProgress()
    local lines = {}
    for k, v in pairs(completedLevels) do
        if v then table.insert(lines, tostring(k)) end
    end
    love.filesystem.write("save.txt", table.concat(lines, "\n"))
end

function loadProgress()
    if love.filesystem.getInfo("save.txt") then
        local data = love.filesystem.read("save.txt")
        for line in data:gmatch("[^\n]+") do
            local n = tonumber(line)
            if n then completedLevels[n] = true end
        end
    end
end

function resetGame(levelData)
    world = worldModule.new(levelData)
    local lvl = levelsModule.get(currentLevel)
    local sx, sy = 230, 350
    if lvl and lvl.startX then sx, sy = lvl.startX, lvl.startY end
    player = playerModule.new(sx, sy)
    if not particleSystem then particleSystem = particleModule.new() end
    prevButtonStates = {}
    victory = false
    shake   = 0
    camX, camY = player.x, player.y
    camZoom = 1.0
end

function loadLevel(n)
    currentLevel = n
    local lvl = levelsModule.get(n)
    if lvl then
        local wallsCopy = {}
        for _, w in ipairs(lvl.walls) do
            local copy = {}
            for k, v in pairs(w) do copy[k] = v end
            table.insert(wallsCopy, copy)
        end
        world = worldModule.new(wallsCopy)
        world.tutorialTexts = {}
        if lvl.texts then
            for _, t in ipairs(lvl.texts) do
                table.insert(world.tutorialTexts, {x=t.x, y=t.y, text=t.text})
            end
        end
        player = playerModule.new(lvl.startX or 100, lvl.startY or 300)
    end
    if not particleSystem then particleSystem = particleModule.new() end
    prevButtonStates = {}
    victory = false
    shake   = 0
    camX, camY = player.x, player.y
    camZoom = 1.0
end

function isLevelUnlocked(n)
    if n == 1 then return true end
    if isDevMode then return true end
    return completedLevels[n - 1] == true
end

function resetMenu()
    menuTime = 0
    buttons.play.landed    = false; buttons.play.offsetY    = -600
    buttons.options.landed = false; buttons.options.offsetY = -500
end

function getMouseWorld()
    local mx, my = love.mouse.getPosition()
    local w, h   = love.graphics.getDimensions()
    return camX + (mx - w/2) / camZoom, camY + (my - h/2) / camZoom
end
