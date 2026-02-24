-- Level 3: "Under Pressure"

return {
    name = "Under Pressure",
    act  = "I",
    storyPre  = "Pressure plates control mag-locks.\nCrates hold them down.",
    storyPost = "Access protocol understood.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=900, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1020, y=0, w=20, h=920, type="normal"},

        -- vertical divider x=340 (col 0 | col 1)
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=240, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=830, w=20, h=70, type="normal"},

        -- vertical divider x=680 (col 1 | col 2)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=410, w=20, h=100, type="door", id="door_1", open=false},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=240, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2)
        {x=20, y=580, w=320, h=80, type="normal"},
        {x=360, y=580, w=100, h=80, type="normal"},
        {x=580, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- pallet K1 in room (2,1) — left side, player pushes right toward B1
        {x=760, y=420, w=60, h=60, type="pallet"},
        -- button B1 in room (2,1) — right side
        {x=900, y=400, w=100, h=100, type="button", target="door_1"},

        -- room pillar
        {x=500, y=100, w=20, h=100, type="normal"},

        -- exit in (0,2)
        {x=100, y=740, w=80, h=80, type="exit"},
    },
    texts = {
        {x=860, y=360, text="PUSH THE BLOCK\nONTO THE BUTTON"},
        {x=700, y=460, text="OPENS THE GATE"},
        {x=120, y=840, text="EXIT"},
    }
}
