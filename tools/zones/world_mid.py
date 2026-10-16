"""World pass (group mid): walk-in interiors for Birmingham, Nottingham, Sherwood, London, Stonehenge, Douglas.
Run: python3 tools/zones/world_mid.py data/zones
Adds a door tile (rows) + warp to each building, writes the interior zones and their dialogue.
Idempotent: safe to re-run (doors/warps are not duplicated). Edits town JSON in place, never regenerates it."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".,#=:sfw_+|D")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zone, (bx, by) of the building prop, door x, interior id, name, kind, w, h, npcs, extras)
# npc = (id, sprite, x, y, who, lines[, (gift_flag, item, repeat_line)])
E = []


def add(zone, bxy, dx, zid, name, kind, w, h, npcs, fix=(), rm=()):
    E.append((zone, bxy, dx, zid, name, kind, w, h, npcs, list(fix), list(rm)))


# ---------------------------------------------------------------- BIRMINGHAM
add("birmingham", (41, 13), 47, "birmingham_selfridges", "Selfridges", "cafe", 14, 10, [
    ("selfridges_assistant", "shopkeeper", 3, 3, "Shop Assistant", [
        "Welcome to Selfridges. Mind the discs, they are not for borrowing.",
        "This building opened in 2003 and is covered in about 15,000 shiny aluminium discs. It looks like a very expensive sequinned armadillo.",
        "Around it is the Bullring, where Birmingham has held a market since a royal charter in 1166. We just added a roof and better biscuits."]),
    ("selfridges_shopper", "villager_2", 10, 4, "Shopper", [
        "I came in for socks two hours ago. The socks are somewhere on floor three, probably living their best life.",
        "Do not follow the escalator. It is very persuasive."])])
add("birmingham", (23, 21), 26, "birmingham_anchor", "The Anchor", "cafe", 12, 9, [
    ("anchor_landlady", "mum", 3, 3, "Landlady", [
        "Come in, bab, take the warm seat. Plate of grey peas and bacon? It is a proper Black Country dish.",
        "Digbeth is full of canal history. The first Birmingham canal opened in 1769 so coal would stop costing a fortune.",
        "Folk here call a canal 'the cut'. A forward roll is a 'gambol'. Do not ask me why, nobody has ever said."])])
add("birmingham", (42, 21), 45, "birmingham_rotunda", "The Rotunda", "hall", 11, 9, [
    ("rotunda_concierge", "commuter", 3, 3, "Concierge", [
        "Welcome to the Rotunda. Yes, it is round. Yes, I have heard every joke about it.",
        "It is a 25-storey cylinder about 81 metres tall, finished in 1965. It was built as offices.",
        "It was listed in 2000 so nobody could knock it down, and it became flats in 2008. The lift view is excellent."]),
    ("rotunda_resident", "student", 8, 5, "Resident", [
        "My sofa has a view of the whole city. Also of three cranes and one very confident pigeon."])])
add("birmingham", (56, 21), 59, "birmingham_mailbox", "The Mailbox", "hall", 13, 10, [
    ("mailbox_clerk", "villager_4", 5, 4, "Post Room Clerk", [
        "Letters, parcels, the odd postcard from Skegness. This place used to sort the lot.",
        "The Mailbox was Royal Mail's big Birmingham sorting office. It was turned into shops, flats and offices around the year 2000.",
        "The very first postage stamp, the Penny Black, went on sale in 1840. Before that the person receiving the letter paid. Imagine that on your birthday."])])
add("birmingham", (34, 37), 37, "birmingham_custard", "The Custard Factory", "mill", 13, 10, [
    ("custard_guide", "villager_5", 6, 4, "Studio Guide", [
        "Smell that? No, you cannot. It stopped years ago. The ghost of custard lives here.",
        "Alfred Bird invented egg-free custard in Birmingham in 1837, because his wife Elizabeth could not eat eggs. Love, and chemistry.",
        "Bird's custard went round the world. This old factory is now studios, shops and workshops."]),
    ("custard_artist", "poet", 3, 6, "Artist", [
        "I paint with all the colours, mostly yellow. Custard-adjacent, you might say."])])
add("birmingham", (34, 44), 37, "birmingham_jewellery", "Jewellery Quarter Workshop", "workshop", 13, 10, [
    ("jewellery_maker", "villager_6", 4, 3, "Jeweller", [
        "Welcome in. Please do not breathe on the silver. It has views.",
        "The Jewellery Quarter makes a big share of Britain's jewellery. People often say about 40 per cent. Many workshops still hum.",
        "Birmingham's hallmark is an anchor, stamped at the Assay Office since 1773. A tiny anchor on your ring means it was checked here.",
        "The Chamberlain Clock outside went up in 1903. It is a lovely place to meet someone who is always late."])])
add("birmingham", (49, 46), 52, "birmingham_backtobacks", "Back-to-Backs", "cottage", 11, 9, [
    ("backtoback_volunteer", "mum", 5, 3, "Volunteer", [
        "Come in, mind your head on the beam. It was built for shorter people, and for fewer opinions.",
        "Back-to-backs were houses built in rows, joined at the back and the sides to pack workers into the city. This is the last surviving court in Birmingham.",
        "Families lived at Court 15, Hurst Street until 1966. The rooms are set in four times: the 1840s, 1870s, 1930s and 1970s.",
        "Everyone in the court shared the yard, the washhouse and the privies. It was cosy. Mostly it was a queue."])])
add("birmingham", (4, 21), 6, "birmingham_home1", "Nan Pat's House", "home", 11, 9, [
    ("brum_home1_nan", "mum", 4, 3, "Nan Pat", [
        "Come in, bab, mind the step. Kettle's on, it is always on. It is a Birmingham law.",
        "'Bab' means love, 'bostin' means brilliant, and 'tara-a-bit' means see you later. You can say it to anyone, even the bin men.",
        "Our back gate opens near the cut. In summer you can hear narrowboats and a heron complaining about the traffic.",
        "Mind the binfox on the way out. It once took a whole Sunday roast off my windowsill. Here, a flask for the road, bab."],
     ("gift_brum_home1", "flask_of_tea", "I have already given you a flask, you cheeky thing. Off you go, tara-a-bit."))])
add("birmingham", (34, 21), 37, "birmingham_home2", "The Singh Family Home", "home", 12, 9, [
    ("brum_home2_gramps", "villager_1", 4, 3, "Grandad Harjit", [
        "Sit, sit. You look like you walk a lot. Have a biscuit with your tea. Birmingham insists.",
        "Joseph Gillott made steel pen nibs by the million here in the 1800s. Half the world wrote letters with Birmingham metal.",
        "Cadbury moved to Bournville in 1879 because it was green, with room for gardens. A chocolate factory with a lawn. Very sensible.",
        "My granddaughter learned to ride a bike on the towpath. She fell in the cut once. She says she was inspecting a duck."]),
    ("brum_home2_kid", "student", 8, 5, "Priya", [
        "Round here a forward roll is a gambol. That is a real word. Gran says so, so it must be true.",
        "Watch for sootwing around old chimneys. They look black as a coal bucket and they never say sorry."])])
add("birmingham", (49, 37), 51, "birmingham_home3", "Mia's House", "cottage", 11, 9, [
    ("brum_home3_mia", "villager_5", 5, 4, "Mia", [
        "I am doing a school project on canals. Birmingham has about 35 miles of them, which is why people say more than Venice.",
        "Spaghetti Junction opened in 1972, and a newspaper reporter named it. It really does look like a plate of pasta from above.",
        "If you meet a heronarch on a lock gate, stand still. It decides you are part of the furniture. Do not take it personally."])])
add("birmingham", (56, 37), 58, "birmingham_home4", "Mr Okafor's House", "home", 11, 9, [
    ("brum_home4_driver", "villager_3", 4, 3, "Mr Okafor", [
        "Retired bus driver. Thirty years on the Number 11 Outer Circle, one of the longest city bus routes in Europe.",
        "Here we say 'mom', not 'mum'. Say it with your whole mouth. 'Mom, the bus is late.'",
        "A strutcoo on the bus stop has strong opinions about the council. Wait quietly and it will lose interest.",
        "My wife says I still brake at every corner in my sleep. She is not wrong."])])

# ---------------------------------------------------------------- NOTTINGHAM
add("nottingham", (11, 5), 18, "nottingham_castle", "Nottingham Castle", "castle", 15, 11, [
    ("ncastle_guide", "tour_guide", 7, 4, "Castle Guide", [
        "Welcome to Nottingham Castle. The Norman one is long gone. This is the later ducal mansion, built in the 1670s.",
        "It was set on fire by rioters in 1831 during the Reform Bill unrest. It was rebuilt and opened in 1878 as a museum.",
        "Under the rock are more than 800 man-made caves. One is called Mortimer's Hole, a secret tunnel used in 1330 to catch Roger Mortimer.",
        "Edward III led the raid himself, so it was quite a good party trick."]),
    ("ncastle_visitor", "student", 10, 6, "Visitor", [
        "I came for Robin Hood. They told me he is outside, in bronze. He has not moved in decades. A calm fellow."])])
add("nottingham", (6, 17), 9, "nottingham_trip", "Ye Olde Trip to Jerusalem", "cafe", 13, 10, [
    ("trip_keeper", "shopkeeper", 3, 3, "Innkeeper", [
        "Welcome in. We are carved right into the castle rock. If the wall looks like a cave, that is because it is one.",
        "The sign says 1189, the year of the Crusades. Historians say the pub is mainly 17th century. The caves underneath are far older.",
        "The caves were once used by the castle brewhouse. Today they hold cosy corners and a very polite draught.",
        "See the ship in the glass case, covered in dust? Nobody cleans it. Legend says that is wise."])])
add("nottingham", (12, 23), 16, "nottingham_bikeworks", "Raleigh Bike Works", "workshop", 13, 9, [
    ("bikeworks_mechanic", "steelworker", 5, 3, "Mechanic", [
        "Welcome to the Bike Works. Mind the oil, it has big plans for your shoes.",
        "Raleigh began in Nottingham in 1887. At its busiest it was one of the biggest bicycle makers in the world.",
        "The Raleigh Chopper came out in 1969. It had a long seat and a gear stick like a sports car, and every child wanted one."]),
    ("bikeworks_rider", "jogger", 9, 4, "Cyclist", [
        "I ride one of ours every day. Well, I push it up the hill. Nottingham has hills. Do not tell the brochure."])])
add("nottingham", (56, 15), 60, "nottingham_lacemarket", "Lace Market Museum", "museum", 14, 10, [
    ("lacemarket_curator", "villager_2", 6, 4, "Curator", [
        "Welcome to the Lace Market. These tall brick warehouses were built in the 1800s to store and sell lace.",
        "Nottingham became the world's centre of machine-made lace. John Levers adapted a bobbinet machine here in 1813, and the lace flowed.",
        "Lace for wedding dresses, curtains and royal gowns came from this one corner of the city. Hold it up to the light. It is mostly holes, carefully arranged."])])
add("nottingham", (12, 28), 16, "nottingham_laceworks", "Lace Works", "mill", 13, 10, [
    ("laceworks_minder", "steelworker", 6, 4, "Machine Minder", [
        "Mind the machine. It weighs several tonnes and has thousands of threads. It does not stop for sightseers.",
        "The patterns were guided by punched cards, borrowed from the Jacquard weaving loom. Punched cards later inspired early computers.",
        "So the next time you use a laptop, thank a lace machine. Sort of."]),
    ("laceworks_bobbin_fan", "villager_4", 9, 6, "Weaver", [
        "Bobbin turns up in empty mills at night and spins thread for fun. It is a terrible dinner guest and a fantastic tidier."])])
add("nottingham", (56, 28), 60, "nottingham_porkpie", "The Pork Pie Shop", "cafe", 11, 9, [
    ("porkpie_baker", "shopkeeper", 3, 3, "Pie Maker", [
        "Warm pie? Hot water crust, a bit of jelly, plenty of pepper. Simple, and perfect.",
        "True Melton Mowbray pork pies have protected status. That is in Leicestershire, just down the road. We respect it. We do not discuss it.",
        "Goose Fair has run in Nottingham since a charter in 1284. Older than my recipe, and much louder."])])
add("nottingham", (2, 23), 6, "nottingham_home1", "Nanna Mavis's House", "home", 12, 9, [
    ("not_home1_nanna", "mum", 4, 3, "Nanna Mavis", [
        "Ay up me duck, come in. 'Me duck' is a Nottingham hello. It is not about birds, though we have those too.",
        "If somebody is 'mardy' they are in a grump. A 'jitty' is a narrow alley between houses. A 'cob' is a bread roll. It is not a swan.",
        "Meet people at the Left Lion outside the Council House. It is a stone lion from 1926, and folk have met there ever since.",
        "My cousin sends a Bakewell tart from Derbyshire every month. I cannot eat them all. Here, you have one."],
     ("gift_not_home1", "bakewell_tart", "You have had your tart, me duck. I will not spoil you. Much."))])
add("nottingham", (66, 15), 68, "nottingham_home2", "Grandad Ken's House", "home", 11, 9, [
    ("not_home2_ken", "villager_3", 4, 3, "Grandad Ken", [
        "Sit down, sit down. Notts County is the oldest professional football league club in the world, founded in 1862. I will tell you about it.",
        "Nottingham Forest won the European Cup in 1979 and again in 1980. I was there. I still have the scarf.",
        "Mind the pincray in the river. It came from America and it is making itself at home. Please do not carry one home yourself.",
        "My grandson says the scarf is old. I say it is vintage."])])
add("nottingham", (56, 22), 59, "nottingham_home3", "Priya's Flat", "cottage", 11, 9, [
    ("not_home3_nurse", "villager_6", 4, 3, "Priya", [
        "Night shift nurse. Hootlet keeps the same hours as me, and has better opinions about visitors.",
        "John Boot opened a little herbalist's shop in Goosegate in 1849. That became Boots, one of the best-known chemists in Britain.",
        "'Gizza' means give me. 'Gizza cob' is the right way to ask for a roll. Do not say please. It spoils the effect.",
        "My son wants to be a bobbin when he grows up. I am letting him think about it."])])
add("nottingham", (66, 28), 68, "nottingham_home4", "Dev's House", "home", 11, 9, [
    ("not_home4_dev", "student", 4, 3, "Dev", [
        "I am at the university. It was funded by Jesse Boot, of Boots, who gave the land and a lake. Good start for a campus.",
        "Nottingham became a UNESCO City of Literature in 2015. Byron, D. H. Lawrence and Alan Sillitoe all have a connection here.",
        "Hold your lunch under your elbow outside. A chipgull will steal it. A cooplet will watch, then help itself to the crumbs."])])

# ---------------------------------------------------------------- SHERWOOD (route)
add("sherwood", (21, 39), 24, "sherwood_visitor", "Sherwood Forest Visitor Centre", "museum", 13, 10, [
    ("sherwood_ranger", "hiker", 4, 3, "Ranger", [
        "Welcome to the Visitor Centre. The Major Oak is a short walk away, and about a thousand years old. Maybe eight hundred. It does not give interviews.",
        "It is named after Major Hayman Rooke, who wrote about it in 1790. It is propped up with supports, and weighs about 23 tonnes.",
        "This forest holds one of the biggest collections of ancient oaks in Europe. Over 900 veteran trees. I know a few of them by name.",
        "Here, take a snare. Wicker, hand woven, entirely legal. Be gentle with whatever you catch."],
     ("gift_sherwood_vc", "wicker_snare", "You already have my snare. Do not make me weave another before lunch.")),
    ("sherwood_volunteer", "villager_4", 9, 5, "Volunteer", [
        "Barkdeer yaps at the first sign of strangers. If you hear one, you are probably being announced.",
        "Fawnlet hides in the bracken all day. Mum comes back at dusk, so do not fuss it. The barnling hunts by sound, so keep your voice down."])],
    fix=[(24, 42, "#"), (24, 43, "#"), (24, 44, "#")], rm=[(24, 43), (25, 42)])

# ---------------------------------------------------------------- STONEHENGE (route)
add("stonehenge", (43, 44), 49, "stonehenge_visitor", "Stonehenge Visitor Centre", "museum", 15, 10, [
    ("stone_guide", "tour_guide", 6, 4, "Exhibition Guide", [
        "Welcome to the exhibition. The big stones are called sarsens, about 25 tonnes each, hauled here from the Marlborough Downs, roughly 15 miles away.",
        "The smaller bluestones came from the Preseli Hills in Wales, about 150 miles away. Nobody is completely sure how they were moved.",
        "The Altar Stone is the surprise. A 2024 study found it came from north-east Scotland, over 400 miles away. Not bad for a hobby.",
        "The first stage was built about 5,000 years ago. This centre opened in 2013, so we are the new building."]),
    ("stone_volunteer", "student", 10, 4, "Volunteer", [
        "Those houses outside are copies of Neolithic homes, based on digs at Durrington Walls. They are small and cosy and a bit smoky.",
        "The sun rises over the Heel Stone at midsummer, and sets in the circle's line at midwinter. That is the bit the builders planned.",
        "Something about a Moot is happening in the field. It is not on my rota. The robes are very nice."])])

# ---------------------------------------------------------------- LONDON
add("london", (3, 6), 10, "london_westminster", "Westminster Abbey", "church", 15, 11, [
    ("abbey_verger", "choir_singer", 7, 3, "Verger", [
        "Welcome to Westminster Abbey. Voices low, boots soft, and no running on the royal tombs.",
        "Kings and queens have been crowned here since 1066. William the Conqueror was first, on Christmas Day.",
        "The Abbey is a Royal Peculiar. It answers to the monarch, not to a bishop. Quite the dress code.",
        "The old Coronation Chair is covered in carved scribbles by schoolboys and visitors from hundreds of years ago. Please do not add yours."]),
    ("abbey_visitor", "villager_2", 4, 6, "Visitor", [
        "I am looking for Poets' Corner. Geoffrey Chaucer was buried here in 1400, and the poets followed him. A very good neighbourhood."])])
add("london", (60, 5), 68, "london_tower", "Tower of London", "castle", 15, 11, [
    ("tower_warder", "tour_guide", 7, 4, "Yeoman Warder", [
        "Good day. Yeoman Warder, one of about three dozen. People call us Beefeaters. I have no comment on beef.",
        "The White Tower was begun by William the Conqueror around 1078. It has been a fortress, a palace, a prison and a very grand treasure box.",
        "There was once a royal menagerie here, with lions and even an elephant. The animals moved to London Zoo in the 1830s.",
        "And yes, the ravens. The old saying is that the kingdom falls if they leave. So we keep at least six, and very polite they are about it."]),
    ("tower_visitor", "student", 10, 6, "Visitor", [
        "The armour is smaller than I thought. Medieval people were not all giants. They were mostly just cold."])])
add("london", (33, 45), 38, "london_globe", "Shakespeare's Globe", "theatre", 15, 10, [
    ("globe_usher", "villager_5", 3, 3, "Usher", [
        "Welcome to the Globe. Mind the groundlings, they stand in the yard and have the best view and the worst knees.",
        "The first Globe opened in 1599. It burned down in 1613 when a cannon fired in a play set the thatch alight.",
        "This one opened in 1997, rebuilt near the original. It has the first thatched roof in London since the Great Fire of 1666."]),
    ("globe_actor", "poet", 7, 2, "Actor", [
        "All the world is a stage, and this is the part of the world with the good acoustics.",
        "No microphones. We shout. Some of us were born for it."])])
add("london", (47, 33), 49, "london_towerbridge", "Tower Bridge Exhibition", "museum", 11, 9, [
    ("bridge_keeper", "tour_guide", 5, 3, "Bridge Guide", [
        "Welcome to Tower Bridge. It is not London Bridge. London Bridge is the dull one upriver.",
        "It opened in 1894 after eight years of building. The two halves lift in the middle to let tall ships through.",
        "The lifting was done by steam engines until 1976, when electric motors took over. It still lifts hundreds of times a year.",
        "Look through the glass floor on the high walkway. Do not drop your phone. It will not bounce."])],
    fix=[(50, 35, "B"), (50, 36, "="), (49, 36, "#")])

# ---------------------------------------------------------------- DOUGLAS
add("douglas", (7, 6), 9, "douglas_laxey", "Laxey Wheel (not to scale)", "mill", 11, 9, [
    ("laxey_keeper", "tin_miner", 5, 3, "Wheel Keeper", [
        "Moghrey mie, that is 'good morning' in Manx. Welcome to the Laxey Wheel. Not to scale, as the sign says. The real one is much bigger.",
        "It is called Lady Isabella and was built in 1854. At 22 metres across, it is the largest working waterwheel in the world.",
        "It pumped water out of the Great Laxey Mines. Robert Casement, a Manxman, designed it. Lady Isabella was the governor's wife.",
        "Laxey is up the coast, so this is a model of a day trip. The tram will take you."])])
add("douglas", (25, 6), 29, "douglas_home1", "Mrs Quayle's House", "home", 11, 9, [
    ("dou_home1_quayle", "mum", 4, 3, "Mrs Quayle", [
        "Moghrey mie, that is good morning, and 'fastyr mie' is good afternoon. And 'traa dy liooar' means time enough. It is our whole attitude.",
        "The last native Manx speaker, Ned Maddrell, died in 1974. Now the language is taught again, and there is a Manx-language primary school.",
        "A loaghtan sheep has brown wool and often four horns. The name means something like 'mouse-brown'. Do not tell it that.",
        "My grandson counts loaghtan horns instead of sheep. He never falls asleep. He just gets very good at sums."])])
add("douglas", (34, 6), 38, "douglas_home2", "Old Tom's House", "cottage", 11, 9, [
    ("dou_home2_tom", "fisher", 5, 3, "Old Tom", [
        "Retired ferryman. The Steam Packet company has run boats here since 1830. It is the oldest continuous passenger shipping company in the world.",
        "Tynwald, our parliament, goes back to 979. It meets on Tynwald Day, 5 July, in the open air. Fine weather is optional.",
        "'Mooinjer veggey' means the little people, the fairies. Say hello at Fairy Bridge, it is only polite. Slane lhiat, that is goodbye.",
        "A pinchkin claims every stone on the beach. Do not argue. It will win. Lightly."])])
add("douglas", (35, 15), 38, "douglas_home3", "Aunty Jo's House", "home", 12, 9, [
    ("dou_home3_jo", "villager_4", 4, 3, "Aunty Jo", [
        "Come in, come in. There is a cuppa ready. Manx cats have no tail. The tale says the cat was last onto Noah's Ark and Noah shut the door.",
        "A swiftlet hardly ever lands. The sky is its sofa. I have seen exactly one on my washing line and I took a photo.",
        "My granddaughter says pipkin is a robin in a waistcoat. The red one is its Sunday best. She is generally right.",
        "Here, take a cuppa for later. It is still warm. Do not tell the Steam Packet."],
     ("gift_dou_home3", "cup_of_tea", "You have had your cuppa. Sit a minute, dear, then off to explore."))])


def set_row(td, x, y, ch):
    r = td["rows"][y]
    td["rows"][y] = r[:x] + ch + r[x + 1:]


dlg = {}
zones = {}
for zone, (bx, by), dx, zid, name, kind, w, h, npcs, fix, rm in E:
    tj = os.path.join(OUT, zone + ".json")
    td = zones.get(zone) or json.load(open(tj))
    zones[zone] = td
    bp = [p for p in td["props"] if p["type"] == "building" and p["x"] == bx and p["y"] == by]
    assert bp, (zone, bx, by)
    bp = bp[0]
    dy = by + bp["h"] - 1
    assert bp["x"] <= dx < bp["x"] + bp["w"], (zid, dx)
    for (px, py) in rm:
        td["props"] = [p for p in td["props"] if not (p["type"] != "building" and p["x"] == px and p["y"] == py)]
    for (fx, fy, ch) in fix:
        set_row(td, fx, fy, ch)
    set_row(td, dx, dy, "D")
    south = td["rows"][dy + 1][dx]
    if south not in WALK:
        set_row(td, dx, dy + 1, "#")
        print("note: made", (dx, dy + 1), "a path for", zid, "(was", south + ")")
    blockers = [p for p in td["props"] if p["type"] != "building" and p["x"] == dx and p["y"] == dy + 1]
    if blockers:
        print("WARNING prop on tile south of door", zid, blockers)
    ret = (dx, dy + 1)
    nl = []
    for n in npcs:
        nid, spr, x, y, who, lines = n[:6]
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        assert len(set(l for l in lines)) == len(lines)
        for t in lines:
            assert len(t) <= 200, (zid, len(t), t)
            assert "—" not in t and "–" not in t, t
        script = [say(who, t) for t in lines]
        if len(n) > 6:
            flag, item, again = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1},
                          {"do": "set", "flag": flag}]}]
        dlg.setdefault(zid, {})[nid] = script
    # build the interior with no NPCs first, so NPCs can be nudged off props/counters
    z = landmark(OUT, zid, name, zone, ret, kind, [], w, h)
    taken = {(p["x"], p["y"]) for p in z.d["props"]}
    spawn = tuple(z.d["spawn"])
    mid = w // 2
    placed = []
    for n in nl:
        def ok(x, y):
            return (1 <= x < w - 1 and 1 <= y < h - 1 and z.g[y][x] in "|+" and (x, y) not in taken
                    and (x, y) != spawn and not (abs(x - mid) <= 1 and y >= h - 4)
                    and not any(abs(x - px) + abs(y - py) == 0 for px, py in placed))
        x, y = n["x"], n["y"]
        if not ok(x, y):
            best = None
            for yy in range(1, h - 1):
                for xx in range(1, w - 1):
                    if ok(xx, yy):
                        dist = abs(xx - x) + abs(yy - y)
                        if best is None or dist < best[0]:
                            best = (dist, xx, yy)
            x, y = best[1], best[2]
        n["x"], n["y"] = x, y
        placed.append((x, y))
        z.npc(**n)
    z.save(OUT + "/" + zid + ".json")
    wp = {"x": dx, "y": dy, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"}
    td["warps"] = [q for q in td["warps"] if not (q["x"] == dx and q["y"] == dy) and q["to"] != zid] + [wp]

for zone, td in zones.items():
    json.dump(td, open(os.path.join(OUT, zone + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(E))
