-- Level 5: "Sequence"

return {
    name = "Sequence",
    act  = "II",
    storyPre  = "Gates must open in order.\nPlan your route.",
    storyPost = "Sequential logic mastered.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (3x3 grid: 1040 x 920)
        {x=0, y=0, w=1040, h=20, type="normal"},
        {x=0, y=900, w=1040, h=20, type="normal"},
        {x=0, y=0, w=20, h=920, type="normal"},
        {x=1020, y=0, w=20, h=920, type="normal"},

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

        -- vertical divider x=680
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="door", id="door_2", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2)
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- K1 and B1 in room (2,0)
        {x=760, y=120, w=60, h=60, type="pallet"},
        {x=900, y=100, w=100, h=100, type="button", target="door_1"},
        -- K2 and B2 in room (2,1)
        {x=760, y=440, w=60, h=60, type="pallet"},
        {x=900, y=420, w=100, h=100, type="button", target="door_2"},

        -- spikes in (0,1) left wall
        {x=20, y=420, w=20, h=100, type="spikes", facing="right"},

        -- exit in (2,2)
        {x=820, y=740, w=80, h=80, type="exit"},
    },
}
