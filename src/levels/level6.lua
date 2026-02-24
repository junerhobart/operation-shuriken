-- Level 6: "Spike Alley"
-- Difficulty: 6/10 | Rooms: 9 (3x3 grid)
-- Objects: 1 breakable wall, 2 pallets, 2 buttons, 2 doors, 3 spike strips
--
-- Layout:
--   (0,0)S --> (1,0)[spk] -bw1-> (2,0)
--     (solid below)                 |
--   (0,1)[dead end]  (1,1) <--- (2,1) [K1, B1 -> G1]
--                      | G1
--   (0,2)[dead end]  (1,2) [K2, B2 -> G2] -G2-> (2,2)E
--
-- Solution:
--   1. (0,0) right to (1,0) — dodge spike strip
--   2. Break bw1 right into (2,0)
--   3. Go down to (2,1), push K1 onto B1 — G1 opens
--   4. Go left to (1,1), go down through G1 to (1,2)
--   5. Push K2 onto B2 in (1,2) — G2 opens
--   6. Go right through G2 into (2,2) — reach exit

return {
    name = "Spike Alley",
    act  = "II",
    storyPre  = "Security spikes deployed.\nNavigate with caution.",
    storyPost = "Hazard zone cleared.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=900, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1020, y=0, w=20, h=920, type="normal"},

        -- vertical divider x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=240, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=240, type="normal"},

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=110, type="normal"},
        {x=680, y=770, w=20, h=60, type="door", id="door_2", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660
        {x=20, y=580, w=320, h=80, type="normal"},
        {x=360, y=580, w=100, h=80, type="normal"},
        {x=460, y=580, w=120, h=80, type="door", id="door_1", open=false},
        {x=580, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- K1 and B1 in room (2,1) — push right onto button
        {x=760, y=420, w=60, h=60, type="pallet"},
        {x=900, y=400, w=100, h=100, type="button", target="door_1"},

        -- K2 and B2 in room (1,2) — centered, clear push path
        {x=400, y=770, w=60, h=60, type="pallet"},
        {x=560, y=760, w=100, h=100, type="button", target="door_2"},

        -- spikes in passage (1,0) — must dodge to reach bw1
        {x=420, y=240, w=200, h=20, type="spikes", facing="up"},

        -- spikes flanking the K2 push in (1,2)
        {x=360, y=880, w=200, h=20, type="spikes", facing="up"},

        -- exit
        {x=820, y=770, w=80, h=80, type="exit"},
    },
}
