-- Level 2: "Wall Runner"

return {
    name = "Wall Runner",
    act  = "I",
    storyPre  = "Multiple barriers detected.\nBreak through.",
    storyPost = "Demolition confirmed.",
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
        {x=340, y=660, w=20, h=240, type="normal"},

        -- vertical divider x=680 (col 1 | col 2)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="breakable"},
        {x=680, y=830, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (row 0 | row 1)
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=100, h=80, type="normal"},
        {x=920, y=260, w=100, h=80, type="normal"},

        -- horizontal gap y=580..660 (row 1 | row 2)
        {x=20, y=580, w=320, h=80, type="normal"},
        {x=360, y=580, w=100, h=80, type="normal"},
        {x=460, y=580, w=120, h=80, type="breakable"},
        {x=580, y=580, w=100, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},

        -- room pillars
        {x=860, y=100, w=20, h=100, type="normal"},
        {x=520, y=420, w=20, h=80, type="normal"},

        -- exit
        {x=820, y=740, w=80, h=80, type="exit"},
    },
    texts = {
        {x=860, y=60, text="SMASH!"},
        {x=520, y=540, text="AIM CAREFULLY"},
    }
}
