# Part of england_north.py (exec'd in its namespace): Douglas, Isle of Man (ferry only).

# ====================================================================
# DOUGLAS  60 x 54, seaside town, reached by ferry from Liverpool
# ====================================================================
d = Z("douglas", "Douglas", 60, 54, kind="town", region="man", music="town_cheshire", fill=".",
      weather={"sunshine": 26, "clear": 24, "gale": 20, "drizzle": 16, "fog": 8, "downpour": 6})
d.d["stage"] = "coast"; d.d["town_id"] = "douglas"
d.legend["r"] = REEDS
d.legend["d"] = {"tile": "tall_grass", "colour": "#c9b96d", "prop": "none"}
d.legend["b"] = BIRCH
d.border("T", 3)
d.rect(50, 0, 10, 54, "$"); d.rect(47, 0, 3, 54, "s")
# the promenade and the horse tram line
d.rect(44, 3, 3, 48, ":")
d.rect(43, 4, 1, 46, "!")
CROSS = [12, 24, 36, 47]
for y in CROSS: d.rect(43, y, 1, 1, "#")
# cross streets
for y in CROSS: d.rect(3, y, 41, 1, "=")
d.rect(21, 3, 3, 48, ":"); d.rect(22, 3, 1, 48, "=")
for y in CROSS: d.rect(21, y, 3, 1, "=")
# ferry pier and sea terminal
d.rect(47, 9, 9, 2, ":")
d.d["ferry"] = {"x": 55, "y": 10, "route": "liverpool_douglas"}
d.prop("boat", 54, 13, variant=0); d.prop("boat", 53, 5, variant=1); d.prop("buoy", 56, 7); d.prop("buoy", 57, 16, variant=1); d.prop("buoy", 53, 20)
for x in (49, 51, 53): d.prop("bollard", x, 8)
d.prop("lamp_post", 48, 9); d.prop("lamp_post", 52, 11)
d.sign(50, 11, "SEA TERMINAL. Ferries to Liverpool. Don't be late: the captain isn't sentimental.")
# Tower of Refuge on its rock
ell(d, 52, 34, 3, 2.4, "R", only="$"); ell(d, 52, 34, 1.8, 1.4, "s", only="R")
d.prop("lighthouse", 52, 34)
d.prop("boat", 55, 40, variant=1); d.prop("buoy", 54, 30, variant=1)
# promenade furniture
for y in (6, 15, 20, 28, 33, 41, 45):
    d.prop("lamp_post", 44, y); d.prop("bench", 46, y + 1)
d.prop("phone_box", 44, 18); d.prop("post_box", 44, 38); d.prop("planter", 46, 25); d.prop("planter", 46, 36)
d.sign(46, 31, "THE TOWER OF REFUGE. Built 1832 so shipwrecked sailors had somewhere to wait. Still the poshest lighthouse ever. Founded by the chap who started the RNLI.")
d.sign(45, 13, "DOUGLAS PROMENADE. Two miles of Victorian hotels. The Manx wind will find every one.")
d.sign(44, 49, "DOUGLAS HEAD, south. Not on this map. Or any map, it's mostly cliff.")
# horse trams (3x1 red-and-cream)
d.sign(45, 19, "HORSE TRAM. Running since 1876. Oldest surviving horse tramway in the world. Powered by one horse, several opinions.")
# block A: Laxey Wheel and a stream, hotels
d.rect(3, 4, 17, 7, ".")
d.rect(5, 5, 8, 6, "."); d.building(7, 6, 4, 4, "mill", "Laxey Wheel (not to scale)", door=None)
d.rect(5, 10, 8, 1, "#")
pond(d, 15, 7, 3, 2); d.rect(12, 8, 3, 1, "w")
d.prop("standing_stone", 4, 5)
d.sign(5, 9, "THE LAXEY WHEEL, 'Lady Isabella', 1854. Nearly 22 metres across. The largest working waterwheel on Earth. This is a very approximate model.")
d.rect(24, 4, 19, 7, ":")
d.building(25, 6, 8, 4, "terrace", show_label=False); d.building(34, 6, 8, 4, "terrace", show_label=False)
# block B: Sanctuary, Corner Shop, theatre
d.rect(3, 13, 40, 10, ":")
town_services(d, "douglas", "Douglas", (5, 16), (13, 16))
d.building(26, 14, 8, 4, "stone", "Gaiety Theatre", door=3)
d.building(35, 15, 7, 3, "cream_render", show_label=False)
d.prop("lamp_post", 11, 20); d.prop("lamp_post", 24, 20); d.prop("lamp_post", 38, 20)
d.prop("planter", 20, 20); d.prop("bench", 30, 19)
d.sign(24, 21, "GAIETY THEATRE. Victorian, ornate, haunted by exactly the right amount of ghost.")
# block C: station and tram depot
d.rect(3, 25, 40, 11, ":")
d.building(6, 28, 8, 2, "station", "Douglas Station", door=3)
d.rect(4, 30, 17, 1, "_"); d.rect(3, 31, 18, 1, "!")
d.d["station"] = {"x": 9, "y": 30}
d.prop("lamp_post", 5, 32); d.prop("lamp_post", 17, 32); d.prop("bench", 12, 32)
d.sign(14, 32, "ISLE OF MAN STEAM RAILWAY. Narrow gauge, wide smile, puffs of coal smoke and nostalgia.")
d.building(26, 27, 8, 3, "red_brick", "Horse Tram Depot", door=3)
d.building(36, 28, 5, 3, "white_render", "Manx Kipper Shop", door=2)
d.prop("lamp_post", 25, 31); d.prop("bench", 35, 31)
d.sign(30, 31, "MANX KIPPERS. Smoked herring. The smell announces itself three streets away.")
d.rect(3, 32, 17, 4, ".")
for (x, y) in [(4, 33), (8, 34), (12, 33), (17, 34)]: d.prop("oak", x, y)
# block D: the Loaghtan field
d.rect(3, 38, 40, 9, ".")
hill(d, 22, 42, 15, 4, 2)
d.rect(4, 38, 36, 1, "F"); d.rect(4, 46, 36, 1, "F"); d.rect(4, 38, 1, 9, "F"); d.rect(39, 38, 1, 9, "F")
d.rect(21, 38, 3, 1, ":"); d.rect(21, 37, 3, 1, ":")
for (cx, cy, rx, ry) in [(10, 42, 4, 2), (18, 43, 4, 2), (28, 41, 4, 2), (34, 43, 3, 2), (24, 44, 3, 1)]:
    ell(d, cx, cy, rx, ry, ",", only=".")
for (x, y) in [(6, 40), (14, 40), (30, 44), (36, 40), (8, 44)]: d.prop("rock", x, y)
d.sign(22, 39, "LOAGHTAN FIELD. Four horns, one opinion: leave us alone. They are mouse-coloured, and they know it.")
d.rect(3, 47, 41, 4, ".")
d.rect(3, 47, 41, 1, "=")
d.sign(10, 48, "DOUGLAS HEAD. Cliffs this way. Seagulls that way. Chips somewhere between.")
# beach tufts
for (cx, cy, rx, ry) in [(47, 20, 1, 3), (48, 44, 1, 3), (48, 28, 1, 2)]:
    ell(d, cx, cy, rx, ry, "d", only="s")
# trees round the edges
d.scatter(3, 3, 17, 10, "T", 10, 601, only=".")
d.scatter(3, 48, 40, 4, "b", 16, 602, only=".")
# horse trams last (3x1), on the rails
d.building(42, 17, 3, 1, "cream_render", "Horse Tram")
d.building(42, 40, 3, 1, "cream_render", "Horse Tram")
d.prop("bollard", 41, 18); d.prop("bollard", 41, 41)
# NPCs
d.npc(id="douglas_sailor", sprite="sailor", x=54, y=9, facing="right", move="still", script="sailor", name="Sailor")
d.npc(id="farmer", sprite="farmer", x=19, y=41, facing="down", move="wander", script="farmer", name="Farmer")
d.npc(id="doug_tram", sprite="villager_4", x=41, y=19, facing="right", move="still", script="tram_driver", name="Tram Driver")
d.npc(id="doug_tt", sprite="jogger", x=30, y=25, facing="down", move="wander", script="tt_fan", name="TT Fan")
d.npc(id="doug_cat", sprite="villager_3", x=31, y=12, facing="left", move="wander", script="cat_lady", name="Cat Lady")
d.npc(id="doug_kipper", sprite="villager_5", x=36, y=31, facing="down", move="still", script="kipper_man", name="Kipper Seller")
d.npc(id="doug_tynwald", sprite="tour_guide", x=23, y=26, facing="down", move="wander", script="tynwald_guide", name="Guide")
d.npc(id="rail_guard", sprite="rail_guard", x=11, y=30, facing="down", move="still", script="rail_guard", name="Rail Guard")
for t in [("douglas_angler", "Angler Maughold", "Angler", "angler", [("chipgull", 21), ("pupplash", 22), ("pinchkin", 22)], 780, 44, 22, "down",
           ["Cod, mackerel, the occasional jellyfish. Any of them would be a better opponent than my wife.", "Care for a quick one?"],
           "Landed me. Well done.", "The sea round here is cold enough to pickle a herring."),
          ("douglas_rider", "TT Rider Ewan", "Jogger", "jogger", [("pinchkin", 22), ("duneskink", 23), ("loaghtan", 24)], 860, 14, 37, "down",
           ["I did a lap of the TT course last year. Seventeen minutes. On a bicycle. They counted it.", "Rev up. I've got a battle to catch."],
           "That's me parked. Good lap.", "The TT's the fastest road race in the world. I am the slowest part of it.")]:
    tid, nm, cls, spr, party, money, x, y, facing, intro, win, after = t
    trainer(tid, nm, cls, spr, party, money, intro, win, after)
    d.npc(id=tid, sprite=spr, x=x, y=y, facing=facing, move="still", trainer=tid)
say("douglas", "farmer", "Farmer", "...")
say("douglas", "sailor", "Sailor", "Back to Liverpool? The boat goes when the tide agrees.")
DLG["douglas"]["sailor"].append({"do": "ferry", "route": "liverpool_douglas"})
say("douglas", "rail_guard", "Rail Guard", "Douglas Station. Steam trains to Port Erin. All the nostalgia, none of the hurry.")
DLG["douglas"]["rail_guard"].append({"do": "rail"})
say("douglas", "tram_driver", "Tram Driver", "Horse trams have run along this prom since 1876. The oldest surviving horse tramway in the world.", "Our horses get the winter off. Lucky horses.")
say("douglas", "tt_fan", "TT Fan", "The Isle of Man TT races started in 1907. Bikes at over 120 miles an hour, past people's front gardens.", "My nan's front hedge has been clipped by seven world champions.")
say("douglas", "cat_lady", "Cat Lady", "That's a Manx cat. No tail. Well, almost none. Some have a tiny stump called a rumpy.", "A Manx cat can't wag a tail at you. You'll have to guess whether it likes you.")
say("douglas", "kipper_man", "Kipper Seller", "Manx kippers are smoked over oak chippings. The island's been doing it since the 1840s.", "If you smell this on your coat for days, you've been shopping well.")
say("douglas", "tynwald_guide", "Guide", "Tynwald is the Manx parliament. It's more than a thousand years old. Arguably the oldest in the world to be running continuously.", "Every July they sit on a hill and read the laws out loud, in Manx and English. Takes ages. Free tea after.")
d.d["encounters"] = {"grass": [
    {"species": "loaghtan", "min": 20, "max": 24, "weight": 38},
    {"species": "chipgull", "min": 20, "max": 22, "weight": 18},
    {"species": "pinchkin", "min": 20, "max": 22, "weight": 14},
    {"species": "duneskink", "min": 21, "max": 23, "weight": 12, "weather": ["clear", "sunshine"]},
    {"species": "pupplash", "min": 21, "max": 23, "weight": 12},
    {"species": "starlet", "min": 20, "max": 22, "weight": 10, "time": ["dawn", "day", "dusk"]},
    {"species": "swiftlet", "min": 21, "max": 23, "weight": 8, "weather": ["gale", "clear"]},
    {"species": "hootlet", "min": 21, "max": 23, "weight": 8, "time": ["dusk", "night"]}],
    "water": [
    {"species": "chipgull", "min": 20, "max": 22, "weight": 35},
    {"species": "pinchkin", "min": 20, "max": 22, "weight": 30},
    {"species": "pupplash", "min": 21, "max": 23, "weight": 25}]}
d.d["spawn"] = [45, 10]
deco(d, 3, 25, 40, 11, ["bench", "planter", "bollard", "market_stall"], 10, 611, on=":")
deco(d, 3, 13, 40, 10, ["planter", "bench", "phone_box", "lamp_post"], 8, 612, on=":")
deco(d, 24, 4, 19, 7, ["planter", "bench", "bush"], 5, 613, on=":")
deco(d, 47, 3, 3, 48, ["bollard", "rock", "buoy"], 8, 614, on="s")
d.save(OUT + "/douglas.json")
nurse_and_shop("douglas",
    ["Hello, dear! Come in, Manx weather's not for the faint-hearted. Cup of tea?",
     "Right-o, give them here. We'll have them champion in no time.",
     "There you are. Better than new. Off you pop.",
     "The Ark is by the window. No cats in it, please. We've tried.",
     "No problem. Mind the gulls on the way out. They know."],
    ["Welcome! Kippers, kendal mint cake and umbrellas for the sideways rain.", "Thanks, my love. Mind the wind. It's not personal."])
