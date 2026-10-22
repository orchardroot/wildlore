# Wave 45 session B (world graphics): handoff

## Done
- `--quality=low|medium|high` dev switch (core/dev_args.gd, core/game_state.gd), never saved.
- Before shots: docs/shots/w45b/*_before.png (city liverpool@30,16 16:30; moor dartmoor@29,12 10:00; coast
  antrim_coast@50,14 12:00; cave cairngorm_cave@13,18; interior aberdeen_home_a@5,5 20:00; all --seed=7 --weather=clear
  --quality=medium, delay 25).
- Code (Medium/High only; Low = today's look): eased time-of-day + sun yaw + soft shadows (world/sky_and_light.gd),
  ground AO/mottle/cloud shadows (art/shaders/ground.gdshader, world/zone_builder.gd UVs), water foam/sky/glitter
  (water.gdshader, shore in vertex green), foliage gusts, haze+vignette (tilt_shift.gdshader), interior lights
  (world/interior_light.gd), readable characters (art/shaders/char_sprite.gdshader, world/char_sprite.gd).
- Tests: tests/world/test_world_graphics.gd.

- After shots: docs/shots/w45b/*_after.png (medium), city_dusk_after.png (high, 18:05), city_low.png (Low = today).
- Indoors on Medium/High the glow pass is off (it lifted the dark surround to murky blue; base code does this too).
- FPS (this loaded iMac, Liverpool): base medium 79 -> 75, base high 63 -> 59; interior 186 -> 176; Low 147.

## Left
- Nothing: CI green on 61c1b9dd (2425 passed, 0 failed, validate 0 errors). Open questions in the final report.

## Gotchas
- zsh doesn't word-split "$S": pass shot args literally. Shot delay 25 under load (12 caught the title).
