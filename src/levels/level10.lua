-- Level 10: "Angle Shot"
-- Difficulty: 8/10 | Rooms: 11 (4x3 grid, 11 active, unused: (3,2))
-- Objects: 2 breakable walls, 1 portal pair, 2 pallets, 2 buttons, 2 doors
--
-- Layout:
--   (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portal_a]
--     |                                  |
--   (0,1) -G1-> (1,1)[K2,B2->G2] --> (2,1) --> (3,1)
--     | bw2
--   (0,2)[portal_b] --> (1,2)[K1,B1->G1]    (2,2)E [behind G2]
--
-- Two islands: upper rows 0-1 connected; lower row 2 isolated by barrier.
-- Col 2 row 2 accessible only via G2 from (2,1).
--
-- Solution:
--   1. (0,0) right to (1,0), break bw1 to (2,0), right to (3,0)
--   2. Enter portal_a -> teleport to portal_b in (0,2)
--   3. (0,2) right to (1,2): push K1 onto B1 -> G1 opens (between (0,1) and (1,1))
--   4. Enter portal_b -> teleport back to portal_a in (3,0)
--   5. Navigate: (3,0) down to (3,1), left to (2,1), left to (1,1)
--      OR: (3,0) left to (2,0), left to (1,0), left to (0,0), down to (0,1), G1 to (1,1)
--   6. Push K2 onto B2 in (1,1) -> G2 opens (between (2,1) and (2,2))
--   7. Navigate to (2,1), down through G2 to (2,2) -> reach exit
--
-- Reasoning moments:
--   1. Portal to lower island, solve K1/B1 to unlock G1 in upper island
--   2. Portal back to upper island, use newly opened G1 to access (1,1)
--   3. Solve K2/B2 to unlock G2, then navigate to exit through G2
--
-- Softlock check:
--   - Portal always bidirectional; player can teleport freely
--   - K1 re-pushable from (0,2); K2 re-pushable from (2,1) or (0,1)
--   - G1/G2 stay open while pallets on buttons
--   - (2,2) only accessible via G2; no way to get trapped there (can go back up)

return {
    name = "Angle Shot",
    act  = "III",
    storyPre  = "Objects pass through portals intact.\nUse this.",
    storyPost = "Portal logistics mastered.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (4x3 grid: 1380 x 920)
        {x=0, y=0, w=1380, h=20, type="normal"},
        {x=0, y=900, w=1380, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1360, y=0, w=20, h=920, type="normal"},

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

        -- vertical divider x=680 (bw1 in row 0)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=240, type="normal"},

        -- vertical divider x=1020
        {x=1020, y=20, w=20, h=70, type="normal"},
        {x=1020, y=190, w=20, h=70, type="normal"},
        {x=1020, y=260, w=20, h=80, type="normal"},
        {x=1020, y=340, w=20, h=70, type="normal"},
        {x=1020, y=510, w=20, h=70, type="normal"},
        {x=1020, y=580, w=20, h=80, type="normal"},
        {x=1020, y=660, w=20, h=240, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},
        {x=1040, y=260, w=100, h=80, type="normal"},
        {x=1260, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2) — mostly solid barrier
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=100, h=80, type="normal"},
        {x=800, y=580, w=100, h=80, type="door", id="door_2", open=false},
        {x=900, y=580, w=120, h=80, type="normal"},
        {x=1040, y=580, w=320, h=80, type="normal"},

        -- portal pair
        {x=1180, y=100, w=60, h=60, type="portal_a"},
        {x=140, y=740, w=60, h=60, type="portal_b"},

        -- K1 and B1 in room (1,2) — controls G1
        {x=420, y=720, w=60, h=60, type="pallet"},
        {x=540, y=740, w=100, h=100, type="button", target="door_1"},

        -- K2 and B2 in room (1,1) — controls G2
        {x=420, y=400, w=60, h=60, type="pallet"},
        {x=540, y=420, w=100, h=100, type="button", target="door_2"},

        -- exit in room (2,2)
        {x=800, y=740, w=80, h=80, type="exit"},
    },
}
