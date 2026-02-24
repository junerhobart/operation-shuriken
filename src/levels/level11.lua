-- Level 11: "Rift Walker"
-- Difficulty: 9/10 | Rooms: 11 (4x3 grid, 11 active, unused: (0,2))
-- Objects: 3 breakable walls, 1 portal pair, 2 pallets, 2 buttons, 2 doors, spikes
--
-- Layout:
--   (0,0)S -bw1-> (1,0) --> (2,0) --> (3,0)
--     |                        |         |
--   (0,1)[spk] --> (1,1) --> (2,1)[portA] (3,1)[K2,B2->G2]
--                    |G1                    |
--                  (1,2)[portB,K1,B1->G1] -bw2-> (2,2) -bw3-> (3,2)E[G2 blocks]
--
-- The portal connects the middle of the level to the lower-right area.
-- G1 in lower area blocks path to K1; G2 blocks exit.
--
-- Solution:
--   1. (0,0) break bw1 to (1,0), right to (2,0), down to (2,1)
--   2. Enter portal_a in (2,1) -> teleport to portal_b in (1,2)
--   3. Push K1 onto B1 in (1,2) -> G1 opens [between (1,1) and (1,2)]
--   4. Portal back: (1,2) portal_b -> (2,1) portal_a
--   5. Left to (1,1), right to (2,0)... no. Left to (1,1), down through G1 to (1,2)
--      Wait, player is in (2,1). Go left to (1,1), down through G1 to (1,2)?
--      Actually G1 was between (1,1) and (1,2). Now it's open.
--   5. (2,1) -> (1,1) -> G1 -> already in (1,2). But player portalled FROM (1,2).
--      Let me revise: portal back to (2,1), then navigate to (3,0) -> (3,1).
--   5. (2,1) -> (2,0) -> (3,0) -> (3,1): push K2 onto B2 -> G2 opens
--   6. Portal to (1,2) -> bw2 -> (2,2) -> bw3 -> (3,2)E through G2
--
-- REVISED Solution:
--   1. (0,0) break bw1 to (1,0), right to (2,0), right to (3,0), down to (3,1)
--   2. Push K2 onto B2 in (3,1) -> G2 opens... but exit is behind bw3 and G2.
--      Wait, need to reach (3,2) which is below (3,1) — needs G2 in gap.
--   Actually let me simplify connections. G2 blocks the very last passage.
--
-- FINAL path:
--   1. (0,0) bw1 right to (1,0), right to (2,0), down to (2,1)
--   2. Portal_a in (2,1) -> portal_b in (1,2)
--   3. Push K1 onto B1 in (1,2) -> G1 opens between (1,1) and (1,2)
--   4. Portal_b -> portal_a in (2,1), go up to (2,0), right to (3,0), down to (3,1)
--   5. Push K2 onto B2 in (3,1) -> G2 opens
--   6. Portal to (1,2) again, break bw2 right to (2,2), break bw3 right to (3,2)
--   7. G2 open -> enter (3,2) exit
--
-- Reasoning moments:
--   1. Using portal to access (1,2) before G1 is open
--   2. Solving K1/B1 puzzle while accessed via portal
--   3. Backtracking via portal to reach K2/B2 in (3,1)
--   4. Final portal trip to lower-right for exit
--
-- Softlock check:
--   - Portal always bidirectional
--   - K1 in (1,2) re-pushable from portal or (1,1) via G1
--   - K2 in (3,1) re-pushable from (3,0)
--   - bw2/bw3 are forward-only but on the exit path

return {
    name = "Rift Walker",
    act  = "III",
    storyPre  = "Multiple relay points active.\nRoute through the network.",
    storyPost = "Portal network mastered.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (4x3 grid: 1380 x 920)
        {x=0, y=0, w=1380, h=20, type="normal"},
        {x=0, y=900, w=1380, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1360, y=0, w=20, h=920, type="normal"},

        -- vertical divider x=340 (bw1 in row 0)
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=90, w=20, h=100, type="breakable"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=240, type="normal"},

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="breakable"},
        {x=680, y=830, w=20, h=70, type="normal"},

        -- vertical divider x=1020
        {x=1020, y=20, w=20, h=70, type="normal"},
        {x=1020, y=190, w=20, h=70, type="normal"},
        {x=1020, y=260, w=20, h=80, type="normal"},
        {x=1020, y=340, w=20, h=240, type="normal"},
        {x=1020, y=580, w=20, h=80, type="normal"},
        {x=1020, y=660, w=20, h=70, type="normal"},
        {x=1020, y=730, w=20, h=100, type="breakable"},
        {x=1020, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},
        {x=1040, y=260, w=100, h=80, type="normal"},
        {x=1260, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2)
        {x=20, y=580, w=320, h=80, type="normal"},
        {x=360, y=580, w=100, h=80, type="normal"},
        {x=460, y=580, w=120, h=80, type="door", id="door_1", open=false},
        {x=580, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},
        {x=1040, y=580, w=100, h=80, type="normal"},
        {x=1140, y=580, w=120, h=80, type="door", id="door_2", open=false},
        {x=1260, y=580, w=100, h=80, type="normal"},

        -- spikes in (0,1)
        {x=30, y=400, w=20, h=120, type="spikes", facing="right"},
        {x=280, y=540, w=40, h=20, type="spikes", facing="up"},

        -- portal pair
        {x=820, y=420, w=60, h=60, type="portal_a"},
        {x=480, y=740, w=60, h=60, type="portal_b"},

        -- K1 and B1 in room (1,2)
        {x=420, y=720, w=60, h=60, type="pallet"},
        {x=560, y=780, w=100, h=80, type="button", target="door_1"},

        -- K2 and B2 in room (3,1)
        {x=1100, y=400, w=60, h=60, type="pallet"},
        {x=1220, y=420, w=120, h=100, type="button", target="door_2"},

        -- room obstacle
        {x=520, y=100, w=20, h=100, type="normal"},

        -- exit in room (3,2)
        {x=1160, y=740, w=80, h=80, type="exit"},
    },
}
