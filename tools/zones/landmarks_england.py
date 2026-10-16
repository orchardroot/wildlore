"""Landmark interiors for the England group (newcastle, york, whitby, birmingham, sheffield, nottingham,
northumberland_coast, bath). Usage: python3 tools/zones/landmarks_england.py data/zones
Writes the interiors, their dialogue, and adds the warps on the town doors (idempotent)."""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zlib import landmark

OUT = sys.argv[1]
DLG = os.path.join(os.path.dirname(OUT.rstrip("/")), "dialogue")

# (zid, name, town, door (x, y), kind, w, h, [ (npc id, sprite, x, y, facing, who, [lines], gift) ])
# gift = (flag, item) or None. Lines are single dialogue boxes.
L = [
 ("bath_abbey", "Bath Abbey", "bath", (37, 17), "church", 13, 10, [
  ("verger", "choir_singer", 6, 2, "down", "Verger", [
   "Welcome to the Abbey. Look up. That's fan vaulting, and no, nobody has ever got a crick in the neck. Much.",
   "King Edgar was crowned here in 973, the first king of all England. Quite the opening night.",
   "Out on the west front, angels climb a stone ladder. Bishop Oliver King dreamed it, so he had it carved.",
  ], None)]),
 ("birmingham_library", "Library of Birmingham", "birmingham", (13, 10), "library", 15, 10, [
  ("librarian", "student", 7, 3, "down", "Librarian", [
   "Shh. Well, quietly. This place opened in 2013 and it's wrapped in thousands of shiny metal rings.",
   "Up top there's a Shakespeare Memorial Room, carried over from the old library, panelling and all.",
   "Birmingham reckons it's the biggest public library in the UK. We've the shelf space to back it up.",
  ], None)]),
 ("birmingham_stmartins", "St Martin's", "birmingham", (58, 16), "church", 13, 10, [
  ("churchwarden", "villager_3", 6, 2, "down", "Churchwarden", [
   "Morning. Traders have been shouting outside this door since 1166, when the Bull Ring got its market charter.",
   "The church was mostly rebuilt in Victorian times, but there's been one on this spot since the 1200s.",
   "Don't mind the noise. After eight hundred years, we've stopped hearing the pigeons and the fruit sellers.",
  ], None)]),
 ("newcastle_keep", "The Castle Keep", "newcastle", (9, 8), "castle", 13, 10, [
  ("keep_warden", "ravenmaster", 6, 4, "down", "Keep Warden", [
   "Welcome to the New Castle, which is how Newcastle got its name. Robert Curthose built the first in 1080.",
   "This stone keep came later, in the 1170s, under Henry II. It's had a good innings.",
   "Mind the spiral stairs and keep a hand on the wall. Castles were never built for comfort.",
  ], None)]),
 ("newcastle_stnicholas", "St Nicholas' Cathedral", "newcastle", (21, 8), "church", 13, 10, [
  ("cathedral_guide", "tour_guide", 6, 2, "down", "Guide", [
   "Have you spotted the lantern tower? Stone crown on top, built around 1470, and it's survived everything.",
   "It only became a cathedral in 1882. Before that it was the parish church, and nobody was fussed.",
   "Legend says the tower survived a Scottish siege in 1644 because prisoners were held up there. Clever mayor.",
  ], None)]),
 ("newcastle_sage", "Sage Gateshead", "newcastle", (65, 20), "theatre", 15, 10, [
  ("sage_steward", "harpist", 7, 2, "down", "Steward", [
   "Hello, love. Sage opened in 2004, a great glass caterpillar over the Tyne. Norman Foster drew it.",
   "The Northern Sinfonia live here. Folk, classical, brass, all under one wobbly roof.",
   "Mind the acoustics. They're so good that a whispered rude word will reach the front row. Ask me how I know.",
  ], None)]),
 ("newcastle_theatre", "Theatre Royal", "newcastle", (16, 27), "theatre", 13, 10, [
  ("front_of_house", "poet", 6, 2, "down", "Front of House", [
   "Welcome to the Theatre Royal, Grey Street. This building has been putting on shows since 1837.",
   "Grey Street was once voted the finest street in Britain. We try not to let it go to our heads. We fail.",
   "The Royal Shakespeare Company swing by every year. Bring a cushion if you're in the gods.",
  ], None)]),
 ("newcastle_baltic", "BALTIC Centre for Contemporary Art", "newcastle", (62, 34), "museum", 15, 10, [
  ("gallery_host", "student", 7, 5, "down", "Gallery Host", [
   "This was the Baltic Flour Mill, grinding away on the Tyne until the 1980s. Now it grinds out ideas instead.",
   "It opened as an art gallery in 2002, and there's no permanent collection. It's all change, all the time.",
   "If you can't tell whether it's art or a fire exit, that's half the fun. Do check before you lean on it.",
  ], None)]),
 ("bamburgh_castle", "Bamburgh Castle", "northumberland_coast", (47, 45), "castle", 13, 10, [
  ("castle_guide", "tour_guide", 6, 4, "down", "Castle Guide", [
   "Welcome to Bamburgh. It sits on a great lump of black dolerite, the Whin Sill. Very hard to knock over.",
   "It was a royal seat of the kings of Northumbria. Folk say King Ida built the first fort here in 547.",
   "Lord Armstrong, the gun and crane magnate, bought it in 1894 and spent a fortune putting it right.",
  ], None)]),
 ("nottingham_council", "Council House", "nottingham", (37, 21), "hall", 13, 10, [
  ("hall_keeper", "villager_2", 6, 2, "down", "Hall Keeper", [
   "Welcome to the Council House, opened in 1929. Mind the marble. We've had it polished since the Twenties.",
   "Out front are the two stone lions. Every Nottingham first date is 'meet you by the left lion'.",
   "The bell in the dome is Little John. Robin Hood's mate, and he has a tremendous voice.",
  ], None)]),
 ("sheffield_townhall", "Town Hall", "sheffield", (44, 18), "hall", 15, 10, [
  ("steward", "steelworker", 7, 2, "down", "Town Hall Steward", [
   "Queen Victoria opened this place in 1897. She said it was lovely. She said that about most things.",
   "Up on the tower stands Vulcan, Roman god of fire and the forge. Very fitting for Steel City.",
   "He's rather lightly dressed for a Yorkshire winter, mind. Don't tell him. He'll only get a chill.",
  ], None)]),
 ("whitby_abbey", "Whitby Abbey (ruins)", "whitby", (51, 12), "church", 13, 10, [
  ("abbey_guide", "tour_guide", 6, 2, "down", "Abbey Guide", [
   "Whitby Abbey! In 664 a big meeting here, the Synod of Whitby, decided when England would keep Easter.",
   "A cowherd named Caedmon sang the first known poem in English here, after an angel gave him the tune.",
   "And Bram Stoker stayed in Whitby in 1890. Count Dracula comes ashore down there. Lock your windows.",
  ], None)]),
 ("whitby_jet", "Jet Workshop", "whitby", (43, 31), "mill", 11, 9, [
  ("jet_carver", "shipwright", 5, 3, "down", "Jet Carver", [
   "This black stuff is jet. Fossilised monkey puzzle trees, 180 million years old, washed out of the cliffs.",
   "Queen Victoria wore it in mourning after Prince Albert died, and half the country copied her. Good for trade.",
   "Rub a bit of jet on wool and it picks up static, like amber does. A pocket magic trick, courtesy of a tree.",
  ], None)]),
 ("whitby_chippy", "Fish and Chips", "whitby", (43, 36), "cafe", 11, 9, [
  ("chippy_owner", "shopkeeper", 3, 3, "up", "Chip Shop Owner", [
   "Haddock, love. Yorkshire folk take haddock over cod and I'll not hear a word against it.",
   "Eat them on the harbour, mind. And keep one eye on the gulls. They know when you've paid.",
   "Climb the 199 steps up to the Abbey afterwards. It helps. Slightly. You'll want a sit down at the top.",
  ], None)]),
 ("york_stonegate", "Stonegate Books", "york", (56, 21), "library", 13, 10, [
  ("bookseller", "poet", 6, 3, "down", "Bookseller", [
   "Welcome to Stonegate. This was a Roman road, then the way to the Minster, then the street of the printers.",
   "See the little red devil on the corner? A printer's devil, to show where the presses were.",
   "Browse as long as you like. Somewhere in here is a book you were not expecting to want. There always is.",
  ], None)]),
 ("york_bettys", "Bettys Tea Rooms", "york", (57, 27), "cafe", 13, 10, [
  ("tea_waitress", "shopkeeper", 3, 3, "up", "Waitress", [
   "Good afternoon. Do take a seat. The pot is silver and the pinkies are optional.",
   "See the big mirror? Airmen based round Yorkshire in the war scratched their names on it with a diamond.",
   "Here, a cream tea on the house. Scone first, jam, then cream. Yes, I know. Let's not start.",
  ], ("bettys_gift", "cream_tea"))]),
 ("york_cliffords", "Clifford's Tower", "york", (52, 50), "castle", 13, 10, [
  ("tower_warden", "ravenmaster", 6, 4, "down", "Tower Warden", [
   "Clifford's Tower. Henry III had the stone one built in the 1260s, on a big mound the Normans threw up.",
   "Notice the shape: four lobes, like a clover. A quatrefoil plan. You don't see that in a keep very often.",
   "In 1684 a salute fired from the tower set the whole inside ablaze. Hence the roofless look. Wear a hat.",
  ], None)]),
]

DOORS = {}
for zid, name, town, door, kind, w, h, npcs in L:
    ret = (door[0], door[1] + 1)
    nl = []
    for nid, spr, x, y, facing, who, lines, gift in npcs:
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing=facing, move="still", script=nid))
        script = []
        for i, t in enumerate(lines):
            assert len(t) <= 112 and "—" not in t, (zid, len(t), t)
            if gift and i == len(lines) - 1:
                flag, item = gift
                script.append({"do": "if", "flag": flag,
                               "then": [{"do": "say", "who": who, "text": "You've had your cream tea. Come back for another, and I'll pretend I never said it."}],
                               "else": [{"do": "say", "who": who, "text": t},
                                        {"do": "give_item", "item": item},
                                        {"do": "set", "flag": flag}]})
            else:
                script.append({"do": "say", "who": who, "text": t})
        path = os.path.join(DLG, zid + ".json")
        d = json.load(open(path)) if os.path.exists(path) else {}
        d[nid] = script
        json.dump(d, open(path, "w"), indent=1, ensure_ascii=False)
    landmark(OUT, zid, name, town, ret, kind, nl, w=w, h=h)
    DOORS.setdefault(town, []).append((door, zid, w, h))

# warps on the town doors
for town, ds in DOORS.items():
    path = os.path.join(OUT, town + ".json")
    d = json.load(open(path))
    for (x, y), zid, w, h in ds:
        d["warps"] = [p for p in d["warps"] if not (p["x"] == x and p["y"] == y)]
        d["warps"].append({"x": x, "y": y, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})
    if town == "whitby":  # the jeweller stood in front of the Jet Workshop door: step aside
        for n in d["npcs"]:
            if n["id"] == "wby_jeweller": n["x"] = 42
    json.dump(d, open(path, "w"), indent=1, ensure_ascii=False)
