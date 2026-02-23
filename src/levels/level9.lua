return {
    name = "Gauntlet",
    act  = "III",
    storyPre  = "Security is maximal.\nEvery tool at your disposal — use it.",
    storyPost = "Defense grid bypassed.",
    startX = 100, startY = 460,
    walls = {
        {x=40,   y=140, w=20,  h=640, type="normal"},
        {x=60,   y=140, w=980, h=20,  type="normal"},
        {x=60,   y=760, w=980, h=20,  type="normal"},
        {x=1020, y=160, w=20,  h=600, type="normal"},
        {x=220,  y=160, w=20,  h=400, type="spikes", facing="right"},
        {x=220,  y=620, w=20,  h=140, type="normal"},
        {x=400,  y=340, w=20,  h=420, type="breakable"},
        {x=400,  y=160, w=20,  h=140, type="normal"},
        {x=580,  y=160, w=20,  h=400, type="door",   id="door_g", open=false},
        {x=580,  y=620, w=20,  h=140, type="normal"},
        {x=430,  y=560, w=120, h=120, type="button", target="door_g"},
        {x=460,  y=260, w=70,  h=70,  type="pallet"},
        {x=760,  y=300, w=20,  h=460, type="spikes", facing="left"},
        {x=760,  y=160, w=20,  h=100, type="normal"},
        {x=860,  y=460, w=100, h=100, type="exit"},
    },
    texts = {
        {x=100, y=560, text="USE EVERY\nSKILL"},
    }
}
