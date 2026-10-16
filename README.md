# Wildlore

[![CI](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml/badge.svg)](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml)

A monster-catching RPG across the UK and Ireland. You start in Macclesfield, because somebody has to, and the plan is forty towns, ten Keepers and two hundred creatures, most of which you could see on a decent walk if you got up early enough. The rest are legends, and the legends are waking up.

![Title](docs/screens/t13-title.png)

## What's in 1.2

All of it, start to finish, and then some. You leave home in Macclesfield with a hedgehog, a squirrel or an otter, and you walk (and cycle, and take the train, and catch the odd ferry) all the way round England, Wales, Scotland, Northern Ireland, Ireland and the Isle of Man, collecting ten Stones from ten Keepers while a heritage company with very good lanyards tries to buy the countryside. Then you go to Stonehenge for the Moot, find out who the Champion has been all along, and go to London to have a word with Lord Vane about his tower.

- 40 towns, from Macclesfield to Kirkwall, Penzance to Derry~Londonderry
- 200 creatures, every one with a real fact about the animal or the legend it's based on, and all ten legends: Y Ddraig Goch, the Green Man, the Morrígan, Manannán's Horse, the Cù-Sìth, Nessie, Black Shuck, the Lambton Worm, Herne the Hunter and Bran's Raven
- Ten Keepers, the Four Winds, a Champion, a rival who turns out to be the best mate you've got, and a villain who complains about his deposit
- A bike, a coracle, a lantern, a pair of waders, trains, ferries, and eventually a raven to fly you anywhere you've been
- Double battles, British weather that matters, day and night, three save slots and an Ark for the spares
- Folk-ish music and sound effects, all synthesised from scratch, and pixel art and buildings all generated from code
- A post-game: the Keepers, the Professor and your rival want rematches (once a day, they have lives), two secrets that only come out after dark or after the credits, and a diploma if you fill the Fieldbook
- About 500 buildings you can walk into: every landmark from the John Rylands Library to the Tower of London has someone inside who'll tell you something true about it, and every town has a few front doors open for a cuppa and a bit of local dialect
- Railways that go somewhere: trains actually run (into termini, through tunnels, off over the horizon) and the level crossing barriers come down for them
- A world that's actually alive: surf and gulls, birdsong, rain on the roof, footsteps that change with the ground, trains you can hear coming; weather that hangs about properly, chimney smoke, bobbing boats, lamplight pooling on the pavement, bunting, washing lines, and creatures rustling about in the long grass. Townsfolk notice the drizzle, some go home at night, and the lamplighter comes out
- Proper furniture in every room: fireplaces, rugs, a fryer in the chippy, pictures on the walls
- Kinder to your thumbs: speed up battles and text, "super effective" tags once you know a creature, plain-English move descriptions, a "Where next?" hint, the Ark from the pause menu, nicknames, a move relearner in every Sanctuary, a Lavender Sachet to keep the riff-raff away, and button prompts that match your controller
- The Team Thermos, a flask big enough for the whole team: switch it on and the ones on the bench learn from every win too
- Options for the rest of us: every key and button can be remapped, type symbols as well as colours, a colour-blind palette, instant text, and a setting to calm the flashing down

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
| Fly (after the Moot) | F | Back / Select |

All of it can be rebound under Settings, Controls. Confirm and Back can't be swapped onto the same key, because I've seen what happens.

## Playing it

Grab the Mac or Windows zip from [Releases](../../releases). The builds aren't signed, so on a Mac right-click Wildlore.app and choose Open the first time; on Windows click "More info" then "Run anyway". It runs at 60 fps on my 2013 iMac, Liverpool included, so it'll be fine on yours.

From source: install nothing, run `tools/get_godot.sh` (it fetches the pinned Godot 4.7.2), then open the project with that binary.

## How it's made

Godot 4, GDScript, the Compatibility renderer. Everything is generated: the 3D world is built from text maps by `world/zone_builder.gd`, the creature and character sprites are drawn by `tools/spritegen.gd` from JSON recipes, and the music is composed as note lists in `tools/music/`. No downloaded art or audio.

```
tools/test.sh              # over 500 unit tests plus the data validator
tools/playtest.sh slice 2  # a headless bot plays the slice and must win the Brook Stone
tools/playtest.sh m2 2     # ...or carries on to Cardiff and must win all four
tools/playtest.sh fuzz 7 600   # random walking, talking and battling, looking for soft-locks
tools/playtest.sh full 1   # the whole story, Macclesfield to the credits (about 20 minutes)
```

CI runs the tests and the bot on every push, and three fuzz runs every night. Design and plans live in `docs/superpowers/`.

## Status

Done. 1.0 is the whole game, polished, levelled and play-tested by a robot that walked from Macclesfield to London and found three places it could get stuck (it can't any more). If you find a fourth, the issues page is [here](../../issues). The board is [here](https://github.com/users/orchardroot/projects/2).

*orchardroot, made in Cheshire, under the supervision of two cats. Neither of them is in this one. Yet.*
