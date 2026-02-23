return {
    name = "Demolition",
    act  = "I",
    storyPre  = "Some walls are structurally weak.\nHit them hard enough and they shatter.",
    storyPost = "Demolition capability confirmed.",
    startX = 100, startY = 300,
    walls = {
        {x=40,  y=160, w=20,  h=480, type="normal"},
        {x=60,  y=160, w=820, h=20,  type="normal"},
        {x=60,  y=620, w=820, h=20,  type="normal"},
        {x=860, y=180, w=20,  h=440, type="normal"},
        {x=260, y=180, w=20,  h=340, type="breakable"},
        {x=260, y=560, w=20,  h=60,  type="normal"},
        {x=460, y=280, w=20,  h=340, type="normal"},
        {x=640, y=180, w=20,  h=280, type="breakable"},
        {x=640, y=500, w=20,  h=120, type="normal"},
        {x=720, y=340, w=100, h=100, type="exit"},
    },
    texts = {
        {x=100, y=380, text="BREAK THE\nFRAGILE WALLS"},
        {x=260, y=260, text="FRAGILE"},
        {x=640, y=260, text="FRAGILE"},
    }
}
