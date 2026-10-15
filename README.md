# Wildlore

[![CI](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml/badge.svg)](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml)

A monster-catching RPG across the UK and Ireland. You start in Macclesfield, because somebody has to, and the plan is forty towns, ten Keepers and two hundred creatures, most of which you could see on a decent walk if you got up early enough. The rest are legends, and the legends are waking up.

![Title](docs/screens/t13-title.png)

## What's in v0.5: the whole story

All of it, start to finish. You leave home in Macclesfield with a hedgehog, a squirrel or an otter, and you walk (and cycle, and take the train, and catch the odd ferry) all the way round England, Wales, Scotland, Northern Ireland, Ireland and the Isle of Man, collecting ten Stones from ten Keepers while a heritage company with very good lanyards tries to buy the countryside. Then you go to Stonehenge for the Moot, find out who the Champion has been all along, and go to London to have a word with Lord Vane about his tower.

- 40 towns, from Macclesfield to Kirkwall, Penzance to Derry
- 200 creatures, every one with a real fact about the animal or the legend it's based on, and all ten legends: Y Ddraig Goch, the Green Man, the Morrígan, Manannán's Horse, the Cù-Sìth, Nessie, Black Shuck, the Lambton Worm, Herne the Hunter and Bran's Raven
- Ten Keepers, the Four Winds, a Champion, a rival who turns out to be the best mate you've got, and a villain who complains about his deposit
- A bike, a coracle, a lantern, a pair of waders, trains, ferries, and eventually a raven to fly you anywhere you've been
- Double battles, British weather that matters, day and night, three save slots and an Ark for the spares
- Folk-ish music and sound effects, all synthesised from scratch, and pixel art and buildings all generated from code

| | |
|---|---|
| ![The Moot](docs/screens/p6-stonehenge-2.png) | ![London](docs/screens/p6-london-1.png) |
| ![Belfast](docs/screens/p5-belfast-1.png) | ![Glastonbury Tor](docs/screens/p4-glastonbury_tor-1.png) |
| ![Liverpool](docs/screens/p3-liverpool-1.png) | ![Double battle](docs/screens/p4-doubles-target.png) |

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | Arrows or WASD | D-pad or left stick |
| Run | Shift (hold) | X / West |
| Confirm / talk | Z, Enter or Space | A / South |
| Back | X or Backspace | B / East |
| Menu | Esc or Tab | Start |
| Bike on / off | B | Y / North |

## Playing it

Grab the Mac or Windows zip from [Releases](../../releases). The builds aren't signed, so on a Mac right-click Wildlore.app and choose Open the first time; on Windows click "More info" then "Run anyway". It runs at 60 fps on my 2013 iMac, Liverpool included, so it'll be fine on yours.

From source: install nothing, run `tools/get_godot.sh` (it fetches the pinned Godot 4.7.2), then open the project with that binary.

## How it's made

Godot 4, GDScript, the Compatibility renderer. Everything is generated: the 3D world is built from text maps by `world/zone_builder.gd`, the creature and character sprites are drawn by `tools/spritegen.gd` from JSON recipes, and the music is composed as note lists in `tools/music/`. No downloaded art or audio.

```
tools/test.sh              # nearly 500 unit tests plus the data validator
tools/playtest.sh slice 2  # a headless bot plays the slice and must win the Brook Stone
tools/playtest.sh m2 2     # ...or carries on to Cardiff and must win all four
tools/playtest.sh fuzz 7 600   # random walking, talking and battling, looking for soft-locks
```

CI runs the tests and the bot on every push, and three fuzz runs every night. Design and plans live in `docs/superpowers/`.

## Status

The story is complete. What's left is polish for 1.0: post-game rematches, accessibility options, a proper listen to the music by someone with ears, and a long hard look at the balance. The board is [here](https://github.com/users/orchardroot/projects/2).

*orchardroot, made in Cheshire, under the supervision of two cats. Neither of them is in this one. Yet.*
