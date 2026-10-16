"""World pass (Wildlore 1.1), group isouth: walk-in interiors for Cork, Kilkenny, the Comeraghs, Dingle and the
Ring of Kerry. Run: python3 tools/zones/world_isouth.py data/zones
Writes interior zones (landmark()), their dialogue, and hand-patches the town/route JSON (doors, warps, a few new
homes). Idempotent: running it again does not duplicate warps, buildings or doors."""
import sys, os, json
from collections import deque
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".,#=:fsw+|_khr")


def say(who, text):
    assert len(text) <= 200, (len(text), text)
    assert "—" not in text and "–" not in text, text
    return {"do": "say", "who": who, "text": text}


# interiors: (zid, name, zone, door(x,y), kind, npcs, w, h)
# npc = (id, sprite, who, [lines], optional gift (flag, item, repeat_text))
L = []
# new houses added to the zone maps: zone -> [(x, y, w, h, style)]
NEW_HOUSES = {
    "kilkenny": [(14, 30, 5, 4, "white_render"), (20, 30, 5, 4, "stone"), (54, 25, 4, 4, "slate_cottage")],
    "dingle": [(19, 28, 5, 4, "slate_cottage"), (44, 28, 5, 4, "cream_render")],
    "ring_of_kerry": [(19, 15, 4, 4, "stone")],
    "comeraghs": [(31, 28, 5, 4, "slate_cottage")],
}
ROW_FIX = {  # (zone, x, y, ch): open a tile so a door has somewhere to open onto
    ("kilkenny", 41, 11): ".",
}
GATED = {"kerry_innisfallen": "brook_wade"}
# deep-water causeway to Innisfallen (Brook-wade)
for yy in range(33, 39):
    ROW_FIX[("ring_of_kerry", 12, yy)] = "o"


def add(zid, name, zone, door, kind, npcs, w=13, h=10):
    L.append((zid, name, zone, door, kind, npcs, w, h))


def dr(bx, by, bw, bh, dx=None):
    return (bx + (bw // 2 if dx is None else dx), by + bh - 1)


# ---------------------------------------------------------------- CORK
add("cork_shandon", "St Anne's Shandon", "cork", dr(21, 4, 6, 5), "church", [
    ("shandon_ringer", "choir_singer", "Bell Ringer", [
        "Welcome to St Anne's, Shandon. Bring your ears. Visitors may ring the bells, and nobody calls the Guards.",
        "The tower went up in the 1720s. It has four clock faces, and they once disagreed on the time, so Cork calls it the four-faced liar.",
        "On top, the weather vane is a golden salmon. Cork is a river city, and the fish gets the best view in town.",
        "Father Mahony wrote 'The Bells of Shandon' about them in the 1830s. He wrote as 'Father Prout', which is a very good name for a priest."])]
    , 13, 10)
add("cork_butter", "The Butter Exchange", "cork", dr(8, 4, 8, 5), "museum", [
    ("butter_curator", "tour_guide", "Curator", [
        "Welcome to the Butter Exchange. It opened in 1769. Butter was weighed, graded and branded right here, then packed in barrels.",
        "In its day Cork was one of the biggest butter markets on Earth. Salted butter kept well, so ships carried it round the world.",
        "A barrel of it was called a firkin. A Cork firkin held about 25 kilos, which is a lot of toast."])], 13, 10)
add("cork_pairc", "Páirc Café", "cork", dr(41, 4, 8, 5), "cafe", [
    ("pairc_owner", "villager_4", "Cafe Owner", [
        "Welcome to Páirc Café, named for Páirc Uí Chaoimh, the big GAA ground by the Lee. Cork hurlers and footballers play there.",
        "The ground honours Pádraig Ó Caoimh, who ran the GAA for 35 years. He liked a tidy pitch and a tidy report."]),
    ("pairc_hurler", "hurler", "Hurling Fan", [
        "The ball is a sliotar. It is tough as a boot and flies faster than a bus on the Dublin road.",
        "Rule one of hurling is that you duck. Rule two is that there is no rule two."])], 11, 9)
add("cork_patrick", "Patrick Street Shops", "cork", dr(20, 28, 7, 4), "workshop", [
    ("patrick_shopper", "villager_2", "Shop Assistant", [
        "Welcome to Patrick Street. Locals call it Pana, because nobody has time for the whole name.",
        "The street curves because it was built over a river channel in the 1780s. Cork's city centre sits on an island between two arms of the Lee.",
        "The name Cork comes from corcach, which means marsh. So you are standing on a swamp. A very stylish swamp."])], 13, 9)
add("cork_market", "The English Market", "cork", dr(34, 28, 12, 4), "cafe", [
    ("market_stallholder", "villager_5", "Stallholder", [
        "Welcome to the English Market. It has stood here since 1788, so we have sold fish to the Georgians, the Victorians and everyone since.",
        "It was run by Cork's Protestant corporation, and the name stuck. Everyone in here is as Cork as can be.",
        "In 2011 Queen Elizabeth II dropped in and laughed so hard at a fishmonger's joke that it made the papers.",
        "Take a soda bread for the road. We cut a cross in the top, to let the fairies out."],
        ("cork_market_gift", "soda_bread", "Another loaf? You will have fairies following you home. Off you go."))], 14, 10)
add("cork_oliver", "The Oliver Plunkett", "cork", dr(48, 28, 8, 4), "theatre", [
    ("oliver_fiddler", "fiddler", "Fiddler", [
        "Pull up a bench. Tuesday is the slow session, when every tune is played at the speed of a Sunday walk.",
        "Oliver Plunkett Street is named for Saint Oliver Plunkett, an archbishop made a saint in 1975. He was the first Irish saint in over 700 years.",
        "In Cork you will hear 'boy' for everyone and 'like' at the end of everything, like. It is a very efficient accent."])], 13, 10)
add("cork_cityhall", "City Hall", "cork", dr(5, 18, 6, 4), "hall", [
    ("cityhall_clerk", "commuter", "Clerk", [
        "Welcome to City Hall. Mind the echo, it has opinions.",
        "This building opened in 1936 on the bank of the Lee. The city hall before it was lost in a fire in 1920.",
        "Cork calls itself the Rebel County, and the real capital of Ireland. Dublin says nothing and checks its watch."])], 13, 10)
add("cork_books", "Opera Lane Books", "cork", dr(16, 19, 7, 3), "library", [
    ("books_keeper", "poet", "Bookseller", [
        "Opera Lane Books. We borrow the name from the Opera House close by. The lane is shorter than the sign.",
        "Frank O'Connor was born in Cork in 1903 and became one of the best short story writers in the world.",
        "George Boole taught maths at Cork's university from 1849. His true-or-false algebra is why your computer works. Thank a Cork man."])], 13, 10)
add("cork_grandparade", "Grand Parade Cafe", "cork", dr(34, 19, 8, 4), "cafe", [
    ("grandparade_owner", "villager_1", "Cafe Owner", [
        "Grand Parade is wide because it was built on filled-in river channels. The Lee is still down there, grumbling.",
        "In Cork it is Barry's Tea or nothing. It has been made here since 1901. Lyons is a Dublin tea, and I would never say it to your face.",
        "Here, a cup on the house. I only ask that you never say 'Lyons'."],
        ("cork_grandparade_gift", "cup_of_tea", "Another cup? You are a hard woman to refuse. Go on."))], 12, 9)
add("cork_finbarre", "St Fin Barre's Cathedral", "cork", dr(16, 39, 14, 9, 7), "church", [
    ("finbarre_verger", "choir_singer", "Verger", [
        "Welcome to St Fin Barre's. Finbarr, Cork's patron saint, set up a monastery on this spot in the 600s.",
        "The cathedral was designed by William Burges and consecrated in 1870. He also did Cardiff Castle, so he knew his turrets.",
        "Look up for the gilded angel on the east end, and count the three spires. Burges never met a spire he did not like."])], 15, 11)
add("cork_home1", "The Kellehers' House", "cork", dr(34, 4, 6, 5), "home", [
    ("kelleher_nan", "villager_1", "Nan Kelleher", [
        "Come in, come in, mind the cat. Sit down and I will put the kettle on. It is a very Cork thing to do, and a very everyone thing.",
        "A word for you: 'gatch' means a swagger, or a daft way of walking. Your gatch is lovely, by the way.",
        "If something is squealing by the bins at night, that is a Binfox. Foxes see in the dark with cat-like pupils, so a torch is no use for sneaking."])], 12, 9)
add("cork_home2", "The Murphys' House", "cork", dr(58, 28, 5, 4), "home", [
    ("murphy_dad", "villager_3", "Mr Murphy", [
        "Grand to see you. 'Grand' means anything from fine to fantastic, depending on the tone.",
        "Cork Harbour at Cobh is one of the biggest natural harbours in the world. The Titanic made her last stop there in 1912.",
        "Never eat chips outdoors. A Chipgull has no manners, and a Pierlord will take the paper too."]),
    ("murphy_kid", "student", "Aoife", [
        "I am learning the tin whistle. Everyone says I am doing great, which is what they say about squeaking.",
        "Dad calls the TV remote 'the yoke'. A yoke is any thing at all. It is the most useful word in Cork."])], 11, 9)
add("cork_home3", "Mrs Lynch's House", "cork", dr(44, 19, 6, 4), "home", [
    ("lynch_mrs", "mum", "Mrs Lynch", [
        "Sit, sit. If someone is 'gas' in Cork, they are funny. My husband is gas. My son is a langer, but a lovely one.",
        "A Hushwing lives in the church roof round the corner. A barn owl can hear a mouse in the dark, so tiptoeing past will not fool it.",
        "The Lee has salmon in it. They come back to the river they were born in, and they never ask for directions."])], 13, 9)

# ---------------------------------------------------------------- KILKENNY
add("kilkenny_castle", "Kilkenny Castle", "kilkenny", dr(13, 4, 11, 6), "castle", [
    ("castle_guide", "tour_guide", "Castle Guide", [
        "Welcome to Kilkenny Castle. William Marshal, son-in-law of Strongbow, built the first stone one here in the 1190s, beside the Nore.",
        "The Butler family owned it from 1391 until 1967. Then the last of them sold it to the people of Kilkenny for just 50 pounds.",
        "Do see the Long Gallery, with its painted roof and portraits. The Butlers did like their faces on a wall."])], 15, 11)
add("kilkenny_tourist", "Tourist Office", "kilkenny", dr(8, 15, 5, 5), "hall", [
    ("tourist_staff", "villager_2", "Tourist Officer", [
        "Welcome to Kilkenny! Take a map. The Medieval Mile runs from the castle up to the cathedral, so you cannot go wrong, unless you go wrong.",
        "Kilkenny is the Marble City, for its polished black limestone. It looks like marble. It is limestone with good PR.",
        "And mind the Slips, the narrow lanes between the streets. They are the best shortcuts in town, if you fit."])], 12, 9)
add("kilkenny_rothe", "Rothe House", "kilkenny", dr(33, 15, 8, 5), "museum", [
    ("rothe_curator", "poet", "Curator", [
        "Rothe House was built by a merchant, John Rothe Fitz Piers, between 1594 and 1610. Three houses, three courtyards and a long garden.",
        "The garden is a Tudor plot, with herbs, vegetables and an orchard. In those days townsfolk grew most of their own dinner.",
        "It is one of the best Tudor merchant houses left in Ireland, which is a lot of 'best' for one building."])], 13, 10)
add("kilkenny_kyteler", "Kyteler's Inn", "kilkenny", dr(42, 15, 5, 5), "cafe", [
    ("kyteler_host", "villager_6", "Host", [
        "Welcome to Kyteler's. Dame Alice Kyteler lived here in the 1300s, a rich lady with four husbands and a head for business.",
        "In 1324 she was accused of witchcraft, in the first big witch case recorded in Ireland. She escaped to England and was never caught.",
        "Locals say the charges were really about her money. Some swear her ghost tidies the cellar, which is more than I do."])], 11, 9)
add("kilkenny_canice", "St Canice's Cathedral", "kilkenny", dr(46, 3, 12, 10), "church", [
    ("canice_verger", "choir_singer", "Verger", [
        "Welcome to St Canice's. Kilkenny comes from Cill Chainnigh, which means the church of Cainnech, or Canice. This is his hill.",
        "Canice was a monk who lived in the 500s and knew Saint Columba. The cathedral you see is mostly from the 1200s.",
        "It is one of the longest cathedrals in Ireland. The round tower beside it is older still. Climb it if your knees agree."])], 15, 11)
add("kilkenny_tower", "The Round Tower", "kilkenny", (41, 10), "church", [
    ("tower_warden", "villager_3", "Tower Warden", [
        "Welcome to the Round Tower. It is about 30 metres tall and nearly a thousand years old, maybe more.",
        "Monks used these towers as bell towers, and as a place to hide valuables and themselves when raiders came. The door is high up for a reason.",
        "There are 121 steps to the top. I counted twice and got two answers, which is why I mind the door."])], 11, 9)
add("kilkenny_tholsel", "The Tholsel", "kilkenny", dr(9, 25, 7, 4), "hall", [
    ("tholsel_clerk", "commuter", "Clerk", [
        "Welcome to the Tholsel. The name comes from 'toll' and an old word for hall. So it is, literally, the Toll Hall.",
        "The building you see went up around 1761, with arches over the pavement and a clock tower on top.",
        "People walk through its arches every day without looking up. Do look up."])], 13, 9)
add("kilkenny_butterslip", "Butter Slip Cafe", "kilkenny", dr(18, 25, 7, 4), "cafe", [
    ("butterslip_owner", "villager_4", "Cafe Owner", [
        "Welcome to the Butter Slip Cafe. We are named for the slip outside, one of Kilkenny's narrow medieval lanes. Mind your elbows.",
        "If someone says they are 'giving out' in Kilkenny, they are scolding you, not donating. I am mostly donating soup.",
        "Here, a cup of tea for the road. It is the Irish way to keep warm and keep talking."],
        ("kilkenny_butterslip_gift", "cup_of_tea", "A second cup? That is how a visit turns into an afternoon. Go on with you."))], 12, 9)
add("kilkenny_craft", "Craft Shop", "kilkenny", dr(30, 25, 6, 4), "workshop", [
    ("craft_maker", "villager_5", "Craftswoman", [
        "Kilkenny is a craft town. Kilkenny Design Workshops started in 1963, in the castle's old stables, to help Irish makers.",
        "See the black tray? It is Kilkenny limestone, polished until it shines. Look closely for little fossils.",
        "The fossils are shells and corals from a warm sea over 300 million years ago, when Ireland sat near the equator."])], 13, 9)
add("kilkenny_hurling", "Hurling Museum", "kilkenny", dr(37, 25, 7, 4), "museum", [
    ("hurling_curator", "hurler", "Curator", [
        "Welcome to the hurling museum. Hurling has been played in Ireland for at least 2,000 years, so it is not going anywhere.",
        "The hurley is carved from ash. The ball, the sliotar, has a cork core and a leather cover, and it can fly well over 100 kilometres an hour.",
        "Kilkenny teams are the Cats, in black and amber. Cork and Kilkenny have a long and friendly feud. Do not mention it near either."])], 13, 10)
add("kilkenny_home1", "The Brennans' House", "kilkenny", dr(46, 25, 7, 4), "home", [
    ("brennan_da", "villager_2", "Mr Brennan", [
        "Come in. If I say 'your man', I mean that fellow over there. 'Your man at the shop gave me the wrong change.'",
        "In 1366 Kilkenny held a parliament that passed the Statutes of Kilkenny, banning settlers from speaking Irish. It did not work. Everyone kept speaking it.",
        "A Moolet is a tiny Dexter cow. Dexters come from the south-west of Ireland, and they are among the smallest cattle in the world."])], 12, 9)
add("kilkenny_home2", "The Dalys' House", "kilkenny", dr(14, 30, 5, 4), "home", [
    ("daly_gran", "mum", "Gran Daly", [
        "That hurley over the fire was my father's. We touch it for luck before the big matches, whether it is working or not.",
        "In spring, if you see two hares boxing, it is usually the lady fending off the gentleman. Do not blame the hare.",
        "Bad news about the weather, 'tis 'lashing' out there. In Kilkenny that means raining hard, not being generous."])], 11, 9)
add("kilkenny_home3", "The Walshes' House", "kilkenny", dr(20, 30, 5, 4), "home", [
    ("walsh_mrs", "villager_6", "Mrs Walsh", [
        "Kilkenny sits on the River Nore. If you are quiet by the water, you might spot a Rillotter. Otter droppings smell of jasmine tea, honestly.",
        "There is a tale of the Kilkenny cats, who fought until only their tails were left. We are very proud, and the tails have not been found.",
        "My sister says 'yoke' for everything, and 'banjaxed' for broken. 'The yoke is banjaxed.' It is a full sentence."])], 13, 9)
add("kilkenny_home4", "The Cullens' House", "kilkenny", dr(54, 25, 4, 4), "home", [
    ("cullen_grandad", "villager_3", "Mr Cullen", [
        "For a few years in the 1640s Kilkenny was the capital of Confederate Ireland. The parliament met right in this town.",
        "If a Binfox gets into your bin, do not chase it. It will only leave a trail and an opinion.",
        "My granddaughter says we bleed black and amber, like the Cats. I tell her I am more of a tabby."])], 11, 9)

# ---------------------------------------------------------------- COMERAGHS
add("comeraghs_bothy", "Mountain Bothy", "comeraghs", dr(12, 20, 5, 4), "cottage", [
    ("bothy_keeper", "hillwalker", "Bothy Walker", [
        "Welcome to the bothy. A bothy is a simple shelter for walkers, free for anyone to use, and best left tidier than you found it.",
        "The Comeraghs are in County Waterford. Coumshingaun is a corrie, a steep bowl with a lake in it, scooped out by a glacier thousands of years ago.",
        "Mahon Falls pours off the plateau on the east side. Here, a flask of tea. Walkers have to look after one another."],
        ("comeraghs_bothy_gift", "flask_of_tea", "Another flask? I need some myself. Off you go, and keep to the path."))], 11, 9)
add("comeraghs_farm", "The Farmhouse", "comeraghs", dr(31, 28, 5, 4), "cottage", [
    ("comeragh_farmwife", "farmer", "Farmer", [
        "Come in out of the wind. Waterford folk call themselves the Deise, and our county in Irish is Port Láirge.",
        "Waterford city is said to be the oldest in Ireland. The Vikings founded it in 914, and it has been arguing about it since.",
        "Mind the Pooka on the heather roads. Folk say it spoils the blackberries after Samhain, so we pick them early."])], 11, 9)

# ---------------------------------------------------------------- DINGLE
add("dingle_dolphin", "The Dolphin Gifts", "dingle", dr(3, 11, 7, 4, 2), "workshop", [
    ("dolphin_shopkeeper", "villager_4", "Shopkeeper", [
        "Welcome to the Dolphin Gifts. Fungie the dolphin lived in Dingle harbour from 1983, and boats took visitors out to see him for nearly forty years.",
        "He swam off in 2020, and the town still waves at the harbour. A bottlenose dolphin can live forty years or more.",
        "Dolphins sleep with half the brain at a time, so the other half keeps them swimming. I wish I could do that on a Monday."])], 13, 9)
add("dingle_fish", "Fish Supper", "dingle", dr(11, 11, 6, 4), "cafe", [
    ("fishsupper_cook", "fisher", "Fish Cook", [
        "Fish and chips, Dingle style. The fish was in the bay this morning. The chips were in a field this week.",
        "Dingle's Irish name is An Daingean, which means 'the stronghold'. The Irish is still spoken in the shops, on the signs and on the street.",
        "A tip: the gulls on the harbour wall know all about chips. A Chipgull will have your supper if you look away."])], 11, 9)
add("dingle_cone", "Cone Zone", "dingle", dr(18, 11, 5, 4), "cafe", [
    ("cone_server", "villager_6", "Ice Cream Server", [
        "Cone Zone! Dingle is famous for ice cream. Murphy's began here in 1999 and made sea salt flavour, which sounds odd and tastes brilliant.",
        "The milk comes from Kerry cows, a small black breed, and one of the oldest in Ireland. They are very good at their jobs."])], 11, 9)
add("dingle_tweed", "Tweed and Wool", "dingle", dr(24, 11, 4, 4), "workshop", [
    ("tweed_weaver", "villager_3", "Weaver", [
        "Tweed and Wool. Irish tweed is woven from sheep's wool, and it keeps the rain out, which is a full-time job around here.",
        "Báinín is undyed wool, the colour of the sheep's own coat. The word comes from bán, which means white.",
        "Behind the town, Mount Brandon rises nearly a thousand metres. The sheep up there have the best view in Kerry, and know it."])], 13, 9)
add("dingle_marina", "Marina Cafe", "dingle", dr(32, 11, 5, 4), "cafe", [
    ("marina_skipper", "fisher", "Skipper", [
        "Welcome to the Marina Cafe. Dingle harbour is a long narrow inlet, so the boats are safe in a gale and hard to find in a fog.",
        "The stone tower on the hill above is Eask Tower, built in 1847 as a landmark for ships.",
        "Look out for the Bayrunners. They race the boats for fun, and they win."])], 12, 9)
add("dingle_books", "Books Beyond the Bay", "dingle", dr(38, 11, 6, 4), "library", [
    ("books_beyond_keeper", "poet", "Bookseller", [
        "Books Beyond the Bay. The Blasket Islands, off the tip of the peninsula, gave Irish literature some of its finest memoirs.",
        "Tomás Ó Criomhthain wrote 'An tOileánach', 'The Islandman'. Peig Sayers told her life story. Muiris Ó Súilleabháin wrote 'Fiche Blian ag Fás'.",
        "The islanders left the Blaskets in 1953. The books are what stayed, which is a good reason to write things down."])], 13, 10)
add("dingle_bakery", "Strand Bakery", "dingle", dr(45, 11, 5, 4), "cafe", [
    ("strand_baker", "villager_1", "Baker", [
        "Strand Bakery. Brown bread, scones and barmbrack, which comes from 'bairín breac', the speckled loaf.",
        "A barmbrack at Halloween has a ring baked in. Whoever finds the ring will be lucky. Whoever swallows it will be quiet.",
        "Here, a farl of soda bread for the road. It is best eaten warm, and fastest eaten before the gulls spot it."],
        ("dingle_bakery_gift", "soda_bread", "Another farl? You are eating for two, or for one very hungry two. Go on."))], 11, 9)
add("dingle_pierbar", "The Pier Bar", "dingle", dr(51, 11, 6, 4, 2), "theatre", [
    ("pier_fiddler", "fiddler", "Fiddler", [
        "Pull up a bench. There is music most nights here, and the tunes go on until someone has a boat to catch.",
        "Tunes come in types. A jig is in 6/8, a reel in 4/4, and a slide in 12/8, which sounds like falling down a hill, in a good way.",
        "At a session you wait until a tune has ended before you join in. It is polite, and it saves the fiddlers a headache."])], 13, 10)
add("dingle_oceanworld", "Oceanworld", "dingle", dr(19, 20, 8, 4), "museum", [
    ("oceanworld_keeper", "tour_guide", "Aquarium Guide", [
        "Welcome to Oceanworld, Dingle's aquarium. We look after the creatures of the Atlantic coast, from sea stars to rays.",
        "Basking sharks visit the Kerry coast in summer. They are the second biggest fish in the world, and they only eat plankton. Very gentle.",
        "Touch the starfish gently, with two fingers. A starfish has no brain, but it does have manners."])], 14, 10)
add("dingle_inn", "The Dolphin Inn", "dingle", dr(32, 20, 9, 4, 6), "hall", [
    ("inn_host", "mum", "Innkeeper", [
        "Céad míle fáilte to the Dolphin Inn. It means a hundred thousand welcomes, and we mean most of them.",
        "Breakfast is until ten. Ask for the full Irish and you will need a lie down afterwards.",
        "The peninsula is called Corca Dhuibhne in Irish, after an old tribe, the Corcu Duibne. They got here long before the breakfast."])], 13, 10)
add("dingle_gallarus", "Gallarus Gifts", "dingle", dr(42, 20, 6, 4), "workshop", [
    ("gallarus_seller", "villager_2", "Gift Shop Owner", [
        "Gallarus Gifts. The real Gallarus Oratory is a few miles away, a little stone church shaped like an upturned boat.",
        "It was built without mortar. Each layer of stone leans in a little more until they meet, and it has kept the rain out for over a thousand years.",
        "Not a bad record for a building with no glue. Our shelves are held up with considerably more."])], 13, 9)
add("dingle_bus", "Bus Office", "dingle", dr(49, 20, 6, 4, 2), "hall", [
    ("bus_clerk", "commuter", "Ticket Clerk", [
        "Bus Office. Buses to Tralee and Killarney and every beautiful road between. Tickets on the left, sympathy on the right.",
        "There was a railway here once. The Tralee and Dingle Light Railway ran from 1891 until 1953, and it was said to be the most westerly in Europe.",
        "The Slea Head Drive circles the tip of the peninsula. Take the bus. The roads are narrow and the sheep have right of way."])], 12, 9)
add("dingle_james", "St James' Church", "dingle", dr(36, 28, 6, 4, 2), "church", [
    ("james_sacristan", "choir_singer", "Sacristan", [
        "Welcome to St James'. Behind the town rises Mount Brandon, nearly a thousand metres, named after Saint Brendan the Navigator.",
        "Brendan was a monk who, the old story goes, sailed west in a leather boat. In 1976 Tim Severin built a copy and sailed from Kerry to Newfoundland.",
        "It worked, which surprised everyone, including the cows who donated the leather. The pilgrim path up the mountain is Cosán na Naomh."])], 13, 10)
add("dingle_home1", "The O'Sullivans' House", "dingle", dr(2, 20, 3, 4, 1), "home", [
    ("osullivan_ma", "villager_1", "Mrs O'Sullivan", [
        "Dia dhuit! That means 'God to you', and you answer 'Dia is Muire dhuit'. Then you may sit and have tea.",
        "Selkie stories say seals take off their skins to walk ashore as people. A Selklet pup is born white, and the pale fur goes in weeks.",
        "Our Cian has Irish homework. 'Go raibh maith agat' is thank you. He can say it fine. He cannot say it to his sister."])], 11, 9)
add("dingle_home2", "The Kennedys' House", "dingle", dr(56, 20, 3, 4, 1), "home", [
    ("kennedy_nan", "mum", "Nan Kennedy", [
        "Fáilte. If you hear a rasping crex-crex at night in the long meadow, that is a Crexling, calling for company.",
        "They were once common across Ireland. They need meadows cut late, so the chicks can grow up. We leave a corner uncut for them.",
        "And craic, pronounced crack, means fun. 'What's the craic?' is hello. The answer is usually 'Not much, and plenty of it.'"])], 11, 9)
add("dingle_home3", "The Moriartys' House", "dingle", dr(19, 28, 5, 4), "home", [
    ("moriarty_da", "fisher", "Mr Moriarty", [
        "Come in, we are mad for company. 'Slán abhaile' is 'safe home', and I say it to every boat.",
        "A Gannetling folds its wings and dives from a great height. They can plunge 30 metres, and the Plungebeak does it in style.",
        "My nephew was named Fungie, after the dolphin. He says he is the second most famous Fungie in the harbour."])], 12, 9)
add("dingle_home4", "The Fitzgeralds' House", "dingle", dr(44, 28, 5, 4), "home", [
    ("fitzgerald_teacher", "villager_5", "Mr Fitzgerald", [
        "Welcome in. I teach at the scoil, which is the school. A madra is a dog, and a cat is a cat, because the cats never learned Irish.",
        "In the spring the Polartern nests on the shore. It is an Arctic tern, flying pole to pole each year. Do not wave near a nest, it will dive at you.",
        "Dingle is in the Gaeltacht, where Irish is the everyday language. The Irish lessons come free with the weather."])], 12, 9)

# ---------------------------------------------------------------- RING OF KERRY
add("kerry_innisfallen", "Innisfallen Abbey", "ring_of_kerry", dr(11, 30, 3, 2, 1), "church", [
    ("innisfallen_scribe", "poet", "Scribe", [
        "Welcome to Innisfallen. Saint Finian the Leper founded a monastery on this island around 640. We keep the quiet here.",
        "Monks wrote the Annals of Innisfallen here, a history of Ireland from the early centuries to the 1300s. The book is in Oxford now.",
        "The island sits in Lough Leane, the biggest of the Killarney lakes. Bring a boat, or a firm belief in Brook-wade."])], 11, 9)
add("kerry_ross", "Ross Castle", "ring_of_kerry", dr(32, 28, 5, 4), "castle", [
    ("ross_ghillie", "ghillie", "Castle Warden", [
        "Welcome to Ross Castle. It is a tower house built by the O'Donoghue chiefs in the 1400s, on the shore of Lough Leane.",
        "The legend says it would never fall until a warship sailed on the lake. In 1652 Parliament's forces brought boats, and the legend was right.",
        "Red deer roam the park behind. In autumn the stags roar across the valley. Do not argue with a Stagmor."])], 13, 10)
add("kerry_cottage", "The Cottage", "ring_of_kerry", dr(19, 15, 4, 4), "cottage", [
    ("kerry_cottager", "farmer", "Farmer", [
        "Come in and sit. In Kerry, 'sure look it' is a whole sentence. It means 'what can you do?', and it is the answer to everything.",
        "Killarney has the last truly native herd of red deer in Ireland. The stags roar in autumn, and the Fawnlets hide in the bracken.",
        "Daniel O'Connell, the Liberator, was born near Cahersiveen in 1775. We say that to visitors, and they say 'who?', and we say it again."])], 11, 9)

# ---------------------------------------------------------------- build
def blocked_interior(z):
    return {(p["x"], p["y"]) for p in z.d["props"]} | {(x, y) for y in range(z.h) for x in range(z.w) if z.g[y][x] in "xCD"}


def place_npcs(zid, name, zone, ret, kind, specs, w, h):
    """Choose standing tiles for the NPCs off props, counters and the exit lane, then check they are reachable."""
    z = landmark(OUT, zid, name, zone, ret, kind, [], w, h)
    blocked = blocked_interior(z)
    dx = w // 2
    used = []
    targets = [(dx, 3), (w - 4, 3), (3, 3)]
    for i, spec in enumerate(specs):
        tx, ty = targets[i]
        best = None
        for y in range(2, h - 3):
            for x in range(2, w - 2):
                if (x, y) in blocked or (x, y) in used or abs(x - dx) <= 0 and y >= h - 4:
                    continue
                free = [(x + a, y + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))
                        if (x + a, y + b) not in blocked and (x + a, y + b) not in used and 1 <= x + a < w - 1 and 1 <= y + b < h - 1]
                if not free:
                    continue
                d = abs(x - tx) + abs(y - ty)
                if best is None or d < best[0]:
                    best = (d, x, y)
        assert best, zid
        used.append((best[1], best[2]))
    # reachability: flood from spawn, every NPC must touch a reached tile
    spawn = tuple(z.d["spawn"])
    seen = {spawn}
    q = deque([spawn])
    while q:
        cx, cy = q.popleft()
        for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (cx + a, cy + b)
            if n in seen or n in blocked or n in used or not (0 < n[0] < w - 1 and 0 < n[1] < h - 1):
                continue
            seen.add(n)
            q.append(n)
    for (x, y) in used:
        assert any((x + a, y + b) in seen for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))), (zid, x, y)
    return used


dlg = {}
patches = {}
for zid, name, zone, door, kind, npcs, w, h in L:
    ret = (door[0], door[1] + 1)
    pos = place_npcs(zid, name, zone, ret, kind, npcs, w, h)
    nl = []
    for spec, (px, py) in zip(npcs, pos):
        nid, spr, who, lines = spec[:4]
        nl.append(dict(id=nid, sprite=spr, x=px, y=py, facing="down", move="still", script=nid))
        if len(spec) > 4:
            flag, item, again = spec[4]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag, "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, zone, ret, kind, nl, w, h)
    patches.setdefault(zone, []).append((zid, door, w, h))

for zone in set(list(patches) + list(NEW_HOUSES)):
    tj = os.path.join(OUT, zone + ".json")
    td = json.load(open(tj))
    rows = [list(r) for r in td["rows"]]
    for (z2, x, y), ch in ROW_FIX.items():
        if z2 == zone:
            rows[y][x] = ch
    for (x, y, w, h, style) in NEW_HOUSES.get(zone, []):
        if not any(p["type"] == "building" and p["x"] == x and p["y"] == y for p in td["props"]):
            td["props"].append({"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h, "show_label": False})
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                rows[yy][xx] = "B"
    blockers = {(p["x"], p["y"]) for p in td["props"] if p["type"] != "building"}
    blockers |= {(s["x"], s["y"]) for s in td["signs"]} | {(n["x"], n["y"]) for n in td["npcs"]}
    for zid, door, w, h in patches.get(zone, []):
        x, y = door
        assert rows[y][x] in "BD", (zid, rows[y][x])
        rows[y][x] = "D"
        if rows[y + 1][x] not in WALK:
            rows[y + 1][x] = "#"
        assert (x, y + 1) not in blockers, ("blocked south of door", zid, x, y + 1)
        if not any(wp["x"] == x and wp["y"] == y for wp in td["warps"]):
            wp = {"x": x, "y": y, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"}
            if zid in GATED:
                wp["gate"] = GATED[zid]
            td["warps"].append(wp)
    td["rows"] = ["".join(r) for r in rows]
    json.dump(td, open(tj, "w"), indent=1, ensure_ascii=False)

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print(len(L), "interiors")
