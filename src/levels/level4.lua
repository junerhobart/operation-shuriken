-- Level 4: "Double Lock"

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
        {x=20, y=390, w=20, h=140, type="spikes", facing="right"},

        -- exit in (0,3)
        {x=120, y=1060, w=80, h=80, type="exit"},
    },
}
