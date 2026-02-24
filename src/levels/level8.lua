-- Level 8: "Checkmate"

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
        {x=1000, y=40, w=20, h=180, type="spikes", facing="left"},
        {x=20, y=700, w=20, h=160, type="spikes", facing="right"},

        -- room obstacles
        {x=520, y=400, w=20, h=120, type="normal"},

        -- exit in (1,3)
        {x=460, y=1060, w=80, h=80, type="exit"},
    },
}
