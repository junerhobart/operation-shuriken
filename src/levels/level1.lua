return {
    name = "First Contact",
    act  = "I",
    storyPre  = "SHURIKEN-7 deployed.\nObjective: Reach extraction point.\nDrag to aim. Release to launch.",
    storyPost = "Systems nominal. Proceeding deeper.",
    startX = 110, startY = 340,
    walls = {
        {x=40,  y=200, w=20,  h=400, type="normal"},
        {x=60,  y=200, w=700, h=20,  type="normal"},
        {x=60,  y=580, w=700, h=20,  type="normal"},
        {x=740, y=220, w=20,  h=360, type="normal"},
        {x=280, y=260, w=20,  h=180, type="normal"},
        {x=280, y=500, w=20,  h=80,  type="normal"},
        {x=480, y=220, w=20,  h=200, type="normal"},
        {x=480, y=480, w=20,  h=100, type="normal"},
        {x=610, y=360, w=100, h=100, type="exit"},
    },
    texts = {
        {x=110, y=430, text="DRAG TO AIM\nRELEASE TO LAUNCH"},
        {x=610, y=480, text="EXIT"},
    }
}
