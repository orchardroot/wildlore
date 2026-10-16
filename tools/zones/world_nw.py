"""World pass (nw group): walk-in interiors for Macclesfield, Buxton, Manchester, Liverpool, Chester,
Cat and Fiddle, Goyt Valley, Chat Moss and Wirral Way.
Run: python3 tools/zones/world_nw.py data/zones   (writes interiors, dialogue, patches town doors/warps; re-runnable)"""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


L = []   # (zid, name, town, door, kind, npcs, w, h)


def add(zid, name, town, door, kind, npcs, w=13, h=10):
    L.append((zid, name, town, door, kind, npcs, w, h))

# npc = (sprite, who, [lines], gift) ; gift = (item, line_said_when_already_given); the last line is said when giving

# ---------------------------------------------------------------- MACCLESFIELD
add("macc_townhall", "Macclesfield Town Hall", "macclesfield", (40, 26), "hall", [
    ("commuter", "Town Clerk", [
        "Welcome to Macclesfield Town Hall. Mind the columns, they are very proud of themselves.",
        "The building dates from the 1820s, with a classical front fit for a much bigger town. Macclesfield was never short of confidence.",
        "Silk made this town rich, and its market goes back to the 1200s. The Market Place outside has seen centuries of haggling."]),
    ("villager_4", "Councillor", [
        "I chair the committee on pigeon management. Strictly speaking the pigeons chair us.",
        "Come on a Treacle Market Sunday. It is the whole town in one street, with cake."])])
add("macc_silkmuseum", "Silk Museum", "macclesfield", (15, 10), "museum", [
    ("tour_guide", "Curator", [
        "Welcome to the Silk Museum. Macclesfield made silk for centuries, and this is the town's memory of it.",
        "Charles Roe opened the first big silk mill here in 1743. By Victorian times Macclesfield was one of the great silk towns of England.",
        "One cocoon is a single thread, up to about a kilometre long. A silkworm is a very small, very patient knitter.",
        "Silk was 'thrown' here. That does not mean tossed about. Throwing is twisting the raw threads together into yarn."]),
    ("poet", "Visitor", [
        "I came for the silk ties and stayed for the Jacquard cards. Holes in card, pattern in cloth.",
        "Computers borrowed that trick later. Macclesfield got there first, with more style."])], 13, 10)
add("macc_paradise", "Paradise Mill", "macclesfield", (35, 34), "mill", [
    ("villager_3", "Weaver", [
        "Paradise Mill. Brick, windows and clatter. These handlooms were working right up until 1981.",
        "The Jacquard loom reads its pattern from a chain of punched cards. A hole means a thread lifts. It is a computer made of wood.",
        "A weaver on a very fine pattern might finish only a few inches in a day. Silk rewards patience, and punishes sneezing."])], 15, 10)
add("macc_stmichael", "St Michael's Church", "macclesfield", (44, 7), "church", [
    ("choir_singer", "Verger", [
        "Welcome to St Michael's. A church has stood on this hill since 1278, founded by Queen Eleanor of Castile.",
        "Inside is the Savage Chapel, with old family tombs and carved stone. The Savages were powerful people round here for centuries.",
        "On a clear day the view from the churchyard runs out over the roofs to the hills of the Peak District."])], 13, 11)
add("macc_h1", "Bailey's House", "macclesfield", (35, 9), "cottage", [
    ("villager_2", "Mrs Bailey", [
        "Come in, love. Mind the cat. She thinks she owns the settee, the telly and me.",
        "Word of the day is 'nesh'. It means you feel the cold more than anyone else. My husband is shockingly nesh.",
        "He wears a jumper in July. Mardy as well, which means sulky, but I let him have that one."])], 11, 9)
add("macc_h2", "Hulme's House", "macclesfield", (30, 25), "home", [
    ("villager_1", "Mr Hulme", [
        "Did you know Hovis started in Macclesfield? A miller called Richard Smith patented the wheatgerm flour in 1886.",
        "The name came a few years later, from the Latin for 'strength of man'. I say it also means strength of toast."]),
    ("student", "Daughter", [
        "Dad says the 108 Steps are good for the legs. I say they are good for complaining."])], 12, 9)
add("macc_h3", "Gran's House", "macclesfield", (7, 25), "cottage", [
    ("mum", "Gran", [
        "Sit down, I will put the kettle on. A ginnel is what we call the little alley behind the houses.",
        "Our ginnel is where I learned to ride a bike. And to fall off it, in front of the whole street.",
        "My mum worked in a silk mill as a girl. She said you kept your hands soft so the silk would not snag."])], 11, 9)
add("macc_h4", "Walker's House", "macclesfield", (13, 25), "home", [
    ("hillwalker", "Walker", [
        "I climb Shutlingsloe most weekends. They call it the Cheshire Matterhorn, because of its pointy top.",
        "It is only about 506 metres, so please do not pack ropes. A flask and a waterproof will do."])], 12, 9)
add("macc_h5", "Boater's House", "macclesfield", (19, 25), "cottage", [
    ("canal_boater", "Boater", [
        "The Macclesfield Canal skirts the edge of town. It opened in 1831 and the great engineer Thomas Telford had a hand in it.",
        "It has 'roving bridges', where the towpath swaps sides so the horse never has to be unhitched. Very tidy thinking."])], 11, 9)

# ---------------------------------------------------------------- BUXTON
add("buxton_crescent", "The Crescent", "buxton", (20, 9), "hall", [
    ("tour_guide", "Guide", [
        "Welcome to the Crescent. John Carr built it in the 1780s for the 5th Duke of Devonshire.",
        "The curve was inspired by the Royal Crescent in Bath. The Duke wanted Buxton to be the Bath of the north, and it rather worked.",
        "Visitors came to take the waters and to be seen taking them. Today they come for the scones, which is a modern improvement."]),
    ("villager_6", "Guest", [
        "They say Mary Queen of Scots came to Buxton for the waters while she was in the care of the Earl of Shrewsbury.",
        "Even a queen needed a spa weekend."])], 15, 10)
add("buxton_well", "St Ann's Well", "buxton", (30, 9), "cafe", [
    ("villager_3", "Well Keeper", [
        "St Ann's Well. The water comes out at about 28 degrees all year round. Mild as a Tuesday.",
        "The Romans knew this place as Aquae Arnemetiae, the waters of the goddess Arnemetia. Not an easy name for an address.",
        "The rain falls on the hills, sinks deep, warms in the rock and rises here years later. Slow travel, but worth the wait.",
        "Here, a bottle to take with you. It is good for the road, and for arguing with your sister."],
     ("buxton_water", "Another bottle? You will slosh. Off you go, and mind the hills."))], 11, 9)
add("buxton_opera", "Buxton Opera House", "buxton", (46, 29), "theatre", [
    ("harpist", "Front of House", [
        "Welcome to the Opera House. Frank Matcham designed it, and it opened in 1903.",
        "Matcham was the great theatre architect of his day. He also did the London Coliseum, which is bigger. We have the better chandelier.",
        "Every summer Buxton holds an international music festival, and a Gilbert and Sullivan festival too. The whole town hums."]),
    ("student", "Stagehand", [
        "Rule one: never whistle on stage. Rule two: if you must, go outside and turn round three times."])], 15, 11)
add("buxton_h1", "Wragg's House", "buxton", (6, 9), "cottage", [
    ("mum", "Mrs Wragg", [
        "Ey up, duck! That is how we say hello round here. 'Duck' means dear, and it is a compliment.",
        "Folk argue about Bakewell tart. Over in Bakewell they will tell you the real thing is a pudding.",
        "Have a slice of the tart. I will not tell Bakewell."],
     ("bakewell_tart", "Another slice? Your eyes are bigger than the tin. Off you go."))], 11, 9)
add("buxton_h2", "Grandad's House", "buxton", (6, 15), "home", [
    ("villager_4", "Grandad", [
        "Buxton claims to be the highest market town in England, about a thousand feet up. We get snow when London gets drizzle.",
        "Poole's Cavern is just up the hill. Legend says an outlaw called Poole hid in it. Sensible man, it is dry in there."])], 12, 9)
add("buxton_h3", "Walker's House", "buxton", (44, 6), "cottage", [
    ("hillwalker", "Walker", [
        "The River Wye rises on the moors just above Buxton. I like to say I once walked from the source to the sea.",
        "Poole's Cavern has stalagmites called the Poached Eggs. Chilly, damp and brilliant."])], 11, 9)
add("buxton_h4", "Gardens Cottage", "buxton", (36, 6), "home", [
    ("student", "Kid", [
        "My mum runs a stall in the Pavilion Gardens. They were laid out by Edward Milner, who also did Crystal Palace Park.",
        "Mum says the ducks run the place. I say the ducks run Mum."]),
    ("villager_5", "Dad", [
        "A 'twitchel' is our word for a narrow alley. Buxton is full of them, and every one has a shortcut and a cat."])], 12, 9)
add("buxton_h5", "Cottage by the Slopes", "buxton", (6, 30), "cottage", [
    ("villager_2", "Mrs Oldfield", [
        "Do not mither me, I am nearly done. 'Mither' means to bother, and I use it daily.",
        "We fill the kettle with Buxton water and feel very posh. Tastes of nothing, which is the point."])], 11, 9)
add("buxton_h6", "Corner House", "buxton", (49, 33), "home", [
    ("jogger", "Runner", [
        "I jog the Slopes every morning, the hillside park above the Crescent. The grass is steep, so the legs get a lecture.",
        "Nice view, though. You can see the whole town spread out like a toy set."])], 12, 9)

# ---------------------------------------------------------------- MANCHESTER
add("manchester_h1", "Chadwick's House", "manchester", (8, 6), "home", [
    ("villager_1", "Mrs Chadwick", [
        "Our kid! Come in. 'Our kid' means a brother, or just a pal. Do not ask which.",
        "The worker bee is on everything round here. It stands for all the graft Manchester put in during the cotton days."])], 12, 9)
add("manchester_h2", "Dad's House", "manchester", (18, 6), "cottage", [
    ("commuter", "Dad", [
        "'Mither' is a Manc word. It means to bother or pester. 'Stop mithering the cat.'",
        "The first modern stored-program computer ran in Manchester in 1948. They nicknamed it Baby. Mine is just called the telly."])], 11, 9)
add("manchester_h3", "Student Digs", "manchester", (49, 5), "home", [
    ("student", "Student", [
        "I am studying at the university. Ernest Rutherford first split the atom here, around 1917.",
        "He turned nitrogen into oxygen, which sounds like cheating. I could not even change my timetable."])], 12, 9)
add("manchester_h4", "Nana's House", "manchester", (56, 10), "cottage", [
    ("villager_4", "Nana", [
        "Eccles cakes come from Eccles, just down the road. Currants in flaky pastry, buttery and dangerous.",
        "The Ship Canal opened in 1894 and turned Manchester into a port, 36 miles from the sea. Cheek of it.",
        "Take an Eccles cake for the road. Go on, you look peckish."],
     ("eccles_cake", "You have had one, our kid. Save some for the rest of Manchester."))], 11, 9)
add("manchester_h5", "Nelson Street House", "manchester", (8, 20), "home", [
    ("villager_6", "Resident", [
        "Emmeline Pankhurst founded the suffragette movement here in 1903, in a front room on Nelson Street.",
        "A front room changed the vote. And I cannot even get anyone to turn the telly down."])], 13, 9)
add("manchester_h6", "Joe's House", "manchester", (18, 20), "cottage", [
    ("steelworker", "Joe", [
        "I am buzzing, me. 'Buzzing' means delighted. 'Chuffed' is the same, but older.",
        "They say the damp Manchester air stopped cotton thread snapping, so the rain was good for business. Brilliant. Thanks, weather."])], 11, 9)
add("manchester_h7", "Canalside House", "manchester", (18, 55), "home", [
    ("canal_boater", "Boater", [
        "Castlefield is where the Bridgewater Canal arrived. I live right by the water and nowt beats it.",
        "'Nowt' is nothing and 'owt' is anything. So 'owt for tea?' means 'is there anything for tea?', and the answer is usually nowt."])], 12, 9)
add("manchester_h8", "Corner House", "manchester", (44, 55), "cottage", [
    ("mum", "Mum", [
        "Tea is at six. Our daughter is learning the cornet and the neighbours have started a polite petition.",
        "Rolls met Royce here in 1904, at the Midland Hotel. Two men, one lunch, and the world got posh cars."])], 11, 9)

# ---------------------------------------------------------------- LIVERPOOL
add("liverpool_h1", "Scouse House", "liverpool", (42, 27), "cottage", [
    ("villager_2", "Mrs Doran", [
        "Alright, la! Come in, kettle's on. 'Boss' means brilliant. 'Made up' means delighted. 'Scran' means food.",
        "Scouse the stew gave its name to the people and the accent. Same word, bigger flavour.",
        "Take a bowl for the road. Lamb, spuds and carrots. Do not tell my mam it is not hers."],
     ("scouse", "You have had your bowl, la. Ta-ra now."))], 11, 9)
add("liverpool_h2", "Sailor's House", "liverpool", (8, 46), "home", [
    ("sailor", "Retired Sailor", [
        "Liverpool had docks the length of the river. Albert Dock was one of the first warehouses built with no wood at all. Iron, brick, stone, no fire.",
        "The two Liver Birds on the Liver Building face opposite ways. One watches the sea, one watches the city."])], 12, 9)
add("liverpool_h3", "Overhead Railway Flat", "liverpool", (18, 46), "home", [
    ("student", "Student", [
        "I am doing a project on the Overhead Railway. It opened in 1893, the first electric elevated railway in the world.",
        "Locals called it the Dockers' Umbrella, because it ran above the docks and kept off the rain."])], 12, 9)
add("liverpool_h4", "Hope Street Terrace", "liverpool", (8, 52), "cottage", [
    ("choir_singer", "Chorister", [
        "Four lads from Liverpool changed music, and we have never been allowed to forget it. Mind, we have never wanted to.",
        "Liverpool has one of the oldest Chinese communities in Europe. The Chinatown arch is the biggest outside China, they say."])], 11, 9)
add("liverpool_h5", "Nan's House", "liverpool", (18, 52), "home", [
    ("mum", "Nan", [
        "'Ta-ra' means goodbye. 'Sound' means all right. So 'Ta-ra, la, sound' is a full conversation.",
        "Hope Street has a cathedral at each end. The Anglican one is the biggest in Britain. Our Jack is saving up for the ferry across the Mersey."])], 12, 9)

# ---------------------------------------------------------------- CHESTER
add("chester_h1", "Dodd's House", "chester", (16, 24), "cottage", [
    ("villager_3", "Mrs Dodd", [
        "'Cestrian' is what we call someone from Chester. Say it with a straight face.",
        "Cheshire cheese is in the Domesday Book of 1086, so it is Britain's oldest named cheese. My cheese on toast has no such history."])], 11, 9)
add("chester_h2", "Dutton's House", "chester", (22, 24), "home", [
    ("farmer", "Mr Dutton", [
        "Chester Zoo opened in 1931 because George Mottershead wanted a zoo without bars. He used ditches and moats instead.",
        "Cheeky and clever. I use the same trick to keep my dog off the sofa. It does not work."])], 12, 9)
add("chester_h3", "Roodee House", "chester", (35, 24), "cottage", [
    ("student", "Student", [
        "Racing has gone on at the Roodee since 1539. It is the oldest racecourse still in use in Britain.",
        "'Rood' is cross, 'ee' is island. It was once a bit of land by the river Dee with a cross on it."])], 11, 9)
add("chester_h4", "Walker's House", "chester", (40, 24), "home", [
    ("hiker", "Walker", [
        "Lewis Carroll grew up a few miles away at Daresbury. Some say the Cheshire Cat grinned its way out of Cheshire.",
        "Nobody can prove it. Have a brew, you look as if you have walked the walls."],
     ("cup_of_tea", "Another brew? You will turn into a teapot. Off you go."))], 12, 9)
add("chester_h5", "Border House", "chester", (45, 24), "cottage", [
    ("fisher", "Mr Hughes", [
        "Wales is ten minutes away. Say 'Croeso', which means welcome, to anyone you meet who has just crossed.",
        "The Romans used the river Dee as a port for Deva. Now it is mostly swans, and swans do not pay tolls."])], 11, 9)

# ---------------------------------------------------------------- ROUTES
add("cat_and_fiddle_inn", "Cat and Fiddle Inn", "cat_and_fiddle", (34, 12), "cafe", [
    ("villager_6", "Landlady", [
        "Welcome to the Cat and Fiddle. The second highest inn in England, at about 1,690 feet. The wind is included.",
        "It was built around 1820 beside the old road between Macclesfield and Buxton. Folk have argued about the name ever since.",
        "Some say it comes from a French phrase, Caton Fidele. Others from the nursery rhyme. I say the cat is sensible and the fiddler is loud."]),
    ("hiker", "Walker", [
        "I came up for the wind and the view. Both are generous. Keep an ear out for hootlets at dusk."])], 13, 10)
add("goyt_errwood", "Errwood Hall, as it was", "goyt_valley", (16, 29), "hall", [
    ("hiker", "Ranger", [
        "Step in and picture it. Errwood Hall was built in the 1830s by Samuel Grimshawe. Today only the shell is left.",
        "The valley was bought to protect the water for Stockport, and the hall was pulled down in the 1930s.",
        "The family planted rhododendrons all around. They still turn the hillside pink and purple in early summer.",
        "Keep an eye out for brocklings at dusk. They are the real owners of this valley."])], 13, 10)
add("goyt_shrine", "Spanish Shrine", "goyt_valley", (11, 26), "church", [
    ("villager_2", "Keeper", [
        "This little shrine was built by the Grimshawe family, who had Spanish servants and a Spanish governess called Dolores.",
        "They built it in the late 1800s, so their household had a place to pray. Walkers still leave flowers here sometimes."])], 11, 9)
add("chatmoss_signalbox", "Signal Box", "chat_moss", (38, 23), "workshop", [
    ("rail_guard", "Signaller", [
        "Mind the levers. Each one moves a signal or a set of points, by wire and rod, out across the moss.",
        "Signal boxes talk by bell code. One beat on the bell means 'attention, please'. It is a very polite language.",
        "Out here the ground is so soggy the line is still, more or less, floating. Sphagnets love it, and croakles hop about when it drizzles."])], 11, 9)
add("wirral_hillfarm", "Hill Farm", "wirral_way", (46, 10), "cottage", [
    ("farmer", "Farmer", [
        "Welcome to Hill Farm. Mind the boots. 'Wirral' is said to mean the corner of the bog-myrtle, so we have been damp a thousand years.",
        "Vikings settled on the Wirral around 902, led by a man called Ingimund. Thingwall, just up the road, was where they held their assembly."]),
    ("mum", "Farmer's Wife", [
        "He says he will tidy the barn. He has said that since I married him."])], 13, 10)
add("wirral_stbarts", "St Bartholomew's Church", "wirral_way", (44, 38), "church", [
    ("choir_singer", "Verger", [
        "Welcome to St Bartholomew's, a Victorian church in Thurstaston. The name means 'Thorsteinn's farm', after a Viking.",
        "Thor's Stone is a big lump of red sandstone on the common nearby. Whether Vikings worshipped there is a story people like to tell."])], 13, 10)
add("wirral_boathouse", "The Boathouse, Parkgate", "wirral_way", (45, 52), "cafe", [
    ("fisher", "Boatman", [
        "Parkgate was a busy port once, with packet boats to Ireland. Then the Dee silted up and the water went away.",
        "Now the marsh is where the birds are. The story goes Handel waited in Chester for a fair wind, then sailed for Dublin from round here in 1741."]),
    ("birdwatcher", "Birdwatcher", [
        "On a high autumn tide the marsh floods and the wading birds pile up in thousands. Hen harriers and short-eared owls hunt here in winter."])], 13, 10)
add("wirral_h1", "Slate Cottage", "wirral_way", (52, 52), "cottage", [
    ("villager_1", "Mrs Roberts", [
        "The Wirral Way was a railway once. Hooton to West Kirby, closed in the 1950s and 60s. Now it is a path.",
        "In 1973 it opened as Wirral Country Park, the first country park in Britain. Mind the pinchkin in the rock pools. They pinch."])], 11, 9)
add("wirral_h2", "Seaview House", "wirral_way", (44, 58), "home", [
    ("mum", "Mum", [
        "Chipgulls steal chips off the front. Never eat with your back to the sea. Tide table is on the fridge.",
        "'Sound' means all right round here. I say it about the weather, the neighbours and my own cooking."])], 12, 9)
add("wirral_h3", "Estuary House", "wirral_way", (51, 58), "cottage", [
    ("angler", "Angler", [
        "The tide in the Dee comes in a lot faster than you would think. Never go onto the marsh without checking the times.",
        "A friendly pupplash sometimes follows my line, hoping for dinner. I tell it the same thing every day: no."])], 11, 9)

# ---------------------------------------------------------------- TOWN PATCHES
# new buildings: (town, x, y, w, h, style)
NEW_BUILDINGS = [("buxton", 4, 28, 5, 3, "stone"), ("buxton", 47, 31, 5, 3, "gritstone")]
# tile edits: (town, x, y, ch)
TILES = [("macclesfield", x, 35, "#") for x in range(25, 36)]
# a clearing in the tree line south of Paradise Mill so its door is not hidden behind trees
TILES += [("macclesfield", x, y, ".") for y in (36, 37) for x in range(31, 40)]
# relabels: (town, x, y, label)
LABELS = [("macclesfield", 13, 7, "Silk Museum")]


def spots(z, w, h):
    dx = w // 2
    blocked = {(p["x"], p["y"]) for p in z.d["props"]}
    for y in range(h):
        for x in range(w):
            if z.g[y][x] in "xCD~": blocked.add((x, y))
    cand = []
    for y in range(2, h - 3):
        for x in range(2, w - 2):
            if (x, y) in blocked or x == dx: continue
            free = [(x + a, y + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)) if (x + a, y + b) not in blocked
                    and 1 <= x + a < w - 1 and 1 <= y + b < h - 1]
            if len(free) < 2: continue
            cand.append((abs(x - dx) * 1.0 + abs(y - 3.5) * 1.5, x, y))
    cand.sort()
    return [(x, y) for _, x, y in cand]


towns = {}


def town(t):
    if t not in towns:
        towns[t] = json.load(open(os.path.join(OUT, t + ".json")))
    return towns[t]


def setrow(d, x, y, ch):
    r = d["rows"][y]
    d["rows"][y] = r[:x] + ch + r[x + 1:]


for (t, x, y, w, h, style) in NEW_BUILDINGS:
    d = town(t)
    if not any(p["type"] == "building" and p["x"] == x and p["y"] == y for p in d["props"]):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                assert d["rows"][yy][xx] in ".,", (t, xx, yy, d["rows"][yy][xx])
                setrow(d, xx, yy, "B")
        d["props"].append({"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h})
for (t, x, y, ch) in TILES:
    setrow(town(t), x, y, ch)
for (t, x, y, lab) in LABELS:
    for p in town(t)["props"]:
        if p["type"] == "building" and p["x"] == x and p["y"] == y:
            p["label"] = lab

dlg = {}
for zid, name, t, door, kind, npcs, w, h in L:
    d = town(t)
    ret = (door[0], door[1] + 1)
    z0 = landmark(OUT, zid, name, t, ret, kind, [], w, h)
    sp = spots(z0, w, h)
    chosen = []
    nl = []
    for i, n in enumerate(npcs):
        spr, who, lines = n[:3]
        gift = n[3] if len(n) > 3 else None
        pick = next(s for s in sp if all(abs(s[0] - c[0]) + abs(s[1] - c[1]) >= 3 for c in chosen))
        chosen.append(pick)
        nid = "%s_%d" % (zid, i)
        nl.append(dict(id=nid, sprite=spr, x=pick[0], y=pick[1], facing="down", move="still", script=nid))
        if gift:
            item, again = gift
            flag = zid + "_gift"
            script = [say(who, s) for s in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, s) for s in lines]
        dlg.setdefault(zid, {})[nid] = script
        for s in lines:
            assert len(s) <= 200 and "—" not in s and "–" not in s, s
    landmark(OUT, zid, name, t, ret, kind, nl, w, h)
    x, y = door
    assert d["rows"][y][x] in "BD", (zid, d["rows"][y][x])
    setrow(d, x, y, "D")
    if not any(p["x"] == x and p["y"] == y for p in d["warps"]):
        d["warps"].append({"x": x, "y": y, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})

for t, d in towns.items():
    json.dump(d, open(os.path.join(OUT, t + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(L))
