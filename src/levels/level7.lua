-- Level 7: "The Long Way Round"

return {
    name = "The Long Way Round",
    act  = "II",
    storyPre  = "Extended facility wing.\nBacktracking required.",
    storyPost = "Extended traversal complete.",
    startX = 230,
    startY = 140,
    walls = {
        -- outer boundary (3x3 wide: 1380 x 920)
        {x=0, y=0, w=1380, h=20, type="normal"},
        {x=0, y=900, w=1380, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1360, y=0, w=20, h=920, type="normal"},

        -- vertical divider x=460
        {x=460, y=20, w=20, h=70, type="normal"},
        {x=460, y=190, w=20, h=70, type="normal"},
        {x=460, y=260, w=20, h=80, type="normal"},
        {x=460, y=340, w=20, h=70, type="normal"},
        {x=460, y=410, w=20, h=100, type="door", id="door_1", open=false},
        {x=460, y=510, w=20, h=70, type="normal"},
        {x=460, y=580, w=20, h=80, type="normal"},
        {x=460, y=660, w=20, h=70, type="normal"},
        {x=460, y=830, w=20, h=70, type="normal"},

        -- vertical divider x=920
        {x=920, y=20, w=20, h=70, type="normal"},
        {x=920, y=90, w=20, h=100, type="breakable"},
        {x=920, y=190, w=20, h=70, type="normal"},
        {x=920, y=260, w=20, h=80, type="normal"},
        {x=920, y=340, w=20, h=70, type="normal"},
        {x=920, y=510, w=20, h=70, type="normal"},
        {x=920, y=580, w=20, h=80, type="normal"},
        {x=920, y=660, w=20, h=70, type="normal"},
        {x=920, y=730, w=20, h=100, type="door", id="door_2", open=false},
        {x=920, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0|1)
        {x=20, y=260, w=440, h=80, type="normal"},
        {x=480, y=260, w=440, h=80, type="normal"},
        {x=940, y=260, w=140, h=80, type="normal"},
        {x=1200, y=260, w=160, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1|2)
        {x=20, y=580, w=140, h=80, type="normal"},
        {x=160, y=580, w=120, h=80, type="breakable"},
        {x=280, y=580, w=180, h=80, type="normal"},
        {x=480, y=580, w=440, h=80, type="normal"},
        {x=940, y=580, w=420, h=80, type="normal"},

        -- K1 and B1 in room (2,1) — spacious
        {x=1040, y=420, w=60, h=60, type="pallet"},
        {x=1200, y=400, w=120, h=100, type="button", target="door_1"},

        -- K2 and B2 in room (1,2)
        {x=560, y=740, w=60, h=60, type="pallet"},
        {x=740, y=720, w=120, h=100, type="button", target="door_2"},

        -- spikes on walls (attached, single-sided)
        {x=1340, y=380, w=20, h=160, type="spikes", facing="left"},
        {x=480, y=880, w=200, h=20, type="spikes", facing="up"},

        -- room pillars for visual interest
        {x=680, y=80, w=20, h=100, type="normal"},
        {x=220, y=420, w=20, h=100, type="normal"},

        -- exit in (2,2)
        {x=1100, y=750, w=80, h=80, type="exit"},
    },
}
