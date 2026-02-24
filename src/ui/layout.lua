UI_BASE_W    = 1024
UI_BASE_H    = 768
UI_MAX_ASPECT = 21/9

function isPortraitScreen()
    local w, h = love.graphics.getDimensions()
    return h > w
end

function getUIScale()
    local w, h   = love.graphics.getDimensions()
    local portrait = h > w
    local s
    if portrait then
        s = w / UI_BASE_W
    else
        s = math.min(w / UI_BASE_W, h / UI_BASE_H)
    end
    return math.max(0.38, math.min(s, 2.2))
end

function getUIViewport()
    local w, h  = love.graphics.getDimensions()
    local aspect = w / h
    local vw, vh = w, h
    local ox, oy = 0, 0
    if aspect > UI_MAX_ASPECT then
        vw = h * UI_MAX_ASPECT
        ox = (w - vw) / 2
    end
    return ox, oy, vw, vh
end

function getUIScaleCentered()
    local ox, oy, vw, vh = getUIViewport()
    local scale = math.min(vw / UI_BASE_W, vh / UI_BASE_H)
    return scale, ox, oy, vw, vh
end

function drawLetterbox()
    local w, h   = love.graphics.getDimensions()
    local aspect = w / h
    if aspect > UI_MAX_ASPECT then
        local vw   = h * UI_MAX_ASPECT
        local barW = (w - vw) / 2
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0,       0, barW, h)
        love.graphics.rectangle("fill", w - barW, 0, barW, h)
    end
end

function easeOutBounce(t)
    if     t < 1/2.75   then return 7.5625 * t * t
    elseif t < 2/2.75   then t = t - 1.5/2.75;   return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then t = t - 2.25/2.75;  return 7.5625 * t * t + 0.9375
    else                      t = t - 2.625/2.75; return 7.5625 * t * t + 0.984375
    end
end

function easeInQuad(t) return t * t end

function pointInRect(px, py, btn)
    local x, y, w, h = btn.x, btn.y, btn.w, btn.h
    local s  = btn.scale
    local cx = x + w/2; local cy = y + h/2
    local sw = w * s;   local sh = h * s
    local sx = cx - sw/2; local sy = cy - sh/2
    return px >= sx and px <= sx + sw and py >= sy and py <= sy + sh
end
