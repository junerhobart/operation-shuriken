function love.mousepressed(x, y, button)
    unlockAudio()
    if button ~= 1 and button ~= 2 then return end

    if state == "menu" then
        if button == 1 then
            if pointInRect(x, y, buttons.play) then
                sounds.click:stop(); sounds.click:play()
                state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0
            elseif pointInRect(x, y, buttons.options) then
                sounds.click:stop(); sounds.click:play()
                prevState = "menu"; state = "options"; optionsTime = 0
            end
        end
        return
    end

    if state == "levelSelect" then
        if button == 1 then

            lsDrag.active      = true
            lsDrag.startY      = y
            lsDrag.startScroll = levelSelectScroll or 0
            lsDrag.velY        = 0
            lsDrag.lastY       = y
            lsDrag.lastT       = love.timer.getTime()
        end
        return
    end

    if state == "story" and button == 1 then
        local lvl = levelsModule.get(currentLevel)
        if lvl then
            local text = storyType == "pre" and (lvl.storyPre or "") or (lvl.storyPost or "")
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
                        currentLevel = currentLevel + 1
                        storyType = "pre"; storyTime = 0
                        loadLevel(currentLevel)
                    else
                        state = "menu"; resetMenu(); playMusic("menu")
                    end
                end
            end
        end
        return
    end

    if state == "options" then
        if button == 1 then
            local sw2, sh2 = love.graphics.getDimensions()
            local scale = getUIScale()
            local cx = sw2 / 2
            local tabs = {"General", "Audio", "Display"}
            local tabSpacing = math.min(140 * scale, sw2 * 0.28)
            local tabStartX = cx - tabSpacing
            local tabY = math.min(165 * scale, sh2 * 0.22)

            for i, tab in ipairs(tabs) do
                local tx = tabStartX + (i - 1) * tabSpacing
                local tw = fonts.main:getWidth(tab)
                local th = fonts.main:getHeight()
                if x > tx - tw/2 - 12 and x < tx + tw/2 + 12 and y > tabY - 8 and y < tabY + th + 12 then
                    optionsTab = tab
                    sounds.hover:stop(); sounds.hover:play()
                    return
                end
            end
        end
        return
    end

    if state == "editor" then
        local sx, sy = love.mouse.getPosition()
        local sw2    = love.graphics.getWidth()
        local TH = editor.TOPBAR_H
        local LW = editor.LEFT_W
        local RW = editor.RIGHT_W

        if sy < TH then return end

        if sx < LW then
            if button == 1 then
                local itemH  = 32
                local listY  = TH + 41
                for i, typeName in ipairs(editor.types) do
                    local iy = listY + (i - 1) * itemH
                    if sy >= iy and sy < iy + itemH then
                        editor.selectedType = typeName
                        sounds.hover:play()
                        return
                    end
                end

                if world.tutorialTexts then
                    local txSectY = listY + #editor.types * itemH + 6
                    local txListY = txSectY + 27
                    local txItemH = 26
                    for i = 1, #world.tutorialTexts do
                        local iy = txListY + (i - 1) * txItemH
                        if sy >= iy and sy < iy + txItemH then
                            editor.selectedText = i
                            editor.selectedWall = nil
                            editor.editingText  = false
                            sounds.hover:play()
                            return
                        end
                    end
                end
            end
            return
        end

        if sx > sw2 - RW then return end

        if editor.spaceHeld then return end

        local mx2, my2 = getMouseWorld()

        if button == 1 then
            editor.editingText = false

            if editor.selectedWall and world.walls[editor.selectedWall] then
                local sel       = world.walls[editor.selectedWall]
                local hitRadius = 10 / camZoom
                local corners   = {
                    tl = {sel.x,         sel.y},
                    tr = {sel.x + sel.w, sel.y},
                    bl = {sel.x,         sel.y + sel.h},
                    br = {sel.x + sel.w, sel.y + sel.h},
                }
                for handleName, cp in pairs(corners) do
                    if math.abs(mx2 - cp[1]) < hitRadius and math.abs(my2 - cp[2]) < hitRadius then
                        pushUndo()
                        editor.isResizing = true
                        editor.resizeHandle = handleName
                        if handleName == "tl" then
                            editor.resizeAnchorX = sel.x + sel.w; editor.resizeAnchorY = sel.y + sel.h
                        elseif handleName == "tr" then
                            editor.resizeAnchorX = sel.x;         editor.resizeAnchorY = sel.y + sel.h
                        elseif handleName == "bl" then
                            editor.resizeAnchorX = sel.x + sel.w; editor.resizeAnchorY = sel.y
                        elseif handleName == "br" then
                            editor.resizeAnchorX = sel.x;         editor.resizeAnchorY = sel.y
                        end
                        return
                    end
                end
            end

            if world.tutorialTexts then
                local txHit = 13 / camZoom
                for i, t in ipairs(world.tutorialTexts) do
                    if math.abs(mx2 - t.x) < txHit and math.abs(my2 - t.y) < txHit then
                        editor.selectedText    = i
                        editor.selectedWall    = nil
                        editor.isDraggingText  = true
                        editor.textDragOffX    = mx2 - t.x
                        editor.textDragOffY    = my2 - t.y
                        sounds.hover:play()
                        return
                    end
                end
            end

            local hit = nil
            for i = #world.walls, 1, -1 do
                local wall = world.walls[i]
                if mx2 >= wall.x and mx2 <= wall.x + wall.w and
                   my2 >= wall.y and my2 <= wall.y + wall.h then
                    hit = i; break
                end
            end

            if hit then
                editor.selectedText = nil
                if editor.selectedWall == hit then

                    editor._pendingSnap  = takeSnapshot()
                    editor.isDragging    = true
                    local sel = world.walls[hit]
                    editor.dragOffsetX   = mx2 - sel.x
                    editor.dragOffsetY   = my2 - sel.y
                else

                    editor.selectedWall = hit
                    sounds.hover:play()
                end
            else

                local gs = editor.gridSize
                local gx = math.floor(mx2 / gs + 0.5) * gs
                local gy = math.floor(my2 / gs + 0.5) * gs
                editor.startX       = gx
                editor.startY       = gy
                editor.isDrawing    = true
                editor.selectedWall = nil
                editor.selectedText = nil
            end

        elseif button == 2 then

            for i = #world.walls, 1, -1 do
                local wall = world.walls[i]
                if mx2 >= wall.x and mx2 <= wall.x + wall.w and
                   my2 >= wall.y and my2 <= wall.y + wall.h then
                    pushUndo()
                    table.remove(world.walls, i)
                    if editor.selectedWall == i then
                        editor.selectedWall = nil
                    elseif editor.selectedWall and editor.selectedWall > i then
                        editor.selectedWall = editor.selectedWall - 1
                    end
                    sounds.click:stop(); sounds.click:play()
                    break
                end
            end
        end
        return
    end

    if victory and button == 1 then
        local vb = victoryButtons

        local function inVB(b) return x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h end

        if inVB(vb.continue) then
            sounds.click:stop(); sounds.click:play()
            if currentLevel < levelsModule.totalLevels then
                currentLevel = currentLevel + 1
                storyType    = "pre"; storyTime = 0
                loadLevel(currentLevel)
                state = "story"
            else
                storyType = "post"; storyTime = 0
                state = "story"
            end
            return
        end
        if inVB(vb.map) then
            sounds.click:stop(); sounds.click:play()
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0
            return
        end
        if inVB(vb.restart) then
            sounds.click:stop(); sounds.click:play()
            loadLevel(currentLevel)
            return
        end
        return
    end

    if not victory and button == 1 then
        pendingDragX = x
        pendingDragY = y
    end
end

function love.mousemoved(x, y, dx, dy)

    if state == "levelSelect" and lsDrag.active then
        local delta = y - lsDrag.lastY

        levelSelectScroll = lsDrag.startScroll - (y - lsDrag.startY)

        local now = love.timer.getTime()
        local dt2 = math.max(now - lsDrag.lastT, 0.001)
        lsDrag.velY = -delta / dt2
        lsDrag.lastY = y
        lsDrag.lastT = now
        return
    end
    if state == "editor" then

        if (editor.spaceHeld and love.mouse.isDown(1)) or love.mouse.isDown(3) then
            camX = camX - dx / camZoom
            camY = camY - dy / camZoom
            return
        end

        if editor.isDragging and editor.selectedWall and world.walls[editor.selectedWall] then
            local mx2, my2 = getMouseWorld()
            local gs  = editor.gridSize
            local sel = world.walls[editor.selectedWall]
            local nx  = math.floor((mx2 - editor.dragOffsetX) / gs + 0.5) * gs
            local ny  = math.floor((my2 - editor.dragOffsetY) / gs + 0.5) * gs
            if (nx ~= sel.x or ny ~= sel.y) and editor._pendingSnap then
                commitPendingSnap()
            end
            sel.x = nx
            sel.y = ny
        end

        if editor.isResizing and editor.selectedWall and world.walls[editor.selectedWall] then
            local mx2, my2 = getMouseWorld()
            local gs = editor.gridSize
            local sel = world.walls[editor.selectedWall]
            local sx  = math.floor(mx2 / gs + 0.5) * gs
            local sy  = math.floor(my2 / gs + 0.5) * gs
            local ax, ay = editor.resizeAnchorX, editor.resizeAnchorY
            sel.x = math.min(sx, ax)
            sel.y = math.min(sy, ay)
            sel.w = math.max(math.abs(sx - ax), gs)
            sel.h = math.max(math.abs(sy - ay), gs)
        end

        if editor.isDraggingText and editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
            local mx2, my2 = getMouseWorld()
            local gs = editor.gridSize
            local t  = world.tutorialTexts[editor.selectedText]
            t.x = math.floor((mx2 - editor.textDragOffX) / gs + 0.5) * gs
            t.y = math.floor((my2 - editor.textDragOffY) / gs + 0.5) * gs
        end
        return
    end

    if state == "game" and not victory and pendingDragX then
        local dist = math.sqrt((x - pendingDragX)^2 + (y - pendingDragY)^2)
        if dist >= DRAG_THRESHOLD then
            local wx, wy = getMouseWorld()
            player.startDrag(wx, wy)
            pendingDragX = nil
            pendingDragY = nil
        end
    end
end

function love.wheelmoved(x, y)
    if state == "levelSelect" then

        local speed = 60
        levelSelectScroll = levelSelectScroll + y * speed
        lsDrag.velY = y * speed * 8
        return
    end
    if state == "editor" then
        local mx, my = love.mouse.getPosition()
        local sw, sh = love.graphics.getDimensions()
        local oldZoom = camZoom
        camZoom = math.max(0.1, math.min(4.0, camZoom * (1 + y * 0.1)))
        local wMX = camX + (mx - sw/2) / oldZoom
        local wMY = camY + (my - sh/2) / oldZoom
        camX = wMX - (mx - sw/2) / camZoom
        camY = wMY - (my - sh/2) / camZoom
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
            local panelX, panelY, panelW, panelH, nodeRadius, _, rowH =
                levelSelectPanelGeom(sw, sh)
            local positions = levelSelectNodePositions(
                panelX, panelY, panelH, nodeRadius, 1, rowH, 0, 0,
                levelSelectScroll or 0)
            for i = 1, levelsModule.totalLevels do
                local pos = positions[i]
                if pos then
                    local dist = math.sqrt((x - pos.x)^2 + (y - pos.y)^2)
                    if dist < nodeRadius + 12 then
                        if isLevelUnlocked(i) then
                            sounds.click:stop(); sounds.click:play()
                            currentLevel = i
                            loadLevel(currentLevel)
                            storyType = "pre"; storyTime = 0
                            state = "story"
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
        editor.isDragging     = false
        editor.isResizing     = false
        editor.isDraggingText = false
        editor._pendingSnap   = nil
        if editor.isDrawing then
            local wx, wy = getMouseWorld()
            wx = math.floor(wx / editor.gridSize + 0.5) * editor.gridSize
            wy = math.floor(wy / editor.gridSize + 0.5) * editor.gridSize

            local finalX = math.min(editor.startX, wx)
            local finalY = math.min(editor.startY, wy)
            local finalW = math.abs(wx - editor.startX)
            local finalH = math.abs(wy - editor.startY)

            if finalW >= editor.gridSize and finalH >= editor.gridSize then
                pushUndo()
                local newWall = {x = finalX, y = finalY, w = finalW, h = finalH, type = editor.selectedType}
                if editor.selectedType == "door" then newWall.id = "door_" .. math.random(100, 999); newWall.open = false
                elseif editor.selectedType == "button" then newWall.target = "" end
                table.insert(world.walls, newWall)
                sounds.drop:stop(); sounds.drop:play()
            end
            editor.isDrawing = false
        end
        return
    end

    if state == "menu" or state == "options" then return end
    pendingDragX = nil
    pendingDragY = nil
    if not victory and button == 1 then local r = player.releaseDrag(); if r > 0 then shake = math.max(shake, r * 6) end end
end

function love.keypressed(key)

    if state == "levelSelect" then
        if key == "escape" then
            state = "menu"; resetMenu(); playMusic("menu")
        end
        return
    end

    if state == "story" then
        local lvl = levelsModule.get(currentLevel)
        local text = storyType == "pre" and lvl.storyPre or lvl.storyPost
        local textLen = utf8len(text or "")
        local charCount = math.floor(storyTime * 40)

        if key == "space" or key == "return" then
            if charCount < textLen then
                storyTime = textLen / 40 + 0.1
            else
                if storyType == "pre" then
                    state = "game"
                    playMusic("game")
                else
                    if currentLevel < levelsModule.totalLevels then
                        currentLevel = currentLevel + 1
                        storyType = "pre"
                        storyTime = 0
                        loadLevel(currentLevel)
                    else
                        state = "menu"; resetMenu(); playMusic("menu")
                    end
                end
            end
        elseif key == "escape" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0
        end
        return
    end

    if state == "game" and victory then
        if key == "space" or key == "return" then
            if currentLevel < levelsModule.totalLevels then
                currentLevel = currentLevel + 1
                storyType = "pre"
                storyTime = 0
                loadLevel(currentLevel)
                state = "story"
            else
                storyType = "post"
                storyTime = 0
                state = "story"
            end
        elseif key == "m" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0
        elseif key == "r" then
            loadLevel(currentLevel)
        end
        return
    end

    if key == "escape" then
        if state == "editor" and editor.editingText then
            editor.editingText = false
        elseif state == "game" then
            state = "levelSelect"; levelSelectTime = 0; levelSelectScroll = 0; lsDrag.active = false; lsDrag.velY = 0
        elseif state == "options" then
            state = prevState
        elseif state == "editor" then
            state = "menu"; camZoom = 1.0; playMusic("menu")
        else
            love.event.quit()
        end
    elseif key == "r" and state == "game" then
        loadLevel(currentLevel)
    elseif state == "game" then
        if key == "=" or key == "+" then camZoom = math.min(camZoom * 1.25, 2.5)
        elseif key == "-" then camZoom = math.max(camZoom / 1.25, 0.35)
        elseif key == "0" then camZoom = 1.0
        end
    elseif key == "e" and state == "menu" and isDevMode then
        state = "editor"
        camZoom = 0.8
    elseif key == "space" and state == "editor" then
        editor.spaceHeld = true
    elseif state == "editor" then
        local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

        local function doSave()
            local lines = {"--- LEVEL DATA ---"}
            for _, wall in ipairs(world.walls) do
                local line = string.format("{x = %d, y = %d, w = %d, h = %d, type = \"%s\"",
                    wall.x, wall.y, wall.w, wall.h, wall.type)
                if wall.id     then line = line .. string.format(", id = \"%s\", open = false", wall.id) end
                if wall.target then line = line .. string.format(", target = \"%s\"", wall.target) end
                table.insert(lines, line .. "},")
            end
            table.insert(lines, "--- END LEVEL DATA ---")
            if world.tutorialTexts and #world.tutorialTexts > 0 then
                table.insert(lines, "--- TEXT NODES ---")
                for _, t in ipairs(world.tutorialTexts) do
                    local escaped = t.text:gsub("\n", "\\n")
                    table.insert(lines, string.format("{x = %d, y = %d, text = \"%s\"},", t.x, t.y, escaped))
                end
                table.insert(lines, "--- END TEXT NODES ---")
            end
            local out = table.concat(lines, "\n")
            print("\n" .. out .. "\n")
            love.system.setClipboardText(out)
            editor.saveNotifTime = love.timer.getTime()
            sounds.click:play()
        end

        if editor.editingText and editor.selectedText then
            if key == "backspace" then
                local node = world.tutorialTexts and world.tutorialTexts[editor.selectedText]
                if node and #node.text > 0 then

                    local i = #node.text
                    while i > 1 and node.text:byte(i) >= 0x80 and node.text:byte(i) < 0xC0 do
                        i = i - 1
                    end
                    node.text = node.text:sub(1, i - 1)
                end
            elseif key == "return" then
                local node = world.tutorialTexts and world.tutorialTexts[editor.selectedText]
                if node then node.text = node.text .. "\n" end
            elseif key == "escape" then
                editor.editingText = false
            elseif ctrl and key == "s" then
                doSave()
            end
            return
        end

        if ctrl and key == "z" then
            if #editor.undoStack > 0 then
                world.walls = table.remove(editor.undoStack)
                editor.selectedWall = nil
                sounds.hover:play()
            end
        elseif (ctrl and key == "s") or key == "s" then
            doSave()
        elseif key == "t" then

            if not world.tutorialTexts then world.tutorialTexts = {} end
            local gs = editor.gridSize
            local node = {
                x    = math.floor(camX / gs + 0.5) * gs,
                y    = math.floor(camY / gs + 0.5) * gs,
                text = "New Text",
            }
            table.insert(world.tutorialTexts, node)
            editor.selectedText = #world.tutorialTexts
            editor.selectedWall = nil
            editor.editingText  = true
            sounds.hover:play()
        elseif key == "return" then

            if editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
                editor.editingText = true
            end
        elseif key == "g" then
            editor.showGrid = not editor.showGrid
        elseif key == "c" then
            pushUndo()
            world.walls = {}
            editor.selectedWall = nil
            sounds.death:play()
        elseif key == "f" then
            if #world.walls > 0 then
                local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                for _, wall in ipairs(world.walls) do
                    minX = math.min(minX, wall.x); minY = math.min(minY, wall.y)
                    maxX = math.max(maxX, wall.x + wall.w); maxY = math.max(maxY, wall.y + wall.h)
                end
                local bw, bh = love.graphics.getDimensions()
                camX = (minX + maxX) / 2; camY = (minY + maxY) / 2
                local margin = 120
                camZoom = math.min(
                    (bw - margin * 2) / math.max(maxX - minX, 1),
                    (bh - margin * 2) / math.max(maxY - minY, 1), 2.0)
                camZoom = math.max(camZoom, 0.1)
            end
        elseif key == "=" or key == "+" then
            camZoom = math.min(camZoom * 1.25, 4.0)
        elseif key == "-" then
            camZoom = math.max(camZoom / 1.25, 0.1)
        elseif key == "0" then
            camZoom = 1.0
        elseif key == "delete" or key == "backspace" then
            if editor.selectedWall and world.walls[editor.selectedWall] then
                pushUndo()
                table.remove(world.walls, editor.selectedWall)
                editor.selectedWall = nil
                sounds.click:play()
            elseif editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
                table.remove(world.tutorialTexts, editor.selectedText)
                editor.selectedText = nil
                editor.editingText  = false
                sounds.click:play()
            end
        elseif key == "tab" then
            local idx = 1
            for i, t in ipairs(editor.types) do if t == editor.selectedType then idx = i; break end end
            idx = (idx % #editor.types) + 1
            editor.selectedType = editor.types[idx]
            sounds.hover:play()
        else
            local num = tonumber(key)
            if num and num >= 1 and num <= #editor.types then
                editor.selectedType = editor.types[num]
                sounds.hover:play()
            end
        end
    end
end

function love.keyreleased(key)
    if key == "space" then editor.spaceHeld = false end
end

function love.textinput(text)
    if state == "editor" and editor.editingText and editor.selectedText then
        local node = world.tutorialTexts and world.tutorialTexts[editor.selectedText]
        if node then node.text = node.text .. text end
    end
end
