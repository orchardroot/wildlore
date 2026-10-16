"""Walk-in interiors for the eastern Ireland group (Belfast to Wicklow): landmarks, homes, new houses.
Run: python3 tools/zones/world_ieast.py data/zones
Edits the town JSON directly (doors, warps, a few extra houses), writes interiors and dialogue. Safe to re-run."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".#:=,fsw_|+")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


L = []      # interiors
HOUSES = []  # brand new house props: (town, x, y, w, h, style)


def add(zid, name, town, door, kind, npcs, w=13, h=10):
    L.append((zid, name, town, door, kind, npcs, w, h))


def house(town, x, y, w, h, style):
    HOUSES.append((town, x, y, w, h, style))


# ---------------------------------------------------------------- new houses (towns short of homes)
house("belfast", 3, 15, 5, 3, "terrace")
house("belfast", 29, 38, 5, 3, "red_brick")
house("bushmills", 19, 23, 5, 3, "white_render")
house("bushmills", 17, 3, 5, 3, "slate_cottage")
house("derry", 13, 15, 5, 3, "terrace")
house("derry", 38, 39, 5, 3, "red_brick")
house("derry", 62, 13, 5, 3, "terrace")
house("dublin", 18, 16, 4, 3, "terrace")
house("dublin", 25, 2, 4, 3, "cream_render")
house("newgrange", 28, 32, 4, 3, "white_render")
house("newgrange", 38, 32, 4, 3, "slate_cottage")

# ---------------------------------------------------------------- BELFAST
add("belfast_cityhall", "Belfast City Hall", "belfast", (20, 13), "hall", [
    ("bel_hall_guide", "tour_guide", 5, 3, "Guide", [
        "Welcome to City Hall. Portland stone outside, marble inside, and a copper dome that turned green ages ago.",
        "Belfast became a city in 1888, and this building opened in 1906. It stands where the White Linen Hall once did.",
        "Look up at the dome from inside. Then lie down, if the steward allows it. Nobody has ever managed to look bored."])],
    w=15, h=11)
add("belfast_palmhouse", "Palm House", "belfast", (11, 23), "museum", [
    ("bel_palm_gardener", "villager_4", 6, 3, "Gardener", [
        "Mind the humidity. Your hair will not forgive you, and neither will the ferns.",
        "The Palm House is curved iron and glass, built around 1840. It is one of the oldest glasshouses of its kind anywhere.",
        "Tropical plants in Belfast sounds like a bad bet, yet here they are. Glass is a wonderful thing."])],
    w=12, h=9)
add("belfast_ulstermuseum", "Ulster Museum", "belfast", (37, 11), "museum", [
    ("bel_ulster_curator", "tour_guide", 5, 4, "Curator", [
        "Welcome to the Ulster Museum. We have dinosaurs, paintings, and a lady who is over two and a half thousand years old.",
        "Takabuti was an Egyptian woman from Thebes. She came to Belfast in 1834 and was unwrapped in public. She was a good sport about it.",
        "Our other treasures are gold and jewels from the Armada ship Girona, wrecked off the Antrim coast in 1588."]),
    ("bel_ulster_kid", "student", 9, 5, "Student", [
        "My project is on Takabuti. She has more fans than I do. It is slightly unfair."])],
    w=15, h=11)
add("belfast_linenhall", "Linen Hall Library", "belfast", (37, 19), "library", [
    ("bel_linen_librarian", "poet", 6, 3, "Librarian", [
        "Hush now. Well, a wee bit hush. Welcome to the Linen Hall Library.",
        "We were founded in 1788, which makes us the oldest library in Belfast. We are still going, and still very patient.",
        "The name comes from the White Linen Hall, where cloth merchants once traded. The library lived there for a century."])])
add("belfast_albertclock", "Albert Clock", "belfast", (37, 26), "hall", [
    ("bel_clock_keeper", "villager_5", 5, 3, "Clock Keeper", [
        "Careful on the stairs. It leans a bit in here too, and I have got used to it.",
        "The Albert Memorial Clock was finished in 1869, for Prince Albert, Queen Victoria's husband.",
        "The ground was soft river mud, so it sits on timber piles. It has leaned by more than a metre. Still keeps good time."])],
    w=11, h=9)
add("belfast_lisburnroad", "Lisburn Road Linens", "belfast", (8, 46), "workshop", [
    ("bel_linen_seller", "shopkeeper", 6, 4, "Shopkeeper", [
        "Linen, madam, sir, or anybody else. Touch the tablecloth. Go on, it is cooler than you think.",
        "Linen comes from flax, the blue-flowered plant. Belfast made so much of it that it was nicknamed Linenopolis.",
        "In the 1690s a Huguenot called Louis Crommelin set up near Lisburn and improved the trade. His name is still on a few things."])])
add("belfast_sandwichbar", "Sandwich Bar", "belfast", (17, 46), "cafe", [
    ("bel_sandwich_cook", "villager_2", 4, 3, "Cook", [
        "What'll it be? We do the lot. If you want it Ulster-style, you want a fry.",
        "An Ulster fry has sausage, bacon, egg, potato bread and a soda farl. A farl is a triangle of bread raised with baking soda, not yeast.",
        "Take one for the road. Wee bit of crumb never hurt anybody."],
        "belfast_sandwich_gift", "soda_farl")])
add("belfast_titanic", "Titanic Belfast", "belfast", (55, 20), "museum", [
    ("bel_titanic_guide", "tour_guide", 6, 4, "Guide", [
        "Welcome to Titanic Belfast. The building has four points, shaped like the prows of ships.",
        "The ship was launched from a slipway on this very site on 31 May 1911. The launch took under a minute.",
        "Belfast is proud of the workers who built her, and not at all fussed that the story gets all the attention."]),
    ("bel_titanic_shipwright", "shipwright", 10, 6, "Shipwright", [
        "I am a retired plater. Every steel plate was hand-fitted, and every rivet was hammered in by a team of four."])],
    w=15, h=11)
add("belfast_home_lisburn", "Terrace Home", "belfast", (26, 46), "home", [
    ("bel_home_mairead", "villager_2", 6, 3, "Mairead", [
        "Come on in, the kettle is on. In Belfast, 'a wee while' can mean anywhere from five minutes to a week.",
        "'Scundered' means fed up or embarrassed, usually both. 'Catch yourself on' means stop being silly. I say both every day.",
        "Mind the chipgulls down at the Docks. They have a system, and the system is you."],
        "belfast_home_gift", "ulster_fry")])
add("belfast_home_riveter", "Riveter's House", "belfast", (5, 17), "home", [
    ("bel_home_riveter", "steelworker", 6, 3, "Mr Gillen", [
        "My granda was a riveter at Harland and Wolff. The rivets were heated red-hot, tossed across the gap, and caught in a bucket.",
        "Samson and Goliath, the big yellow cranes, still stand in the yard. You can see them from nearly every street in Belfast.",
        "Rivetlings gather round the dockside, if you want to meet one. They whistle. Out of tune, I will have you know."])])
add("belfast_home_wain", "Dockside Home", "belfast", (31, 40), "home", [
    ("bel_home_family", "mum", 6, 3, "Mrs Hanna", [
        "Tea is on and the cat is on the radiator. Between the two of them, I am a happy woman.",
        "The wains are at school. 'Wain' is what we call a child here. It comes from 'wee ane', or wee one.",
        "At dusk the starlets sit on the cranes by the hundred and have a chat. They are very loud, and very tidy about it."])])

# ---------------------------------------------------------------- BUSHMILLS
add("bushmills_postoffice", "Bushmills Post Office", "bushmills", (7, 15), "workshop", [
    ("bush_postmaster", "villager_4", 5, 3, "Postmaster", [
        "Morning. A stamp, a parcel, or a chat? The chat is free but takes longer.",
        "Bushmills once had the Giant's Causeway Tramway, opened in 1883. It was among the earliest electric trams, powered by the river.",
        "The trams are gone but the little railway to the Causeway is a lovely thing. Do give it a go."])],
    w=11, h=9)
add("bushmills_craftshop", "Bushmills Craft Shop", "bushmills", (38, 25), "workshop", [
    ("bush_craft_keeper", "shopkeeper", 6, 4, "Shopkeeper", [
        "Have a look around. Everything here is made within ten miles, and the odd thing within ten feet.",
        "Please do not take stones from the Giant's Causeway. It is protected, and the columns miss every single one.",
        "We have postcards and tea towels with giants on them. It is the closest you will get to a giant today."])],
    w=12, h=9)
add("bushmills_riverside", "Riverside Cottage", "bushmills", (38, 15), "cottage", [
    ("bush_angler", "fisherman_north", 5, 3, "Mr McAuley", [
        "Bradan is the Irish word for salmon. They come up the Bush every year, same as they have for thousands.",
        "Parrlet are the young ones, small and striped. Patience pays with those. It pays with most things, though not on the bus.",
        "The river is quick and clear. If you hear splashing, it is either a salmon or my wife throwing something at me. Probably the salmon."])])
add("bushmills_home_green", "House by the Green", "bushmills", (21, 25), "home", [
    ("bush_home_nan", "mum", 6, 3, "Nan Boyle", [
        "Come away in. We go for a 'dander' round here, which is a gentle stroll with no destination.",
        "I take mine to the river. Dipling bob on the rocks there like they are on springs. They think they own the place.",
        "My granda told me the trams ran on river power. I did not believe him until I saw the photograph."])])
add("bushmills_home_hill", "Hilltop House", "bushmills", (19, 5), "home", [
    ("bush_home_birder", "birdwatcher", 6, 3, "Mr Wylie", [
        "Binoculars are by the window. Heronarch stalks the river below, and if you wait, it does the same thing again.",
        "Dunluce Castle is a few miles west, on a cliff by the sea. They say part of the kitchen fell into the water in 1639.",
        "The cook, I hope, was off that day. Tradition is a bit vague on it."])])

# ---------------------------------------------------------------- DERRY~LONDONDERRY
add("derry_craftvillage", "Craft Village", "derry", (15, 13), "workshop", [
    ("derry_potter", "villager_3", 5, 4, "Potter", [
        "Welcome to the Craft Village. Mind the wet clay. It is hard to wash out of a good opinion.",
        "In the 1800s Derry~Londonderry became famous for making shirts. Thousands of people worked in the factories, most of them women.",
        "Some streets in the city had a shirt factory at every corner. Now we have pottery, and fewer collars."])],
    w=14, h=10)
add("derry_towermuseum", "Tower Museum", "derry", (30, 13), "museum", [
    ("derry_tower_guide", "tour_guide", 6, 4, "Guide", [
        "Welcome to the Tower Museum. We tell the story of Derry~Londonderry from the first oak grove to the present day.",
        "One of our treasures is from La Trinidad Valencera, an Armada ship. She sank off Inishowen in 1588, and divers found her in 1971.",
        "Do try the story gallery. Nobody has ever got through it quickly, and nobody has ever minded."]),
    ("derry_tower_student", "student", 9, 3, "Student", [
        "I am here for a school project and I have stayed for the cafe. Both are going well."])],
    w=15, h=11)
add("derry_bookshop", "Derry Bookshop", "derry", (37, 13), "library", [
    ("derry_bookseller", "poet", 5, 3, "Bookseller", [
        "Take your time. If you find the one you want, it is probably under a different one.",
        "Seamus Heaney was born in County Londonderry in 1939 and won the Nobel Prize for Literature in 1995. He wrote about digging and blackberries.",
        "I say that, and customers look at the poetry shelf with an air of wonder. Then they buy a cookbook. It is fine."])])
add("derry_waterloo", "Waterloo Tavern", "derry", (30, 28), "cafe", [
    ("derry_tavern_fiddler", "fiddler", 4, 3, "Fiddler", [
        "Come in. We have a music session on, and everyone is welcome to listen. Keep your toes out of the way of the bodhrán.",
        "A jig is in six-eight time and bounces. A reel is smoother and faster. Nobody can tell the difference until they try to dance.",
        "There is always a soup on, a fire in the grate, and a tune. That is a proper night out."])],
    w=14, h=10)
add("derry_home_flats", "Linen Mill Flat", "derry", (37, 28), "home", [
    ("derry_home_flat", "villager_1", 6, 3, "Mrs Doherty", [
        "Come in, mind the cat. The mill was a linen mill once, and these flats keep the big windows.",
        "'Houl yer whisht' is what you say here for 'be quiet'. Hear it from a grandmother and you will stop talking.",
        "The wee hootlets in the wood up the road keep very odd hours. I call them the night staff."],
        "derry_flat_gift", "cup_of_tea")])
add("derry_home_walls", "House Within the Walls", "derry", (15, 17), "home", [
    ("derry_home_wains", "villager_2", 6, 3, "Mrs Gallagher", [
        "Come in, come in. My wains are in the front room, doing homework, or pretending to.",
        "'Yousens' is how we say 'you' when it is more than one of you. It saves a lot of trouble.",
        "The Walls are right outside. Complete, and nearly four hundred years old. Every Derry child has run on them."])])
add("derry_home_foyle", "House by the Foyle", "derry", (40, 41), "home", [
    ("derry_home_boatman", "angler", 6, 3, "Mr Brogan", [
        "The Foyle is a tidal river. In the morning it is high and silvery, and in the evening it has gone out for a walk.",
        "Selklet pop up near the estuary and watch you with big dark eyes. They are very polite, for seals.",
        "I have never caught a salmon here. The salmon have never caught me. We have an understanding."])])
add("derry_home_station", "Railway House", "derry", (64, 15), "home", [
    ("derry_home_railfan", "commuter", 6, 3, "Mr Cassidy", [
        "I have lived near the station all my life and I still run to the window every time a train goes by.",
        "The line to Coleraine runs along the shore of Lough Foyle, then tunnels under the cliffs at Downhill. It is a famously pretty ride.",
        "Take a window seat. Take sandwiches. Take your phone, then forget it and look out."])])

# ---------------------------------------------------------------- CAUSEWAY, ANTRIM COAST, MOURNES
add("causeway_marquee", "Vane Estates Marquee", "causeway", (39, 31), "hall", [
    ("cw_marquee_intern", "commuter", 5, 3, "Intern", [
        "Welcome to the Vane Estates Premium Experience. Please do not touch the brochures. They are not finished, and neither is the lease.",
        "We plan an Advanced Causeway Tier. Hexagonal flats, hexagonal cafe, and a hexagonal plate for each visitor.",
        "The real columns are a World Heritage Site, as it happens. Somebody has to tell Lord Vane. It will not be me."])],
    w=11, h=9)
add("antrim_ropehut", "Rope Bridge Ticket Hut", "antrim_coast", (41, 13), "cottage", [
    ("antrim_hut_volunteer", "hiker", 5, 3, "Volunteer", [
        "Morning. Tickets, please. We only let so many onto the bridge at a time, so it stays a happy place.",
        "Carrick-a-Rede is said to mean 'rock in the road'. The road in question is the one the salmon used to take.",
        "Fishermen built the first rope bridge here, to get to the best salmon nets. It has been rebuilt many times since. It is very safe, I promise."])],
    w=11, h=9)
add("mournes_peathut", "Peat Cutter's Hut", "mournes", (9, 10), "cottage", [
    ("mournes_peatman", "farmer", 5, 3, "Peat Cutter", [
        "Mind the damp. Peat is called 'móin' in Irish, and it takes a very long time to make and a short time to burn.",
        "Peatmonarch rules the bog. Slow and bulky, and not to be rushed. Treat it with respect, and it might return the favour.",
        "The Mourne Wall runs about 22 miles over 15 summits. It was built between 1904 and 1922 to protect a reservoir's water. Here, a flask."],
        "mournes_peat_gift", "flask_of_tea")],
    w=11, h=9)

# ---------------------------------------------------------------- DUBLIN
add("dublin_customhouse", "Custom House", "dublin", (46, 19), "hall", [
    ("dub_custom_clerk", "commuter", 5, 3, "Clerk", [
        "Welcome to the Custom House. It was designed by James Gandon and finished in 1791. He also did the Four Courts, further up the river.",
        "Look for the carved stone heads above the doors and windows. They represent Irish rivers, and one of them is the Atlantic Ocean.",
        "The dome is topped by a statue of Commerce. I have never seen her do any."])],
    w=15, h=11)
add("dublin_trinity", "Trinity College Library", "dublin", (8, 37), "library", [
    ("dub_trinity_librarian", "poet", 6, 3, "Librarian", [
        "Quietly, if you will. The Book of Kells is a copy of the four Gospels, made around the year 800 by monks. It came to Trinity in 1661.",
        "The Long Room is 65 metres, with 200,000 old books and a smell students call 'academic'. It gives every visitor goosebumps.",
        "Our oldest harp is the model for the harp on Irish coins. It is about 600 years old and has not played a note in ages."])],
    w=14, h=10)
add("dublin_campanile", "The Campanile", "dublin", (17, 42), "hall", [
    ("dub_campanile_keeper", "student", 5, 3, "Student", [
        "Do not walk under the bell. Legend says that you will fail your exams. I walked round it three times. I am doing fine.",
        "The Campanile was built in 1853. The architect was Charles Lanyon, who also designed buildings in Belfast.",
        "The bells ring on the hour, and, I swear, a little louder before exams."])],
    w=11, h=9)
add("dublin_oldlibrary", "The Old Library", "dublin", (19, 48), "library", [
    ("dub_oldlib_librarian", "villager_3", 6, 3, "Librarian", [
        "Welcome. Do not blow on the pages. That is a small request, and the books are old.",
        "Not far from here, Marsh's Library has lent books since 1707. Readers were locked into wooden cages so that they could not walk off with the rare ones.",
        "Nowadays we trust you. Mostly."])],
    w=13, h=10)
add("dublin_templebar", "The Temple Bar", "dublin", (37, 37), "cafe", [
    ("dub_templebar_fiddler", "fiddler", 4, 3, "Fiddler", [
        "Come in, find a seat, and listen. The music starts at lunchtime and finishes whenever it feels like it.",
        "The area is named after Sir William Temple, who lived by the river in the 1600s. His family house and gardens were here.",
        "The 'bar' is an old word for a walkway by the water. Nobody has told the cafe next door."])],
    w=14, h=10)
add("dublin_cobbler", "The Cobbler's Tap", "dublin", (45, 37), "workshop", [
    ("dub_cobbler", "villager_5", 6, 4, "Cobbler", [
        "Mind the shoes. Each pair is waiting for a new heel and a better owner.",
        "In Irish folklore the shoemaker of the fairies is the leipreachán, the leprechaun. He is always mending one shoe.",
        "The cluricaun is his cousin, a bit sneakier and a bit shorter. I have no information on where the other shoe went."])],
    w=12, h=9)
add("dublin_templebooks", "Temple Bar Books", "dublin", (53, 37), "library", [
    ("dub_books_seller", "shopkeeper", 6, 3, "Bookseller", [
        "Welcome. We have a poem for every mood, and a map for every misplaced tourist.",
        "Dublin was made a UNESCO City of Literature in 2010. Yeats, Shaw and Beckett were all born here, and every one of them could talk.",
        "We have signed copies, second-hand copies, and a cat. The cat is not for sale, and neither is the signed copy."])],
    w=14, h=10)
add("dublin_home_terrace", "Georgian House", "dublin", (56, 19), "home", [
    ("dub_home_orla", "villager_1", 6, 3, "Orla", [
        "Come in, come in. 'Grand' means everything from 'fine' to 'wonderful'. A 'yoke' is any gadget whose name you have forgotten.",
        "Dublin's Georgian doors are famously bright. One story is that people painted them to tell the identical houses apart.",
        "Down in the Park the fawnlets hide in the bracken. Walk quietly, and they might not hide. Here, some barmbrack, my gran's recipe."],
        "dublin_home_gift", "barmbrack")])
add("dublin_home_stone", "Stone House", "dublin", (18, 37), "home", [
    ("dub_home_teacher", "poet", 6, 3, "Mr Byrne", [
        "I teach history and I never tire of it. Dublin was founded as a Viking settlement around the year 841. They named it, roughly, after a black pool.",
        "Something gets 'banjaxed' when it is broken beyond repair. My bicycle is banjaxed, so is my umbrella, and so is the clock.",
        "Flittermice swoop round the college lamps at dusk. They are tiny, fast and extremely good at their job."])])
add("dublin_home_park", "Park Cottage", "dublin", (20, 18), "cottage", [
    ("dub_home_hurler", "hurler", 6, 3, "Ciaran", [
        "That stick is a hurley, and the ball is a sliotar. Hurling is the fastest field game in the world, and a good reason to wear a helmet.",
        "'Gas' means funny. 'I'm going for the messages' means going shopping. Both are very Dublin.",
        "Hushwing hunts over the Park at dusk. Silent as a tea towel. Do not stand under one."])])
add("dublin_home_green", "Green Cottage", "dublin", (27, 4), "home", [
    ("dub_home_student", "student", 6, 3, "Aoife", [
        "Welcome. It is small, but the rent is lovely and the kettle is faithful.",
        "Dublin has two tall red and white striped chimneys down at Poolbeg. They are a big part of the skyline, and a big part of my homesickness.",
        "'Sound' means good, or all right. 'Deadly' means brilliant. A sound, deadly cup of tea, that is the whole city."])])

# ---------------------------------------------------------------- NEWGRANGE, BOYNE VALLEY, WICKLOW
add("newgrange_visitor", "Brú na Bóinne Visitor Centre", "newgrange", (11, 24), "museum", [
    ("ng_visitor_guide", "tour_guide", 6, 4, "Guide", [
        "Fáilte. Newgrange is about 5,200 years old, built around 3200 BC. That makes it older than Stonehenge and the pyramids at Giza.",
        "Brú na Bóinne means roughly 'the mansion of the Boyne'. It is a World Heritage Site, with Knowth and Dowth nearby.",
        "Our replica passage is the real thing, only with a shorter queue."]),
    ("ng_visitor_archaeologist", "student", 12, 3, "Archaeologist", [
        "Knowth has more decorated stones than any other site in Europe. We are still counting, and we are still amazed."])],
    w=15, h=11)
add("newgrange_cafe", "Farmhouse Cafe", "newgrange", (7, 34), "cafe", [
    ("ng_cafe_cook", "mum", 4, 3, "Cook", [
        "Sit anywhere. Soda bread is in the oven, and the scones are in the other oven.",
        "Soda bread rises with baking soda and buttermilk, not yeast, so it is quick. The first time you try it you will wonder why every bread isn't.",
        "Here, a slice for the road. It is still warm. The farm cat believes it is hers."],
        "newgrange_cafe_gift", "soda_bread")],
    w=12, h=9)
add("newgrange_inn", "The Boyne Inn", "newgrange", (47, 34), "cafe", [
    ("ng_inn_host", "fiddler", 4, 3, "Host", [
        "Come in. We have soup, bread, and a tune most evenings. The fiddle is in tune. The singer is not always.",
        "The River Boyne is named after a goddess, Bóann. Her name means 'white cow', which is a very Irish way to name a river.",
        "In the old stories the goddess made the river rise when she walked round a magical well. Do not try this at home."])],
    w=14, h=10)
add("newgrange_home_cottage", "Boyne Cottage", "newgrange", (15, 34), "cottage", [
    ("ng_home_siobhan", "villager_6", 6, 3, "Siobhan", [
        "Fáilte. 'Cúpla focal' means a couple of words, as in 'I only have a cúpla focal of Irish'. Everyone does, and they are lovely.",
        "'Slán' means goodbye. Say it on the doorstep and I will be delighted.",
        "In summer crexlings call from the long grass at dusk. A rasping 'crex crex'. Hearing one is a good omen."])])
add("newgrange_home_farm", "Meath Farmhouse", "newgrange", (30, 34), "home", [
    ("ng_home_farmer", "farmer", 6, 3, "Farmer Dunne", [
        "Meath is called the Royal County, for the Hill of Tara a few miles on. Kings were crowned there, so I tell the cattle to behave.",
        "Brockling digs under the hedge every spring. I put a stone there, and he put the stone somewhere else. It is a great partnership.",
        "My granda ploughed up bits of flint here. Five thousand years of farming, and I am still learning."])])
add("newgrange_home_dig", "Archaeologist's House", "newgrange", (40, 34), "cottage", [
    ("ng_home_digger", "student", 6, 3, "Ruth", [
        "I came for a summer dig and stayed for fifteen years. The soil here remembers everything.",
        "The stone carvings are spirals, circles, and lozenges. Nobody knows what they mean. We have guesses, and some of them are even sensible.",
        "Pooka turn up at dusk, in all sorts of shapes. Keep your blackberries. They say they spoil after Samhain, which is the end of October."])])

add("boyne_mellifont", "Mellifont Abbey", "boyne_valley", (30, 7), "church", [
    ("mellifont_warden", "choir_singer", 6, 3, "Warden", [
        "Welcome to Mellifont. It was the first Cistercian monastery in Ireland, founded in 1142 by St Malachy, a friend of St Bernard of Clairvaux.",
        "The Cistercians liked simple stone, clean lines, and quiet. They also liked a good garden. Not a bad way to live.",
        "The octagonal washing house, the lavabo, is the best piece left. Have a look. It looks like a very small church that lost its roof."])],
    w=14, h=10)

add("wicklow_cathedral", "Glendalough Cathedral", "wicklow", (27, 25), "church", [
    ("glen_cathedral_guide", "tour_guide", 6, 3, "Guide", [
        "Welcome to Glendalough, Gleann Dá Loch, the valley of the two lakes. St Kevin settled here in the 6th century and the monastery flourished for six hundred years.",
        "Most of the stones you see here date from about the 10th to the 12th century. They have seen a lot of weather.",
        "Kevin liked the quiet. Today you can still hear it. The ducks help."])],
    w=13, h=10)
add("wicklow_roundtower", "Round Tower", "wicklow", (34, 26), "hall", [
    ("glen_tower_keeper", "hiker", 5, 3, "Warden", [
        "This is a cloigtheach, which means 'bell house'. It stands about 30 metres tall, and the door is high up off the ground.",
        "Monks reached it by ladder, and pulled the ladder up after them in a hurry. It served as a lookout and a safe room.",
        "It has stood for a thousand years or so. Not a bad record for a stack of stones."])],
    w=11, h=9)
add("wicklow_kevinschurch", "St Kevin's Church", "wicklow", (38, 25), "church", [
    ("glen_church_poet", "poet", 5, 3, "Storyteller", [
        "This little church is called 'St Kevin's Kitchen'. The belfry looks like a chimney, and the roof is steep stone.",
        "The story goes that Kevin was praying with his hand out of the window when a blackbird laid an egg in his palm.",
        "He stayed still until the chick hatched. Seamus Heaney wrote a poem about it. I have never managed to sit still that long."])],
    w=11, h=9)

# ---------------------------------------------------------------- town fixes (wall gaps for doors facing walls)
TOWN_FIX = {
    "dublin": [(19, 49, ".")],     # open the wall south of the Old Library
    "wicklow": [(27, 26, ".")],    # open the wall south of the Cathedral Ruins
}


def find_building(td, door):
    for p in td["props"]:
        if p.get("type") == "building":
            by = p["y"] + p["h"] - 1
            if door[1] == by and p["x"] <= door[0] < p["x"] + p["w"]:
                return p
    raise SystemExit("no building for door %s in %s" % (door, td["id"]))


def load(town):
    return json.load(open(os.path.join(OUT, town + ".json")))


def save(town, td):
    with open(os.path.join(OUT, town + ".json"), "w") as f:
        json.dump(td, f, indent=1, ensure_ascii=False)


# 1. new house props
for town, x, y, w, h, style in HOUSES:
    td = load(town)
    if any(p.get("type") == "building" and p["x"] == x and p["y"] == y for p in td["props"]):
        continue
    for yy in range(y, y + h):
        r = td["rows"][yy]
        assert all(c in ".," for c in r[x:x + w]), (town, x, y, r[x:x + w])
        td["rows"][yy] = r[:x] + "B" * w + r[x + w:]
    # building props sit before the point props; insert after the last building
    last = max(i for i, p in enumerate(td["props"]) if p.get("type") == "building")
    td["props"].insert(last + 1, {"type": "building", "x": x, "y": y, "w": w, "h": h, "style": style})
    save(town, td)

# 1b. a short boardwalk of path tiles across the bog to the Peat Cutter's island
td = load("mournes")
r = td["rows"][11]
td["rows"][11] = r[:12] + "####" + r[16:]
save("mournes", td)

# 2. interiors, dialogue, doors and warps
dlg = {}
for zid, name, town, door, kind, npcs, w, h in L:
    td = load(town)
    find_building(td, door)
    ret = (door[0], door[1] + 1)
    for (fx, fy, ch) in TOWN_FIX.get(town, []):
        if abs(fx - door[0]) <= 1 and fy == door[1] + 1:
            r = td["rows"][fy]
            td["rows"][fy] = r[:fx] + ch + r[fx + 1:]
    # door tile and a walkable tile just south
    r = td["rows"][door[1]]
    td["rows"][door[1]] = r[:door[0]] + "D" + r[door[0] + 1:]
    south = td["rows"][ret[1]][ret[0]]
    assert south in WALK, (zid, "south tile %r not walkable" % south)
    nl = []
    for n in npcs:
        nid, spr, x, y, who, lines = n[:6]
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        script = [say(who, t) for t in lines]
        if len(n) > 6:
            flag, item = n[6], n[7]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, "That is all I have, I am afraid. Off you go, and mind how you go.")],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1},
                          {"do": "set", "flag": flag}]}]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, town, ret, kind, nl, w, h)
    # nudge any NPC off props / counters / the exit column
    zp = os.path.join(OUT, zid + ".json")
    zd = json.load(open(zp))
    blocked = {(int(p["x"]), int(p["y"])) for p in zd["props"]}
    dx = w // 2

    def ok(x, y):
        return (1 <= x <= w - 2 and 1 <= y <= h - 4 and (x, y) not in blocked
                and zd["rows"][y][x] in "|+")
    placed = set()
    for n in zd["npcs"]:
        if not ok(n["x"], n["y"]) or (n["x"], n["y"]) in placed:
            for rad in range(1, 6):
                cands = [(n["x"] + a, n["y"] + b) for a in range(-rad, rad + 1) for b in range(-rad, rad + 1)
                         if ok(n["x"] + a, n["y"] + b) and (n["x"] + a, n["y"] + b) not in placed]
                if cands:
                    n["x"], n["y"] = min(cands, key=lambda c: abs(c[0] - n["x"]) + abs(c[1] - n["y"]))
                    break
        placed.add((n["x"], n["y"]))
    json.dump(zd, open(zp, "w"), indent=1, ensure_ascii=False)
    if not any(p["x"] == door[0] and p["y"] == door[1] for p in td["warps"]):
        td["warps"].append({"x": door[0], "y": door[1], "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})
    save(town, td)

# 3. new house doors are added in step 2 only for listed interiors; houses listed above without an interior would be
# decorative, so make sure every house got one
for town, x, y, w, h, style in HOUSES:
    door = (x + w // 2, y + h - 1)
    td = load(town)
    assert any(p["x"] == door[0] and p["y"] == door[1] for p in td["warps"]), ("house without a door", town, door)

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(L), "new houses:", len(HOUSES))
