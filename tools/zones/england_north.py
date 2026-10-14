"""Plan 3 zone group A: England North and the Isle of Man.
    python3 tools/zones/england_north.py tools/zones data/zones
Writes zones into <out>, dialogue into <out>/../dialogue and trainers into <out>/../trainers.
Also patches buxton.json (north gap to Goyt Valley) in place; that patch is idempotent."""
import sys, os, json, math, random
sys.path.insert(0, sys.argv[1]); from zlib import Z, sanctuary, shop
OUT = sys.argv[2]
DLG_DIR = os.path.join(OUT, "..", "dialogue")
TR_DIR = os.path.join(OUT, "..", "trainers")
DLG = {}


# ---------------- helpers ----------------
def say(zone, sid, who, *lines):
    DLG.setdefault(zone, {})[sid] = [{"do": "say", "who": who, "text": t} for t in lines]

def trainer(tid, name, cls, sprite, party, money, intro, win, after):
    d = {"id": tid, "name": name, "class": cls, "sprite": sprite,
         "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
         "intro": [{"do": "say", "who": name, "text": t} for t in intro], "win": win, "after": after}
    os.makedirs(TR_DIR, exist_ok=True)
    json.dump(d, open(os.path.join(TR_DIR, tid + ".json"), "w"), indent=1)

def occupied(z):
    s = set()
    for p in z.d["props"]:
        if p["type"] != "building": s.add((p["x"], p["y"]))
    for g in z.d["signs"]: s.add((g["x"], g["y"]))
    for n in z.d["npcs"]: s.add((n["x"], n["y"]))
    for w in z.d["warps"]: s.add((w["x"], w["y"]))
    return s

def deco(z, x, y, w, h, typ, n, seed, on=".", **kw):
    r = random.Random(seed); occ = occupied(z); placed = 0; tries = 0
    x2, y2 = min(x + w, z.w), min(y + h, z.h); x, y = max(x, 0), max(y, 0)
    while placed < n and tries < n * 40:
        tries += 1
        xx = r.randrange(x, x2); yy = r.randrange(y, y2)
        if z.g[yy][xx] in on and (xx, yy) not in occ:
            t = r.choice(typ) if isinstance(typ, list) else typ
            k = dict(kw)
            if t in ("oak",): k.setdefault("variant", (xx + yy) % 3)
            z.prop(t, xx, yy, **k); occ.add((xx, yy)); placed += 1

def ell(z, cx, cy, rx, ry, ch, only=None):
    for yy in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for xx in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if 0 <= xx < z.w and 0 <= yy < z.h and ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 <= 1:
                if only is None or z.g[yy][xx] in only: z.g[yy][xx] = ch

def pond(z, cx, cy, rx, ry, shore="s", flat=True):
    ell(z, cx, cy, rx + 1.6, ry + 1.4, shore, only=".,fT P")
    ell(z, cx, cy, rx + 0.6, ry + 0.5, "w", only=".,fTPs")
    ell(z, cx, cy, rx - 0.6, ry - 0.6, "~")

def reedify(z, prob, seed):
    """Turn a share of shallow-water tiles into reed beds (needs legend 'r')."""
    r = random.Random(seed)
    for y in range(z.h):
        for x in range(z.w):
            if z.g[y][x] == "w" and r.random() < prob: z.g[y][x] = "r"

def hill(z, cx, cy, rx, ry, peak):
    for yy in range(max(0, int(cy - ry)), min(z.h, int(cy + ry) + 1)):
        for xx in range(max(0, int(cx - rx)), min(z.w, int(cx + rx) + 1)):
            d = math.sqrt(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)
            if d < 1: z.hg[yy][xx] = max(z.hg[yy][xx], int(peak * (1 - d) + 0.5))

def path(z, pts, ch="#", w=1):
    o = w // 2
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        for x in range(min(x0, x1), max(x0, x1) + 1):
            for y in range(min(y0, y1), max(y0, y1) + 1):
                z.rect(x - o, y - o, w, w, ch)

def wood(z, x, y, w, h, n, seed, ch="P", only="."):
    z.scatter(x, y, w, h, ch, n, seed, only=only)

def door_to(z, door, interior, tx, ty, facing="up", front=":"):
    """Warp from a building door tile to an interior; lay `front` in the tile south of the door; return that tile."""
    dx, dy = door
    z.warp(dx, dy, interior, tx, ty, facing)
    if front: z.set(dx, dy + 1, front)
    return (dx, dy + 1)

def town_services(z, town, name, sanct_xy, shop_xy, sanct_style="sanctuary"):
    """Sanctuary and Corner Shop buildings with doors, warps, interiors and dialogue."""
    sx, sy = sanct_xy
    d = z.building(sx, sy, 6, 4, "sanctuary", "Sanctuary", door=3)
    r = door_to(z, d, town + "_sanctuary", 5, 6)
    sanctuary(OUT, town, name, r)
    hx, hy = shop_xy
    d = z.building(hx, hy, 5, 3, "shop", "Corner Shop", door=2)
    r2 = door_to(z, d, town + "_shop", 4, 5)
    shop(OUT, town, name, r2)
    return r, r2

def nurse_and_shop(town, nurse_lines, shop_lines):
    """data/dialogue/<town>_sanctuary.json and <town>_shop.json."""
    DLG[town + "_sanctuary"] = {"nurse": [
        {"do": "say", "who": "Nurse", "text": nurse_lines[0]},
        {"do": "choice", "text": "What can we do for you?", "options": ["Heal my team", "Open the Ark", "Just looking"], "set": "_nurse_choice"},
        {"do": "if", "flag": "_nurse_choice", "eq": 0,
         "then": [{"do": "say", "who": "Nurse", "text": nurse_lines[1]}, {"do": "heal"},
                  {"do": "say", "who": "Nurse", "text": nurse_lines[2]}],
         "else": [{"do": "if", "flag": "_nurse_choice", "eq": 1,
                   "then": [{"do": "say", "who": "Nurse", "text": nurse_lines[3]}, {"do": "ark"}],
                   "else": [{"do": "say", "who": "Nurse", "text": nurse_lines[4]}]}]}]}
    DLG[town + "_shop"] = {"shopkeeper": [
        {"do": "say", "who": "Shopkeeper", "text": shop_lines[0]},
        {"do": "shop", "id": town + "_corner_shop"},
        {"do": "say", "who": "Shopkeeper", "text": shop_lines[1]}]}

def interior(zid, name, w, h, door_x, out_zone, ox, oy, music="town_cheshire", fill="|"):
    r = Z(zid, name, w, h, fill=fill, kind="interior", region="", music=music, weather={})
    r.border("x", 1)
    r.set(door_x, h - 2, "D")
    r.warp(door_x, h - 2, out_zone, ox, oy, "down")
    r.d["spawn"] = [door_x, h - 3]
    return r

def rail_guard(z, x, y, facing="down"):
    z.npc(id="rail_guard", sprite="rail_guard", x=x, y=y, facing=facing, move="still", script="rail_guard", name="Rail Guard")

def flush():
    os.makedirs(DLG_DIR, exist_ok=True)
    for zone, scripts in DLG.items():
        json.dump(scripts, open(os.path.join(DLG_DIR, zone + ".json"), "w"), indent=1)
import atexit; atexit.register(flush)

BIRCH = {"tile": "tree_oak", "prop": "birch"}
REEDS = {"tile": "shallow", "prop": "reeds"}
HEATHER = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}


# ====================================================================
# Buxton: open the north gap (columns 26 to 28) to Goyt Valley
# ====================================================================
bp = os.path.join(OUT, "buxton.json")
b = json.load(open(bp))
rows = [list(r) for r in b["rows"]]
for y in range(0, 6):
    for x in (26, 27, 28):
        rows[y][x] = "#"
for y in range(6, 10):
    rows[y][28] = "#" if rows[y][28] == "." else rows[y][28]
b["rows"] = ["".join(r) for r in rows]
b["edges"]["north"] = {"to": "goyt_valley", "offset": 0}
b["stage"] = b.get("stage", "town")
if not any(s.get("x") == 29 and s.get("y") == 5 for s in b["signs"]):
    b["signs"].append({"x": 29, "y": 5, "text": "NORTH: Goyt Valley and, eventually, Manchester. Take a coat. Manchester will not provide one."})
json.dump(b, open(bp, "w"), indent=1)


# ====================================================================
# GOYT VALLEY  60 x 64, route, Buxton (south) to Manchester (north)
# ====================================================================
g = Z("goyt_valley", "Goyt Valley", 60, 64, kind="route", region="peak", music="route_forest",
      weather={"drizzle": 35, "clear": 25, "fog": 20, "sunshine": 15, "gale": 5})
g.d["stage"] = "valley"
g.legend["b"] = BIRCH; g.legend["r"] = REEDS; g.legend["h"] = HEATHER
g.border("P", 3, gaps=[(26, 61, 3, 3), (26, 0, 3, 3)])
hill(g, 12, 13, 14, 11, 3); hill(g, 50, 11, 14, 10, 4); hill(g, 50, 53, 12, 9, 3); hill(g, 8, 57, 10, 6, 2)
hill(g, 30, 60, 8, 4, 1)
wood(g, 3, 3, 54, 58, 330, 101, "P"); wood(g, 3, 3, 54, 58, 120, 102, "T"); wood(g, 3, 3, 54, 58, 60, 103, "b")
# the reservoirs: Errwood (west) and Fernilee (east)
pond(g, 13, 44, 8, 8); pond(g, 47, 29, 6, 9)
g.rect(5, 37, 18, 1, "r"); g.rect(41, 18, 12, 1, "r")
g.height(5, 35, 18, 20, 0); g.height(40, 18, 14, 22, 0)
# the track, with a clear verge either side
TRACK = [(27, 63), (27, 55), (33, 55), (33, 37), (27, 37), (27, 23), (34, 23), (34, 10), (27, 10), (27, 0)]
path(g, TRACK, ".", 5); g.border("P", 3, gaps=[(26, 61, 3, 3), (26, 0, 3, 3)]); path(g, TRACK, "#", 1)
# heather and bog on the tops
for (cx, cy, rx, ry) in [(46, 10, 7, 4), (10, 12, 6, 4), (52, 46, 4, 4)]:
    ell(g, cx, cy, rx, ry, "h", only=".P")
# tall-grass clearings near the track
for (cx, cy, rx, ry) in [(21, 54, 4, 3), (40, 50, 4, 4), (39, 42, 3, 3), (22, 31, 5, 3), (31, 29, 2, 3), (41, 15, 4, 3), (21, 14, 4, 3), (30, 17, 2, 3), (22, 46, 2, 2)]:
    ell(g, cx, cy, rx, ry, ",", only=".Pb T")
# Errwood Hall ruin and the Spanish shrine
g.rect(9, 24, 14, 10, "."); g.height(9, 24, 14, 10, 0)
g.building(14, 27, 6, 3, "stone", "Errwood Hall (ruin)", show_label=True)
g.rect(17, 30, 1, 3, "#"); path(g, [(17, 31), (27, 31)], "#")
g.rect(17, 36, 1, 1, "#")
g.building(10, 25, 3, 2, "chapel", "Spanish Shrine")
path(g, [(11, 27), (11, 31), (17, 31)], "#")
for (x, y) in [(13, 25), (21, 25), (9, 29), (22, 33)]: g.prop("rock", x, y)
g.rect(12, 28, 1, 1, "f"); g.rect(20, 27, 1, 1, "f")
# rhododendrons (bushes) round the hall, drystone walls and fences
for (x, y) in [(13, 27), (20, 27), (13, 30), (20, 30), (15, 26), (18, 26)]: g.prop("bush", x, y)
g.rect(24, 17, 1, 10, "W"); g.rect(24, 17, 10, 1, "W")
g.rect(35, 38, 1, 8, "F"); g.rect(31, 56, 8, 1, "F"); g.rect(25, 40, 1, 6, "W")
# car park by the south gap
g.rect(20, 57, 6, 3, ":"); g.rect(21, 56, 4, 1, ":")
g.prop("bench", 20, 59); g.prop("post_box", 25, 57); g.prop("lamp_post", 25, 59)
# Shining Tor trig point
g.prop("standing_stone", 47, 8); g.prop("standing_stone", 48, 8, variant=1); g.prop("rock", 46, 9); g.prop("rock", 49, 7)
path(g, [(34, 12), (44, 12), (44, 8)], "#"); g.rect(45, 8, 1, 1, "#")
# signs
g.sign(29, 59, "GOYT VALLEY. Pay and display. The honesty box is not an honesty box, it is a ticket machine.")
g.sign(26, 54, "ERRWOOD RESERVOIR, built 1967 to quench Stockport. The old road under the water is still down there.")
g.sign(32, 36, "ERRWOOD HALL. Once grand, now rhododendrons. They always win in the end.")
g.sign(35, 22, "NORTH: Manchester, 20 miles. Rain: 20 miles of it.")
g.sign(35, 11, "SHINING TOR, 559 metres. Highest point in Cheshire. Say it loudly, they will only half believe you.")
g.sign(28, 31, "THE SPANISH SHRINE. A family built it for their governess. Best staff benefits in the Peak.")
g.sign(43, 17, "FERNILEE RESERVOIR, 1938. Dam, dignity and a lot of heron.")
# NPCs (chatty)
g.npc(id="goyt_ranger", sprite="villager_2", x=29, y=58, facing="left", move="still", script="ranger", name="Ranger")
g.npc(id="goyt_sailor", sprite="villager_4", x=31, y=40, facing="left", move="wander", script="dinghy", name="Dinghy Dave")
g.npc(id="goyt_gardener", sprite="villager_6", x=15, y=32, facing="down", move="still", script="shrine_fan", name="Shrine Visitor")
g.npc(id="goyt_runner", sprite="jogger", x=29, y=25, facing="up", move="pace", script="tor_runner", name="Fell Runner")
g.npc(id="goyt_walker", sprite="villager_1", x=36, y=12, facing="left", move="still", script="tor_walker", name="Walker")
for t in [("goyt_hiker", "Hiker Marge", "Hiker", "hiker", [("brockling", 12), ("pepperling", 13)], 380, 31, 51, "left",
           ["Do you know how far it is to Manchester? Neither do I. We've been lost since Tuesday.", "The map says 'valley'. The valley says 'no'."],
           "Right. Left. Whichever way you're going, you've earned it.", "I've found the path. It was under my other foot."),
          ("goyt_birder", "Birdwatcher Olwen", "Birdwatcher", "birdwatcher", [("pipkin", 13), ("starlet", 13), ("hootlet", 14)], 420, 38, 41, "left",
           ["Shh! I'm watching a dipper. Did you hear that? It's just you. Now it's gone.", "You owe me one dipper."],
           "Alright, alright. The dipper wasn't that rare anyway.", "Dippers walk underwater. I'd like to see you try."),
          ("goyt_angler", "Angler Phil", "Angler", "angler", [("holtling", 13), ("dipling", 14)], 400, 21, 41, "right",
           ["Fernilee's full of trout. Errwood's full of excuses. Care to join me for either?", "Hold my rod, I've a battle to see to."],
           "That's a bigger catch than anything I've had all day.", "Seven hours. One boot. Peaceful, though."),
          ("goyt_runner_t", "Fell Runner Sasha", "Fell Runner", "jogger", [("scuttlet", 14), ("zigzlet", 14), ("sphagnet", 15)], 450, 29, 20, "down",
           ["I run up Shining Tor before breakfast. Do you want to see how fast I run into a fight?", "Warm up first, or you'll get a stitch."],
           "Ow. I'm taking a stitch and a lesson. Well run, you.", "Next time I'll take the hill first, then you.")]:
    tid, nm, cls, spr, party, money, x, y, facing, intro, win, after = t
    trainer(tid, nm, cls, spr, party, money, intro, win, after)
    g.npc(id=tid, sprite=spr, x=x, y=y, facing=facing, move="still", trainer=tid)
say("goyt_valley", "ranger", "Ranger", "Welcome to Goyt Valley! The reservoirs here feed the taps in Stockport. Drink responsibly, as they say.", "There are three rules: shut the gate, keep your dog on a lead, and never trust a sheep.")
say("goyt_valley", "dinghy", "Dinghy Dave", "That's Errwood Reservoir. They flooded the valley in 1967 and left a road down there. I like to think of it as a very long drowned car park.", "Don't tell the herons. They think they own it.")
say("goyt_valley", "shrine_fan", "Shrine Visitor", "The Spanish Shrine was built by the Grimshawe family of Errwood Hall for their Spanish governess. She must have been quite the governess.", "The rhododendrons around here were planted by them too, and they've been taking over since.")
say("goyt_valley", "tor_runner", "Fell Runner", "Shining Tor is the highest point in Cheshire at 559 metres. I know because I nearly died on it.", "Worth it for the view of Manchester. Mostly cloud. Occasionally Manchester.")
say("goyt_valley", "tor_walker", "Walker", "Up here the old Roman road runs along the ridge. They don't make them straight like that any more.", "I tried to follow it once and ended up in Whaley Bridge. Don't ask.")
g.d["encounters"] = {"grass": [
    {"species": "pepperling", "min": 12, "max": 14, "weight": 22, "time": ["dusk", "night", "dawn"]},
    {"species": "brockling", "min": 12, "max": 14, "weight": 14, "time": ["dawn", "dusk", "night"]},
    {"species": "zigzlet", "min": 13, "max": 15, "weight": 12, "time": ["day", "dusk"]},
    {"species": "sphagnet", "min": 12, "max": 14, "weight": 14, "weather": ["drizzle", "downpour", "fog"]},
    {"species": "scuttlet", "min": 12, "max": 14, "weight": 18, "time": ["dawn", "day", "dusk"]},
    {"species": "pipkin", "min": 12, "max": 14, "weight": 14, "time": ["dawn", "day"]},
    {"species": "flittermouse", "min": 13, "max": 15, "weight": 14, "time": ["dusk", "night"]},
    {"species": "hootlet", "min": 13, "max": 15, "weight": 10, "time": ["dusk", "night"]},
    {"species": "croakle", "min": 12, "max": 14, "weight": 8, "weather": ["drizzle", "downpour"]},
    {"species": "wispet", "min": 13, "max": 15, "weight": 10, "weather": ["fog"]}],
    "water": [
    {"species": "holtling", "min": 12, "max": 14, "weight": 30},
    {"species": "dipling", "min": 12, "max": 14, "weight": 30},
    {"species": "croakle", "min": 12, "max": 14, "weight": 20}]}
g.d["edges"] = {"south": {"to": "buxton", "offset": 0}, "north": {"to": "manchester", "offset": 0}}
g.d["spawn"] = [27, 60]
deco(g, 3, 3, 54, 58, ["bush", "rock", "birch", "oak"], 90, 111)
reedify(g, 0.5, 113)
deco(g, 3, 3, 54, 58, ["bush", "rock", "birch"], 70, 112, on=",")
g.save(OUT + "/goyt_valley.json")

for _part in ["en_manchester", "en_chat_moss", "en_liverpool", "en_wirral", "en_chester", "en_douglas", "en_post"]:
    exec(compile(open(os.path.join(sys.argv[1], _part + ".py")).read(), _part, "exec"))
