"""World pass (group iwest): walk-in interiors for Galway, the Burren, Connemara and Sligo.
Run: python3 tools/zones/world_iwest.py data/zones
Writes interiors (landmark()), data/dialogue/<zid>.json, and hand-patches each town's rows (door tile) and warps."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# Each entry: zone, find (label, or (x, y) of an unlabelled building), door column offset from building x,
# zid, name, kind, w, h, npcs.  npc = (id, sprite, ox, y, who, lines[, gift]) with ox relative to the centre column,
# gift = (flag, item, line when already given).
L = []


def add(town, find, doff, zid, name, kind, w, h, npcs):
    L.append((town, find, doff, zid, name, kind, w, h, npcs))


# ------------------------------------------------------------------ GALWAY
add("galway", "The Quays Bar", 3, "galway_quays", "The Quays", "cafe", 13, 10, [
    ("quays_host", "villager_4", -2, 1, "Host", [
        "Welcome to the Quays. Sit anywhere, the chowder is hot and the music starts early.",
        "Galway was the European Capital of Culture in 2020, and every July it hosts a huge arts festival.",
        "Quay Street outside is the old heart of the town. Nowadays it is mostly buskers and people who are lost."]),
    ("quays_fiddler", "fiddler", 1, 4, "Fiddler", [
        "A trad session is not a concert. We sit round a table and anyone who knows the tune just joins in.",
        "The word for the whole fun of it is craic, said 'crack'. It means good company and a good laugh."])])
add("galway", "Latin Quarter Books", 3, "galway_latinbooks", "Latin Quarter Books", "library", 13, 10, [
    ("latinbooks_seller", "shopkeeper", 0, 3, "Bookseller", [
        "Mind the stairs and the cat. The cat is in charge.",
        "James Joyce's wife, Nora Barnacle, grew up in Galway. Her little house on Bowling Green is now a museum.",
        "Galway's Irish name is Gaillimh, after the river. The Conamara Gaeltacht next door is one of the biggest Irish-speaking areas in the country."])])
add("galway", "Druid Theatre", 3, "galway_druid", "Druid Theatre", "theatre", 15, 10, [
    ("druid_usher", "villager_5", 0, 2, "Stage Manager", [
        "Quietly, please, we are in the middle of a tech rehearsal. Which is theatre for 'everything is on fire, politely'.",
        "Druid was founded in 1975 by Garry Hynes with the actors Marie Mullen and Mick Lally.",
        "Garry Hynes was the first woman to win a Tony Award for directing, for 'The Beauty Queen of Leenane' in 1998."]),
    ("druid_actor", "student", -3, 2, "Actor", [
        "I have been saying the same line for an hour. 'The tea is on the table.' I have tried it nine ways.",
        "Do not tell the director I said the third way was best."])])
add("galway", "Crann Cafe", 3, "galway_crann", "Crann Cafe", "cafe", 13, 10, [
    ("crann_baker", "villager_2", -2, 1, "Baker", [
        "Crann is the Irish word for a tree, and for a ship's mast. We liked the sound of it.",
        "Our soda bread has no yeast. It rises on bread soda and buttermilk, because Irish wheat is soft and low in gluten.",
        "Cut a cross in the top before it goes in the oven. The old story says it lets the fairies out.",
        "Here, take a loaf for the road. Do not share it with the gulls, they will remember you."],
     ("got_crann_bread", "soda_bread", "One loaf per customer, I am afraid. The gulls have been watching.")),
    ("crann_regular", "villager_3", 0, 4, "Regular", [
        "If something is 'grand' in Galway it is fine, which can mean anything from wonderful to adequate.",
        "Watch your chips on the quay. Chipgulls round here have a very organised supply chain."])])
add("galway", "Galway Cathedral", 5, "galway_cathedral", "Galway Cathedral", "church", 15, 11, [
    ("cathedral_guide", "tour_guide", 0, 3, "Guide", [
        "Welcome to the cathedral. Take your time, there is a lot of ceiling.",
        "It is called the Cathedral of Our Lady Assumed into Heaven and St Nicholas, and it was finished in 1965.",
        "It stands on the site of the old city jail, and the floors and altars use Connemara marble.",
        "St Nicholas is a patron saint of sailors, which suits a port. Story goes that Christopher Columbus prayed in the old St Nicholas' church in 1477."])])
add("galway", "Tigh Neachtain", 3, "galway_tighn", "Tigh Neachtain", "cafe", 13, 10, [
    ("tighn_host", "villager_4", -2, 1, "Host", [
        "Tigh Neachtain is Irish for 'Naughton's house'. It is a Cross Street landmark, with a very good fire.",
        "Cross Street is in the old medieval core of Galway, a few steps from the Spanish Arch and the quays.",
        "Galway had Fourteen Tribes, merchant families: Athy, Blake, Bodkin, Browne, D'Arcy, Deane, Font, French, Joyce, Kirwan, Lynch, Martin, Morris, Skerrett."]),
    ("tighn_piper", "piper", 2, 4, "Piper", [
        "The uilleann pipes are played with a bellows under the elbow, not blown into. Uilleann means 'of the elbow'.",
        "It takes about seven years to get a decent tune out of them. The neighbours take a bit longer to forgive you."])])
add("galway", "Spanish Arch Books", 3, "galway_spanishbooks", "Spanish Arch Books", "library", 11, 9, [
    ("spanishbooks_seller", "shopkeeper", 0, 3, "Bookseller", [
        "Looking for something on the Spanish Arch? It was built in 1584 to guard the quay where the wine ships unloaded.",
        "The River Corrib is only about six kilometres long, from Lough Corrib to the bay. It makes up for it in volume.",
        "Between us, chipgulls and pierlords have claimed the harbour wall. Do not argue with a pierlord. I have lost lunches that way."])])
add("galway", "Salthill Gifts", 3, "galway_salthill", "Salthill Gifts", "workshop", 13, 10, [
    ("salthill_keeper", "villager_6", 0, 4, "Shop Owner", [
        "Claddagh rings, Aran jumpers and rock candy. Have a look, nothing bites.",
        "On a Claddagh ring the hands mean friendship, the heart means love and the crown means loyalty.",
        "It is a Galway tradition to walk the Salthill Prom and kick the wall at the far end. Nobody knows why. It still has to be done."])])

add("galway", (3, 19), 2, "galway_home_prom", "Cottage by the Prom", "cottage", 11, 9, [
    ("home_prom_gran", "villager_5", 2, 2, "Gran", [
        "Come in, come in, mind the cat. Tea?",
        "If I cannot remember what a thing is called, it is a 'yoke'. Pass me that yoke. The one for the other yoke.",
        "Moolets are the gentlest thing in any field. Mine will follow you home if you have a biscuit."])])
add("galway", (38, 30), 1, "galway_home_claddagh", "Claddagh Cottage", "home", 11, 9, [
    ("home_claddagh_fisher", "fisher", 2, 2, "Retired Fisherman", [
        "The Claddagh was a fishing village with its own elected 'king', who settled quarrels on the quay.",
        "The old thatched cottages were cleared in the 1930s. I live in what is left, with an extra-long view of the water.",
        "Pierlords guard the harbour wall like landlords. Keep your sandwich in your bag and you will be fine."])])
add("galway", (43, 30), 1, "galway_home_bad", "Hooker House", "home", 12, 9, [
    ("home_bad_kid", "villager_1", 2, 2, "Boat Mad Kid", [
        "Dia duit! That means 'God be with you'. You answer 'Dia is Muire duit', which is 'God and Mary be with you'.",
        "The Galway hooker has a black hull and red-brown sails. There is a race festival in Kinvara every August called Cruinniú na mBád.",
        "Bád is Irish for boat. Dad says I have it written all over my homework."])])
add("galway", (48, 30), 1, "galway_home_teacher", "Teacher's Home", "cottage", 11, 10, [
    ("home_teacher", "villager_6", 2, 2, "Teacher", [
        "Pardon the marking. Three hundred essays about what everyone did at the weekend.",
        "Go raibh maith agat means thank you. It sounds like 'guh rev mah ugut'. Irish spelling is a prank on the rest of us.",
        "Ternlets hover over the bay and then dive headfirst. My Year 7s do the same thing off the diving board at Blackrock."])])
add("galway", (43, 36), 1, "galway_home_arch", "House by the Arch", "home", 13, 9, [
    ("home_arch_dad", "villager_3", 2, 2, "Neighbour", [
        "We get a lot of visitors looking for the Spanish Arch. It is a bit of the old city wall, that is all, and very nicely carved.",
        "Every house round here has a cluricaun story. Mine says one lives behind the boiler and mends the family shoes at night.",
        "The shoes do not look mended. But they do go missing, so he must be doing something."])])

# ------------------------------------------------------------------ BURREN
add("burren", "Cliffs of Moher Visitor Centre", 5, "burren_visitor", "Cliffs of Moher Visitor Centre", "museum", 15, 10, [
    ("visitor_ranger", "hiker", 0, 4, "Ranger", [
        "Welcome to the Cliffs of Moher. In Irish they are Aillte an Mhothair, 'cliffs of the ruined fort'.",
        "They run for about eight kilometres, and the highest point is around 214 metres above the Atlantic.",
        "This centre is built into the hillside so it does not spoil the view. You can tell, because you did not see it coming.",
        "Puffins nest on the cliffs in summer. Plungebeaks dive from them, and are much less polite about it. Here, have a cuppa."],
     ("got_moher_tea", "cup_of_tea", "That was your cuppa. The next one is in the cafe, and it costs money.")),
    ("visitor_botanist", "student", -3, 5, "Botanist", [
        "The Burren rock is split into blocks called clints, and plants grow in the cracks between them, called grikes.",
        "Gentlets and burrenbloom love it. Arctic and Mediterranean flowers grow side by side, which is absurd and lovely."])])
add("burren", "O'Brien's Tower", 1, "burren_tower", "O'Brien's Tower", "hall", 11, 9, [
    ("tower_keeper", "villager_2", 0, 5, "Tower Keeper", [
        "Sir Cornelius O'Brien built this tower in 1835 so that visitors could admire the cliffs from a proper height.",
        "He was an MP for Clare. A local wit said it was built so the whole county could admire him, but the cliffs are better looking.",
        "On a clear day you can see the Aran Islands, the Twelve Bens in Connemara and Loop Head. A clear day is an event."])])

# ------------------------------------------------------------------ CONNEMARA
add("connemara", "Kylemore Abbey", 5, "connemara_kylemore", "Kylemore Abbey", "hall", 15, 11, [
    ("kylemore_nun", "villager_4", 0, 4, "Guide", [
        "Welcome to Kylemore. The castle was built in the 1860s for Mitchell Henry, a surgeon from Manchester who fell in love with the glen.",
        "He built it for his wife, Margaret. It was a very big present, and she is not on record complaining.",
        "Since 1920 it has been home to Benedictine nuns, who came from Ypres in Belgium after the First World War.",
        "The Victorian walled garden is about six acres. The slugs agree it is the best in the west."]),
    ("kylemore_gardener", "farmer", -4, 5, "Gardener", [
        "The walled garden keeps off the Atlantic wind. In Connemara that counts as luxury heating.",
        "Sphagnets love the damp ground out the back. They hold a great deal of water, like a sponge with opinions."])])
add("connemara", "Gothic Church", 1, "connemara_gothic", "Gothic Church", "church", 11, 9, [
    ("gothic_guide", "choir_singer", 0, 3, "Guide", [
        "This little church is a miniature cathedral. Mitchell Henry had it built by the lake, and it was finished around 1881.",
        "The columns are made from different Irish marbles, and the stone from Connemara is the green one.",
        "Listen to the quiet. That is not silence, that is the lake being polite."])])

# ------------------------------------------------------------------ SLIGO
add("sligo", "Hawk's Well Theatre", 3, "sligo_hawkswell", "Hawk's Well Theatre", "theatre", 15, 10, [
    ("hawkswell_manager", "villager_5", 0, 2, "House Manager", [
        "Welcome to the Hawk's Well. We opened in 1982 and took the name from a play by W. B. Yeats, 'At the Hawk's Well'.",
        "Yeats wrote it in 1916, with dancers and masks, and it was inspired by Japanese Noh theatre. He was ahead of the fashion, as usual.",
        "The theatre is small and the seats are close, so if you cough, the whole room is in on it."])])
add("sligo", "Sligo Abbey", 3, "sligo_abbey", "Sligo Abbey", "church", 15, 10, [
    ("abbey_guide", "tour_guide", 0, 3, "Guide", [
        "Welcome to Sligo Abbey. It was a Dominican friary, founded in 1253 by Maurice FitzGerald.",
        "It was damaged by fire in 1414 and rebuilt. The cloister, with its carved stone columns, is a rare survivor.",
        "Look out for the carving on the old tombs. Some of the faces look as if they have heard the same joke every century since."])])
add("sligo", "The Model Gallery", 3, "sligo_model", "The Model", "museum", 15, 10, [
    ("model_curator", "poet", 0, 4, "Curator", [
        "Welcome to the Model. It opened in 1862 as a model school, which is how it got the name. We dropped the desks, kept the windows.",
        "We look after the Niland Collection of Irish art, including paintings by Jack B. Yeats, the poet's younger brother.",
        "Jack painted the west in loud, thick colour. Sligo looks wetter in his paintings, and somehow cheerier."])])
add("sligo", "Strand Cafe", 3, "sligo_strandcafe", "Strand Cafe", "cafe", 13, 9, [
    ("strandcafe_owner", "villager_2", -2, 1, "Cafe Owner", [
        "Hello, hello. Scones just out. The jam is local.",
        "Sligo is Sligeach in Irish, which means 'shelly place'. Shells were piled along the shore and rivers, and the name stuck.",
        "People travel to Strandhill for the seaweed baths. Seaweed has been a thing along this coast for centuries."]),
    ("strandcafe_walker", "hillwalker", 2, 4, "Walker", [
        "I have just walked Knocknarea. The summit has a cairn the size of a small hill, and it is not even the hill's fault.",
        "Hushwings hunt over the fields at dusk. Barn owls, so quiet you only notice after they have gone."])])
add("sligo", "The Poet's Corner Books", 3, "sligo_poetsbooks", "The Poet's Corner Books", "library", 13, 10, [
    ("poetsbooks_seller", "shopkeeper", 0, 3, "Bookseller", [
        "Poetry on the left, tea on the right, and a wobbly stool in the middle. Browse away.",
        "W. B. Yeats won the Nobel Prize for Literature in 1923. He spent childhood summers in Sligo, and the county is all over his poems.",
        "He is buried at Drumcliffe, beneath Benbulben. His epitaph reads: 'Cast a cold eye on life, on death. Horseman, pass by!'",
        "His poem 'The Lake Isle of Innisfree' is about a little island on Lough Gill, just east of town."])])
add("sligo", "The Garavogue Arms", 4, "sligo_garavogue", "The Garavogue Arms", "cafe", 15, 10, [
    ("garavogue_host", "villager_4", -2, 1, "Landlady", [
        "Welcome to the Garavogue. The river outside is named An Ghairbhóg, which means 'the rough one'.",
        "It is a short river, only a few kilometres from Lough Gill to the sea, but it knows how to make an entrance.",
        "Look out for rillotters on the water. They have been rude to my swans for years."]),
    ("garavogue_singer", "sean_nos_singer", 2, 4, "Singer", [
        "Sean-nós means 'old style'. It is unaccompanied Irish singing, full of little twists and turns in the tune.",
        "You are not meant to sing along. You are meant to hold your breath and enjoy it."])])
add("sligo", "Sligo Tweed", 3, "sligo_tweed", "Sligo Tweed", "workshop", 13, 10, [
    ("tweed_weaver", "shopkeeper", 0, 4, "Weaver", [
        "Tweed is woven wool. It is thick, warm, and very good at ignoring Irish weather.",
        "The name is said to be a mistake. A clerk in London misread 'tweel', the Scots word for twill, as 'tweed', thinking of the River Tweed.",
        "It stuck, as mistakes usually do. We still call it that and the river has never complained."])])
add("sligo", "Memorial Hall", 3, "sligo_memorial", "Memorial Hall", "hall", 15, 10, [
    ("memorial_historian", "prof_garside", 0, 5, "Local Historian", [
        "Welcome to the hall. Today's talk is about Queen Medb, or Maeve, who in legend ruled Connacht.",
        "Her supposed grave is the huge cairn on top of Knocknarea, about 55 metres wide. It has never been opened.",
        "Down at Carrowmore there are over thirty stone monuments, one of the biggest megalithic cemeteries in Ireland. Older than Stonehenge, as I tell everyone."]),
    ("memorial_caller", "ceilidh_caller", -4, 5, "Céilí Caller", [
        "Céilí means a gathering, and it is also the dance. Say 'kay-lee'.",
        "If you go the wrong way in the Walls of Limerick, just smile. Everyone else is also wrong."])])
add("sligo", "Strandhill Surf Shop", 3, "sligo_surfshop", "Strandhill Surf Shop", "workshop", 13, 10, [
    ("surfshop_surfer", "surfer", 0, 4, "Surf Instructor", [
        "Strandhill has some of the best surf in Ireland, and it is also very cold. Wetsuits are not a fashion choice.",
        "Out in the bay is Coney Island, which you can walk to at low tide. Some say New York's Coney Island is named after it.",
        "Check the tide table first. The causeway disappears when the sea comes in, and the sea does not read signs."])])
add("sligo", (3, 31), 2, "sligo_home_strand", "Cottage on the Strand", "cottage", 11, 9, [
    ("home_sligo_nana", "villager_6", 2, 2, "Nana", [
        "Sit down, sit down. The kettle has already forgiven me for being late.",
        "Round here you do not complain, you 'give out'. I have given out about the weather since 1971.",
        "Brocklings come into the garden at night. Keep the bins shut and we get along very well.",
        "I baked a barmbrack. There is a ring hidden inside, and whoever finds it gets a year of luck. Take a slice."],
     ("got_sligo_brack", "barmbrack", "You have had your slice. The ring is still out there, somewhere.")),
    ])


def find_building(td, key):
    for p in td["props"]:
        if p["type"] != "building":
            continue
        if isinstance(key, str):
            if p.get("label") == key:
                return p
        elif (int(p["x"]), int(p["y"])) == tuple(key):
            return p
    raise SystemExit("no building " + str(key) + " in " + td["id"])


dlg = {}
towns = {}
for town, key, doff, zid, name, kind, w, h, npcs in L:
    tj = os.path.join(OUT, town + ".json")
    td = towns.setdefault(town, json.load(open(tj)))
    p = find_building(td, key)
    bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
    dxt, dyt = bx + doff, by + bh - 1
    row = td["rows"][dyt]
    assert row[dxt] in "BD", (zid, row[dxt])
    assert td["rows"][dyt + 1][dxt] in ":#=.,fkh", (zid, "south blocked", td["rows"][dyt + 1][dxt])
    td["rows"][dyt] = row[:dxt] + "D" + row[dxt + 1:]
    ret = (dxt, dyt + 1)
    cx = w // 2
    nl = []
    for n in npcs:
        nid, spr, ox, y, who, lines = n[:6]
        nl.append(dict(id=nid, sprite=spr, x=cx + ox, y=y, facing="down", move="still", script=nid))
        for ln in lines:
            assert len(ln) <= 200, (nid, len(ln))
            assert "—" not in ln
        if len(n) > 6:
            flag, item, again = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag, "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    z = landmark(OUT, zid, name, town, ret, kind, nl, w, h)
    # sanity: NPCs on floor, off props and off the exit column
    occupied = {(int(q["x"]), int(q["y"])) for q in z.d["props"]}
    for n in nl:
        c = z.g[n["y"]][n["x"]]
        assert c in "|+", (zid, n["id"], "tile", c)
        assert (n["x"], n["y"]) not in occupied, (zid, n["id"], "on prop")
        assert not (n["x"] == cx and n["y"] >= h - 3), (zid, n["id"], "blocks exit")
    if not any(int(wp["x"]) == dxt and int(wp["y"]) == dyt for wp in td["warps"]):
        td["warps"].append({"x": dxt, "y": dyt, "to": zid, "tx": cx, "ty": h - 3, "facing": "up"})

for town, td in towns.items():
    json.dump(td, open(os.path.join(OUT, town + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print(len(L), "interiors")
