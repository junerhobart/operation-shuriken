function love.conf(t)
    t.window.title = "Operation: Shuriken"
    t.window.width = 1024
    t.window.height = 768
    t.window.resizable = true
    t.window.highdpi = true
    t.window.msaa = 4
    t.version = "11.4"

    -- Cross-platform module config
    t.modules.physics = false
    t.modules.joystick = true
    t.modules.touch = true
    t.modules.video = false

    -- Mobile: start fullscreen so we fill the whole screen
    local os = love.system and love.system.getOS() or ""
    if os == "iOS" or os == "Android" then
        t.window.fullscreen = true
        t.window.fullscreentype = "desktop"
        t.window.width = 0
        t.window.height = 0
    end
end

--[[
    ASPECT RATIO CONSTRAINTS
    
    Minimum: 4:3  (1.333) — iPad, old monitors, Switch docked
    Maximum: 21:9 (2.333) — ultrawide monitors
    
    Reference: 16:9 (1.778) — standard HD
    
    The game uses a virtual canvas of 1024x768 (4:3) as the base.
    Content is centered with letterboxing/pillarboxing on extreme ratios.
    
    Platform notes:
    - iOS/Android: typically 16:9 to 19.5:9
    - Nintendo Switch: 16:9 (docked), ~16:9 (handheld)
    - PlayStation/Xbox: 16:9, some 21:9 support
    - Steam Deck: 16:10 (1280x800)
    - Web: any size, responsive
]]
