# Plan 4 story beats (playtest bot route for M3)

The ordered beats a bot performs to finish M3 (the Fae Stone through the Newgrange scene), one per line as `zone | npc id | what it does | flag set`. "Talk" means stand on an adjacent tile and interact; trainer NPCs also challenge by line of sight. Badge checks in dialogue use our own flags (`badge_<id>`) because `if` cannot see `data.badges`; each `badge` command is followed by `set badge_<id>`.

Gates that depend on flags are evaluated when a zone loads (`hide_if` / `show_if`). Where a blocker sits in the zone you are standing in, the script ends with a `warp` back to the same zone (a reload) so the blocker is gone straight away. Elsewhere, leaving and re-entering the zone is enough. The Keeper scripts (Morwen, Declan, Nuala) end with Garside's call, as M2's did, and none of the three Stones grants a new field ability.

## Required beats, in order

```
cardiff_arena | keeper_rhys | Rhys script now ends with Garside's call sending you east over the Severn to Bath and Glastonbury (the v0.2 end card is gone) | badge_storm, ch4_storm, v02_complete, ch5_started
glastonbury | kit_tor | kit_glaston: Kit battle 5 (kit_5_vs_<starter>, counter of the starter flag), NPC at (47,8) beside the Tor path | trainer_kit_5_vs_<starter>, kit5_done
glastonbury_tor | tor_druid, tor_festival | one double battle (trainer tor_druid, 2v2 with 4 creatures); both NPCs at (19,20) (19,21) facing right on the path to the top; either one triggers it | trainer_tor_druid
glastonbury_tor | greenman_spot | the orchard scene before the Stone: the Enclosure fences the orchard, Kit helps, the Green Man wakes and says "the Keeper's Stone first". Talk from (10,20) facing left; zone reloads at (10,21). Optional for the route, but it is what the spot shows before badge_fae | ch5_greenman_woke
glastonbury_tor | keeper_morwen | Keeper Morwen fight (pixiedell 47, thornwyn 48, tylwyth 48, lanternis 50), Fae Stone, Garside's call west (Ashcombe, Dartmoor, Tintagel, Cornwall) | badge_fae, ch5_fae, trainer_keeper_morwen (badge fae)
glastonbury_tor | greenman_spot | after badge_fae: legend battle greenman L55 (no run); once caught never offered again; zone reloads at (10,21) | caught_greenman (when caught)
tintagel | ashcombe | ashcombe_tintagel: Ashcombe battle 1 (bodminax 44, wessexwyrm 45, cassiterix 45) at (17,12), talk from (17,13) facing up; zone reloads at (17,13) | trainer_ashcombe_1, ashcombe1_done
geevor | ashcombe_mine | ashcombe_mine: Ashcombe battle 2 (cassiterix 42, bodminax 42, sootwing 43, wessexwyrm 44), deep end at (23,5), talk from (23,6) facing up. Garside's call gives ferry_ticket and sends you to Holyhead (rail to Llanberis, west over Anglesey and the Menai Bridge). Zone reloads at (23,6) | trainer_ashcombe_2, ashcombe2_done, ferry_ticket (flag and key item)
holyhead | hh_sailor | needs flag ferry_ticket; ferry choice 0 sails to Dublin. Without the ticket the sailor politely refuses and nothing happens | none
dublin | kerrigan_launch | kerrigan_launch: "Ireland's Ancient East Experience" launch speech at (52,4), no battle | ch6_launch
dublin_hall | keeper_declan | Keeper Declan fight (stagmor 47, gealhare 47, dextera 48, connemarr 50), Kin Stone, Garside's call (Wicklow road, Kilkenny) | badge_kin, ch6_kin, trainer_keeper_declan (badge kin)
kilkenny | kerrigan | kerrigan_kilkenny: Kerrigan battle 1 (pooka 50, sikawhistle 50, pincray 51, rookery 52) at (17,14), talk from (17,15) facing up; zone reloads at (17,15) | trainer_kerrigan_1, kerrigan1_done
galway | kit | kit_galway: Kit battle 6 (kit_6_vs_<starter>) at (25,21) | trainer_kit_6_vs_<starter>, kit6_done
galway_docks | keeper_nuala | Keeper Nuala fight (plungebeak 50, selkie 51, baskarr 51, merrow 52, bradan 54), Tide Stone, Garside's call (Newgrange at the solstice; the bog road and the Dublin road are open) | badge_tide, ch7_tide, trainer_keeper_nuala (badge tide)
newgrange_tomb | kerrigan_tomb | kerrigan_tomb: Kerrigan battle 2 (pooka 62, bansheen 62, rookery 63, megalorn 64) at (11,18), talk from (11,19) facing up. Then, in the same script: solstice light (music legend_crow, sfx tomb_light, sfx crow), the Morrigan wakes and judges the Enclosure, Kerrigan hands in her lanyard, end card "End of Wildlore v0.3. The North is waiting." Zone reloads at (11,20) | trainer_kerrigan_2, ch7_judged, kerrigan_resigned, v03_complete
newgrange_tomb | morrigan_spot | after ch7_judged: legend battle morrigan L60 (no run) at (11,6); once caught never offered again; zone reloads at (11,8) | caught_morrigan (when caught)
```

Not required for the route but available: Bath, Mendips, Levels, Dartmoor, Wicklow, Cork, Kerry and Connemara trainers are optional XP.

## Blocker NPCs (physical gates, all `hide_if` unless marked)

```
zone | npc ids | tiles | what it blocks | hide_if
somerset_levels | levels_gate_a, levels_gate_b, levels_gate_c | (28,42) (29,42) (30,42) | the south road to Dartmoor, Tintagel, Penzance and Geevor | badge_fae
tintagel | tintagel_gate_a, tintagel_gate_b, tintagel_gate_c | (28,42) (29,42) (30,42) | the south road to Penzance and Geevor, until Ashcombe 1 | ashcombe1_done
geevor | geevor_gate_a, geevor_gate_b, geevor_gate_c | (21,19) (22,19) (23,19) | the north spine to the deep end and Ashcombe 2 | ashcombe1_done
holyhead | hh_sailor | n/a (not a blocker NPC) | the Dublin ferry; the sailor checks flag ferry_ticket | ferry_ticket (set by the Geevor scene)
dublin | dublin_south_a, dublin_south_b, dublin_south_c | (30,52) (31,52) (32,52) | the south road to Wicklow, Kilkenny and everything south and west | badge_kin
dublin | dublin_north_a, dublin_north_b, dublin_north_c | (30,1) (31,1) (32,1) | the north road to the Boyne Valley, which would skip the west and reach Newgrange early | badge_tide
galway | galway_north_a, galway_north_b, galway_north_c | (34,1) (35,1) (36,1) | the north road to Connemara, Sligo, the Boyne Valley and Newgrange | badge_tide
newgrange_tomb | kerrigan_tomb, tomb_gate_a, tomb_gate_b | (11,18) (10,18) (12,18) | the inner passage to the chamber and the Morrigan; the two Wardens vanish on trainer_kerrigan_2, Kerrigan herself on ch7_judged | trainer_kerrigan_2 (Wardens), ch7_judged (Kerrigan)
```

`show_if` NPCs: `newgrange/garside_ng` (35,19) and `newgrange/kerrigan_after` (40,20) appear once `ch7_judged` is set. Garside is in person only here.

The glastonbury_tor juniors `tor_festival` (merged into the double-battle trainer `tor_druid`, the `tor_festival` trainer file is gone) are on the path at (19,20) and (19,21), not a hard block, since the three-wide path lets you walk past, but both see you.

The unavoidable ordering is therefore: Morwen (Fae Stone) before the Levels road south; Ashcombe 1 (Tintagel) before Penzance and the mine; Ashcombe 2 before the ferry ticket, so before Ireland; Declan (Kin Stone) before leaving Dublin south; Nuala (Tide Stone) before Connemara north and before Dublin's north road, so before Newgrange; Kerrigan 2 before the tomb's chamber. No gate can soft-lock: each hider is set by a script in a zone reachable before the gate, the Keepers' arenas have no way to lose progress (a loss whites out to the last Sanctuary and the script repeats), the Kerrigan 2 script is safe to re-run after a loss, and the arrival edge row of each gated zone is never occupied by a blocker.

## Optional beats (bot may skip)

```
bath | heritage_stall | the Heritage Water stall: choice 0 asks where it comes from | heritage_found
bath_baths | spring_keeper | first talk explains; after heritage_found gives cream_tea, once | heritage_started, heritage_done
glastonbury_tor | greenman_spot | the orchard scene, see above | ch5_greenman_woke
dartmoor | ashcombe_moor | Ashcombe at Hound Tor for his brochure, no battle, choice about the brochure | ch5_moor_met
ring_of_kerry | deer_ranger | first talk: asks for a count; second talk: choice 2 ("Five") is right, gives barmbrack x2, once. There are 5 red deer here (2 stags, 3 fawns) | deer_started, deer_done
cork | market_fishmonger | starts the English Market trail | market_started
cork | market_baker | stamp, any time | market_baker_done
cork | market_spice | stamp, any time | market_spice_done
cork | market_fishmonger | after both stamps: soda_bread x3 and pasty, once | market_done
sligo | sligo_poet | offer a line (choice 0 or 1, not 2), gives kendal_mint_cake x2, once | poet_done
newgrange | garside_ng | Garside in person after the scene: the North is waiting | garside_met
newgrange | kerrigan_after | Kerrigan with a 99 and no lanyard | none
```

## Field abilities told to the player

None new. Garside's calls after Morwen, Declan and Nuala mention no field ability; Morwen and Declan say so lightly. The Tide Stone grants no field ability either.

## Item and key-flag summary

`ferry_ticket` (key item) from the Geevor scene after Ashcombe 2, together with the flag `ferry_ticket` that the Holyhead sailor reads (the flag is how `if` sees it). `cream_tea` from the Bath spring keeper, `barmbrack` x2 from the Kerry ranger, `soda_bread` x3 and `pasty` from the Cork fishmonger, `kendal_mint_cake` x2 from the Sligo poet. All items already exist. Flags the bot may rely on for assertions: `badge_fae`, `trainer_kit_5_vs_<starter>`, `ashcombe1_done`, `ashcombe2_done`, `ferry_ticket`, `badge_kin`, `kerrigan1_done`, `trainer_kit_6_vs_<starter>`, `badge_tide`, `ch7_judged`, `v03_complete`, `caught_greenman` and `caught_morrigan` (only when caught).
