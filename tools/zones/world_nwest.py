"""World pass (nwest): walk-in interiors for Yorkshire Dales, Sheffield, Lancaster, Keswick, Lake District.
Run: python3 tools/zones/world_nwest.py data/zones
Adds a door to every labelled building without one (plus 3 to 5 homes per town), writes the interiors with
landmark(), the dialogue JSON, and patches the zone JSON (rows, warps) in place. Safe to re-run."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".,#=:fswL_|+")


def say(who, text):
    assert len(text) <= 200 and "—" not in text and "–" not in text, text
    return {"do": "say", "who": who, "text": text}


# (zone, bx, by, zid, name, kind, w, h, [npc...], gift)
L = []


def add(zone, bx, by, zid, name, kind, w, h, npcs, extra=None):
    L.append((zone, bx, by, zid, name, kind, w, h, npcs, extra))


# npc = (id, sprite, x, y, who, lines, gift=None) ; gift = (item, flag, repeat line)
# ---------------------------------------------------------------- Yorkshire Dales
D = "yorkshire_dales"
add(D, 54, 14, "yorkshire_dales_fieldbarn", "Field Barn", "mill", 11, 9, [
    ("dales_fieldbarn_farmer", "farmer", 5, 3, "Dales Farmer", [
        "Mind the step. This is a field barn, or a laithe if you want to sound local. Every field used to have one.",
        "Cattle sheltered downstairs in winter and the hay sat above. Nobody carried anything far, which is the whole genius of it.",
        "There are thousands of these across the Dales. Walkers call them picturesque. I call them Tuesday."])])
add(D, 14, 28, "yorkshire_dales_waller", "Field Barn", "mill", 12, 9, [
    ("dales_waller", "villager_4", 5, 3, "Waller", [
        "Drystone wall. No mortar, just gravity and good manners. A waller picks the right stone first time, or learns to.",
        "Every so often a long 'throughstone' pokes right across the wall to tie both faces together.",
        "The Dales have thousands of miles of walls, many built when the fields were enclosed in the 1700s and 1800s. Somebody's great-grandad stacked every one."])])
add(D, 5, 41, "yorkshire_dales_meadow", "Field Barn", "mill", 11, 9, [
    ("dales_meadow_walker", "hillwalker", 5, 3, "Walker", [
        "I come for the hay meadows in June. Wood cranesbill, buttercups, globeflower. It is like a carpet that has opinions.",
        "Meadows like these are rare now. Farmers cut late, once the flowers have seeded, and that keeps them going.",
        "Muker in Swaledale is famous for them. Bring a camera and a small picnic, and never sit on the flowers."])])
add(D, 48, 40, "yorkshire_dales_barn", "Barn", "mill", 13, 9, [
    ("dales_barn_shepherd", "farmer", 6, 3, "Shepherd", [
        "That lot out there are Swaledales. Black face, white nose, horns on lasses and lads alike, and a fleece like a doormat.",
        "Wensleydale sheep are the curly ones, with long blue-grey wool. Tourists think they are poodles. They are not poodles.",
        "Slatelets nest in our old walls. Flat, grey and proud of a roof. We get on fine."])])
add(D, 62, 28, "yorkshire_dales_laithe", "Laithe", "cottage", 12, 9, [
    ("dales_laithe_elder", "villager_5", 6, 4, "Retired Farmer", [
        "This is a laithe house, so the barn and the house share one roof. You get warm cows through the wall. Central heating, old style.",
        "Say 'nowt' for nothing and 'owt' for anything. If I say 'nowt wrong wi' it', that is a rave review.",
        "A ginnel is a little alley, and a snicket is the same thing in the next village. We argue about it."])])
add(D, 20, 29, "yorkshire_dales_creamery", "Dales Creamery", "cafe", 13, 9, [
    ("dales_creamery_maker", "mum", 3, 1, "Cheesemaker", [
        "Welcome to the creamery. The air is mostly milk and the floor is mostly spotless. Do not lick the walls.",
        "Wensleydale cheese goes back to Cistercian monks, who brought a recipe over from France and made it in the dale.",
        "It is crumbly and mild, and it goes with fruit cake, which sounds mad until you try it.",
        "Wallace and Gromit made it famous. Wallace says it is the finest cheese there is, and he is not wrong."])])

# ---------------------------------------------------------------- Sheffield
S = "sheffield"
add(S, 4, 6, "sheffield_kelham", "Kelham Island Museum", "mill", 15, 11, [
    ("kelham_guide", "tour_guide", 5, 3, "Museum Guide", [
        "Welcome to Kelham Island. People have used this spot to make things since the 1100s, because the river did the heavy lifting.",
        "Our star is the River Don Engine, one of the most powerful working steam engines in Europe. It starts up with a hiss like a very big kettle.",
        "Outside stands a Bessemer converter. Henry Bessemer's trick of blowing air through molten iron made steel cheap enough for railways and bridges."]),
    ("kelham_engineer", "steelworker", 11, 4, "Engineer", [
        "Don't touch the brass. Well, you can, but it will be warm and it will remember you.",
        "I keep the engine happy. It likes oil, polish and a bit of conversation. I give it all three."])])
add(S, 4, 15, "sheffield_cutlery", "Cutlery Works", "workshop", 13, 10, [
    ("cutlery_cutler", "steelworker", 5, 3, "Cutler", [
        "Welcome. Sheffield cutlers were famous long before anybody said 'stainless'.",
        "In 1743 a cutler called Thomas Boulsover accidentally fused silver onto copper. Sheffield Plate was born: the silver look, for much less.",
        "Then in 1913 a Sheffield metallurgist, Harry Brearley, noticed a chrome steel that would not rust. Stainless steel. Your cutlery owes him a thank-you."])])
add(S, 13, 15, "sheffield_forge", "Forge", "workshop", 11, 9, [
    ("forge_smith", "steelworker", 5, 3, "Blacksmith", [
        "Sheffield sits on five rivers: the Don, the Sheaf, the Porter, the Loxley and the Rivelin. Water wheels drove hammers and grindstones all over.",
        "Benjamin Huntsman perfected crucible steel near here in the 1740s. He melted steel in clay pots until it was even all the way through.",
        "Tap a good blade and it should ring. Tap a bad one and it goes thunk, and so does your reputation."])])
add(S, 36, 38, "sheffield_millgallery", "Millennium Gallery", "museum", 13, 10, [
    ("millgallery_attendant", "poet", 4, 4, "Gallery Attendant", [
        "Welcome to the Millennium Gallery. Silver, steel, paintings, and a very polite carpet.",
        "John Ruskin, the great Victorian art critic, opened a museum for Sheffield's workers at Walkley in 1875. Beauty, he said, should be for everyone.",
        "His collection of minerals, drawings and manuscripts lives here now. Please admire it with your eyes, not your sleeves."])])
add(S, 56, 25, "sheffield_wintergarden", "Winter Garden", "museum", 15, 10, [
    ("wintergarden_gardener", "villager_2", 4, 3, "Gardener", [
        "Welcome to the Winter Garden. It is a glasshouse the size of an aircraft hangar, with a climate better than the one outside.",
        "It opened in 2003 and it is one of the biggest glasshouses in any European city centre.",
        "Plants from all over the world live here, and no two of them agree about the temperature. I just keep the kettle on."])],
    extra=lambda z: [z.prop("potted_plant", x, y) for x, y in ((3, 6), (11, 6), (3, 2), (11, 2), (6, 5), (8, 5))])
add(S, 58, 31, "sheffield_crucible", "Crucible Theatre", "theatre", 13, 10, [
    ("crucible_usher", "commuter", 4, 6, "Usher", [
        "Welcome to the Crucible. The stage pokes out into the audience, so nobody sits very far from the action.",
        "The theatre opened in 1971. Since 1977 it has hosted the World Snooker Championship every spring, so the plays have to share.",
        "Pin-drop silence is part of the rules. People would rather swallow a cough than miss a clearance."])])
add(S, 68, 31, "sheffield_cutlershall", "Cutlers' Hall", "hall", 13, 10, [
    ("cutlers_steward", "tour_guide", 6, 5, "Hall Steward", [
        "Welcome to Cutlers' Hall. The Company of Cutlers in Hallamshire got its charter by Act of Parliament in 1624.",
        "A new Master Cutler is chosen every year. It is a big honour, with a chain of office that is heavier than it looks.",
        "This is the third hall on this site, and it was finished in 1832. The cutlers like to keep things going."])])
add(S, 60, 4, "sheffield_parkhill", "Park Hill Flats", "home", 13, 10, [
    ("parkhill_resident", "villager_3", 5, 3, "Resident", [
        "Welcome to our flat in Park Hill. We live on a 'street in the sky', a wide deck with front doors all along it.",
        "The decks were built wide enough for the milk float, which is the most Sheffield sentence I have ever said.",
        "It was finished around 1961 and it is among the biggest listed buildings in Europe. Concrete can be a landmark too."]),
    ("parkhill_kid", "student", 9, 3, "Kid", [
        "I race my sister along the deck. She wins on corners, I win on stairs.",
        "You can see the whole city from our window. It is mostly hills, with some buses on them."])])
add(S, 26, 31, "sheffield_cafe", "Corner Cafe", "cafe", 12, 9, [
    ("shfcafe_owner", "villager_2", 3, 1, "Cafe Owner", [
        "Ey up, love! Sit anywhere. If someone is 'mardy', they are sulking, and I will not name names.",
        "And 'nesh' means you feel the cold easily. You look a bit nesh. Have a pork pie, on the house."],
     ("pork_pie", "nwest_shfcafe_gift", "Already had your pie! Don't be greedy, love. Off you go."))])
# homes
add(S, 24, 14, "sheffield_home_platt", "Mrs Platt's House", "home", 11, 9, [
    ("shfhome_platt", "villager_1", 5, 3, "Mrs Platt", [
        "Come in, duck. Sheffield is built on seven hills, like Rome, but with more buses.",
        "My husband worked in the steelworks. He still says 'thee' and 'tha', which is how folk round here talked for centuries.",
        "Cutlets turn up near the old works, all bright edges. They have never once been cold, which is more than I can say for him."])])
add(S, 72, 16, "sheffield_home_ahmed", "Ahmed Family Home", "home", 12, 9, [
    ("shfhome_ahmed", "villager_6", 5, 3, "Mr Ahmed", [
        "Welcome! Mind the football in the hall. Our youngest calls sweets 'spice'. It is a Sheffield thing, nothing to do with curry.",
        "Grizzlets hang off our bird feeder upside down. I put up a sign saying not to. They read it and carried on."])])
add(S, 2, 25, "sheffield_home_doreen", "Doreen's House", "home", 11, 9, [
    ("shfhome_doreen", "mum", 5, 3, "Doreen", [
        "Sit down, sit down. My grandson wants to be a goalkeeper, so he practises on the washing line. The washing has views on this.",
        "Sheffield FC was founded in 1857. It is the oldest football club in the world, and we have never let anyone forget it."])])
add(S, 6, 41, "sheffield_home_eze", "Eze Family Home", "home", 13, 9, [
    ("shfhome_eze", "villager_4", 6, 3, "Mr Eze", [
        "Welcome in. Part of the Peak District National Park sits inside Sheffield's boundary, which no other English city can say.",
        "My daughter cycles to school up that hill every day. I take the bus and complain.",
        "Starlets sit on our chimney and copy the sound of my phone. Half the street has stopped answering it."])])

# ---------------------------------------------------------------- Lancaster
LA = "lancaster"
add(LA, 9, 5, "lancaster_castle", "Lancaster Castle", "castle", 15, 11, [
    ("lancaster_castle_guide", "tour_guide", 5, 4, "Castle Guide", [
        "Welcome to Lancaster Castle. It has been a fortress, a courthouse and a prison, sometimes all in the same century.",
        "The Norman keep is over 800 years old. The gatehouse is named for John of Gaunt, Duke of Lancaster.",
        "It worked as a prison right up until 2011. Folk still tell the story of the Pendle witches, who were tried here in 1612."])])
add(LA, 11, 11, "lancaster_priory", "The Priory", "church", 11, 9, [
    ("priory_verger", "choir_singer", 5, 2, "Verger", [
        "Welcome to Lancaster Priory. Roger de Poitou founded a Benedictine priory here in 1094.",
        "The oak choir stalls were carved around 1340, and the canopies are so fine they look like lace made from trees.",
        "From the churchyard you can see over the River Lune to the hills. Take a moment. The hills are not going anywhere."])])
add(LA, 41, 15, "lancaster_market", "Market Hall", "cafe", 11, 9, [
    ("lanmarket_stallholder", "villager_6", 3, 1, "Stallholder", [
        "Lancaster has had a market for centuries. The stalls change, but folk still come to moan about the weather and buy a cabbage.",
        "Lancashire cheese is the local star. Creamy, crumbly, and it makes a toastie that ends arguments.",
        "Atkinsons have sold tea and coffee in Lancaster since 1837. The smell drags people in from the street."])])
add(LA, 34, 4, "lancaster_judges", "Judges' Lodgings", "museum", 13, 10, [
    ("judges_curator", "poet", 4, 4, "Curator", [
        "Welcome to the Judges' Lodgings. It was built around 1625 and later housed the judges who came to Lancaster's courts.",
        "Today it is a museum of the Gillow family. Gillows of Lancaster made fine furniture from about 1730 and sold it far and wide.",
        "The Gillows are credited with the Davenport, a little writing desk, and with a very clever extending dining table."])])
add(LA, 13, 24, "lancaster_bakery", "Bakery", "cafe", 11, 9, [
    ("lanbakery_baker", "shopkeeper", 3, 1, "Baker", [
        "Morning! Warm out of the oven. Lancashire folk are mad about Chorley cakes, which are flat, full of currants and a bit plain.",
        "Eccles cakes are the flaky ones. We eat them with a slice of crumbly Lancashire cheese, and I will not hear otherwise.",
        "Take one for the road. Mind the pastry flakes. They get everywhere, especially on cats."],
     ("eccles_cake", "nwest_lanbakery_gift", "You have had your cake, my love. Off you go before the cats smell it."))])
add(LA, 20, 24, "lancaster_maritime", "Maritime Museum", "museum", 13, 9, [
    ("maritime_shipwright", "shipwright", 5, 4, "Museum Guide", [
        "Welcome to the Maritime Museum. We are in the old Custom House on St George's Quay, which Richard Gillow designed in 1764.",
        "Ships once unloaded timber, wine and fine mahogany here, and the Gillows turned a lot of that mahogany into furniture.",
        "Out in Morecambe Bay the tide has a reputation for coming in faster than a galloping horse. Please do not test it."])])
add(LA, 53, 24, "lancaster_tearooms", "Tea Rooms", "cafe", 12, 9, [
    ("lantea_owner", "mum", 3, 1, "Tea Room Owner", [
        "Table by the window? Lovely. We serve cake, tea and opinions on the weather. The opinions are free.",
        "Up on the hill stands the Ashton Memorial, a great green-domed folly. Lord Ashton built it in 1909 in memory of his wife.",
        "Have a cream tea, on me. Jam first or cream first, I stay out of that fight."],
     ("cream_tea", "nwest_lantea_gift", "One cream tea each, my love, or the scones will run out. Off you go."))])
add(LA, 35, 9, "lancaster_home_dewhurst", "Dewhurst House", "home", 11, 9, [
    ("lanhome_dewhurst", "villager_1", 5, 3, "Mrs Dewhurst", [
        "Come in, don't mither about your shoes. 'Mither' means to fuss, by the way. I do it all day.",
        "The canal crosses the Lune on a big aqueduct, 62 feet up. John Rennie designed it and it opened in 1797.",
        "Chipgulls on the quay will have your chips before you have blinked. Hold your food close and look fierce."])])
add(LA, 51, 5, "lancaster_home_birkett", "Birkett House", "home", 12, 9, [
    ("lanhome_birkett", "villager_5", 5, 3, "Mr Birkett", [
        "Welcome. Out in Morecambe Bay there is an official Guide to the Sands, a job going back to the 1500s.",
        "The cross-bay walk is about eight miles, and nobody should try it without the guide. The sands are lovely and very, very changeable.",
        "Pupplashes splash about the shallows looking innocent. They are only interested in the fish. Mostly."])])
add(LA, 51, 10, "lancaster_home_rigby", "Rigby House", "home", 13, 9, [
    ("lanhome_rigby", "villager_3", 5, 3, "Mrs Rigby", [
        "Hello, pet. The King is Duke of Lancaster, not Duchess, and in Lancashire they say so in the loyal toast.",
        "Our Jack asked why the red rose is on the bin lorry. I said it is the county badge. He said 'then why is it on the bin?'",
        "Binfoxes knock over our bins on Thursdays. Always Thursdays. They must have a timetable."])])
add(LA, 4, 24, "lancaster_home_procter", "Procter House", "cottage", 11, 9, [
    ("lanhome_procter", "canal_boater", 5, 3, "Mr Procter", [
        "Come aboard. Well, come in. I spent so long on boats I still say 'aboard' by mistake.",
        "The Lancaster Canal runs about forty miles without a single lock. Very restful, for a boat or a lazy man.",
        "Zigzlets wiggle through the towpath grass in lines that make no sense. I think they are lost."])])

# ---------------------------------------------------------------- Keswick
K = "keswick"
add(K, 28, 23, "keswick_moothall", "Moot Hall", "hall", 13, 10, [
    ("moothall_volunteer", "tour_guide", 5, 4, "Information Volunteer", [
        "Welcome to the Moot Hall. The present building dates from 1813, though Keswick has had a meeting hall in the market place for far longer.",
        "The town has a market charter from 1276, so people have been buying and selling around here for the best part of 750 years.",
        "Hill, lake or pencil museum? Keswick has all three, and it rains on all of them."])])
add(K, 4, 22, "keswick_pencil", "Cumberland Pencil Museum", "museum", 13, 10, [
    ("pencil_guide", "tour_guide", 4, 4, "Pencil Guide", [
        "Welcome to the Pencil Museum. Graphite was found in Borrowdale in the 1500s, and the story goes a storm uprooted a tree and showed it.",
        "Locals called it 'wad' or black lead. It was so valuable that the mine was guarded, and it was used to line moulds for cannonballs.",
        "That is how Keswick became the pencil town. And look, there is the world's largest colouring pencil, nearly eight metres long."])])
add(K, 21, 33, "keswick_teashop", "Tea Shop", "cafe", 11, 9, [
    ("kesteashop_owner", "villager_2", 3, 1, "Tea Shop Owner", [
        "Come in out of the damp. The damp is outside, with the rest of Cumbria.",
        "Grasmere gingerbread is the local treat, chewy and spicy, like a biscuit and a cake in an argument. Sarah Nelson started selling it in 1854.",
        "Have a cup of tea. Please do not tell the rain I was nice to you."],
     ("cup_of_tea", "nwest_kesteashop_gift", "One cup each, love. The kettle needs a rest too. Off you go."))])
add(K, 42, 33, "keswick_outdoor", "Outdoor Shop", "workshop", 12, 9, [
    ("kesoutdoor_assistant", "fell_runner", 5, 1, "Shop Assistant", [
        "Boots, maps, waterproofs and the sort of socks that change your life. Keswick is basically one big outdoor shop with a lake.",
        "Alfred Wainwright walked and drew every fell in his guides. There are 214 of them, and plenty of people are trying to bag the lot.",
        "Kendal mint cake is proper walking fuel. Joseph Wiper made the first batch by accident in 1869, and later it went up Everest. Here, have a piece."],
     ("kendal_mint_cake", "nwest_kesoutdoor_gift", "One bar each, or you will bounce all the way up Skiddaw. Off you go."))])
add(K, 21, 38, "keswick_guesthouse", "Guest House", "cottage", 11, 9, [
    ("kesguest_landlady", "villager_1", 5, 3, "Landlady", [
        "Welcome! Two rooms free, hot water, and a drying room for your wet boots. That is the most important room in the house.",
        "Castlerigg stone circle is just outside town. Thirty-eight stones, around five thousand years old, with fells all around.",
        "Seathwaite in Borrowdale is the wettest inhabited place in England. Keswick feels dry by comparison, and that is saying something."])])
add(K, 14, 33, "keswick_home_armstrong", "Armstrong House", "cottage", 11, 9, [
    ("keshome_armstrong", "farmer", 5, 3, "Mr Armstrong", [
        "Come in. Herdwick lambs are born almost black. They fade to grey as they grow, which is how I feel about Mondays.",
        "Beatrix Potter kept Herdwicks and left her farms to the National Trust. A Herdlet on our wall is basically a national treasure."])])
add(K, 35, 33, "keswick_home_nicholson", "Nicholson House", "cottage", 12, 9, [
    ("keshome_nicholson", "villager_5", 5, 3, "Mrs Nicholson", [
        "Welcome in. Up here a stream is a beck, a hill is a fell, a pond in the hills is a tarn, and a gate is a yat.",
        "A lonning is a lane. Ours is narrow and the sheep have right of way.",
        "Osprets nested near Bassenthwaite in 2001, the first time in about 150 years. We cheered like it was the football."])])
add(K, 36, 38, "keswick_home_tyson", "Tyson House", "home", 11, 9, [
    ("keshome_tyson", "villager_3", 5, 3, "Mrs Tyson", [
        "Hello, love. My husband is on the Keswick Mountain Rescue team. They are all volunteers, and it runs on donations.",
        "He always tells people to pack a torch, a map and a flask. Dinner here is whenever the pager lets it be.",
        "Midgies swarm by the lake at dusk. They are tiny, hungry and numerous. Wear a hat."])])
add(K, 43, 38, "keswick_home_lowther", "Lowther House", "cottage", 13, 9, [
    ("keshome_lowther", "villager_4", 5, 3, "Mr Lowther", [
        "Welcome! A Pipkin sits on our windowsill every morning, waistcoat out, demanding crumbs. We pay in toast.",
        "Our daughter is in the school play at Theatre by the Lake. It opened on the lakeshore in 1999. We have heard every line forty times."]),
    ("keshome_lowther_kid", "student", 8, 3, "Kid", [
        "I am a tree. It is a speaking part. I say 'whoosh'.",
        "Dad says I am the best tree he has ever seen. He has seen one other tree."])])

# ---------------------------------------------------------------- Lake District route
LD = "lake_district"
add(LD, 6, 46, "lake_farmhouse", "Farmhouse", "cottage", 13, 10, [
    ("lakefarm_farmer", "farmer", 6, 3, "Farmer", [
        "Come in, mind the dog. The dog minds nobody. The kettle is on. It is always on, it is practically the law.",
        "Beatrix Potter bred Herdwicks right here in the Lakes. When she died in 1943 she left about fourteen farms to the National Trust.",
        "Herdwick wool is rough as a doormat, so it goes in carpets, not jumpers. Here, take a flask. You look like you have been up Helvellyn."],
     ("flask_of_tea", "nwest_lakefarm_gift", "That flask is spoken for, love. Come back when you've climbed something."))])
add(LD, 16, 46, "lake_barn", "Barn", "mill", 13, 9, [
    ("lakebarn_shepherd", "villager_6", 6, 3, "Shepherd", [
        "Herdwicks are hefted. Each ewe learns her own patch of fell and teaches her lambs, so we do not need fences up there.",
        "Many Lakeland barns are bank barns, built into the hill so you can drive in upstairs with the hay and drop it straight down.",
        "A Kitelet has been turning slow circles over the fell all week. Keep an eye on your sandwiches."])])
add(LD, 58, 4, "lake_slatemine", "Slate Mine", "workshop", 13, 10, [
    ("lakeslate_miner", "tin_miner", 5, 3, "Slate Miner", [
        "Honister Slate Mine, over in Borrowdale, is the last working slate mine in England. Lake District green slate roofs half the county.",
        "Slate splits in flat, clean sheets. A good splitter taps along the grain with a chisel and the stone just opens up.",
        "If something taps three times on the wall down there, it is a Tapknock. Tap back politely."])])


def find_door(d, bx, by, w, h, props):
    rows = d["rows"]
    by1 = by + h - 1
    cands = sorted(range(bx, bx + w), key=lambda x: abs(x - (bx + w // 2)) + 0.1 * (x > bx + w // 2))
    for x in cands:
        if by1 + 1 >= len(rows):
            continue
        ch = rows[by1 + 1][x]
        if ch in WALK and (x, by1 + 1) not in props:
            return x
    raise SystemExit("no door spot for building %s,%s in %s" % (bx, by, d["id"]))


def set_tile(d, x, y, ch):
    r = d["rows"][y]
    d["rows"][y] = r[:x] + ch + r[x + 1:]


# manual terrain tweaks so doors have a walkable tile to the south
TWEAKS = {
    "yorkshire_dales": [(56, 17, "#")] + [(x, 44, ".") for x in range(8, 12)],
}

# decorative props removed because they walled in a new door (the farmhouse's planters boxed in its porch)
DROP_PROPS = {"lake_district": [("planter", 12, 50)]}

# the farm sign stood on the only way out of the farmhouse porch; move it beside the planter
SIGN_MOVES = {"lake_district": [((13, 50), (7, 50))]}

zones = {}


def zone(zid):
    if zid not in zones:
        zones[zid] = json.load(open(os.path.join(OUT, zid + ".json")))
    return zones[zid]


for zid, tw in TWEAKS.items():
    for x, y, ch in tw:
        set_tile(zone(zid), x, y, ch)

for zid, drops in DROP_PROPS.items():
    d = zone(zid)
    for t, x, y in drops:
        d["props"] = [p for p in d["props"] if not (p["type"] == t and p["x"] == x and p["y"] == y)]

for zid, moves in SIGN_MOVES.items():
    for (ox, oy), (nx, ny) in moves:
        for sg in zone(zid)["signs"]:
            if (sg["x"], sg["y"]) == (ox, oy):
                sg["x"], sg["y"] = nx, ny

dlg = {}
seen = set()
for zone_id, bx, by, zid, name, kind, w, h, npcs, extra in L:
    assert zid not in seen, zid
    seen.add(zid)
    d = zone(zone_id)
    bld = [p for p in d["props"] if p["type"] == "building" and p["x"] == bx and p["y"] == by]
    assert len(bld) == 1, (zone_id, bx, by)
    b = bld[0]
    props = {(p["x"], p["y"]) for p in d["props"] if p["type"] != "building"}
    props |= {(sg["x"], sg["y"]) for sg in d["signs"]} | {(n["x"], n["y"]) for n in d["npcs"]}
    by1 = b["y"] + b["h"] - 1
    existing = [wp for wp in d["warps"] if b["x"] <= wp["x"] < b["x"] + b["w"] and wp["y"] == by1]
    if existing:
        print("skip (already has door):", zid)
        continue
    dx = find_door(d, b["x"], b["y"], b["w"], b["h"], props)
    set_tile(d, dx, by1, "D")
    ret = (dx, by1 + 1)
    z = landmark(OUT, zid, name, zone_id, ret, kind, [], w, h)
    if extra:
        extra(z)
    occupied = {(p["x"], p["y"]) for p in z.d["props"]}
    mid = w // 2
    placed = []
    for n in npcs:
        nid, spr, px, py, who, lines = n[:6]
        best = None
        for yy in range(1, h - 2):
            for xx in range(1, w - 1):
                if z.g[yy][xx] not in "|+" or (xx, yy) in occupied:
                    continue
                if abs(xx - mid) <= 0 and yy >= h - 5:
                    continue
                dist = abs(xx - px) + abs(yy - py)
                if best is None or dist < best[0]:
                    best = (dist, xx, yy)
        _, xx, yy = best
        occupied.add((xx, yy))
        z.npc(id=nid, sprite=spr, x=xx, y=yy, facing="down", move="still", script=nid)
        script = [say(who, t) for t in lines]
        if len(n) > 6 and n[6]:
            item, flag, again = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1},
                          {"do": "set", "flag": flag}]}]
        dlg.setdefault(zid, {})[nid] = script
    z.save(os.path.join(OUT, zid + ".json"))
    d["warps"].append({"x": dx, "y": by1, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})

for zid, d in zones.items():
    with open(os.path.join(OUT, zid + ".json"), "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    with open(os.path.join(DLG, zid + ".json"), "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=False)
print("interiors:", len(dlg))
