-- Level 8: "Checkmate"
-- Difficulty: 8/10 | Rooms: 10 (3x4 grid, 10 active)
-- Objects: 4 breakable walls, 2 pallets, 2 buttons, 2 doors, 2 spike strips
--
-- Layout (3 cols x 4 rows, unused: (0,3) and (2,3)):
--   (0,0)S -bw1-> (1,0) --> (2,0)[spk]
--     |                        |
--   (0,1) -bw2-> (1,1)[K1,B1->G1] (2,1)
--     |                        |
--   (0,2)[spk] <-bw3- (1,2) <-G1- (2,2)[K2,B2->G2]
--                        | G2
--                      (1,3)E
--
-- The twist: G1 blocks passage from (2,2) to (1,2). The player must:
--   reach (2,2) via a long route, push K2 first, then loop back.
--
-- Solution:
--   1. Break bw1 right into (1,0), right to (2,0) [spikes on wall]
--   2. Down to (2,1), down to (2,2), push K2 onto B2 — G2 opens (at (1,2)→(1,3))
--   3. Go left: break bw4... wait, (2,2) to (1,2) blocked by G1.
--      Need to open G1 first! Wrong order!
--
-- CORRECT order (the non-obvious part):
--   1. (0,0) break bw1 right to (1,0), right to (2,0)
--   2. Down to (2,1), left to (1,1) — but (1,1) not reachable from (2,1) unless passage exists
--
-- Revised layout with clearer routing:
--   (0,0)S --> (1,0) -bw1-> (2,0)[spk]
--     | bw2                    |
--   (0,1) --> (1,1) -------> (2,1)[K1,B1->G1]
--     |                        |
--   (0,2)[spk] -bw3-> (1,2) <-G1- (2,2)[K2,B2->G2]
--                        | G2
--                      (1,3)E
--
-- Solution:
--   1. (0,0) right to (1,0), break bw1 into (2,0), down to (2,1)
--   2. Push K1 onto B1 in (2,1) — G1 opens between (2,2) and (1,2)
--   3. Backtrack: (2,1) up to (2,0), left to (1,0), left to (0,0)
--   4. Break bw2 down into (0,1), right to (1,1), right to (2,1)
--      Wait, already visited (2,1). Let me rethink.
--
--   Simplified: the key puzzle is reaching (2,2) and (1,2) in the right order.
--   3. From (2,1), down to (2,2), push K2 onto B2 — G2 opens
--   4. (2,2) left through G1 (now open) to (1,2)
--   5. (1,2) down through G2 to (1,3) — exit
--
-- Reasoning moments:
--   1. Must open G1 BEFORE trying to go from (2,2) to (1,2)
--   2. Must push K1 first (in 2,1), then K2 (in 2,2), then backtrack through G1
--   3. Spikes in (2,0) and (0,2) punish sloppy movement
--
-- Softlock check:
--   - K1 re-pushable via (1,1) → (2,1) or (2,0) → (2,1)
--   - K2 re-pushable via (2,1) → (2,2)
--   - G1 stays open while K1 on B1; player in (2,2) can go left through G1
--   - G2 stays open while K2 on B2

return {
    name = "Checkmate",
    act  = "II",
    storyPre  = "Two routes. One wrong order.\nThink before you move.",
    storyPost = "Tactical routing complete.",
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
        {x=340, y=90, w=20, h=100, type="breakable"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=730, w=20, h=100, type="breakable"},
        {x=340, y=830, w=20, h=70, type="normal"},
        {x=340, y=900, w=20, h=80, type="normal"},
        {x=340, y=980, w=20, h=240, type="normal"},

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="door", id="door_1", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},
        {x=680, y=900, w=20, h=80, type="normal"},
        {x=680, y=980, w=20, h=240, type="normal"},

        -- horizontal gap y=260..340 (row 0|1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=130, y=260, w=100, h=80, type="breakable"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=100, h=80, type="normal"},
        {x=580, y=260, w=100, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1|2)
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=100, h=80, type="normal"},
        {x=920, y=580, w=100, h=80, type="normal"},

        -- horizontal gap y=900..980 (row 2|3)
        {x=20, y=900, w=320, h=80, type="normal"},
        {x=360, y=900, w=100, h=80, type="normal"},
        {x=460, y=900, w=120, h=80, type="door", id="door_2", open=false},
        {x=580, y=900, w=100, h=80, type="normal"},
        {x=700, y=900, w=320, h=80, type="normal"},

        -- K1 and B1 in room (2,1)
        {x=800, y=400, w=60, h=60, type="pallet"},
        {x=880, y=480, w=120, h=80, type="button", target="door_1"},

        -- K2 and B2 in room (2,2)
        {x=800, y=720, w=60, h=60, type="pallet"},
        {x=880, y=800, w=120, h=80, type="button", target="door_2"},

        -- spikes
        {x=980, y=40, w=20, h=180, type="spikes", facing="left"},
        {x=30, y=700, w=20, h=160, type="spikes", facing="right"},

        -- room obstacles
        {x=520, y=400, w=20, h=120, type="normal"},

        -- exit in (1,3)
        {x=460, y=1060, w=80, h=80, type="exit"},
    },
}
