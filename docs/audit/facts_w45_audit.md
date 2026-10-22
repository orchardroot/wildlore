# Facts audit, wave 45 (session S)

Accuracy audit of existing player-facing facts: zone plaques (`signs`, `examine`), item descriptions (including the Gazetteer key items), `data/festivals.json`, quest text in `data/quests/` and the language data in `data/lang/` (places, greetings, phrases).

Texts checked: 4,091 strings (4,002 unique) extracted with python from 1470 zone files, 25 festivals, the quest files, the item files and 7 language files. Jokes and game fiction were skipped.

Fixes made: 50 by session S, then 41 more by session V from the doubts below. Open doubts left: 6 (for the owner).

## Fixes made

### `data/zones/armboth_forest.json#signs/0/text`
- Before: THIRLMERE. In 1879 Parliament let Manchester Corporation dam Thirlmere in the Lake District and send its water to the city by aqueduct, under the Manchester Waterworks Act. Two hamlets went under. The scheme was bitterly opposed, and the Thirlmere fight helped start the national fight for the Lakes and, in time, the National Trust.
- After: THIRLMERE. In 1879 Parliament let Manchester Corporation dam Thirlmere in the Lake District and send its water to the city by aqueduct, under the Manchester Corporation Water Act. Two hamlets went under. The scheme was bitterly opposed, and the Thirlmere fight helped start the national fight for the Lakes and, in time, the National Trust.
- Why: The 1879 Thirlmere act was the Manchester Corporation Water Act 1879.

### `data/zones/armboth_forest.json#signs/3/text`
- Before: OSPREYS. Persecuted out of England and wiped out in Britain by 1916, ospreys began returning to Scotland in the 1950s. In 2001 a pair nested in the Lake District for the first time in about two hundred years, at Bassenthwaite Lake. Wardens guard the nest, and the public watches through telescopes with enormous respect.
- After: OSPREYS. Persecuted out of England and wiped out in Britain by 1916, ospreys began returning to Scotland in the 1950s. In 2001 a pair nested in the Lake District for the first time in over 150 years, at Bassenthwaite Lake. Wardens guard the nest, and the public watches through telescopes with enormous respect.
- Why: The 2001 Bassenthwaite pair was the first Lake District breeding in over 150 years (RSPB / Lake District Osprey Project).

### `data/zones/aberdeen.json#signs/3/text`
- Before: THE MARITIME MUSEUM. A whole offshore oil rig in a hall, a model of a clipper ship called the Thermopylae and a very sensible hat.
- After: THE MARITIME MUSEUM. A towering model of an offshore oil rig, a model of a clipper ship called the Thermopylae and a very sensible hat.
- Why: The Maritime Museum has a multi-storey model of the Murchison platform, not a real rig.

### `data/zones/ascension.json#signs/0/text`
- Before: A speck of volcanic rock in the middle of the South Atlantic, about 1,500 kilometres from the coast of Africa and 2,250 from Brazil. It is named for the day it was first sighted by Europeans, Ascension Day, in 1501. Nobody lived here until the Royal Navy arrived in 1815.
- After: A speck of volcanic rock in the middle of the South Atlantic, about 1,500 kilometres from the coast of Africa and 2,250 from Brazil. Europeans first sighted it in 1501, and it was named when it was seen again on Ascension Day, 1503. Nobody lived here until the Royal Navy arrived in 1815.
- Why: Joao da Nova sighted it in 1501; Afonso de Albuquerque saw it on Ascension Day 1503 and the name dates from then.

### `data/zones/burren.json#signs/1/text`
- Before: CLIFFS OF MOHER. Eight kilometres of sea cliff, up to 214 metres high at the tallest. Nobody has ever been disappointed. A fair few have been blown sideways.
- After: CLIFFS OF MOHER. Fourteen kilometres of sea cliff, up to 214 metres high at the tallest. Nobody has ever been disappointed. A fair few have been blown sideways.
- Why: The Cliffs of Moher run about 14 km (about 8 miles).

### `data/zones/cotswolds.json#signs/12/text`
- Before: A folly built in 1798 for the Countess of Coventry, so that a fire on top could be seen from her house at Worcester, thirty-odd miles away. It stands at the second-highest point of the Cotswold scarp, and on a clear day you can see as many as sixteen counties. William Morris holidayed here, and the Arts and Crafts movement liked the hill's views.
- After: A folly built in 1798 for the Countess of Coventry, so that a fire on top could be seen from her house near Worcester, about fifteen miles away. It stands at the second-highest point of the Cotswold scarp, and on a clear day you can see as many as sixteen counties. William Morris holidayed here, and the Arts and Crafts movement liked the hill's views.
- Why: The Coventrys' house was Croome Court, near Worcester, roughly 15 miles from Broadway Tower.

### `data/zones/dee_valley.json#signs/1/text`
- Before: PONTCYSYLLTE AQUEDUCT. 1805. Eighteen arches, 38 metres up. Boats cross in the sky and nobody bats an eyelid.
- After: PONTCYSYLLTE AQUEDUCT. 1805. Nineteen arches, 38 metres up. Boats cross in the sky and nobody bats an eyelid.
- Why: Pontcysyllte has 18 piers carrying 19 arches.

### `data/zones/derry_towermuseum.json#examine/0/text/0`
- Before: The Siege of Derry lasted 105 days in 1688 and 1689, after the Apprentice Boys closed the gates.
- After: The Siege of Derry lasted 105 days in 1689, months after the Apprentice Boys closed the gates in December 1688.
- Why: The gates were shut on 7 December 1688; the 105-day siege ran from 18 April to 28 July 1689.

### `data/zones/donegal_town.json#signs/9/text`
- Before: MALIN HEAD. Ireland's most northerly point is up at the tip of Inishowen, in this county. It has a weather station, a signal tower and, in 2015, a visit from a film crew making Star Wars, who borrowed the cliffs for a galaxy far, far away.
- After: MALIN HEAD. Ireland's most northerly point is up at the tip of Inishowen, in this county. It has a weather station, a signal tower and, in 2016, a visit from a film crew making Star Wars, who borrowed the cliffs for a galaxy far, far away.
- Why: The Last Jedi filmed at Malin Head in 2016.

### `data/zones/dundee.json#signs/5/text`
- Before: Dundee's own poet, often called the worst in the English language. His poem about the bridge disaster ends 'the strength of the bridge would not have been so frail'. He gave readings; audiences threw peas. He carried on.
- After: Dundee's own poet, often called the worst in the English language. His poem about the bridge disaster ends 'the stronger we our houses do build, the less chance we have of being killed'. He gave readings; audiences threw peas. He carried on.
- Why: Misquote: the real closing couplet of The Tay Bridge Disaster is given.

### `data/zones/enniskillen_castle.json#examine/0/text/0`
- Before: Enniskillen Castle houses the museum of the Inniskilling Fusiliers and the Inniskillings Dragoon Guards.
- After: Enniskillen Castle houses the museum of the Inniskilling Fusiliers and the Inniskilling Dragoon Guards.
- Why: The regiment was the 5th Royal Inniskilling Dragoon Guards.

### `data/zones/dover.json#signs/11/text`
- Before: On 25 July 1909 Louis Bleriot flew across the Channel from Calais in his little monoplane and crash-landed in a meadow just north of the castle: the first flight across the sea between two countries. A memorial in the grass is shaped like his aeroplane.
- After: On 25 July 1909 Louis Bleriot flew across the Channel from Calais in his little monoplane and crash-landed in a meadow just north of the castle: the first aeroplane flight across the Channel. A memorial in the grass is shaped like his aeroplane.
- Why: Balloonists Blanchard and Jeffries crossed the Channel in 1785; Bleriot's was the first aeroplane crossing.

### `data/zones/carlisle.json#signs/0/text`
- Before: THE CURSING STONE. A 14-tonne granite slab, carved in 2001, with words from the curse of 1525 that the Archbishop of Glasgow, Gavin Dunbar, laid on the Border reivers: 'I curse their head and all the hairs of their head; I curse their face, their brain...' and on down to the toes. The curse was 1,500 words long. They were thorough.
- After: THE CURSING STONE. A 14-tonne granite slab, carved in 2001, with words from the curse of 1525 that the Archbishop of Glasgow, Gavin Dunbar, laid on the Border reivers: 'I curse their head and all the hairs of their head; I curse their face, their brain...' and on down to the toes. The curse ran to over a thousand words. They were thorough.
- Why: Dunbar's curse is about 1,069 words.

### `data/zones/dingle.json#signs/1/text`
- Before: DINGLE, AN DAINGEAN. 'The fortress', in Irish. About two thousand people, a Gaeltacht where Irish is the everyday language, and a lot of pubs, some of which are also hardware shops.
- After: DINGLE, AN DAINGEAN. 'The fortress', in Irish. About two thousand people, a Gaeltacht town where Irish is still spoken, and a lot of pubs, some of which are also hardware shops.
- Why: Dingle town is in the Gaeltacht, but English is the everyday language of most of the town.

### `data/zones/geevor.json#signs/1/text`
- Before: LEVEL ONE. The tin ore was hand-drilled by candlelight before safety lamps came along. The miners wore felt hats hardened with clay. And bravery.
- After: LEVEL ONE. The tin ore was hand-drilled by candlelight before safety lamps came along. The miners wore felt hats hardened with resin. And bravery.
- Why: Cornish miners' felt hats were stiffened with resin; clay was what held the candle on.

### `data/zones/gibraltar.json#signs/2/text`
- Before: Gibraltar's airfield is RAF Gibraltar and the civil airport together, with a runway that is only about 1,800 metres long and ends in the sea at both ends. The main road into town, Winston Churchill Avenue, crosses the runway on the level. When a plane lands or takes off the barriers go down, and the traffic waits for it.
- After: Gibraltar's airfield is RAF Gibraltar and the civil airport together, with a runway that is only about 1,800 metres long and ends in the sea at both ends. Winston Churchill Avenue crosses the runway on the level. Since 2023 cars take a tunnel underneath, but walkers and cyclists still wait at the barriers for each plane.
- Why: The Kingsway tunnel under the runway opened to traffic in March 2023.

### `data/zones/gibraltar.json#signs/12/text`
- Before: The Rock has about 600 kinds of plant, and one of them grows nowhere else in the world: the Gibraltar candytuft, with clusters of pale-pink flowers on the cliffs. It is the national flower of Gibraltar. Barbary partridges and peregrines nest on the same cliffs.
- After: The Rock has about 600 kinds of plant, and one of them grows wild nowhere else in Europe: the Gibraltar candytuft, with clusters of pale-pink flowers on the cliffs. It is the national flower of Gibraltar. Barbary partridges and peregrines nest on the same cliffs.
- Why: Gibraltar candytuft also grows in northern Morocco; Gibraltar is its only European site.

### `data/zones/gibraltar_rock.json#signs/5/text`
- Before: Europa Point is the southernmost tip of Gibraltar, with a lighthouse built in 1841 that is white with a red band. On a clear day the coast of Morocco can be seen across the Strait, 14 kilometres away. Ships from half the world pass by, going in and out of the Mediterranean.
- After: Europa Point is the southernmost tip of Gibraltar, with a lighthouse built in 1841 that is white with a red band. On a clear day the coast of Morocco can be seen across the Strait, over 20 kilometres away. Ships from half the world pass by, going in and out of the Mediterranean.
- Why: 14 km is the Strait's narrowest point, near Tarifa; Europa Point to Morocco is about 23 km.

### `data/zones/glasgow.json#signs/0/text`
- Before: KELVINGROVE. Red sandstone, built for the 1901 Exhibition. It has a Spitfire hanging from the ceiling, an elephant called Sophie, a Dalí, and an organ that plays most days. Entry is free. Ask for the elephant.
- After: KELVINGROVE. Red sandstone, built for the 1901 Exhibition. It has a Spitfire hanging from the ceiling, an elephant called Sir Roger, a Dalí, and an organ that plays most days. Entry is free. Ask for the elephant.
- Why: Kelvingrove's famous stuffed elephant is Sir Roger.

### `data/zones/glenveagh.json#signs/3/text`
- Before: GLENVEAGH CASTLE. Built between 1870 and 1873 for John George Adair, whose Derryveagh evictions of 1861 put 244 people off the land in the depths of winter. A later owner, Henry McIlhenny of Philadelphia, gave the castle and gardens to the nation.
- After: GLENVEAGH CASTLE. Built between 1870 and 1873 for John George Adair, whose Derryveagh evictions of 1861 put 244 people off the land in the spring. A later owner, Henry McIlhenny of Philadelphia, gave the castle and gardens to the nation.
- Why: The Derryveagh evictions took place on 8 to 10 April 1861.

### `data/zones/grytviken.json#signs/3/text`
- Before: THE SOUTH GEORGIA MUSEUM. It lives in the old whaling station manager's villa, and tells the story of sealing, whaling, exploration and wildlife. It also has a gift shop, a very small post office and a model of the James Caird, which is what Shackleton sailed here from Elephant Island, about 800 nautical miles in a lifeboat.
- After: THE SOUTH GEORGIA MUSEUM. It lives in the old whaling station manager's villa, and tells the story of sealing, whaling, exploration and wildlife. It also has a gift shop, a very small post office and a model of the James Caird, which is what Shackleton sailed here from Elephant Island, about 720 nautical miles in a lifeboat.
- Why: The James Caird voyage was about 720 nautical miles (about 800 statute miles).

### `data/zones/harris_weaver.json#signs/0/text`
- Before: THE LOOM. A Hattersley double-width loom, a hundred years old and still going. Treadles below, shuttle across, beam forward, and again, thousands of times for one length of cloth. Harris Tweed is woven on looms like this in the islanders' own homes, often in a shed beside the house.
- After: THE LOOM. A Hattersley single-width loom, a hundred years old and still going. Treadles below, shuttle across, beam forward, and again, thousands of times for one length of cloth. Harris Tweed is woven on looms like this in the islanders' own homes, often in a shed beside the house.
- Why: The Hattersley domestic loom is single-width; double-width looms came later (Bonas-Griffith).

### `data/zones/inverness.json#signs/7/text`
- Before: ST ANDREW'S CATHEDRAL. Built in the 1860s, it was the first new cathedral in Britain since the Reformation. The two towers were added later, which is why one of them is a bit shy.
- After: ST ANDREW'S CATHEDRAL. Built in the 1860s, it was the first new cathedral in Britain since the Reformation. The two towers were meant to carry spires, which never came, so they look a bit shy.
- Why: The towers were built with the cathedral; the planned spires were never added.

### `data/zones/hafod_cwm.json#signs/0/text`
- Before: THE ELAN VALLEY. Birmingham Corporation built a chain of dams on the Elan and Claerwen, opened in 1904, to bring clean water to a city of factories and cholera. Farms, a school and a mansion were drowned, and families moved out. The water still travels to Birmingham by gravity alone, without a pump. The valley has been quietly complicated about this ever since.
- After: THE ELAN VALLEY. Birmingham Corporation built a chain of dams on the Elan, opened in 1904, and a big one on the Claerwen in 1952, to bring clean water to a city of factories and cholera. Farms, a school and a mansion were drowned, and families moved out. The water still travels to Birmingham by gravity alone, without a pump. The valley has been quietly complicated about this ever since.
- Why: The 1904 dams are on the Elan; the Claerwen dam opened in 1952.

### `data/zones/lerwick_galley_shed.json#examine/0/text/0`
- Before: Up Helly Aa is held on the last Tuesday in January. The galley is built, paraded and burned in one night.
- After: Up Helly Aa is held on the last Tuesday in January. The galley is paraded and burned in one night.
- Why: The galley takes months to build; only the procession and burning happen on the night.

### `data/zones/llanberis_dolbadarn.json#examine/0/text/1`
- Before: His brother Owain Goch was held here for twenty-two years. The view is lovely, but that is a long time.
- After: Later, Llywelyn the Last's brother Owain Goch was held here for twenty-two years. The view is lovely, but that is a long time.
- Why: Owain Goch was imprisoned by his brother Llywelyn ap Gruffudd (the Last), Llywelyn the Great's grandson, not by Llywelyn the Great.

### `data/zones/norwich.json#signs/11/text`
- Before: BLUE PLAQUE: Mustard. Norwich mustard has been milled since 1814 by the river at Carrow, and the yellow tins went all over the world. The heat only appears when the powder meets cold water.
- After: BLUE PLAQUE: Mustard. Norwich mustard was milled from 1814, later by the river at Carrow, and the yellow tins went all over the world. The heat only appears when the powder meets cold water.
- Why: Colman's began at Stoke Holy Cross in 1814, moved to Carrow in the 1850s and left Carrow in 2019-20.

### `data/zones/lincoln_cathedral.json#examine/0/text/0`
- Before: Lincoln Cathedral was the tallest building in the world for over two centuries, until the spire fell in 1549. The Lincoln Imp is up in the Angel Choir, looking smug.
- After: Lincoln Cathedral was the tallest building in the world for over two centuries, until the spire fell in 1548. The Lincoln Imp is up in the Angel Choir, looking smug.
- Why: Usual date, and matches the lincoln.json plaque (1548).

### `data/zones/oban.json#signs/8/text`
- Before: ST COLUMBA'S CATHEDRAL. Built of granite in the 1930s to a design by Sir Giles Gilbert Scott, who also designed Liverpool's Anglican cathedral and, rather less grandly, the red telephone box.
- After: ST COLUMBA'S CATHEDRAL. Built of granite from 1932 to a design by Sir Giles Gilbert Scott, who also designed Liverpool's Anglican cathedral and, rather less grandly, the red telephone box.
- Why: Begun in 1932, not finished until 1959.

### `data/zones/lancaster.json#signs/3/text`
- Before: THE LUNE. A fast, wide river that gave Lancaster its name (Lune Castle). Ships once sailed up it to the Old Port, full of sugar and rum and cotton. The quay has been quiet for a century, which makes it a good place to sit and eat chips.
- After: THE LUNE. A fast, wide river that gave Lancaster its name (the Roman fort on the Lune). Ships once sailed up it to the Old Port, full of sugar and rum and cotton. The quay has been quiet for a century, which makes it a good place to sit and eat chips.
- Why: -caster is from Latin castra, a Roman fort, not a castle.

### `data/zones/lee_moor.json#signs/3/text`
- Before: SPOIL. Bare clay waste is a surprisingly good place for plants that hate rich soil: heather, gorse, bell heather and the odd orchid. Old workings across Britain become some of the best wildlife sites in the county, by accident. The wildlife has never once complained about the lack of a plan.
- After: SPOIL. Bare clay waste is a surprisingly good place for plants that hate rich soil: heather, gorse, bell heather and the odd orchid. Old workings across Britain become some of the best wildlife sites in the country, by accident. The wildlife has never once complained about the lack of a plan.
- Why: Typo: the sentence is about workings across Britain.

### `data/zones/newcastle.json#signs/7/text`
- Before: THE BALTIC. Not a sea, a flour mill. Rank Hovis built it in 1950, and in 2002 it became a very large gallery for contemporary art. There is a viewing box on the roof, and the view is not contemporary at all.
- After: THE BALTIC. Not a sea, a flour mill. Joseph Rank's flour company built it in 1950, and in 2002 it became a very large gallery for contemporary art. There is a viewing box on the roof, and the view is not contemporary at all.
- Why: Built by Joseph Rank Ltd; Rank Hovis McDougall only formed in 1962.

### `data/zones/lease_coire_dubh.json#signs/2/text`
- Before: STALKING AND THE RAILWAY. Deer stalking became fashionable in the 1800s, helped by the railways and by Queen Victoria's Highland holidays at Balmoral. Whole glens were cleared of people and farming for sporting estates. Since 2003 the Land Reform (Scotland) Act has given everyone a right of responsible access to most land.
- After: STALKING AND THE RAILWAY. Deer stalking became fashionable in the 1800s, helped by the railways and by Queen Victoria's Highland holidays at Balmoral. Whole glens were cleared of people and farming for sporting estates. Since 2005 the Land Reform (Scotland) Act 2003 has given everyone a right of responsible access to most land.
- Why: The Act passed in 2003 but the access rights came into force in February 2005.

### `data/zones/oxford.json#signs/14/text`
- Before: The OED began in 1857 and was seventy years in the making. The first editor, James Murray, ran it from a corrugated-iron shed called the Scriptorium in his garden in north Oxford, and thousands of volunteers posted in quotations on paper slips. It records the history of more than 600,000 words, tracing each one back to its first known use.
- After: The OED began in 1857 and was seventy years in the making. Its great editor, James Murray, ran it from a corrugated-iron shed called the Scriptorium in his garden in north Oxford, and thousands of volunteers posted in quotations on paper slips. It records the history of more than 600,000 words, tracing each one back to its first known use.
- Why: Murray was not the first editor (Herbert Coleridge, then Furnivall, came before him).

### `data/zones/oxford.json#signs/6/text`
- Before: Alice Liddell was the daughter of Henry Liddell, Dean of Christ Church, and in 1862 the college mathematics tutor Charles Dodgson, who wrote as Lewis Carroll, rowed her and her sisters up the river and told the story that became Alice's Adventures in Wonderland. The sweet shop across the road from the college is the one in the books, and the Dodo in the story is Dodgson himself, who stammered his own name as 'Do-Do-Dodgson'.
- After: Alice Liddell was the daughter of Henry Liddell, Dean of Christ Church, and in 1862 the college mathematics tutor Charles Dodgson, who wrote as Lewis Carroll, rowed her and her sisters up the river and told the story that became Alice's Adventures in Wonderland. The sweet shop across the road from the college is said to be the one in the books, and the Dodo in the story is Dodgson himself, who stammered his own name as 'Do-Do-Dodgson'.
- Why: Alice's Shop is only believed to be the model for the Old Sheep Shop in Through the Looking-Glass.

### `data/zones/poole.json#signs/7/text`
- Before: An Iron Age dugout canoe, hollowed from one huge oak about 2,200 years ago, found in the harbour mud in 1964 and now in Poole Museum. At about ten metres long it is one of the largest of its kind found in Britain.
- After: An Iron Age dugout canoe, hollowed from one huge oak about 2,300 years ago, found in the harbour mud in 1964 and now in Poole Museum. At about ten metres long it is one of the largest of its kind found in Britain.
- Why: The Poole Logboat is dated to around 300 BC.

### `data/zones/portree.json#signs/1/text`
- Before: PORT RÌGH · PORTREE. 'King's Port', after King James V, who landed here in 1540 to calm the island clans down. The harbour houses were painted bright so fishermen could find their way home in the fog.
- After: PORT RÌGH · PORTREE. 'King's Port', said to be after King James V, who landed here in 1540 to calm the island clans down. The harbour houses were painted bright so fishermen could find their way home in the fog.
- Why: The James V derivation is traditional and disputed (Port Ruighe, 'slope harbour', is another explanation).

### `data/zones/sark.json#signs/0/text`
- Before: There are no cars on Sark, the only island in Europe where nobody drives, apart from tractors, bikes and horse-drawn carriages. The ambulance is a tractor. The sensible way to get about is by bicycle or on foot, and the island's rule is that everybody waves.
- After: There are no cars on Sark, one of the few islands in Europe where nobody drives, apart from tractors, bikes and horse-drawn carriages. The ambulance is a tractor. The sensible way to get about is by bicycle or on foot, and the island's rule is that everybody waves.
- Why: Other European islands are car-free too (Herm, Hydra, several Frisian islands).

### `data/zones/sherwood.json#signs/8/text`
- Before: Conkers is played with the seeds of the horse chestnut, Aesculus hippocastanum, a tree that came to Britain from the Balkans in the 1600s. Each player threads a conker on a string and the two take turns to swing at one another's until one breaks. The World Conker Championships have been held at Ashton in Northamptonshire since 1965, on the second Sunday of October, and raise money for charity. The organisers supply the conkers and the string, so nobody can bake theirs or soak them in vinegar. Both are well known cheats.
- After: Conkers is played with the seeds of the horse chestnut, Aesculus hippocastanum, a tree that came to Britain from the Balkans in the 1600s. Each player threads a conker on a string and the two take turns to swing at one another's until one breaks. The World Conker Championships began at Ashton in Northamptonshire in 1965, and now take place at nearby Southwick,, on the second Sunday of October, and raise money for charity. The organisers supply the conkers and the string, so nobody can bake theirs or soak them in vinegar. Both are well known cheats.
- Why: The championships moved from Ashton to Southwick in the 2010s.

### `data/zones/shrewsbury.json#signs/4/text`
- Before: Shrewsbury has more than six hundred listed buildings, and many are timber-framed in the Shropshire black-and-white style, nicknamed magpie work: oak beams tarred black, panels whitewashed. The upper floors jut out over the street because building space upstairs was taxed less than the ground.
- After: Shrewsbury has more than six hundred listed buildings, and many are timber-framed in the Shropshire black-and-white style, nicknamed magpie work: oak beams tarred black, panels whitewashed. The upper floors jut out over the street, and folk say it was because upstairs space was taxed less.
- Why: The jetty-tax explanation is a popular myth; hedged.

### `data/zones/st_helena_plantation.json#signs/8/text`
- Before: Before goats, felling and ships, St Helena was covered in gumwood and ebony forest, found nowhere else. By the 1700s most had gone, and several kinds of plant were lost for ever. The St Helena olive was declared extinct in the 1990s. A small number of gumwoods are now being planted again.
- After: Before goats, felling and ships, St Helena was covered in gumwood and ebony forest, found nowhere else. By the 1700s most had gone, and several kinds of plant were lost for ever. The St Helena olive was lost for good in 2003. A small number of gumwoods are now being planted again.
- Why: The last wild tree died in 1994, the last cultivated one in 2003.

### `data/zones/st_helena_jamestown.json#signs/8/text`
- Before: The islanders call themselves Saints. They are descended from English settlers, Africans, Indians, Chinese labourers and many others who ended up on the island. For most of its history the only way here was a ship from Cape Town, about five days away. The airport finally opened in 2016.
- After: The islanders call themselves Saints. They are descended from English settlers, Africans, Indians, Chinese labourers and many others who ended up on the island. For most of its history the only way here was a ship from Cape Town, about five days away. The airport was finished in 2016, and regular flights began in 2017.
- Why: Scheduled commercial flights only began in October 2017.

### `data/zones/staffa_cave.json#signs/1/text`
- Before: AN T-UAMH BHINN. That is the Gaelic name for this cave: the Melodious Cave. Staffa itself is Old Norse, from a word for a staff or pillar, so the Vikings named the island for its columns and the Gaels named the cave for its sound.
- After: AN UAMH BHINN. That is the Gaelic name for this cave: the Melodious Cave. Staffa itself is Old Norse, from a word for a staff or pillar, so the Vikings named the island for its columns and the Gaels named the cave for its sound.
- Why: Uamh is feminine, so no t- prefix: An Uamh Bhinn.

### `data/zones/staffa_hollow.json#signs/0/text`
- Before: SIR JOSEPH BANKS. The naturalist Sir Joseph Banks, who had sailed round the world with Captain Cook, landed on Staffa in 1772 on his way to Iceland. His account of the cave made it famous. Its old Gaelic name is An t-Uamh Bhinn, the Melodious Cave, and Fingal's Cave was the name that stuck.
- After: SIR JOSEPH BANKS. The naturalist Sir Joseph Banks, who had sailed round the world with Captain Cook, landed on Staffa in 1772 on his way to Iceland. His account of the cave made it famous. Its old Gaelic name is An Uamh Bhinn, the Melodious Cave, and Fingal's Cave was the name that stuck.
- Why: Uamh is feminine, so no t- prefix: An Uamh Bhinn.

### `data/zones/stornoway.json#signs/4/text`
- Before: One Lewis chessman went missing for nearly two centuries. A Scottish dealer bought a knight for a few pounds in 1964. His family kept it in a drawer, never knowing what it was, until it was recognised in 2019 and sold for hundreds of thousands of pounds. It is worth checking your drawers.
- After: One Lewis chessman went missing for nearly two centuries. A Scottish dealer bought a warder for a few pounds in 1964. His family kept it in a drawer, never knowing what it was, until it was recognised in 2019 and sold for hundreds of thousands of pounds. It is worth checking your drawers.
- Why: The piece bought for 5 pounds in 1964 and sold in 2019 was a warder (a rook), not a knight.

### `data/zones/stoke_museum.json#signs/1/text`
- Before: THE STAFFORDSHIRE HOARD. Gold and garnet sword fittings, a folded gold cross and pieces of a helmet, all made in the 600s and 700s and buried for reasons nobody knows.
- After: THE STAFFORDSHIRE HOARD. Gold and garnet sword fittings, a folded gold cross and pieces of a helmet, all made in the 500s and 600s and buried for reasons nobody knows.
- Why: The Hoard's objects date from the late 6th to mid 7th century; it was buried around 650 to 675.

### `data/zones/whitby_boat_hut.json#signs/0/text`
- Before: HMS Endeavour began as a Whitby collier, the Earl of Pembroke, launched in 1764. The town built sturdy ships for sturdy cargoes, and still lands fish on the same quay.
- After: HM Bark Endeavour began as a Whitby collier, the Earl of Pembroke, launched in 1764. The town built sturdy ships for sturdy cargoes, and still lands fish on the same quay.
- Why: Cook's ship was commissioned as His Majesty's Bark Endeavour.

### `data/quests/fife.json#quests/1/steps/2/text`
- Before: Bring back an iron girdle, for oatcakes on the ice, from the Girdlesmith's Forge at Culross, over the Forth.
- After: Bring back an iron girdle, for oatcakes on the ice, from the Girdlesmith's Forge at Culross, on the Forth.
- Why: Culross is in Fife, on the north shore of the Forth.

### `data/items/arc_scotland.json#1/desc`
- Before: Butter, flour and sugar in the old 3-2-1 sum, baked in the Braes Hall oven for the opening night. Restores 120 HP and leaves crumbs in the bag for weeks.
- After: Flour, butter and sugar in the old 3-2-1 sum, baked in the Braes Hall oven for the opening night. Restores 120 HP and leaves crumbs in the bag for weeks.
- Why: The traditional ratio is 3 flour : 2 butter : 1 sugar; the old order implied 3 parts butter.

### `data/items/charms.json#7/desc`
- Before: A Davy lamp from a Welsh pit. The miners swore by it, and swore at the tommyknockers.
- After: A Davy lamp from a Welsh pit. The miners swore by it, and swore at the coblynau.
- Why: Tommyknockers are Cornish and Devon mine spirits; the Welsh pit spirits are the coblynau.

## Session V: open doubts worked through

Session V (branch `claude/w45-v-fixes`) went through the 52 doubts below with a source check on each. 41 were settled and edited in the game (listed first, with the source that settled them), 4 were checked and kept as written, and 6 are kept open for the owner at the end. Where a figure could not be pinned down the line was reworded to say less, not more.

### Settled and edited

- `data/zones/ascension_green_mountain.json#signs/4`: Devil's Riding School is an inland crater north-east of Wideawake airfield (NASA Earth Observatory). Now "A flat-bottomed crater inland, north-east of Wideawake airfield".
- `data/zones/ascension_green_mountain.json#signs/5`: "Nothing here is native except the ferns" softened to "Almost nothing", since Ascension has a handful of other native plants (spurge, grasses).
- `data/zones/ascension_green_mountain.json#signs/6`: rewritten. Feral cats (about 5,800 adult terns a year) were eradicated 2002 to 2004; rats and mynas still take eggs; the colony is a few hundred thousand against millions a century ago (Hughes et al., University of Birmingham 2019; Ratcliffe et al. 2008). No claim that numbers are climbing.
- `data/zones/bath.json#signs/2`: "Founded 757" was a land grant year. Osric's charter of 675 founded the convent (Bath Abbey, Wessex Archaeology). Now "A monastery since 675".
- `data/zones/bath_hall.json#signs/0`: Guildhall built 1775 to 1778 (Historic England list entry 1396021).
- `data/zones/birmingham.json#signs/7`: Bird invented custard powder in 1837 as a Birmingham chemist; the Devonshire Works in Digbeth went up in 1902. Now says so.
- `data/zones/belfast_titanic.json#examine/1/text/1`: riveting squads were five: heater boy, catcher, holder-up and two riveters (Encyclopedia Titanica, National Museums Liverpool).
- `data/zones/borders_abbotsford.json#examine/0`: farm bought 1811, house built in phases 1816-18 and 1822-24 (Historic Environment Scotland LB15104). Now "bought a farm here in 1811, built Abbotsford in stages through the 1810s and 1820s".
- `data/zones/canterbury.json#signs/1`: the Westgate closure was a trial from April 2012 to spring 2013 and the old layout was restored (Kent County Council, ITV Meridian). Now "Traffic still squeezes through its arch; a year's trial of closing it, in 2012, was not kept."
- `data/zones/canterbury.json#signs/2`: circuit about two miles, over half surviving (Historic UK, Wikipedia). The mile-and-a-half figure is gone.
- `data/zones/chester.json#signs/3`: fortress begun in the mid-70s AD by Legio II Adiutrix; sources give 74, 75 and 79. Now "founded in the AD 70s".
- `data/zones/dingle_boat_hut.json#signs/0`: now "sheltered by the hills of the Dingle Peninsula" (Slea Head is the tip).
- `data/zones/enniskillen_castle.json#signs/1`: "two Victoria Crosses' worth" is now "several" (the Inniskillings won eight in the First World War alone).
- `data/zones/enniskillen_portora.json#signs/0`: no Portora gold medal is attested; the Berkeley Gold Medal was Trinity's, 1874. Now "left in 1871 with the school's prize for Classics and a scholarship to Trinity College Dublin" (the Royal School Scholarship, 1871).
- `data/zones/enniskillen.json#signs/8`: Devenish tower measured at about 26.5 m (irishstones.org survey); some guides say 30. Now "over 25 metres".
- `data/zones/galway.json#signs/0`: Eyre Square is about 3 acres (1.2 ha), not eight. Now "A few acres of green".
- `data/zones/galway_druid.json#examine/0`: Druid has had its theatre on the lane (Chapel Lane, renamed Druid Lane in 1996) since 1979. Now says "since 1979 it has played in a tiny theatre on the lane now named after it".
- `data/zones/gibraltar.json#signs/3`: Grand Casemates Barracks built 1817. Now "built by the British in 1817".
- `data/zones/gibraltar.json#signs/1`: matches the audit's fix to signs/2: walkers and cyclists wait at the barriers, cars have used the Kingsway tunnel since 2023, and the "only road that gives way to a Hercules" is in the past tense.
- `data/zones/grytviken.json#signs/2`: Grytviken ran to 1965 by the South Georgia government's account and closed December 1966 by Wikipedia's; the last whale is not dated anywhere. Now "Whaling here ended in the mid-1960s".
- `data/zones/lease_clonbeg.json#signs/0`: ESB's Lough Ree and West Offaly closed in 2020; Edenderry burned its last peat on 23 December 2023 (Bord na Mona). Now says both.
- `data/zones/norwich.json#signs/5`: the Norwich Society campaigned and the council decided; the one-vote (mayor's casting vote) detail is local tradition. Now "talked the council out of it, by the narrowest of votes, so the story goes".
- `data/zones/poole.json#signs/0`: the 1847 line ended at Hamworthy; Poole's own station opened 1872; the line runs on to Weymouth; Poole to Cherbourg sails most of the year. Now "The railway reached the far side of the harbour in 1847 and the town itself in 1872" and plain "Cherbourg".
- `data/zones/rothera.json#signs/2`: the Dash 7 flies from both Punta Arenas and the Falklands (BAS). Now says both.
- `data/zones/oxford.json#signs/13`: the Eagle and Child closed in 2020 and is being restored by the Ellison Institute with no opening date set. Now "The pub closed in 2020 and is being restored to open again."
- `data/zones/penshaw.json#signs/3`: the National Glass Centre's closure (31 July 2026) was announced in advance; the line now says Sunderland "in 1998 opened a National Glass Centre on the riverbank", true whatever happens to the building.
- `data/zones/st_helena_plantation.json#signs/6`: 5,500 to 6,000 prisoners, 1900 to 1902, at Deadwood and Broadbottom (SA Military History Society). Now "From 1900 to 1902 nearly six thousand ... in camps here on Deadwood Plain and at Broadbottom".
- `data/zones/st_peter_port.json#signs/11`: Douzaines are a dozen in most parishes, 20 in St Peter Port. Now "a dozen or more elected parish officers".
- `data/zones/staffa_columns.json#signs/0`: the opening bars went in a letter home to the family (7 August 1829). Now "sent it home in a letter to his family".
- `data/zones/tobermory.json#signs/12`: Mull Little Theatre was a converted byre at Dervaig (about 42 seats, once in the Guinness book as the world's smallest professional theatre); the company moved to Druimfin outside Tobermory in 2008. Rewritten in the past tense with the move.
- `data/zones/yorkshire_wolds.json#signs/2`: the 69 Harewood kites (1999 on) all came from the Chilterns, whose own founders were Spanish (1990) (Yorkshire Red Kites, Natural England). Now says so.
- `data/zones/swansea.json#signs/16`: Oystermouth founded by William de Londres about 1106, rebuilt in stone by the de Breoses in the 1200s. Now says so.
- `data/zones/york_hall.json#signs/0`: Domesday records two butchers' stalls, not the street name; "Great Flesh Shambles" is attested by 1426 (York Civic Trust, History Hit). Rewritten accordingly.
- `data/zones/wookey_hole.json#signs/3`: the attraction's own telling names the monk Father Bernard. Now "The guide calls the monk Father Bernard. Nobody ever asked the witch her name."
- `data/zones/sherwood.json#signs/8`: double comma left by the audit's own edit ("Southwick,,") removed.
- `data/items/borders.json#0`: Carr's was founded in Carlisle in 1831; the Table Water biscuit's own date is disputed (1832 or 1890). Now "from a Carlisle bakery founded in 1831".
- `data/items/overseas_anguilla.json#4`: Anguillan race boats have no deck, a foot-wide rail and sandbag or lead ballast; no hiking plank. The Crew Plank's description now says the crew sit on the rail as ballast.
- `data/items/valleys.json#1`: earliest record is George Borrow's Wild Wales (breakfast at Brynamman, published 1862); the meatless version came into its own under wartime rationing. Now says that instead of "invented when meat was short".
- `data/lang/ga.json#places/glenveagh`: now "Gleann Bheatha agus an Earagail".
- `data/festivals.json#events/braemar`: moved from the Welsh Dee Valley to the `cairngorms` zone (Braemar is inside the Cairngorms National Park, on the Aberdeenshire Dee), Caber Callum at a free tile (62, 22); the quest's town and step zones follow. `Festivals.validate` now checks every festival person stands on a free floor tile of their town.
- `data/festivals.json#events/uphellyaa`: the event already carried a `rule` (last Tuesday of January, 3 days before to 1 after) that overrides the window; the misleading fixed 24 to 28 January window is removed and the file's `_doc` says so. `tests/core/test_festivals.gd` now checks the Tuesday is inside the window, and the days around it are right, for every year 2026 to 2040 (it falls on the 31st in 2034 and 2040, so the window runs into 1 February). A late-December "Coming up" line now looks at next January's dates rather than the one just gone (`Festivals.coming_window`).

### Checked and kept as written

- `data/zones/inverness.json#signs/4`: the River Ness is about 10 km (6.2 miles) in Wikipedia and the Gazetteer for Scotland; longer figures are outliers.
- `data/zones/st_helena_jamestown.json#signs/0`: St Helena to Ponta do Seixas, Brazil's eastern tip, is about 3,310 km by great circle; 4,000 km is the distance to Rio. "3,300 from South America" stands.
- `data/zones/st_peter_port.json#signs/10`: the Guernsey Press and Liberation Route give 34 killed in the 28 June 1940 raid (Visit Guernsey says 33). 34 stands.
- `data/quests/potteries.json#quests/3/steps/1`: the detectorist's own line in `data/dialogue/the_roaches.json` puts the Hoard's field "near Lichfield"; the Roaches is only where he stands.

### Still open (for the owner)

- `data/zones/beacons.json#signs/7` and `data/zones/cambrian_coast.json#signs/8`: fingerpost mileages (St Davids 40 miles, Aberystwyth 14 miles) are game geography, not real distances (nearer 90 and 35 miles by road). Owner's call whether fingerposts should carry real figures.
- `data/zones/diego_garcia.json#signs/0`: "BRITISH INDIAN OCEAN TERRITORY" was true through 2025; the UK-Mauritius treaty of May 2025 hands over sovereignty with Diego Garcia leased back, and its entry into force cannot be verified from here. The brief says not to describe 2025-26 developments we cannot verify, so left as is.
- `data/zones/donegal_castle.json#examine/0`: sources conflict. The 1601 siege (and a fire) is well attested; Wikipedia's castle article instead has the departing O'Donnells wrecking it in 1607, and no source found has Red Hugh burning it himself "rather than see it taken". Needs a better source before editing.
- `data/quests/valleys.json#quests/2/summary`: Trevithick's 1804 run hauled iron with local Merthyr coal; the quest's item is "Rhondda Steam Coal" (Rhondda steam coal came in the 1850s). Gameplay framing; renaming the item would touch saves, so left for the owner.
- `data/lang/nrf_gg.json#places/st_peter_port` and its greeting: Guernésiais forms ("St Pierre Port", "Bouan jour" or similar) need a speaker to confirm; "Bonjour" is standard French.
- `data/zones/ascension_green_mountain.json#signs/6`: reworded as above, but the current sooty tern count (no census found after 2019) is worth a check against RSPB or Ascension Island Government figures when someone has them.

## Language data checked and left as is

All places, greetings and phrases in cy, ga, gd, gv, kw, jer and nrf_gg were read. Welsh, Irish, Scottish Gaelic, Manx, Cornish and Jèrriais entries look right (e.g. Bannau Brycheiniog, Dyffryn Dyfrdwy, Clochán an Aifir, Loch nEathach, Am Monadh Ruadh, Na Hearadh, Laksaa, Pennsans, Saint Hélyi). Session V fixed the Glenveagh article; the Guernésiais point is still open above.
