-- Level 10: "Angle Shot"

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
