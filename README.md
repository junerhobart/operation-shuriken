# Operation: Shuriken

A minimalist puzzle game built in LÖVE (Lua). You're a spinning blade — drag to aim, release to launch, bounce through rooms to reach the exit.

---

## Running it

You need [LÖVE 11.4](https://love2d.org/). Drop the project folder onto the LÖVE binary, or run:

```bash
love .
```

Pass `--dev` to enable the level designer:

```bash
love . --dev
```

---

## How it plays

Drag from the player to set your shot angle and power. Release to fire. You're trying to reach the green exit tile. Along the way you'll deal with:

- **Bouncy walls** — angles matter more as levels get longer
- **Breakable walls** — hit them fast enough and they shatter
- **Spike walls** — instant death, avoid at all costs
- **Crates (pallets)** — shove them onto pressure plates to open doors
- **Portals** — enter one, exit the other on the other side of the level

The trajectory preview shows you where you're going to land, highlights breakable walls in orange, and turns red at spikes.

---

## Controls

| Input | Action |
|---|---|
| Drag + release | Aim and shoot |
| R | Restart level |
| M | Return to mission map |
| ESC | Back / quit |
| +/- or scroll | Zoom in/out |

---

## File layout

```
main.lua              core game loop, state, love.load/update/draw/resize
conf.lua              window config, platform detection
constants.lua         physics tuning, colours
utils.lua             small math helpers
physics.lua           circle vs AABB collision
player.lua            player movement, drag input, trajectory preview
world.lua             level rendering (walls, portals, buttons, etc.)
particles.lua         particle effects system
levels.lua            all 12 level definitions

ui/
  draw.lua            scaling helpers, buttons, menus, level select,
                      story screens, settings panel
  editor.lua          level designer UI and undo stack

input/
  handlers.lua        love.keypressed, mousepressed, mousemoved, wheelmoved,
                      mousereleased, keyreleased, textinput

assets/
  fonts/              Jersey25 (pixel font)
  audio/
    music/            menu-loop, stealth-loop, action-loop
    sound-effects/    click, hover, drop, bounce, squish
  images/             sprite.png (shuriken sprite)
```

---

## Level designer

Enable with `--dev`. Press **E** from the main menu.

- **Click empty space** and drag to draw a new tile
- **Click a tile** to select it; drag it to move
- **Drag a corner handle** to resize
- **T** to place a text node; **Enter** to edit it
- **Tab / 1–9** to switch tile type
- **Ctrl+Z** to undo
- **G** to toggle the grid
- **F** to fit all tiles in view
- **Ctrl+S / S** to copy the level data to clipboard

Paste the clipboard output into `levels.lua` to save a level permanently.

---

## Level structure

Each entry in `levels.data` looks like this:

```lua
[1] = {
    name     = "First Contact",
    act      = "I",
    storyPre = "Text shown before the level.",
    storyPost = "Text shown after completing it.",
    startX   = 110, startY = 340,
    walls = {
        {x=60, y=200, w=400, h=20, type="normal"},
        {x=350, y=320, w=80, h=80, type="exit"},
        -- ...
    },
    texts = {
        {x=100, y=400, text="DRAG TO AIM\nRELEASE TO LAUNCH"},
    }
}
```

Wall types: `normal`, `breakable`, `spikes` (+ `facing` = up/down/left/right), `pallet`, `button` (+ `target`), `door` (+ `id`, `open`), `portal_a`, `portal_b`, `exit`.

---

## Physics constants

Tunable in `constants.lua`:

| Constant | What it controls |
|---|---|
| `PLAYER_LAUNCH_POWER` | How fast you fire per pixel of drag |
| `PLAYER_DAMPING` | How quickly the shuriken slows down |
| `PLAYER_BOUNCE_RETENTION` | Speed kept after each wall bounce |
| `PLAYER_MAX_PULL` | Maximum drag distance |
| `PLAYER_BREAK_THRESHOLD` | Minimum impact speed to break a wall |

---

## Platform notes

Tested on macOS. Should run on Windows, Linux, iOS, and Android with LÖVE. Mobile gets fullscreen automatically. UI scales to fit any aspect ratio — portrait phones use a narrower 3-node layout on the mission map.
