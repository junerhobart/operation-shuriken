return {
    name = "Warp Zone",
    act  = "III",
    storyPre  = "Portal network is destabilised.\nNavigate the chaos to survive.",
    storyPost = "Spatial anomaly survived.",
    startX = 100, startY = 540,
    walls = {
        {x=40,   y=120, w=20,   h=680, type="normal"},
        {x=60,   y=120, w=1040, h=20,  type="normal"},
        {x=60,   y=780, w=1040, h=20,  type="normal"},
        {x=1080, y=140, w=20,   h=640, type="normal"},
        {x=200,  y=120, w=20,   h=460, type="spikes", facing="right"},
        {x=200,  y=640, w=20,   h=140, type="normal"},
        {x=100,  y=580, w=60,   h=60,  type="portal_a"},
        {x=440,  y=180, w=60,   h=60,  type="portal_b"},
        {x=440,  y=300, w=20,   h=480, type="breakable"},
        {x=280,  y=240, w=60,   h=60,  type="portal_a"},
        {x=760,  y=500, w=60,   h=60,  type="portal_b"},
        {x=680,  y=120, w=20,   h=320, type="spikes", facing="right"},
        {x=680,  y=580, w=20,   h=200, type="normal"},
        {x=860,  y=280, w=20,   h=500, type="door",   id="door_w", open=false},
        {x=680,  y=660, w=120,  h=120, type="button", target="door_w"},
        {x=700,  y=380, w=70,   h=70,  type="pallet"},
        {x=940,  y=400, w=100,  h=100, type="exit"},
    },
    texts = {
        {x=100, y=640, text="USE PORTALS\nTO BYPASS"},
    }
}
