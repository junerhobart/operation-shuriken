return {
    name = "Wormhole",
    act  = "II",
    storyPre  = "Experimental portals detected.\nEnter one, exit the other.",
    storyPost = "Quantum transit successful.",
    startX = 100, startY = 380,
    walls = {
        {x=40,  y=140, w=20,  h=560, type="normal"},
        {x=60,  y=140, w=900, h=20,  type="normal"},
        {x=60,  y=680, w=900, h=20,  type="normal"},
        {x=940, y=160, w=20,  h=520, type="normal"},
        {x=240, y=160, w=20,  h=360, type="normal"},
        {x=240, y=580, w=20,  h=100, type="normal"},
        {x=440, y=320, w=20,  h=360, type="normal"},
        {x=640, y=160, w=20,  h=300, type="normal"},
        {x=640, y=520, w=20,  h=160, type="normal"},
        {x=60,  y=580, w=180, h=20,  type="spikes", facing="up"},
        {x=440, y=160, w=200, h=20,  type="spikes", facing="down"},
        {x=140, y=440, w=70,  h=70,  type="portal_a"},
        {x=660, y=220, w=70,  h=70,  type="portal_b"},
        {x=780, y=460, w=100, h=100, type="exit"},
    },
    texts = {
        {x=140, y=380, text="USE\nPORTAL"},
        {x=660, y=320, text="EXIT\nTHROUGH"},
    }
}
