# Plan 3 story beats (playtest bot route for M2)

The ordered beats a bot performs to finish M2 (Brook Stone through the Storm Stone), one per line as `zone | npc id | what it does | flag set`. "Talk" means stand on an adjacent tile and interact; trainer NPCs also challenge by line of sight. Badge checks in dialogue use our own flags (`badge_<id>`) because `if` cannot see `data.badges`; each `badge` command is followed by `set badge_<id>`.

Gates that depend on flags are evaluated when a zone loads (`hide_if` / `show_if`). Where a blocker sits in the zone you are standing in, the script ends with a `warp` back to the same zone (a reload) so the blocker is gone straight away. Elsewhere, leaving and re-entering the zone is enough.

## Required beats, in order

```
buxton_spa | maud | Keeper Maud fight, Brook Stone, Garside's call north (Hedge-lay, Manchester) | badge_brook, slice_complete, ch2_started (badge brook)
manc_bikes | bev | needs badge_brook; gives key item bike | bev_bike_given
liverpool | kit | kit_pier: Kit battle 3 (kit_3_vs_<starter>, counter of the starter flag) | trainer_kit_3_vs_<starter>, kit3_done
liverpool_club | keeper_ray | Keeper Ray fight (binfox 20, strutcoo 21, pierlord 23), Urban Stone (Brook-wade), Garside's call, gives rail_pass | badge_urban, ch2_urban, trainer_keeper_ray (badge urban)
llanberis | pryce | pryce_quarry: Pryce fight 1 from the tile (15,15) facing up, then zone reloads at (15,15) | trainer_pryce_1, ch3_pryce1
llanberis_quarry | keeper_eluned | Keeper Eluned fight (gritling 28, billgruff 29, quarrion 31), Stone Stone (Fell-scramble) | badge_stone, ch3_stone, trainer_keeper_eluned (badge stone)
yr_wyddfa | pryce_summit | summit scene at (33,13), no battle: Wardstone, Y Ddraig Goch wakes, Wardens scatter; zone reloads at (34,14); needs Fell-scramble over the scree at x 37-39, y 17-18 | ch3_ddraig_woke
cardiff | kit | kit_bay: Kit battle 4 (kit_4_vs_<starter>), Kit quits the sponsorship | trainer_kit_4_vs_<starter>, kit4_done
cardiff | pryce | pryce_cardiff: Pryce fight 2 from the tile (21,31) facing up, then zone reloads at (21,31) | trainer_pryce_2, ch4_pryce2
cardiff_arena | keeper_rhys | Keeper Rhys fight (natterjack 35, severnshock 36, petrelash 37, stormswift 38), Storm Stone, Garside's call, end card "End of Wildlore v0.2. Ireland awaits." | badge_storm, ch4_storm, v02_complete, trainer_keeper_rhys (badge storm)
```

Not required for the route but available: before Keeper Ray, nothing; Wirral to Cardiff trainers are optional XP.

## Blocker NPCs (physical gates, all `hide_if`)

```
zone | npc ids | tiles | what it blocks | hide_if
liverpool | wirral_gate_a, wirral_gate_b, wirral_gate_c | (26,55) (27,55) (28,55) | the south road to Wirral Way, Chester and everything west | badge_urban
llanberis | pryce | (15,14) | the only tile in front of the quarry door (warp at 15,13) to llanberis_quarry and Keeper Eluned | trainer_pryce_1
llanberis | cambrian_gate_a, cambrian_gate_b, cambrian_gate_c | (24,39) (25,39) (26,39) | the south road to Cambrian Coast, Aberystwyth, Pembroke, St Davids, Beacons, Cardiff | ch3_ddraig_woke
cardiff | pryce | (21,30) | the only tile in front of the arena door (warp at 21,29) to cardiff_arena and Keeper Rhys | trainer_pryce_2
yr_wyddfa | pryce_summit, wyddfa_warden_1, wyddfa_warden_2, kit_summit | (33,13) (35,16) (37,16) (34,13) | not a road block: the summit party, gone after the scene | ch3_ddraig_woke
```

`show_if` NPCs: `yr_wyddfa/kit_summit_after` at (32,13) appears once `ch3_ddraig_woke` is set.

The unavoidable ordering is therefore: Liverpool badge before Wales; Pryce 1 before Eluned; Eluned (Fell-scramble) before the summit; summit before the road south of Llanberis; Pryce 2 before Rhys. No gate can soft-lock: each hider is set by a script in a zone reachable before the gate, the Keepers' arenas have no way to lose progress (a loss whites out to the last Sanctuary and the script repeats), and the Beacons road into Cardiff is open.

## Optional beats (bot may skip)

```
chat_moss | moss_warden | trainer: Warden Pike (scuttlet 16, pepperling 17, minkshade 18), faces down along the path at (65,18) | trainer_moss_warden
chat_moss | moss_peat | peat cutter, Garside's call about the bog (first talk only) | ch2_moss_call
manchester | vane | Vane's Heritage Experience speech, Kit with tote bags | ch2_vane_met
chester | pryce | Pryce's first appearance (talk, no battle) | ch3_pryce_met
llangollen | harpist | the tale of the two dragons | ch3_dragon_tale
aber_lab | dr_hughes | Wardstones explained, ten legends, ten Stones | ch4_hughes
pembroke_coast | cleanup | beach clean-up, choice 0 helps, gives bara_brith x3 | cleanup_done
douglas | lamb_1, lamb_2, lamb_3 (field at (8,43) (31,44) (36,41)), then farmer at (19,41) | Loaghtan lambs, farmer gives silver_snare | lamb_1_found, lamb_2_found, lamb_3_found, lambs_started, lambs_returned
dinas_emrys | ddraig_spot | before badge_storm: quiet pool and a rumble. After: legend battle ddraig L45 (no run), once caught never offered again | caught_ddraig
yr_wyddfa | kit_summit_after | Kit's afterthoughts | none
```

Reach Dinas Emrys through the warp at (36,9) on Yr Wyddfa (needs Fell-scramble). The dragon is not part of the M2 bot route.

## Field abilities told to the player

Brook Stone: Hedge-lay (Garside's call after Maud, and Bev). Urban Stone: Brook-wade (Keeper Ray). Stone Stone: Fell-scramble (Keeper Eluned). The Storm Stone grants no field ability in M2.

## Item and key-flag summary

`bike` from Bev (needs `badge_brook`, once). `rail_pass` from Garside's call after Ray (once, inside the first-win branch). `silver_snare` from the Douglas farmer. Flags the bot may rely on for assertions: `badge_brook`, `bev_bike_given`, `badge_urban`, `trainer_pryce_1`, `badge_stone`, `ch3_ddraig_woke`, `trainer_pryce_2`, `badge_storm`, `v02_complete`.
