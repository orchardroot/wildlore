# Wildlore 3.0 "Wider Isles": the Cotswolds and Oxford, off Birmingham's east side (late game, par 89).
#
#   python3 tools/zones/cotswolds.py data/zones
#
# Zones: `cotswolds` (a route: honey-stone villages, drystone walls, Cooper's Hill, the Rollright Stones, Broadway
# Tower) and `oxford` (the town: spires, the Bodleian, the Radcliffe Camera, colleges, punts). Writes the zones,
# their interiors, dialogue (data/dialogue) and trainers (data/trainers). Quests, items, shops, creatures, quiz,
# map entries and the Birmingham gate are in cotswolds_data.py.
import sys
import math
from p6a_common import *
from wcommon import _stand
from zlib import landmark
import cotswolds_story as story

FLOOR = 89  # Birmingham's band: everything here is authored for a level ~89 team and lifts with the story
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
WARM = {"g": {"tile": "grass", "colour": "#a8b45f"}, "k": {"tile": "tall_grass", "colour": "#97a652"},
        "b": {"tile": "road", "bridge": True, "colour": "#9b8a68"}}


def plaque(z, x, y, region, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": region + "_" + pid, "title": title, "text": text})


def fringe(z, land=".,#:=fTg"):
    marks = []
    for y in range(z.h):
        for x in range(z.w):
            if z.g[y][x] != "~":
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < z.w and 0 <= yy < z.h and z.g[yy][xx] in land:
                    marks.append((x, y))
                    break
    for (x, y) in marks:
        z.set(x, y, "w")


def blocked_ok(z, x, y, w, h):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            assert z.g[yy][xx] not in "B~", "%s: building overlap at %d,%d" % (z.d["id"], xx, yy)


def bld(z, x, y, w, h, style, label=None, door=None, to=None, iw=13, ih=10, show_label=True, kind=None):
    """a building; with `door` and `to`, a warp into interior `to` (arrive above its exit). Returns the tile below the door."""
    blocked_ok(z, x, y, w, h)
    z.building(x, y, w, h, style, label, door=door, show_label=show_label)
    if door is not None and to:
        z.warp(x + door, y + h - 1, to, iw // 2, ih - 3, "up")
        return (x + door, y + h)
    return None


def scale_trainers(ids):
    for t in ids:
        TRN[t]["scaled_floor"] = FLOOR


def reach_check(z, extra=()):
    """BFS from the spawn over walkable tiles: every warp door, NPC and sign must be reachable (or have a walkable neighbour)."""
    walk = set(".,#=:sfw_Dbgk+|")
    blockers = {(p["x"], p["y"]) for p in z.d["props"] if p["type"] != "building" and not p.get("walk")}
    start = tuple(z.d["spawn"])
    seen = {start}
    q = [start]
    while q:
        x, y = q.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < z.w and 0 <= ny < z.h and (nx, ny) not in seen and z.g[ny][nx] in walk and (nx, ny) not in blockers:
                seen.add((nx, ny))
                q.append((nx, ny))
    bad = []
    targets = [(w_["x"], w_["y"]) for w_ in z.d["warps"]] + [(n["x"], n["y"]) for n in z.d["npcs"]] + [(s["x"], s["y"]) for s in z.d["signs"]] + list(extra)
    for (x, y) in targets:
        if (x, y) in seen:
            continue
        if not any((x + dx, y + dy) in seen for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
            bad.append((x, y))
    assert not bad, "%s: unreachable %s" % (z.d["id"], bad)
    return seen


def drystone(z, x0, y0, x1, y1, gaps=()):
    """a drystone wall line (horizontal or vertical) on grass only, leaving gaps (list of coordinates along the line)."""
    if y0 == y1:
        for x in range(x0, x1 + 1):
            if x not in gaps and z.g[y0][x] in ".g,k":
                z.set(x, y0, "W")
    else:
        for y in range(y0, y1 + 1):
            if y not in gaps and z.g[y][x0] in ".g,k":
                z.set(x0, y, "W")


def standing_ring(z, cx, cy, r, n, gap_angle, gap_w, seed=0):
    """standing stones round a circle, with an entrance gap (angle in degrees, 90 = south)."""
    rng = random.Random(seed)
    placed = []
    for i in range(n):
        a = 360.0 * i / n
        d = abs(((a - gap_angle + 180) % 360) - 180)
        if d < gap_w:
            continue
        x = int(round(cx + r * math.cos(math.radians(a))))
        y = int(round(cy + r * 0.92 * math.sin(math.radians(a))))
        if (x, y) in placed:
            continue
        placed.append((x, y))
        _stand(z, x, y)
        z.g[y][x] = "g"
        z.prop("standing_stone", x, y, variant=rng.randrange(3))
    return placed


# ------------------------------------------------------------------------------------------------ the Cotswolds
def cotswolds():
    W, H = 88, 66
    zid = "cotswolds"
    z = Z(zid, "The Cotswolds", W, H, kind="route", region="midlands", music="route_forest",
          weather={"clear": 28, "sunshine": 24, "drizzle": 24, "fog": 10, "gale": 6, "downpour": 4, "frost": 4})
    z.d["stage"] = "forest"
    z.d["scaled_floor"] = FLOOR
    z.legend.update(WARM)
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(0, 25, 2, 3), (86, 30, 2, 3)])
    z.scatter(0, 0, W, H, "P", 4, 91, only="T")
    # the main road: in from Birmingham, then east along the old Fosse Way line to Stow, Bourton and Oxford
    path(z, [(0, 25), (20, 25), (20, 30), (86, 30)], "=", 3)
    z.d["spawn"] = [3, 26]
    z.sign(4, 24, "WEST: Birmingham. EAST: Stow, Bourton and, beyond them, Oxford. SOUTH: Cooper's Hill, mind the slope. NORTH-EAST: the Rollright Stones, count them if you dare.")

    # ---- Stow-ish: honey-stone village on both sides of the road
    z.rect(24, 29, 37, 1, ":")
    z.rect(24, 33, 37, 1, ":")
    z.rect(39, 28, 10, 1, ":")
    bld(z, 26, 24, 6, 5, "cotswold_house", "Sanctuary", 3)
    z.warp(29, 28, "cotswolds_sanctuary", 5, 6, "up")
    bld(z, 33, 25, 5, 4, "cotswold_house", "Corner Shop", 2)
    z.warp(35, 28, "cotswolds_shop", 4, 5, "up")
    bld(z, 39, 23, 7, 5, "cotswold_house", "Wool Merchant's House", 3, "cotswolds_woolhouse")
    bld(z, 47, 21, 9, 7, "wool_church", "St Edward's Church", 5, "cotswolds_church")
    # a pair of yews either side of the north door (the Stow door that Tolkien may or may not have borrowed)
    z.prop("pine", 51, 29, variant=1)
    z.prop("pine", 55, 29, variant=2)
    plaque(z, 38, 29, "cotswolds", "stow", "Stow-on-the-Wold",
           "At nearly 250 metres, Stow is the highest town in the Cotswolds, and the old rhyme says 'Stow-on-the-Wold, where the wind blows cold'. Several ancient roads meet here, the Fosse Way among them, and its great market square held sheep fairs where as many as twenty thousand animals could change hands in a day. The church's north door sits between two ancient yews and is said to have inspired a certain famous fictional door.")
    plaque(z, 46, 29, "cotswolds", "wool_church", "Wool Churches",
           "In the Middle Ages the Cotswolds grew rich on wool, and the merchants spent it on enormous, airy churches, far bigger than a village needs. At Chipping Campden the wool merchant William Grevel was remembered as 'the flower of the wool merchants of all England'. The churches are called wool churches, and they are the wool trade's biggest souvenirs.")
    bld(z, 28, 34, 7, 4, "cotswold_house", "The Fleece", 3, "cotswolds_fleece")
    bld(z, 40, 34, 6, 4, "cotswold_cottage", "The Model Village", 2, "cotswolds_model")
    bld(z, 47, 34, 5, 4, "cotswold_house", show_label=False)
    bld(z, 53, 34, 6, 4, "cotswold_cottage", show_label=False)
    z.rect(26, 38, 36, 1, ":")
    plaque(z, 36, 38, "cotswolds", "honey_stone", "Honey-Coloured Stone",
           "Cotswold stone is oolitic limestone, made of tiny round grains of lime that formed in warm shallow seas about 167 million years ago in the Jurassic. The iron in it turns it honey-gold, deepest in the north near Chipping Campden and paler and greyer to the south. Every village is built of the same stone that lies beneath it, so each one seems to grow out of its field.")
    # shop gate stones: a lamp and bunting give the square life
    for (x, y) in [(31, 29), (45, 29), (57, 29), (31, 33), (45, 33), (57, 33)]:
        z.prop("lamp_post", x, y)
    z.prop("bunting", 41, 29, variant=2, walk=True)
    z.prop("bunting", 43, 29, variant=3, walk=True)
    z.prop("market_stall", 49, 33, variant=0)
    z.prop("planter", 37, 33, variant=1)
    z.prop("planter", 59, 33, variant=1)
    z.prop("post_box", 24, 33)

    # ---- Bourton-ish: the Windrush with its low stone bridges
    z.rect(26, 41, 43, 4, "~")
    z.rect(26, 41, 43, 1, "w")
    z.rect(26, 44, 43, 1, "w")
    for y in range(41, 45):
        z.set(26, y, "w")
        z.set(68, y, "w")
    for bx in (36, 48, 60):
        z.rect(bx, 41, 2, 4, "b")
        z.rect(bx, 38, 2, 3, ":")
        z.rect(bx, 45, 2, 3, ":")
    z.rect(24, 48, 44, 1, ":")
    plaque(z, 38, 40, "cotswolds", "windrush", "The Windrush at Bourton",
           "Bourton-on-the-Water is called the Venice of the Cotswolds, because the shallow, clear River Windrush runs right down the middle of it under a string of low stone footbridges. The river is rarely more than knee deep, so children paddle in it and ducks hold the right of way. On the green stands a model of the village at one-ninth scale, built in 1937, which includes a model of itself, and so on.")
    z.sign(46, 48, "THE MODEL VILLAGE is that way, north of the river. It is a very small village. Do not step on the vicar.")
    # south bank cottages
    bld(z, 26, 49, 5, 3, "cotswold_cottage", show_label=False)
    bld(z, 32, 49, 6, 3, "cotswold_cottage", show_label=False)
    bld(z, 52, 49, 5, 3, "cotswold_cottage", show_label=False)
    bld(z, 58, 49, 6, 3, "cotswold_house", show_label=False)
    z.rect(24, 52, 44, 1, ":")
    # the sheep pen: Cotswold Lions in a drystone fold
    for x in range(40, 51):
        z.set(x, 54, "W")
        z.set(x, 62, "W")
    for y in range(54, 63):
        z.set(40, y, "W")
        z.set(50, y, "W")
    for x in (44, 45, 46):
        z.set(x, 54, "g")
    z.rect(44, 52, 3, 2, ":")
    for (x, y, v) in [(42, 57, 0), (47, 56, 1), (44, 59, 2), (48, 60, 0), (42, 61, 1), (46, 58, 2), (49, 57, 1)]:
        z.prop("sheep", x, y, variant=v)
    z.rect(41, 55, 9, 7, "g")
    plaque(z, 45, 53, "cotswolds", "cotswold_lion", "The Cotswold Lion",
           "A big, long-woolled sheep with a shaggy forelock like a lion's mane, called the Cotswold Lion. Its heavy, lustrous fleece was the foundation of the wool trade that built the wool churches and the honey-coloured towns. The breed is now rare, kept by enthusiasts and rare-breed farms.")

    # ---- Cooper's Hill, to the south-west: a very steep slope, a finish line, a dairy
    for y in range(34, 62):
        top = 8 if y <= 40 else max(0, 8 - (y - 40) // 2)
        for x in range(4, 24):
            side = min(x - 3, 23 - x)
            z.hg[y][x] = max(0, min(top, side))
    path(z, [(12, 33), (12, 40)], "#", 2)
    z.rect(12, 33, 11, 1, "#")
    z.rect(8, 36, 11, 5, "g")
    z.rect(7, 56, 13, 2, "#")
    z.prop("cheese_wheel", 12, 57, variant=2)
    z.prop("cheese_wheel", 15, 57, variant=1)
    z.prop("flagpole", 9, 57, variant=4)
    z.prop("flagpole", 17, 57, variant=4)
    z.prop("bunting", 11, 56, variant=1, walk=True)
    z.prop("bunting", 14, 56, variant=2, walk=True)
    for y in range(41, 56, 3):
        z.prop("rock", 5, y, variant=y % 3)
    plaque(z, 14, 38, "cotswolds", "coopers_hill", "Cooper's Hill Cheese-Rolling",
           "Each spring bank holiday a round of Double Gloucester, about 3 to 4 kilograms, is sent rolling down this hill, which is so steep that the cheese can reach 70 mph and nobody can keep up on two feet. The runners tumble after it, and the first over the line at the bottom wins the cheese. The custom is at least two centuries old and probably much older; the winner's prize is the wheel itself.")
    bld(z, 25, 55, 6, 3, "cotswold_cottage", "Cooper's Hill Dairy", 2, "cotswolds_dairy", iw=11, ih=9)
    z.rect(25, 58, 6, 1, ":")
    z.rect(20, 58, 6, 1, "#")
    z.rect(22, 50, 3, 8, "g")
    z.rect(23, 52, 3, 3, ":")

    # ---- the Rollright Stones, to the north-east
    hills(z, [(74, 11, 3, 14)])
    path(z, [(66, 30), (66, 20), (74, 20), (74, 16)], "#", 1)
    ring = standing_ring(z, 74, 11, 6.3, 30, 90, 24, seed=5)
    _stand(z, 63, 21)
    z.prop("standing_stone", 63, 21, variant=2)
    for (x, y) in [(80, 20), (81, 19), (82, 20), (81, 21), (83, 21)]:
        z.prop("standing_stone", x, y, variant=(x + y) % 3)
    z.rect(60, 18, 6, 1, "W")
    z.rect(60, 24, 6, 1, "W")
    z.rect(60, 18, 1, 7, "W")
    plaque(z, 69, 21, "cotswolds", "rollright", "The Rollright Stones",
           "On the Oxfordshire border stand three monuments: the King's Men, a ring of about seventy-seven weathered limestone stones from around 2500 BC; the King Stone, a lone pillar across the road; and the Whispering Knights, the remains of a tomb some 5,000 years old. Legend says a king and his men were turned to stone by a witch, and that you can never count the stones the same twice. Nobody ever has, and a baker who tried with a bun on each stone is said to have failed.")
    plaque(z, 64, 22, "cotswolds", "king_stone", "The King Stone",
           "Legend says an invading king was told by a witch, 'Seven long strides shalt thou take, and if Long Compton thou canst see, King of England thou shalt be.' He took the seven strides, but a mound of earth rose up and hid the village. 'Rise up, stick, and stand still, stone, for King of England thou shalt be none,' said the witch, and she turned him to stone, with his men round him.")
    plaque(z, 79, 20, "cotswolds", "whispering_knights", "The Whispering Knights",
           "Five stones leaning together, the remains of a Neolithic burial chamber. Legend says they are knights who stood whispering their plots against the king, and were turned to stone for it. The stones lean as if they are still muttering.")
    # fingerpost and the Stone Keeper's honesty box
    z.sign(67, 29, "THE ROLLRIGHT STONES. Up the lane. Honesty box for the upkeep: £1. The King is not accepting visitors.")

    # ---- Broadway Tower and the walled uplands, to the north-west
    hills(z, [(12, 9, 5, 12)])
    bld(z, 11, 6, 4, 4, "castle", "Broadway Tower")
    z.rect(11, 10, 4, 1, "#")
    path(z, [(12, 11), (12, 16)], "#", 1)
    plaque(z, 14, 11, "cotswolds", "broadway_tower", "Broadway Tower",
           "A folly built in 1798 for the Countess of Coventry, so that a fire on top could be seen from her house at Worcester, thirty-odd miles away. It stands at the second-highest point of the Cotswold scarp, and on a clear day you can see as many as sixteen counties. William Morris holidayed here, and the Arts and Crafts movement liked the hill's views.")
    # drystone field walls, with gates
    drystone(z, 4, 16, 24, 16, gaps=(12, 13))
    drystone(z, 25, 3, 25, 22, gaps=(11, 12, 13))
    drystone(z, 4, 22, 24, 22, gaps=(10, 11, 17))
    drystone(z, 26, 18, 59, 18, gaps=(31, 32, 44, 45))
    drystone(z, 50, 3, 50, 17, gaps=(10, 11))
    drystone(z, 59, 3, 59, 17, gaps=(9, 10, 11))
    drystone(z, 70, 26, 86, 26, gaps=(76, 77))
    drystone(z, 70, 38, 86, 38, gaps=(78, 79, 80))
    drystone(z, 70, 38, 70, 62, gaps=(50, 51))
    drystone(z, 4, 62, 24, 62, gaps=(12, 13))
    plaque(z, 24, 23, "cotswolds", "drystone", "Drystone Walls",
           "The Cotswolds are criss-crossed by thousands of kilometres of walls built without a drop of mortar. Wallers sort the stone, lay two faces that lean inwards, tie them across with long 'through stones', fill the heart with rubble and finish with upright coping stones. Most date from the enclosure of the open fields in the 1700s and 1800s, and a good wall will outlast the waller by centuries.")
    # tall grass for the wild creatures, and some meadow flowers
    for (cx, cy, rx, ry, s) in [(8, 20, 4, 2, 1), (18, 12, 5, 3, 2), (36, 14, 6, 3, 3), (54, 12, 4, 3, 4), (66, 12, 3, 4, 5),
                                (80, 30, 4, 2, 6), (78, 44, 5, 3, 7), (60, 58, 6, 3, 8), (34, 62, 4, 2, 9), (16, 50, 3, 3, 10),
                                (8, 46, 2, 4, 11), (80, 55, 4, 3, 12), (30, 8, 4, 2, 13), (44, 11, 4, 2, 14), (84, 14, 2, 5, 15)]:
        blob(z, cx, cy, rx, ry, ",", only="g", seed=s, jitter=0.3)
    for (cx, cy, rx, ry, s) in [(20, 36, 2, 2, 31), (52, 56, 3, 2, 32), (66, 48, 3, 2, 33), (36, 12, 2, 1, 34)]:
        blob(z, cx, cy, rx, ry, "f", only="g", seed=s, jitter=0.3)
    scatter_props(z, "oak", 4, 3, 21, 12, 9, 61, avoid=("g",))
    scatter_props(z, "oak", 27, 3, 22, 13, 9, 62, avoid=("g",))
    scatter_props(z, "oak", 60, 3, 12, 12, 7, 63, avoid=("g",))
    scatter_props(z, "oak", 70, 40, 15, 22, 10, 64, avoid=("g",))
    scatter_props(z, "oak", 52, 54, 16, 9, 8, 65, avoid=("g",))
    scatter_props(z, "oak", 26, 55, 12, 8, 6, 66, avoid=("g",))
    scatter_props(z, "bush", 4, 24, 14, 14, 8, 67, avoid=("g",))

    # ---- people
    story.cotswolds_cast(z, chat, trainer, _stand)
    z.d["edges"] = {"west": {"to": "birmingham", "offset": 0}, "east": {"to": "oxford", "offset": 0}}
    wild(z, [("herdlet", 89, 91, 14, {}), ("loaghtan", 89, 91, 10, {}), ("leveret", 89, 91, 10, {"time": ["dawn", "dusk"]}),
             ("foalmoor", 89, 90, 8, {}), ("gloucelet", 89, 91, 12, {}), ("dozelet", 89, 90, 8, {}),
             ("moolet", 89, 90, 10, {}), ("starlet", 89, 90, 8, {"time": ["dawn", "day", "dusk"]}),
             ("hootlet", 89, 91, 6, {"time": ["night"]}), ("brockling", 89, 91, 8, {"time": ["dawn", "dusk", "night"]}),
             ("flaxling", 89, 90, 8, {}), ("pixling", 89, 90, 6, {"weather": ["fog", "drizzle"]}),
             ("tapknock", 89, 91, 6, {"weather": ["fog"]}), ("megalorn", 90, 92, 2, {"time": ["dusk", "night"]})])
    wild(z, [("volet", 89, 90, 20, {}), ("holtling", 89, 90, 14, {}), ("dipling", 89, 90, 16, {}), ("stalklet", 89, 90, 12, {}),
             ("cranelet", 89, 90, 10, {"time": ["dawn"]}), ("rillotter", 89, 91, 10, {"time": ["dusk", "night"]})], "water")
    smooth(z)
    z.d["props"] = [p for p in z.d["props"] if p]
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors
    sanctuary(OUT, zid, "Cotswolds", (29, 29))
    shop(OUT, zid, "Cotswolds", (35, 29))
    nurse(zid, ["Hello, my lovely! Welcome to the Cotswolds Sanctuary. Mind the step; it's been here since the wool trade and it has opinions.",
                "Pop your team on the counter. There's tea, and honey from the hives out the back, which has the same colour as the walls and the same sort of sweetness.",
                "There we are. Right as rain, and the rain is mostly lovely too.",
                "The Ark is in the corner. A lovely bit of oak, from a barn that blew down in the last gale.",
                "No hurry. Have a look at the walls; there's no wall in this village that hasn't been photographed."])
    shopkeeper(zid, "Afternoon! Tea, honey, a nice bit of Double Gloucester and the sort of snares you'd expect up on the wolds. What can I get you?",
               "Cheerio. Mind the wind on the way out, it comes straight from Stow.")
    landmark(OUT, "cotswolds_church", "St Edward's Church", zid, (52, 28), "church",
             [dict(id="cw_churchwarden", sprite="villager_3", x=6, y=2, facing="down", move="still", script="cw_churchwarden", name="Churchwarden")])
    landmark(OUT, "cotswolds_woolhouse", "Wool Merchant's House", zid, (42, 28), "museum",
             [dict(id="cw_woolman", sprite="villager_6", x=4, y=3, facing="right", move="still", script="cw_woolman", name="Wool Stapler"),
              dict(id="cw_fleecegirl", sprite="farmer", x=9, y=4, facing="left", move="still", script="cw_fleecegirl", name="Spinner")])
    landmark(OUT, "cotswolds_fleece", "The Fleece", zid, (31, 38), "cafe",
             [dict(id="cw_landlord", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="cw_landlord", name="Landlord"),
              dict(id="cw_quizmaster", sprite="fiddler", x=7, y=4, facing="left", move="still", script="cw_quizmaster", name="Quizmaster")], w=11, h=9)
    landmark(OUT, "cotswolds_model", "The Model Village", zid, (42, 38), "museum",
             [dict(id="cw_modelman", sprite="astronomer", x=9, y=3, facing="left", move="still", script="cw_modelman", name="Model Maker")])
    landmark(OUT, "cotswolds_dairy", "Cooper's Hill Dairy", zid, (27, 58), "cafe",
             [dict(id="cw_cheesemaker", sprite="jam_maker", x=3, y=1, facing="down", move="still", script="cw_cheesemaker", name="Cheesemaker"),
              dict(id="cw_dairyshop", sprite="villager_4", x=8, y=4, facing="left", move="still", script="cw_dairyshop", name="Dairy Hand")], w=11, h=9)


# ------------------------------------------------------------------------------------------------ Oxford
def oxford():
    W, H = 72, 60
    zid = "oxford"
    z = Z(zid, "Oxford", W, H, kind="town", region="south_east", music="town_york",
          weather={"clear": 28, "sunshine": 20, "drizzle": 24, "fog": 14, "gale": 4, "downpour": 6, "frost": 4})
    z.d["stage"] = "town"
    z.d["town_id"] = zid
    z.d["scaled_floor"] = FLOOR
    z.legend.update(WARM)
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 30, 2, 3)])
    z.scatter(0, 0, W, H, "P", 5, 92, only="T")
    z.d["spawn"] = [3, 31]
    # roads: the Botley Road in from the west, High Street through the middle, the N-S spine of St Giles, Cornmarket and St Aldate's
    z.rect(0, 30, 24, 3, "=")
    z.rect(24, 30, 36, 3, ":")
    z.rect(32, 3, 3, 11, "=")
    z.rect(32, 14, 3, 34, ":")
    z.rect(32, 48, 3, 9, "=")
    # the Cherwell and the Thames, with Magdalen Bridge and Folly Bridge
    z.rect(60, 3, 6, 54, "~")
    z.rect(2, 50, 58, 5, "~")
    fringe(z)
    z.rect(59, 30, 8, 3, "b")
    z.rect(32, 49, 3, 7, "b")
    z.rect(66, 30, 5, 3, "=")
    z.sign(69, 29, "COWLEY ROAD: closed for resurfacing. Again. (The shark is that way, all the same.)")
    # ---- the station, south-west
    station(z, 4, 36, 8, 3, "Oxford Station")
    z.rect(0, 39, 15, 1, "!")
    z.prop("buffer_stop", 15, 39)
    z.rect(2, 33, 2, 6, ":")
    z.rect(2, 33, 29, 1, ":")
    rail_guard(z, 9, 38, ["Oxford Station. The trains to everywhere you have been, and to the Gloucester Road, the Great Western and a surprising number of places that are not Oxford.",
                          "You'll need a Rail Pass. I'll ask nicely, and then I'll ask the barrier."], facing="down")
    # ---- south side of High Street
    bld(z, 14, 34, 6, 4, "oxford_college", "Sanctuary", 3)
    z.warp(17, 37, "oxford_sanctuary", 5, 6, "up")
    z.rect(12, 33, 2, 6, ":")
    z.rect(12, 38, 19, 1, ":")
    bld(z, 22, 34, 9, 4, "castle", "Oxford Castle")
    bld(z, 36, 34, 5, 4, "tudor", "Alice's Shop", 2)
    z.warp(38, 37, "oxford_shop", 4, 5, "up")
    bld(z, 41, 34, 3, 4, "oxford_tower", "Tom Tower")
    bld(z, 44, 34, 12, 4, "oxford_college", "Christ Church", 6, "oxford_christchurch", iw=15, ih=11)
    z.rect(35, 38, 24, 1, ":")
    # ---- the Meadow, the cathedral and the Botanic Garden
    bld(z, 38, 40, 8, 5, "oxford_church", "Christ Church Cathedral")
    z.rect(46, 40, 1, 8, "#")
    blob(z, 41, 47, 6, 1.5, ",", only=".", seed=71, jitter=0.3)
    blob(z, 50, 47, 3, 1.5, "f", only=".", seed=72, jitter=0.3)
    for x in range(48, 58):
        z.set(x, 40, "W")
        z.set(x, 47, "W")
    for y in range(40, 48):
        z.set(48, y, "W")
        z.set(57, y, "W")
    z.set(52, 40, ":")
    z.set(53, 40, ":")
    z.rect(49, 41, 8, 6, "f")
    z.rect(52, 41, 2, 6, "#")
    z.rect(50, 44, 6, 1, "#")
    z.prop("bench", 50, 42)
    z.prop("bench", 55, 45)
    scatter_props(z, "bush", 49, 41, 8, 6, 5, 73, avoid=("f",))
    # ---- north side of High Street: the market, Hertford and its bridge, Magdalen
    z.rect(24, 29, 36, 1, ":")
    bld(z, 36, 25, 8, 4, "market_hall", "Covered Market", 4, "oxford_market")
    bld(z, 47, 25, 8, 4, "oxford_college", "Magdalen College")
    bld(z, 55, 24, 3, 4, "oxford_tower", "Magdalen Tower")
    bld(z, 23, 25, 5, 4, "tudor", show_label=False)
    bld(z, 29, 25, 3, 4, "oxford_tower", "Carfax Tower")
    z.rect(44, 17, 3, 12, ":")
    bld(z, 36, 20, 8, 5, "oxford_college", "Hertford College")
    bld(z, 47, 20, 8, 5, "oxford_college", show_label=False)
    z.prop("sighs_bridge", 44, 22, variant=3, walk=True)
    # Radcliffe Square, the Bodleian and the Camera
    z.rect(35, 15, 24, 4, ":")
    z.rect(36, 19, 8, 1, ":")
    z.rect(47, 19, 12, 1, ":")
    bld(z, 36, 10, 12, 5, "oxford_college", "Bodleian Library", 6, "oxford_bodleian", iw=15, ih=11)
    bld(z, 50, 10, 7, 7, "radcliffe_camera", "Radcliffe Camera", 3, "oxford_camera", iw=13, ih=10)
    for (x, y) in [(38, 16), (46, 16), (49, 18), (57, 18)]:
        z.prop("lamp_post", x, y)
    z.prop("statue", 48, 14, variant=2)
    # Museum of Natural History and the Pitt Rivers, up Parks Road
    bld(z, 36, 3, 12, 6, "oxford_college", "Museum of Natural History", 6, "oxford_natural", iw=15, ih=11)
    bld(z, 50, 3, 8, 6, "oxford_college", "Pitt Rivers Museum", 4, "oxford_pitt", iw=13, ih=10)
    z.rect(36, 9, 23, 1, ":")
    z.rect(48, 9, 2, 1, ":")
    # ---- the west: the Ashmolean, the Eagle and Child, the Press, the canal
    bld(z, 14, 3, 11, 5, "portico", "Ashmolean Museum", 5, "oxford_ashmolean", iw=15, ih=11)
    z.rect(14, 8, 18, 1, ":")
    bld(z, 24, 10, 7, 4, "tudor", "The Eagle and Child", 3, "oxford_eagle", iw=13, ih=10)
    z.rect(14, 14, 18, 1, ":")
    bld(z, 14, 17, 10, 5, "oxford_college", "Oxford University Press", 5, "oxford_oed", iw=13, ih=10)
    z.rect(14, 22, 18, 1, ":")
    z.rect(2, 24, 21, 2, "~")
    fringe(z)
    for (x, y) in [(6, 24), (14, 25), (21, 24)]:
        z.prop("canal_boat", x, y, rot=0)
    bld(z, 3, 12, 8, 3, "terrace", show_label=False)
    bld(z, 3, 17, 8, 3, "terrace", show_label=False)
    z.rect(3, 15, 9, 1, "#")
    z.rect(3, 20, 9, 1, "#")
    z.rect(12, 14, 2, 1, ":")
    z.rect(12, 20, 2, 1, ":")
    # ---- east of the river: the boathouse, a very odd house with a shark in the roof
    z.rect(66, 33, 1, 11, "#")
    z.rect(66, 43, 5, 1, "#")
    bld(z, 67, 40, 4, 3, "weatherboard", "Magdalen Bridge Boathouse", 1, "oxford_boathouse", iw=11, ih=9)
    bld(z, 67, 36, 4, 3, "terrace", show_label=False)
    for (x, y, r) in [(63, 34, 0), (62, 38, 0), (63, 42, 0), (62, 21, 0), (63, 14, 0)]:
        z.prop("punt", x, y, rot=r)
    for (x, y) in [(10, 52), (22, 52), (44, 52), (52, 52)]:
        z.prop("punt", x, y, rot=0)
    # ---- plaques: the learning
    P = "oxford"
    plaque(z, 33, 28, P, "carfax", "Carfax",
           "Carfax is the crossroads at the centre of Oxford, and its name comes from the Latin quadrifurcus, 'four-forked', for the four roads that meet here. The tower is all that is left of St Martin's church, and climbing its 99 steps gets you the best view over the spires. Its clock has two figures, called quarterboys, that strike the bells on the quarter hour.")
    plaque(z, 40, 19, P, "radcliffe", "The Radcliffe Camera",
           "Built between 1737 and 1749 with money left by John Radcliffe, the royal physician, and designed by James Gibbs. 'Camera' is Latin for a room, and this round, domed one has been a Bodleian reading room since 1860. Its rotunda is one of the most photographed buildings in England, and it is full of people being told to be quiet.")
    plaque(z, 40, 16, P, "bodleian", "The Bodleian Oath",
           "The Bodleian Library, founded in 1602 by Sir Thomas Bodley, receives a copy of every book published in the UK. To read here you must make a declaration, and it is a famous one: not to remove, mark or damage any book, 'nor to bring into the Library or kindle therein any fire or flame, nor to smoke in the Library'. Since 1602, nobody has been caught kindling a fire, or at least nobody will admit it.")
    plaque(z, 45, 18, P, "bridge_of_sighs", "The Bridge of Sighs",
           "Hertford Bridge was built in 1914 to link the old and new parts of Hertford College across New College Lane. It is nicknamed the Bridge of Sighs after the one in Venice, though it looks more like the Rialto, and nobody has been led over it to prison, only to a tutorial. Students say the sighing was at the exam results.")
    plaque(z, 38, 29, P, "tom_tower", "Great Tom",
           "Tom Tower at Christ Church holds Great Tom, a bell weighing over six tonnes. Every night at 9.05 pm it rings 101 times, once for each of the original students of the college, to tell them to be in. Oxford lies about five minutes west of Greenwich, so 9.05 by the clock was nine o'clock by Oxford's own time.")
    plaque(z, 39, 38, P, "alice", "Alice and the Dean's Daughter",
           "Alice Liddell was the daughter of Henry Liddell, Dean of Christ Church, and in 1862 the college mathematics tutor Charles Dodgson, who wrote as Lewis Carroll, rowed her and her sisters up the river and told the story that became Alice's Adventures in Wonderland. The sweet shop across the road from the college is the one in the books, and the Dodo in the story is Dodgson himself, who stammered his own name as 'Do-Do-Dodgson'.")
    plaque(z, 58, 31, P, "magdalen", "May Morning",
           "On 1 May at six in the morning the choir of Magdalen College sings a Latin hymn from the top of the tower, and crowds gather on the bridge and in the street below to hear it, then dance morris and drink at breakfast. Magdalen, by the way, is said 'Maudlin', one of Oxford's many traps for visitors.")
    plaque(z, 52, 40, P, "botanic_garden", "The Botanic Garden",
           "The oldest botanic garden in Britain, founded in 1621 as a physic garden to grow plants for medicine. It stands behind a high wall beside Magdalen Bridge, and its greenhouses hold everything from Amazon water lilies to carnivorous plants. Oxford gives it a few acres for growing things and a great many students for walking past.")
    plaque(z, 26, 38, P, "castle", "Oxford Castle",
           "The Normans built Oxford Castle in 1071, and its tower, St George's, is still standing. In the winter of 1142 the Empress Matilda, besieged here by her cousin Stephen in the war called the Anarchy, escaped across the frozen river in a white cloak to blend in with the snow. Later it was the county prison, until 1996.")
    plaque(z, 66, 35, P, "punting", "Punting",
           "Punts are flat-bottomed boats driven by a long pole pushed against the river bed. In Cambridge the punter stands on the raised flat deck at the back, called the till; in Oxford, the proud tradition is to stand at the sloping end instead. Each city says the other has it backwards, and punters in both occasionally fall in.")
    plaque(z, 66, 38, P, "shark", "The Headington Shark",
           "In 1986 a seven-and-a-half-metre fibreglass shark was fixed headfirst through the roof of an ordinary terraced house in Headington, east Oxford, on the anniversary of the bombing of Nagasaki, as a protest about nuclear war. The council tried to have it removed; the planning inspector decided it could stay, and it has become one of the best-loved sights in the city.")
    plaque(z, 30, 7, P, "ashmolean", "The Ashmolean",
           "The oldest public museum in Britain, opened in 1683, and it began with the collection of the Tradescants, gardeners and travellers, which included a dodo. The dodo rotted in the end and was thrown out, apart from its head and a foot, which went to the Museum of Natural History. Today the Ashmolean's treasures include King Alfred's Jewel, made around 880 AD.")
    plaque(z, 31, 13, P, "inklings", "The Inklings",
           "The Eagle and Child, locally the Bird and Baby, is the pub where the Inklings, an informal group of writers, met in the back room from the 1930s to 1962. Two of them, J. R. R. Tolkien and C. S. Lewis, read chapters of their unfinished books aloud, got criticised by their friends and carried on drinking. The pub still serves a pint to anyone who looks as though they might be writing a book.")
    plaque(z, 24, 22, P, "oed", "The Oxford English Dictionary",
           "The OED began in 1857 and was seventy years in the making. The first editor, James Murray, ran it from a corrugated-iron shed called the Scriptorium in his garden in north Oxford, and thousands of volunteers posted in quotations on paper slips. It records the history of more than 600,000 words, tracing each one back to its first known use.")
    plaque(z, 37, 29, P, "covered_market", "The Covered Market",
           "Opened in 1774 to clear the messy street stalls out of the High Street and Cornmarket, and still going. More than fifty units sell fish, game, cheese, flowers, cakes and the odd pie, in a Georgian arcade that smells of coffee.")
    plaque(z, 24, 29, P, "dreaming_spires", "The City of Dreaming Spires",
           "The poet Matthew Arnold called Oxford 'that sweet city with her dreaming spires' in a poem of 1866. The spires, towers and domes are all different, and the skyline from the hills is a tangle of stone. Oxford has been teaching since about 1096, which makes it the oldest university in the English-speaking world.")
    # trees, benches, lamps
    for (x, y) in [(6, 8), (9, 5), (4, 6), (10, 9), (7, 25), (3, 27), (13, 27), (27, 27), (5, 42), (4, 46), (9, 45), (17, 45), (24, 45), (29, 47), (36, 45), (58, 45), (57, 49), (68, 48), (68, 52), (66, 6), (69, 10), (67, 15), (69, 22), (68, 28)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    for (x, y) in [(31, 31), (37, 31), (47, 31), (54, 31), (22, 31), (16, 31), (33, 12), (33, 40), (33, 20), (31, 45)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(36, 30), (42, 30), (58, 30)]:
        z.prop("bench", x, y)
    z.prop("phone_box", 24, 33)
    z.prop("post_box", 31, 33)
    z.prop("bunting", 45, 30, variant=2, walk=True)
    blob(z, 8, 7, 5, 3, ",", only=".", seed=81, jitter=0.3)
    blob(z, 7, 45, 5, 2, ",", only=".", seed=82, jitter=0.3)
    blob(z, 17, 44, 4, 2, ",", only=".", seed=83, jitter=0.3)
    blob(z, 68, 12, 2, 5, ",", only=".", seed=84, jitter=0.3)
    blob(z, 69, 47, 2, 3, ",", only=".", seed=85, jitter=0.3)
    # ---- people
    story.oxford_cast(z, chat, trainer, _stand)
    z.d["edges"] = {"west": {"to": "cotswolds", "offset": 0}}
    wild(z, [("rooklet", 89, 91, 14, {}), ("starlet", 89, 90, 12, {"time": ["dawn", "day", "dusk"]}), ("binfox", 89, 91, 10, {"time": ["dusk", "night"]}),
             ("pipkin", 89, 90, 12, {}), ("hootlet", 89, 91, 8, {"time": ["night"]}), ("flittermouse", 89, 91, 6, {"time": ["night"]}),
             ("zigzlet", 89, 91, 8, {}), ("cooplet", 89, 90, 10, {}), ("leveret", 89, 90, 8, {"time": ["dawn", "dusk"]}),
             ("bobbin", 89, 90, 6, {}), ("tickhopper", 89, 91, 6, {"time": ["night"]}), ("wispet", 89, 91, 3, {"weather": ["fog"]})])
    wild(z, [("volet", 89, 90, 20, {}), ("holtling", 89, 90, 14, {}), ("dipling", 89, 90, 14, {}), ("stalklet", 89, 91, 12, {}),
             ("elverlet", 89, 91, 12, {"time": ["dusk", "night"]}), ("minkshade", 89, 91, 8, {"time": ["night"]}),
             ("cranelet", 89, 90, 8, {"time": ["dawn"]})], "water")
    z.d["props"] = [p for p in z.d["props"] if p]
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors
    sanctuary(OUT, zid, "Oxford", (17, 38))
    shop(OUT, zid, "Oxford", (38, 38))
    nurse(zid, ["Hello, dear! Welcome to Oxford Sanctuary, which is not part of the University, whatever the hat on the door says. Pop your team on the counter.",
                "Sit down. We've tea, and Oxford marmalade on toast, which I'm told is the right way round.",
                "There we are. Right as rain, and the rain here comes with its own spire.",
                "The Ark is in the corner, by the bookcase. It's been on the waiting list for a book since 1987.",
                "No hurry. Mind the cyclists on the way out; they have the right of way and the right of way knows it."])
    shopkeeper(zid, "Welcome to Alice's Shop, as in the Alice. We do tea, marmalade, Banbury cakes and snares for chasing white rabbits. What'll it be?",
               "Off you go. Oh, and if you hear a clock ticking, you're late.")
    story.oxford_interiors(OUT, zid, landmark)


# ------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    cotswolds()
    oxford()
    story.write(DLG, TRN, scale_trainers)
    write_all(OUT)
