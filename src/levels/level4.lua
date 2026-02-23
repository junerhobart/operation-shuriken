return {
    name = "Red Zone",
    act  = "I",
    storyPre  = "Hazard spikes line the facility walls.\nOne wrong bounce and it's over.",
    storyPost = "Threat assessment complete. Stay sharp.",
    startX = 100, startY = 320,
    walls = {
        {x=40,  y=160, w=20,  h=520, type="normal"},
        {x=60,  y=160, w=880, h=20,  type="normal"},
        {x=60,  y=660, w=880, h=20,  type="normal"},
        {x=920, y=180, w=20,  h=480, type="normal"},
        {x=240, y=180, w=20,  h=280, type="spikes", facing="right"},
        {x=240, y=520, w=20,  h=140, type="normal"},
        {x=420, y=340, w=20,  h=320, type="spikes", facing="left"},
        {x=420, y=180, w=20,  h=120, type="normal"},
        {x=600, y=180, w=20,  h=240, type="spikes", facing="right"},
        {x=600, y=480, w=20,  h=180, type="normal"},
        {x=240, y=640, w=180, h=20,  type="spikes", facing="up"},
        {x=500, y=640, w=120, h=20,  type="spikes", facing="up"},
        {x=730, y=300, w=20,  h=200, type="breakable"},
        {x=790, y=380, w=100, h=100, type="exit"},
    },
    texts = {
        {x=100, y=400, text="AVOID THE\nSPIKES"},
    }
}
