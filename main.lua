-- Core state and systems
require('src.core.globals')
require('src.core.audio')
require('src.core.level')

-- Game modules (loaded as globals for cross-module access)
worldModule    = require("src.game.world")
playerModule   = require("src.game.player")
particleModule = require("src.game.particles")
C              = require("src.utils.constants")
physics        = require("src.utils.physics")
levelsModule   = require("src.levels.init")

-- UI
require('src.ui.layout')
require('src.ui.buttons')
require('src.ui.menu')
require('src.ui.levelselect')
require('src.ui.story')
require('src.ui.options')
require('src.ui.victory')
require('src.ui.editor.state')
require('src.ui.editor.draw')
require('src.ui.editor.handlers')
require('src.ui.handlers')

-- ─── helpers ────────────────────────────────────────────────────────────────

local function updateColors()
    if settings.darkMode then
        C.COLOR_BG           = {0.07, 0.07, 0.085}
        C.COLOR_WALL         = {0.16, 0.16, 0.19}
        C.COLOR_WALL_OUTLINE = {0.24, 0.24, 0.30}
    else
        C.COLOR_BG           = {0.93, 0.92, 0.89}
        C.COLOR_WALL         = {0.46, 0.45, 0.43}
        C.COLOR_WALL_OUTLINE = {0.46, 0.45, 0.43}
    end
end

local function touchCount()
    local n = 0; for _ in pairs(activeTouches) do n = n + 1 end; return n
end

local function touchPinchDist()
    local ids = {}
    for k in pairs(activeTouches) do ids[#ids+1] = k end
    if #ids < 2 then return nil end
    local a, b = activeTouches[ids[1]], activeTouches[ids[2]]
    return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end

-- ─── love callbacks ─────────────────────────────────────────────────────────

function love.load(arg)
    for _, v in ipairs(arg) do
        if v == "--dev" then isDevMode = true end
    end

    love.graphics.setDefaultFilter("linear", "linear", 16)
    updateColors()
    initAudio()

    local function newFont(size, scale)
        return love.graphics.newFont("assets/fonts/Jersey25.ttf", math.max(10, math.floor(size * (scale or 1))))
    end
    fonts.main    = newFont(24)
    fonts.large   = newFont(64)
    fonts.title   = newFont(92)
    fonts.options = newFont(48)
    fonts.play    = newFont(80)

    local w, h = love.graphics.getDimensions()
    buttons.play = {
        x=w/2-150, y=h/2-80, w=300, h=110, baseY=h/2-80, baseH=110,
        scale=1, targetScale=1, offsetY=-600, delay=0.35,
        rotation=0, targetRotation=0, squashX=1, squashY=1, hovered=false, landed=false,
    }
    buttons.options = {
        x=w/2-125, y=h/2+20, w=250, h=90, baseY=h/2+20, baseH=90,
        scale=1, targetScale=1, offsetY=-500, delay=0,
        rotation=0, targetRotation=0, squashX=1, squashY=1, hovered=false, landed=false,
    }

    loadProgress()
    resetGame()
    state = "menu"
    playMusic("menu")
    love.resize(love.graphics.getDimensions())
end

function love.update(dt)
    for k, v in pairs(music)  do v:setVolume(settings.musicVol) end
    for k, v in pairs(sounds) do v:setVolume(settings.sfxVol)   end

    if state == "menu" then
        menuTime = menuTime + dt
        local mx, my = love.mouse.getPosition()
        updateButton(buttons.play,    dt, mx, my)
        updateButton(buttons.options, dt, mx, my)
        return
    end

    if state == "levelSelect" then
        levelSelectTime = levelSelectTime + dt
        if not lsDrag.active and math.abs(lsDrag.velY) > 0.5 then
            levelSelectScroll = levelSelectScroll + lsDrag.velY * dt
            lsDrag.velY = lsDrag.velY * (1 - math.min(dt * 12, 1))
            if math.abs(lsDrag.velY) < 1 then lsDrag.velY = 0 end
        end
        return
    end

    if state == "story"   then storyTime   = storyTime   + dt; return end
    if state == "options" then optionsTime = optionsTime + dt; return end

    if state == "editor" then
        local mx, my = getMouseWorld()
        mx = math.floor(mx / editor.gridSize + 0.5) * editor.gridSize
        my = math.floor(my / editor.gridSize + 0.5) * editor.gridSize
        editor.curX, editor.curY = mx, my
        local speed = 500 * dt
        if love.keyboard.isDown("up")    then camY = camY - speed end
        if love.keyboard.isDown("down")  then camY = camY + speed end
        if love.keyboard.isDown("left")  then camX = camX - speed end
        if love.keyboard.isDown("right") then camX = camX + speed end
        return
    end

    if not love.window.hasFocus() then return end

    if victory then
        local mx, my = love.mouse.getPosition()
        for _, vb in pairs(victoryButtons) do
            vb.hovered = (mx >= vb.x and mx <= vb.x + vb.w and my >= vb.y and my <= vb.y + vb.h)
        end
        victoryTime = victoryTime + dt
        return
    end

    if shake > 0 then shake = shake - dt * 25; if shake < 0 then shake = 0 end end

    player.update(dt, world, particleSystem)
    player.updateDrag(getMouseWorld())
    world.update(dt, player)

    for _, w in ipairs(world.walls) do
        if w.type == "button" then
            local id = tostring(w.x) .. "_" .. tostring(w.y)
            if w.active and not prevButtonStates[id] then particleSystem.spawnActivate(w.x, w.y, w.w, w.h) end
            prevButtonStates[id] = w.active
        end
    end

    particleSystem.update(dt)

    camX = camX + (player.x - camX) * dt * 4
    camY = camY + (player.y - camY) * dt * 4

    if player.reachedExit and not victory then
        victory = true; victoryTime = 0
        completedLevels[currentLevel] = true
        saveProgress()
        particleSystem.spawnVictory(player.x, player.y)
        love.resize(love.graphics.getDimensions())
    end
    if player.dead and not deathPending then
        deathPending = true
        deathTime = 0
        sounds.death:stop(); sounds.death:play()
    end
    if deathPending then
        deathTime = deathTime + dt
    end
end

function drawGame()
    love.graphics.push()
    local w, h = love.graphics.getDimensions()
    local sx, sy = 0, 0
    if shake > 0 then
        local s = math.min(shake, 10)
        sx, sy = math.random(-s, s), math.random(-s, s)
    end
    love.graphics.translate(w/2, h/2)
    love.graphics.scale(camZoom)
    love.graphics.translate(-math.floor(camX + sx), -math.floor(camY + sy))
    world.draw()
    if particleSystem then particleSystem.draw() end
    player.draw(world, settings.darkMode)
    love.graphics.pop()
end

function love.draw()
    love.graphics.setBackgroundColor(C.COLOR_BG)

    if state == "levelSelect" then drawLevelSelect(); drawLetterbox(); return end
    if state == "story"       then drawStory();       drawLetterbox(); return end

    if state == "menu" then
        drawGame(); drawMainMenu(); drawLetterbox(); return
    end

    if state == "options" then
        if prevState == "menu" then
            drawGame()
            local w, h  = love.graphics.getDimensions()
            local scale = getUIScale()
            love.graphics.setColor(0.97, 0.96, 0.93, 0.84)
            love.graphics.rectangle("fill", 0, 0, w, h)
            local pushDist = UI_BASE_H * scale
            local pushP    = easeInQuad(math.min(optionsTime / 0.26, 1))
            love.graphics.push()
            love.graphics.translate(0, pushP * pushDist)
            drawButton(buttons.play, "Play", fonts.play)
            drawButton(buttons.options, "Options", fonts.options)
            love.graphics.pop()
        else drawGame() end
        drawOptions(); drawLetterbox(); return
    end

    if state == "editor" then drawGame(); drawEditorUI(); return end

    drawGame()
    local w, h = love.graphics.getDimensions()
    if math.abs(camZoom - 1.0) > 0.05 then
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.10, 0.10, 0.10, 0.30)
        love.graphics.printf(math.floor(camZoom * 100) .. "%", w - 90, h - 36, 80, "right")
    end
    if victory then drawVictory() end
    if deathPending then drawDeath() end
    drawLetterbox()
end

function love.resize(w, h)
    local scale   = getUIScale()
    local portrait = h > w

    local function newFont(size)
        return love.graphics.newFont("assets/fonts/Jersey25.ttf", math.max(10, math.floor(size * scale)))
    end
    fonts.main    = newFont(24)
    fonts.large   = newFont(64)
    fonts.title   = newFont(92)

    local playH = math.min(math.max(68 * scale, 56), 90)
    local optH  = math.min(math.max(52 * scale, 44), 70)
    local playW = math.min(playH * 5.2, w * 0.82)
    local optW  = math.min(optH  * 5.2, w * 0.82)

    local function btnFont(btnH)
        return love.graphics.newFont("assets/fonts/Jersey25.ttf", math.max(12, math.floor(btnH * 0.68)))
    end
    fonts.play    = btnFont(playH)
    fonts.options = btnFont(optH)

    local btnGap   = math.max(16 * scale, 14)
    local groupH   = playH + btnGap + optH
    local groupTop = h / 2 - groupH / 2

    buttons.play.w = playW; buttons.play.h = playH; buttons.play.baseH = playH
    buttons.play.x = w/2 - playW/2; buttons.play.baseY = groupTop

    buttons.options.w = optW; buttons.options.h = optH; buttons.options.baseH = optH
    buttons.options.x = w/2 - optW/2; buttons.options.baseY = groupTop + playH + btnGap

    local cy     = h / 2
    local fh     = fonts.main:getHeight()
    local labels = {"CONTINUE", "LEVEL SELECT", "RESTART"}
    local keys   = {"continue", "map", "restart"}

    if portrait then
        local btnW   = math.min(w * 0.72, 320 * scale)
        local btnH   = math.max(44 * scale, 44)
        local vGap2  = math.max(10 * scale, 8)
        local startY = cy + 68 * scale
        for i, lbl in ipairs(labels) do
            victoryButtons[keys[i]].x = w/2 - btnW/2
            victoryButtons[keys[i]].y = startY + (i-1) * (btnH + vGap2)
            victoryButtons[keys[i]].w = btnW
            victoryButtons[keys[i]].h = btnH
        end
    else
        local gap    = math.max(28 * scale, 20)
        local totalW = 0
        for _, lbl in ipairs(labels) do totalW = totalW + fonts.main:getWidth(lbl) + gap * 2 end
        local startX = w/2 - totalW/2
        local btnY   = cy + 78 * scale
        local cx2    = startX
        for i, lbl in ipairs(labels) do
            local tw = fonts.main:getWidth(lbl) + gap * 2
            victoryButtons[keys[i]].x = cx2
            victoryButtons[keys[i]].y = btnY - fh
            victoryButtons[keys[i]].w = tw
            victoryButtons[keys[i]].h = fh * 3
            cx2 = cx2 + tw
        end
    end
end

function love.focus(f)
end

function love.visible(v)
    if not v then
        for _, s in pairs(sounds) do pcall(function() s:stop() end) end
        for _, s in pairs(music)  do pcall(function() s:stop() end) end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    unlockAudio()
    activeTouches[id] = {x=x, y=y}
    local n = touchCount()
    if n == 2 then
        pinchDist0 = touchPinchDist(); pinchZoom0 = camZoom
    elseif n == 1 then
        love.mousepressed(x, y, 1)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    activeTouches[id] = {x=x, y=y}
    local n = touchCount()
    if n == 2 and pinchDist0 and pinchZoom0 then
        local dist = touchPinchDist()
        if dist and dist > 0 then
            local ratio  = dist / pinchDist0
            local powered = ratio > 1 and ratio or (ratio ^ 0.85)
            camZoom = math.max(0.25, math.min(3.0, pinchZoom0 * powered))
        end
    elseif n == 1 then
        love.mousemoved(x, y, dx, dy)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    activeTouches[id] = nil; pinchDist0 = nil; pinchZoom0 = nil
    if touchCount() == 0 then love.mousereleased(x, y, 1) end
end

function love.filedropped(file)
    local filename = file:getFilename()
    if filename:match("%.lua$") then
        local content = file:read()
        if content then
            local chunk, err = loadstring(content)
            if chunk then
                local levelData = chunk()
                if type(levelData) == "table" then
                    sounds.click:stop(); sounds.click:play()
                    resetGame(levelData); state = "game"
                end
            end
        end
    end
end

function love.directorydropped(path) end
