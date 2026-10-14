# plan 5 group A, part 1: mournes (route), antrim_coast (route), causeway (landmark).
from wcommon import *
from wcommon import _stand
import math


def build(OUT):
    mournes(OUT)
    antrim(OUT)
    causeway(OUT)


def mournes(OUT):
    W, H = 66, 56
    z = Z("mournes", "The Mournes", W, H, kind="route", region="ireland", music="route_mountain",
          weather={"fog": 26, "drizzle": 30, "clear": 14, "downpour": 10, "gale": 8, "sunshine": 12})
    z.d["stage"] = "mountain"
    z.legend["g"] = {"tile": "grass", "colour": "#908e82"}                                  # granite grass
    z.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}          # heather (encounters)
    z.border("T", 2, gaps=[(35, 0, 3, 2), (35, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 40, 2, only="T")
    # the massif: Slieve Donard at (51,16), rings of granite stepping up one level at a time
    cx, cy = 51, 16
    for y in range(4, 29):
        for x in range(38, 64):
            d = max(abs(x - cx), abs(y - cy))
            lv = 4 if d <= 2 else 3 if d <= 5 else 2 if d <= 8 else 1 if d <= 11 else 0
            z.hg[y][x] = lv
            if lv >= 2:
                z.set(x, y, "g")
    # heather and tall grass patches
    for (x, y, w, h) in [(18, 4, 8, 6), (22, 14, 7, 5), (4, 28, 8, 7), (20, 42, 10, 6), (40, 36, 3, 14), (5, 42, 9, 8), (28, 28, 4, 5)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(36, 30, 6, 4), (50, 28, 8, 4), (26, 4, 5, 3), (10, 24, 3, 6)]:
        z.rect(x, y, w, h, ",")
    # the Mourne Wall: a drystone ring at the 850 m shoulder, with stiles, and tails that run off over the hills
    for x in range(43, 60):
        z.set(x, 8, "W"); z.set(x, 24, "W")
    for y in range(8, 25):
        z.set(43, y, "W"); z.set(59, y, "W")
    for y in range(25, 35):
        z.set(43, y, "W"); z.set(59, y, "W")
    for x in range(36, 43):
        z.set(x, 8, "W")
    for (gx, gy) in [(50, 8), (51, 8), (50, 24), (51, 24), (43, 16), (43, 17), (59, 16), (59, 17), (43, 30), (43, 31), (59, 30), (59, 31), (39, 8), (40, 8)]:
        z.set(gx, gy, "g" if z.hg[gy][gx] >= 2 else ".")
    # paths: south gap, a switchback up the glen, then north to Belfast; and the summit trail
    path(z, [(35, 54), (35, 38), (14, 38), (14, 24), (35, 24), (35, 0)], "#", 3)
    path(z, [(38, 25), (50, 25), (50, 8)], "#", 2)
    # Spelga reservoir, south-east
    z.rect(44, 38, 18, 14, "w"); z.rect(45, 39, 16, 12, "~")
    # the bog: deep peat in the north-west, gated by Bog-cross, with a dry hollow in the middle
    z.rect(3, 4, 13, 18, "*")
    z.rect(7, 9, 5, 6, ".")
    z.rect(7, 12, 5, 3, "f")
    z.building(8, 9, 3, 2, "slate_cottage", "Peat Cutter's Hut")
    z.prop("bush", 7, 14); z.prop("bush", 11, 14)
    z.rect(14, 22, 3, 2, ".")
    scatter_props(z, "rock", 4, 24, 30, 28, 14, 3, avoid=(".", "h"))
    scatter_props(z, "bush", 4, 24, 28, 30, 14, 4, avoid=(".",))
    scatter_props(z, "rock", 40, 5, 22, 22, 14, 9, avoid=("g",))
    scatter_props(z, "pine", 4, 40, 30, 12, 8, 5, avoid=(".",))
    # signs
    z.sign(34, 52, "THE MOURNES. Twelve granite peaks that sweep down to the sea, which is an actual line from a song. Percy French wrote it in 1896. He was an engineer by day and a songwriter by whim.")
    z.sign(34, 37, "THE BRANDY PAD. A smugglers' trail across the Mournes, used in the 1700s to carry tea, tobacco and brandy from the coast, past a taxman who never fancied the climb. Today it is mostly walkers carrying sandwiches.")
    z.sign(49, 27, "THE MOURNE WALL. 35 km of drystone wall, built between 1904 and 1922, climbing over 15 summits without a drop of mortar. It was built to keep sheep and cattle out of the reservoir catchment. The sheep have views on this.")
    z.sign(51, 16, "SLIEVE DONARD. 850 metres, and the highest peak in Northern Ireland. On a clear day you can see Wales, Scotland and the Isle of Man. On most days you can see your own boots.")
    z.sign(43, 40, "SPELGA. A reservoir behind a dam, in the high Mournes. The water is very clear and very cold. Swimming is not recommended, and neither are opinions on whether it is a lake.")
    z.sign(13, 23, "BOG. The brown bit ahead is deep peat. Without proper know-how the ground simply swallows your boot and keeps it. Bog-cross is the old art of walking on it. Come back with the knack.")
    z.sign(11, 13, "THE HOLLOW. Peat takes a thousand years to grow a metre. Nobody here is in a hurry. The bog has all day, and all next year.")
    # sheep
    for i, (x, y) in enumerate([(30, 33), (28, 34), (24, 46), (46, 31), (33, 8), (20, 10), (18, 27), (56, 31)]):
        _stand(z, x, y)
        z.npc(id="sheep_%d" % i, sprite="creature:loaghtan", x=x, y=y, facing="down", move="wander", script="sheep")
    script("mournes", "sheep", say("Loaghtan", "It chews, looks up, and regards you with deep sheep wisdom, which on closer inspection is a blank. A good blank. Very well maintained."))
    chat(z, "wall_mender", "villager_3", 47, 28, "Wall Mender",
         ["Mind your elbows, I'm mending the wall. A drystone wall is held up by weight and gravity and nothing else. Same as me.",
          "The Mourne Wall took 18 years and about 200 men to build. They'd stop for the weather, I'm told, and then get on with the weather anyway."], "right", "still")
    chat(z, "shepherd", "farmer", 31, 30, "Shepherd",
         ["The sheep up here know where every gap in the wall is. We have a gentleman's agreement: they stay in, and I don't ask how.",
          "A lamb's got more sense than a dog on a bad day. Don't tell the dog."], "down", "wander")
    chat(z, "peat_cutter", "villager_6", 9, 12, "Peat Cutter",
         ["Well now! Nobody comes in here without wading. Have a sit. The kettle's on, and so, I'm told, is the fog.",
          "My granda cut peat on this very bog for the fire. These days we leave it wet to keep the carbon in. Same peat, newer manners."], "down", "still")
    chat(z, "mourne_rambler", "villager_4", 24, 41, "Rambler",
         ["I'm walking the whole of the Wall in a day. I'm on hour six. I'm on tile number... Look, there's a lot of wall.",
          "The trick is snacks. Soda farl, a flask, and a heart full of denial."], "right", "wander")
    trainer(z, "mo_hiker1", "Hiker Oisin", "Hiker", "hiker", [("billgruff", 62), ("cragchough", 61), ("stagmor", 62)],
            30, 36, "down", ["Ho! A fellow walker! Mind you, nobody's a fellow walker till they've been to the top.", "I've done Donard eleven times. Twelve is when I finally learn the way."],
            "Fair play. The legs are good. The boots are better.", "The summit's up the trail east of here. Wrap up, it blows a hooley.", 1900)
    trainer(z, "mo_hiker2", "Hiker Aoife", "Hiker", "hiker", [("gealhare", 62), ("peatmonarch", 62), ("flaxling", 63)],
            48, 26, "right", ["The Wall's looking grand today. I'm looking for a gap in it. Not for climbing, for my sandwiches. They rolled."],
            "You've steadier feet than my sandwich.", "There are stiles every so often. They're called stiles because you need style.", 1950)
    trainer(z, "mo_birder", "Birdwatcher Brigid", "Birdwatcher", "birdwatcher", [("cragchough", 62), ("forkwing", 62), ("kitelet", 61)],
            19, 30, "left", ["Shh! A peregrine falcon nests on the crags above Slieve Binnian. If I don't see it today I'll be unbearable."],
            "A fair fight, and I didn't even miss the falcon. Mostly.", "The peregrine drops at over 300 kilometres an hour. It's the fastest animal on Earth. I can barely get the lid off my flask.", 1850)
    trainer(z, "mo_angler", "Angler Fergal", "Angler", "angler", [("bradan", 62), ("rillotter", 62), ("holtling", 61)],
            39, 46, "left", ["The trout in Spelga are coy and cold. Like me, early in the morning. Fancy a go at the reeds?"],
            "I'd have caught you in a lake, I'm sure of it.", "The trick with a trout is patience. And tea. Mostly tea.", 1800)
    trainer(z, "mo_warden", "Warden Quentin", "Warden", "warden_grunt", [("snowhare", 63), ("tormane", 63), ("sikawhistle", 62)],
            32, 14, "right", ["Halt! This glen has been pre-curated for your enjoyment. No bog, no rambling, and certainly no mess. We've labelled the heather."],
            "Hmph. Unauthorised curation. I shall file a form.", "The Enclosure says views must be booked in advance. The mountain did not respond to the email.", 2000)
    z.d["edges"] = {"south": {"to": "boyne_valley", "offset": 0}, "north": {"to": "belfast", "offset": 0}}
    z.d["spawn"] = [36, 50]
    wild(z, [("flaxling", 61, 63, 18, {}), ("billgruff", 62, 63, 10, {}), ("stagmor", 62, 63, 10, {"time": ["dawn", "dusk"]}),
             ("gealhare", 61, 63, 12, {"time": ["day", "dawn"]}), ("cragchough", 62, 63, 10, {}), ("snowhare", 61, 63, 8, {"weather": ["fog", "frost"]}),
             ("peatmonarch", 62, 63, 8, {}), ("hootlet", 61, 62, 8, {"time": ["night"]}), ("flittermouse", 61, 62, 8, {"time": ["night", "dusk"]}),
             ("forkwing", 62, 63, 6, {"weather": ["gale", "sunshine"]})])
    z.save(OUT + "/mournes.json")


def antrim(OUT):
    W, H = 64, 44
    z = Z("antrim_coast", "Antrim Coast", W, H, kind="route", region="ireland", music="route_coast",
          weather={"drizzle": 28, "clear": 20, "fog": 10, "gale": 14, "sunshine": 22, "downpour": 6})
    z.d["stage"] = "coast"
    z.border("T", 2, gaps=[(30, 0, 3, 2), (30, 42, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 6, only="T")
    # the sea, with sea cliffs along the shore
    z.rect(53, 0, 11, H, "$")
    for y in range(2, H - 2):
        z.set(52, y, "^")
    # glen hills in the west
    for y in range(3, 24):
        for x in range(3, 27):
            d = max(abs(x - 14) * 1.0, abs(y - 12) * 1.4)
            z.hg[y][x] = 3 if d <= 4 else 2 if d <= 7 else 1 if d <= 10 else 0
    # patches
    for (x, y, w, h) in [(34, 36, 14, 4), (4, 28, 5, 5), (22, 6, 6, 4), (36, 15, 5, 4), (20, 36, 7, 5), (6, 6, 3, 8), (22, 24, 6, 3)]:
        z.rect(x, y, w, h, ",")
    for (x, y, w, h) in [(38, 24, 4, 3), (4, 36, 6, 4), (36, 8, 3, 5)]:
        z.rect(x, y, w, h, "f")
    # the headland, the island and the rope bridge (a narrow platform walkway over the sea)
    z.rect(57, 6, 5, 9, ".")
    # roads: the coast road north-south, a branch east to the rope bridge, a branch west into the glen
    path(z, [(30, 43), (30, 0)], "#", 3)
    path(z, [(30, 22), (44, 22), (44, 10), (50, 10)], "#", 2)
    path(z, [(30, 31), (18, 31), (18, 12)], "#", 2)
    z.rect(50, 10, 2, 1, "#")
    z.rect(52, 10, 5, 1, "_")
    # the stream in the glen, with a deep pool
    z.rect(10, 4, 1, 28, "~")
    z.rect(9, 18, 3, 4, "o")
    # the Dark Hedges: an avenue of beech trees beside a lane
    z.rect(33, 30, 19, 3, "#")
    for x in range(34, 52, 2):
        z.prop("oak", x, 29, variant=x % 3); z.prop("oak", x, 33, variant=(x + 1) % 3)
    scatter_props(z, "oak", 3, 20, 26, 20, 22, 7, avoid=(".",))
    scatter_props(z, "bush", 3, 3, 49, 38, 22, 8, avoid=(".",))
    scatter_props(z, "rock", 36, 6, 15, 16, 8, 9, avoid=(".",))
    scatter_props(z, "pine", 4, 3, 26, 28, 10, 10, avoid=(".",))
    # headland buildings
    z.building(40, 11, 3, 3, "slate_cottage", "Rope Bridge Ticket Hut")
    z.prop("bench", 47, 12); z.prop("lamp_post", 46, 8); z.prop("bollard", 50, 9); z.prop("bollard", 50, 12)
    z.sign(49, 8, "CARRICK-A-REDE. The name means 'rock in the road', because salmon swimming past had to dodge it. Fishermen have strung a rope bridge to the island for over 250 years. The current one is 20 metres long and 30 metres above the sea. Don't look down. Look at the gulls. They look down for you.")
    z.sign(29, 40, "THE CAUSEWAY COASTAL ROUTE. Nine glens, a rope bridge, a lane of beech trees, and some of the best views in the islands. Take your time. The sea is not going anywhere.")
    z.sign(35, 28, "THE DARK HEDGES. Beech trees planted in the 1700s by the Stuart family to impress their visitors. Two hundred years later they impress everyone else. The branches meet overhead like a tunnel, and the road is rather moody.")
    z.sign(17, 29, "GLENARIFF. One of the nine Glens of Antrim, nicknamed the Queen of the Glens. There are waterfalls, ferns and paths that were built by walkers who would have preferred a shorter route.")
    z.sign(60, 8, "ISLAND LOOKOUT. The cliffs here are chalk topped with basalt, and the birds know it. Fulmars, kittiwakes and a very unimpressed raven.")
    # NPCs and trainers
    chat(z, "ticket_ranger", "tour_guide", 47, 10, "Ticket Ranger",
         ["Single file on the bridge, please! It sways. The bridge isn't scared. It's just very relaxed about the whole thing.",
          "Fishermen built the first bridge to get to the salmon nets on the island. They'd haul the catch back across it with a rope and an attitude."], "right", "still")
    chat(z, "glen_walker", "villager_2", 22, 29, "Glen Walker",
         ["Nine glens in Antrim, and each has its own mood. This one's 'damp but proud'.",
          "You can see Scotland from the coast on a clear day. I have never seen a clear day, but I'm told it's there."], "down", "wander")
    chat(z, "lane_painter", "villager_5", 40, 31, "Lane Painter",
         ["I paint the Dark Hedges every year, and every year the trees have rearranged themselves.",
          "In autumn the leaves go gold and everyone takes a photo. In winter they take the same photo, only greyer. I like both."], "down", "wander")
    chat(z, "coast_cyclist", "jogger", 28, 37, "Cyclist",
         ["I'm following the Coastal Route on two wheels. Eighty kilometres of lovely scenery, and eleven of them are straight uphill into the wind.",
          "Don't tell the sea, but I prefer the road."], "right", "wander")
    for i, (x, y) in enumerate([(24, 38), (43, 36), (28, 14)]):
        _stand(z, x, y)
        z.npc(id="gull_%d" % i, sprite="creature:chipgull", x=x, y=y, facing="down", move="wander", script="gull")
    script("antrim_coast", "gull", say("Chipgull", "It stares at your lunch with the focus of a bank manager. You pretend not to notice. It knows."))
    trainer(z, "ant_hiker", "Hiker Cathal", "Hiker", "hiker", [("billgruff", 64), ("stagmor", 65), ("cragchough", 64)],
            26, 31, "right", ["Grand walking weather! I say that every day. It's rained on four of them."],
            "Good stride. You'll do the coast.", "It's six hours round the glen if you stop for photographs, and I always stop for photographs.", 2100)
    trainer(z, "ant_birder", "Birdwatcher Maeve", "Birdwatcher", "birdwatcher", [("clownbill", 65), ("plungebeak", 64), ("polartern", 65)],
            60, 10, "left", ["You crossed the rope bridge! Right, now you must cross it back, and I've got the only exit. Nothing personal."],
            "Well flown. The puffins will be pleased for you.", "Puffins come back to the same burrow every year. Reliable birds. They'd make good tenants.", 2150)
    trainer(z, "ant_angler", "Angler Rory", "Angler", "angler", [("heronarch", 65), ("bradan", 64), ("severnshock", 64)],
            14, 20, "right", ["The pool by the stream, the one with the deep bit? Salmon, sometimes. Today it's mostly my reflection."],
            "My line's tangled and so is my pride. Well fought.", "A salmon can leap a waterfall. I can barely leap a puddle.", 2050)
    trainer(z, "ant_warden", "Warden Ivo", "Warden", "warden_grunt", [("sootwing", 65), ("pooka", 65), ("raidtail", 64)],
            28, 11, "right", ["Stop. This stretch of coastline has been optimised. We've straightened the cliffs. They were looking unprofessional."],
            "Cliffs, I apologise on behalf of the management.", "The Enclosure would like to rent the sea. They've made the sea an offer.", 2200)
    trainer(z, "ant_student", "Student Orla", "Student", "student", [("hazeldoze", 64), ("pinewraith", 65), ("redbreast", 64)],
            38, 21, "down", ["I'm writing a thesis on coastal erosion. The coast is writing a rebuttal. It's winning."],
            "I'll update my references. You've changed my argument.", "Basalt is volcanic rock. The cliffs here are what's left of lava that cooled sixty million years ago. I'm saying it's old, not that it's boring.", 2100)
    z.d["edges"] = {"south": {"to": "belfast", "offset": 0}, "north": {"to": "causeway", "offset": 0}}
    z.d["spawn"] = [31, 40]
    wild(z, [("plungebeak", 64, 66, 12, {}), ("clownbill", 64, 66, 10, {"time": ["day", "dawn"]}), ("cragchough", 64, 66, 12, {}),
             ("forkwing", 64, 66, 8, {}), ("stagmor", 65, 66, 8, {"time": ["dawn", "dusk"]}), ("dextera", 64, 65, 10, {}),
             ("pooka", 65, 66, 8, {"time": ["night"]}), ("redbreast", 64, 65, 10, {}), ("polartern", 65, 66, 6, {"weather": ["frost", "fog"]}),
             ("rookery", 64, 66, 8, {}), ("bansheen", 65, 66, 5, {"weather": ["fog", "drizzle"]}), ("hootlet", 64, 65, 6, {"time": ["night"]})])
    wild(z, [("bradan", 64, 66, 25, {}), ("parrlet", 64, 65, 20, {}), ("rillotter", 64, 66, 15, {}), ("heronarch", 65, 66, 10, {}),
             ("dipling", 64, 65, 20, {}), ("elverlet", 64, 65, 10, {"weather": ["drizzle", "downpour"]})], "water")
    z.save(OUT + "/antrim_coast.json")


def relax(hg, fixed):
    """make neighbouring heights differ by at most one: lower a tall cell, or raise a cell beside a fixed one."""
    for _ in range(40):
        changed = False
        for (x, y) in list(hg):
            if (x, y) in fixed:
                continue
            v = hg[(x, y)]
            for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = hg.get((x + dx, y + dy))
                if n is None:
                    continue
                if v > n + 1 and (x + dx, y + dy) not in fixed:
                    v = n + 1; changed = True
                elif v > n + 1:
                    v = n + 1; changed = True
                elif v < n - 1 and (x + dx, y + dy) in fixed:
                    v = n - 1; changed = True
            hg[(x, y)] = v
        if not changed:
            break


def causeway(OUT):
    import random
    W, H = 64, 40
    z = Z("causeway", "Giant's Causeway", W, H, kind="route", region="ireland", music="route_coast",
          weather={"drizzle": 22, "clear": 22, "fog": 8, "gale": 14, "sunshine": 28, "downpour": 6})
    z.d["stage"] = "coast"
    z.legend["b"] = {"tile": "cobbles", "colour": "#43464e"}                                 # basalt column top
    z.legend["c"] = {"tile": "tall_grass", "colour": "#555961", "prop": "none"}              # basalt, wild encounters
    z.legend["d"] = {"tile": "cobbles", "colour": "#34363e"}
    z.border("T", 2, gaps=[(30, 38, 3, 2), (0, 18, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 4, only="T")
    z.rect(0, 0, W, 6, "$")
    z.rect(52, 0, 12, H, "$")
    z.rect(44, 28, 12, 12, "$")
    # the plateau stands at level 3; cliffs face the sea
    z.height(0, 6, 52, 34, 3)
    z.rect(0, 5, 36, 1, "^")
    z.rect(0, 6, 36, 1, "^")
    # the columns: 2x2 blocks on staggered rows, stepping down east into the sea
    r = random.Random(61)
    x0, x1, y0, y1 = 36, 52, 7, 27
    key = {}
    for y in range(y0, y1):
        for x in range(x0, x1):
            key[(x, y)] = ((x - x0 + (1 if ((y - y0) // 2) % 2 else 0)) // 2, (y - y0) // 2)
    hv = {}
    for k in set(key.values()):
        lvl = 3 - (k[0] * 2) // 4
        hv[k] = max(0, min(3, lvl + r.choice([0, 0, 1, -1])))
    hg = {p: hv[k] for p, k in key.items()}
    fixed = set()
    for y in range(y0, y1):
        hg[(x0 - 1, y)] = 3; fixed.add((x0 - 1, y))
    for x in range(x0 - 1, 44):
        hg[(x, y1)] = 3; fixed.add((x, y1))
    for x in range(x0, x1):
        hg[(x, y0 - 1)] = 3; fixed.add((x, y0 - 1))      # the cliff row above (not walkable) is ignored below
    # the Grand Causeway finger and the sea stack, fixed so the field settles around them
    finger = {}
    for x in range(48, 56):
        for y in (13, 14):
            finger[(x, y)] = 1 if x < 52 else 0
    for x in range(56, 59):
        for y in range(12, 16):
            finger[(x, y)] = 1 if x == 56 else 2
    for p, v in finger.items():
        hg[p] = v; fixed.add(p)
    for x in range(x0, x1):
        fixed.discard((x, y0 - 1)); hg.pop((x, y0 - 1), None)
    relax(hg, fixed)
    for (x, y), v in hg.items():
        if (x, y) in fixed and (x, y) not in finger:
            continue
        z.hg[y][x] = v
        if (x, y) in finger:
            z.set(x, y, "b" if (x + y) % 2 else "d")
        else:
            k = key[(x, y)]
            z.set(x, y, "c" if (k[0] * 7 + k[1] * 3) % 5 in (0, 2) else ("b" if (k[0] + k[1]) % 2 else "d"))
    for y in range(y0, y1):
        for x in range(x0, x1):
            if (x, y) not in finger and z.hg[y][x] == 0 and x > 49:
                z.set(x, y, "$")
    for (x, y) in [(59, 12), (59, 15), (57, 11), (57, 16), (55, 12), (55, 15)]:
        z.set(x, y, "R")
    # paths: the road from Bushmills (west), the lane from Antrim (south)
    z.rect(2, 18, 30, 3, "#")
    path(z, [(30, 39), (30, 24), (39, 24)], "#", 3)
    path(z, [(18, 31), (30, 31)], "#", 3)
    path(z, [(30, 18), (30, 24)], "#", 3)
    # visitor centre, and Vane's marquee on the cove side
    z.building(14, 26, 12, 5, "white_render", "Visitor Centre", door=6)
    z.building(36, 29, 6, 3, "white_render", "Vane Estates Marquee")
    z.rect(20, 31, 1, 1, "#")
    for (x, y, w, h) in [(4, 8, 12, 5), (18, 8, 12, 4), (4, 22, 8, 4), (6, 34, 14, 3), (36, 34, 6, 3)]:
        z.rect(x, y, w, h, ",")
    for (x, y, w, h) in [(18, 12, 12, 3), (4, 14, 6, 3), (22, 22, 7, 3)]:
        z.rect(x, y, w, h, "f")
    scatter_props(z, "rock", 2, 8, 33, 29, 14, 3, avoid=(".",))
    scatter_props(z, "bush", 2, 8, 33, 29, 16, 5, avoid=(".",))
    for (x, y) in [(23, 33), (27, 33), (17, 24), (35, 22)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 29, 28); z.prop("bench", 34, 26); z.prop("planter", 13, 31); z.prop("planter", 26, 31)
    z.prop("buoy", 48, 34, variant=0); z.prop("boat", 50, 31, variant=1)
    # signs
    z.sign(29, 36, "THE GIANT'S CAUSEWAY. About 40,000 columns of basalt, most of them hexagons, formed some 60 million years ago when lava cooled and cracked. A UNESCO World Heritage Site since 1986. The columns don't care. They just stand about in a row, looking geometric.")
    z.sign(34, 16, "FIONN AND BENANDONNER. The legend says the giant Fionn mac Cumhaill built the causeway to reach Scotland and fight a rival giant, Benandonner. Seeing how big Benandonner was, Fionn's wife dressed him as a baby. The rival fled. It's the best argument for sensible shoes I know.")
    z.sign(36, 22, "THE WISHING CHAIR. A natural seat of columns, said to grant a wish to anyone who sits on it. Don't wish for dry weather. It has a hard time with those.")
    z.sign(46, 16, "THE GRAND CAUSEWAY. The columns step down into the sea and carry on under the waves. On a calm day it feels like the beginning of a road somewhere. People have been following it for thousands of years.")
    z.sign(20, 16, "THE COASTAL PATH. West to Bushmills, a few miles by foot and a few minutes by train. The path is level. The weather is not.")
    # NPCs
    chat(z, "centre_guide", "tour_guide", 23, 35, "Visitor Centre Guide",
         ["Welcome to the Causeway! Most of the columns have six sides. Some have four, five, seven, even eight. There are no sides on the sea. We've checked.",
          "The tallest columns are about 12 metres high. They're basalt, so they won't be moved. Visitors, on the other hand, move quite a lot."], "down", "still")
    chat(z, "geologist", "student", 34, 12, "Geology Student",
         ["Sixty million years ago this was lava. Now it's a staircase. If that doesn't make you feel small, I'll draw you a diagram.",
          "The columns formed as the lava cooled and shrank. It cracked in a regular pattern, like drying mud. The hexagon wins because it uses the least crack for the most room."], "right", "still")
    chat(z, "visitor", "villager_4", 40, 35, "Visitor",
         ["I wished on the Wishing Chair. I wished for a cup of tea. I got a coach party, but the tea followed.",
          "Everyone talks about Fionn. Nobody asks about his wife, who was the cleverest person in the legend. She baked a griddle into a loaf and fed it to the rival."], "left", "wander")
    chat(z, "local_man", "villager_6", 27, 24, "Local",
         ["I've lived beside the Causeway sixty years. The rocks haven't changed. I have.",
          "They say a pony the colour of sea foam gallops the waves off here in the mist. Manannan's horse, the old ones called it. Mind you, the old ones also said the tide could be bribed."], "right", "wander")
    # story placeholders
    z.npc(id="enbarr_spot", sprite="creature:enbarr", x=57, y=13, facing="left", move="still", script="enbarr", hide_if="caught_enbarr")
    script("causeway", "enbarr", say("Manannan's Horse", "Placeholder: the story agent writes the Enbarr encounter here."))
    z.npc(id="vane_causeway", sprite="vane", x=38, y=33, facing="up", move="still", script="vane_causeway")
    script("causeway", "vane_causeway", say("Lord Vane", "Placeholder: the story agent writes Lord Vane's marquee scene here."))
    trainer(z, "cw_birder", "Birdwatcher Tadhg", "Birdwatcher", "birdwatcher", [("polartern", 66), ("clownbill", 66), ("plungebeak", 66)],
            24, 22, "up", ["Fulmars! Look, a fulmar! Don't look at it, it'll spit. It's the single worst defence in birds."],
            "Splendid. I'll note it in my logbook as a minor spectacle.", "A fulmar can spit oil at attackers up to a metre away. It's a bird with a water pistol and a personality.", 2250)
    trainer(z, "cw_warden", "Warden Percival", "Warden", "warden_grunt", [("sootwing", 66), ("raidtail", 66), ("gritling", 66)],
            28, 22, "right", ["Stop right there. The Causeway is being repositioned. We're making the columns more... uniform. Fewer dents."],
            "I'll tell management the stones resisted my tender.", "The Enclosure wants to put a gift shop on every column. The stones have politely declined.", 2300)
    trainer(z, "cw_hiker", "Hiker Sorcha", "Hiker", "hiker", [("billgruff", 66), ("stagmor", 66), ("basaltling", 66)],
            12, 17, "down", ["Welcome to the cliff path. It's all level, and yet I'm out of breath. That's the sea air. Or my age."],
            "Fine boots. Stout heart. Come and join the walk.", "Past the next headland is a ruin. Dunluce Castle. Part of its kitchen fell into the sea in 1639. Terrible for the cook.", 2200)
    z.d["edges"] = {"south": {"to": "antrim_coast", "offset": 0}, "west": {"to": "bushmills", "offset": 0}}
    z.d["spawn"] = [31, 36]
    wild(z, [("basaltling", 65, 67, 20, {}), ("fionnling", 65, 67, 14, {}), ("plungebeak", 65, 66, 10, {}), ("clownbill", 65, 66, 10, {"time": ["day", "dawn"]}),
             ("cragchough", 65, 67, 10, {}), ("petrelash", 65, 67, 10, {"weather": ["gale", "downpour"]}), ("clawcastle", 65, 67, 8, {}),
             ("selkie", 66, 67, 6, {"time": ["dusk", "night"]}), ("polartern", 65, 66, 8, {"weather": ["frost", "fog"]}),
             ("bayrunner", 65, 67, 8, {"time": ["day"]}), ("merrow", 66, 67, 4, {"time": ["dusk"]})])
    z.save(OUT + "/causeway.json")
