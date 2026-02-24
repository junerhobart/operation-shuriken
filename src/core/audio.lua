sounds              = {}
music               = {}
audioUnlocked       = false
currentMusicTrack   = nil

function playMusic(track)
    currentMusicTrack = track
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
        if currentMusicTrack then
            playMusic(currentMusicTrack)
        end
    end
end

function initAudio()
    sounds.click  = love.audio.newSource("assets/audio/sound-effects/click.wav",  "static")
    sounds.hover  = love.audio.newSource("assets/audio/sound-effects/hover.wav",  "static")
    sounds.drop   = love.audio.newSource("assets/audio/sound-effects/drop.wav",   "static")
    sounds.bounce = love.audio.newSource("assets/audio/sound-effects/bounce.wav", "static")
    sounds.death  = love.audio.newSource("assets/audio/sound-effects/squish.wav", "static")

    music.menu   = love.audio.newSource("assets/audio/music/menu-loop.wav",    "stream")
    music.game   = love.audio.newSource("assets/audio/music/stealth-loop.wav", "stream")
    music.action = love.audio.newSource("assets/audio/music/action-loop.wav",  "stream")
end
