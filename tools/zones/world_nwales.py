"""World pass (Wildlore 1.1): walk-in interiors for North Wales.
Zones: anglesey, holyhead, llanberis, llanberis_quarry, llangollen, dee_valley, ogwen, yr_wyddfa.
Run: python3 tools/zones/world_nwales.py data/zones
Hand-edits the town JSON in place (adds a door tile + warp per building, a path tile where needed), writes the
interiors with landmark(), and writes data/dialogue/<interior>.json. Safe to re-run (skips doors that exist)."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".,#=:sfw|+_")


def say(who, text):
    assert len(text) <= 200, (len(text), text)
    assert "—" not in text and "–" not in text, text
    return {"do": "say", "who": who, "text": text}


L = []


def add(zid, name, town, b, kind, npcs, size=(13, 10), prefs=None):
    """b = (x, y, w, h, door_col_offset) of the building prop in the town."""
    L.append(dict(zid=zid, name=name, town=town, b=b, kind=kind, npcs=npcs, size=size, prefs=prefs))


# npc tuple: (id, sprite, who, lines[, (gift_flag, item, thanks_line)])

# ---------------------------------------------------------------- ANGLESEY
add("anglesey_signshop", "Station Sign Shop", "anglesey", (3, 30, 7, 4, 3), "workshop", [
    ("signshop_clerk", "shopkeeper", "Sign Shop Clerk", [
        "Welcome to the sign shop. Yes, we sell the long one. No, I cannot say it all in one breath.",
        "Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch has 58 letters. Say it slowly and you will get there.",
        "It means roughly St Mary's church in the hollow of the white hazel, near the fierce whirlpool and St Tysilio's church by the red cave.",
        "The long name was probably stretched in the 1860s to get visitors off the train. It worked. Here you are."])],
    size=(13, 10))
add("anglesey_mill", "Llynnon Mill", "anglesey", (20, 30, 4, 4, 1), "mill", [
    ("llynnon_miller", "villager_4", "Miller", [
        "Mind your head on the stairs. The sails do the hard work, and I do the standing about.",
        "Llynnon was built in 1775 and is said to be the last working windmill in Wales. It still grinds flour.",
        "Anglesey was once called Môn Mam Cymru, Mother of Wales, because its fields fed so much of the country.",
        "The sails turn into the wind by a little cap on top. Wind is free. Waiting for it is the expensive part."])],
    size=(11, 9))
add("anglesey_cottage", "Cottage on the Hill", "anglesey", (11, 30, 5, 4, 2), "cottage", [
    ("angcottage_nain", "mum", "Nain", [
        "Come in, cariad, mind the cat. Everyone calls me Nain, which is Welsh for grandma.",
        "Round here if someone is tamping, they are properly furious. Best to offer them a Welsh cake and back away slowly.",
        "On the lane I hear wispets at dusk. Little lights, flickering, bobbing along the hedge. Harmless but very showy.",
        "Our Sioned says the long village name was a stunt. I say it was good marketing, and I am rather fond of it."])],
    size=(11, 9))
add("anglesey_farm", "Stone Farmhouse", "anglesey", (25, 31, 3, 3, 1), "home", [
    ("angfarm_farmer", "farmer", "Farmer", [
        "Mind the boots. And the dog. Mostly the dog.",
        "We still make Anglesey eggs round here, with leeks, potatoes, cheese and eggs. It is better than it sounds, and it sounds great.",
        "There is a salt works on the island too, Halen Môn, made from the sea water of the Menai Strait. Fancy crisps, fancy crystals.",
        "My boy says I talk about the weather too much. It rained on Tuesday. See? I am not wrong."]),
    ],
    size=(12, 9))

# ---------------------------------------------------------------- HOLYHEAD
add("holyhead_watchtower", "Roman Watchtower", "holyhead", (26, 3, 3, 3, 1), "castle", [
    ("watchtower_warden", "tour_guide", "Heritage Warden", [
        "Salve, traveller. You are standing in a very old lookout. I am the very old lookout's very new guide.",
        "Caer Gybi was a Roman fort, built around the 4th century to watch for raiders crossing the Irish Sea.",
        "Three of its walls still stand, and the sea once guarded the fourth. The church inside them is St Cybi's.",
        "Watch the horizon, as they did. If you see a boat that is not a ferry, tell someone. Or just wave."])],
    size=(11, 9))
add("holyhead_museum", "Maritime Museum", "holyhead", (44, 17, 5, 4, 2), "museum", [
    ("maritime_curator", "shipwright", "Museum Curator", [
        "Welcome aboard. The deck is solid. Mostly because it is a floor.",
        "Holyhead's breakwater is about 1.5 miles long, started in 1847 and finished in 1873. It is one of the longest in Britain.",
        "Thomas Telford's road from London ended here too, because Holyhead was the mail port for Ireland.",
        "That means a lot of letters and a lot of seasick people. Please do not compare notes."])],
    size=(15, 10))
add("holyhead_chippy", "Fish and Chips", "holyhead", (19, 26, 6, 4, 2), "cafe", [
    ("chippy_owner", "villager_2", "Chippy Owner", [
        "Salt and vinegar? Course you do. Watch the gulls, they have no manners.",
        "Two places claim the first ever fish and chip shop: London in 1860 and Mossley, near Manchester, in 1863.",
        "I say the real first was in Holyhead and it was the best. I have no evidence, but I have a fryer.",
        "A chipgull will snatch a chip right out of your hand. Hold the tray high and walk with purpose."])],
    size=(13, 9))
add("holyhead_ferryinn", "The Ferry Inn", "holyhead", (26, 26, 7, 4, 3), "cafe", [
    ("ferryinn_host", "villager_6", "Innkeeper", [
        "Welcome to the Ferry Inn. Hot breakfast till eleven, hot opinions all day.",
        "Holyhead is the gateway to Ireland. Ferries leave for Dublin Port, about three and a half hours away.",
        "We get walkers, lorry drivers and day-trippers on the same morning. All of them want the same egg.",
        "Holy Island is joined to Anglesey by a long causeway, so technically you arrive by road and leave by sea."]),
    ("ferryinn_guest", "hiker", "Guest", [
        "I am booked on the next boat. I have been booked on the next boat since breakfast.",
        "The cliffs at South Stack are lovely, though. Watch for puffins in spring."])],
    size=(15, 10))
add("holyhead_cybi", "St Cybi's Church", "holyhead", (47, 6, 6, 5, 3), "church", [
    ("cybi_verger", "druid", "Verger", [
        "Welcome to St Cybi's. Voices low, please. The stones remember everything.",
        "Cybi was a 6th century holy man who came from the south west and set up a monastery inside the old Roman fort.",
        "The walls around the churchyard are Roman. They have been guarding the place for around 1,700 years, and are not tired yet.",
        "Look up at the old roof beams. Locals have been repairing them since the medieval days."])],
    size=(15, 11))
# holyhead_home1 and _home2 (the houses at 45,26 and 52,26) back onto the railway now, so they have no doors.
add("holyhead_home3", "Corner Cottage", "holyhead", (38, 6, 4, 3, 2), "cottage", [
    ("hh3_lad", "student", "Resident", [
        "I am revising for my exams. By which I mean I am sitting near a book.",
        "At the old fort you can see how the Romans picked a spot guarding the harbour. Smart. Same reason we have a ferry.",
        "My nan swears she saw a selklet on the rocks last winter. She is usually right about animals and wrong about directions."])],
    size=(11, 9), prefs=None)

# ---------------------------------------------------------------- LLANBERIS
add("llanberis_electric", "Electric Mountain", "llanberis", (39, 24, 12, 5, 6), "museum", [
    ("electric_guide", "steelworker", "Power Station Guide", [
        "Welcome to Electric Mountain. Behind me is a whole power station inside Elidir Fawr.",
        "Dinorwig opened in 1984. It is a pumped-storage station: water falls from a high lake to make power, then gets pumped back up.",
        "It can reach full power in less than 16 seconds. That is quicker than most kettles, and the whole country uses it.",
        "The cavern is carved into slate. Quarrymen dug the hillside for 150 years, and engineers just kept on digging."]),
    ("electric_kid", "student", "School Visitor", [
        "It is like a giant rechargeable battery. In a mountain. How cool is that?",
        "I asked if there was a dragon inside. The guide said no. I am not fully convinced."])],
    size=(17, 11))
add("llanberis_home_eglwys", "Bryn Eglwys", "llanberis", (39, 14, 4, 3, 2), "home", [
    ("eglwys_quarryman", "tin_miner", "Retired Quarryman", [
        "Bryn Eglwys means church hill. Do not ask me which church. It has gone and the hill stayed.",
        "I worked at Dinorwic until it closed in 1969. At its peak it gave work to something like 3,000 men.",
        "Half the roofs in Britain were once Welsh slate. Mine are probably on a church hall in Leeds.",
        "You will hear slatelets around the spoil heaps. They do not mind the quarry. They treat it as a playground."])],
    size=(12, 9))
add("llanberis_capelcoch", "Capel Coch", "llanberis", (51, 3, 4, 3, 1), "church", [
    ("capelcoch_deacon", "villager_3", "Chapel Steward", [
        "Croeso. Capel Coch means red chapel. You will notice it is not especially red. Do not tell the paint.",
        "In Wales the chapel was the centre of everything: singing, Sunday school, even learning to read for many families.",
        "Quarrymen would walk home from a twelve hour shift and still turn up for choir practice. That is Welsh stamina.",
        "Sit as long as you like. The pews were made to be sat on, not stared at."])],
    size=(13, 10))
add("llanberis_padarn", "Caffi Padarn", "llanberis", (32, 22, 4, 3, 2), "cafe", [
    ("padarn_owner", "villager_1", "Cafe Owner", [
        "Bore da, welcome! Tea, toast, Welsh cakes. We do not do anything with kale.",
        "Welsh cakes were cooked on a bakestone, so in Welsh they are called pice ar y maen, which means cakes on the stone.",
        "Llyn Padarn outside has a rare fish called the Welsh char, or torgoch. It has been here since the Ice Age.",
        "Here, take a slice of bara brith for the path. It is a Welsh tea loaf full of dried fruit."],
        ("llanberis_padarn_brith", "bara_brith", "Another slice? You will be buying the cafe next. Off you go, cariad."))],
    size=(13, 9))
add("llanberis_dolbadarn", "Dolbadarn Castle", "llanberis", (7, 23, 5, 3, 2), "castle", [
    ("dolbadarn_guide", "tour_guide", "Castle Guide", [
        "Welcome to Dolbadarn. One round tower, one great view, no cafe. I am working on that last part.",
        "Llywelyn the Great probably built the keep early in the 1200s to guard the Llanberis Pass.",
        "Llywelyn's grandson Owain Goch was held prisoner here for about twenty years by his own brother. A long stay, and no tea.",
        "The painter J. M. W. Turner came to sketch it in 1799. He added a lot of moody sky. Not hard in Snowdonia."])],
    size=(13, 10))
add("llanberis_home1", "Slate Cottage", "llanberis", (23, 14, 3, 3, 1), "cottage", [
    ("lh1_mam", "villager_6", "Resident", [
        "Hello, cariad, cariad meaning love. Yes, everyone gets one. We are generous with it.",
        "The Snowdon Mountain Railway has run since 1896. It climbs on a rack and pinion track, so it grips like a very polite goat.",
        "We keep hearing a tapping from the old slate wall at night. Dad says it is the coblynau, the Welsh knockers. Nan agrees. I stay out of it."])],
    size=(11, 9))
add("llanberis_home2", "Lakeside Terrace", "llanberis", (28, 22, 3, 3, 1), "cottage", [
    ("lh2_dad", "villager_5", "Resident", [
        "Mind the wellies. It rained last night. It will rain tonight. It is a very reliable village.",
        "My little one has a word for everything. Her favourite is hwyl: spirit, fun, the good feeling at a good gig.",
        "I have spotted a dipling on the shore a few times. It is small and shy. I take a biscuit and sit very still."])],
    size=(11, 9))
add("llanberis_home3", "Terrace End", "llanberis", (54, 23, 5, 4, 2), "home", [
    ("lh3_gran", "mum", "Resident", [
        "Come in and sit down. You look like you have been up Snowdon. Everyone does by Tuesday.",
        "Hiraeth is a Welsh word for missing home so much it aches. I felt it the day I moved two streets away.",
        "My husband worked on the lake railway. The locos came from the quarry, small and stubborn, like him."])],
    size=(13, 9))
add("llanberis_home4", "Quarry View", "llanberis", (4, 18, 4, 3, 1), "cottage", [
    ("lh4_lad", "fell_runner", "Resident", [
        "Just back from a run. Mum says I look like a drowned otter. Probably the correct look.",
        "Yr Wyddfa, the name Snowdon goes by in Welsh, means something like the burial mound. Not as cosy as it sounds.",
        "On the long route to the summit I always see a kidgruff on the crags. Grumpy little goat. We get on fine."])],
    size=(11, 9))
add("llanberis_home5", "Chapel Row", "llanberis", (9, 18, 4, 3, 1), "cottage", [
    ("lh5_nain", "villager_4", "Resident", [
        "Welcome in, bach. The kettle is on. It is always on. It is a very tired kettle.",
        "My grandad's quarry whistle is on the shelf. When it blew, everyone knew what time it was and what was for dinner.",
        "The wispets drift up from the marsh by Padarn on mild nights. Folk used to call it fairy fire. I call it good telly."])],
    size=(11, 9))

# ---------------------------------------------------------------- LLANBERIS QUARRY
add("quarry_powderstore", "Powder Store", "llanberis_quarry", (8, 26, 4, 2, 1), "workshop", [
    ("powder_keeper", "tin_miner", "Powder Keeper", [
        "Mind where you stand. Not that anything is stored here now, but old habits.",
        "Blasting slate used black powder. They set the charges carefully, and every quarryman knew the warning call.",
        "Dinorwic opened in 1787 and closed in 1969. It was once among the biggest slate quarries in the world.",
        "Everything here was built a little way off from the main workings. Sensible, that."])],
    size=(11, 9))
add("quarry_barracks", "Barracks", "llanberis_quarry", (24, 11, 4, 2, 1), "cottage", [
    ("barracks_cook", "villager_3", "Barracks Cook", [
        "In you come. Sit down. Do not touch the pot. It is not for you.",
        "Many quarrymen lived in these barics, which is Welsh for barracks, from Monday to Saturday, then walked home for Sunday.",
        "They would bring a week of bread, oatmeal and bacon, then cook it all on a single stove.",
        "A Saturday walk of ten miles was just 'getting home' in those days."])],
    size=(11, 9))
add("quarry_weighbridge", "Weighbridge", "llanberis_quarry", (22, 17, 4, 2, 2), "workshop", [
    ("weigh_clerk", "poet", "Weighbridge Clerk", [
        "Shh, I am counting. Seven, eight, nine... oh bother, now I have lost my place.",
        "Quarry teams were paid by the finished slate, under a system called the bargain. Rock that split badly meant a poor week.",
        "Slate sizes had grand names: Duchess, Countess and Lady, so a roof was a small aristocracy.",
        "Every slab went across this bridge and into someone's ledger. Mine is still full of sums."])],
    size=(11, 9))
add("quarry_caban", "Quarrymen's Caban", "llanberis_quarry", (10, 17, 4, 2, 2), "cottage", [
    ("caban_poet", "poet", "Caban Poet", [
        "Welcome to the caban. That is the hut where quarrymen ate lunch.",
        "It was a school, a debating chamber and a poetry club in one. They argued about politics and verse in equal measure.",
        "A good caban had a stove, a bench and a bard. Mine is the bard. I only need the stove.",
        "Here, a flask for the road. Hot and sweet. Do not tell the overseer."],
        ("quarry_caban_flask", "flask_of_tea", "Another flask? No, no, I have to keep one for the poem. Off you go."))],
    size=(11, 9))

# ---------------------------------------------------------------- LLANGOLLEN
add("llangollen_cartref", "Cartref", "llangollen", (5, 13, 5, 4, 2), "home", [
    ("cartref_gwen", "villager_6", "Gwen", [
        "Welcome to Cartref. It means home, and I think it is quite accurate.",
        "The Pontcysyllte Aqueduct runs a canal 38 metres above the river. I walk across it for fun, which my knees dispute.",
        "In Llangollen the best word for a gorgeous day is braf, which is Welsh for fine. We use it sparingly. It may run out.",
        "A brockling raided my compost heap last week. It took the apple cores and left a very tidy mess."])],
    size=(12, 9))
add("llangollen_bethel", "Capel Bethel", "llangollen", (11, 13, 5, 4, 2), "church", [
    ("bethel_organist", "choir_singer", "Organist", [
        "Shhh, I am tuning. The organ sulks if it is rushed.",
        "Bethel is Hebrew for house of God. Welsh chapels often took their names from the Bible, Zion, Salem and Bethel.",
        "This valley sings. Llangollen holds an International Musical Eisteddfod every July. It began in 1947.",
        "It started to bring people from the war-torn world together through music. A fine thing to do with a song."])],
    size=(13, 10))
add("llangollen_tearooms", "Plas Newydd Tea Rooms", "llangollen", (36, 13, 5, 4, 2), "cafe", [
    ("plasnewydd_host", "villager_2", "Tea Room Host", [
        "Welcome in. Scones, jam, cream, and a seat with a view. What more does a person need?",
        "Plas Newydd was the home of the Ladies of Llangollen, Lady Eleanor Butler and Sarah Ponsonby. They arrived in 1780.",
        "They left Ireland, set up house here and became so famous that Wordsworth and the Duke of Wellington came to tea.",
        "A cream tea for the road? Jam first, then cream. Anyone who says different is from Cornwall."],
        ("llangollen_tearooms_gift", "cream_tea", "A second one? The Ladies would be shocked. And a bit impressed. Off you go."))],
    size=(13, 10))
add("llangollen_pavilion", "Eisteddfod Pavilion", "llangollen", (47, 11, 9, 3, 3), "theatre", [
    ("pavilion_steward", "harpist", "Pavilion Steward", [
        "Hush, there is a rehearsal. Oh, it has not started. Hello then!",
        "The Llangollen International Musical Eisteddfod brings in choirs and dancers from all over the world every July.",
        "It began in 1947, two years after the war ended, and the first competitors came from more than a dozen countries.",
        "The Pavilion holds thousands. When they all sing, you can feel it in your teeth."])],
    size=(17, 11))
add("llangollen_dinasbran", "Castell Dinas Bran", "llangollen", (11, 28, 7, 3, 3), "castle", [
    ("dinasbran_guide", "hillwalker", "Hill Guide", [
        "You made it up the hill. Very good. The view is the reward. The hill is the entrance fee.",
        "Dinas Bran sits on a hill about 300 metres up. The castle was built in the 1260s by the princes of Powys Fadog.",
        "It was already a ruin within a couple of decades. The view, mercifully, has not changed.",
        "The old stories say the hill hides a gwyllgi, a spectral black dog. I have never seen it. I have heard a lot of Labradors."])],
    size=(15, 10))
add("llangollen_tygwyn", "Tŷ Gwyn", "llangollen", (29, 22, 4, 3, 1), "cottage", [
    ("tygwyn_nain", "mum", "Nain", [
        "Tŷ Gwyn means white house. It is white. We were not very creative.",
        "Telford and William Jessop built the Pontcysyllte Aqueduct. It opened in 1805, and it is now a World Heritage Site.",
        "If the water level is low, folk say you can see afanc ripples in the Dee. I say it is the tide of tourists."])],
    size=(11, 9))
add("llangollen_brynteg", "Bryn Teg", "llangollen", (34, 22, 4, 3, 1), "cottage", [
    ("brynteg_dad", "villager_1", "Resident", [
        "Bryn Teg means fair hill. I have no idea which hill. I think the house just liked the name.",
        "A Welsh canal horse used to walk the towpath for hours, pulling the boat. They were very stubborn and very well liked.",
        "My daughter says martlings stalk the trees near the river. They are small and quick, and I never get a good look."])],
    size=(11, 9))
add("llangollen_stationterrace", "Station Terrace", "llangollen", (54, 22, 5, 3, 2), "home", [
    ("stationterrace_fan", "rail_guard", "Resident", [
        "Welcome to my little museum. It is also my living room.",
        "The Llangollen Railway is a heritage line. They run proper steam engines along the Dee, and the whistle gets me every time.",
        "Steam trains use coal to heat water that makes steam that pushes pistons. Simple. Hard to get right."])],
    size=(13, 9))
add("llangollen_seion", "Capel Seion", "llangollen", (17, 22, 4, 3, 2), "church", [
    ("seion_deacon", "villager_4", "Deacon", [
        "Croeso. Seion is Welsh for Zion. The chapel is plain, and the singing is not.",
        "Welsh chapels had a tradition of congregational singing, with hymns in four-part harmony and no sheet music to hand.",
        "I once heard the whole congregation lift the roof. The roof is still here, so it held."])],
    size=(13, 9))
add("llangollen_home1", "River Cottage", "llangollen", (5, 22, 4, 3, 1), "cottage", [
    ("llh1_mam", "villager_3", "Resident", [
        "Come in, cariad. Wipe your feet or the dog will do it for you.",
        "The river Dee is the old border. For centuries Welsh and English crossed it, argued and traded.",
        "At night I leave a light on for the tylwyth teg, the fair family. Better to be on good terms with the neighbours."])],
    size=(11, 9))
add("llangollen_home2", "Towpath Cottage", "llangollen", (39, 22, 3, 3, 1), "cottage", [
    ("llh2_dad", "canal_boater", "Resident", [
        "Ahoy. Well, 'ahoy' if you live on the canal. I live on land. Mostly.",
        "A windlass is the handle you use to wind open a lock paddle. I own seven. I can find one on a good day.",
        "Elverlets dart around the water meadows. I see them from the towpath. They are very fast and very unimpressed."])],
    size=(11, 9))

# ---------------------------------------------------------------- DEE VALLEY
add("dee_tearooms", "Trevor Basin Tea Rooms", "dee_valley", (46, 11, 6, 3, 2), "cafe", [
    ("trevor_host", "villager_2", "Tea Room Host", [
        "Welcome to Trevor Basin. You can hear the boats before you see them.",
        "The aqueduct next door carries a canal 38 metres above the river. Telford and Jessop finished it in 1805.",
        "It is cast iron and stone, and a UNESCO World Heritage Site since 2009. Not many tea rooms can say they have that for a neighbour.",
        "The towpath on top has a drop on one side and no railings. Hold hands. Hold the tea."])],
    size=(13, 9))
add("dee_lockkeeper", "Lock Keeper's Cottage", "dee_valley", (14, 11, 4, 3, 1), "cottage", [
    ("lockkeeper_home", "canal_boater", "Lock Keeper", [
        "Come in, mind the windlass on the step. Lock keepers say it is a tool. The rest say it is a trip hazard.",
        "The canal here gets its water from the River Dee at the Horseshoe Falls, a curved weir Telford built in 1808.",
        "A narrowboat travels at walking pace. This is the point. If you wanted to hurry you would have taken the A5.",
        "I have seen minkshades and brocklings along the bank at dusk. Both leave very neat tracks."])],
    size=(11, 9))

# ---------------------------------------------------------------- OGWEN
add("ogwen_idwal", "Idwal Cottage", "ogwen", (6, 22, 4, 3, 1), "cafe", [
    ("idwal_warden", "hillwalker", "Warden", [
        "Boots off the mat, please. There is a puddle. There is always a puddle.",
        "Cwm Idwal was the first National Nature Reserve in Wales, set up in 1954. It is a very good bowl of rock.",
        "In 1831 Charles Darwin came here with his geology teacher. He did not spot the glacier marks then. Later he said it was obvious.",
        "A slatelet hides in the scree if you are quiet. It does not mind being watched. It minds being waved at."])],
    size=(13, 10))

# ---------------------------------------------------------------- YR WYDDFA
add("wyddfa_hafod", "Hafod Eryri", "yr_wyddfa", (50, 20, 7, 3, 3), "hall", [
    ("hafod_attendant", "hiker", "Summit Attendant", [
        "You made it. Have a sit. Everything below is very small and you are very high.",
        "The summit of Yr Wyddfa is 1,085 metres, the tallest point in Wales. The cafe is called Hafod Eryri, which means summer house of Snowdonia.",
        "The visitor centre opened in 2009 and replaced a worn-out one. The old one was built in the 1930s.",
        "It is windy up here. That is not a surprise to anyone but the sandwiches.",
        "Here, a bit of mint cake. Proper fuel for the way down."],
        ("wyddfa_hafod_mintcake", "kendal_mint_cake", "More mint cake? You will not need any more energy. You will need a lie down."))],
    size=(15, 10))


def clear_south(td, x, y):
    ch = td["rows"][y][x]
    if ch not in WALK:
        r = td["rows"][y]
        td["rows"][y] = r[:x] + "#" + r[x + 1:]


def free_tile(z, prefs, avoid):
    props = {(p["x"], p["y"]) for p in z.d["props"]}
    dx = z.w // 2
    for (x, y) in prefs:
        if (x, y) in props or (x, y) in avoid:
            continue
        if z.g[y][x] in ("|", "+") and not (y >= z.h - 3 and abs(x - dx) <= 1):
            return (x, y)
    raise SystemExit("no free tile for %s" % z.d["id"])


# Prefer central tiles that are not on props or the entrance lane.
def make_prefs(z, kind):
    dx = z.w // 2
    out = []
    for y in (3, 4, 2, 5, 6):
        for d in (0, 1, -1, 2, -2, 3, -3, 4, -4):
            x = dx + d
            if 2 <= x < z.w - 2 and y < z.h - 3:
                out.append((x, y))
    return out


# Dolbadarn's mound drops two levels to the shore: add a one-step ramp south of the door
HEIGHT_FIX = (8, 26, 3, 1, 1)

dlg = {}
for e in L:
    zid, name, town, kind = e["zid"], e["name"], e["town"], e["kind"]
    bx, by, bw, bh, off = e["b"]
    w, h = e["size"]
    tj = os.path.join(OUT, town + ".json")
    td = json.load(open(tj))
    doorx, doory = bx + off, by + bh - 1
    # new house prop (Holyhead corner cottage)
    if zid == "holyhead_home3" and not any(p.get("x") == bx and p.get("y") == by and p["type"] == "building" for p in td["props"]):
        td["props"].append({"type": "building", "style": "slate_cottage", "x": bx, "y": by, "w": bw, "h": bh, "show_label": False})
        for yy in range(by, by + bh):
            r = td["rows"][yy]
            td["rows"][yy] = r[:bx] + "B" * bw + r[bx + bw:]
    assert any(p["type"] == "building" and p["x"] == bx and p["y"] == by and p["w"] == bw and p["h"] == bh for p in td["props"]), zid
    # door tile
    r = td["rows"][doory]
    assert r[doorx] in ("B", "D"), (zid, r[doorx])
    td["rows"][doory] = r[:doorx] + "D" + r[doorx + 1:]
    clear_south(td, doorx, doory + 1)
    tx, ty = w // 2, h - 3
    td["warps"] = [wp for wp in td["warps"] if not (int(wp["x"]) == doorx and int(wp["y"]) == doory)]
    td["warps"].append({"x": doorx, "y": doory, "to": zid, "tx": tx, "ty": ty, "facing": "up"})
    if zid == "llanberis_dolbadarn":
        hx, hy, hw, hh, lv = HEIGHT_FIX
        for yy in range(hy, hy + hh):
            r = td["heights"][yy]
            td["heights"][yy] = r[:hx] + str(lv) * hw + r[hx + hw:]
    json.dump(td, open(tj, "w"), indent=1, ensure_ascii=False)
    # interior with NPCs
    z = landmark(OUT, zid, name, town, (doorx, doory + 1), kind, [], w, h)
    prefs = make_prefs(z, kind)
    used = set()
    for n in e["npcs"]:
        nid, spr, who, lines = n[:4]
        gift = n[4] if len(n) > 4 else None
        x, y = free_tile(z, prefs, used)
        used.add((x, y))
        # keep neighbours open so the player can reach the NPC
        used.update({(x + 1, y), (x - 1, y)})
        z.npc(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid)
        if gift:
            flag, item, thanks = gift
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag, "then": [say(who, thanks)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    z.save(OUT + "/" + zid + ".json")

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(L))
