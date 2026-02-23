return {
    name = "Ricochet",
    act  = "I",
    storyPre  = "The facility is full of angles.\nMaster the bounce to advance.",
    storyPost = "Ricochet protocol confirmed.",
    startX = 100, startY = 240,
    walls = {
        {x=40,  y=140, w=20,  h=520, type="normal"},
        {x=60,  y=140, w=800, h=20,  type="normal"},
        {x=60,  y=640, w=800, h=20,  type="normal"},
        {x=840, y=160, w=20,  h=480, type="normal"},
        {x=200, y=160, w=20,  h=260, type="normal"},
        {x=340, y=340, w=20,  h=300, type="normal"},
        {x=480, y=160, w=20,  h=300, type="normal"},
        {x=620, y=320, w=20,  h=320, type="normal"},
        {x=200, y=460, w=140, h=20,  type="normal"},
        {x=480, y=500, w=140, h=20,  type="normal"},
        {x=700, y=180, w=100, h=100, type="exit"},
    },
    texts = {
        {x=100, y=320, text="BOUNCE THROUGH\nTHE MAZE"},
        {x=700, y=300, text="EXIT"},
    }
}
