# Continual polish (QoL and immersion) while the owner plays

Owner, 2026-10-16: "think about continual improvements which can be made here while I play through it. Quality of life and immersion are the key things."

Loop: audit, build in waves of parallel agents (each owning separate files), merge into `polish-1.x`, test, release a small version, install when the game is closed. Anything the owner reports jumps the queue. No balance changes unless something needs absurd grinding; never break saves; keep 60 fps on the 2013 iMac; cap concurrent Godot jobs (seed worktree `.godot` caches).

## Wave 1 (v1.2), in progress
- qol-battle: battle speed + hold to speed text, effectiveness tags, caught icon, catch-chance hint, cursor memory, move descriptions
- qol-world: hold/B to advance dialogue, run toggle, Fly key, bike remembered, Saved toast + autosave after catches, water encounter rate 5%
- qol-menus: Ark from pause, bag stays open, cursor memory, Fieldbook paging and evolution info, time/weather on card, found-in conditions, "Where next?" objective, rematches ready
- imm-audio: ambience beds, weather layers, footsteps, muffled music indoors, train sounds, interaction sounds, bells and horns, ambience volume
- imm-world: weather persists, zone name card, interiors follow time, varied night windows, bobbing boats, birds/bats, fog/gale/frost visuals, chimney smoke, wet ground

## Backlog (from the audits, ranked)
QoL: button hints follow the device and remaps (all ui/*); nicknames; move reordering; move relearner; repel item (Lavender Sachet); swap on catch with a full party; Ark swap/sort/summary/release; shorter Sanctuary heal; interactive map with town info and fly-by-cursor.
Immersion: visible train/ferry journeys; fake lamp light pools; wild creatures roaming the grass; NPCs reacting to weather/time (`when` conditions + lines); NPC day/night schedules (`times`); more NPC movement; idle and running animations; bunting, flags, washing lines; interior dressing presets (chippy, pub, library, home); camera polish; door animation; regional greetings.
