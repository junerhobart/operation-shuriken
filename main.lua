worldModule   = require("src.world")
playerModule  = require("src.player")
C             = require("src.utils.constants")
physics       = require("src.utils.physics")
particleModule= require("src.particles")
levelsModule  = require("src.levels.init")

world, player         = nil, nil
particleSystem        = nil
victoryButtons        = {
    continue = {x=0, y=0, w=0, h=0, hovered=false},
    map      = {x=0, y=0, w=0, h=0, hovered=false},
    restart  = {x=0, y=0, w=0, h=0, hovered=false},
}
prevButtonStates      = {}
shake                 = 0
victory               = false
victoryTime           = 0
camX, camY            = 0, 0
camZoom               = 1.0
state                 = "menu"
prevState             = "menu"
optionsTab            = "General"
fonts                 = {}
sounds                = {}
music                 = {}
buttons               = {}
settings = {
    fov = 90,
    musicVol = 0.5,
    sfxVol = 0.7,
    shakeIntensity = 1.0,
    dragSense = 1.0,
    darkMode = false,
    fullscreen = false
}
menuTime              = 0
optionsTime           = 0
audioUnlocked         = false
isDevMode             = false
_switchLock           = false

currentLevel          = 1
completedLevels       = {}

lsDrag = {
    active   = false,
    startY   = 0,
    startScroll = 0,
    velY     = 0,
    lastY    = 0,
    lastT    = 0,
}

activeTouches  = {}
pinchDist0     = nil
pinchZoom0     = nil
pendingDragX   = nil   -- screen coords of touch-down, nil when not pending
pendingDragY   = nil
DRAG_THRESHOLD = 10    -- pixels before drag commits

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
levelSelectTime       = 0
levelSelectScroll     = 0
storyTime             = 0
storyType             = "pre"
levelTransition       = 0
transitionDir         = 0

editor = {
    gridSize = 20,
    showGrid = true,
    selectedType = "normal",
    startX = 0, startY = 0,
    isDrawing = false,
    types = {"normal", "breakable", "spikes", "pallet", "button", "portal_a", "portal_b", "door", "exit"},
    selectedWall = nil,
    undoStack = {},
    spaceHeld = false,
    curX = 0, curY = 0,
    TOPBAR_H = 44,
    LEFT_W = 200,
    RIGHT_W = 220,
    isDragging = false,
    dragOffsetX = 0, dragOffsetY = 0,
    isResizing = false,
    resizeHandle = nil,
    resizeAnchorX = 0, resizeAnchorY = 0,

    selectedText  = nil,
    editingText   = false,
    isDraggingText = false,
    textDragOffX  = 0, textDragOffY = 0,

    _pendingSnap  = nil,
    saveNotifTime = -99,
}

EDITOR_COLORS = {
    normal    = {0.45, 0.47, 0.52},
    breakable = {0.82, 0.62, 0.20},
    spikes    = {0.90, 0.28, 0.28},
    pallet    = {0.25, 0.72, 0.52},
    button    = {0.24, 0.53, 0.95},
    portal_a  = {0.68, 0.28, 0.92},
    portal_b  = {0.45, 0.28, 0.92},
    door      = {0.62, 0.42, 0.18},
    exit      = {0.18, 0.82, 0.42}
}

function takeSnapshot()
    local snap = {}
    for _, wall in ipairs(world.walls) do
        local copy = {}
        for k, v in pairs(wall) do copy[k] = v end
        table.insert(snap, copy)
    end
    return snap
end

function pushUndo()
    table.insert(editor.undoStack, takeSnapshot())
    if #editor.undoStack > 50 then table.remove(editor.undoStack, 1) end
end

function commitPendingSnap()
    if editor._pendingSnap then
        table.insert(editor.undoStack, editor._pendingSnap)
        if #editor.undoStack > 50 then table.remove(editor.undoStack, 1) end
        editor._pendingSnap = nil
    end
end

function playMusic(track)
    for _, v in pairs(music) do pcall(function() v:stop() end) end
    if music[track] then
        pcall(function()
            music[track]:setLooping(true)
            music[track]:setVolume(settings.musicVol)
            music[track]:play()
        end)
    end
end

function unlockAudio()
    if not audioUnlocked then
        local ok, soundData = pcall(love.sound.newSoundData, 512, 44100, 16, 1)
        if ok and soundData then
            local ok2, src = pcall(love.audio.newSource, soundData, "static")
            if ok2 and src then pcall(function() src:play() end) end
        end
        audioUnlocked = true
    end
end

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

require('src.ui.draw')
require('src.ui.editor')
require('src.ui.handlers')

function love.load(arg)
    for _, v in ipairs(arg) do
        if v == "--dev" then isDevMode = true end
    end

    love.graphics.setDefaultFilter("linear", "linear", 16)
    updateColors()

    fonts.main = love.graphics.newFont("assets/fonts/Jersey25.ttf", 24)
    fonts.large = love.graphics.newFont("assets/fonts/Jersey25.ttf", 64)
    fonts.title = love.graphics.newFont("assets/fonts/Jersey25.ttf", 92)
    fonts.options = love.graphics.newFont("assets/fonts/Jersey25.ttf", 48)
    fonts.play = love.graphics.newFont("assets/fonts/Jersey25.ttf", 80)

    sounds.click = love.audio.newSource("assets/audio/sound-effects/click.wav", "static")
    sounds.hover = love.audio.newSource("assets/audio/sound-effects/hover.wav", "static")
    sounds.drop = love.audio.newSource("assets/audio/sound-effects/drop.wav", "static")
    sounds.bounce = love.audio.newSource("assets/audio/sound-effects/bounce.wav", "static")
    sounds.death = love.audio.newSource("assets/audio/sound-effects/squish.wav", "static")

    music.menu = love.audio.newSource("assets/audio/music/menu-loop.wav", "stream")
    music.game = love.audio.newSource("assets/audio/music/stealth-loop.wav", "stream")
    music.action = love.audio.newSource("assets/audio/music/action-loop.wav", "stream")

    local w, h = love.graphics.getDimensions()
    buttons.play = {
        x = w/2 - 150, y = h/2 - 80, w = 300, h = 110,
        baseY = h/2 - 80, baseH = 110, scale = 1, targetScale = 1,
        offsetY = -600, delay = 0.35, rotation = 0, targetRotation = 0,
        squashX = 1, squashY = 1, hovered = false, landed = false
    }
    buttons.options = {
        x = w/2 - 125, y = h/2 + 20, w = 250, h = 90,
        baseY = h/2 + 20, baseH = 90, scale = 1, targetScale = 1,
        offsetY = -500, delay = 0, rotation = 0, targetRotation = 0,
        squashX = 1, squashY = 1, hovered = false, landed = false
    }

    loadProgress()
    resetGame()
    state = "menu"
    playMusic("menu")

    love.resize(love.graphics.getDimensions())
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
    shake = 0
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
        if lvl.texts then
            world.tutorialTexts = {}
            for _, t in ipairs(lvl.texts) do
                table.insert(world.tutorialTexts, {x = t.x, y = t.y, text = t.text})
            end
        else
            world.tutorialTexts = {}
        end
        player = playerModule.new(lvl.startX or 100, lvl.startY or 300)
    end
    if not particleSystem then particleSystem = particleModule.new() end
    prevButtonStates = {}
    victory = false
    shake = 0
    camX, camY = player.x, player.y
    camZoom = 1.0
end

function isLevelUnlocked(n)
    if n == 1 then return true end
    return completedLevels[n - 1] == true
end

function resetMenu()
    menuTime = 0
    buttons.play.landed = false; buttons.play.offsetY = -600
    buttons.options.landed = false; buttons.options.offsetY = -500
end

function getMouseWorld()
    local mx, my = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    return camX + (mx - w/2) / camZoom, camY + (my - h/2) / camZoom
end

function love.update(dt)

    for k, v in pairs(music) do v:setVolume(settings.musicVol) end
    for k, v in pairs(sounds) do v:setVolume(settings.sfxVol) end

    if state == "menu" then
        menuTime = menuTime + dt
        local mx, my = love.mouse.getPosition()
        updateButton(buttons.play, dt, mx, my)
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

    if state == "story" then
        storyTime = storyTime + dt
        return
    end

    if state == "options" then
        optionsTime = optionsTime + dt
        return
    end

    if state == "editor" then
        local mx, my = getMouseWorld()
        mx = math.floor(mx / editor.gridSize + 0.5) * editor.gridSize
        my = math.floor(my / editor.gridSize + 0.5) * editor.gridSize
        editor.curX, editor.curY = mx, my

        local speed = 500 * dt
        if love.keyboard.isDown("up") then camY = camY - speed end
        if love.keyboard.isDown("down") then camY = camY + speed end
        if love.keyboard.isDown("left") then camX = camX - speed end
        if love.keyboard.isDown("right") then camX = camX + speed end
        return
    end

    if not love.window.hasFocus() then return end

    if victory then

        local mx, my = love.mouse.getPosition()
        for _, vb in pairs(victoryButtons) do
            vb.hovered = (mx >= vb.x and mx <= vb.x + vb.w and
                          my >= vb.y and my <= vb.y + vb.h)
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
            if w.active and not prevButtonStates[id] then
                particleSystem.spawnActivate(w.x, w.y, w.w, w.h)
            end
            prevButtonStates[id] = w.active
        end
    end

    particleSystem.update(dt)

    local targetCamX, targetCamY = player.x, player.y
    camX = camX + (targetCamX - camX) * dt * 4
    camY = camY + (targetCamY - camY) * dt * 4

    if player.reachedExit and not victory then
        victory = true
        victoryTime = 0
        completedLevels[currentLevel] = true
        saveProgress()
        particleSystem.spawnVictory(player.x, player.y)
        love.resize(love.graphics.getDimensions())
    end
    if player.dead then
        sounds.death:stop(); sounds.death:play()
        loadLevel(currentLevel)
    end
end

function love.focus(f)
    if not f and state == "game" then

    end
end

function love.visible(v)
    if not v then
        for _, s in pairs(sounds) do pcall(function() s:stop() end) end
        for _, s in pairs(music)  do pcall(function() s:stop() end) end
    end
end

function love.resize(w, h)
    local scale = getUIScale()
    local portrait = h > w

    local function newFont(size)
        return love.graphics.newFont("assets/fonts/Jersey25.ttf",
            math.max(10, math.floor(size * scale)))
    end
    fonts.main  = newFont(24)
    fonts.large = newFont(64)
    fonts.title = newFont(92)

    local playH = math.min(math.max(68 * scale, 56), 90)
    local optH  = math.min(math.max(52 * scale, 44), 70)
    local playW = math.min(playH * 5.2, w * 0.82)
    local optW  = math.min(optH  * 5.2, w * 0.82)

    local function btnFont(btnH)
        return love.graphics.newFont("assets/fonts/Jersey25.ttf",
            math.max(12, math.floor(btnH * 0.68)))
    end
    fonts.play    = btnFont(playH)
    fonts.options = btnFont(optH)

    local playBaseH = playH
    local optBaseH  = optH

    local btnGap   = math.max(16 * scale, 14)
    local groupH   = playH + btnGap + optH
    local groupTop = h / 2 - groupH / 2

    buttons.play.w     = playW
    buttons.play.h     = playH
    buttons.play.baseH = playBaseH
    buttons.play.x     = w/2 - playW/2
    buttons.play.baseY = groupTop

    buttons.options.w     = optW
    buttons.options.h     = optH
    buttons.options.baseH = optBaseH
    buttons.options.x     = w/2 - optW/2
    buttons.options.baseY = groupTop + playH + btnGap

    local cy      = h / 2
    local fh      = fonts.main:getHeight()
    local labels  = {"CONTINUE", "LEVEL SELECT", "RESTART"}
    local keys    = {"continue", "map", "restart"}
    local portrait = h > w
    -- On mobile/portrait: stack vertically with large tap targets
    -- On landscape/desktop: horizontal row
    if portrait then
        local btnW   = math.min(w * 0.72, 320 * scale)
        local btnH   = math.max(44 * scale, 44)
        local vGap2  = math.max(10 * scale, 8)
        local totalH = #labels * btnH + (#labels - 1) * vGap2
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

function love.touchpressed(id, x, y, dx, dy, pressure)
    unlockAudio()
    activeTouches[id] = {x=x, y=y}
    local n = touchCount()
    if n == 2 then
        pinchDist0 = touchPinchDist()
        pinchZoom0 = camZoom
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
            -- apply 1.15x power curve so zooming out feels more responsive
            local ratio = dist / pinchDist0
            local powered = ratio > 1 and ratio or (ratio ^ 0.85)
            camZoom = math.max(0.25, math.min(3.0, pinchZoom0 * powered))
        end
    elseif n == 1 then
        love.mousemoved(x, y, dx, dy)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    activeTouches[id] = nil
    pinchDist0 = nil
    pinchZoom0 = nil
    if touchCount() == 0 then
        love.mousereleased(x, y, 1)
    end
end

function love.filedropped(file)
    local filename = file:getFilename()
    if filename:match("%.lua$") then
        local content, size = file:read()
        if content then

            local chunk, err = loadstring(content)
            if chunk then
                local levelData = chunk()
                if type(levelData) == "table" then
                    sounds.click:stop(); sounds.click:play()
                    resetGame(levelData)
                    state = "game"
                end
            end
        end
    end
end

function love.directorydropped(path)

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

    if state == "levelSelect" then
        drawLevelSelect()
        drawLetterbox()
        return
    end

    if state == "story" then
        drawStory()
        drawLetterbox()
        return
    end

    if state == "menu" then
        drawGame()
        local w, h = love.graphics.getDimensions()
        local scale = getUIScale()
        local t = menuTime

        love.graphics.setColor(0.97, 0.96, 0.93, 0.84)
        love.graphics.rectangle("fill", 0, 0, w, h)

        local titleY = h * 0.14
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.08, 0.08, 0.08, 1)
        love.graphics.printf("Operation: Shuriken", 0, titleY, w, "center")

        local afterTitle = titleY + fonts.title:getHeight() * 0.82
        local titleW = math.min(440 * scale, w * 0.70)
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
        drawLetterbox()
        return
    end
    if state == "options" then
        if prevState == "menu" then
            drawGame()
            local w, h = love.graphics.getDimensions()
            local scale = getUIScale()
            love.graphics.setColor(0.97, 0.96, 0.93, 0.84)
            love.graphics.rectangle("fill", 0, 0, w, h)

            local pushDist = UI_BASE_H * scale
            local pushP = easeInQuad(math.min(optionsTime / 0.26, 1))
            love.graphics.push()
            love.graphics.translate(0, pushP * pushDist)
            drawButton(buttons.play, "Play", fonts.play)
            drawButton(buttons.options, "Options", fonts.options)
            love.graphics.pop()
        else drawGame() end
        drawOptions()
        drawLetterbox()
        return
    end
    if state == "editor" then
        drawGame()
        drawEditorUI()
        return
    end
    drawGame()
    local w, h = love.graphics.getDimensions()

    if math.abs(camZoom - 1.0) > 0.05 then
        love.graphics.setFont(fonts.main)
        love.graphics.setColor(0.10, 0.10, 0.10, 0.30)
        love.graphics.printf(math.floor(camZoom * 100) .. "%", w - 90, h - 36, 80, "right")
    end
    if victory then
        local scale = getUIScale()
        local vt = victoryTime or 0

        local overlayAlpha = math.min(vt * 2.5, 0.55)
        love.graphics.setColor(0, 0, 0, overlayAlpha)
        love.graphics.rectangle("fill", 0, 0, w, h)

        local lvl = levelsModule.get(currentLevel)
        local cy  = h / 2
        local textA = math.min(vt * 3, 1)

        local levelText = "LEVEL " .. currentLevel .. "  " .. (lvl and lvl.name or "")
        local levelChars = math.min(math.floor((vt - 0.2) * 35), #levelText)
        if levelChars > 0 then
            love.graphics.setFont(fonts.main)
            love.graphics.setColor(0.80, 0.80, 0.80, textA)
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
            local vb = victoryButtons
            local labels = {
                isLast and "CREDITS" or "CONTINUE",
                "LEVEL SELECT",
                "RESTART",
            }
            local keys = {"continue", "map", "restart"}

            love.graphics.setFont(fonts.main)
            for i, lbl in ipairs(labels) do
                local btn = vb[keys[i]]
                local hov = btn.hovered

                local tw = fonts.main:getWidth(lbl)
                local tx = btn.x + btn.w/2 - tw/2
                local ty = btn.y + (btn.h - fonts.main:getHeight()) / 2
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
    drawLetterbox()
end
