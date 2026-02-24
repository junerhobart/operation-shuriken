-- Level 7: "The Long Way Round"
-- Difficulty: 7/10 | Rooms: 10 (3x4 grid, 10 active)
-- Objects: 3 breakable walls, 2 pallets, 2 buttons, 2 doors, 2 spike strips
--
-- Layout (3 cols x 4 rows):
--   (0,0)S --> (1,0) -bw1-> (2,0)
--                              |
--   (0,1) <-G1- (1,1) <--- (2,1) [K1, B1 -> G1]
--     | bw2
--   (0,2) --> (1,2)[spk] -bw3-> (2,2) [K2, B2 -> G2]
--                                   | G2
--              (1,3)E <--------  (2,3 - not exist, use gap)
--
--   Revised: 10 rooms = rows 0-2 (9) + (1,3)
--   (2,2) connects down via G2 to... need (2,3). Let me use (1,3) as exit
--   with connection (2,2) -> (1,2) -> (1,3) via G2 at (1,2)->(1,3)
--
-- Revised layout:
--   (0,0)S --> (1,0) -bw1-> (2,0)
--                              |
--   (0,1) <-G1- (1,1) <--- (2,1) [K1, B1 -> G1]
--     | bw2
--   (0,2) --> (1,2)[spk,K2,B2->G2] -bw3-> (2,2)
--               | G2
--             (1,3)E
--
-- Solution:
--   1. (0,0) right to (1,0), break bw1 right into (2,0)
--   2. Down to (2,1), push K1 onto B1 — G1 opens
--   3. Left to (1,1), left through G1 into (0,1) [BACKTRACK]
--   4. Break bw2 down into (0,2), right to (1,2)
--   5. Push K2 onto B2 in (1,2) — G2 opens [avoid spikes]
--   6. Down through G2 into (1,3) — reach exit
--
-- Reasoning moments:
--   1. After opening G1 in (2,1), must backtrack west through (1,1) to reach (0,1)
--   2. Navigating spikes in (1,2) while pushing K2 onto B2
--   3. The path requires visiting the right side first, then looping back left
--
-- Softlock check:
--   - K1 re-pushable via (2,0) → (2,1)
--   - K2 re-pushable via (0,2) → (1,2)
--   - Breaking bw2 is one-way but only needed after G1 is already open
--   - G2 at (1,2)→(1,3) stays open while K2 on B2

return {
    name = "The Long Way Round",
    act  = "II",
    storyPre  = "Extended facility wing.\nBacktracking required.",
    storyPost = "Extended traversal complete.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (3x4 grid: 1040 x 1240)
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=1220, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=1240, type="normal"},
        {x=1020, y=0, w=20, h=1240, type="normal"},

        -- vertical divider x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=410, w=20, h=100, type="door", id="door_1", open=false},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=830, w=20, h=70, type="normal"},
        {x=340, y=900, w=20, h=80, type="normal"},
        {x=340, y=980, w=20, h=240, type="normal"},

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="breakable"},
        {x=680, y=830, w=20, h=70, type="normal"},
        {x=680, y=900, w=20, h=80, type="normal"},
        {x=680, y=980, w=20, h=240, type="normal"},

        -- horizontal gap y=260..340 (row 0|1)
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1|2)
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=100, h=80, type="normal"},
        {x=580, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- horizontal gap y=900..980 (row 2|3)
        {x=20, y=900, w=320, h=80, type="normal"},
        {x=360, y=900, w=100, h=80, type="normal"},
        {x=460, y=900, w=120, h=80, type="door", id="door_2", open=false},
        {x=580, y=900, w=100, h=80, type="normal"},
        {x=700, y=900, w=320, h=80, type="normal"},

        -- K1 and B1 in room (2,1)
        {x=760, y=400, w=60, h=60, type="pallet"},
        {x=900, y=380, w=100, h=120, type="button", target="door_1"},

        -- K2 and B2 in room (1,2)
        {x=420, y=720, w=60, h=60, type="pallet"},
        {x=560, y=720, w=100, h=100, type="button", target="door_2"},

        -- spikes
        {x=460, y=880, w=120, h=20, type="spikes", facing="up"},
        {x=920, y=360, w=20, h=160, type="spikes", facing="left"},

        -- exit in (1,3)
        {x=460, y=1060, w=80, h=80, type="exit"},
    },
}
