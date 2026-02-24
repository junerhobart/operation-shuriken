-- Level 12: "Final Exam"
-- Difficulty: 10/10 | Rooms: 13 (4x4 grid, 13 active, unused: (0,3), (1,3), (2,3))
-- Objects: 4 breakable walls, 1 portal pair, 3 pallets, 3 buttons, 3 doors, spikes
--
-- Layout (4 cols x 4 rows):
--   (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portalA]
--     |                       |          |
--   (0,1)[spk] --> (1,1) -G1-> (2,1) --> (3,1)[K2,B2->G2]
--     | bw2                     |
--   (0,2)[portalB] --> (1,2) -bw3-> (2,2)[K3,B3->G3] --> (3,2)[spk]
--                        | G3
--                      (1,3 via G3? no, use (3,3))
--
-- Revised 13-room layout (4x4 minus 3):
--   (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portalA]
--     |                       |          |
--   (0,1)[spk] -G1-> (1,1) --> (2,1)[K1,B1->G1] --> (3,1)[K2,B2->G2]
--     | bw2                                           |
--   (0,2)[portalB] --> (1,2) -bw3-> (2,2) -G2-> (3,2)[K3,B3->G3]
--                                                  | G3
--                                               (3,3)E
--
-- Solution (non-obvious order):
--   1. (0,0) right to (1,0), break bw1 to (2,0), right to (3,0)
--   2. Portal to (0,2) [lower left]
--   3. (0,2) right to (1,2), break bw3 to (2,2): STUCK — G2 blocks path to (3,2)
--   4. Need G2 open. Portal back to (3,0)
--   5. (3,0) down to (3,1): push K2 onto B2 -> G2 opens
--   6. Portal to (0,2) -> (1,2) -> bw3 -> (2,2) -> G2 -> (3,2)
--   7. Push K3 onto B3 -> G3 opens -> but G3 leads to (3,3)E
--   8. BUT (3,3) is the exit! Go down through G3 to (3,3) -> DONE?
--   9. Wait — bw3 was already broken. But we never opened G1!
--      G1 was a red herring? No — let me revise.
--
-- REVISED: G3 blocks the exit. G3 requires K3 which is behind G1.
--
--   (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portalA]
--     |                       |          |
--   (0,1)[spk] -G1-> (1,1)[K3] (2,1)[K1,B1->G1] (3,1)[K2,B2->G2]
--     | bw2                              |
--   (0,2)[portB] (1,2) -bw3-> (2,2)[B3->G3] -G2-> (3,2)
--     |bw4                                          |G3
--   (0,3)E                                        (3,3)
--
-- Hmm, too complex. Let me simplify to a clear 13-room layout.
--
-- FINAL Layout (4x4, 13 rooms, unused: (0,3)(1,3)(2,3)):
--   (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portalA]
--     |                                  |
--   (0,1)[spk] --> (1,1) -bw2-> (2,1)[K1,B1->G1] --> (3,1)
--     |                                               |
--   (0,2)[portB] --> (1,2)[K2,B2->G2] -G1-> (2,2) --> (3,2)[K3,B3->G3,spk]
--                                                        |G3
--                                                      (3,3)E
--
-- Solution:
--   1. Explore upper: (0,0)→(1,0)→bw1→(2,0)→(3,0): find portal_a
--   2. Portal to (0,2)→(1,2): push K2 onto B2 → G2 opens (tracks to where?)
--      G2 opens passage somewhere we need. Let me assign targets carefully.
--
-- CLEAN FINAL DESIGN:
--   G1: controlled by B1 in (2,1), blocks passage (1,2)→(2,2)
--   G2: controlled by B2 in (1,2), blocks passage (2,2)→(3,2)
--   G3: controlled by B3 in (3,2), blocks passage (3,2)→(3,3) exit
--
--   Order: Must open G1 first (to reach G2 area), then G2 (to reach G3 area), then G3 (exit)
--
--   K1/B1 in (2,1): accessible via upper island route
--   K2/B2 in (1,2): accessible via portal to lower island
--   K3/B3 in (3,2): accessible only after G1 and G2 are open
--
-- Solution:
--   1. (0,0)→(1,0)→bw1→(2,0)→(3,0)→(3,1)→(2,1): push K1→B1 → G1 opens
--   2. (3,0) portal_a → (0,2) portal_b
--   3. (0,2)→(1,2): push K2→B2 → G2 opens
--   4. (1,2) → G1 → (2,2) → G2 → (3,2): push K3→B3 → G3 opens
--   5. (3,2) → G3 → (3,3) → exit

return {
    name = "Final Exam",
    act  = "III",
    storyPre  = "Full facility access.\nEverything you have learned applies.",
    storyPost = "SHURIKEN-7 extracted.\nMission complete.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (4x4 grid: 1380 x 1240)
        {x=0, y=0, w=1380, h=20, type="normal"},
        {x=0, y=1220, w=1380, h=20, type="normal"},
        {x=0, y=0, w=20, h=1240, type="normal"},
        {x=1360, y=0, w=20, h=1240, type="normal"},

        -- VW x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=830, w=20, h=70, type="normal"},
        {x=340, y=900, w=20, h=320, type="normal"},

        -- VW x=680 (bw1 row 0, bw2 row 1)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=410, w=20, h=100, type="breakable"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="door", id="door_1", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},
        {x=680, y=900, w=20, h=320, type="normal"},

        -- VW x=1020
        {x=1020, y=20, w=20, h=70, type="normal"},
        {x=1020, y=190, w=20, h=70, type="normal"},
        {x=1020, y=260, w=20, h=80, type="normal"},
        {x=1020, y=340, w=20, h=70, type="normal"},
        {x=1020, y=510, w=20, h=70, type="normal"},
        {x=1020, y=580, w=20, h=80, type="normal"},
        {x=1020, y=660, w=20, h=70, type="normal"},
        {x=1020, y=730, w=20, h=100, type="door", id="door_2", open=false},
        {x=1020, y=830, w=20, h=70, type="normal"},
        {x=1020, y=900, w=20, h=80, type="normal"},
        {x=1020, y=980, w=20, h=240, type="normal"},

        -- HG y=260..340 (row 0|1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},
        {x=1040, y=260, w=100, h=80, type="normal"},
        {x=1260, y=260, w=100, h=80, type="normal"},

        -- HG y=580..660 (row 1|2) — mostly barrier
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},
        {x=1040, y=580, w=320, h=80, type="normal"},

        -- HG y=900..980 (row 2|3) — mostly solid, G3 for col 3
        {x=20, y=900, w=1000, h=80, type="normal"},
        {x=1040, y=900, w=100, h=80, type="normal"},
        {x=1140, y=900, w=120, h=80, type="door", id="door_3", open=false},
        {x=1260, y=900, w=100, h=80, type="normal"},

        -- portal pair
        {x=1180, y=100, w=60, h=60, type="portal_a"},
        {x=140, y=740, w=60, h=60, type="portal_b"},

        -- K1 and B1 in room (2,1) — controls G1
        {x=760, y=400, w=60, h=60, type="pallet"},
        {x=880, y=420, w=100, h=100, type="button", target="door_1"},

        -- K2 and B2 in room (1,2) — controls G2
        {x=420, y=720, w=60, h=60, type="pallet"},
        {x=560, y=740, w=100, h=100, type="button", target="door_2"},

        -- K3 and B3 in room (3,2) — controls G3
        {x=1100, y=720, w=60, h=60, type="pallet"},
        {x=1240, y=740, w=100, h=100, type="button", target="door_3"},

        -- spikes
        {x=30, y=400, w=20, h=120, type="spikes", facing="right"},
        {x=1320, y=700, w=20, h=160, type="spikes", facing="left"},

        -- breakable wall bw4 between (0,1) and (0,2) already handled above

        -- room obstacles
        {x=520, y=100, w=20, h=100, type="normal"},
        {x=860, y=760, w=20, h=80, type="normal"},

        -- exit in room (3,3)
        {x=1160, y=1060, w=80, h=80, type="exit"},
    },
}
