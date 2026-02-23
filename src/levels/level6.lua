return {
    name = "Under Pressure",
    act  = "II",
    storyPre  = "Pressure plates release mag-locks.\nGet the crate on the button.",
    storyPost = "Access protocols understood.",
    startX = 100, startY = 360,
    walls = {
        {x=40,  y=160, w=20,  h=540, type="normal"},
        {x=60,  y=160, w=900, h=20,  type="normal"},
        {x=60,  y=680, w=900, h=20,  type="normal"},
        {x=940, y=180, w=20,  h=500, type="normal"},
        {x=300, y=180, w=20,  h=340, type="door",   id="door_a", open=false},
        {x=300, y=560, w=20,  h=120, type="normal"},
        {x=160, y=500, w=120, h=120, type="button", target="door_a"},
        {x=200, y=280, w=70,  h=70,  type="pallet"},
        {x=300, y=640, w=160, h=20,  type="spikes", facing="up"},
        {x=580, y=300, w=20,  h=380, type="door",   id="door_b", open=false},
        {x=430, y=480, w=120, h=120, type="button", target="door_b"},
        {x=370, y=240, w=70,  h=70,  type="pallet"},
        {x=760, y=380, w=100, h=100, type="exit"},
    },
    texts = {
        {x=160, y=380, text="PUSH CRATE\nONTO BUTTON"},
        {x=700, y=500, text="EXTRACT"},
    }
}
