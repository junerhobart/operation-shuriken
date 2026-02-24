-- Level 4: "Double Lock"
-- Difficulty: 4/10 | Rooms: 8 (2x4 grid)
-- Objects: 2 breakable walls, 2 pallets, 2 buttons, 2 doors, 1 spike strip
--
-- Layout (2 cols x 4 rows):
--   (0,0)S -bw1-> (1,0)
--                   |
--   (0,1) <--G1-- (1,1) [K1, B1 -> G1]
--     |  spikes
--   (0,2) -bw2-> (1,2)
--                   |
--   (0,3)E <--G2-- (1,3) [K2, B2 -> G2]
--
-- Solution:
--   1. Break bw1 (right) to enter (1,0)
--   2. Go down into (1,1)
--   3. Push K1 onto B1 in (1,1) — G1 opens
--   4. Go left through G1 into (0,1) — avoid spikes on left wall
--   5. Go down into (0,2)
--   6. Break bw2 (right) to enter (1,2)
--   7. Go down into (1,3)
--   8. Push K2 onto B2 in (1,3) — G2 opens
--   9. Go left through G2 into (0,3) — reach exit
--
-- Reasoning moments:
--   1. First multi-step puzzle: break wall, then push pallet, then pass gate
--   2. Avoiding spikes in (0,1) while navigating to the passage below
--
-- Softlock check:
--   - K1 re-pushable: player can re-enter (1,1) from (1,0) above
--   - K2 re-pushable: player can re-enter (1,3) from (1,2) above
--   - Spikes kill (restart) but never softlock
--   - Doors stay open while pallets remain on buttons

return {
    name = "Double Lock",
    act  = "II",
    storyPre  = "Dual-lock system active.\nBoth gates require authorization.",
    storyPost = "Multi-gate bypass complete.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary
        {x=0, y=0, w=700, h=20, type="normal"},
        {x=0, y=1220, w=700, h=20, type="normal"},
        {x=0, y=0, w=20, h=1240, type="normal"},
        {x=680, y=0, w=20, h=1240, type="normal"},

        -- vertical divider x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=90, w=20, h=100, type="breakable"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=410, w=20, h=100, type="door", id="door_1", open=false},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=730, w=20, h=100, type="breakable"},
        {x=340, y=830, w=20, h=70, type="normal"},
        {x=340, y=900, w=20, h=80, type="normal"},
        {x=340, y=980, w=20, h=70, type="normal"},
        {x=340, y=1050, w=20, h=100, type="door", id="door_2", open=false},
        {x=340, y=1150, w=20, h=70, type="normal"},

        -- horizontal gaps
        -- y=260..340 (row 0|1): col 0 solid, col 1 passage
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=100, h=80, type="normal"},
        {x=580, y=260, w=100, h=80, type="normal"},
        -- y=580..660 (row 1|2): col 0 passage, col 1 solid
        {x=20, y=580, w=100, h=80, type="normal"},
        {x=240, y=580, w=100, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        -- y=900..980 (row 2|3): col 0 solid, col 1 passage
        {x=20, y=900, w=320, h=80, type="normal"},
        {x=360, y=900, w=100, h=80, type="normal"},
        {x=580, y=900, w=100, h=80, type="normal"},

        -- K1 and B1 in room (1,1)
        {x=540, y=400, w=60, h=60, type="pallet"},
        {x=460, y=490, w=160, h=80, type="button", target="door_1"},
        -- K2 and B2 in room (1,3)
        {x=540, y=1040, w=60, h=60, type="pallet"},
        {x=460, y=1130, w=160, h=80, type="button", target="door_2"},

        -- spikes on left wall of (0,1)
        {x=30, y=390, w=20, h=140, type="spikes", facing="right"},

        -- exit in (0,3)
        {x=120, y=1060, w=80, h=80, type="exit"},
    },
}
