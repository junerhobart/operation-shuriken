function love.conf(t)
    t.window.title = "Operation: Shuriken"
    t.window.width = 1024
    t.window.height = 768
    t.window.resizable = true
    t.window.highdpi = true
    t.window.msaa = 4
    t.version = "11.5"

    t.modules.physics = false
    t.modules.joystick = true
    t.modules.touch = true
    t.modules.video = false

    local os = love.system and love.system.getOS() or ""
    if os == "iOS" or os == "Android" then
        t.window.fullscreen = true
        t.window.fullscreentype = "desktop"
        t.window.width = 0
        t.window.height = 0
    end
end
