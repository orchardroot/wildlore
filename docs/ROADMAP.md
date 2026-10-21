# Wildlore: These Isles, roadmap

The game is meant to be looked after for years. This is the running plan beyond whatever release is in progress. The
reasoning behind it (what the game is now, the economy design, depth, minigames, the name) is in
[docs/design/2026-10-21-deeper-wildlore.md](design/2026-10-21-deeper-wildlore.md). Work items for the next release are
GitHub issues labelled with its milestone.

The identity line everything is judged against: **a walking holiday round the real Isles that turns into a life
there.** A feature belongs if it makes a place more knowable, makes the player more of a local, or makes the land
richer.

## Done
- **3.0 Wider Isles**: the walled-off edges opened, 72 towns, quests, 900+ plaques and the Gazetteer, 131 regional
  creatures, euros and markets, the casino and Aintree, par-level scaling.
- **3.1 Seasons & Streets**: local architecture for the original towns, real-date festivals, regional cooking, home
  souvenirs and garden, weather that matters.
- **3.2 Shetland and Small Mercies**: Shetland and Up Helly Aa, yearly festivals, the game says why it won't do things,
  visual fixes.
- **3.3 Overseas**: RAF Brize Norton and 18 overseas destinations, Jersey, Guernsey and Sark, real currencies; the game
  renamed Wildlore: These Isles.

## Next: 3.4 Market Day (the economy's floor)
- **Trade Ledger**: place-set prices for materials, dishes and regional items, gluts, perishables, a pannier; the Money
  Box on the wireless and a Monday market report.
- **Market Halls**: 25 real halls as rooms with a stall-holder, a price board and a sell flow.
- **The Building Society**: loans with honest compound interest, letters, Mum's sub.
- **Trades**: the player's own progression (Rambler, Trader, Cook and more) read off the stats you already earn, with
  small perks.
- **Fishing**: on water tiles, rods, fish as items, creatures only found on a line.

## Then
- **3.5 Open for Business**: Deeds you buy, supply, upgrade and pay rates on (a chippy, a B&B, a boat, a market stall,
  an allotment), twelve recurring characters who remember you, the HMRC envelope, darts, crabbing, the allotment show and
  sheepdog trials.
- **3.6 Behind Doors**: examine spots and hidden rooms, Deep Places (puzzle caves and mines, Blue John first), the
  Casebook of mysteries, guilds with one real choice, your lead creature doing a job in the overworld, bell ringing and
  drystone walling.
- **3.7 The Long Game**: the Enclosure leases (buying back fenced land after the story opens new small zones), a pub
  quiz league, Highland games, hurling and shinty, sea shanties, NPC routines, a long arc for each nation, a Year in the
  Isles epilogue.

## Alongside, whenever there's room
- Windows and Linux builds checked in the Release workflow, and an in-game "report a bug" button.
- A fresh-eyes audit of the first hour for new players, and a scan for anything too close to Pokémon.
- Contributor docs: CONTRIBUTING.md, issue templates, "good first issue" labels.

## Parked
- **Android**: Godot exports it easily, but it needs touch controls and a UI pass for small screens first.

## Long term (not in the current version)
- **Multiplayer.** A PvP battle server: link battles between friends, ranked play with sensible rules (level caps, banned
  items), spectating.
- **Trading.** Trade creatures between players (with evolution-on-trade and anti-cheat checks on what is traded), and
  a way to share Fieldbook progress.
- Needs: an account or friend-code system, a server (Cloud Run fits what we already use), save integrity checks so
  traded creatures are legitimate, and a protocol that keeps battles deterministic (the battle engine already runs
  from a seeded Rng).
