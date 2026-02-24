function drawEditorUI()
    local w, h = love.graphics.getDimensions()
    local TH  = editor.TOPBAR_H
    local LW  = editor.LEFT_W
    local RW  = editor.RIGHT_W

    love.graphics.push()
    love.graphics.translate(w/2, h/2)
    love.graphics.scale(camZoom)
    love.graphics.translate(-math.floor(camX), -math.floor(camY))

    if editor.showGrid then
        local startX = (camX - w/2) - ((camX - w/2) % editor.gridSize)
        local startY = (camY - h/2) - ((camY - h/2) % editor.gridSize)
        local ext = math.ceil(math.max(w, h) / camZoom) + editor.gridSize * 2
        love.graphics.setLineWidth(0.5 / camZoom)
        love.graphics.setColor(1, 1, 1, 0.07)
        for gx = startX - ext, startX + ext * 2, editor.gridSize do
            love.graphics.line(gx, startY - ext, gx, startY + ext * 2)
        end
        for gy = startY - ext, startY + ext * 2, editor.gridSize do
            love.graphics.line(startX - ext, gy, startX + ext * 2, gy)
        end
    end

    if editor.isDrawing and editor.curX then
        local rx  = math.min(editor.startX, editor.curX)
        local ry  = math.min(editor.startY, editor.curY)
        local rw2 = math.abs(editor.curX - editor.startX)
        local rh2 = math.abs(editor.curY - editor.startY)
        local tc  = EDITOR_COLORS[editor.selectedType] or {1, 1, 1}
        love.graphics.setColor(tc[1], tc[2], tc[3], 0.22)
        love.graphics.rectangle("fill", rx, ry, rw2, rh2)
        love.graphics.setColor(tc[1], tc[2], tc[3], 1)
        love.graphics.setLineWidth(1.5 / camZoom)
        love.graphics.rectangle("line", rx, ry, rw2, rh2)
        if rw2 > 30 and rh2 > 20 then
            love.graphics.setFont(fonts.main)
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.print(rw2 .. " × " .. rh2, rx + 4/camZoom, ry + 4/camZoom, 0, 1/camZoom, 1/camZoom)
        end
    end

    if editor.selectedWall and world.walls[editor.selectedWall] then
        local sw = world.walls[editor.selectedWall]
        love.graphics.setColor(0.05, 0.60, 1.0, 0.18)
        love.graphics.rectangle("fill", sw.x, sw.y, sw.w, sw.h)
        love.graphics.setColor(0.05, 0.60, 1.0, 1)
        love.graphics.setLineWidth(2 / camZoom)
        love.graphics.rectangle("line", sw.x, sw.y, sw.w, sw.h)
        local hw = 5 / camZoom
        for _, cp in ipairs({{sw.x, sw.y},{sw.x+sw.w, sw.y},{sw.x, sw.y+sw.h},{sw.x+sw.w, sw.y+sw.h}}) do
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("fill", cp[1]-hw/2, cp[2]-hw/2, hw, hw)
            love.graphics.setColor(0.05, 0.60, 1.0, 1)
            love.graphics.setLineWidth(1.5 / camZoom)
            love.graphics.rectangle("line", cp[1]-hw/2, cp[2]-hw/2, hw, hw)
        end
    end

    if world.tutorialTexts then
        local r = 7 / camZoom
        for i, t in ipairs(world.tutorialTexts) do
            local isSel = (editor.selectedText == i)

            if isSel then
                love.graphics.setColor(0.05, 0.60, 1.0, 0.22)
                love.graphics.circle("fill", t.x, t.y, r * 2.4)
                love.graphics.setColor(0.05, 0.60, 1.0, 1)
                love.graphics.setLineWidth(1.8 / camZoom)
                love.graphics.circle("line", t.x, t.y, r * 2.4)
            end

            love.graphics.setColor(isSel and 0.05 or 0.92, isSel and 0.60 or 0.82, isSel and 1.0 or 0.28, 1)
            love.graphics.circle("fill", t.x, t.y, r)
            love.graphics.setColor(0, 0, 0, 0.30)
            love.graphics.setLineWidth(1.2 / camZoom)
            love.graphics.circle("line", t.x, t.y, r)

            local firstLine = (t.text:match("([^\n]+)") or t.text):sub(1, 26)
            if editor.editingText and isSel then

                if math.floor(love.timer.getTime() * 2) % 2 == 0 then
                    firstLine = firstLine .. "|"
                end
            end
            love.graphics.setFont(fonts.main)
            love.graphics.setColor(0.90, 0.90, 0.90, 0.70)
            love.graphics.print(firstLine, t.x + r + 5/camZoom, t.y - fonts.main:getHeight()/(2*camZoom), 0, 1/camZoom, 1/camZoom)
        end
    end

    love.graphics.pop()

    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", 0, 0, w, TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(0, TH, w, TH)

    love.graphics.setFont(fonts.main)

    love.graphics.setColor(0.42, 0.42, 0.44, 1)
    love.graphics.printf("DESIGNER", 0, (TH - fonts.main:getHeight())/2, w, "center")

    love.graphics.setColor(0.30, 0.30, 0.32, 1)
    love.graphics.printf(math.floor(camZoom * 100) .. "%", 0, (TH - fonts.main:getHeight())/2, w - RW - 16, "right")

    love.graphics.setColor(0.28, 0.28, 0.30, 1)
    local undoLabel = #editor.undoStack > 0 and (#editor.undoStack .. " undo" .. (#editor.undoStack ~= 1 and "s" or "")) or "no undos"
    love.graphics.printf(undoLabel, LW + 8, (TH - fonts.main:getHeight())/2, 140, "left")

    local notifAge = love.timer.getTime() - editor.saveNotifTime
    if notifAge < 2.0 then
        local a = math.min(1, (2.0 - notifAge) / 0.4)
        love.graphics.setColor(0.15, 0.85, 0.45, a)
        love.graphics.printf("Saved to clipboard!", LW + 160, (TH - fonts.main:getHeight())/2, 220, "center")
    end

    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", 0, TH, LW, h - TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(LW, TH, LW, h)

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("TILES", 0, TH + 10, LW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(8, TH + 33, LW - 8, TH + 33)

    local itemH  = 32
    local listY  = TH + 41
    for i, typeName in ipairs(editor.types) do
        local isSel = (editor.selectedType == typeName)
        local iy    = listY + (i - 1) * itemH
        if isSel then
            love.graphics.setColor(0.05, 0.60, 1.0, 0.13)
            love.graphics.rectangle("fill", 0, iy, LW, itemH)
            love.graphics.setColor(0.05, 0.60, 1.0, 1)
            love.graphics.rectangle("fill", 0, iy, 3, itemH)
        end
        local tc = EDITOR_COLORS[typeName] or {0.5, 0.5, 0.5}
        love.graphics.setColor(tc[1], tc[2], tc[3], 1)
        love.graphics.rectangle("fill", 13, iy + (itemH - 12)/2, 12, 12, 2, 2)
        love.graphics.setColor(isSel and 0.88 or 0.46, isSel and 0.88 or 0.46, isSel and 0.88 or 0.48, 1)
        love.graphics.print(typeName, 33, iy + (itemH - fonts.main:getHeight())/2)
        if i <= 9 then
            love.graphics.setColor(0.34, 0.34, 0.36, 1)
            love.graphics.printf(tostring(i), 0, iy + (itemH - fonts.main:getHeight())/2, LW - 9, "right")
        end
    end

    local txSectY = listY + #editor.types * itemH + 6
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(8, txSectY, LW - 8, txSectY)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("TEXT NODES", 0, txSectY + 7, LW, "center")

    local txItemH = 26
    local txListY = txSectY + 27
    if world.tutorialTexts then
        for i, t in ipairs(world.tutorialTexts) do
            local isSel = (editor.selectedText == i)
            local iy    = txListY + (i - 1) * txItemH
            if isSel then
                love.graphics.setColor(0.05, 0.60, 1.0, 0.13)
                love.graphics.rectangle("fill", 0, iy, LW, txItemH)
                love.graphics.setColor(0.05, 0.60, 1.0, 1)
                love.graphics.rectangle("fill", 0, iy, 3, txItemH)
            end
            love.graphics.setColor(0.92, 0.82, 0.28, 1)
            love.graphics.circle("fill", 20, iy + txItemH/2, 4)
            local preview = (t.text:match("([^\n]+)") or t.text):sub(1, 15)
            love.graphics.setColor(isSel and 0.88 or 0.44, isSel and 0.88 or 0.44, isSel and 0.88 or 0.46, 1)
            love.graphics.print(preview, 32, iy + (txItemH - fonts.main:getHeight())/2)
        end
    end

    love.graphics.setColor(0.28, 0.28, 0.30, 1)
    love.graphics.printf("T — Add text", 0, h - 48, LW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.printf("Ctrl+Z  Undo     G  Grid", 0, h - 28, LW, "center")

    local rpx = w - RW
    love.graphics.setColor(0.13, 0.13, 0.14, 1)
    love.graphics.rectangle("fill", rpx, TH, RW, h - TH)
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(rpx, TH, rpx, h)

    love.graphics.setFont(fonts.main)
    love.graphics.setColor(0.32, 0.32, 0.34, 1)
    love.graphics.printf("PROPERTIES", rpx, TH + 10, RW, "center")
    love.graphics.setColor(0.22, 0.22, 0.24, 1)
    love.graphics.line(rpx + 8, TH + 33, w - 8, TH + 33)

    local py2  = TH + 44
    local lx   = rpx + 13
    local rowH = 25
    local function propRow(label, val, ry)
        love.graphics.setColor(0.32, 0.32, 0.34, 1)
        love.graphics.print(label, lx, ry)
        love.graphics.setColor(0.78, 0.78, 0.80, 1)
        love.graphics.printf(tostring(val), rpx, ry, RW - 10, "right")
    end

    if editor.selectedText and world.tutorialTexts and world.tutorialTexts[editor.selectedText] then

        local t = world.tutorialTexts[editor.selectedText]
        propRow("X", t.x, py2)
        propRow("Y", t.y, py2 + rowH)
        love.graphics.setColor(0.22, 0.22, 0.24, 1)
        love.graphics.line(rpx + 8, py2 + rowH * 2 + 2, w - 8, py2 + rowH * 2 + 2)
        love.graphics.setColor(0.32, 0.32, 0.34, 1)
        love.graphics.print("text", lx, py2 + rowH * 2 + 10)

        local boxY = py2 + rowH * 3 + 2
        local boxH = 84
        love.graphics.setColor(0.09, 0.09, 0.10, 1)
        love.graphics.rectangle("fill", rpx + 10, boxY, RW - 20, boxH, 4, 4)
        if editor.editingText then
            love.graphics.setColor(0.05, 0.60, 1.0, 0.55)
        else
            love.graphics.setColor(0.24, 0.24, 0.26, 1)
        end
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", rpx + 10, boxY, RW - 20, boxH, 4, 4)

        local cursor = (editor.editingText and math.floor(love.timer.getTime() * 2) % 2 == 0) and "|" or ""
        love.graphics.setColor(0.80, 0.80, 0.82, 1)
        love.graphics.printf(t.text .. cursor, rpx + 14, boxY + 6, RW - 28, "left")

        love.graphics.setColor(0.34, 0.34, 0.36, 1)
        if editor.editingText then
            love.graphics.printf("Esc — stop editing", rpx, boxY + boxH + 8, RW, "center")
        else
            love.graphics.printf("Enter — edit text", rpx, boxY + boxH + 8, RW, "center")
        end

        love.graphics.setColor(0.60, 0.12, 0.12, 1)
        love.graphics.rectangle("fill", rpx + 12, h - 46, RW - 24, 28, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("DELETE  Del", rpx, h - 46 + (28 - fonts.main:getHeight())/2, RW, "center")

    elseif editor.selectedWall and world.walls[editor.selectedWall] then

        local sw = world.walls[editor.selectedWall]
        propRow("X", sw.x, py2)
        propRow("Y", sw.y, py2 + rowH)
        propRow("W", sw.w, py2 + rowH * 2)
        propRow("H", sw.h, py2 + rowH * 3)
        love.graphics.setColor(0.22, 0.22, 0.24, 1)
        love.graphics.line(rpx + 8, py2 + rowH * 4 + 2, w - 8, py2 + rowH * 4 + 2)
        propRow("type",   sw.type,   py2 + rowH * 4 + 10)
        if sw.id     then propRow("id",     sw.id,     py2 + rowH * 5 + 10) end
        if sw.target then propRow("target", sw.target, py2 + rowH * 6 + 10) end

        love.graphics.setColor(0.60, 0.12, 0.12, 1)
        love.graphics.rectangle("fill", rpx + 12, h - 46, RW - 24, 28, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("DELETE  Del", rpx, h - 46 + (28 - fonts.main:getHeight())/2, RW, "center")

    else

        love.graphics.setColor(0.26, 0.26, 0.28, 1)
        love.graphics.printf(
            "Click  —  select\nDrag  —  draw new\nDrag corner  —  resize\nDel  —  delete\n\nT  —  add text\nTab  —  next tile\n1–9  —  tile type\nF  —  fit view\nG  —  grid",
            rpx, TH + 52, RW, "center")
    end

    if editor.isDragging then
        love.graphics.setColor(0.05, 0.60, 1.0, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.05, 0.60, 1.0, 1)
        love.graphics.printf("MOVING", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    elseif editor.isResizing then
        love.graphics.setColor(0.68, 0.28, 0.92, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.68, 0.28, 0.92, 1)
        love.graphics.printf("RESIZING", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    elseif editor.editingText then
        love.graphics.setColor(0.92, 0.82, 0.28, 0.14)
        love.graphics.rectangle("fill", rpx, h - 50, RW, 22)
        love.graphics.setColor(0.92, 0.82, 0.28, 1)
        love.graphics.printf("EDITING TEXT", rpx, h - 50 + (22 - fonts.main:getHeight())/2, RW, "center")
    end

    love.graphics.setColor(0.24, 0.24, 0.26, 1)
    local txCount = (world.tutorialTexts and #world.tutorialTexts or 0)
    love.graphics.printf(#world.walls .. " walls  " .. txCount .. " texts", rpx, h - 26, RW, "center")
end
