function editorMousePressed(x, y, button)
    local sx, sy = love.mouse.getPosition()
    local TH = editor.TOPBAR_H
    local LW = editor.LEFT_W
    local RW = editor.RIGHT_W

    if sy < TH then return end

    if sx < LW then
        if button == 1 then
            local itemH = 32; local listY = TH + 41
            for i, typeName in ipairs(editor.types) do
                local iy = listY + (i - 1) * itemH
                if sy >= iy and sy < iy + itemH then
                    editor.selectedType = typeName; sounds.hover:play(); return
                end
            end
            if world.tutorialTexts then
                local txSectY = listY + #editor.types * itemH + 6
                local txListY = txSectY + 27; local txItemH = 26
                for i = 1, #world.tutorialTexts do
                    local iy = txListY + (i - 1) * txItemH
                    if sy >= iy and sy < iy + txItemH then
                        editor.selectedText = i; editor.selectedWall = nil
                        editor.editingText  = false; sounds.hover:play(); return
                    end
                end
            end
        end
        return
    end

    local sw2 = love.graphics.getWidth()
    if sx > sw2 - RW then return end
    if editor.spaceHeld then return end

    local mx2, my2 = getMouseWorld()

    if button == 1 then
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
                    pushUndo(); editor.isResizing = true; editor.resizeHandle = handleName
                    if     handleName == "tl" then editor.resizeAnchorX = sel.x + sel.w; editor.resizeAnchorY = sel.y + sel.h
                    elseif handleName == "tr" then editor.resizeAnchorX = sel.x;         editor.resizeAnchorY = sel.y + sel.h
                    elseif handleName == "bl" then editor.resizeAnchorX = sel.x + sel.w; editor.resizeAnchorY = sel.y
                    elseif handleName == "br" then editor.resizeAnchorX = sel.x;         editor.resizeAnchorY = sel.y
                    end
                    return
                end
            end
        end

        if world.tutorialTexts then
            local txHit = 13 / camZoom
            for i, t in ipairs(world.tutorialTexts) do
                if math.abs(mx2 - t.x) < txHit and math.abs(my2 - t.y) < txHit then
                    editor.selectedText = i; editor.selectedWall = nil
                    editor.isDraggingText = true
                    editor.textDragOffX = mx2 - t.x; editor.textDragOffY = my2 - t.y
                    sounds.hover:play(); return
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
                editor._pendingSnap = takeSnapshot(); editor.isDragging = true
                local sel = world.walls[hit]
                editor.dragOffsetX = mx2 - sel.x; editor.dragOffsetY = my2 - sel.y
            else
                editor.selectedWall = hit; sounds.hover:play()
            end
        else
            local gs = editor.gridSize
            editor.startX    = math.floor(mx2 / gs + 0.5) * gs
            editor.startY    = math.floor(my2 / gs + 0.5) * gs
            editor.isDrawing = true; editor.selectedWall = nil; editor.selectedText = nil
        end

    elseif button == 2 then
        for i = #world.walls, 1, -1 do
            local wall = world.walls[i]
            if mx2 >= wall.x and mx2 <= wall.x + wall.w and
               my2 >= wall.y and my2 <= wall.y + wall.h then
                pushUndo(); table.remove(world.walls, i)
                if editor.selectedWall == i then
                    editor.selectedWall = nil
                elseif editor.selectedWall and editor.selectedWall > i then
                    editor.selectedWall = editor.selectedWall - 1
                end
                sounds.click:stop(); sounds.click:play(); break
            end
        end
    end
end

function editorMouseMoved(x, y, dx, dy)
    if (editor.spaceHeld and love.mouse.isDown(1)) or love.mouse.isDown(3) then
        camX = camX - dx / camZoom; camY = camY - dy / camZoom; return
    end

    if editor.isDragging and editor.selectedWall and world.walls[editor.selectedWall] then
        local mx2, my2 = getMouseWorld(); local gs = editor.gridSize
        local sel = world.walls[editor.selectedWall]
        local nx  = math.floor((mx2 - editor.dragOffsetX) / gs + 0.5) * gs
        local ny  = math.floor((my2 - editor.dragOffsetY) / gs + 0.5) * gs
        if (nx ~= sel.x or ny ~= sel.y) and editor._pendingSnap then commitPendingSnap() end
        sel.x = nx; sel.y = ny
    end

    if editor.isResizing and editor.selectedWall and world.walls[editor.selectedWall] then
        local mx2, my2 = getMouseWorld(); local gs = editor.gridSize
        local sel = world.walls[editor.selectedWall]
        local sx  = math.floor(mx2 / gs + 0.5) * gs
        local sy  = math.floor(my2 / gs + 0.5) * gs
        local ax, ay = editor.resizeAnchorX, editor.resizeAnchorY
        sel.x = math.min(sx, ax); sel.y = math.min(sy, ay)
        sel.w = math.max(math.abs(sx - ax), gs); sel.h = math.max(math.abs(sy - ay), gs)
    end

    if editor.isDraggingText and editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
        local mx2, my2 = getMouseWorld(); local gs = editor.gridSize
        local t = world.tutorialTexts[editor.selectedText]
        t.x = math.floor((mx2 - editor.textDragOffX) / gs + 0.5) * gs
        t.y = math.floor((my2 - editor.textDragOffY) / gs + 0.5) * gs
    end
end

function editorMouseReleased(x, y, button)
    if button ~= 1 then return end
    editor.isDragging = false; editor.isResizing = false
    editor.isDraggingText = false; editor._pendingSnap = nil
    if editor.isDrawing then
        local wx, wy = getMouseWorld()
        wx = math.floor(wx / editor.gridSize + 0.5) * editor.gridSize
        wy = math.floor(wy / editor.gridSize + 0.5) * editor.gridSize
        local finalX = math.min(editor.startX, wx); local finalY = math.min(editor.startY, wy)
        local finalW = math.abs(wx - editor.startX); local finalH = math.abs(wy - editor.startY)
        if finalW >= editor.gridSize and finalH >= editor.gridSize then
            pushUndo()
            local newWall = {x=finalX, y=finalY, w=finalW, h=finalH, type=editor.selectedType}
            if     editor.selectedType == "door"   then newWall.id = "door_" .. math.random(100,999); newWall.open = false
            elseif editor.selectedType == "button" then newWall.target = "" end
            table.insert(world.walls, newWall)
            sounds.drop:stop(); sounds.drop:play()
        end
        editor.isDrawing = false
    end
end

function editorKeyPressed(key)
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
                while i > 1 and node.text:byte(i) >= 0x80 and node.text:byte(i) < 0xC0 do i = i - 1 end
                node.text = node.text:sub(1, i - 1)
            end
        elseif key == "return" then
            local node = world.tutorialTexts and world.tutorialTexts[editor.selectedText]
            if node then node.text = node.text .. "\n" end
        elseif key == "escape" then editor.editingText = false
        elseif ctrl and key == "s" then doSave()
        end
        return
    end

    if key == "escape" then
        editor.editingText = false
    elseif ctrl and key == "z" then
        if #editor.undoStack > 0 then world.walls = table.remove(editor.undoStack); editor.selectedWall = nil; sounds.hover:play() end
    elseif (ctrl and key == "s") or key == "s" then
        doSave()
    elseif key == "t" then
        if not world.tutorialTexts then world.tutorialTexts = {} end
        local gs   = editor.gridSize
        local node = { x = math.floor(camX/gs+0.5)*gs, y = math.floor(camY/gs+0.5)*gs, text = "New Text" }
        table.insert(world.tutorialTexts, node)
        editor.selectedText = #world.tutorialTexts; editor.selectedWall = nil
        editor.editingText  = true; sounds.hover:play()
    elseif key == "return" then
        if editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
            editor.editingText = true
        end
    elseif key == "g" then editor.showGrid = not editor.showGrid
    elseif key == "c" then pushUndo(); world.walls = {}; editor.selectedWall = nil; sounds.death:play()
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
            camZoom = math.max(math.min(
                (bw - margin*2) / math.max(maxX-minX, 1),
                (bh - margin*2) / math.max(maxY-minY, 1), 2.0), 0.1)
        end
    elseif key == "=" or key == "+" then camZoom = math.min(camZoom * 1.25, 4.0)
    elseif key == "-" then camZoom = math.max(camZoom / 1.25, 0.1)
    elseif key == "0" then camZoom = 1.0
    elseif key == "delete" or key == "backspace" then
        if editor.selectedWall and world.walls[editor.selectedWall] then
            pushUndo(); table.remove(world.walls, editor.selectedWall); editor.selectedWall = nil; sounds.click:play()
        elseif editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then
            table.remove(world.tutorialTexts, editor.selectedText)
            editor.selectedText = nil; editor.editingText = false; sounds.click:play()
        end
    elseif key == "tab" then
        local idx = 1
        for i, t in ipairs(editor.types) do if t == editor.selectedType then idx = i; break end end
        editor.selectedType = editor.types[(idx % #editor.types) + 1]; sounds.hover:play()
    else
        local num = tonumber(key)
        if num and num >= 1 and num <= #editor.types then editor.selectedType = editor.types[num]; sounds.hover:play() end
    end
end

function editorTextInput(text)
    if editor.editingText and editor.selectedText then
        local node = world.tutorialTexts and world.tutorialTexts[editor.selectedText]
        if node then node.text = node.text .. text end
    end
end
