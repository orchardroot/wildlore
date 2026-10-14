# Plan 5 story beats (playtest bot route for M4 part 1)

The ordered beats a bot performs to finish v0.4 (Garside's call north from Newgrange through Garside's call in Aberdeen), one per line as `zone | npc id | what it does | flag set`. "Talk" means stand on an adjacent tile and interact; trainer NPCs also challenge by line of sight. Badge checks in dialogue use our own flags (`badge_<id>`) because `if` cannot see `data.badges`; each `badge` command also sets `badge_<id>` itself, so the scripts need no extra `set`.

Gates that depend on flags are evaluated when a zone loads (`hide_if` / `show_if`). Where a blocker sits in the zone you are standing in, the script ends with a `warp` back to the same zone (a reload) so the blocker is gone straight away. Elsewhere, leaving and re-entering the zone is enough (this is how all four gates below clear: the scripts that unlock them run in a different zone). The Keeper scripts (Ruairí, Isla) end with Garside's call, as M3's did. Neither Stone unlocks anything by itself that a bot has to do: the Lantern is a key item given by Ruairí, and Bog-cross comes with the Frost Stone (waders from Isla are flavour).

## Required beats, in order

```
newgrange_tomb | kerrigan_tomb | the Kerrigan 2 scene as before, but the v0.3 end card is gone: after the Morrigan judges the Enclosure, Garside's call sends you north over the Mournes to Belfast (the Morrigan was seen flying north). Zone reloads at (11,20) | trainer_kerrigan_2, ch7_judged, kerrigan_resigned, v03_complete, ch8_started
newgrange | garside_ng | for v0.3 saves that saw the old end card: talking to Garside (35,19) gives the same call once if ch8_started is not yet set | ch8_started
belfast_yard | keeper_ruairi | Keeper Ruairi fight (samsonian 66, railspark 66, shuttlecog 67, quarrion 67, causewarden 68) at (9,3), talk from (9,4) facing up. Iron Stone, gives the Lantern (key item) and says the Stone lets you see in dark caves, then Garside's call (Belfast to Cairnryan ferry now open, Strachan, the Causeway) | badge_iron, ch8_iron, trainer_keeper_ruairi (badge iron), lantern (key item)
causeway | vane_causeway | Vane battle 1 (vane_1: goldeneyrie 63, sootwing 63, shuttlecog 64, wessexwyrm 65) at (38,33), talk from (38,34) facing up. Then the scripted scene: music legend_sea, Manannan's Horse rises, the sea washes out his marquee, Vane leaves saying "We'll meet at the Moot". Zone reloads at (38,34): Vane gone, Enbarr appears | trainer_vane_1, ch8_vane
causeway | enbarr_spot | after ch8_vane: legend battle enbarr L66 (no run, music legend_sea), talk from (56,13) facing right; once caught never offered again; zone reloads at (56,13) | caught_enbarr (when caught)
belfast | belfast_sailor | needs flag badge_iron; ferry choice 0 sails to Cairnryan. Without the Stone the sailor politely refuses and nothing happens | none
cairnryan | (arrival) | the ferry lands at the Cairnryan quay. The Cairnryan sailor (cai_sailor) always sails back to Belfast | none
edinburgh | kit | kit_edinburgh: Kit battle 7 (kit_7_vs_<starter>, counter of the starter flag) on the Castle esplanade at (20,42), talk from (20,43) facing up | trainer_kit_7_vs_<starter>, kit7_done, ch9_started
glencoe | strachan | strachan_glencoe: Strachan battle 1 in the mist (strachan_1: highlynx 70, midgeswarm 70, kelpie 71, heilan 72) at (27,29), talk from (27,30) facing up; zone reloads at (27,30) and she is gone | trainer_strachan_1, strachan1_done, ch9_glencoe
great_glen | great_glen_east_a/b/c | the gate to Loch Ness is gone once trainer_strachan_1 is set (reload by leaving and re-entering) | none
loch_ness | strachan_boat | strachan_loch_ness: Strachan battle 2 on the survey boat (strachan_2: highlynx 69, kelpie 69, minchman 70, orcaird 70, heilan 71) at (24,31), talk from (24,30) facing down. Then Nessie surfaces (scripted, music legend_sea), Strachan announces the Enclosure is pulling out of Scotland. Zone reloads at (24,30), boat gone | trainer_strachan_2, strachan2_done, ch9_nessie_seen
inverness_rink | keeper_isla | Keeper Isla fight (ermine 76, ptarmigan 76, orcaird 77, reindeer 77, haarling 78, polartern 79) at (8,3), talk from (8,4) facing up. Frost Stone, gives the waders and says the Stone lets you cross bogs (Bog-cross), then Garside's call (Skye, the Cairngorms) | badge_frost, ch9_frost, trainer_keeper_isla (badge frost), waders (key item)
loch_ness | nessie_spot | after badge_frost: legend battle nessie L74 (no run, music legend_sea), talk from (56,36) facing down; island needs brook_wade; once caught never offered again; zone reloads at (56,36) | caught_nessie (when caught)
faerie_glen | cusith_spot | before badge_frost: the three barks scene (counted, choice 2 "Three" is right), no battle. After badge_frost: legend battle cusith L76 (no run, music legend_hound), talk from (15,6) facing up; once caught never offered again; zone reloads at (15,6) | ch9_cusith_heard (counting scene), caught_cusith (when caught)
aberdeen | abdn_postie | Garside's call at (7,27), talk from (7,26) facing down: "York. The Spirit Stone. And then the Moot." End card "End of Wildlore v0.4. The Moot is gathering." The player stays free (Orkney ferry, side quests) | ch9_done, v04_complete
```

Reachability notes for the bot: from Belfast to the Causeway the road runs Belfast, Antrim coast, Causeway (the Belfast north gate clears at badge_iron). Skye and the Cairngorms need badge_frost (the Inverness gates). Aberdeen is reached through the Cairngorms (east of Inverness), so it is always after the Frost Stone. Nessie and the Cù-Sìth are optional for the route and need the Frost Stone; the bot may take them after Isla. Strachan 1 does not stop the player physically (the path is two tiles wide and she stands on one), so a player can walk past her and reach the Great Glen gate, where the Wardens send them back to Glencoe.

## Blocker NPCs (physical gates, all `hide_if`)

```
zone | npc ids | tiles | what it blocks | hide_if
belfast | belfast_north_a, belfast_north_b, belfast_north_c | (30,1) (31,1) (32,1) | the Antrim coast road north (Antrim coast, Causeway, Bushmills, Derry), until Ruairi | badge_iron
great_glen | great_glen_east_a, great_glen_east_b, great_glen_east_c | (54,20) (54,21) (54,22) | the east road to Loch Ness (and so Inverness), until Strachan 1 at Glencoe | trainer_strachan_1
inverness | inverness_west_a, inverness_west_b, inverness_west_c | (1,20) (1,21) (1,22) | the west road to Skye and Portree, until the Frost Stone | badge_frost
inverness | inverness_east_a, inverness_east_b, inverness_east_c | (62,24) (62,25) (62,26) | the east road to the Cairngorms and Aberdeen, until the Frost Stone | badge_frost
causeway | vane_causeway | (38,33) | not a blocker: Vane stands beside the road and leaves after the scene | ch8_vane
glencoe | strachan | (27,29) | not a hard blocker: stands on one of the two path tiles; leaves after the battle | strachan1_done
loch_ness | strachan_boat | (24,31) | not a blocker: end of the pier; leaves after the scene | strachan2_done
belfast | belfast_sailor | n/a (not a blocker NPC) | the Cairnryan ferry; the sailor checks flag badge_iron | badge_iron
```

`show_if` NPCs: `causeway/enbarr_spot` (57,13) appears once `ch8_vane` is set (and hides again on `caught_enbarr`).

The unavoidable ordering is therefore: Ruairi (Iron Stone) before the Antrim coast road and the Causeway, and before the ferry to Scotland; Strachan 1 before Loch Ness, Inverness and everything after; Isla (Frost Stone) before Skye, the Cairngorms and Aberdeen. No gate can soft-lock: each hider is set by a script in a zone reachable before the gate (Ruairi's yard is inside Belfast; Strachan 1 is in Glencoe, south of the Great Glen; Isla's rink is inside Inverness, which is reached before either Inverness gate), a loss at any of those fights whites out to the last Sanctuary and the script repeats, and the arrival edge row or column of each gated zone is never occupied by a blocker (the gates sit one row or column inside: row 1 in Belfast, column 54 in the Great Glen, columns 1 and 62 in Inverness).

Every Warden gate tells the player where to go: the Belfast Wardens name Ruairi's shed, the Great Glen Wardens send you back to Strachan in Glencoe, the Inverness Wardens point to the ice rink.

## Optional beats (bot may skip)

```
derry | wall_guide | the Walls walk: first talk asks you to walk the north wall to its east end and say hello to Roaring Meg's keeper | walls_started
derry | walls_gunner | the keeper at the east end of the north wall, platform tile (40,7): after walls_started gives soda_farl x2, once | walls_done
glasgow | glasgow_ceilidh, glasgow_ceilidh_b | the Fiona and Ruaridh double battle (trainer glasgow_ceilidh, 2v2 with 4 creatures) at (62,29) (63,29) | trainer_glasgow_ceilidh
glasgow | glw_ceilidh_host | at (65,29): explains the ceilidh; after the double battle gives tablet x3, once | glw_ceilidh_paid
cairngorms | reindeer_herder | first talk: asks for a count; second talk: choice 2 ("Seven") is right, gives cranachan x2, once. There are 7 reindeer on this map (5 at the paddock, 2 out on the hills) | reindeer_started, reindeer_done
kirkwall | brodgar_ranger | the Ring of Brodgar riddle at (15,31) (reach it by the ferry from Aberdeen): choice 0 ("A standing stone") is right, gives irn_tonic x2, once | brodgar_done
aberdeen | abdn_sailor | the ferry to Kirkwall always runs; kwl_sailor always sails back | none
cairngorm_cave | cave_ranger | the dark cave (needs the Lantern to see well), tonic and tablet once | cave_ranger_gift
causeway | bushmills, derry | Bushmills and Derry trainers: optional XP | none
```

## Field abilities told to the player

Ruairi says the Iron Stone lets you see in dark caves, and hands over the Lantern (a key item). Isla says the Frost Stone lets you cross deep bogs, calls it Bog-cross, and hands over a pair of waders (a key item that is flavour for Bog-cross). Both are mentioned in the Keepers' own lines and in Garside's call.

## Item and key-flag summary

`lantern` (key item) from Ruairi; `waders` (key item) from Isla; `soda_farl` x2 from the Derry walls keeper; `tablet` x3 from the Glasgow hall keeper; `cranachan` x2 from the Cairngorms reindeer herder; `irn_tonic` x2 from the Brodgar ranger. All items already exist. Flags the bot may rely on for assertions: `ch8_started`, `badge_iron`, `ch8_vane`, `caught_enbarr` (only when caught), `trainer_kit_7_vs_<starter>`, `kit7_done`, `trainer_strachan_1`, `strachan1_done`, `trainer_strachan_2`, `strachan2_done`, `badge_frost`, `caught_nessie` and `caught_cusith` (only when caught), `ch9_done`, `v04_complete`.
