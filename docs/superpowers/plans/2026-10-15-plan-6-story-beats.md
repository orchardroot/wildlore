# Plan 6 story beats (playtest bot route for M4 part 2 and the ending)

The ordered beats a bot performs to finish v0.5 (Garside's call south in Aberdeen through the credits), one per line as `zone | npc id | what it does | flag set`. "Talk" means stand on an adjacent tile and interact; trainer NPCs also challenge by line of sight. Badge checks in dialogue use our own flags (`badge_<id>`) because `if` cannot see `data.badges`; each `badge` command also sets `badge_<id>` itself.

Gates that depend on flags are evaluated when a zone loads (`hide_if` / `show_if`). Where a blocker sits in the zone you are standing in, the script ends with a `warp` back to the same zone (a reload) so the blocker is gone straight away. Elsewhere, leaving and re-entering the zone is enough. The Keeper script (Hester) ends with Garside's call, as every Keeper's does. The v0.4 end card is gone: Aberdeen's postie now gives the call south.

## Required beats, in order

```
aberdeen | abdn_postie | Garside's call at (7,27), talk from (7,26) facing down: Strachan has resigned, York and the Spirit Stone, the south road to Northumberland, rumours of a worm and a black dog, and the Moot. No end card. Guarded by ch10_started, so a v0.4 save that saw the old card (v04_complete set) gets the call once | ch9_done, v04_complete, ch10_started
york_minster_crypt | keeper_hester | Keeper Hester fight (centurion 86, coblynn 86, gwyllgi 87, bansheen 87, hushwing 88) at (9,2), talk from (9,3) facing up. Spirit Stone, the Moot Token (key item), then Garside's call: "All ten. The Moot will call you." Names Sheffield, the Dales and Salisbury Plain and tells you the worm and the dog are ready. Buxton's Sheffield Wardens (hide_if badge_spirit) clear on the next visit | badge_spirit, ch10_spirit, trainer_keeper_hester (badge spirit), moot_token (key item)
penshaw | lambton_spot | before badge_spirit: the hill stirs and the Worm says "It's only for ten" (no battle). After badge_spirit: the Worm rises (first time only), legend battle lambton L86 (no run, music legend), talk from (22,13) facing up; once caught never offered again; the zone reloads at (22,13) | lambton_stirred, lambton_met, caught_lambton (when caught)
whitby | shuck_spot | before badge_spirit: a gatepost with ears, "Not yet, little walker". After badge_spirit: Black Shuck steps out of the fog (first time only), legend battle shuck L86 (no run, music legend_hound2), talk from (53,17) facing up; once caught never offered again; the zone reloads at (53,17) | shuck_stirred, shuck_met, caught_shuck (when caught)
stonehenge | kit | Kit 8 at the gate of the Moot (kit_8_vs_<starter>, by the starter flag) at (28,8), talk from (29,8) facing left. Kit's short speech: "I'm proud of you. That's the speech." | trainer_kit_8_vs_<starter>, kit8_done, ch12_started
stonehenge | wind_aelwen, wind_fergus, wind_aoife, wind_wilf (script moot_wind) or champion_garside (script moot_centre) | talking to any of them, once kit8_done is set, explains the rules (first time only), asks "Begin the Moot?" (choice 0 is Begin) and runs ONE gauntlet: wind_aelwen, wind_fergus, wind_aoife, wind_wilf, champion_garside, flag moot_won, exit at (30,8) beside Kit. The gauntlet plays each trainer's intro itself; Garside's intro is the reveal ("Someone had to keep the old places safe until someone better came along"). A loss at any fight wakes you at (30,8), healed and half-poorer, nothing half-won; you try again from Aelwen. Then the victory scene: the stones hum, the Winds speak, Kit cheers from the gate, Bran's Raven arrives (music legend_crow) with the news that Vane has taken the ten Wardstones to his tower to bind every legend at once, and offers to fly you anywhere you have been | moot_won, champion, ch12_moot
sherwood | herne_spot | before moot_won: a horn in the trees and a rider with antlers, "The Moot first, walker" (no battle). After moot_won: Herne rides out (first time only), legend battle herne L90 (no run, music legend_green), talk from (50,49) facing right; once caught never offered again; reloads at (50,49) | herne_stirred, herne_met, caught_herne (when caught)
london | (arrival) | walk east out of the Moot along the road; London's west edge is the arrival. The Tower of London, the ravens and the shops are open. The tower door and the Underground door are shut by Wardens until moot_won | none
underground | reunion_a | Directors Pryce and Ashcombe, a double battle (reunion_pryce_ashcombe) in the one-tile corridor at (14,24), talk from (14,25) facing up. They wander off; the zone reloads at (14,25) and they are gone | trainer_reunion_pryce_ashcombe
underground | reunion_b | Directors Kerrigan and Strachan, a double battle (reunion_kerrigan_strachan) in the corridor at (24,8), talk from (24,9) facing up. They go home; the zone reloads at (24,9) | trainer_reunion_kerrigan_strachan
vane_tower_lobby / vane_tower_mid / vane_tower_top | vt_warden_1 to vt_warden_6 | the tower's Wardens, optional XP on the way up; the Underground's north end (25,1) and the street door (37,19 in London) both lead into the lobby | trainer_vt_warden_*
vane_tower_top | vane | Lord Vane at (15,5), talk from (15,6) facing up. His speech, the trainer intro, music battle_final, vane_final (wessexwyrm 84, shuttlecog 84, sootwing 85, goldeneyrie 85, shuck 87). On the win: the Wardstones crack, a montage names all ten legends (Nessie, Y Ddraig Goch, the Morrigan, the Cu-Sith, Manannan's Horse, the Green Man, the Lambton Worm, Black Shuck, Herne, Bran's Raven), Vane is left on a filing box grumbling about his deposit. Fade, warp home to macc_home (4,5), music ending; Mum, Kit and Garside in a warm closing scene; game_complete is set; credits; then three lines of post-game hints. The player is free | trainer_vane_final, game_complete
london | bran_spot | before the ending the raven only watches the glass tower ("Kraa. The tower first" once moot_won). After game_complete: Bran's Raven speaks (first time only), legend battle bran L92 (no run, music legend_crow), talk from (70,20) facing up; once caught never offered again; reloads at (70,20) | bran_met, caught_bran (when caught)
```

Reachability notes for the bot: after Aberdeen the road is Northumberland coast, Hadrian's Wall, Newcastle (Penshaw to its west), the Moors, Whitby, York. From York the long way round is the Dales, Lancaster, the Lakes and Keswick, then south; York also joins Sheffield directly, and Buxton's east road joins it too once badge_spirit is set. Sheffield, Sherwood, Nottingham, Birmingham and Salisbury Plain lead to the north edge of Stonehenge. The Moot is south of the gate; London is the east exit from inside the circle. Flight (the `champion` flag) is a shortcut only: it is never the only way to reach a place.

## Blocker NPCs (physical gates, all `hide_if`)

```
zone | npc ids | tiles | what it blocks | hide_if
stonehenge | moot_gate_a, moot_gate_b, moot_gate_c, moot_gate_d, moot_gate_e | (2,9) (29,9) (30,9) (31,9) (57,9) | the Moot circle and so London (the fence on row 9 has the path and a gap at each end, so five Wardens) until the tenth Stone | badge_spirit
london | london_tower_gate | (37,20) | Vane Tower's street door (37,19), reachable only from this tile | moot_won
london | london_tube_gate | (24,26) | the Underground door (24,25), reachable only from this tile | moot_won
underground | reunion_a | (14,24) | the one-tile corridor north of the first platform, until Pryce and Ashcombe are beaten | trainer_reunion_pryce_ashcombe
underground | reunion_b | (24,8) | the corridor to the lobby stairs, until Kerrigan and Strachan are beaten | trainer_reunion_kerrigan_strachan
buxton | sheffield_warden_1/2/3 | (54,20) (54,21) (54,22) | the Sheffield road (already in place) | badge_spirit
kit | kit | (28,8) | not a blocker: stands beside the path. The Winds ask for him first (kit8_done) | none
```

`show_if` NPCs: none new. The legend spots (`lambton_spot`, `shuck_spot`, `herne_spot`, `bran_spot`) are always visible and `hide_if` their `caught_<id>` flag; each script also checks `caught_<id>` first, so a repeat call never starts a second battle.

The unavoidable ordering is therefore: Hester (Spirit Stone) before the Moot gate and before Sheffield from Buxton; Kit 8 before the Winds; the whole gauntlet before the London doors; the Directors before Vane's lobby from the Underground (the street door is open to anyone who has won the Moot). No gate can soft-lock: badge_spirit is set in the York crypt, which sits north of every gated zone and is reached without passing the Moot gate; moot_won is set inside the circle, which is on the near side of London; the reunion flags are set by their own battles (`battle` sets `trainer_<id>`), and a loss at any of them whites out to the last Sanctuary and the script repeats; the Wardens at the two London doors stand one row inside, never on an edge or arrival tile, and a player who has not yet won the Moot can still walk the whole of London, buy things, and see the ravens. A gauntlet loss warps to (30,8), a walkable path tile next to Kit, so it never traps the player in the circle. Flight is only offered after `champion`, so it cannot jump the gates.

Every Warden gate tells the player where to go: the Moot Wardens send you to the York crypt, the London Wardens send you to Stonehenge.

## Optional beats (bot may skip)

```
whitby | wby_jeweller | the jet carver at (43,31): first talk, choice 0 ("Go on, then") polishes a piece and gives whitby_jet once (the evolution item for Jetling); choice 1 declines | jet_choice, jet_done
lake_district | ld_shepherd | the shepherdess at (13,47): first talk asks you to count the Herdwicks; second talk, choice 2 ("Eight") is right, gives kendal_mint_cake x2, once. There are 8 Herdwicks on this map (7 on the fell, 1 on the summit) | herd_started, herd_count, herd_done
sheffield | shf_steelman | the retired steelworker at (8,19): choice 0 ("Show me round") takes the steelworks tour (fade, a short scene) and gives pork_pie x2, once | steel_choice, steel_toured
birmingham | brum_boater_chat | the narrowboat captain at (12,29): choice 0 ("All aboard") takes the canal trip (fade, a short scene) and gives flask_of_tea x2, once | canal_choice, canal_done
macc_home | mum | after game_complete Mum has her post-game lines and no more free tea | none
```

## Post-game

After the credits the player is free in Mum's front room. Flight is on (the Map's Fly button; flag `champion`). Bran's Raven, Herne and the rest are catchable as above. The closing narration points at Orkney's standing stones (Kirkwall) and Douglas Head on the Isle of Man for the last secrets. Vane stays on his filing box (his post-game lines are two short jokes).

## Item and key-flag summary

`moot_token` (key item) from Hester; `whitby_jet` from the Whitby jet carver; `kendal_mint_cake` x2 from the Lake District shepherdess; `pork_pie` x2 from the Sheffield steelworker; `flask_of_tea` x2 from the Birmingham captain. All items already exist. Flags the bot may rely on for assertions: `ch10_started`, `badge_spirit`, `ch10_spirit`, `kit8_done`, `trainer_kit_8_vs_<starter>`, `moot_won`, `champion`, `ch12_moot`, `trainer_reunion_pryce_ashcombe`, `trainer_reunion_kerrigan_strachan`, `trainer_vane_final`, `game_complete`, and `caught_lambton`, `caught_shuck`, `caught_herne`, `caught_bran` (only when caught).
