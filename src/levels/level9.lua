-- Level 9: "Through the Glass"
-- Difficulty: 7/10 | Rooms: 10 (5x2 grid)
-- Objects: 2 breakable walls, 1 portal pair, 1 pallet, 1 button, 1 door
--
-- Layout (two isolated islands connected only by portal):
--   UPPER: (0,0)S --> (1,0) -bw1-> (2,0) --> (3,0)[portal_a] -G1-> (4,0)E
--   ===== solid barrier — no physical passages between rows =====
--   LOWER: (0,1)[portal_b] --> (1,1) -bw2-> (2,1) --> (3,1) --> (4,1)[K1,B1->G1]
--
-- Solution:
--   1. (0,0) right to (1,0), break bw1, continue right to (2,0), right to (3,0)
--   2. Enter portal_a in (3,0) — teleport to portal_b in (0,1)
--   3. Navigate lower island: (0,1) right to (1,1), break bw2, right to (2,1)-(3,1)-(4,1)
--   4. Push K1 onto B1 in (4,1) — G1 opens (in upper island between (3,0) and (4,0))
--   5. Navigate back to portal_b in (0,1) — teleport to portal_a in (3,0)
--   6. Go right through now-open G1 into (4,0) — reach exit
--
-- Reasoning moments:
--   1. Discovering the portal as the only bridge between the two islands
--   2. Realizing the button in the lower island controls a gate in the upper island
--   3. Must teleport TWICE: once to reach the lower island, once to return
--
-- Softlock check:
--   - Portal is always bidirectional; player can always return to either island
--   - K1 re-pushable; player can re-enter (4,1) from (3,1)
--   - G1 stays open while K1 on B1
--   - Breakable walls are forward-only along the path

return {
    name = "Through the Glass",
    act  = "III",
    storyPre  = "Spatial relays online.\nA enters B. B enters A.",
    storyPost = "Portal traversal confirmed.",
    startX = 180,
    startY = 140,
    walls = {
        -- outer boundary (5x2 grid: 1720 x 600)
        {x=0, y=0, w=1720, h=20, type="normal"},
        {x=0, y=580, w=1720, h=20, type="normal"},
        {x=0, y=0, w=20, h=600, type="normal"},
        {x=1700, y=0, w=20, h=600, type="normal"},

        -- vertical divider x=340
        {x=340, y=20, w=20, h=70, type="normal"},
        {x=340, y=190, w=20, h=70, type="normal"},
        {x=340, y=260, w=20, h=80, type="normal"},
        {x=340, y=340, w=20, h=70, type="normal"},
        {x=340, y=510, w=20, h=70, type="normal"},

        -- vertical divider x=680 (bw1 in row 0, bw2 in row 1)
        {x=680, y=20, w=20, h=70, type="normal"},
        {x=680, y=90, w=20, h=100, type="breakable"},
        {x=680, y=190, w=20, h=70, type="normal"},
        {x=680, y=260, w=20, h=80, type="normal"},
        {x=680, y=340, w=20, h=70, type="normal"},
        {x=680, y=410, w=20, h=100, type="breakable"},
        {x=680, y=510, w=20, h=70, type="normal"},

        -- vertical divider x=1020
        {x=1020, y=20, w=20, h=70, type="normal"},
        {x=1020, y=190, w=20, h=70, type="normal"},
        {x=1020, y=260, w=20, h=80, type="normal"},
        {x=1020, y=340, w=20, h=70, type="normal"},
        {x=1020, y=510, w=20, h=70, type="normal"},

        -- vertical divider x=1360 (G1 door in row 0, open in row 1)
        {x=1360, y=20, w=20, h=70, type="normal"},
        {x=1360, y=90, w=20, h=100, type="door", id="door_1", open=false},
        {x=1360, y=190, w=20, h=70, type="normal"},
        {x=1360, y=260, w=20, h=80, type="normal"},
        {x=1360, y=340, w=20, h=70, type="normal"},
        {x=1360, y=510, w=20, h=70, type="normal"},

        -- horizontal gap y=260..340 (solid barrier between islands)
        {x=20, y=260, w=320, h=80, type="normal"},
        {x=360, y=260, w=320, h=80, type="normal"},
        {x=700, y=260, w=320, h=80, type="normal"},
        {x=1040, y=260, w=320, h=80, type="normal"},
        {x=1380, y=260, w=320, h=80, type="normal"},

        -- portal pair
        {x=1180, y=100, w=60, h=60, type="portal_a"},
        {x=140, y=400, w=60, h=60, type="portal_b"},

        -- K1 and B1 in room (4,1)
        {x=1500, y=400, w=60, h=60, type="pallet"},
        {x=1580, y=460, w=100, h=80, type="button", target="door_1"},

        -- exit in room (4,0)
        {x=1520, y=100, w=80, h=80, type="exit"},
    },
    texts = {
        {x=1200, y=60, text="ENTER THE PORTAL"},
        {x=180, y=500, text="YOU TELEPORTED\nTO A NEW AREA"},
    }
}
