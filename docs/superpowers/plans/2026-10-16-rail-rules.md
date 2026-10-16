# Rail rules (2026-10-16)

Player report: "the line in Manchester randomly starts and stops". A rail line has to look like something a train could run on. These are the rules, the pieces to fix each town with, and the list of towns that break them today. Manchester (`data/zones/manchester.json`) is the worked example.

## Tiles

| char | tile | walkable | use |
|---|---|---|---|
| `!` | `rail` | no | track |
| `&` | `level_crossing` | **yes** | track a path or road crosses: planked deck, barrier posts, rails drawn through. Counts as rail for joining and for line ends. |
| `_` | `platform` | yes | now drawn raised, with white coping and a yellow safety line on any edge next to rail |

Lines are straight runs of `!`/`&`, one tile wide or two side by side (double track). T junctions and crossings are fine; **bends are not** (the renderer and the line-end check only understand straight track).

## Props

Both are point props in `props`, like `lamp_post`. They block their tile (fine on a rail tile, which blocks anyway).

| prop | what | variants |
|---|---|---|
| `buffer_stop` | red buffer beam with a lamp: the end of a terminus line | one |
| `tunnel_portal` | stone arch with a dark bore in a grassy knoll (`variant` 0, the default); sooty brick tube mouth exactly one tile wide (`variant: 1`, two side by side make a double-track tube) | 0, 1 |

```json
{"type": "buffer_stop", "x": 39, "y": 41}
{"type": "tunnel_portal", "x": 34, "y": 14}
{"type": "tunnel_portal", "x": 60, "y": 34, "variant": 1}
```

**Orientation is automatic**: leave `rot` out and the prop turns to face its track (from the rail next to it). If you must, `rot` is degrees about the vertical: 0 = the track runs off to the east of the prop (prop at the west end), 90 = track to the north (prop at the south end), 180 = track to the west (east end), 270 = track to the south (north end).

**Where to put them**: on the last rail tile of the line (preferred), or on the tile just beyond it. A tunnel's knoll reaches about one tile back and one tile to each side, so put portals where those tiles are scenery (trees `T`, rock `R`, cliff `^`, void `x`), never where the player walks.

## The rule (ZoneData.validate)

1. **Every line end runs somewhere.** A line end is a rail tile whose track stops (the next tile along the line is not rail). Each one must be either
   - on the **map edge** (the line runs off the map: carry the `!` right through the tree border to the last column/row), or
   - capped by a **`buffer_stop`** (a terminus), or
   - going into a **`tunnel_portal`**.

   The cap counts on the end tile or the tile just beyond it. Error: `rail line ends at X,Y with nowhere to go: ...`
2. A `buffer_stop` or `tunnel_portal` must be on or next to a rail tile.
3. If the zone has a `"station"` tile (a rail stop), there must be rail within 2 tiles of it (square, diagonals count). Heritage or disused halts without a `"station"` tile are left alone.
4. No NPC may stand on a level crossing (trains wait for anyone on one).
5. `mesh_gallery` and `testbed` are exempt.

Reachability still applies: rail is a wall, so a line across a town splits it unless paths cross it on `&` tiles. The validator's usual "can't reach" errors will tell you.

## Passing trains (world/rail_traffic.gd)

Every 40-90 s a three-car train runs on one of the zone's lines, chosen at random:

- **through**: between two open ends (edge or tunnel), either way; it calls at the station for 7 s if the line passes within 2 tiles of the `"station"` tile;
- **terminus**: in from an open end to the buffers, a 7 s wait, then back out.

A line with buffers at both ends, or with anything parked on the track (props on rail tiles other than the caps, like the Underground's boats), gets no trains. Trains slide out of view at the map edge and at tunnel mouths. Level crossings shut (`can_enter` says blocked) from 10 tiles before a train until it has passed; a train stops short of a crossing someone is standing on, so the player can never be run over or shut in. Dev switch for screenshots: `--train=<seconds>` sets the first train's wait.

## How to fix a town

- Line floating in the middle of town (most of them): pick the end that faces the nearest map edge and carry the `!` out through the border (over `T`, grass, whatever is there), turning any path or road tiles it crosses into `&`. Cap the other end with a `buffer_stop` (a terminus station) or carry it out too (a through station). If the edge side is built up, end it in a `tunnel_portal` against a hill, trees or rocks instead.
- Line broken into pieces by paths (Douglas, Chat Moss): the gaps are where people cross, so fill them with `&`.
- Keep the station's `"station"` tile on the platform, within 2 tiles of the line, and keep the platform `_` row between the station building and the track.
- Check the town is still fully reachable (validator) and look at it: `tools/shot.sh out.png 20 --boot=<zone>@x,y --clock=12:00 --train=1` (the train turns up roughly 10-20 s into the shot, load times vary).

### Example: Manchester Piccadilly (terminus)

Before: a 24-tile stub at row 41 with nothing at either end. After:

```
row 40  ...::::::::________________:::::::TTT     platform x 38-53 under the station canopy
row 41  ...:::::::::!!!!!!!!!!!!!!!!!!&!!!!!!     buffer_stop on 39,41; level crossing at 57,41; off the east edge
```

### Example: mesh_gallery

Station line with a `buffer_stop` (24,14) and a stone `tunnel_portal` (34,14); a north-south line from a stone portal (38,8) over a level crossing on the road (38,16) into a tube mouth (38,19, `variant: 1`). The Underground (`underground.json`) ends both double tracks in pairs of tube mouths.

## Line ends to fix (95 in 37 zones, 2026-10-16)

From `$G --headless --path . -s res://tools/validate.gd`, as `x,y` of each uncapped end:

- aberdeen: 4,43; 45,43
- aberystwyth: 15,6; 15,11; 33,35; 42,35; 51,35; 52,35
- bath: 3,36; 14,36
- belfast: 5,41; 15,41
- birmingham: 40,8; 52,8
- bushmills: 3,31; 11,31
- cairnryan: 29,6; 39,6
- cardiff: 2,26; 12,26
- chat_moss (route): 35,3; 35,23; 35,27; 35,36
- chester: 49,11; 59,11; 61,11
- cork: 37,14; 47,14
- derry: 62,11; 69,11
- douglas: 43,4; 43,11; 43,13; 43,16; 43,18; 43,23; 43,25; 3,31; 20,31; 43,35; 43,37; 43,39; 43,41; 43,46
- dublin: 35,7; 45,7
- edinburgh: 37,16; 50,16
- fort_william: 35,31; 46,31
- galway: 3,32; 13,32
- glasgow: 49,15; 60,15
- glastonbury: 3,29; 13,29
- holyhead: 35,30; 42,30
- inverness: 40,39; 61,39
- keswick: 3,37; 13,37
- kilkenny: 34,37; 42,37
- lancaster: 35,30; 45,30
- liverpool: 3,39; 24,39
- llanberis: 46,12; 55,12
- llangollen: 43,27; 56,27
- london: 47,24; 56,24
- newcastle: 6,34; 17,34
- north_york_moors (route): 3,40; 51,40; 55,40; 76,40
- nottingham: 45,44; 56,44
- penzance: 35,29; 46,29
- sheffield: 53,47; 64,47
- sligo: 5,45; 15,45
- st_davids: 36,7; 44,7
- whitby: 19,39; 26,39
- york: 15,49; 24,49
