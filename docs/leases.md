# Enclosure leases: the zone contract (wave 38)

Core is `core/leases.gd`; the auction screen is `ui/lease_screen.gd`. To add a lease you write **one JSON file, one zone,
one dialogue file**. Nothing else is edited. Reference leases: `pennine_grouse_moor` (England, anchor `saddleworth_moor`)
and `welsh_conifer_plantation` (Wales, anchor `dee_valley`).

## data/leases/<id>.json
`id` (= filename), `name`, `nation` (england, wales, scotland, ireland, northern_ireland), `kind` (see `Leases.KINDS`),
`anchor` (an existing outdoor zone), `side` (an edge of the anchor that is free today), `zone` (your new zone id),
`reserve` (sterling, 30000 to 150000; euros by Wallet for Ireland), `upkeep` (weekly, a year of it must cost less than the
reserve), `unlock_flag` (`game_complete`), `trust_wants` (the Heritage Trust bids), `blurb`, plus:
- `gap`: `{"at": n, "width": 3, "offset": k}`. `at` is the position along the anchor's `side` border (x for north and
  south, y for east and west). The parser cuts a path track of `width` from that border inward until it meets land the
  anchor's spawn can reach (so you only pick a position; `tools/validate.gd` complains if none is within 24 tiles) and adds
  the edge `side` to the anchor. You never edit the anchor file. Unowned land is fenced across the gap with a
  "Private land, Enclosure Ltd" sign (`Leases.apply`, called when the overworld loads the zone).
- `rewild`: `{"biome", "rect", "encounters"}`. `biome` is a four-look set in `data/rewild.json` (moss, rainforest,
  pinewood, river, cutaway, heath), `rect` is `[x, y, w, h]` of the lease zone that changes, `encounters` is three lists
  (stages 1 to 3) of `{kind, species, min, max, weight, ...}` that only appear once the land reaches that stage.
- `ranger`: four lines, one per stage 0 to 3, said by the ranger (see dialogue).

## The lease zone (data/zones/<zone>.json)
- Outdoor, `kind: "route"`, a **cul-de-sac**: exactly one edge, the opposite of `side`, to the anchor, with
  `offset` = minus the gap's `offset`. Never a shortcut between two existing zones; warps may only lead to interiors.
- The zone's border must be walkable **only** where the gap lands: with anchor edge offset `k` the tiles are
  `gap.at - width/2 .. gap.at + width/2` shifted by `k`. Everything else on that border is trees, rock or void.
- Base `encounters` are the damaged land's creatures (post-game levels, about 84 to 90); `rewild.encounters` add the returning ones.
- At least **two plaques** (`signs` with `plaque` and `title`; unique ids prefixed `lease_`), accurate land-use history.
- A ranger NPC whose dialogue script is `{"do": "lease", "id": "<lease id>", "who": "Ranger"}`: he says the line for the
  land's stage, then the estate office opens (upkeep, commission the next stage).
- Cheap and honest: no per-frame work, no new autoload names in validator-loaded scripts.

## The auction
At the Exchange (`{"do": "lease", "id": ""}` on an auctioneer NPC; Edinburgh, Manchester and Dublin have one). Opens at
the reserve; steps of 5%; rivals are the Enclosure's liquidator, a sector rival by kind, and the Heritage Trust if
`trust_wants`. Ramblers face a keener Trust; Trustees have no Trust bid, a 10% friendlier reserve, and their land is
managed for the shoot (rewilding stops at stage 1 until they resign). State: flag `lease_<id>` (absent = not held),
`rewild_lease_<id>` (stage 0 to 3), `lease_tries_<id>`, `leases_post`. Upkeep is taken weekly and arrives as post; six
missed weeks and the Enclosure takes the land back (the stage is kept). Each stage costs money and takes 30 in-game days.

## Dev
`--menu=lease[:<id>][:owned|:trust|:ramblers]`, and on a boot `--lease=<id,id>` (holds them) with `--rewild=<0..3>`.
