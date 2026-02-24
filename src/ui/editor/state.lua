editor = {
    gridSize      = 20,
    showGrid      = true,
    selectedType  = "normal",
    startX        = 0, startY = 0,
    isDrawing     = false,
    types         = {"normal", "breakable", "spikes", "pallet", "button", "portal_a", "portal_b", "door", "exit"},
    selectedWall  = nil,
    undoStack     = {},
    spaceHeld     = false,
    curX          = 0, curY = 0,
    TOPBAR_H      = 44,
    LEFT_W        = 200,
    RIGHT_W       = 220,
    isDragging    = false,
    dragOffsetX   = 0, dragOffsetY = 0,
    isResizing    = false,
    resizeHandle  = nil,
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
    exit      = {0.18, 0.82, 0.42},
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
