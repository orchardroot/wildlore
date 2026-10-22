# First-hour audit (wave 39 G)

Method: `tools/playtest.sh slice` (passes: first Stone won, 75 wins / 4 losses, no script errors) plus reading
macc_home, macc_fieldstation and macclesfield dialogue. The bot cannot judge confusion, so this is a read-through.

## Fixed
- Garside never said what a Stone is or how to open the menu; she now explains Keepers/Stones and Esc (Fieldbook, bag, map).
- Blocked-path hint said "comes with a gym badge" (also an IP finding); now "comes with one of the Stones".

## Open (not small or clear enough to fix blind)
- Terminology drifts between "Stone" and "Wardstone" (Mum and Garside use both); pick one in the opening.
- The noticeboard is mentioned by Mum, Garside and the Pigeon Lady, but nothing marks it on the map.
- Catching is explained in one line ("weaken, then throw"); no in-battle prompt shows the Snare option the first time.
- Kit's "Fire beats hedgerow" is the only type-matchup teaching; a first-battle hint would help.
- Mum's flask/tea gift is mentioned repeatedly with no visible purpose for a new player.

## Wave 40 E (gentle introductions)
- Added the Hints setting (Settings, on by default) and `Intros`: one short line in the hint bar the first time you open the
  Fieldbook, Bag, Team, Ark, Map, Journal, Stats, Almanac, a shop, a noticeboard, crafting, the Building Society, a Deed, a
  Market Hall or a pairing, plus a line at the first wild battle (weaken, then Snare) and the first Keeper battle (cannot be
  caught). Fixes the "no first-battle catching prompt" item above. Saves already past half an hour of play are treated as veterans.
- Still open: Stone/Wardstone wording, the noticeboard not marked on the map, Mum's flask.
