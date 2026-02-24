-- Level 12: "Final Exam"

return {
    name = "Final Exam",
    act  = "III",
    storyPre  = "Full facility access.\nEverything you have learned applies.",
    storyPost = "SHURIKEN-7 extracted.\nMission complete.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (4x4 grid: 1380 x 1240)
        {x=0, y=0, w=1380, h=20, type="normal"},
        {x=0, y=1220, w=1380, h=20, type="normal"},
        {x=0, y=0, w=20, h=1240, type="normal"},
        {x=1360, y=0, w=20, h=1240, type="normal"},

        -- VW x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},
        {x=340, y=580, w=20, h=80, type="normal"},
        {x=340, y=660, w=20, h=70, type="normal"},
        {x=340, y=830, w=20, h=70, type="normal"},
        {x=340, y=900, w=20, h=320, type="normal"},

        -- VW x=680 (bw1 row 0, bw2 row 1)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=410, w=20, h=100, type="breakable"},
        {x=680, y=510, w=20, h=70, type="normal"},
        {x=680, y=580, w=20, h=80, type="normal"},
        {x=680, y=660, w=20, h=70, type="normal"},
        {x=680, y=730, w=20, h=100, type="door", id="door_1", open=false},
        {x=680, y=830, w=20, h=70, type="normal"},
        {x=680, y=900, w=20, h=320, type="normal"},

        -- VW x=1020
        {x=1020, y=20, w=20, h=70, type="normal"},
        {x=1020, y=190, w=20, h=70, type="normal"},
        {x=1020, y=260, w=20, h=80, type="normal"},
        {x=1020, y=340, w=20, h=70, type="normal"},
        {x=1020, y=510, w=20, h=70, type="normal"},
        {x=1020, y=580, w=20, h=80, type="normal"},
        {x=1020, y=660, w=20, h=70, type="normal"},
        {x=1020, y=730, w=20, h=100, type="door", id="door_2", open=false},
        {x=1020, y=830, w=20, h=70, type="normal"},
        {x=1020, y=900, w=20, h=80, type="normal"},
        {x=1020, y=980, w=20, h=240, type="normal"},

        -- HG y=260..340 (row 0|1)
        {x=20, y=260, w=110, h=80, type="normal"},
        {x=230, y=260, w=110, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},
        {x=1040, y=260, w=100, h=80, type="normal"},
        {x=1260, y=260, w=100, h=80, type="normal"},

        -- HG y=580..660 (row 1|2) — mostly barrier
        {x=20, y=580, w=110, h=80, type="normal"},
        {x=130, y=580, w=100, h=80, type="breakable"},
        {x=230, y=580, w=110, h=80, type="normal"},
        {x=360, y=580, w=320, h=80, type="normal"},
        {x=700, y=580, w=320, h=80, type="normal"},
        {x=1040, y=580, w=320, h=80, type="normal"},

        -- HG y=900..980 (row 2|3) — mostly solid, G3 for col 3
        {x=20, y=900, w=1000, h=80, type="normal"},
        {x=1040, y=900, w=100, h=80, type="normal"},
        {x=1140, y=900, w=120, h=80, type="door", id="door_3", open=false},
        {x=1260, y=900, w=100, h=80, type="normal"},

        -- portal pair
        {x=1180, y=100, w=60, h=60, type="portal_a"},
        {x=140, y=740, w=60, h=60, type="portal_b"},

        -- K1 and B1 in room (2,1) — controls G1
        {x=760, y=400, w=60, h=60, type="pallet"},
        {x=880, y=420, w=100, h=100, type="button", target="door_1"},

        -- K2 and B2 in room (1,2) — controls G2
        {x=420, y=720, w=60, h=60, type="pallet"},
        {x=560, y=740, w=100, h=100, type="button", target="door_2"},

        -- K3 and B3 in room (3,2) — controls G3
        {x=1100, y=720, w=60, h=60, type="pallet"},
        {x=1240, y=740, w=100, h=100, type="button", target="door_3"},

        -- spikes
        {x=20, y=400, w=20, h=120, type="spikes", facing="right"},
        {x=1340, y=700, w=20, h=160, type="spikes", facing="left"},

        -- breakable wall bw4 between (0,1) and (0,2) already handled above

        -- room obstacles
        {x=520, y=100, w=20, h=100, type="normal"},
        {x=860, y=760, w=20, h=80, type="normal"},

        -- exit in room (3,3)
        {x=1160, y=1060, w=80, h=80, type="exit"},
    },
}
