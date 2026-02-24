function love.mousepressed(x, y, button)
    unlockAudio()
    if button ~= 1 and button ~= 2 then return end

    if state == "menu" then
        if button == 1 then
            if pointInRect(x, y, buttons.play) then
                sounds.click:stop(); sounds.click:play()
                state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0
            elseif pointInRect(x, y, buttons.options) then
                sounds.click:stop(); sounds.click:play()
                prevState = "menu"; state = "options"; optionsTime = 0
            end
        end
        return
    end

    if state == "levelSelect" then
        if button == 1 then
            lsDrag.active = true; lsDrag.startY = y; lsDrag.startScroll = levelSelectScroll or 0
            lsDrag.velY = 0; lsDrag.lastY = y; lsDrag.lastT = love.timer.getTime()
        end
        return
    end

    if state == "story" and button == 1 then
        local lvl = levelsModule.get(currentLevel)
        if lvl then
            local text    = storyType == "pre" and (lvl.storyPre or "") or (lvl.storyPost or "")
            local textLen = utf8len(text)
            local charCount = math.floor(storyTime * 40)
            if charCount < textLen then
                storyTime = textLen / 40 + 0.1
            else
                sounds.click:stop(); sounds.click:play()
                if storyType == "pre" then
                    state = "game"; playMusic("game")
                else
                    if currentLevel < levelsModule.totalLevels then
                        currentLevel = currentLevel + 1; storyType = "pre"; storyTime = 0; loadLevel(currentLevel)
                    else
                        state = "menu"; resetMenu(); playMusic("menu")
                    end
                end
            end
        end
        return
    end

    if state == "options" and button == 1 then
        local sw2, sh2 = love.graphics.getDimensions()
        local scale    = getUIScale()
        local cx       = sw2 / 2
        local tabs     = {"General", "Audio", "Display"}
        local tabSpacing = math.min(140 * scale, sw2 * 0.28)
        local tabStartX  = cx - tabSpacing
        local tabY       = math.min(165 * scale, sh2 * 0.22)
        for i, tab in ipairs(tabs) do
            local tx = tabStartX + (i - 1) * tabSpacing
            local tw = fonts.main:getWidth(tab); local th = fonts.main:getHeight()
            if x > tx - tw/2 - 12 and x < tx + tw/2 + 12 and y > tabY - 8 and y < tabY + th + 12 then
                optionsTab = tab; sounds.hover:stop(); sounds.hover:play(); return
            end
        end
        return
    end

    if state == "editor" then
        editorMousePressed(x, y, button); return
    end

    if deathPending and button == 1 then
        if deathTime > 0.5 then
            sounds.click:stop(); sounds.click:play()
            deathPending = false; deathTime = 0
            loadLevel(currentLevel)
        end
        return
    end

    if victory and button == 1 then
        local vb = victoryButtons
        local function inVB(b) return x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h end
        if inVB(vb.continue) then
            sounds.click:stop(); sounds.click:play()
            if currentLevel < levelsModule.totalLevels then
                currentLevel = currentLevel + 1; storyType = "pre"; storyTime = 0; loadLevel(currentLevel); state = "story"
            else
                storyType = "post"; storyTime = 0; state = "story"
            end
            return
        end
        if inVB(vb.map) then
            sounds.click:stop(); sounds.click:play()
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0; return
        end
        if inVB(vb.restart) then
            sounds.click:stop(); sounds.click:play(); loadLevel(currentLevel); return
        end
        return
    end

    if not victory and not deathPending and button == 1 then
        pendingDragX = x; pendingDragY = y
    end
end

function love.mousemoved(x, y, dx, dy)
    if state == "levelSelect" and lsDrag.active then
        local now = love.timer.getTime()
        levelSelectScroll = lsDrag.startScroll - (y - lsDrag.startY)
        lsDrag.velY = -(y - lsDrag.lastY) / math.max(now - lsDrag.lastT, 0.001)
        lsDrag.lastY = y; lsDrag.lastT = now
        return
    end

    if state == "editor" then
        editorMouseMoved(x, y, dx, dy); return
    end

    if state == "game" and not victory and pendingDragX then
        local dist = math.sqrt((x - pendingDragX)^2 + (y - pendingDragY)^2)
        if dist >= DRAG_THRESHOLD then
            local wx, wy = getMouseWorld()
            player.startDrag(wx, wy)
            pendingDragX = nil; pendingDragY = nil
        end
    end
end

function love.wheelmoved(x, y)
    if state == "levelSelect" then
        local speed = 60
        levelSelectScroll = levelSelectScroll + y * speed; lsDrag.velY = y * speed * 8; return
    end
    if state == "editor" then
        local mx, my = love.mouse.getPosition()
        local sw, sh = love.graphics.getDimensions()
        local oldZoom = camZoom
        camZoom = math.max(0.1, math.min(4.0, camZoom * (1 + y * 0.1)))
        local wMX = camX + (mx - sw/2) / oldZoom; local wMY = camY + (my - sh/2) / oldZoom
        camX = wMX - (mx - sw/2) / camZoom; camY = wMY - (my - sh/2) / camZoom
    elseif state == "game" then
        camZoom = math.max(0.35, math.min(2.5, camZoom * (1 + y * 0.1)))
    end
end

function love.mousereleased(x, y, button)
    _switchLock = false

    if state == "levelSelect" and button == 1 then
        local wasDrag = math.abs(y - lsDrag.startY) > 8
        lsDrag.active = false
        if not wasDrag then
            local sw, sh = love.graphics.getDimensions()
            local panelX, panelY, panelW, panelH, nodeRadius, _, rowH = levelSelectPanelGeom(sw, sh)
            local positions = levelSelectNodePositions(panelX, panelY, panelH, nodeRadius, 1, rowH, 0, 0, levelSelectScroll or 0)
            for i = 1, levelsModule.totalLevels do
                local pos = positions[i]
                if pos then
                    local dist = math.sqrt((x - pos.x)^2 + (y - pos.y)^2)
                    if dist < nodeRadius + 12 then
                        if isLevelUnlocked(i) then
                            sounds.click:stop(); sounds.click:play()
                            currentLevel = i; loadLevel(currentLevel)
                            storyType = "pre"; storyTime = 0; state = "story"
                        else
                            sounds.hover:stop(); sounds.hover:play()
                        end
                        return
                    end
                end
            end
        end
        return
    end

    if state == "editor" and button == 1 then
        editorMouseReleased(x, y, button); return
    end

    if state == "options" then saveSettings(); return end
    if state == "menu" then return end
    pendingDragX = nil; pendingDragY = nil
    if not victory and not deathPending and button == 1 then
        local r = player.releaseDrag()
        if r > 0 then shake = math.max(shake, r * 6) end
    end
end

function love.keypressed(key)
    if state == "levelSelect" then
        if key == "escape" then state = "menu"; resetMenu(); playMusic("menu") end
        return
    end

    if state == "story" then
        local lvl      = levelsModule.get(currentLevel)
        local text     = storyType == "pre" and lvl.storyPre or lvl.storyPost
        local textLen  = utf8len(text or "")
        local charCount = math.floor(storyTime * 40)
        if key == "space" or key == "return" then
            if charCount < textLen then
                storyTime = textLen / 40 + 0.1
            else
                if storyType == "pre" then
                    state = "game"; playMusic("game")
                else
                    if currentLevel < levelsModule.totalLevels then
                        currentLevel = currentLevel + 1; storyType = "pre"; storyTime = 0; loadLevel(currentLevel)
                    else
                        state = "menu"; resetMenu(); playMusic("menu")
                    end
                end
            end
        elseif key == "escape" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0
        end
        return
    end

    if state == "game" and deathPending then
        if key == "space" or key == "return" or key == "r" then
            sounds.click:stop(); sounds.click:play()
            deathPending = false; deathTime = 0
            loadLevel(currentLevel)
        elseif key == "escape" then
            deathPending = false; deathTime = 0
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0
        end
        return
    end

    if state == "game" and victory then
        if key == "space" or key == "return" then
            if currentLevel < levelsModule.totalLevels then
                currentLevel = currentLevel + 1; storyType = "pre"; storyTime = 0; loadLevel(currentLevel); state = "story"
            else
                storyType = "post"; storyTime = 0; state = "story"
            end
        elseif key == "m" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0
        elseif key == "r" then loadLevel(currentLevel)
        end
        return
    end

    if key == "escape" then
        if state == "editor" and editor.editingText then
            editor.editingText = false
        elseif state == "game" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0; speedrunTime = 0; speedrunMoveTime = 0
        elseif state == "options" then state = prevState
        elseif state == "editor" then state = "menu"; camZoom = 1.0; playMusic("menu")
        else love.event.quit()
        end
    elseif key == "r" and state == "game" then loadLevel(currentLevel)
    elseif state == "game" then
        if     key == "=" or key == "+" then camZoom = math.min(camZoom * 1.25, 2.5)
        elseif key == "-"               then camZoom = math.max(camZoom / 1.25, 0.35)
        elseif key == "0"               then camZoom = 1.0
        end
    elseif key == "e" and state == "menu" and isDevMode then
        state = "editor"; camZoom = 0.8
    elseif key == "space" and state == "editor" then
        editor.spaceHeld = true
    elseif state == "editor" then
        editorKeyPressed(key)
    end
end

function love.keyreleased(key)
    if key == "space" then editor.spaceHeld = false end
end

function love.textinput(text)
    if state == "editor" then editorTextInput(text) end
end
