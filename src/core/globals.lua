world, player, particleSystem = nil, nil, nil

state         = "menu"
prevState     = "menu"
optionsTab    = "General"
fonts         = {}
buttons       = {}
shake         = 0
victory       = false
victoryTime   = 0
deathTime     = 0
deathPending  = false

victoryButtons = {
    continue = {x=0, y=0, w=0, h=0, hovered=false},
    map      = {x=0, y=0, w=0, h=0, hovered=false},
    restart  = {x=0, y=0, w=0, h=0, hovered=false},
}
prevButtonStates = {}

camX, camY = 0, 0
camZoom    = 1.0

menuTime        = 0
optionsTime     = 0
isDevMode       = false
_switchLock     = false

currentLevel    = 1
completedLevels = {}

lsDrag = {
    active      = false,
    startY      = 0,
    startScroll = 0,
    velY        = 0,
    lastY       = 0,
    lastT       = 0,
}
levelSelectTime   = 0
levelSelectScroll = 0
storyTime         = 0
storyType         = "pre"
levelTransition   = 0
transitionDir     = 0

activeTouches  = {}
pinchDist0     = nil
pinchZoom0     = nil
pendingDragX   = nil
pendingDragY   = nil
DRAG_THRESHOLD = 10

settings = {
    fov            = 90,
    musicVol       = 0.5,
    sfxVol         = 0.7,
    shakeIntensity = 1.0,
    dragSense      = 1.0,
    darkMode       = false,
    fullscreen     = false,
}
