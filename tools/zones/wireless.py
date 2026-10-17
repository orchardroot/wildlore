"""Adds the Shipping Forecast radios (signs of kind "radio" in home interiors) and the round heritage plaques
(signs of kind "plaque" on a building wall beside its door) to existing zone JSON. Edits in place, never
regenerates a town, and is safe to run twice (a zone that already has one of each is left alone).

    python3 tools/zones/wireless.py          # from the repo root

Both are ordinary entries in the zone's "signs" list, so the engine treats them as blocked, interactable tiles:
  radio  {"x","y","text","kind":"radio","areas":[sea areas, nearest first]}   (world/forecast.gd reads it aloud)
  plaque {"x","y","text","kind":"plaque","dx":+-0.475}                          (a disc on the south wall, dx from tile centre, towards the door side of the gap)
"""
import json, os, sys

ZONES = os.path.join(os.path.dirname(__file__), "..", "..", "data", "zones")
WALK = set(".,#=:sfw|+_&D")   # legend chars you can stand on (see ZoneData.LEGEND)
PLAIN = {"red_brick", "stone", "white_render", "gritstone", "cream_render", "sanctuary", "shop"}  # Meshes.building's own facades

# interior -> sea areas, nearest first (the first gets the game's real current weather)
RADIOS = {
    "macc_home": ["Irish Sea", "Malin", "Hebrides", "Lundy"],
    "edinburgh_home_a": ["Forth", "Tyne", "Fair Isle", "Hebrides"],
    "glasgow_home_a": ["Hebrides", "Malin", "Forth", "Irish Sea"],
    "kirkwall_home_a": ["Fair Isle", "Hebrides", "Forth", "Rockall"],
    "portree_home_a": ["Hebrides", "Malin", "Rockall", "Fair Isle"],
    "york_house_a": ["Humber", "Tyne", "Forth", "Thames"],
    "sheffield_home_platt": ["Humber", "Tyne", "Thames", "Irish Sea"],
    "nottingham_home1": ["Humber", "Thames", "Dover", "Irish Sea"],
    "birmingham_home1": ["Irish Sea", "Thames", "Lundy", "Humber"],
    "bath_home1": ["Portland", "Lundy", "Wight", "Plymouth"],
    "penzance_home1": ["Plymouth", "Lundy", "Fastnet", "Portland"],
    "cardiff_home_bute": ["Lundy", "Irish Sea", "Plymouth", "Fastnet"],
    "dublin_home_green": ["Irish Sea", "Malin", "Shannon", "Fastnet"],
    "cork_home1": ["Fastnet", "Shannon", "Lundy", "Plymouth"],
    "galway_home_prom": ["Shannon", "Rockall", "Malin", "Fastnet"],
    "belfast_home_wain": ["Malin", "Irish Sea", "Hebrides", "Shannon"],
    "keswick_home_armstrong": ["Irish Sea", "Malin", "Tyne", "Hebrides"],
    "dingle_home1": ["Shannon", "Fastnet", "Rockall", "Malin"],
    "douglas_home1": ["Irish Sea", "Malin", "Hebrides", "Lundy"],
    "holyhead_home3": ["Irish Sea", "Lundy", "Malin", "Fastnet"],
}

# town -> (label of the building to put it on, text). Wording avoids "here" where the building is only a stand-in.
PLAQUES = {
    "manchester": ("John Rylands Library", "Alan Turing, mathematician and computing pioneer, worked at the University of Manchester from 1948 to 1954."),
    "macclesfield": ("Paradise Mill", "Macclesfield has woven silk since the 1700s and was one of the great silk towns of England. The Jacquard looms in this mill worked until 1981."),
    "liverpool": ("The Cavern (ish)", "The Beatles played at the Cavern Club in Mathew Street from 1961 to 1963, and the rest is history."),
    "edinburgh": ("Corner Shop", "Arthur Conan Doyle, creator of Sherlock Holmes, was born near here at 11 Picardy Place on 22 May 1859."),
    "dublin": ("Trinity College", "Oscar Wilde, writer and wit, was born in Dublin in 1854 and studied at Trinity College from 1871 to 1874."),
    "cardiff": ("Norwegian Church", "Roald Dahl, author, was born in Llandaff in 1916 and baptised in the Norwegian Church."),
    "london": ("Corner Shop", "Charles Dickens, novelist, lived at 48 Doughty Street from 1837 to 1839 and wrote Oliver Twist there."),
    "whitby": (["The Harbour Inn", "Fish and Chips", "Captain Cook Memorial Museum"], "Bram Stoker, author of Dracula, stayed in Whitby in the summer of 1890, and the town and its abbey crept into the book."),
    "york": ("Stonegate Books", "Guy Fawkes of the Gunpowder Plot was born in Stonegate in 1570 and baptised at St Michael le Belfrey."),
    "belfast": ("Corner Shop", "C. S. Lewis, author of The Chronicles of Narnia, was born in Belfast on 29 November 1898."),
    "aberdeen": ("Town House", "Lord Byron, poet, spent his boyhood in Aberdeen from 1790 to 1798 and went to the Grammar School."),
    "aberystwyth": ("Old College", "The University College of Wales opened here in 1872, the first university institution in Wales."),
    "bath": ("Corner Shop", "Jane Austen, novelist, lived in Bath from 1801 to 1806, first at 4 Sydney Place."),
    "birmingham": ("Library of Birmingham", "J. R. R. Tolkien, author of The Hobbit, grew up in Birmingham from 1895, and the Shire owes a lot to Sarehole Mill."),
    "bushmills": ("Post Office", "The Old Bushmills Distillery, along the road, has held a licence to distil since 1608."),
    "buxton": ("St Ann's Well", "Mary, Queen of Scots, took the waters at Buxton while a prisoner of the Earl of Shrewsbury in the 1570s and 1580s."),
    "cairnryan": ("Harbour Office", "Loch Ryan was a Second World War military port. Surrendered German U-boats gathered here in 1945."),
    "chester": ("Corner Shop", "Charles Kingsley, author of The Water-Babies, was Canon of Chester and founded the Chester Society of Natural Science in 1871."),
    "cork": ("The English Market", "The English Market has traded on this spot since 1788."),
    "derry": ("Tower Museum", "The city walls were built between 1613 and 1618, and they are still complete."),
    "dingle": ("Strand Bakery", "Tom Crean, Antarctic explorer with Scott and Shackleton, was born at Annascaul on the Dingle Peninsula in 1877."),
    "douglas": ("Gaiety Theatre", "Sir William Hillary, who founded the RNLI in 1824, lived in Douglas. His Tower of Refuge stands on Conister Rock."),
    "fort_william": ("West Highland Museum", "Weather was recorded on the summit of Ben Nevis every hour from 1883 to 1904."),
    "galway": ("Latin Quarter Books", "Nora Barnacle, the wife of James Joyce, was born in Galway in 1884."),
    "glasgow": ("City Chambers", "Charles Rennie Mackintosh, architect and designer, studied in Glasgow and designed the School of Art, begun in 1897."),
    "glastonbury": ("Pyramid Stage", "The first Glastonbury Festival was held at Worthy Farm, Pilton, in September 1970. Tickets cost one pound and included free milk."),
    "holyhead": ("Ferry Terminal", "Thomas Telford built the Holyhead Road in the 1820s to carry the Irish mail from London. His Menai Bridge opened in 1826."),
    "inverness": ("Corner Shop", "In February 1746 Jacobite troops blew up the fort at Inverness, a few weeks before the Battle of Culloden."),
    "keswick": ("Cumberland Pencil Museum", "Graphite found in Borrowdale in the 1500s made Keswick a pencil town for centuries."),
    "kilkenny": ("The Tholsel", "The Confederation of Kilkenny, the Irish Catholic government of the 1640s, first met in this city in 1642."),
    "kirkwall": ("Corner Shop", "St Magnus Cathedral, just up the street, was founded in 1137 by Earl Rognvald in memory of his uncle Magnus."),
    "lancaster": ("Judges' Lodgings", "The Pendle witches were tried at Lancaster Castle in August 1612."),
    "llanberis": ("Dinorwic Quarry Gates", "Dinorwic Quarry employed up to 3,000 men at its height. It closed in 1969."),
    "llangollen": ("Corner Shop", "Eleanor Butler and Sarah Ponsonby, the Ladies of Llangollen, made their home at Plas Newydd in 1780."),
    "newcastle": ("Corner Shop", "Robert Stephenson and Company, the world's first purpose-built locomotive works, opened in Newcastle in 1823."),
    "newgrange": ("Visitor Centre", "Newgrange was built about 5,200 years ago, older than Stonehenge and the pyramids at Giza."),
    "nottingham": ("Corner Shop", "John Boot opened a herbalist's shop in Goose Gate in 1849. His son Jesse turned it into Boots."),
    "penzance": ("Chapel Street Books", "Sir Humphry Davy, chemist and inventor of the miners' safety lamp, was born in Penzance in 1778."),
    "portree": ("Royal Hotel", "Flora MacDonald said goodbye to Prince Charles Edward Stuart at Portree in 1746, after helping him escape to Skye."),
    "sheffield": ("Forge", "Harry Brearley, metallurgist, invented stainless steel in Sheffield in 1913."),
    "sligo": ("Hawk's Well Theatre", "W. B. Yeats, poet, spent boyhood summers in Sligo and lies buried at Drumcliffe."),
    "st_davids": ("Pilgrim Hostel", "St David, patron saint of Wales, founded a monastery here in the sixth century."),
}
PLAQUE_FALLBACK = ["Corner Shop", "Sanctuary"]


def load(zid):
    path = os.path.join(ZONES, zid + ".json")
    raw = open(path, encoding="utf-8").read()
    return path, raw, json.loads(raw)


def dump(z, raw):
    """The file's own style: indent=1, and ensure_ascii only where the file already escaped its non-ASCII."""
    plain = json.dumps(z, indent=1, ensure_ascii=False)
    return plain if plain in (raw, raw.rstrip("\n")) or "\\u" not in raw else json.dumps(z, indent=1)


def round_trips(z, raw):
    return dump(z, raw) in (raw, raw.rstrip("\n"))


def save(path, raw, z):
    out = dump(z, raw)
    if raw.endswith("\n"):
        out += "\n"
    open(path, "w", encoding="utf-8").write(out)


def blocked_tiles(z):
    b = set()
    for p in z["props"]:
        if p["type"] != "building" and not p.get("walk"):
            b.add((p["x"], p["y"]))
    for s in z["signs"]:
        b.add((s["x"], s["y"]))
    return b


def free(z, x, y, blocked):
    rows = z["rows"]
    return 0 <= y < len(rows) and 0 <= x < len(rows[y]) and rows[y][x] in WALK and (x, y) not in blocked


def reach(z, blocked, start):
    seen = {start}
    todo = [start]
    while todo:
        x, y = todo.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (x + dx, y + dy)
            if q not in seen and free(z, q[0], q[1], blocked):
                seen.add(q)
                todo.append(q)
    return seen


def add_radio(zid, areas):
    path, raw, z = load(zid)
    if any(s.get("kind") == "radio" for s in z["signs"]):
        return "has one"
    if not round_trips(z, raw):
        return "SKIPPED: file does not round-trip"
    blocked = blocked_tiles(z)
    spawn = tuple(z["spawn"])
    before = reach(z, blocked, spawn)
    occupied = {(n["x"], n["y"]) for n in z["npcs"]} | {(w["x"], w["y"]) for w in z["warps"]}
    row_props = [p["x"] for p in z["props"] if p["type"] != "building" and p["y"] <= 2]
    best = None
    for x in range(1, len(z["rows"][1]) - 1):
        y = 1
        if not free(z, x, y, blocked) or (x, y) in occupied or (x, y + 1) in occupied or z["rows"][y][x] not in "|+":
            continue
        if not free(z, x, y + 1, blocked):
            continue
        after = reach(z, blocked | {(x, y)}, spawn)
        if after != before - {(x, y)}:
            continue
        near = min([abs(x - px) for px in row_props] or [9])
        score = (near >= 2, min(near, 3), -abs(x - len(z["rows"][1]) // 2))
        if best is None or score > best[0]:
            best = (score, x, y)
    if best is None:  # a cramped room: stand the set on a kitchen counter instead (already blocked, so nothing is lost)
        for x in range(1, len(z["rows"][1]) - 1):
            for y in range(1, len(z["rows"]) - 1):
                if z["rows"][y][x] == "C" and (x, y + 1) in before and (x, y) not in occupied and (x, y) not in blocked:
                    score = (-abs(x - len(z["rows"][1]) // 2), -y)
                    if best is None or score > best[0]:
                        best = (score, x, y)
    if best is None:
        return "SKIPPED: no free wall tile"
    _, x, y = best
    z["signs"].append({"x": x, "y": y, "text": "A wireless set. It hums, hisses, and then a calm voice starts on the sea areas.",
                       "kind": "radio", "areas": areas})
    save(path, raw, z)
    return "radio at %d,%d" % (x, y)


def add_plaque(zid, label, text):
    path, raw, z = load(zid)
    if any(s.get("kind") == "plaque" for s in z["signs"]):
        return "has one"
    if not round_trips(z, raw):
        return "SKIPPED: file does not round-trip"
    blocked = blocked_tiles(z)
    heights = z.get("heights")
    blds = [p for p in z["props"] if p["type"] == "building"]
    for want in (label if isinstance(label, list) else [label]) + PLAQUE_FALLBACK:
        for b in blds:
            if b.get("label") != want:
                continue
            bx, by = int(b["x"]), int(b["y"] + b["h"] - 1)
            doors = [x for x in range(bx, bx + int(b["w"])) if z["rows"][by][x] == "D"]
            if not doors:
                continue
            dx0 = doors[0]
            for side in (1, -1):
                x = dx0 + side
                if not (bx <= x < bx + int(b["w"])) or z["rows"][by][x] != "B":
                    continue
                if not free(z, x, by + 1, blocked) or z["rows"][by + 1][x] in "D":
                    continue
                if heights and heights[by + 1][x] != heights[by][dx0]:
                    continue
                if (x, by) in blocked:
                    continue
                z["signs"].append({"x": x, "y": by, "text": "BLUE PLAQUE: " + text, "kind": "plaque", "dx": -0.475 * side})
                save(path, raw, z)
                return "%s on %s (%s)" % (b.get("style"), want, "wanted" if want in label else "fallback")
    return "SKIPPED: no wall slot"


if __name__ == "__main__":
    for zid, areas in RADIOS.items():
        print("%-24s %s" % (zid, add_radio(zid, areas)))
    for zid, (label, text) in PLAQUES.items():
        print("%-14s %s" % (zid, add_plaque(zid, label, text)))
