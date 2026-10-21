# Deeper Wildlore: a design proposal

*2026-10-21. A design review of 3.3 and a proposal for 3.4 to 3.7. Written against the code as it stands (file names in brackets are the systems each idea extends).*

## 1. Diagnosis

### The loops today

Wildlore runs on five loops, and they are not equally deep.

1. **The main line.** Walk, catch, battle, Keeper, Stone. Ten badges across six nations, par-level scaling for everything off the line (`core/par_level.gd`), a post-game of rematches and the Open Moot (`core/tournament.gd`). This is the Pokémon skeleton and it is finished, balanced and bot-tested. It does not need more.
2. **The tourist loop.** 72 towns, 1,191 zones, 924 plaques in the Gazetteer, a Visitor's Book that pays out when you have seen every room in a town (`core/visitors_book.gd`), souvenirs on Mum's shelves (`core/home_extras.gd`). This is the thing nobody else has, and it is the heart of what the game has become.
3. **The daily loop.** Parish jobs (`core/jobs.gd`), Today's Walk (`core/todays_walk.gd`), the pub quiz, the county show, the race meeting, the garden visitors, all keyed on the real date (`core/daily_key.gd`). Good reasons to come back, each one small.
4. **The home loop.** Garden, forage, bench, kitchen, trophy shelf, rewilding (`world/rewild.gd`). Things that accumulate.
5. **The money loop.** Faucets: trainer prize money, jobs (`Jobs.money_for`, scaled by badges), the tourist board's £500, quiz prizes. Sinks: snares, food, charms, the bureau's spread (`core/forex.gd`), the casino's edge (`core/punt.gd`), share commission (`core/markets.gd`). Selling is half price everywhere (`ui/shop_screen.gd`).

### Where it is shallow or disconnected

- **Money has nowhere to go.** By Scotland the purse is comfortably ahead of anything the shops sell. The Exchange and Doggerel are well built but they are a side room: nothing in the world changes because you are rich, and nothing in the world feeds the markets except story flags. The casino is honest and therefore a sink only for people who enjoy losing.
- **Materials have no economy.** Eighteen materials, 23 dishes, 12 charms, all priced flat. A Whitby crab and a Cheshire blackberry are worth the same in Cork as at home. Regional items (`data/items/<region>.json`) are local to buy but not local to sell, so there is no reason to carry anything anywhere.
- **Standing is a discount.** Six nations, five tiers, and the payoff is 15% off and a parcel. It should be the spine of belonging and it is a loyalty card.
- **Rooms are talk-and-leave.** Five hundred interiors with someone inside who tells you something true. That is lovely once and never again. Only the London Underground and a few caves ask anything of you.
- **Quests are errands.** 150-odd quests, all flag chains of "go here, talk, fetch". The Quest Log is good; the quests inside it are short, and nobody in them remembers you afterwards. Side stories (`core/side_stories.gd`) are the one exception and there are 15 of them.
- **The trainer is nobody.** Badges give field moves (`world/field_moves.gd`); otherwise the player has no progression, no trade, no choices that stick. The Stats page counts your teas, which is the right instinct with no system behind it.

### What Wildlore is now

Pokémon is a game about power: the strongest team, the top of the League. Wildlore has quietly become a game about **belonging**: knowing a place, being known in it, and leaving it better than you found it. The creatures are the way in; the Isles are the game.

The identity line: **a walking holiday round the real Isles that turns into a life there.**

Everything below is chosen against that line. A feature belongs if it makes a place more knowable, makes the player more of a local, or makes the land richer. Pure combat depth, competitive ladders, grind for grind's sake do not.

## 2. The economy

### Principles

1. **One ledger, many doors.** Every pound still moves through `Wallet` and `Purse`. New systems are new doors on the same room, never new purses.
2. **Place sets the price.** Where you are should change what things are worth. That single rule produces trading, seasonal demand and regional character without a hundred special cases.
3. **Friction is the game.** Fares, spreads, gluts, perishables, bag limits. Arbitrage must exist and must be work.
4. **Sinks with meaning.** The late game needs things worth being rich for, and they should be things the story already cares about: land, people, places.
5. **Scale by par, not by level.** Every number keys on badges or `ParLevel`, the way `Jobs.money_for` and `Punt.LIMIT_PER_BADGE` already do, so the economy stretches from a £500 purse in Macclesfield to six figures after the Moot without any table rewriting.

### 2a. The Trade Ledger (regional prices)

A new pure-logic module `core/trade.gd`, built like `Markets`: seeded, per in-game day, nothing to save except what the player did.

`price(item, town, day)` = base price (from `data/items`) × **regional factor** × **seasonal demand** × **glut** × **standing**.

- **Regional factor** lives in a new `data/trade.json`: each material, dish and regional item has a `home` region (where it is cheap, 0.6) and `wants` regions (where it is dear, 1.6 to 2.2). Arbroath smokies are cheap in Fife and dear in Cardiff. Peat is worthless in Donegal and wanted in Bath. Everything else sits at 1.0.
- **Seasonal demand** reads `Calendar` and `data/festivals.json`: coal and sloe gin up in winter, strawberries at Wimbledon time, anything orange in the fortnight before Halloween, fireworks before Bonfire Night. A festival town pays double for its festival's things in its date window. This is already half-authored: the festivals know their dates and their towns.
- **Glut** is the friction that stops the loop being a tap: every sale in a town records `trade_glut_<town>_<item>` (count, day); the price falls 8% per unit sold and recovers over three in-game days. Ten crabs sell well in Bath. The eleventh does not.
- **Standing** gives the sell-side the discount tiers already give the buy-side (`Standing.DISCOUNT`): locals get a better price from locals.

**Where the player meets it.** Not in the corner shop. Every town with a real market gets a **Market Hall** (Leeds Kirkgate, Cardiff Central, Cork's English Market, St George's in Belfast, Barras in Glasgow, Bury, Chesterfield: about 25 towns, all real and mostly already enterable rooms) with a stall-holder who buys produce at the Ledger price and sells a few regional goods at theirs. The corner shop keeps its flat half price, so a casual player never has to care. The Market Hall also displays "best price in the Isles today" for each item you hold, nation by nation, so the player learns that fish is dear inland without a spreadsheet. The wireless gets a Monday "Market Report" alongside the Shipping Forecast.

**Perishables.** Fish, dairy and fresh forage carry a `keeps` value in days; the bag stamps the in-game day when they arrive (new per-item flag, missing means fresh, so old saves are fine). After `keeps` days they become "a bit off": sellable at a quarter, or cooked (the kitchen does not mind). This is what makes the fishing boat and the chippy a chain rather than a pile.

**Bag limits.** A stack cap of 30 for trade goods. A **Trader's Pannier** (key item, bought in Shrewsbury, £2,000) lifts it to 99. First sink.

**The numbers' shape.** A good route early on (Buxton Bakewell puddings to Manchester, train fare £40) clears £150 to £300 on a full stack. Mid-game, smokies from Arbroath to Dublin with the euro in your favour, £1,500. Post-game, overseas goods (section 2d) £10,000 a run but needing a flight, a bureau, and a two-day round trip in which Doggerel could do anything. That tracks the purse at each stage, and never beats a Keeper's prize money for the time spent, so trading stays a choice rather than the optimum.

### 2b. Businesses: the Deeds

The big sinks and the long game. A **Deed** is a property the player buys, supplies and collects from. Five archetypes, each in two or three real places so the player chooses where to settle:

| Deed | Where | Cost (badges 3 / 6 / post) | Input | Output |
|---|---|---|---|---|
| **The Chippy** | Whitby, Blackpool, Portrush | £4k / £9k / £25k | fish (Ledger or your boat), potatoes (shop) | daily takings; a free fish supper heals the team |
| **The B&B** | Keswick, Portree, Dingle, Tenby | £6k / £14k / £40k | nothing to supply; takings depend on weather, season, festivals and your Gazetteer count for the region (you know the walks) | takings; a bed that resets daily rematches early |
| **The Market Stall** | moveable: pitches at the day's County Show (`core/tournament.gd`) and in any Market Hall | £1.5k, the cheapest, the one Mum suggests | goods you stock it with | sells at Ledger price while you are away, slowly, no glut |
| **The Boat** | Whitby, Stornoway, Dingle, Grimsby | £8k / £18k / £50k | a skipper's wages, bait (nettles, seaweed) | a daily catch of fish and sea materials, better with a brook or tide creature aboard; a storm loses the catch, never the boat |
| **The Allotment** | an extension of `world/home_garden.gd` | £800 | seeds | the garden already does this; the Deed adds plots in three more towns and the Allotment Show (section 4) |

Mechanics shared by all Deeds (`core/deeds.gd`, flags `deed_*`):

- **Takings** accrue per in-game day, computed from a seeded walk like `Markets` so there is nothing to save but the last collection day. Season, weather (`world/forecast.gd`), the real festival calendar and your standing in that nation each move the day's takings; the rewilding site in that nation at Wild adds a "tourists came for the ospreys" bonus. The wireless mentions a good day.
- **Collection** in person or **by post**: at Regular standing a manager posts takings to any post box (`world/post_box.gd` already routes Kit's postcards), minus their cut.
- **Managers** are recurring NPCs you have befriended (section 3). A Deed with no manager earns while you are in that nation only. That ties the people system to the money system without a tutorial.
- **Events**, one in ten days: a health inspection (pass if you hold the right dish recipe), a coach party (double), a rival chippy opening (takings down until you win a fish supper cook-off), a storm. Each is a two-line scene, never a blocker.
- **Rates.** Each Deed pays council rates on the first of each real month, taken from takings, with a letter from the council that is slightly too pleased with itself. Rates rise with the Deed's upgrade level, so a chain of upgraded chippies has running costs and the number on the pause card is honest.
- **Upgrades** (a fryer, a conservatory, a bigger net) are the sink that keeps scaling: each tier costs about the next Keeper's total prize pool and lifts takings by 40%, so the return on the last upgrade is always about 20 in-game days. Break-even on a fresh Deed: 12 to 18 in-game days, five to seven hours of play.

### 2c. Credit, rates and the taxman

- **The Macclesfield and District Building Society** (one room, a woman named Pat who has seen it all). From badge 2 the player can borrow up to a badge-scaled cap (`500 + 1,500 × badges`), at 1% per in-game day, repayable at any branch (every Sanctuary town has one, as every town has a noticeboard). Pat shows the full cost of the loan over 10, 20 and 30 days before you sign, which is the whole lesson in compound interest. Three missed days and Pat sends a letter; ten and a bailiff NPC (Mr Clegg, apologetic, fond of his pigeons) stands outside your nearest Deed and takes the takings until you are square. Standing in that nation drops a tier. Nothing is ever repossessed; the game is not that kind of game.
- **His Majesty's Revenue and Creatures.** Once per real year, in the first week of April, a brown envelope at any post box: a self-assessment on last year's Deed takings and share dividends, in three bands with a personal allowance, settled from the purse with a joke about the 31 January deadline. The Republic's Deeds get a green envelope from the Revenue Commissioners in euros. The tax is 10 to 20% of passive income, enough to notice, never enough to hurt, and it only exists once Deeds do, so no early save ever sees it. (Euros are already a separate purse; this is a dozen lines in `Wallet`.)
- **Mum's loan.** Before Pat, a £300 sub from Mum at 0% to buy the Market Stall, paid back in instalments "when you're flush". The first time the player meets debt it is kind.

### 2d. Many currencies, with friction

3.3 brings eighteen territories whose real currencies are "mentioned in dialogue". The next step is to make them real in the one place it is fun: **the bureau**. `Wallet` grows from two purses to a currencies dictionary (`data.purses`, defaulting from `money` and `euros` so every old save loads unchanged) and `Forex` grows from one pair to a small table, each a seeded walk against sterling:

- **At-par pounds** (Gibraltar, the Falklands, St Helena, Jersey, Guernsey, Manx) are the joke that teaches: worth exactly a pound on their islands, and a corner shop in Macclesfield gives you the tourist rate for them. "That's a Manx fiver, love. Lovely picture of a cat. I can't take it."
- **Dollars** (USD in the BVI and Turks and Caicos, Cayman dollars, Eastern Caribbean dollars) float properly. Overseas goods (conch, Bermuda onions, Falklands wool, Tristan lobster) are post-game Ledger items with "wants" all over the Isles, bought in local money.
- **Doggerel** stays exactly as it is, except that the Caribbean kiosks quote it in dollars, so a determined player can triangulate. The `MarketSim` harness (`core/market_sim.gd`) gets a `fx_triangle` strategy to prove it does not print money after spreads.

### 2e. Sinks worth being rich for

The post-game needs a reason to earn, and the story has left one lying there. **The Enclosure's leases.** Lord Vane's company spent the game fencing the countryside; after the credits its leases come up at auction, nation by nation, at the Exchange. Each lease is a real tract (a grouse moor, a fenced beach, a shut footpath, a drained fen), priced from £30k to £150k, and buying one **opens it**: a small new zone of three to six screens with a rare creature, a plaque or two and a ranger who thanks you. Six per nation over time, each one a brief-sized job for a cloud agent. The Exchange's existing Vane shock (`Markets` story events) means a player who shorted Vane on the day of the Moot has the money for the first one. Smaller endowments sit underneath: fund a museum wing (a new room with three plaques), sponsor a rewilding site's next stage with money instead of materials, buy the pub quiz league trophy, pay for a town's Christmas lights (the town is dressed, `world/seasonal.gd`).

### 2f. What it teaches

Each mechanic carries one idea, said once, by someone with a reason to say it: supply and demand (the Market Hall board), arbitrage and friction (the pannier and the fares), spreads (Pat, and the bureau already does this), compound interest (the loan schedule), diversification and dividends (the Exchange, already), sunk cost (the Palace), tax bands (the envelope), rates (the council), inflation (the Ledger's base prices drift up 0.1% per in-game day, so a cup of tea costs more after the Moot than at the start, and Mum remarks on it). A short "Money Box" slot on the wireless (the pattern is `TodaysWalk` on the Shipping Forecast) gives a one-line plain-English explainer once a real day. No glossary screen. If the player never listens, they still have a chippy.

## 3. Depth behind doors

### Rooms with a reason

Give the 500 rooms a small number of **reusable mechanics** rather than bespoke content each:

- **Examine spots.** A `examine` prop (like `forage` and `noticeboard` in `world/forage.gd` and `world/noticeboard.gd`) with a line of flavour and sometimes a find: a coin behind the clock, a note, a key, a clue. One per room, authored in bulk by agents, makes every room worth a second look.
- **Locked doors and keys.** Interiors already warp between rooms; a `warp` gains an optional `needs` flag or item. Keys come from examine spots, quests and NPCs who trust you. The Chester Rows get an upstairs; York's snickelways join up; Edinburgh's Mary King's Close opens under the Royal Mile.
- **Secret rooms.** Rooms that only show once a flag is set are already how blockers work (`hide_if`). Apply it to warps: the priest hole at Speke Hall, the crypt under St Pancras, the Williamson Tunnels in Liverpool.

### Deep Places

A kit in `world/zone_builder.gd` for multi-floor interiors with puzzles that use what the player already has: the Lantern (`FieldMoves.LIGHT_LANTERN`) in dark levels, Brook-wade for flooded passages, a kin creature to push, a storm creature to charge an old dynamo. Puzzle vocabulary kept to four: lever and gate, weight on plate, light and dark (lantern radius), and water level. Six **Deep Places**, one per nation, each 20 to 40 minutes, each real: Blue John Cavern and the Peak lead mines; Big Pit at Blaenavon; the Edinburgh vaults; the Marble Arch Caves in Fermanagh; Newgrange's passage at the solstice (date-gated, `Calendar`); Castle Rushen's dungeons on Mann. Each ends with a creature nobody has seen, a plaque, and something for a Deed (the mine's gear for the boat's winch).

### Investigations: the Casebook

A mystery arc per nation, 8 to 12 steps, built on flags like quests but with **evidence items** and **red herrings**. A new Fieldbook tab, the Casebook, next to Rumours and the Gazetteer (`ui/rumours_tab.gd`, `ui/gazetteer_tab.gd` are the pattern): the clues you hold, the people you have asked, and a "who do you accuse" prompt at the end. Wrong accusations cost standing and close one line of enquiry; right ones pay money, a lease discount, and a recurring character. Cases fit the land: who is poisoning the Mersey otters (the Enclosure, but not the obvious director); the Loch Ness photograph fraud of 1934, re-run; the stolen Stone of Scone, a long story.

### Regulars and relationships

Recurring characters with a **favour** flag (`favour_<id>`, 0 to 5) rather than a romance meter: a dozen people across the Isles who turn up again. Favour rises by doing their jobs, sharing a dish they like (the dishes system already knows regions), remembering their birthday (the calendar). At 3 they write to you (the postcards pipeline); at 4 they will manage a Deed; at 5 they have a scene at Mum's. The side-story pattern (`SideStories.npcs_for`) is already "an NPC the overworld adds to a zone while a flag is waiting": regulars are that pattern with a counter.

### Guilds

Standing per nation stays as the measure of belonging. **Guilds** are the measure of calling, and a few of them conflict:

- The **Ramblers** (plaques read, footpaths walked, leases bought), the **Anglers** (fishing), the **Naturalists** (Garside's lot, the Fieldbook), the **Folk Club** (shanties, the brass band, the bell tower), the **Traders' Guild** (Ledger profit), and the **Heritage Trust** (which is to say, Vane's successors: tidy, well funded, and they want the moor fenced again for the grouse).
- Each has three ranks, earned by doing, with a perk per rank (the Anglers' second rod, the Traders' pannier at half price). Joining the Trust locks the Ramblers' top rank and vice versa, and the lease auctions go differently depending on which side you are on. One real choice with consequences, flagged in advance, reversible at a cost (you can resign, and they remember).

### Trades: the player's own progression

Not a skill tree. Six **Trades** (Rambler, Naturalist, Trader, Angler, Cook, Showman), each with a level 1 to 5 read **off the Stats counters** that already exist (`TrainerStats.COUNTERS` gains a few: fish landed, goods sold, dishes cooked, shows won). No points to spend, nothing to respec, nothing a casual player can get wrong: do the thing, get better at it. Each level is a small perk in that thing (Rambler 3: rail fares down a fifth; Cook 4: dishes keep twice as long; Trader 5: see every Market Hall's prices from the map). The Stats page becomes a Trades page with the same numbers and a title under the player's name.

### Long arcs

One per nation, 10 to 15 steps, woven through the Deeds, the Casebook and the guilds so the systems meet: Wales's arc is about the Big Pit, the Valleys' choirs and whether the Trust reopens the mine as a theme park; Ireland's follows the Wild Atlantic Way boat by boat. These are the briefs the region agents already know how to write (`docs/briefs/wave21.md`), only longer and with the new verbs.

## 4. Minigames and activities

Each one is listed with what it feeds. Nothing is bolted on; if it has no second row it is cut.

| Activity | What it is | What it feeds |
|---|---|---|
| **Fishing** | A rod, a float, a bite timing bar; water tiles on every route and from the boat. Catches are fish items (Ledger goods) and sometimes a water creature (encounter table, `world/encounters.gd`). Rods and bait upgrade. | The chippy, the Ledger, the Anglers, the Angler trade, three creatures only caught on a line |
| **Darts** | 501 in every pub, a wobble-and-release aim. Play the regular for a stake (through `Purse`, under the daily limit). | Pub money, standing, the pub quiz league's social half |
| **Pub quiz league** | The existing quiz (`core/pub_quiz.gd`) gets a season: nine pubs, a Thursday real-date fixture, a table, a trophy, a cup final in Dublin. Questions stay; the structure is new. | Standing, Folk Club, the league trophy endowment |
| **Bowls** | Crown green in Lancashire, flat green in the south: a rolling aim-and-weight game against a pensioner who cheats. | Standing, a summer-only job line |
| **Sheepdog trials** | Your kin creature herds sheep through gates on a timer (the show ring, `world/show_ring.gd`). | County Show rosettes, the Royal Welsh and Highland shows, a creature's bond |
| **Allotment show** | Bring your best veg from the garden plots; judged on size, which is season, soil and a fertiliser recipe. | Garden, crafting, the Allotment Deed, a rosette line |
| **Bell ringing** | Change-ringing as a short sequence puzzle in cathedral towers (York, Durham, St Patrick's). Rings open the tower room above. | Secret rooms, Folk Club, a frost creature that lives in belfries |
| **Crabbing** | Whitby, Dingle, Tenby harbour walls: a bait-and-wait with a bucket. Child-simple, three minutes, seasonal. | Ledger goods, a job line, the chippy's crab sandwich recipe |
| **Conkers** | Autumn only, outside any school: a best-of-three timing duel. | Standing, the Folk Club, a conker charm |
| **Highland games** | Caber (hold-and-release timing) and tug of war (your brawn creature's attack stat with a rhythm tap) at Braemar and Oban. | Standing in Scotland, a Showman rank, prize money |
| **Hurling and shinty** | Not a sport sim: a penalty shoot-out style one-screen game at Croke Park and Fort William, with the rules explained by the goalie. | Standing, the GAA's job line, the Ireland arc |
| **Sea shanties** | A rhythm game on the ferries (`world/journey.gd` already plays the crossing). Four shanties, real ones out of copyright. | Folk Club, cheaper crossings when the crew likes you |
| **Drystone walling** | A tetris-ish fit-the-stones puzzle on rewilding sites and lease land. Wall built, land protected, grazing stops. | Rewilding stages, the Ramblers, a job type |
| **Crossword** | A real-date mini crossword in the local paper, 6 by 6, from the quiz bank's facts (`data/quiz/questions.json`). | A daily, Trades (Naturalist), the Casebook sometimes hides a clue in it |

Cut from consideration: snooker (needs a physics table to feel right and the Palace already covers the "club" mood), brass band (the music pipeline is note lists in `tools/music/`, a rhythm game over it is possible but the sea shanties cover the slot), football management (too big, too licensed).

## 5. RPG systems worth borrowing

- **Creature jobs in the overworld.** The follower (`world/follower.gd`) is cosmetic; let the lead's type do a small thing: a brook creature doubles fishing bites, a night creature is a lantern, a kin creature herds and carries (bag cap +10), a storm creature charges the Deep Places' dynamos, a spirit creature sees examine spots glow. This is "party roles" at the level Wildlore can afford, and it is a reason to change the lead without battle in mind.
- **NPC routines.** `Npc` already keeps hours (`times`). Add a weekly rhythm on the real calendar: market on Saturday, the pub fuller on Friday night, church bells on Sunday morning, the bank shut at the weekend (Pat is at the bowls). The world should feel like it would carry on without you.
- **Consequences.** The guild choice (Ramblers or Trust), the Casebook accusations, the loan. Each is flagged before it lands and each has a way back that costs something. Nothing is a hidden fail.
- **Post-game arcs rather than endings.** The ending stays one ending; the epilogue is plural. After the Moot the wireless reads out a "Year in the Isles" each real New Year's Day from the Stats, the Deeds, the leases and the guild: what you own, who you are to each nation, what came back to the land. A second-year player and a twentieth-year player get a different bulletin.
- **The Ark as a reserve team** with roles: creatures in the Ark can crew the boat or mind the stall, so a full Fieldbook is useful, not just complete.

## 6. Roadmap

Four releases. Each is a theme, not a list; each feature says S/M/L (an afternoon, a day, several days for one agent), its dependencies, and whether it can run as an independent cloud session. Order inside a release is the order to merge.

### 3.4 Market Day (the economy's floor)

1. **Trade Ledger** (`core/trade.gd`, `data/trade.json`), regional prices, glut, perishables, pannier. L. Depends on nothing. *Session: "Build the Trade Ledger: place-set prices for materials, dishes and regional items."*
2. **Market Halls**: 25 real halls as rooms with a stall-holder, the price board, the sell flow. M. Depends on 1 for prices, but the rooms can be built first. *Session: "Author 25 real Market Halls as interiors, one per listed town."* Parallel.
3. **Money Box** on the wireless plus the Monday Market Report. S. Depends on 1. Fold into session 1.
4. **The Building Society**: Pat, loans, letters, Mr Clegg, Mum's sub. M. Depends on nothing. *Session: "Loans with honest compound interest."* Parallel.
5. **Trades page**: six trades read off `TrainerStats`, perks for Rambler, Trader, Cook. M. Depends on nothing (Angler waits for 3.5). *Session: "Turn the Stats page into Trades."* Parallel.
6. **Fishing** (the minigame, rods, fish items, line-only creatures). L. Depends on 1 for prices. *Session: "Fishing on every water tile."* Parallel after the Ledger's item list is agreed in the brief.
7. **Multi-currency purses** in `Wallet`/`Forex`, bureau table, at-par notes gag. M. Depends on 3.3 landing. *Session: "Real overseas currencies at the bureau."* Parallel.

Cut from 3.4: the Market Stall Deed (it is a Deed, wait for 3.5), inflation drift (do it in 3.5 once Deeds give the purse a reason to be big).

### 3.5 Open for Business (the Deeds)

1. **Deeds core**: buy, takings walk, collection, events, rates, upgrades, pause-card line. L. Depends on 3.4's Ledger. *Session: "The Deeds system, with the chippy as the reference Deed."*
2. **The B&B, the Boat, the Stall, the Allotment**: one session each, writing their rooms, NPCs, events and upgrade tiers to the Deeds contract. M each. Depend on 1's contract (publish it in the brief first, as wave 21 did with quests). Parallel, four sessions.
3. **Regulars**: twelve recurring characters, favour, letters, managers. L. Depends on 1 for the manager hook. *Session: "Twelve regulars who remember you."*
4. **HMRC letter, Revenue letter, rates.** S. Fold into 1.
5. **Darts and crabbing.** S each. No dependencies. One session, both.
6. **Allotment Show** and **sheepdog trials** in the show ring. M. Depends on the Allotment Deed. *Session: "Two show-ring events."*
7. Inflation drift and the `MarketSim` strategies for trade and Deeds (prove nothing prints money). S. Fold into 1.

Cut: the fishing boat's weather routing (a storm simply loses the catch), the chain of three chippies (one Deed per archetype per save; upgrades carry the scaling).

### 3.6 Behind Doors (depth)

1. **Examine spots, locked warps, hidden warps** in `zone_builder`, plus a bulk pass adding one examine line to 300 rooms. M for the kit, L for the pass, split: *Session: "The examine kit"* then *Sessions: "Examine lines for England / Wales / Scotland / Ireland and NI"* in parallel.
2. **Deep Places kit**: the four puzzle verbs, multi-floor caves. L. Depends on 1. *Session: "The Deep Places kit, with Blue John as the reference."*
3. **Five more Deep Places.** M each, parallel, after 2's kit lands. Five sessions.
4. **Casebook tab and two cases** (Mersey otters, Loch Ness). L. Depends on 1 for evidence spots. *Session: "The Casebook."* Then four more cases in parallel later.
5. **Guilds** with ranks, perks, the Ramblers versus Trust choice. M. Depends on Trades. *Session: "Six guilds and one real choice."*
6. **Creature jobs in the overworld.** M. Depends on nothing; needs fishing for the brook perk. *Session: "Your lead creature does a job."* Parallel.
7. **Bell ringing and drystone walling.** M. Depends on 1 and the rewilding hooks. One session.

Cut: NPC routines (push to 3.7; they are polish and touch a hot file).

### 3.7 The Long Game (post-game and the land)

1. **The Enclosure leases**: the auction room at the Exchange, the contract for a lease zone, two reference leases. L. Depends on Deeds (money) and guilds (the Trust's bids). *Session: "Lease auctions and the lease-zone contract."*
2. **Lease zones**: six per nation over time, each a region-agent brief. M each, parallel, open-ended.
3. **Pub quiz league, Highland games, hurling and shinty, sea shanties, conkers, crossword.** S to M each. No dependencies. Three parallel sessions of two each.
4. **NPC routines on the weekly calendar.** M. Touches `world/npc.gd`; one session, no parallel.
5. **Year in the Isles** epilogue bulletin. S. Depends on everything, which is the point. Last.
6. **The six nation arcs** (10 to 15 steps each) using every verb above. L each, parallel, six sessions, the last thing.

Cut for good: multiplayer and trading between players stay on the long-term list in `docs/ROADMAP.md`; nothing here depends on them.

## 7. Risks

- **Balance.** Three new money faucets (Ledger, Deeds, fishing) against existing sinks. The guard is the harness: `core/market_sim.gd` already plays 1,000 seeded playthroughs against the markets. Extend it with Ledger, Deeds and loan strategies, and make the test assert that no strategy beats the main line's prize money per hour by more than 1.5× before the Moot, and that nothing compounds without a cap. Every number keys on badges so the early game cannot be flooded.
- **Scope creep.** This document is the scope. Each release ships whole systems, not halves; the cuts are named. If a release slips, cut the parallel content sessions (more Deep Places, more cases, more leases), never the kits, because the kits are what later contributors build on.
- **Saves.** The rule from `docs/briefs/qol_common.md` holds: every new field is a flag with a safe default or a `from_dict` default. `Wallet` keeps `money` and `euros` as the fields of record and derives the purses dictionary. Trade, Deeds, loans, favour, guilds and cases are all `flags`. Nothing here needs a save version bump; a 1.0 save loads with no Deeds, no debt and a shop that still buys at half price.
- **Performance.** All new logic is pure and per-day, seeded, like `Markets` (nothing simulates per frame). Market Halls and Deep Places are ordinary interiors. Examine spots are props, not nodes until looked at. Fishing and the minigames are 2D UI scenes over a paused overworld, like the casino screens (`ui/casino_base.gd`). The 2013 iMac budget is not touched.
- **Accessibility for casual players.** The corner shop, half-price selling, the main line and the daily loop are untouched. Every new system is behind a door with a person in front of it who explains it once; nothing is required for the credits; the Trades level themselves. Minigames have a "let the regular win" exit that costs only pride.
- **Facts.** Market Halls, Deep Places and lease tracts are real places; the briefs keep wave 21's rule, accurate or omitted, and the Casebook's historical cases are told as fiction set around true events. Economics explainers are checked against a textbook, not a vibe.
- **IP.** Nothing here borrows a Pokémon noun. Deeds, Ledger, Trades, Casebook, guilds and leases are the game's own vocabulary; the creature-jobs idea is older than Pokémon (it is Ultima's). Keep "Fieldbook", "Sanctuary", "snare", "Stone" and never drift towards their counterparts.
- **Contributors.** The wave briefs work because they are contracts: a data shape, a flag namespace, a shared-file rule, a test, a time box. Every "Session" above should be written the same way, with the kit landed before the content agents start, and hot files (`Wallet`, `Markets`, `zone_builder`, `npc.gd`, `commands.gd`) edited by one session per release. Publish each release's contract in `docs/briefs/wave<nn>.md` before any agent is spawned.

## 8. The name

### Does "Wildlore" work?

What it gets right: two real words, spelt as said, no apostrophes, says creatures ("wild") and legends ("lore") in one breath, and it is neutral across the four nations and Mann, which was the brief when it was chosen.

What it gets wrong, now the game is what it is:

- **It is generic fantasy.** "Lore" is the most overworked syllable in indie games (Lorestone, Loreweaver, Lore Finder) and "Wild" the most overworked prefix (Wildfrost, Wildermyth, Wild Hearts, WildStar, Wild Arms). Put together they read as a survival-crafting game or a tabletop supplement, and the name gives no hint of the thing that is actually distinctive: that it is set in real Macclesfield, real Lerwick, real Stanley.
- **It says nothing about the UK and Ireland,** nothing about travel, nothing about money, nothing about the humour. A stranger reading "Wildlore" expects a forest and a bestiary. They get a chippy and a building society.
- **Searchability is middling.** "Wildlore" and "Wild Lore" are almost certainly in use by small businesses, a tabletop project or two and probably an itch.io game (I cannot verify, and I would put this at likely rather than certain). It is not a word you own.
- **Memorability is fine, distinctiveness is low.** People will remember it; they will also confuse it with three other things.
- It does fit the creature half of the game and it is already the name of the repo, the save folder, the app bundle and the CI badge, which is a real cost to changing.

Verdict: it is a good name for the game this was in 1.0 and a weak name for the game it is in 3.3. The right move is not necessarily to drop it; it may be to **demote it** to the world or series name and put something with a sense of place on the front.

### Longlist

Place-y: These Isles, The Isles, Archipelago, Four Nations and a Bit, Off the Beaten Track, Right of Way, Footpath, Fingerpost, Hedgerow, Bank Holiday, A Decent Walk, Rain Expected, Pathways, The Long Way Round, Cat and Fiddle, Ordnance (clashes with Ordnance Survey; no), Shipping Forecast (BBC; no), Mind the Gap (TfL; no).

Wry: Somebody Has To, Get Up Early Enough, Legends Expected, Rain Later, Good, Pleasant Weather for Dragons, Bring a Flask, Any Other Business, Nothing to Declare, Mostly Harmless (Adams; no), Sorry, Lovely.

Compound: Hedgelore, Islelore, Landlore, Fellwander, Wanderfolk, Wayfolk, Moorfolk, Hedgefolk, Folkwild, Wildgazetteer, Fieldbook, Lorelands.

Celtic, Old English and Norse roots (glossed): Cynefin (Welsh, roughly "the place you belong, your habitat"), Hiraeth (Welsh, longing for a home you cannot go back to), Dúchas (Irish, heritage, native place, birthright), Tír (Irish and Gaelic, land), Ynys and Eilean (Welsh and Gaelic, island), Innis, Folkmoot (Old English, the people's assembly), Wold (Old English, high open country), Holm (Norse, small island), Garth (Norse, enclosure, which is pointed given the plot), Wyrd (Old English, fate), Ellan Vannin (Manx, the Isle of Man), Albion (excludes Ireland and belongs to Fable; no), Prydain (Lloyd Alexander; no).

Puns on Britain, isles, kingdom, commonwealth: Common Wealth, The Beastly Isles, Great Beasts of Britain (excludes Ireland; no), United Creatures, Monster Kingdom (Pokémon-adjacent; no), Isles of Wonder (the 2012 Olympic ceremony; no), Critterish Isles, Realm and Commonwealth, A Common Wealth of Creatures.

Short brandable: Hedgerow, Bramble, Tussock, Drizzle, Haar, Fellsong, Moorlight, Wold, Garth, Holm, Fieldbook.

### Shortlist

**1. These Isles**
*Meaning.* The phrase British and Irish diplomats reach for when "the British Isles" would offend: it includes Ireland without claiming it, covers Mann, the Channel Islands and Shetland by default, and stretches to the overseas territories without strain (they are islands, nearly all of them). *Why it fits.* It names the thing the game is actually about, the archipelago, and does it with the understatement the whole script runs on. *Tone.* Warm, dry, a little proud. *Risks.* "These Islands" is a UK unionist think tank (founded 2017); "These Isles" is close but not the same and I am fairly sure there is no game of that name (not certain). The phrase is generic enough that nobody can own it, which cuts both ways. Not Pokémon-ish at all. *Logo and subtitle.* Hand-lettered over the game's own map silhouette; "These Isles: a Wildlore" or "These Isles, a Wildlore adventure". *Domain and handles.* theseisles.com is likely taken or parked; theseisles.game, theseisles.co.uk and @theseisles are plausible. Unverified.

**2. Right of Way**
*Meaning.* A public footpath you are legally allowed to walk, and the thing the Enclosure spent the story fencing off. *Why it fits.* Travel, access, the countryside, the rewilding and lease plots, and a wink at the ramblers who would play this. The economy is implied (it is a game about who owns what). *Tone.* Wry, confident, very British, meaningful in Ireland too. *Risks.* A common phrase in road law and real estate; there is almost certainly a board game, an app or a short film called Right of Way somewhere (unsure which). Low trademark risk in games specifically, as far as I know; not Pokémon-ish. *Logo and subtitle.* A green fingerpost with a creature sat on it; "Right of Way: a Wildlore across the Isles". *Domains.* rightofway.com is gone; rightofway.game or rightofwaygame.co.uk plausible. Unverified.

**3. Hedgerow**
*Meaning.* The British and Irish thing itself: a living boundary full of creatures, and already a creature type in the game. *Why it fits.* Creature-forward without a monster word, says countryside, says "look closer", and the Hedgerow Year is already a feature. *Tone.* Gentle, warm, a touch Watership Down. *Risks.* A plain noun; small products, a pub chain or a wine will have it; I would be surprised if a well-known game did. Not Pokémon-ish. It says less about travel and nothing about money or the sea. *Logo and subtitle.* A hedge in silhouette with eyes in it; "Hedgerow: Wildlore of the Isles". *Domains.* hedgerow.com taken; hedgerow.game or hedgerowgame plausible. Unverified.

**4. Cynefin**
*Meaning.* Welsh, glossed in game as "the place you belong". The identity line in one word. *Why it fits.* It is the theme, exactly, and it is from one of the game's own languages. *Tone.* Serious, lovely, quietly proud. *Risks.* Pronunciation ("kuh-NEV-in") will put off English and Irish players and the game would have to teach it on the title screen; the Cynefin framework is a trademarked management-consulting method (Cognitive Edge, Dave Snowden), and Cynefin is also the name of the new Welsh school curriculum strand, so search is crowded and the mark is held in at least one class. Welsh-centric for a pan-Isles game. Better as a chapter or a Welsh arc title than as the box name.

**5. Common Wealth** (two words)
*Meaning.* Wealth held in common: the commons, the land, the standing you earn. *Why it fits.* The economy ask and the rewilding theme in a single pun; 2.0 was already called Common Ground. *Tone.* Wry, a little political. *Risks.* The Commonwealth of Nations, the Commonwealth Games and the 1649 Commonwealth all sit on it; it reads as bigger than the Isles and as a different kind of game (a civ, a strategy). Not Pokémon-ish. Searchability bad.

**6. Folkmoot**
*Meaning.* Old English for the people's assembly; the game already has the Moot at Stonehenge. *Why it fits.* Short, odd, memorable, creatures as folk, the Moot as the climax. *Tone.* Earthy, slightly heathen. *Risks.* Folkmoot is a long-running folk festival in North Carolina with the name and the web presence; "moot" reads as "irrelevant" to many English speakers. Not Pokémon-ish. A good name for the tournament, not the game.

**7. Fieldbook**
*Meaning.* The naturalist's notebook, already the game's dex. *Why it fits.* Says "learn, look, record", which is half the game. *Risks.* It is the Pokédex seat and will be read as such (flag: Pokémon-ish by structure, not by word); Fieldbook was also a spreadsheet-database app (shut in 2018) and the name is generic. Keep it as the dex, not the box.

**8. Bank Holiday**
*Meaning.* A day off, and a bank. *Why it fits.* The walking-holiday identity and the economy in two words, and it is funny. *Risks.* It says nothing about creatures or place, search is hopeless, and the joke wears thin on a title screen seen three hundred times. A fine name for the economy release (3.4 could be "Bank Holiday" rather than "Market Day").

### Recommendation

**Top: These Isles**, with **Wildlore kept as the world and series name**, so the full title is "These Isles: a Wildlore" (or "Wildlore: These Isles" if the repo, saves and the CI badge should keep the first word). It names the real subject, it is inclusive of Ireland in the way the Irish themselves phrase it, it stretches to Stanley and Jamestown, it sounds like the script, and demoting rather than deleting Wildlore keeps every existing asset, repo, save path and memory honest. Nothing about it sounds like Pokémon.

**Runner-up: Right of Way**, if the owner wants a name with a joke in it and a point: it is the plot, it is the ramblers, and it would make a better logo. Use "Hedgerow" instead if the creatures must be in the name.

Whatever is chosen, keep "Wildlore" as the series or world name rather than retiring it: the Fieldbook can still be "the Wildlore of these Isles", the repo stays `wildlore`, and the rename is a title screen, a README line and an app bundle name rather than a migration.
