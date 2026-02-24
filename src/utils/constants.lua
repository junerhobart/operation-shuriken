local C = {

    COLOR_BG           = {0.93, 0.92, 0.89},
    COLOR_WALL         = {0.46, 0.45, 0.43},
    COLOR_WALL_OUTLINE = {0.46, 0.45, 0.43},

    COLOR_BREAKABLE      = {0.72, 0.51, 0.22},
    COLOR_PORTAL_A       = {0.05, 0.60, 1.00},
    COLOR_PORTAL_B       = {0.95, 0.44, 0.12},
    COLOR_SPIKES         = {0.88, 0.18, 0.18},
    COLOR_PALLET         = {0.82, 0.65, 0.34},
    COLOR_BUTTON         = {0.20, 0.20, 0.25},
    COLOR_BUTTON_ACTIVE  = {0.18, 0.82, 0.46},
    COLOR_DOOR           = {0.30, 0.26, 0.26},
    COLOR_BLOOD          = {0.78, 0.20, 0.20},

    PLAYER_RADIUS           = 16,
    PLAYER_DAMPING          = 1.1,
    PLAYER_STOP_THRESHOLD   = 35,
    PLAYER_BOUNCE_RETENTION = 0.87,
    PLAYER_PULL_ENABLE_SPEED= 80,
    PLAYER_MAX_PULL         = 200,
    PLAYER_LAUNCH_POWER     = 9.5,
    PLAYER_MIN_DAMAGE_SPEED = 120,
    PLAYER_SPIN_FACTOR      = 0.2,
    PLAYER_BREAK_THRESHOLD  = 290,

    ARENA_PADDING = 20,
    WORLD_WIDTH   = 1500,
    WORLD_HEIGHT  = 920,
}

return C
