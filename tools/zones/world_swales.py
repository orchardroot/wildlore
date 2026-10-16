"""World pass 1.1 (group swales): walk-in interiors for Aberystwyth, Cardiff, St Davids, the Beacons,
the Pembroke coast, the Severn crossing and the Cambrian coast.
Run: python3 tools/zones/world_swales.py data/zones
Edits the town JSON in place (adds doors, warps, a few new homes, a pier deck), writes the interiors and their
dialogue. Idempotent: running it twice gives the same result."""
import json, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
BLOCK = set("TPHWFR^Bx~o$!C")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# New buildings (unlabelled homes) and tile patches to apply to the towns before doors are cut.
NEW_BUILDINGS = {
    "cardiff": [(3, 31, 5, 3, "terrace"), (8, 31, 4, 3, "terrace"), (52, 31, 4, 2, "red_brick")],
    "st_davids": [(3, 9, 4, 3, "slate_cottage")],
}
TILE_PATCH = {"aberystwyth": [(3, 27, "_"), (4, 27, "_"), (5, 27, "_")]}  # a short pier deck under the Pavilion door

# (zone, zid, name, kind, (bx, by), door_col or None, w, h, npcs)
# npc = (id, sprite, who, lines, gift)   gift = (flag, item, repeat line) or None; the gift is the LAST line.
S = []


def add(zone, zid, name, kind, anchor, npcs, w=13, h=10, col=None):
    S.append((zone, zid, name, kind, anchor, col, w, h, npcs))


# ---------------------------------------------------------------- Aberystwyth
add("aberystwyth", "aberystwyth_pier", "Royal Pier Pavilion", "theatre", (1, 24), [
    ("pier_manager", "villager_4", "Pier Manager", [
        "Welcome aboard. Technically you are standing on a pier, which is a seaside street that gave up on land.",
        "Aberystwyth's Royal Pier opened in 1865, designed by Eugenius Birch. He built piers all round Britain, so he knew a good plank.",
        "The sea has taken bites out of it over the years. The Pavilion at the end gets a fresh coat of paint every time it sulks."], None),
    ("pier_harpist", "harpist", "Harpist", [
        "A harp carries well over the waves. It is louder than a tuba and the gulls like it even less.",
        "The Welsh triple harp, telyn deires, has three rows of strings. Learning it takes about three times as long as the ordinary kind."], None),
], 13, 10, col=2)
add("aberystwyth", "aberystwyth_cliffrail", "Cliff Railway", "museum", (13, 12), [
    ("cliff_driver", "villager_3", "Railway Driver", [
        "Mind the doors. Up we go, all 237 metres of it, at a stately pace.",
        "The Cliff Railway opened in 1896 and climbs Constitution Hill. It is the longest electric cliff railway in Britain.",
        "Two cars run on one cable, so one goes up as the other comes down. Very tidy. The gulls ride free and tip nothing."], None),
    ("cliff_walker", "hillwalker", "Walker", [
        "I came up on the railway and I am walking down. It is the only fair way to treat my knees.",
        "From the top you get a sweep of Cardigan Bay. On a clear day, anyway. On a cloudy day you get my sandwich."], None),
], 11, 9)
add("aberystwyth", "aberystwyth_camera", "Camera Obscura", "museum", (12, 1), [
    ("camera_guide", "tour_guide", "Obscura Guide", [
        "Dim the lights. A camera obscura is a dark room with a lens that throws the outside world onto a table. No batteries needed.",
        "The name is Latin for dark chamber. People used the trick for centuries before anyone invented the camera.",
        "The one on Constitution Hill has a very large lens, said to be one of the biggest of its kind. You can pick out gulls on the bay without squinting."], None),
], 11, 9)
add("aberystwyth", "aberystwyth_oldcollege", "Old College", "hall", (38, 7), [
    ("oldcollege_archivist", "prof_garside", "Archivist", [
        "Welcome to the Old College. It began as a grand seaside hotel, the owner ran out of money, and the university moved in. Education: better than rooms.",
        "The University College of Wales opened here in 1872. Much of the money came from ordinary people, including pennies from miners and quarrymen.",
        "That is why people call it the people's university. The Gothic building was designed by J. P. Seddon, and yes, it does look like a castle that took a degree."], None),
    ("oldcollege_student", "student", "Student", [
        "Aber is what everyone calls the town. Aber means mouth of, so Aberystwyth is the mouth of the Ystwyth.",
        "Half of Wales has an Aber in its name. Aberdare, Abergavenny, Aberaeron. They are all someone's river mouth."], None),
], 15, 10)
add("aberystwyth", "aberystwyth_hughowen", "Hugh Owen Library", "library", (38, 13), [
    ("hughowen_librarian", "villager_6", "Librarian", [
        "Quiet please. Well, studious. Welcome to the Hugh Owen Library.",
        "It is named after Sir Hugh Owen, who spent his life campaigning for proper schools and colleges in Wales. He helped found the university here.",
        "In 1919 Aberystwyth set up the first chair of International Politics anywhere in the world, to study how to avoid another war. Quite a good idea, really."], None),
    ("hughowen_reader", "student", "Student", [
        "It is exam season. Shh. A gull sat on the windowsill all morning and I swear it was reading over my shoulder."], None),
], 13, 10)
add("aberystwyth", "aberystwyth_nlw", "National Library of Wales", "library", (46, 13), [
    ("nlw_archivist", "prof_garside", "Archivist", [
        "Croeso. This is the National Library of Wales. Since 1911 it has been entitled to a free copy of every book published in Britain.",
        "We keep the Black Book of Carmarthen, from around 1250. It is thought to be the oldest surviving manuscript written entirely in Welsh.",
        "We also hold the Hengwrt Chaucer, one of the very earliest copies of the Canterbury Tales. Do not breathe on it, but do admire it."], None),
    ("nlw_reader", "student", "Reader", [
        "I am tracing my family tree. So far it leads to a farm, a chapel and a long argument about a gate."], None),
], 15, 11)
add("aberystwyth", "aberystwyth_chippy", "The Chippy", "cafe", (34, 22), [
    ("chippy_cook", "villager_2", "Chippy Cook", [
        "Salt and vinegar? Hold the bag in both hands. The gulls have been watching you since you came in.",
        "Fish and chips were never rationed in the Second World War. The government decided a hot bag of chips was good for morale.",
        "You will meet Chipgulls all over Aberystwyth. They are loud, bold and have never paid for a chip in their lives. Bring a snare, not a sandwich."], None),
], 13, 10)
add("aberystwyth", "aberystwyth_icecream", "Ice Cream Parlour", "cafe", (43, 22), [
    ("icecream_scooper", "villager_5", "Scooper", [
        "One scoop or two? Three if you are brave. We have seen things in the raspberry ripple.",
        "In South Wales a cafe is often called a bracchi, after Italian families who opened ice cream cafes there in the late 1800s.",
        "A 99 is a cone with a flake stuck in it. Nobody agrees exactly why it is called a 99, and everybody pretends to know."], None),
], 11, 9)
add("aberystwyth", "aberystwyth_marineterrace", "Marine Terrace Guesthouse", "home", (15, 16), [
    ("marineterrace_landlady", "mum", "Mrs Pugh", [
        "Croeso! Small rooms, big welcome, and wallpaper older than the railway.",
        "The railway reached Aberystwyth in 1864 and the Victorians arrived by the trainload. The terraces on the front were built for them. This is one.",
        "In winter, starlings roost under the pier at dusk, thousands of them. We switch the lights off and watch. Free show, and no ticket.",
        "Here, a cuppa for the road. You look like you have walked the Prom twice.",
        ], ("swales_marineterrace_gift", "cup_of_tea", "Another cup? You will slosh. Off you go, bach.")),
    ("marineterrace_lodger", "hillwalker", "Lodger", [
        "Mrs Pugh's sofa is a proper cwtch. That is Welsh for a cosy cuddle, or a snug corner. I have not left it in three days."], None),
], 13, 10)
add("aberystwyth", "aberystwyth_arts", "Aber Arts", "theatre", (21, 31), [
    ("arts_boxoffice", "villager_1", "Box Office", [
        "Tickets? Sit anywhere. The seats are comfy and the plays have so far been free of seagulls.",
        "The National Eisteddfod is a week-long festival of Welsh music, poetry and dance. The word means a sitting. It moves between North and South Wales each year.",
        "The modern festival began in 1861, though bards have been competing for centuries. A good poem here can win you a chair. A real one."], None),
    ("arts_singer", "choir_singer", "Singer", [
        "Cân is song. And hwyl is the feeling that takes over when a whole hall sings together. Hear it once and you will know."], None),
], 13, 10)
add("aberystwyth", "aberystwyth_castle", "Aberystwyth Castle Gatehouse", "castle", (15, 36), [
    ("castle_custodian", "tour_guide", "Custodian", [
        "Welcome to the castle. Mostly it is a view with some walls around it.",
        "Edward I began it in 1277 to keep Wales in check. Owain Glyndwr captured it in 1404 and held it for several years.",
        "In the 1600s Charles I had a royal mint here, striking silver coins from Welsh mines. Aberystwyth money. Please check your pockets."], None),
], 11, 9)
add("aberystwyth", "aberystwyth_home_pier", "Pier Street House", "home", (49, 22), [
    ("pierst_nain", "villager_2", "Nain", [
        "Come in, bach. That means little one, though round here it means anyone from two to a hundred and two.",
        "Hiraeth is a Welsh word for a homesickness that English has no word for. Fishermen's families knew it well, and so do students in their first term.",
        "Chipgulls are clever. They never go for what you are holding, they go for what you are not watching. Keep chips in a pocket, not a packet."], None),
    ("pierst_boy", "villager_6", "Gethin", [
        "Nain bakes Welsh cakes on the bakestone every Sunday. Picau ar y maen, cakes on the stone. If I am not home by two, none are left."], None),
], 13, 10)
add("aberystwyth", "aberystwyth_home_harbour", "Harbour Cottage", "cottage", (23, 16), [
    ("harbour_fisher", "fisherman_north", "Idris", [
        "I used to row out of the harbour before dawn. Now I only say I did.",
        "Two rivers meet at the harbour here, the Ystwyth and the Rheidol. The tide has opinions about both of them."], None),
    ("harbour_wife", "villager_4", "Mair", [
        "Idris, do not be so twp, it is a coat and not a sail! Twp means a bit daft, you know. Said with love.",
        "He has a boat in a bottle on every shelf. I counted eleven. I have given up counting."], None),
], 11, 9)
add("aberystwyth", "aberystwyth_home_digs", "Student Digs", "home", (14, 31), [
    ("digs_student", "student", "Student", [
        "We have one working radiator and three opinions about the washing up.",
        "There is a tradition that you walk the Prom and kick the bar at the north end. Do not ask why. Just do it, and bring dry socks.",
        "Chipgulls on the front are fearless. A friend of mine lost a pasty to one and it looked her straight in the eye while she did it."], None),
], 11, 9)

# ---------------------------------------------------------------- Cardiff
add("cardiff", "cardiff_castle", "Cardiff Castle", "castle", (24, 5), [
    ("cardiffcastle_guide", "tour_guide", "Castle Guide", [
        "Welcome to Cardiff Castle: a Roman wall, a Norman keep and a Victorian fantasy. Pick an era.",
        "The Romans built a fort here about AD 55. The Normans added a great mound and keep inside the old walls.",
        "In the 1800s the third Marquess of Bute, one of the richest men in the world, hired William Burges to turn the castle into a Gothic fairy tale."], None),
    ("cardiffcastle_steward", "villager_1", "Steward", [
        "Have you seen the Animal Wall outside? Stone lions, a bear, baboons and a hyena. Burges liked variety."], None),
], 15, 11, col=6)
add("cardiff", "cardiff_arcade", "Castle Arcade", "cafe", (2, 5), [
    ("arcade_baker", "mum", "Welsh Cake Baker", [
        "Warm Welsh cakes, straight from the bakestone. Do not blow on them. Just burn your tongue like everyone else.",
        "In Welsh they are picau ar y maen, cakes on the stone. Maen is stone, so the old way was a flat griddle stone over a fire.",
        "Cardiff is famous for its Victorian and Edwardian arcades. They kept shoppers dry long before umbrellas were any good, and still do."], None),
    ("arcade_shopper", "villager_5", "Shopper", [
        "I came in for one thing and left with a hat, a record and a bag of sweets. The arcade does that."], None),
], 13, 10)
add("cardiff", "cardiff_chippy", "Grange Chippy", "cafe", (10, 5), [
    ("grange_cook", "villager_3", "Chippy Cook", [
        "Grangetown's finest. Fish, chips and a good gossip, all included in the price.",
        "Cardiff grew rich on coal. By 1913 it was the busiest coal-exporting port in the world, and the dockers needed feeding.",
        "In Cardiff, if something is good you say it is tidy. Do not ask me why. A really good portion of chips is tidy."], None),
], 11, 9)
add("cardiff", "cardiff_wmc", "Wales Millennium Centre", "theatre", (36, 26), [
    ("wmc_usher", "villager_4", "Usher", [
        "Welcome to the Wales Millennium Centre. It opened in 2004 and it is the home of Welsh National Opera.",
        "Look up at the front. The huge poem is by Gwyneth Lewis. In English it reads: In these stones horizons sing.",
        "The Welsh line is Creu gwir fel gwydr o ffwrnais awen. The building is wrapped in Welsh slate in many shades, from several different quarries."], None),
    ("wmc_harpist", "harpist", "Harpist", [
        "The acoustics here are famous, so please hush while I tune. It takes me longer than the show."], None),
], 15, 11)
add("cardiff", "cardiff_pierhead", "Pierhead Building", "museum", (48, 26), [
    ("pierhead_guide", "prof_garside", "Visitor Guide", [
        "Welcome to the Pierhead Building. It went up in 1897 for the Bute Dock Company, in red terracotta that glows at sunset.",
        "The style is French Gothic, and the clock tower looks like a cousin of Big Ben who has been on holiday in France.",
        "Next door is the Senedd, the Welsh Parliament building, all glass and slate, opened in 2006. It was made to be see-through on purpose."], None),
], 13, 10)
add("cardiff", "cardiff_norwegian", "Norwegian Church", "cafe", (55, 27), [
    ("norwegian_host", "villager_2", "Church Host", [
        "Hei! Velkommen. This church was built in 1868 so that Norwegian sailors in Cardiff had somewhere to worship and a taste of home.",
        "Roald Dahl was baptised here. His parents were Norwegian, and he was born in nearby Llandaff in 1916.",
        "The church was later moved, restored and reopened as an arts centre with a cafe. You can see the bay from the window."], None),
    ("norwegian_fan", "student", "Dahl Fan", [
        "I have read every Roald Dahl book. I still check my chocolate bars for suspicious golden tickets."], None),
], 13, 10)
add("cardiff", "cardiff_home_grange", "Grangetown House", "home", (3, 31), [
    ("grange_mamgu", "mum", "Mamgu", [
        "Come in, mind the cat. Mamgu is what we call grandmother in the south, and I have been one for six years.",
        "A cwtch is a cuddle. It is also the cupboard under the stairs. Both are good places to hide when the washing up starts.",
        "Cardiff gulls nest on the shop roofs. Chipgulls, you would call them. Try a snare and stay brave. They are bold little rascals.",
        "Here, a slice of my bara brith for the road. Do not tell the Chipgulls."],
     ("swales_grange_gift", "bara_brith", "Another slice? You will burst, cariad. Off you go.")),
], 11, 9)
add("cardiff", "cardiff_home_bute", "Butetown House", "home", (8, 31), [
    ("bute_oldman", "fisherman_north", "Old Dockworker", [
        "Alright, mush. That is what we say in Cardiff. Mush means mate.",
        "This is Butetown, known as Tiger Bay. Sailors from all over the world lived here, and it is one of the oldest mixed communities in Britain.",
        "Shirley Bassey grew up round the corner. When she sang, the whole bay listened. So did the Chipgulls, but only for chips."], None),
], 11, 9)
add("cardiff", "cardiff_home_roath", "Roath House", "cottage", (52, 31), [
    ("roath_dad", "villager_1", "Dad", [
        "Rugby on the telly, bags in the hall, boots on the wrong feet. It is Saturday in Cardiff.",
        "The Principality Stadium holds about 74,500 people. When Wales score, the city can hear it. Cardiff became Wales's capital in 1955.",
        "Our Ffion starts school rugby next week. Her tackle is lethal and her sandwiches are worse. That is a family tradition."], None),
], 11, 9)

# ---------------------------------------------------------------- St Davids
add("st_davids", "stdavids_giftshop", "The Enclosure Gift Shop", "workshop", (26, 12), [
    ("giftshop_clerk", "villager_2", "Shop Assistant", [
        "Welcome to the Enclosure Gift Shop. Everything here has been carefully curated. That means we put a price on it.",
        "We sell tea towels, fudge, and a miniature puffling that is, strictly speaking, a sock.",
        "Fewer than two thousand people live in St Davids, yet it is a city. It has been one since medieval times, because of the cathedral."], None),
], 13, 10)
add("st_davids", "stdavids_orielyparc", "Oriel y Parc", "museum", (34, 12), [
    ("oriel_host", "villager_4", "Gallery Host", [
        "Croeso to Oriel y Parc. Oriel means gallery and parc means park, so you are in the Park Gallery. Handy.",
        "This is the visitor centre for the Pembrokeshire Coast National Park, made a park in 1952. It is Britain's only national park that is mostly coast.",
        "Upstairs there is art from the National Museum Wales collection, picked to show you the landscape you have been walking through."], None),
    ("oriel_ranger", "hillwalker", "Ranger", [
        "Watch the cliffs for choughs. Real ones have red legs and a red beak. The Cragchough you can find on the cliffs is a rather bigger cousin."], None),
], 13, 10)
add("st_davids", "stdavids_tearooms", "Tea Rooms", "cafe", (11, 5), [
    ("tearooms_server", "mum", "Tea Room Server", [
        "Sit anywhere, cariad. Cariad means darling. Everyone in Pembrokeshire is cariad until they leave a gate open.",
        "Bara brith means speckled bread. The fruit soaks overnight in tea, so by morning it is plump as a puffling.",
        "Here, a slice for the road. You look like you have walked the coast path, or at least thought about it."],
     ("swales_tearooms_gift", "bara_brith", "Another slice? You will sink the boat. Off you go, cariad.")),
], 11, 9)
add("st_davids", "stdavids_hostel", "Pilgrim Hostel", "hall", (26, 4), [
    ("hostel_warden", "villager_6", "Hostel Warden", [
        "Welcome, pilgrim. The beds are narrow but the stories are wide.",
        "In the Middle Ages the Pope ruled that two pilgrimages to St Davids were worth one to Rome. Three were worth one to Jerusalem. A bargain.",
        "David is Dewi Sant in Welsh, the patron saint of Wales. His day is the first of March, when people wear a leek or a daffodil."], None),
    ("hostel_pilgrim", "hiker", "Pilgrim", [
        "I walked the coast path to get here. My feet say it was the long way. The cathedral says well done."], None),
], 13, 10)
add("st_davids", "stdavids_palace", "Bishop's Palace", "castle", (34, 26), [
    ("palace_custodian", "tour_guide", "Custodian", [
        "Welcome to the Bishop's Palace. It is a ruin now, but it was a rather posh ruin before it was a ruin.",
        "Bishop Henry de Gower built most of what you see between 1328 and 1347. Look for the arcaded parapets, rows of stone arches along the top, just for show.",
        "One bishop is said to have sold the lead off the roof. After that the Welsh weather did the rest."], None),
], 15, 10)
add("st_davids", "stdavids_home_cottage", "Fisherman's Cottage", "cottage", (41, 13), [
    ("sd_fisher", "fisherman_north", "Mr Griffiths", [
        "Ramsey Island is across the sound. The Welsh name is Ynys Dewi, St David's Island. It is much too small to be as dramatic as it is.",
        "In autumn the seals have pups on the beaches there. White, fluffy and furious. Give them room.",
        "Pufflings waddle on the cliff top. Never stand between a Puffling and its burrow. It will take it personally."], None),
    ("sd_daughter", "villager_6", "Seren", [
        "Dad says when the sea and the choir are in tune you have got hwyl. That is spirit and swing, all at once. I am working on it."], None),
], 11, 9)
add("st_davids", "stdavids_home_close", "Close Cottage", "cottage", (4, 5), [
    ("close_gran", "villager_2", "Mrs Jenkins", [
        "Hello, love. Gwylan is the Welsh word for a gull. They steal the chips and the dignity, in that order.",
        "Cragchoughs nest on the cliffs and tumble about for the sheer joy of it. Petrelash skim the spray, tiny and quick. Be quick, they vanish before you say their name."], None),
], 11, 9)
add("st_davids", "stdavids_home_hollow", "Hollow House", "home", (3, 9), [
    ("hollow_mam", "mum", "Mam", [
        "Come in, cariad. Mind the washing, it is mostly Dad's socks.",
        "The cathedral sits in a hollow so Viking raiders could not spot it from the sea. They found it anyway, which tells you how much they liked a good cathedral.",
        "Our Cai is doing a school project on St David. He keeps telling people he could live on bread and water. Then he asks for more bread."], None),
], 11, 9)

# ---------------------------------------------------------------- routes
add("beacons", "beacons_storeyarms", "Storey Arms Outdoor Centre", "school", (4, 21), [
    ("storeyarms_instructor", "hillwalker", "Outdoor Instructor", [
        "Waterproofs on, spirits up. Storey Arms is where the main Pen y Fan path begins, and it is nearly all up.",
        "Pen y Fan is 886 metres, the highest peak in southern Britain. The park is Bannau Brycheiniog, after the old Welsh kingdom of Brycheiniog.",
        "It is also Wales's first International Dark Sky Reserve, so on a clear night the stars come out in force.",
        "Take a flask, it is hot. I have a shelf of them, and every one has been to the top."],
     ("swales_storeyarms_gift", "flask_of_tea", "Another flask? Leave some for the mountain. Off you go.")),
    ("storeyarms_cadet", "student", "Student", [
        "My group is learning to read a map. Mine says we are in the middle of a lake. It is a lovely map, to be fair."], None),
], 13, 10)
add("pembroke_coast", "pembroke_lhcottage", "Lighthouse Cottage", "cottage", (10, 6), [
    ("lhcottage_wife", "mum", "Keeper's Wife", [
        "Welcome, welcome. The lighthouse is just across the footbridge. The wind does for hairdos.",
        "Strumble Head Lighthouse was first lit in 1908 and it has been automatic since 1980. It flashes four times every fifteen seconds. We count along when we are bored.",
        "In 1797 French troops landed near Fishguard, the last invasion of Britain. Local women in red shawls and tall hats looked like soldiers from far away. The French gave up."], None),
    ("lhcottage_child", "villager_6", "Child", [
        "The Irish ferry goes by from Fishguard. I wave. Nobody waves back, but that is a ferry for you."], None),
], 11, 9)
add("severn_crossing", "severn_tolloffice", "Toll Office", "hall", (8, 14), [
    ("toll_collector", "commuter", "Toll Collector", [
        "Toll office retired. Tolls were abolished on 17 December 2018. I collect dad jokes now, and you owe me one.",
        "The Severn Bridge opened in 1966. Its deck is shaped like an aeroplane wing, so the wind slides over it instead of shoving. That was a brand new idea then.",
        "It is a long way across: the main span is 988 metres. Here is a cuppa for the road. It is free, I am out of toll booths to hide it in."],
     ("swales_toll_gift", "cup_of_tea", "Another cuppa? Careful on the bridge. Off you go.")),
    ("toll_painter", "steelworker", "Bridge Painter", [
        "They say a bridge painter's work is never done. By the time I reach the Welsh end, the English end needs another coat."], None),
], 11, 9)
add("severn_crossing", "severn_cashonly", "Cash Only Kiosk", "cafe", (12, 14), [
    ("kiosk_seller", "shopkeeper", "Kiosk Seller", [
        "Cash only, and now the tolls are gone there is nobody to give me any. I sell sandwiches and sympathy.",
        "The Severn has one of the biggest tides in the world, about 14 metres. On the biggest spring tides a wave called the Severn Bore rushes up the river and people surf it.",
        "Do not try to catch the bore on foot. It is quicker than you, and the mud is much worse."], None),
], 11, 9)
add("severn_crossing", "severn_home_keeper", "Bridge Keeper's Cottage", "cottage", (8, 24), [
    ("bridgekeeper_mum", "mum", "Mrs Hafren", [
        "Hafren is the Welsh name for the river Severn. Legend says a princess called Hafren drowned in it, and the water was named for her.",
        "At dusk the Murmurants wheel together over the mud. A thousand tiny birds, one idea. We watch from the window.",
        "My son wants to ride the bore. I have told him to start with a bath."], None),
], 11, 9)
add("severn_crossing", "severn_home_ferry", "Old Ferryman's Cottage", "cottage", (12, 24), [
    ("oldferry_sailor", "sailor", "Old Ferryman", [
        "Before the bridge opened in 1966, cars crossed the Severn on the Aust to Beachley ferry. I took thousands of them over, and a few of them came back.",
        "A Clawcastle is a walking fortress. It rarely fights. The other rock pool folk simply get out of the way.",
        "Bayrunners race the boats. They win every time and never gloat. Well, hardly ever."], None),
], 11, 9)
add("cambrian_coast", "cambrian_harlech", "Harlech Castle Gatehouse", "castle", (13, 3), [
    ("harlech_guide", "tour_guide", "Castle Guide", [
        "Welcome to Harlech Castle. Edward I built it between 1282 and 1289 on a cliff, with walls meant to be unbeatable.",
        "It once had a water gate so ships could reach it from the sea. The sea has since backed away and left the castle to enjoy the view.",
        "In the Wars of the Roses it held out for seven years, the longest siege in British history. The song Men of Harlech is said to remember it."], None),
    ("harlech_harpist", "harpist", "Harpist", [
        "I play Men of Harlech all day. It is the only tune the walls like. The rest, they have heard before."], None),
], 13, 10)


# ---------------------------------------------------------------- build
def find_building(td, ax, ay):
    for p in td["props"]:
        if p["type"] == "building" and int(p["x"]) == ax and int(p["y"]) == ay:
            return p
    raise SystemExit("no building at %s,%s in %s" % (ax, ay, td["id"]))


zones = {}


def load(zone):
    if zone not in zones:
        zones[zone] = json.load(open(os.path.join(OUT, zone + ".json")))
    return zones[zone]


def rowset(td, x, y, ch):
    r = td["rows"][y]
    td["rows"][y] = r[:x] + ch + r[x + 1:]


def occupied(td, x, y):
    for p in td["props"]:
        if p["type"] != "building" and int(p["x"]) == x and int(p["y"]) == y:
            return True
    for n in td["npcs"]:
        if int(n["x"]) == x and int(n["y"]) == y:
            return True
    for s in td.get("signs", []):
        if int(s["x"]) == x and int(s["y"]) == y:
            return True
    return False


def height(td, x, y):
    hs = td.get("heights")
    return int(hs[y][x]) if hs else 0


for zone, specs in NEW_BUILDINGS.items():
    td = load(zone)
    for (x, y, w, h, style) in specs:
        if any(p["type"] == "building" and int(p["x"]) == x and int(p["y"]) == y for p in td["props"]):
            continue
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                assert td["rows"][yy][xx] == ".", (zone, xx, yy, td["rows"][yy][xx])
                assert not occupied(td, xx, yy), (zone, xx, yy)
                rowset(td, xx, yy, "B")
        td["props"].append({"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h})
for zone, patches in TILE_PATCH.items():
    td = load(zone)
    for (x, y, ch) in patches:
        rowset(td, x, y, ch)

dlg = {}
for zone, zid, name, kind, anchor, col, w, h, npcs in S:
    td = load(zone)
    b = find_building(td, *anchor)
    bx, by, bw, bh = int(b["x"]), int(b["y"]), int(b["w"]), int(b["h"])
    assert b["style"] not in ("aqueduct", "gantry_crane", "station"), zid
    dcol = bx + (col if col is not None else (bw - 1) // 2)
    dy = by + bh - 1
    sy = dy + 1
    assert td["rows"][dy][dcol] in ("B", "D"), (zid, td["rows"][dy][dcol])
    assert not occupied(td, dcol, sy), ("south tile occupied", zid, dcol, sy)
    sc = td["rows"][sy][dcol]
    if sc in BLOCK:
        rowset(td, dcol, sy, "#")
    assert abs(height(td, dcol, dy) - height(td, dcol, sy)) <= 1, ("height step at door", zid)
    rowset(td, dcol, dy, "D")
    ret = (dcol, sy)
    # the interior, with NPCs placed on free floor
    z = landmark(OUT, zid, name, zone, ret, kind, [], w, h)
    taken = {(int(p["x"]), int(p["y"])) for p in z.d["props"]}
    dx = w // 2
    cands = [(dx, 3), (dx - 2, 3), (dx + 2, 3), (dx, 2), (dx - 1, 4), (dx + 1, 4), (3, 3), (w - 4, 3), (dx - 3, 4), (dx + 3, 4),
             (2, 3), (w - 3, 3), (2, 6), (w - 3, 6), (dx - 3, 6), (dx + 3, 6), (3, 6), (w - 4, 6)]

    def free(c):
        x, y = c
        if not (2 <= x <= w - 3 and 2 <= y <= h - 4):
            return False
        if c in taken or z.g[y][x] in ("C", "x", "D"):
            return False
        if y >= h - 4 and abs(x - dx) <= 1:
            return False
        return True
    nl = []
    for (nid, spr, who, lines, gift) in npcs:
        pos = next((c for c in cands if free(c)), None)
        assert pos, (zid, "no free spot")
        taken.add(pos)
        # keep the next NPC a tile away so nobody is boxed in
        cands = [c for c in cands if abs(c[0] - pos[0]) + abs(c[1] - pos[1]) > 1]
        z.npc(id=nid, sprite=spr, x=pos[0], y=pos[1], facing="down", move="still", script=nid)
        if gift:
            flag, item, again = gift
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag, "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        for t in lines:
            assert len(t) <= 215, (zid, len(t), t)
            assert "—" not in t and "–" not in t, (zid, t)
        dlg.setdefault(zid, {})[nid] = script
    z.save(OUT + "/" + zid + ".json")
    if not any(int(wp["x"]) == dcol and int(wp["y"]) == dy for wp in td["warps"]):
        td["warps"].append({"x": dcol, "y": dy, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})

for zone, td in zones.items():
    json.dump(td, open(os.path.join(OUT, zone + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(S), "dialogue files:", len(dlg))
