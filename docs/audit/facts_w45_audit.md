# Facts audit, wave 45 (session S)

Accuracy audit of existing player-facing facts: zone plaques (`signs`, `examine`), item descriptions (including the Gazetteer key items), `data/festivals.json`, quest text in `data/quests/` and the language data in `data/lang/` (places, greetings, phrases).

Texts checked: 4,091 strings (4,002 unique) extracted with python from 1470 zone files, 25 festivals, the quest files, the item files and 7 language files. Jokes and game fiction were skipped.

Fixes made: 50. Open doubts: 52 (not edited; for the owner).

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

## Open doubts (not edited)

Each needs a source check or an owner decision before anything changes in the game.

- `data/zones/ascension_green_mountain.json#signs/4/text`: "A flat-bottomed crater on the south-east coast, down at Comfortless Cove". Devil's Riding School crater is inland in the west; Comfortless Cove is on the north-west coast, not south-east
- `data/zones/ascension_green_mountain.json#signs/5/text`: "Nothing here is native except the ferns". Ascension has a few other native/endemic plants (e.g. endemic spurge, grasses, mosses); oversimplified
- `data/zones/ascension_green_mountain.json#signs/6/text`: "Before the rats and cats were cleared the colonies were tiny". Sooty tern colony declined (to roughly a few hundred thousand) but was never tiny; cats cleared 2002-04, rats not eradicated
- `data/zones/bath.json#signs/2/text`: "BATH ABBEY. Founded 757". A monastery was founded here in 675; 757 is a less standard date (Offa's grant)
- `data/zones/bath_hall.json#signs/0/text`: "finished in 1775". Bath Guildhall is generally dated 1775 to 1778 (begun 1775, completed 1778)
- `data/zones/birmingham.json#signs/7/text`: "Alfred Bird invented egg-free custard here in 1837". Bird invented it at his chemist's shop in Worcester Street; the Digbeth Custard Factory works was built decades later
- `data/zones/belfast_titanic.json#examine/1/text/1`: "driven in squads of four: a heater boy, a catcher, a holder-on and a riveter". Harland and Wolff squads usually described as five, with two riveters (left- and right-handed)
- `data/zones/borders_abbotsford.json#examine/0/text/0`: "Sir Walter Scott built Abbotsford from 1812". Scott bought the farm 1811 and moved in 1812; the present house was mostly built 1817 to 1825
- `data/zones/beacons.json#signs/7/text`: "ST DAVIDS 40 miles". St Davids is about 90 miles from the Storey Arms by road (Cardiff 20 miles is also short, nearer 35); may be game geography
- `data/zones/cambrian_coast.json#signs/8/text`: "ABERYSTWYTH 14 miles". Barmouth/Harlech to Aberystwyth is about 35 miles by road; may be game geography
- `data/zones/canterbury.json#signs/1/text`: "Traffic squeezed through its arch until 2012". 2012 closure was a trial; traffic may have been restored through the Westgate afterwards
- `data/zones/canterbury.json#signs/2/text`: "about a mile and a half of it". Full circuit was only ~1.7 miles; surviving half is nearer a mile
- `data/zones/chester.json#signs/3/text`: "Deva Victrix, founded AD 79". Fortress usually dated c. AD 74-75
- `data/zones/diego_garcia.json#signs/0/text`: "BRITISH INDIAN OCEAN TERRITORY". 2025 UK-Mauritius treaty transfers Chagos sovereignty (Diego Garcia leased back); status in 2026 setting may need a nod
- `data/zones/dingle_boat_hut.json#signs/0/text`: "sheltered by the Slea Head peninsula". Dingle harbour is on the Dingle (Corca Dhuibhne) peninsula; Slea Head is its tip
- `data/zones/donegal_castle.json#examine/0/text/0`: "burned it in 1601". Date of Red Hugh's slighting of the castle uncertain (often given as 1590s)
- `data/zones/enniskillen_castle.json#signs/1/text`: "two Victoria Crosses' worth of stories". Inniskilling Fusiliers won many more VCs (8 in WWI alone)
- `data/zones/enniskillen_portora.json#signs/0/text`: "left in 1871 with a gold medal for Classics". Wilde won the Carpenter Prize and a Royal School scholarship; 'gold medal' uncertain
- `data/zones/enniskillen.json#signs/8/text`: "round tower stands about 30 metres tall". Devenish tower often given as about 25 m
- `data/zones/galway.json#signs/0/text`: "Eight acres of green". Eyre Square seems smaller than eight acres; size not verified
- `data/zones/galway_druid.json#examine/0/text/0`: "in a tiny space on Druid Lane". Druid first played at the Jesuit Hall in 1975; the Druid Lane (Chapel Lane) theatre came in 1979
- `data/zones/gibraltar.json#signs/3/text`: "a barracks of vaulted rooms built by the British in the 1700s". Grand Casemates barracks usually dated to 1817
- `data/zones/grytviken.json#signs/2/text`: "The last whale was processed in 1965". Grytviken station is usually said to have closed in December 1966; last season may be 1964-65, check
- `data/zones/inverness.json#signs/4/text`: "Only about 10 km long". River Ness is often given as about 19 km (12 miles); check
- `data/zones/gibraltar.json#signs/1/text`: "When a plane is landing the road is closed". Since the 2023 Kingsway tunnel only pedestrians and cyclists use the runway crossing; still broadly true for walkers
- `data/zones/lease_clonbeg.json#signs/0/text`: "Burning peat for electricity ended in 2020". Lough Ree and West Offaly stations closed in 2020 and Bord na Mona stopped harvesting, but Edenderry kept co-firing peat until about 2023
- `data/zones/norwich.json#signs/5/text`: "The Norwich Society saved it by one vote". The Norwich Society campaigned, but the one-vote decision was the city council's
- `data/zones/poole.json#signs/0/text`: "The line reached Poole in 1847 ... the end of the railway". 1847 line reached Hamworthy (old Poole station); town station 1872; line continues to Weymouth (may be game-network fiction)
- `data/zones/poole.json#signs/0/text`: "in summer, Cherbourg". Brittany Ferries Poole-Cherbourg runs most of the year, not only summer
- `data/zones/rothera.json#signs/2/text`: "the Dash 7, flies in from Punta Arenas". BAS Dash 7 mainly flies Rothera to Stanley, Falklands (also Punta Arenas at times)
- `data/zones/st_helena_jamestown.json#signs/0/text`: "3,300 from South America". commonly quoted as about 4,000 km east of Rio; nearest Brazilian coast maybe about 3,300 km, unsure
- `data/zones/oxford.json#signs/13/text`: "The pub still serves a pint". Eagle and Child closed in 2020 for refurbishment; unsure whether reopened by 2026
- `data/zones/penshaw.json#signs/3/text`: "has a National Glass Centre to prove it". University of Sunderland announced closure plans for the National Glass Centre; status in 2026 unclear
- `data/zones/st_helena_plantation.json#signs/6/text`: "In 1900 and 1901 about five thousand Boer prisoners". prisoners held 1900 to 1902, roughly 5,000 to 6,000
- `data/zones/st_peter_port.json#signs/10/text`: "killed 34 people". 28 June 1940 raid on Guernsey is usually given as 33 killed (34 in some counts)
- `data/zones/st_peter_port.json#signs/11/text`: "a council of twelve elected parish officers". Douzaine size varies by parish (St Peter Port has 20, Vale 16); 'douze' is only the name's origin
- `data/zones/staffa_columns.json#signs/0/text`: "sent it to his sister Fanny". The opening bars were sent in a letter home to his family (7 Aug 1829), written before he actually landed on Staffa
- `data/zones/tobermory.json#signs/12/text`: "At Dervaig, a few miles from here, a professional theatre of about forty seats". Mull Theatre moved from the Dervaig barn to Druimfin near Tobermory in 2008; Dervaig is about 8 miles away
- `data/zones/yorkshire_wolds.json#signs/2/text`: "Birds brought from Spain were released at Harewood". Harewood (1999-2003) kites are generally reported as young birds from the Chilterns population (itself founded from Spanish stock)
- `data/zones/swansea.json#signs/16/text`: "Built by the Norman lords of Gower, the de Breoses, from the twelfth century". Oystermouth was founded c. 1106 by William de Londres; the de Braose stone castle is mainly 13th century
- `data/zones/york_hall.json#signs/0/text`: "mentioned in the Domesday Book of 1086 as the Great Flesh Shambles". Shambles is popularly said to be in Domesday, but 'Great Flesh Shambles' is a later medieval name, not the Domesday wording
- `data/zones/wookey_hole.json#signs/3/text`: "The monk, as the guide says, is never named". The legend usually names him Father Bernard of Glastonbury (wry line, may be intentional)
- `data/quests/potteries.json#quests/3/steps/1/text`: "Find the detectorist in the fields below the Roaches.". The Staffordshire Hoard was found at Hammerwich near Lichfield, south Staffordshire, not near the Roaches (by Leek); may mislead if read as the find site
- `data/quests/valleys.json#quests/2/summary`: "Replay the 1804 wager: Rhondda coal". Penydarren ironworks used local Merthyr coal; Rhondda steam coal was exploited later (1850s on). Gameplay framing, low priority
- `data/items/borders.json#0/desc`: "baked in Carlisle since the 1850s". Carr's of Carlisle dates from 1831 and its table water biscuit is often dated to the 1830s/40s; unsure of the 1850s date
- `data/items/overseas_anguilla.json#4/desc`: "It sticks out over the water to balance the sloop.". Not sure Anguillan racing sloops use a hiking plank; they are known for shifting sandbag ballast and crew weight
- `data/zones/ascension_green_mountain.json#signs/6/text`: "Before the rats and cats were cleared the colonies were tiny. The numbers are climbing again". Feral cats were cleared in 2002-04 but rats were not eradicated, and sooty tern numbers are not clearly climbing. Needs rewording by someone with current RSPB/AIG figures.
- `data/items/valleys.json#1/desc`: "Glamorgan sausage 'was invented when meat was short, and it outlived the shortage by a century'". Recorded by George Borrow in 1862 and popular in Second World War rationing; 'invented when meat was short' is doubtful.
- `data/festivals.json#events/braemar`: "The Braemar Gathering is held in town 'dee_valley'". dee_valley is the Welsh Dee Valley (Llangollen, Pontcysyllte). Braemar is on the Aberdeenshire Dee. Needs moving to a Scottish zone (new coordinates on a free tile), so not edited here.
- `data/festivals.json#events/uphellyaa`: "window 24 to 28 January for 'the last Tuesday of January'". The last Tuesday of January falls between the 25th and the 31st, so a fixed 24 to 28 January window misses it in some years (it is 30 January in 2029 and 29 January in 2030).
- `data/lang/nrf_gg.json#places/st_peter_port`: "'Saint Pierre Port'; greeting 'Bonjour!'". Not sure of the Guernésiais forms. Sources give 'St Pierre Port' or 'Saint-Pierre-Port' for the town and 'Bouan jour' or similar for hello; 'Bonjour' is standard French. Owner or a Guernésiais speaker to confirm.
- `data/lang/ga.json#places/glenveagh`: "'Gleann Bheatha agus An Earagail'". Correct words, but mid-phrase the article would normally be lower case: 'Gleann Bheatha agus an Earagail'.

## Language data checked and left as is

All places, greetings and phrases in cy, ga, gd, gv, kw, jer and nrf_gg were read. Welsh, Irish, Scottish Gaelic, Manx, Cornish and Jèrriais entries look right (e.g. Bannau Brycheiniog, Dyffryn Dyfrdwy, Clochán an Aifir, Loch nEathach, Am Monadh Ruadh, Na Hearadh, Laksaa, Pennsans, Saint Hélyi). The two open language points are in the list above.
