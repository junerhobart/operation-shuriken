return {
    name = "Heavy Lifting",
    act  = "II",
    storyPre  = "Moveable crates block the path.\nKinetic force is your tool.",
    storyPost = "Kinetic manipulation mastered.",
    startX = 100, startY = 400,
    walls = {
        {x=40,  y=180, w=20,  h=500, type="normal"},
        {x=60,  y=180, w=860, h=20,  type="normal"},
        {x=60,  y=660, w=860, h=20,  type="normal"},
        {x=900, y=200, w=20,  h=460, type="normal"},
        {x=320, y=200, w=20,  h=220, type="normal"},
        {x=320, y=480, w=20,  h=180, type="normal"},
        {x=180, y=390, w=70,  h=70,  type="pallet"},
        {x=550, y=350, w=70,  h=70,  type="pallet"},
        {x=400, y=200, w=180, h=20,  type="spikes", facing="down"},
        {x=600, y=380, w=20,  h=280, type="normal"},
        {x=720, y=420, w=100, h=100, type="exit"},
    },
    texts = {
        {x=100, y=480, text="PUSH THE\nCRATE"},
        {x=550, y=470, text="USE MOMENTUM"},
    }
}
