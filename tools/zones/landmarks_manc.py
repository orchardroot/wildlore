"""Walk-in interiors for Manchester, Chester and Chat Moss landmarks.
Run: python3 tools/zones/landmarks_manc.py data/zones   (writes interiors, dialogue, town warps)"""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zid, name, town, door(x,y), kind, npcs[(id, sprite, x, y, who, lines[, gift_flag])], w, h)
L = []


def add(zid, name, town, door, kind, npcs, w=13, h=10):
    L.append((zid, name, town, door, kind, npcs, w, h))


add("manchester_rylands", "John Rylands Library", "manchester", (48, 10), "library", [
    ("rylands_keeper", "prof_garside", 6, 3, "Librarian", [
        "Shh. Well, quietly. Welcome to the John Rylands Library.",
        "Enriqueta Rylands built it in memory of her husband John, a cotton magnate. It opened on New Year's Day 1900.",
        "We keep a scrap of papyrus the size of a playing card. It is a bit of St John's Gospel from about AD 125.",
        "That makes it one of the oldest pieces of the New Testament anywhere. Do not sneeze near it."]),
    ("rylands_reader", "student", 8, 3, "Student", [
        "I come for the reading room. It looks like a cathedral that decided to study.",
        "Nobody knows where my pen went. Probably the Gothic bits ate it."])])
add("manchester_townhall", "Town Hall", "manchester", (38, 11), "hall", [
    ("townhall_clerk", "commuter", 6, 5, "Clerk", [
        "Welcome to Manchester Town Hall. Mind the Gothic, it is everywhere.",
        "Alfred Waterhouse designed it and it opened in 1877. He later did the Natural History Museum in London.",
        "The clock tower is about 85 metres tall, and the biggest bell is called Great Abel.",
        "It is named after Abel Heywood, a former mayor. Mayors do like their names on things."])])
add("manchester_murrays", "Murrays' Mill", "manchester", (7, 11), "mill", [
    ("murrays_guide", "steelworker", 6, 4, "Mill Guide", [
        "Murrays' Mill, Ancoats. Brick the colour of a wet Tuesday.",
        "Built in the 1790s and 1800s, these were among the first steam-powered cotton mills in the world.",
        "Ancoats is often called the world's first industrial suburb. Not bad for a muddy corner of Manchester."])])
add("manchester_royalmills", "Royal Mills", "manchester", (17, 11), "mill", [
    ("royal_worker", "villager_3", 6, 4, "Mill Worker", [
        "Royal Mills. Cotton went in one end, and wages went out the other, mostly to the pub.",
        "Manchester was nicknamed Cottonopolis, because so many mills crowded in around Ancoats.",
        "Today there are flats upstairs. Same big windows, far fewer looms."])])
add("manchester_dukesmill", "Dukes Mill", "manchester", (7, 56), "mill", [
    ("dukes_boater", "canal_boater", 6, 4, "Boater", [
        "Dukes Mill, Castlefield. You can smell the canal from here, bless it.",
        "The Duke of Bridgewater's canal reached Manchester in 1765 from his coal mines at Worsley.",
        "It was one of the first big canals in Britain not to follow a river. It went straight there, like a Mancunian."])])
add("manchester_knottmill", "Knott Mill", "manchester", (34, 56), "mill", [
    ("knott_historian", "poet", 6, 4, "Local Historian", [
        "Knott Mill. Even the railway station nearby borrowed the name.",
        "Castlefield was where the Romans built a fort called Mamucium around AD 79.",
        "Manchester's very name comes from it. The city is an old Roman outpost with a good rain gauge."])])

add("chester_cathedral", "Chester Cathedral", "chester", (36, 11), "church", [
    ("cathedral_verger", "choir_singer", 6, 3, "Verger", [
        "Welcome to the cathedral. Do bring your indoor voice.",
        "It began as a Benedictine abbey in 1093, dedicated to St Werburgh. Henry VIII made it a cathedral in 1541.",
        "The monks' carved choir stalls are 700 years old. Look closely for the mischievous little faces."])])
add("chester_deva", "Roman Deva Museum", "chester", (16, 17), "museum", [
    ("deva_curator", "tour_guide", 5, 4, "Curator", [
        "Salve! Chester was the Roman fortress of Deva Victrix, founded around AD 79.",
        "Just outside the walls is the biggest Roman amphitheatre in Britain. It held about 7,000 people.",
        "That is roughly everyone who has ever queued for a Chester pub on a Saturday."])])
add("chester_bookshop", "The Old Bookshop", "chester", (21, 17), "library", [
    ("bookshop_owner", "shopkeeper", 6, 3, "Bookseller", [
        "Browse away. The cat on the history shelf is not for sale.",
        "Chester's Rows are covered galleries with shops on two levels. Nobody is quite sure why they were built that way.",
        "They go back to the Middle Ages, and nowhere else in Britain has a set quite like them."])])
add("chester_rows", "The Rows", "chester", (35, 17), "cafe", [
    ("rows_waitress", "villager_2", 4, 3, "Waitress", [
        "Table for one? Sit anywhere. Mind your head on the beams.",
        "Rows have a street, then a walkway above it, then more shops behind. Chester likes its shopping in layers.",
        "The black and white timber is mostly Victorian revival. Chester was very fond of looking medieval."])])
add("chester_clockmaker", "The Clockmaker's", "chester", (40, 17), "hall", [
    ("clockmaker", "villager_5", 6, 5, "Clockmaker", [
        "Tick, tick. Do not mind the noise, you will stop hearing it in about a decade.",
        "The Eastgate Clock was built for Queen Victoria's Diamond Jubilee and finished in 1899.",
        "Folk say it is the most photographed clock in Britain after Big Ben. I say it is the more handsome."])])
add("chester_walls_tea", "Walls Tea Room", "chester", (45, 17), "cafe", [
    ("walls_tea_lady", "mum", 4, 3, "Tea Lady", [
        "Come in, come in. You look like you have walked the Walls.",
        "You can walk the whole circuit. It is nearly two miles, and the most complete city walls in Britain.",
        "Here, a flask for the road. Fresh brewed. Do not tell the Romans I used a teabag."],
        "chester_walls_tea_gift")])
add("chatmoss_hermit", "Peat Hermit's Hut", "chat_moss", (63, 7), "mill", [
    ("peat_hermit", "druid", 5, 4, "Peat Hermit", [
        "Mind the damp. Everything here is damp, including my opinions.",
        "Chat Moss is a great bog. When the railway to Manchester was built, folk said the track would simply sink.",
        "George Stephenson floated it across on bundles of heather and brushwood. The line opened in 1830.",
        "Trains still go over it today. Nobody tell the bog."])], w=11, h=9)

# open a lane of ground south of the Dukes Mill / Knott Mill doors (they faced solid trees)
TOWN_FIX = {"manchester": [(x, 57) for x in list(range(3, 14)) + list(range(29, 40))]}

dlg = {}
for zid, name, town, door, kind, npcs, w, h in L:
    tj = os.path.join(OUT, town + ".json")
    td = json.load(open(tj))
    ret = (door[0], door[1] + 1)
    nl = []
    for n in npcs:
        nid, spr, x, y, who, lines = n[:6]
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        script = [say(who, t) for t in lines]
        if len(n) > 6:
            flag = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, "Another flask? You will float away. Off you go.")],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": "flask_of_tea", "n": 1},
                          {"do": "set", "flag": flag}]}]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, town, ret, kind, nl, w, h)
    if not any(p["x"] == door[0] and p["y"] == door[1] for p in td["warps"]):
        wp = {"x": door[0], "y": door[1], "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"}
        if town == "chat_moss":
            wp["gate"] = "hedge_lay"  # the hermit's hummock is behind a bramble
        td["warps"].append(wp)
    for (fx, fy) in TOWN_FIX.get(town, []):
        r = td["rows"][fy]
        if r[fx] == "T":
            td["rows"][fy] = r[:fx] + "." + r[fx + 1:]
    json.dump(td, open(tj, "w"), indent=1, ensure_ascii=False)

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
