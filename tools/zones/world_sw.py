"""Walk-in interiors for the South West: Bath, Glastonbury, Mendips, Somerset Levels, Penzance, Tintagel.
Run: python3 tools/zones/world_sw.py data/zones
Writes interiors (via zlib.landmark), dialogue, and patches the town/route JSON in place (doors, warps, a few new houses)."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zid, name, zone, door(x,y), kind, npcs[(id, sprite, x, y, who, lines[, gift])], w, h)
# gift = (flag, item, text said on a repeat visit)
L = []


def add(zid, name, zone, door, kind, npcs, w=13, h=10):
    L.append((zid, name, zone, door, kind, npcs, w, h))


# new unlabelled houses added to Glastonbury (it had none): (style, x, y, w, h)
NEW_HOUSES = {"glastonbury": [("stone", 5, 6, 4, 3), ("tudor", 11, 8, 4, 3), ("slate_cottage", 16, 6, 4, 3)]}
# tile edits: zone -> [(x, y, ch)]
TILE_FIX = {"bath": [(44, 27, ":"), (45, 27, ":")]}

# ------------------------------------------------------------------ BATH
add("bath_pulteney", "Pulteney Bridge Shops", "bath", (46, 18), "workshop", [
    ("pulteney_trader", "villager_2", 6, 4, "Shopkeeper", [
        "Welcome aboard, so to speak. This shop is on a bridge, and the bridge is on a river.",
        "Robert Adam designed Pulteney Bridge and it was finished in 1774. It is one of very few bridges in the world lined with shops.",
        "Down at the weir, the River Avon tumbles over a curved step. Everyone photographs it, so I sell the postcards."])])
add("bath_pulteneytea", "Pulteney Bridge Tea Rooms", "bath", (45, 26), "cafe", [
    ("pulteneytea_waiter", "villager_5", 6, 4, "Waiter", [
        "Window seat? You get a view of the river and the weir. Tables are first come, first served.",
        "Bath has been a tea-and-gossip town since Georgian days, when fashionable visitors came to take the waters.",
        "Sit very quietly at dusk and you might spot a Rillotter hunting below the weir. The fish do not enjoy it."])], 11, 9)
add("bath_crescent", "No. 1 Royal Crescent", "bath", (15, 7), "museum", [
    ("crescent_curator", "tour_guide", 5, 4, "Curator", [
        "Welcome to a Georgian townhouse. Please admire the furniture with your eyes only.",
        "The Royal Crescent has thirty houses in one sweeping curve. John Wood the Younger built it between 1767 and 1774.",
        "Round the back every house looks different, because owners built what they liked. The locals said grand fronts, messy backs.",
        "The lawn in front ends in a sunken fence called a ha-ha. The cows stay out and the view stays clean."])], 15, 10)
add("bath_sallylunn", "Sally Lunn's", "bath", (8, 29), "cafe", [
    ("sallylunn_baker", "mum", 4, 3, "Baker", [
        "Mind your head on the beams. This house is ancient.",
        "It dates from about 1482, so it is one of the oldest houses in Bath. Downstairs, the kitchen museum shows Roman and medieval foundations.",
        "The bun is named for Sally Lunn, a French refugee who may have baked them in the 1680s. Or it came from 'soleil et lune'. Nobody agrees.",
        "Have a cup of tea for the road. It is hot, so blow on it before you panic."],
     ("bath_sallylunn_gift", "cup_of_tea", "One cup per customer, I am afraid. The beams are still very low, though.")),
    ])
add("bath_jollys", "Jolly's Tea Rooms", "bath", (18, 29), "cafe", [
    ("jollys_waitress", "villager_3", 4, 3, "Waitress", [
        "Afternoon tea is a Bath tradition. Pinkies up if you like. We do not check.",
        "In the 1700s Beau Nash ruled the town's social life. He wrote rules of polite behaviour and had them posted in the Pump Room.",
        "He even asked gentlemen to leave their swords at home. Excellent policy, I say."])], 11, 9)
add("bath_thermae", "Thermae Bath Spa", "bath", (54, 32), "hall", [
    ("thermae_attendant", "villager_1", 6, 4, "Spa Attendant", [
        "Welcome. Towels on the left, worries on the right.",
        "Bath has the only naturally hot springs in Britain. The water bubbles up at around 46 degrees, over a million litres a day.",
        "The rain fell on the Mendip Hills thousands of years ago, sank deep, got warmed by the Earth and rose here. A very slow delivery.",
        "The rooftop pool opened in 2006. Swimming among the chimney pots at dusk is quite something."])])
add("bath_home1", "Hale's House", "bath", (5, 17), "home", [
    ("bath_home1_gran", "villager_4", 5, 3, "Mrs Hale", [
        "Come in, come in, wipe your feet. The kettle is on, and so is the cat.",
        "Round here 'gert lush' means really good. Say it about my shortbread and you can stay for tea.",
        "Walk by the canal at dusk and you may meet a Flittermouse. They zip about after the midges, so keep your head up.",
        "My grandson is learning to row on the Avon. He has fallen in twice. We call that training."])], 11, 9)
add("bath_home2", "Cottage Near the Crescent", "bath", (5, 10), "cottage", [
    ("bath_home2_stargazer", "commuter", 5, 3, "Old Tom", [
        "Mind the telescope. Do not sneeze on it, it is older than my knees.",
        "A man called William Herschel lived just up the road and spotted a new planet from his back garden in 1781. It was Uranus.",
        "He wanted to call it King George's Star. Everybody else said no, thank you.",
        "His sister Caroline found eight comets. In Bath we think she was the clever one. Do not tell the Herschels."])], 11, 9)
add("bath_home3", "Terrace House", "bath", (20, 8), "home", [
    ("bath_home3_nan", "mum", 5, 3, "Nan", [
        "Welcome, my lover. Sit down, you look like you have walked the whole hill.",
        "Bath Olivers were invented here by Dr William Oliver in the 1700s. He said they were good for you. They are crackers.",
        "Bath stone is that honey colour because it is limestone. In the sun the whole city looks like toast.",
        "My granddaughter says 'where's that to?' when she wants to know where something is. That is Bristol's fault."])], 11, 9)
add("bath_home4", "Riverside Cottage", "bath", (24, 10), "cottage", [
    ("bath_home4_student", "student", 5, 3, "Joss", [
        "Quiet please, I am revising. No, wait. Hello. I am procrastinating.",
        "The rugby club plays at the Rec, right in the middle of town. On match days you can hear it from the Abbey.",
        "Severnshock lives in the Avon, an eel with a temper. Eels swim thousands of kilometres to breed in the Sargasso Sea.",
        "Dad says Prince Bladud founded Bath. Legend says the pigs found the hot mud first. The pigs have not commented."])], 11, 9)

# ------------------------------------------------------------------ GLASTONBURY
add("glastonbury_crystal", "Crystal Emporium", "glastonbury", (4, 17), "workshop", [
    ("crystal_keeper", "villager_2", 5, 4, "Shopkeeper", [
        "Every stone here is real rock, and every rock has a story. Mostly about how it got to Somerset.",
        "Quartz is made of silicon and oxygen, the two most common elements in Earth's crust. Plain stuff in fancy clothes.",
        "Glastonbury likes its myths. Some are true, some are lovely, and the best ones are both."])], 11, 9)
add("glastonbury_cauldron", "Cauldron Cafe", "glastonbury", (37, 18), "cafe", [
    ("cauldron_cook", "villager_6", 4, 3, "Cook", [
        "Mind the cat on the counter. She thinks she runs this place, and she is right.",
        "Glastonbury was almost an island once, when the Levels flooded. Folk called it the Isle of Avalon.",
        "The Glastonbury Thorn flowers in winter, and a sprig goes to the King each Christmas. Quite a lot of pressure for a bush.",
        "Here, a cup of tea on the house. You look like you have climbed the Tor."],
     ("glaston_cauldron_gift", "cup_of_tea", "Another cup? You will float up the Tor. Go on, off with you.")),
    ], 11, 9)
add("glastonbury_george", "The George and Pilgrims", "glastonbury", (39, 27), "hall", [
    ("george_host", "villager_4", 6, 4, "Innkeeper", [
        "Welcome to the George and Pilgrims. Pilgrims have been staying here for over five hundred years.",
        "It was built in the late 1400s for visitors to the abbey, which was one of the richest in England.",
        "Look at the carved stone front. The builders wanted every pilgrim to know the abbey had plenty of money."])])
add("glastonbury_wizard", "Wizard Wardrobe", "glastonbury", (47, 27), "workshop", [
    ("wizard_assistant", "festival_goer", 5, 4, "Assistant", [
        "Capes, hats, wands and beards. Wizards of every size, we have you covered.",
        "Glastonbury Festival began in 1970 on Worthy Farm at Pilton, nearby. A ticket cost one pound and came with free milk.",
        "Half the festival crowd comes here for costumes. The other half pretends they brought their own."])], 11, 9)
add("glastonbury_abbeymuseum", "Glastonbury Abbey Museum", "glastonbury", (41, 35), "museum", [
    ("abbey_museum_guide", "tour_guide", 5, 4, "Abbey Guide", [
        "Welcome to Glastonbury Abbey. Those mighty ruins outside were once the Great Church.",
        "The abbey burned down in 1184 and was rebuilt grander. Henry VIII closed it in 1539, and the stone went to build local barns and walls.",
        "In 1191 the monks announced they had found King Arthur's grave. Pilgrims arrived in droves, which was probably not a coincidence.",
        "Legend says Joseph of Arimathea planted the Holy Thorn on Wearyall Hill. The Thorn still flowers in winter."])])
add("glastonbury_ladychapel", "Lady Chapel", "glastonbury", (40, 41), "church", [
    ("ladychapel_verger", "choir_singer", 6, 3, "Verger", [
        "Shh, but kindly. This is the Lady Chapel, the oldest part of the abbey that still stands.",
        "It was started right after the great fire of 1184. The monks did not waste time.",
        "Look at the doorways. The carved saints and beasts have been weathered by eight hundred years of Somerset rain."])])
add("glastonbury_abbotskitchen", "Abbot's Kitchen", "glastonbury", (51, 41), "castle", [
    ("abbots_kitchen_guide", "villager_5", 5, 4, "Kitchen Guide", [
        "Welcome to the Abbot's Kitchen. Mind the fireplaces. There are four.",
        "It was built in the 1300s as an octagon, with a huge pointed roof to let the smoke escape.",
        "Medieval cooks fed the abbot and his guests here. It is one of the best preserved medieval kitchens in England."])], 11, 9)
add("glastonbury_pyramid", "Pyramid Stage", "glastonbury", (10, 37), "theatre", [
    ("pyramid_stagehand", "festival_goer", 6, 3, "Stagehand", [
        "Welcome to the Pyramid Stage. The first pyramid-shaped stage appeared in 1971 and the shape stuck.",
        "The festival began on a dairy farm, and after it ends the fields go back to the cows. They are very forgiving.",
        "When it rains the mud becomes a sport. Wellies are practically a uniform."]),
    ("pyramid_soundtech", "student", 9, 3, "Sound Tech", [
        "Please do not shout into the microphone. Shout in the empty field outside, it carries beautifully."])], 15, 11)
add("glastonbury_home1", "Vowles' House", "glastonbury", (6, 8), "home", [
    ("glaston_home1_gran", "mum", 5, 3, "Granny Vowles", [
        "Hello, my lover. Sit, sit. That hat is ansum. That means lovely, in case you wondered.",
        "Hazeldoze sleep for about half the year. I wish I was so lucky. I have the cat to feed.",
        "Every Christmas we hang a sprig of the Holy Thorn in the window. The children think it is magic. I let them."])], 11, 9)
add("glastonbury_home2", "Pomeroy's House", "glastonbury", (12, 10), "cottage", [
    ("glaston_home2_farmer", "farmer", 5, 3, "Mr Pomeroy", [
        "Come in. Mind the boots. Mind the dog. Mind the dog's boots.",
        "Gurt big hill, the Tor. That is 'great' in Somerset. It is about 158 metres high, and the tower on top is St Michael's.",
        "Old farmers say a field with a Thornsow in it never needs a gate. I tried it. The cows were not impressed."])], 11, 9)
add("glastonbury_home3", "Bryony's House", "glastonbury", (17, 8), "home", [
    ("glaston_home3_student", "student", 5, 3, "Bryony", [
        "I help clear up after the festival every year. Around two hundred thousand people come, which is bigger than most Somerset towns.",
        "Folk tales say Wispet lights lead you off the path on the moor. I use a torch.",
        "If you get pixy-led, turn your coat inside out. That is the old way to break the spell. It works about as well as a map."])], 11, 9)

# ------------------------------------------------------------------ MENDIPS
add("mendips_cheese", "Cheddar Cheese Company", "mendips", (7, 17), "workshop", [
    ("cheddar_cheesemonger", "farmer", 6, 4, "Cheesemonger", [
        "Welcome to the cheese shop. Cheddar is a place first and a cheese second.",
        "In 1170 King Henry II bought over four tonnes of Cheddar in one go. A famously large sandwich.",
        "The trick is called cheddaring. You stack slabs of curd to squeeze out the whey. Oddly satisfying.",
        "The caves in the gorge keep a steady cool temperature, which is perfect for ripening. Our cheese lives in there like a very patient guest."])])
add("mendips_gorgecafe", "Gorge Cafe", "mendips", (6, 28), "cafe", [
    ("gorgecafe_cook", "villager_6", 4, 3, "Cook", [
        "Walkers, climbers, goat watchers, everyone ends up here. The gorge makes people hungry.",
        "The cliffs rise to about 137 metres, which makes this the biggest gorge in Britain.",
        "Wild goats and Soay sheep live on the cliffs. Do not offer them a sandwich, they will take the whole bag.",
        "Take a flask of tea for the climb. Bring the flask back if you remember."],
     ("mendips_gorgecafe_gift", "flask_of_tea", "Back for another flask? You have a very thirsty cliff in front of you, I see.")),
    ], 11, 9)
add("mendips_cave", "Cave Tours", "mendips", (12, 28), "museum", [
    ("cave_tour_guide", "tour_guide", 5, 4, "Cave Guide", [
        "Welcome to the caves. Hard hats are optional, but sensible.",
        "In 1903 workers found a skeleton here. Cheddar Man is about 10,000 years old, Britain's oldest complete skeleton.",
        "In 1997 scientists tested the DNA of a local history teacher, Adrian Targett, and found he was related to Cheddar Man. Imagine the family reunion.",
        "Later research suggested Cheddar Man had dark skin and blue eyes. The first Britons were more varied than people expected."])])
add("mendips_strawberry", "Strawberry Barn", "mendips", (58, 17), "mill", [
    ("strawberry_picker", "villager_1", 6, 4, "Berry Picker", [
        "June is strawberry season, and the whole place smells like jam.",
        "The Cheddar Valley railway used to carry strawberries to the cities in Victorian days. It closed to trains in 1963 but folk still call the old line the Strawberry Line.",
        "Now it is a walking and cycling path. Fewer trains, the same strawberries."])])

# ------------------------------------------------------------------ SOMERSET LEVELS
add("levels_church", "Ruined Church", "somerset_levels", (46, 12), "church", [
    ("levels_church_warden", "villager_3", 5, 3, "Volunteer Warden", [
        "Welcome to the hilltop ruins. On a clear day you can see for miles across the Levels.",
        "King Alfred hid on the Isle of Athelney near here in 878, while Danish armies ruled the land. In the story, he burned some cakes.",
        "When the winter floods come, the Levels turn into a huge shining lake. Hills like this one become islands again."])], 11, 9)
add("levels_willows", "Willows and Wetlands Centre", "somerset_levels", (17, 22), "workshop", [
    ("willows_weaver", "villager_4", 6, 4, "Basket Weaver", [
        "Willow, withy, osier, all the same plant with three names. We grow it right here on the Levels.",
        "Cut in winter, the stems grow back thick and straight each year. We weave them into baskets and fences.",
        "Some willow is burnt into charcoal for artists. It draws beautifully and smells of bonfires.",
        "The ditches round here are called rhynes, and they are said 'reens'. Say it as 'rhymes' and the locals will smile politely."])])
add("levels_hide", "Bird Hide", "somerset_levels", (5, 29), "cottage", [
    ("hide_birder", "birdwatcher", 5, 3, "Birder", [
        "Shh, whisper only. The sign says 'quiet', and the birds agree.",
        "In midwinter the Levels host starling murmurations, tens of thousands of birds moving as one cloud at dusk.",
        "Cranes died out in Britain centuries ago. A project released young cranes on the Levels in 2010, and they have been breeding since.",
        "Listen for the bittern. It booms from the reeds like someone blowing across a very large bottle."])], 11, 9)
add("levels_cider", "Cider Farm", "somerset_levels", (28, 13), "mill", [
    ("levels_orchardist", "farmer", 6, 4, "Orchardist", [
        "Welcome to the orchard barn. Today we are only talking about apples.",
        "Somerset has hundreds of old apple varieties, with names like Slack-ma-Girdle, Kingston Black and Tom Putt.",
        "Bittersweet apples are too sharp to eat but the juice is wonderful. Blossom week is the best of the year, white and pink all the way to the horizon."])])
add("levels_pump", "Pumping Station", "somerset_levels", (44, 30), "mill", [
    ("levels_pump_engineer", "steelworker", 6, 4, "Engineer", [
        "Mind the machinery. It is not running, it is a museum piece, but it likes to be respected.",
        "Much of the Levels is barely above sea level. Without pumps, a lot of it would be under water.",
        "This pumping station was built in 1830 and its old steam engines worked until 1951. That is a very long shift."])])

# ------------------------------------------------------------------ PENZANCE
add("penzance_pastyco", "Pasty Co.", "penzance", (23, 18), "cafe", [
    ("pastyco_baker", "shopkeeper", 4, 3, "Baker", [
        "A proper Cornish pasty has beef, potato, swede and onion. Nothing else.",
        "The crimp goes on the side, never the top. Since 2011 only pasties made in Cornwall can use the name.",
        "Pasties were made for tin miners to carry underground. The thick crust kept them warm for hours.",
        "Take a pasty for later. Eat it on a clifftop, it is the law."],
     ("penzance_pastyco_gift", "pasty", "Already had your pasty! One per customer. The seagulls are watching.")),
    ], 11, 9)
add("penzance_benbow", "Admiral Benbow", "penzance", (38, 18), "hall", [
    ("benbow_host", "fisher", 6, 4, "Innkeeper", [
        "Welcome to the Admiral Benbow. Mind the ship's figurehead. He stares.",
        "Penzance was a smugglers' haven in the 1700s. Cornwall's coves were perfect for slipping cargo ashore.",
        "The name comes from Admiral John Benbow, a real Royal Navy admiral. Robert Louis Stevenson borrowed it for the inn in Treasure Island."])])
add("penzance_books", "Chapel Street Books", "penzance", (47, 17), "library", [
    ("penzance_bookseller", "poet", 6, 3, "Bookseller", [
        "Browse away. The Cornwall shelf is the biggest, and the most argued over.",
        "Penzance comes from the Cornish 'Pen Sans', which means Holy Headland.",
        "Sir Humphry Davy was born here in 1778. He invented a safety lamp for miners in 1815.",
        "Gilbert and Sullivan's Pirates of Penzance first appeared in 1879, in New York. Penzance never got over it."])])
add("penzance_engine", "Engine House", "penzance", (15, 29), "mill", [
    ("engine_keeper", "tin_miner", 6, 4, "Engine Keeper", [
        "Careful near the old engine. It is retired and still grumpy.",
        "Cornish engines pumped water out of deep mines. Without them, the tin and copper mines would have flooded.",
        "Richard Trevithick, from near Camborne, drove a steam road carriage up Camborne Hill on Christmas Eve, 1801.",
        "The mining landscape of Cornwall and west Devon became a World Heritage Site in 2006."])])
add("penzance_mount", "St Michael's Mount", "penzance", (58, 34), "castle", [
    ("mount_guide", "tour_guide", 5, 4, "Guide", [
        "Welcome to St Michael's Mount. Hopefully you crossed the causeway at low tide, not the sea at high tide.",
        "Monks lived here from the 1000s, linked to Mont-Saint-Michel in France. The two islands are practically twins.",
        "The St Aubyn family has lived here since the 1650s. They still do, and the view is superb.",
        "The causeway disappears under the sea twice a day. Check the tide table."])])
add("penzance_home1", "Trevenna's Cottage", "penzance", (5, 18), "cottage", [
    ("penz_home1_mum", "mum", 5, 3, "Mrs Trevenna", [
        "Dydh da! That is 'good day' in Cornish. Come in, kettle's on dreckly.",
        "Dreckly is Cornish for 'some time, maybe, no rush'. It is not the same as 'now'.",
        "Chipgulls will take the pasty right out of your hand. Hold it tight and glare.",
        "My grandson says 'meur ras' for thank you. I taught him that. And the cat."])], 11, 9)
add("penzance_home2", "Penhaligon's House", "penzance", (55, 17), "home", [
    ("penz_home2_fisher", "fisher", 5, 3, "Mr Penhaligon", [
        "Newlyn harbour is my patch. It is one of the busiest fishing ports in England.",
        "Baskling come into the bay in summer with their mouths open. They only eat plankton, so say hello.",
        "On 23 December in Mousehole, folk eat Stargazy pie, with fish heads poking out the crust. It remembers Tom Bawcock, who caught fish in a storm."])], 11, 9)
add("penzance_home3", "Old Jory's Cottage", "penzance", (54, 38), "cottage", [
    ("penz_home3_jory", "fisherman_north", 5, 3, "Old Jory", [
        "We call summer visitors emmets. It means ant in Cornish. Do not take offence. We love them, mostly.",
        "My dad was a tin miner. He believed in the knockers, little folk who tapped the rock. He left them a bit of pasty crust.",
        "Gannets dive off this coast from up to 30 metres, folding their wings at the last moment. Eat your heart out, Olympics."])], 11, 9)
add("penzance_home4", "Meryn's House", "penzance", (59, 39), "home", [
    ("penz_home4_meryn", "student", 5, 3, "Meryn", [
        "Take a coat. It is mizzle out there. That is mist and drizzle, all in one go.",
        "The Jubilee Pool is a seawater lido from 1935, Art Deco style. It has been brave-swum since before my dad.",
        "Say 'proper job' when something goes well. That means well done. Say it about my sandcastle and I will be very proud.",
        "Mum insists you take a flask of tea. I cannot stop her."],
     ("penz_home4_gift", "flask_of_tea", "Mum says one flask is plenty. She will not say that twice.")),
    ], 11, 9)

# ------------------------------------------------------------------ TINTAGEL
add("tintagel_castle", "Tintagel Castle", "tintagel", (11, 12), "castle", [
    ("tintagel_castle_guide", "tour_guide", 5, 4, "Heritage Guide", [
        "Welcome to Tintagel Castle, or what the sea has left of it.",
        "Richard, Earl of Cornwall, built the castle in the 1230s, probably to link himself to the legend of King Arthur.",
        "Archaeologists found imported Mediterranean pottery here, from long before the castle. This was a rich trading place about 1,500 years ago.",
        "The name Tintagel probably comes from Cornish and means something like fort of the narrow neck."])])
add("tintagel_greathall", "Great Hall", "tintagel", (14, 16), "hall", [
    ("tintagel_hall_guide", "villager_2", 5, 4, "Hall Guide", [
        "This is the Great Hall, where the Earl's guests dined. Probably draughty.",
        "Geoffrey of Monmouth wrote about Arthur's birth at Tintagel in 1138. That is the first time Arthur was linked to this spot.",
        "Merlin's Cave is at the bottom of the cliff. It floods at high tide, so check the tide table first."])], 11, 9)
add("tintagel_arthurhalls", "King Arthur's Great Halls", "tintagel", (38, 10), "hall", [
    ("arthurhalls_attendant", "poet", 7, 4, "Attendant", [
        "Welcome to the Hall of Chivalry. Please do not pull a sword out of the stone. It is a real stone and it is cross.",
        "Frederick Glasscock, a London businessman, built these halls in the 1930s and spent a large part of his fortune on them.",
        "There is a Round Table here and dozens of stained glass windows, many by Veronica Whall, showing Arthur's knights and the Grail."])], 15, 11)
add("tintagel_postoffice", "Old Post Office", "tintagel", (48, 14), "cottage", [
    ("postoffice_volunteer", "villager_5", 5, 3, "Volunteer", [
        "Mind your head. The roof is the oldest saggy thing in Cornwall, apart from me.",
        "This small manor house dates from the 1300s. The National Trust bought it in 1903 for 100 pounds.",
        "In the 1840s it was the village post office, soon after the penny post began in 1840.",
        "The slate roof is so heavy the ridge bows. It looks wonky but it has held for centuries."])], 11, 9)
add("tintagel_pastyshop", "Pasty Shop", "tintagel", (49, 28), "cafe", [
    ("tintagel_pasty_seller", "shopkeeper", 4, 3, "Pasty Seller", [
        "Hot pasties, cold sea air. Tintagel was designed for this.",
        "Beef, potato, swede, onion, crimp on the side. Anything else is just a savoury pie.",
        "Folk used to shout 'Oggy oggy oggy' to miners underground. Oggy is slang for pasty. The miners shouted back.",
        "Take one for the cliff path. Eat it somewhere windy."],
     ("tintagel_pasty_gift", "pasty", "I only have one for you, sorry. Customers are queuing and the gulls are queuing too.")),
    ], 11, 9)
add("tintagel_camelot", "Camelot Shop", "tintagel", (38, 28), "workshop", [
    ("camelot_keeper", "villager_6", 5, 4, "Shopkeeper", [
        "Excalibur keyrings, dragon mugs and Merlin hats. Pick your legend.",
        "Somerset has a rival Camelot, at Cadbury Castle, an old hill fort. Tintagel folk are polite about it, mostly.",
        "Tennyson's poems about Arthur made Tintagel famous in Victorian times. He visited in 1848."])], 11, 9)
add("tintagel_materiana", "St Materiana's", "tintagel", (37, 38), "church", [
    ("materiana_warden", "villager_3", 6, 3, "Churchwarden", [
        "Welcome to St Materiana's. Most of the building is Norman, with later additions.",
        "Cornwall has hundreds of local saints, and Materiana's story is a mystery. That suits Cornwall rather well.",
        "Look up for the Cragchough over the cliffs. Choughs vanished from Cornwall in the 1970s and came back in 2001."])], 11, 9)

# ------------------------------------------------------------------ build
WALK = ".,#=:fsw|p_+"
dlg = {}
zones = {}


def zone(zid):
    if zid not in zones:
        zones[zid] = json.load(open(os.path.join(OUT, zid + ".json")))
    return zones[zid]


def occupied(td):
    s = set()
    for p in td["props"]:
        if p["type"] == "building":
            for yy in range(int(p["y"]), int(p["y"] + p["h"])):
                for xx in range(int(p["x"]), int(p["x"] + p["w"])):
                    s.add((xx, yy))
        else:
            s.add((int(p["x"]), int(p["y"])))
    for n in td["npcs"]:
        s.add((int(n["x"]), int(n["y"])))
    return s


def setrow(td, x, y, ch):
    r = td["rows"][y]
    td["rows"][y] = r[:x] + ch + r[x + 1:]


# tile fixes and new houses first
for zid, fixes in TILE_FIX.items():
    td = zone(zid)
    for x, y, ch in fixes:
        setrow(td, x, y, ch)
for p in zone("bath")["props"]:  # the bench at (43,27) blocked the new landing stage for the Tea Rooms door
    if p["type"] == "bench" and p["x"] == 43 and p["y"] == 27:
        p["y"] = 29.0
for zid, houses in NEW_HOUSES.items():
    td = zone(zid)
    for style, x, y, w, h in houses:
        if any(p["type"] == "building" and int(p["x"]) == x and int(p["y"]) == y for p in td["props"]):
            continue
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                assert td["rows"][yy][xx] in ".,f", (zid, xx, yy, td["rows"][yy][xx])
                setrow(td, xx, yy, "B")
        td["props"].append({"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h})


def free(z, x, y, w, h):
    if not (1 <= x < w - 1 and 2 <= y <= h - 4):
        return False
    if z.g[y][x] not in "|+":
        return False
    if x == w // 2 and y >= h - 5:
        return False
    return not any(int(p["x"]) == x and int(p["y"]) == y for p in z.d["props"])


for zid, name, zn, door, kind, npcs, w, h in L:
    td = zone(zn)
    dx, dy = door
    ret = (dx, dy + 1)
    # validate the building and the tile south of the door
    bld = [p for p in td["props"] if p["type"] == "building" and int(p["x"]) <= dx < p["x"] + p["w"]
           and int(p["y"] + p["h"] - 1) == dy]
    assert len(bld) == 1, (zid, "no building", door)
    assert td["rows"][dy][dx] in "BD", (zid, td["rows"][dy][dx])
    assert td["rows"][ret[1]][ret[0]] in WALK, (zid, "south tile", td["rows"][ret[1]][ret[0]])
    assert (ret[0], ret[1]) not in occupied(td), (zid, "south tile occupied")
    # interior: first pass for props, then place NPCs on free tiles
    z0 = landmark(OUT, zid, name, zn, ret, kind, [], w, h)
    nl = []
    for n in npcs:
        nid, spr, x, y, who, lines = n[:6]
        if kind in ("home", "cottage") and (x, y) == (5, 3):
            x = w - 4  # the middle of a home is table and bench; stand by the open side
        if not free(z0, x, y, w, h):
            cands = [(abs(xx - x) + abs(yy - y), xx, yy) for yy in range(2, h - 3) for xx in range(1, w - 1)
                     if free(z0, xx, yy, w, h) and not any((nn["x"], nn["y"]) == (xx, yy) for nn in nl)]
            assert cands, (zid, nid)
            _, x, y = min(cands)
            print("moved", nid, "->", x, y)
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        for t in lines:
            assert len(t) <= 200, (zid, len(t), t)
            assert "—" not in t and "–" not in t and " - " not in t, t
        if len(n) > 6:
            flag, item, again = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1},
                          {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, zn, ret, kind, nl, w, h)
    # patch the zone: door tile and warp
    setrow(td, dx, dy, "D")
    if not any(int(p["x"]) == dx and int(p["y"]) == dy for p in td["warps"]):
        td["warps"].append({"x": dx, "y": dy, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})

for zid, td in zones.items():
    json.dump(td, open(os.path.join(OUT, zid + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print(len(L), "interiors")
