import sys; sys.path.insert(0, sys.argv[1]); from zlib import Z
OUT = sys.argv[2]
# ---------------- Macclesfield Forest ----------------
f = Z("macc_forest", "Macclesfield Forest", 62, 36, kind="route", music="route_forest",
      weather={"drizzle": 45, "clear": 25, "fog": 20, "sunshine": 10})
f.border("P", 3, gaps=[(0, 18, 3, 3), (59, 9, 3, 3)])
f.scatter(3, 3, 56, 30, "P", 260, 11)
f.scatter(0, 0, 62, 36, "T", 70, 12, only="P")
# winding track west -> east
for (x, y, w, h) in [(0, 19, 14, 1), (13, 13, 1, 7), (13, 13, 16, 1), (28, 13, 1, 12), (28, 24, 18, 1), (45, 10, 1, 15), (45, 10, 17, 1)]:
    f.rect(x, y, w, h, "#")
# Trentabank reservoir
f.rect(17, 17, 10, 6, "~"); f.rect(17, 23, 10, 1, "w"); f.rect(16, 17, 1, 6, "s"); f.rect(27, 17, 1, 6, "s")
f.legend["r"] = {"tile": "shallow", "prop": "reeds"}
f.rect(18, 16, 8, 1, "r")
# clearings of tall grass
for (x, y, w, h) in [(5, 21, 7, 5), (16, 7, 9, 5), (31, 16, 9, 6), (36, 27, 8, 4), (48, 14, 8, 6), (50, 25, 6, 5)]:
    f.rect(x, y, w, h, ",")
f.rect(3, 15, 8, 3, "."); f.rect(31, 4, 10, 6, ".")
f.legend["b"] = {"tile": "tree_oak", "prop": "birch"}
f.scatter(30, 3, 12, 8, "b", 12, 5, only=".")
f.sign(12, 18, "MACCLESFIELD FOREST. Mind the pines. Mind the herons. Mostly mind the herons.")
f.sign(44, 11, "EAST: Cat and Fiddle road. Moorland ahead. Weather: yes.")
f.sign(16, 12, "TRENTABANK HERONRY. Please do not argue with the herons.")
f.d["encounters"] = {"grass": [
    {"species": "scuttlet", "min": 3, "max": 5, "weight": 30, "time": ["dawn", "day", "dusk"]},
    {"species": "pipkin", "min": 3, "max": 5, "weight": 25, "time": ["dawn", "day"]},
    {"species": "hootlet", "min": 4, "max": 6, "weight": 20, "time": ["dusk", "night"]},
    {"species": "dipling", "min": 4, "max": 6, "weight": 12},
    {"species": "croakle", "min": 3, "max": 5, "weight": 10, "weather": ["drizzle", "downpour"]},
    {"species": "binfox", "min": 4, "max": 6, "weight": 10, "time": ["dusk", "night"]},
    {"species": "wispet", "min": 5, "max": 7, "weight": 10, "weather": ["fog"]}]}
f.d["edges"] = {"west": {"to": "macclesfield", "offset": 0}, "east": {"to": "cat_and_fiddle", "offset": 0}}
f.d["spawn"] = [4, 19]
f.save(OUT + "/macc_forest.json")

# ---------------- Cat and Fiddle road (moor) ----------------
m = Z("cat_and_fiddle", "Cat and Fiddle Road", 66, 32, kind="route", region="peak", music="route_moor",
      weather={"fog": 30, "drizzle": 30, "clear": 20, "gale": 12, "sunshine": 8})
m.legend["m"] = {"tile": "grass", "colour": "#7d7a45"}
m.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}
m.legend["k"] = {"tile": "tall_grass", "colour": "#7a7444", "prop": "none"}
m.rect(0, 0, 66, 32, "m")
m.border("R", 2, gaps=[(0, 9, 2, 3), (64, 20, 2, 3)])
m.scatter(0, 0, 66, 32, "m", 60, 21, only="R")
# moor rises towards the middle
m.height(10, 3, 46, 26, 1); m.height(20, 6, 26, 18, 2)
# the A537, winding up and over
for (x, y, w, h) in [(0, 10, 12, 1), (11, 10, 1, 5), (11, 14, 12, 1), (22, 14, 1, 1), (22, 14, 22, 1), (43, 14, 1, 8), (43, 21, 23, 1)]:
    m.rect(x, y, w, h, "=")
for (x, y, w, h) in [(4, 4, 7, 4), (14, 18, 9, 6), (25, 7, 10, 5), (30, 18, 10, 7), (47, 5, 9, 7), (52, 24, 8, 5)]:
    m.rect(x, y, w, h, "h")
for (x, y, w, h) in [(5, 22, 6, 5), (38, 4, 5, 5), (56, 13, 5, 5)]:
    m.rect(x, y, w, h, "k")
for (x, y, w, h) in [(2, 13, 9, 1), (13, 16, 1, 8), (24, 16, 18, 1), (45, 16, 1, 4), (36, 9, 1, 4), (47, 23, 12, 1)]:
    m.rect(x, y, w, h, "W")
m.rect(45, 16, 1, 1, "W")
m.scatter(12, 4, 44, 24, "R", 30, 31, only="m")
m.rect(26, 20, 3, 2, "w"); m.rect(48, 9, 2, 2, "w")
m.building(31, 10, 7, 3, "gritstone", "Cat and Fiddle", door=None)
m.prop("bench", 30, 13); m.prop("sign", 0, 0) if False else None
m.sign(29, 13, "THE CAT AND FIDDLE. Second highest pub in England. Closed for refurbishment, open for weather.")
m.sign(3, 9, "A537. Exposed moorland road. Fog likely. Herons unlikely.")
m.sign(60, 20, "BUXTON 1 mile. Spa town. Hot water, cold wind.")
m.d["encounters"] = {"grass": [
    {"species": "scuttlet", "min": 6, "max": 8, "weight": 18},
    {"species": "roachroo", "min": 7, "max": 9, "weight": 14, "time": ["dawn", "day", "dusk"]},
    {"species": "snowhare", "min": 7, "max": 9, "weight": 16},
    {"species": "gritling", "min": 7, "max": 10, "weight": 12},
    {"species": "croakle", "min": 6, "max": 8, "weight": 8, "weather": ["drizzle", "downpour", "fog"]},
    {"species": "hootlet", "min": 7, "max": 9, "weight": 12, "time": ["dusk", "night"]},
    {"species": "wispet", "min": 8, "max": 10, "weight": 16, "weather": ["fog"]},
    {"species": "pipkin", "min": 6, "max": 8, "weight": 6, "time": ["day"]}]}
m.d["edges"] = {"west": {"to": "macc_forest", "offset": 0}, "east": {"to": "buxton", "offset": 0}}
m.d["spawn"] = [3, 10]
m.save(OUT + "/cat_and_fiddle.json")

# ---------------- Buxton ----------------
b = Z("buxton", "Buxton", 56, 40, music="town_cheshire", region="peak",
      weather={"drizzle": 40, "clear": 35, "fog": 10, "sunshine": 15})
b.border("T", 3, gaps=[(0, 20, 3, 3)])
b.scatter(0, 0, 56, 40, "P", 40, 41, only="T")
b.rect(0, 21, 50, 1, "="); b.rect(3, 20, 47, 1, ":"); b.rect(3, 22, 47, 1, ":")
b.rect(49, 8, 1, 14, "="); b.rect(48, 8, 1, 13, ":")
# the Crescent and St Ann's Well
b.building(12, 6, 16, 4, "stone", "The Crescent")
b.rect(11, 10, 18, 2, ":")
b.building(30, 8, 3, 2, "stone", "St Ann's Well", show_label=True)
b.sign(29, 11, "ST ANN'S WELL. Warm spring water, 28 degrees, all year. Fill a bottle, everyone does.")
# Pavilion Gardens
b.rect(4, 25, 26, 11, "."); b.rect(10, 28, 9, 4, "~"); b.rect(10, 27, 9, 1, "s"); b.rect(10, 32, 9, 1, "s")
b.rect(4, 24, 26, 1, "#"); b.rect(20, 24, 1, 12, "#")
b.rect(22, 27, 6, 3, "f"); b.rect(5, 33, 4, 2, "f")
for (x, y) in [(5, 26), (8, 34), (24, 32), (27, 34), (21, 26)]: b.prop("oak", x, y, variant=(x+y) % 3)
b.prop("bench", 15, 26); b.prop("bench", 24, 26)
b.sign(19, 23, "PAVILION GARDENS. Ducks have right of way.")
# Sanctuary, shop, spa
b.building(34, 13, 6, 4, "sanctuary", "Sanctuary", door=3)
b.building(41, 14, 5, 3, "shop", "Corner Shop", door=2)
b.building(32, 26, 10, 5, "cream_render", "Buxton Spa", door=5)
b.rect(36, 31, 2, 1, "#"); b.rect(36, 23, 2, 3, "#"); b.rect(37, 31, 1, 0, "#")
b.building(4, 13, 5, 3, "stone", show_label=False); b.building(4, 7, 5, 3, "stone", show_label=False)
b.building(44, 26, 5, 4, "stone", "Opera House")
for x in (8, 16, 24, 32, 40): b.prop("lamp_post", x, 19)
b.prop("planter", 30, 12); b.prop("phone_box", 33, 18); b.prop("post_box", 40, 18)
b.scatter(10, 12, 20, 7, "T", 9, 51)
b.scatter(30, 32, 18, 6, "T", 10, 52)
b.rect(12, 13, 16, 1, "f"); b.rect(3, 4, 30, 1, "H")
b.building(3, 26, 0, 0, "stone") if False else None
b.building(41, 3, 6, 4, "red_brick", show_label=False); b.building(34, 3, 5, 4, "cream_render", show_label=False)
b.prop("market_stall", 22, 19, variant=1); b.prop("bench", 12, 19)
b.sign(4, 19, "BUXTON. Welcome to the highest market town in England. Probably. Wrap up.")
b.warp(37, 16, "buxton_sanctuary", 5, 6, "up"); b.warp(43, 16, "buxton_shop", 4, 5, "up")
b.warp(37, 30, "buxton_spa", 7, 12, "up")
b.d["edges"] = {"west": {"to": "cat_and_fiddle", "offset": 0}}
b.d["spawn"] = [4, 21]
b.save(OUT + "/buxton.json")

def interior(zid, name, w, h, door_x, out_zone, ox, oy, counters=(), music="town_cheshire"):
    r = Z(zid, name, w, h, fill="|", kind="interior", music=music, weather={})
    r.border("x", 1)
    r.set(door_x, h - 2, "D")
    for (x, y, ww) in counters: r.rect(x, y, ww, 1, "C")
    r.warp(door_x, h - 2, out_zone, ox, oy, "down")
    r.d["spawn"] = [door_x, h - 3]
    return r
s = interior("buxton_sanctuary", "Buxton Sanctuary", 11, 9, 5, "buxton", 37, 17, counters=[(3, 3, 5)], music="sanctuary")
s.save(OUT + "/buxton_sanctuary.json")
sh = interior("buxton_shop", "Corner Shop", 9, 8, 4, "buxton", 43, 17, counters=[(2, 2, 3)]); sh.save(OUT + "/buxton_shop.json")
spa = interior("buxton_spa", "Buxton Spa", 15, 15, 7, "buxton", 37, 31, music="battle_keeper")
spa.rect(1, 1, 13, 13, "+")
spa.border("x", 1); spa.set(7, 13, "D")
for (x, y, w, h) in [(2, 9, 4, 3), (9, 9, 4, 3), (2, 4, 4, 3), (9, 4, 4, 3)]: spa.rect(x, y, w, h, "~")
spa.rect(6, 2, 3, 1, "|")
spa.d["spawn"] = [7, 12]
spa.save(OUT + "/buxton_spa.json")
