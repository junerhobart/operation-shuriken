-- Level 5: "Sequence"
-- Difficulty: 5/10 | Rooms: 9 (3x3 grid, all active)
-- Objects: 2 breakable walls, 2 pallets, 2 buttons, 2 doors, 1 spike strip
--
-- Layout:
--   (0,0)S --> (1,0) -bw1-> (2,0) [K1, B1 -> G1]
--     |                        .  (blocked down)
--   (0,1)[spk] -G1-> (1,1) --> (2,1) [K2, B2 -> G2]
--     | bw2            .  (blocked down)
--   (0,2) ------> (1,2) -G2-> (2,2)E
--
-- Solution:
--   1. (0,0) right to (1,0), break bw1 right into (2,0)
--   2. Push K1 rightward onto B1 in (2,0) — G1 opens
--   3. Backtrack: (2,0) left to (1,0), left to (0,0), down to (0,1)
--   4. Go right through now-open G1 into (1,1)
--   5. Go right into (2,1), push K2 rightward onto B2 — G2 opens
--   6. Backtrack: (2,1) left to (1,1), left through G1 to (0,1)
--   7. Break bw2 down into (0,2), go right to (1,2)
--   8. Go right through G2 into (2,2) — reach exit
--
-- Reasoning moments:
--   1. Must go to (2,0) FIRST to open G1 before the center path is accessible
--   2. After opening G1, must backtrack to (0,1) to use the new passage
--   3. After opening G2, must backtrack again to reach the bottom row
--
-- Softlock check:
--   - K1 re-pushable via (1,0) → (2,0); K2 re-pushable via (1,1) → (2,1)
--   - G1/G2 stay open while pallets overlap buttons
--   - Breakable walls are along the forward-only path
--   - Spikes in (0,1) are avoidable (on left wall, player enters from above/right)

return {
    name = "Sequence",
    act  = "II",
    storyPre  = "Gates must open in order.\nPlan your route.",
    storyPost = "Sequential logic mastered.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (3x3 grid: 1040 x 920)
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=900, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1020, y=0, w=20, h=920, type="normal"},

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

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="door", id="door_2", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2)
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- K1 and B1 in room (2,0)
        {x=760, y=120, w=60, h=60, type="pallet"},
        {x=900, y=100, w=100, h=100, type="button", target="door_1"},
        -- K2 and B2 in room (2,1)
        {x=760, y=440, w=60, h=60, type="pallet"},
        {x=900, y=420, w=100, h=100, type="button", target="door_2"},

        -- spikes in (0,1) left wall
        {x=30, y=420, w=20, h=100, type="spikes", facing="right"},

        -- exit in (2,2)
        {x=820, y=740, w=80, h=80, type="exit"},
    },
}
