# Operation: Shuriken

A minimalist puzzle game. You're a spinning blade — drag to aim, release to launch, bounce through rooms to reach the exit.

**[Play in browser](https://junerhobart.github.io/operation-shuriken/) · [junehobart.com](https://junehobart.com)**

---

## Running locally

Requires [LÖVE 11.5](https://love2d.org/).

```bash
love .
```

Add `--dev` to open the level designer:

```bash
love . --dev
```

---

## Mechanics

Drag from the player to set direction and power, release to fire. Reach the green exit.

| Element | Behaviour |
|---|---|
| Bouncy walls | Reflect at the angle you hit |
| Breakable walls | Shatter if hit above a speed threshold |
| Spike walls | Instant death |
| Crates | Push onto pressure plates to open doors |
| Portals | Enter one, exit the other |

The trajectory preview tracks all of these — orange for breakable walls, red at spikes.

---

## Controls

| Input | Action |
|---|---|
| Drag + release | Aim and shoot |
| R | Restart level |
| M | Mission map |
| ESC | Back |
| Scroll / +− | Zoom |

Mobile uses tap and drag throughout; no keyboard required.

---

## Project layout

```
main.lua          game loop, state machine, love callbacks
conf.lua          window config, mobile detection
src/
  player.lua      movement, drag input, trajectory prediction
  world.lua       level rendering — walls, portals, doors, etc.
  particles.lua   particle effects
  ui/
    draw.lua      all rendering — menus, level select, HUD, settings
    editor.lua    level designer UI and undo stack
    handlers.lua  all input callbacks
  levels/
    init.lua      level registry
    level1–12.lua individual level data
  utils/
    constants.lua physics tuning, colours
    physics.lua   circle vs AABB collision
    utils.lua     math helpers
assets/
  fonts/          Jersey25
  audio/          music loops + sound effects
  images/         shuriken sprite
```

---

## Level designer

Launch with `--dev`, then press **E** from the menu.

- Drag on empty space to draw a tile
- Click a tile to select; drag to move, drag a corner to resize
- **Tab / 1–9** — switch tile type
- **T** — place a text label; **Enter** to edit
- **Ctrl+Z** — undo
- **G** — toggle grid, **F** — fit view
- **Ctrl+S** — copy level data to clipboard

Paste the output into the appropriate `src/levels/levelN.lua` file.

---

## Level format

```lua
{
    name      = "First Contact",
    act       = "I",
    storyPre  = "Text shown before the level.",
    storyPost = "Text shown after completing.",
    startX    = 110, startY = 340,
    walls = {
        { x=60,  y=200, w=400, h=20,  type="normal" },
        { x=350, y=320, w=80,  h=80,  type="exit" },
    },
    texts = {
        { x=100, y=400, text="DRAG TO AIM\nRELEASE TO LAUNCH" },
    }
}
```

Wall types: `normal` `breakable` `spikes` `pallet` `button` `door` `portal_a` `portal_b` `exit`

Spikes take a `facing` key: `up` `down` `left` `right`.
Buttons take a `target` key; doors take `id` and `open`.

---

## Physics tuning

All in `src/utils/constants.lua`:

| Constant | Controls |
|---|---|
| `PLAYER_LAUNCH_POWER` | Speed per pixel of drag |
| `PLAYER_DAMPING` | How quickly the blade slows |
| `PLAYER_BOUNCE_RETENTION` | Speed kept after a bounce |
| `PLAYER_MAX_PULL` | Max drag distance |
| `PLAYER_BREAK_THRESHOLD` | Minimum speed to break a wall |

---

## Web build

Built with [love.js](https://github.com/Davidobot/love.js). The `web-build` branch contains the deployed output served on GitHub Pages.

To rebuild locally:

```bash
zip -r game.love main.lua conf.lua src/ assets/
npx love.js -t "Operation: Shuriken" -m 67108864 -c game.love web/
```

Serve with the included `build/web/serve.py` (adds the COOP/COEP headers required for SharedArrayBuffer):

```bash
python3 build/web/serve.py 8080
```
