-- Level 1: "First Launch"
-- Difficulty: 1/10 | Rooms: 6 (3x2 serpentine)
-- Objects: 1 breakable wall
--
-- Layout (grid 3x2):
--   (0,0)S --> (1,0) --> (2,0)
--                         | breakable
--   (0,1)E <-- (1,1) <-- (2,1)
--
-- Solution:
--   1. Launch right from spawn through passage into room (1,0)
--   2. Navigate past pillar, launch right through passage into (2,0)
--   3. Aim downward at breakable wall (brown) with full power, break through into (2,1)
--   4. Launch left through passage into (1,1)
--   5. Navigate past pillar, launch left through passage into (0,1)
--   6. Reach exit
--
-- Reasoning moments:
--   1. Identifying the breakable wall and aiming with enough speed to smash it
--   2. Navigating the U-turn path through correct passages
--
-- Softlock check:
--   - No doors, buttons, pallets, or portals; no state to get stuck in
--   - Breakable wall only needs to be broken once; all rooms remain accessible
--   - All passages are bidirectional

return {
    name = "First Launch",
    act  = "I",
    storyPre  = "SHURIKEN-7 online.\nDrag to aim. Release to launch.",
    storyPost = "Systems nominal.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=580, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=600, type="normal"},
        {x=1020, y=0, w=20, h=600, type="normal"},

        -- vertical divider x=340 (col 0 | col 1)
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},

        -- vertical divider x=680 (col 1 | col 2)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=800, y=260, w=120, h=80, type="breakable"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- room pillars
        {x=500, y=80, w=20, h=120, type="normal"},
        {x=500, y=400, w=20, h=100, type="normal"},

        -- exit
        {x=140, y=420, w=80, h=80, type="exit"},
    },
    texts = {
        {x=180, y=80, text="DRAG TO AIM\nRELEASE TO LAUNCH"},
        {x=860, y=200, text="BREAK THROUGH\nBROWN WALLS"},
        {x=160, y=530, text="REACH THE EXIT"},
    }
}
