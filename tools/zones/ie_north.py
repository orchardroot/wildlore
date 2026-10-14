# connemara, sligo, boyne_valley, newgrange and newgrange_tomb (plus Sanctuary and Corner Shop for sligo, newgrange).
from ie_common import *


def build(OUT):
    connemara(OUT)
    sligo(OUT)
    boyne(OUT)
    newgrange(OUT)
    tomb(OUT)


def connemara(OUT):
    W, H = 64, 46
    zid = "connemara"
    z = Z(zid, "Connemara", W, H, kind="route", region="ireland_west", music="route_ireland",
          weather={"drizzle": 28, "fog": 22, "downpour": 14, "clear": 14, "gale": 10, "sunshine": 8, "frost": 4})
    z.d["stage"] = "bog"
    z.legend["k"] = {"tile": "grass", "colour": "#7f8a55"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["m"] = {"tile": "tall_grass", "colour": "#5f6a4a", "prop": "none"}   # mire
    z.legend["c"] = {"tile": "tall_grass", "colour": "#cfd0c0", "prop": "none"}   # bog cotton
    z.legend["p"] = {"tile": "path", "colour": "#4a3a2c"}                          # peat
    z.rect(0, 0, W, H, "k")
    hills(z, [(14, 12, 6, 15), (27, 7, 5, 11), (7, 26, 4, 9), (52, 8, 3, 8)])
    z.border("R", 2, gaps=[(34, 0, 3, 2), (34, 44, 3, 2)])
    z.scatter(0, 0, W, H, "P", 14, 3, only="R")
    for (x, y, w, h) in [(3, 3, 20, 12), (24, 3, 10, 9), (3, 16, 8, 10), (14, 18, 9, 6), (38, 4, 14, 6)]:
        z.rect(x, y, w, h, "h")
    # bog and peat in the south-east, pools between
    for (x, y, w, h) in [(40, 27, 22, 15)]:
        z.rect(x, y, w, h, "m")
    for (x, y, w, h) in [(42, 29, 7, 3), (52, 33, 6, 3), (44, 37, 8, 3), (56, 28, 4, 3)]:
        z.rect(x, y, w, h, "c")
    for (cx, cy, rx, ry) in [(47, 34, 3, 1.6), (56, 39, 3, 1.5), (42, 40, 2.4, 1.2)]:
        blob(z, cx, cy, rx, ry, "~", seed=cx)
    # Kylemore: a lough, the abbey above it, walled garden and church
    blob(z, 50, 23, 9, 3.6, "w", only="mkh", seed=1); blob(z, 50, 23, 7.5, 2.6, "~", seed=2)
    z.building(43, 10, 10, 6, "castle", "Kylemore Abbey")
    z.building(38, 12, 4, 3, "chapel", "Gothic Church")
    z.rect(55, 6, 7, 9, "W"); z.rect(56, 7, 5, 7, "f"); z.rect(58, 14, 1, 1, "k")
    z.prop("bench", 57, 9); z.prop("planter", 59, 9); z.prop("planter", 57, 12)
    z.rect(36, 17, 20, 2, "#"); z.rect(44, 16, 8, 1, "#"); z.rect(58, 15, 1, 3, "#")
    # stone-walled fields (south-west) with stiles
    for (x, y, w, h) in [(4, 29, 24, 1), (4, 29, 1, 14), (4, 42, 24, 1), (27, 29, 1, 14), (15, 29, 1, 14), (4, 36, 24, 1)]:
        z.rect(x, y, w, h, "W")
    for (x, y) in [(10, 29), (21, 29), (15, 33), (15, 40), (10, 36), (21, 36), (27, 34), (27, 38)]:
        z.set(x, y, "k")
    z.rect(5, 30, 10, 6, "."); z.rect(16, 30, 11, 6, ","); z.rect(5, 37, 10, 5, ","); z.rect(16, 37, 11, 5, ".")
    # paths: the main road north-south, the walkers' trail into the Bens, the peat track, the boardwalk
    z.rect(34, 0, 3, 46, "#")
    z.rect(12, 14, 23, 2, "#"); z.rect(12, 14, 2, 15, "#")
    z.rect(10, 29, 2, 1, "#")
    z.rect(28, 31, 6, 1, "#"); z.rect(36, 30, 24, 1, "|"); z.rect(36, 36, 1, 1, "|")
    z.rect(30, 25, 4, 2, "#")
    scatter_props(z, "rock", 3, 3, 60, 40, 40, 9, avoid=("h", "k"))
    scatter_props(z, "bush", 3, 3, 60, 40, 16, 4, avoid=("k",))
    for (x, y, v) in [(54, 31, 0), (55, 31, 1), (46, 40, 2), (58, 41, 0), (40, 33, 1), (38, 40, 2)]:
        z.prop("slate_heap", x, y, variant=v)
    z.sign(33, 44, "CONNEMARA. A wild, wet, wonderful corner of Galway: bog, lakes, mountains and sky, in that order of area. About half of it is sky, and the sky has opinions.")
    z.sign(33, 14, "THE TWELVE BENS. Na Beanna Beola, a ring of quartzite peaks, the tallest at 729 metres. In clear weather you can see for forty miles. 'Clear weather' is a rumour.")
    z.sign(43, 17, "KYLEMORE ABBEY. A Victorian castle built in the 1860s by Mitchell Henry for his wife Margaret. Since 1920 it has been a home for Benedictine nuns. In the walled garden, the vegetables are grown by monks of the wheelbarrow.")
    z.sign(36, 29, "TURF. Cut from the bog and dried in stacks, burnt for heat for centuries. Connemara bogs are protected now. The old sods smell of peat, smoke and a good yarn.")
    z.sign(10, 28, "STONE WALLS. A thousand miles of them across Connemara, all put up by hand with no mortar. The gaps are on purpose. The wind needs to go through or it takes the wall.")
    # Connemara ponies
    for (sp, x, y, mv) in [("connie", 8, 32, "wander"), ("connie", 12, 33, "wander"), ("connemarr", 20, 33, "wander"), ("connie", 8, 40, "wander"),
                           ("connemarr", 22, 40, "still"), ("connie", 40, 24, "wander"), ("connie", 58, 22, "wander")]:
        creature(z, zid, sp, x, y, mv, who="Connemara Pony",
                 line="It looks at you the way ponies always do: long, grey and unimpressed. It has been in these fields since long before the roads.")
    # chat
    chat(z, "turf_cutter", "farmer", 38, 31, "Turf Cutter",
         ["I cut the turf in May with a slean, a long narrow spade, and stack it to dry. By October it burns beautifully.",
          "Peat's a thousand years in the making. A fire of it tells you stories. Mostly about rain."], "down", "still")
    chat(z, "kylemore_guide", "tour_guide", 47, 19, "Kylemore Guide",
         ["Mitchell Henry built Kylemore for his wife Margaret, in 1867. She died young, in Egypt, and he built a little Gothic church beside the lake in her memory.",
          "The Benedictine nuns have lived here since 1920. They make chocolate. I'm not trying to say that's the main reason for the visit."], "down", "still")
    chat(z, "pony_breeder", "farmer", 14, 31, "Pony Breeder",
         ["Connemara ponies are the only native breed in Ireland. They're hardy, gentle, jump like deer and eat very little. They're a farmer's dream.",
          "In August, Clifden holds the Connemara Pony Show. A champion can fetch more than a house. I've been offered a bicycle for mine."], "right", "still")
    chat(z, "wall_builder", "villager_4", 22, 28, "Wall Builder",
         ["I build the walls the old way: every stone fits, every gap breathes, no cement. A good wall lasts two hundred years.",
          "The trick is to find the stone that wants to go there. It sounds mad. Try it. The wall tells you."], "up", "wander")
    chat(z, "bens_walker", "hiker", 32, 20, "Hill Walker",
         ["The Twelve Bens: twelve peaks, one view. On a bad day you see twelve fogs and one sheep.",
          "Irish for Connemara is Conamara. It means 'the descendants of Conmac'. And yes, I could say all of it with a straight face, but a rainy day makes me silly."], "right", "still")
    trainer(z, "conn_singer", "Sean-nos Singer Maire", "Sean-nos Singer", "choir_singer", [("bansheen", 58), ("bradan", 57), ("gealhare", 58)],
            30, 16, "up", ["Sean-nos is old-style singing: unaccompanied, in Irish, and with a lot of ornament. If you like, I'll sing the battle as well."],
            "A fine loss. It's said to be good luck. Not that I believe it.", "It's the Gaeltacht for you: even the shopkeeper's a better singer than me.", 2520)
    trainer(z, "conn_angler", "Angler Colm", "Angler", "angler", [("bradan", 58), ("parrlet", 57), ("rillotter", 58)],
            44, 26, "up", ["Salmon and sea trout in the lough. Brown trout in the stream. And a very patient man in the middle."],
            "Landed. A good lad. Now go away, I've a bite.", "A salmon comes home to the river it was born in. Remarkable. I can barely find the car.", 2540)
    trainer(z, "conn_warden", "Warden Rupert", "Warden", "warden_grunt", [("connie", 58), ("megalorn", 59), ("bansheen", 58)],
            40, 16, "down", ["Welcome to the Wild Connemara Experience! Peat, ponies and a poncho for just eighteen euro."],
            "That's the poncho gone. I'll file it.", "Director Kerrigan says the bogs are 'under-monetised'. The bogs, I think, disagree.", 2580)
    trainer(z, "conn_birder", "Birdwatcher Enda", "Birdwatcher", "birdwatcher", [("corncrake", 57), ("polartern", 58), ("heronarch", 58)],
            33, 31, "right", ["Listen. A corncrake: crex crex. It sounds like someone running a thumb down a comb. They've almost gone from Ireland."],
            "Good shot. The corncrake didn't flinch, though.", "Western Connemara and Donegal hold most of what's left of Ireland's corncrakes. They like long grass. And quiet.", 2560)
    z.d["edges"] = {"south": {"to": "galway", "offset": 0}, "north": {"to": "sligo", "offset": 0}}
    z.d["spawn"] = [35, 43]
    wild(z, [("connie", 57, 58, 16, {}), ("connemarr", 58, 59, 8, {"time": ["day", "dusk"]}),
             ("bansheen", 58, 59, 5, {"time": ["night"], "weather": ["fog", "drizzle"]}),
             ("megalorn", 58, 59, 3, {"weather": ["fog"], "time": ["dawn", "dusk"]}),
             ("crexling", 57, 58, 10, {"time": ["dawn", "dusk"]}), ("corncrake", 58, 59, 8, {"time": ["day"], "weather": ["clear", "sunshine"]}),
             ("sphagnet", 57, 58, 10, {"weather": ["drizzle", "downpour"]}), ("peatmonarch", 58, 59, 8, {"weather": ["fog", "downpour"]}),
             ("natterjack", 57, 58, 8, {"time": ["night", "dusk"]}), ("parrlet", 57, 58, 6, {"weather": ["downpour"]}),
             ("kidgruff", 57, 58, 8, {"time": ["day"]})])
    wild(z, [("parrlet", 57, 58, 20, {}), ("bradan", 58, 59, 18, {}), ("rillotter", 58, 59, 16, {}), ("heronarch", 58, 59, 14, {}), ("spatelord", 58, 59, 12, {"time": ["night"]})], "water")
    finish(z)
    z.save(OUT + "/connemara.json")


def sligo(OUT):
    W, H = 56, 50
    zid = "sligo"
    z = Z(zid, "Sligo", W, H, kind="town", region="ireland_west", music="town_ireland",
          weather={"drizzle": 30, "clear": 18, "fog": 14, "downpour": 12, "gale": 10, "sunshine": 16})
    z.d["stage"] = "town"; z.d["town_id"] = "sligo"
    z.legend["k"] = {"tile": "grass", "colour": "#7d8a58"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(34, 48, 3, 2), (54, 27, 2, 3)])
    z.scatter(0, 0, W, H, "P", 16, 2, only="T")
    # Benbulben: a table mountain, a plateau behind a wall of cliff, slopes down to the town
    z.rect(2, 0, 52, 11, "k"); z.rect(2, 11, 52, 2, "^")
    z.rect(2, 13, 52, 8, "k")
    z.height(2, 0, 52, 13, 6); z.height(2, 13, 52, 2, 3); z.height(2, 15, 52, 2, 2); z.height(2, 17, 52, 2, 1)
    r = random.Random(3)
    for y in range(2, 11):
        for x in range(2, 54):
            if r.random() < 0.28:
                z.set(x, y, "R")
    for (x, y, w, h) in [(3, 14, 12, 5), (20, 15, 10, 4), (40, 14, 12, 5), (5, 19, 10, 2), (44, 19, 8, 2)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(16, 17, 6, 3), (30, 17, 8, 3), (3, 20, 6, 3)]:
        z.rect(x, y, w, h, ",")
    scatter_props(z, "rock", 3, 13, 50, 8, 14, 2, avoid=("k", "h"))
    z.sign(34, 20, "BENBULBEN. Binn Ghulbain, 'Gulban's peak'. A great flat-topped limestone mountain, 526 metres, shaped by ice. It looks like a ship, a table and a wall all at once, and it's behind everything in Sligo. Yeats used to look at it from his window.")
    # main road and cobbled sides
    z.rect(2, 27, 54, 3, "="); z.rect(2, 26, 52, 1, ":"); z.rect(2, 30, 52, 1, ":")
    z.rect(34, 20, 3, 8, "="); z.rect(34, 30, 3, 20, "=")
    # row A (north of the road): theatre, Sanctuary, shop, abbey, gallery, cafe
    z.building(3, 22, 7, 4, "cream_render", "Hawk's Well Theatre")
    z.building(11, 22, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(18, 22, 5, 4, "shop", "Corner Shop", door=2)
    z.building(24, 22, 8, 4, "chapel", "Sligo Abbey")
    z.building(38, 22, 7, 4, "terrace", "The Model Gallery")
    z.building(46, 22, 7, 4, "white_render", "Strand Cafe")
    z.warp(14, 25, "sligo_sanctuary", 5, 6, "up"); z.warp(20, 25, "sligo_shop", 4, 5, "up")
    # row B (south of the road)
    z.building(3, 31, 6, 4, "slate_cottage", show_label=False)
    z.building(10, 31, 7, 4, "terrace", "The Poet's Corner Books")
    z.building(18, 31, 8, 4, "tudor", "The Garavogue Arms")
    z.building(27, 31, 6, 4, "red_brick", "Sligo Tweed")
    z.building(38, 31, 7, 4, "cream_render", "Memorial Hall")
    z.building(46, 31, 7, 4, "terrace", "Strandhill Surf Shop")
    z.rect(2, 35, 51, 1, ":")
    z.prop("statue", 31, 36); z.prop("planter", 29, 36); z.prop("planter", 33, 36)
    z.sign(30, 36, "W. B. YEATS. Poet, playwright and Nobel laureate, 1865 to 1939. His mother's family were Sligo merchants and the county's in half his poems. He's buried at Drumcliffe, under Benbulben, as he asked.")
    for x in (4, 8, 17, 28, 42, 50):
        z.prop("lamp_post", x, 26)
    for x in (8, 20, 40, 48):
        z.prop("lamp_post", x, 30)
    z.prop("phone_box", 3, 26); z.prop("post_box", 53, 30); z.prop("bench", 26, 26); z.prop("bench", 42, 30)
    # the river Garavogue and the bridge
    z.rect(2, 37, 52, 3, "~"); z.rect(34, 37, 3, 3, "|")
    z.rect(2, 36, 28, 1, "."); z.rect(37, 36, 16, 1, ".")
    for (x, y, v) in [(10, 38, 1), (22, 38, 1), (44, 38, 1)]:
        z.prop("boat", x, y, variant=v)
    # the south bank: station, Innisfree and meadows
    z.rect(2, 40, 52, 8, ".")
    z.rect(5, 40, 31, 1, ":")
    z.rect(34, 40, 3, 8, "=")
    pf = station(z, 6, 42, 9, 4, "MacDiarmada Station")
    z.rect(5, 41, 1, 4, ":"); z.rect(15, 41, 1, 4, ":"); z.rect(6, 41, 9, 1, ":")
    z.prop("bench", 8, 44); z.prop("lamp_post", 13, 44)
    rail_guard(z, 11, 44, ["Sligo, Sligeach, the shelly place. The railway came in 1862, Yeats's early years. He used to take the train home and write poems about the sea.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    blob(z, 46, 44, 6, 2.6, "w", only=".", seed=5); blob(z, 46, 44, 5, 2, "~", seed=6); blob(z, 46, 44, 1.5, 1, ".", seed=7)
    z.prop("oak", 46, 44, variant=1)
    z.sign(40, 42, "THE LAKE ISLE OF INNISFREE. Yeats wrote: 'I will arise and go now, and go to Innisfree, and a small cabin build there.' The real isle is on Lough Gill. This pond is the gift shop's version.")
    z.rect(20, 42, 10, 5, ","); z.rect(38, 45, 4, 3, ","); z.rect(20, 41, 10, 1, "f")
    scatter_props(z, "bush", 3, 41, 50, 7, 8, 4, avoid=(".",))
    # NPCs
    chat(z, "sligo_poet", "villager_6", 29, 35, "Poet",
         ["I'm composing an ode to Benbulben. So far I have 'Oh, Benbulben, you are large.' It's rough, but the bones are strong.",
          "Yeats said Sligo was 'the land of heart's desire'. I've yet to find the heart. I've found the desire. For tea."], "right", "wander")
    chat(z, "benbulben_guide", "hiker", 44, 28, "Mountain Guide",
         ["Benbulben's on top of an ancient seabed, with fossils all over. The flat top's about 526 metres, and the cliff face is a wall of limestone.",
          "They say Diarmuid and Grainne's story ended here: the wild boar and the hunter, and an old tale of love gone wrong. It's very Irish. Everything ends at a mountain."], "left", "still")
    chat(z, "knocknarea_fan", "student", 14, 28, "Student",
         ["Over there, on Knocknarea, the huge cairn's said to be the grave of Queen Maeve. It's about 5,500 years old and hasn't been dug up. Nobody wants to disturb her.",
          "Carrowmore's the megalithic cemetery. Some of it's older than Newgrange. I'm putting that in a postcard."], "right", "wander")
    chat(z, "usher", "villager_3", 8, 27, "Theatre Usher",
         ["The Hawk's Well Theatre is named for a Yeats play. He wrote it in 1916, inspired by Japanese Noh theatre. It's a play about a waiting man and a well with no water.",
          "I wait all night. The play's quite short. I keep a flask."], "up", "still")
    chat(z, "river_angler", "angler", 36, 36, "Fisherman",
         ["The Garavogue runs through the middle of Sligo, only about four kilometres from Lough Gill to the sea. Salmon and sea trout come in all year.",
          "Right in the middle of the town, and no one ever bothers me. They don't think I'm serious. I am."], "left", "wander")
    chat(z, "surf_kid", "surfer", 45, 34, "Strandhill Surfer",
         ["Strandhill's the surfing capital of Ireland, probably. Fifteen minutes up the road and the waves roll in forever.",
          "You wear a thick wetsuit, because the Atlantic hasn't heard of summer. I've never been so cold and so happy."], "down", "still")
    trainer(z, "sligo_birder", "Birdwatcher Grainne", "Birdwatcher", "birdwatcher", [("corncrake", 59), ("rookery", 59), ("polartern", 59)],
            26, 19, "down", ["The peregrines nest on the cliffs of Benbulben. I'm told they can reach 300 kilometres an hour. I can barely reach the bus."],
            "I never saw it coming. Like a peregrine.", "A good birder's like a good poet: lots of waiting, a few seconds of brilliance.", 2700)
    trainer(z, "sligo_hurler", "Hurler Dara", "Hurler", "rugby_player", [("stagmor", 59), ("dextera", 59), ("raidtail", 59)],
            12, 29, "up", ["Sligo's got a tradition of hurling, a bit older than the town itself. Fancy a puck?"],
            "A fair puck. I'll keep the sliotar for the evening.", "A hurley, called a camán, is made of ash. It's tough, and it's flexible, which is more than I can say for myself.", 2680)
    z.d["edges"] = {"south": {"to": "connemara", "offset": 0}, "east": {"to": "boyne_valley", "offset": 0}}
    z.d["spawn"] = [35, 28]
    wild(z, [("crexling", 59, 59, 12, {"time": ["dawn", "dusk"]}), ("corncrake", 59, 60, 8, {"time": ["day"]}),
             ("kidgruff", 59, 59, 10, {}), ("billgruff", 59, 60, 6, {"weather": ["clear", "sunshine"]}),
             ("gealhare", 59, 60, 8, {"time": ["dawn", "dusk"]}), ("rookery", 59, 60, 10, {"time": ["day", "dusk"]}),
             ("hushwing", 59, 60, 8, {"time": ["night"]}), ("hazeldoze", 59, 59, 8, {}), ("polartern", 59, 60, 5, {"weather": ["gale", "frost"]}),
             ("moolet", 59, 59, 8, {"time": ["day"]})])
    wild(z, [("bradan", 59, 60, 20, {}), ("rillotter", 59, 60, 20, {}), ("heronarch", 59, 60, 14, {}), ("parrlet", 59, 59, 12, {}), ("spatelord", 59, 60, 12, {"time": ["night"]})], "water")
    finish(z)
    z.save(OUT + "/sligo.json")
    sanctuary(OUT, "sligo", "Sligo", (14, 26), music="sanctuary")
    shop(OUT, "sligo", "Sligo", (20, 26))
    nurse("sligo", ["Welcome to Sligo Sanctuary. 'Cast a cold eye on life, on death.' That's Yeats' grave, not our policy. We'll have you warm in no time.",
                    "Sit down, I'll fetch the poultice. It's mostly tea, but it works.",
                    "There you go. 'Go n-eiri an bothar leat', may the road rise with you. And may the wind stay at your back.",
                    "The Ark terminal's in the corner. Treat it gently, it reads poetry to the creatures.",
                    "No hurry at all. Benbulben's not going anywhere, and neither's the kettle."])
    shopkeeper("sligo", "Dia duit! Snares, tea, a Yeats postcard and, if you ask nicely, a very good scone.",
               "Slán leat! Say hello to Benbulben on your way out.")


def boyne(OUT):
    W, H = 66, 46
    zid = "boyne_valley"
    z = Z(zid, "Boyne Valley", W, H, kind="route", region="ireland_east", music="route_ireland",
          weather={"clear": 24, "sunshine": 18, "drizzle": 24, "fog": 12, "downpour": 10, "gale": 6, "frost": 6})
    z.d["stage"] = "valley"
    z.legend["c"] = {"tile": "tall_grass", "colour": "#c9b24a", "prop": "none"}   # barley
    z.legend["r"] = {"tile": "tall_grass", "colour": "#6f7f4a", "prop": "reeds"}
    z.border("T", 2, gaps=[(0, 27, 2, 3), (30, 44, 3, 2), (64, 27, 2, 3)])
    z.scatter(0, 0, W, H, "P", 20, 2, only="T")
    # the river Boyne, in two reaches, with one bridge on the north path
    z.rect(2, 14, 26, 2, "~"); z.rect(27, 14, 2, 7, "~"); z.rect(29, 19, 35, 2, "~")
    z.rect(30, 19, 3, 2, "|")
    for (x, y, w, h) in [(2, 16, 20, 1, "r"), (34, 21, 28, 1, "r")] if False else []:
        pass
    z.rect(4, 16, 16, 1, "r"); z.rect(34, 21, 26, 1, "r"); z.rect(34, 18, 24, 1, "r")
    # main road (path) west to east, south branch, north branch over the bridge
    z.rect(0, 27, 66, 3, "#"); z.rect(30, 30, 3, 16, "#"); z.rect(30, 8, 3, 19, "#")
    # farmland: barley, meadow and flowers
    for (x, y, w, h) in [(4, 32, 10, 6), (22, 36, 7, 6), (36, 32, 9, 6), (50, 36, 10, 6), (6, 22, 8, 4), (44, 24, 12, 2)]:
        z.rect(x, y, w, h, "c")
    for (x, y, w, h) in [(14, 32, 4, 8), (46, 32, 3, 8), (36, 40, 8, 3), (6, 40, 8, 3), (36, 4, 20, 3)]:
        z.rect(x, y, w, h, "f")
    for (x, y, w, h) in [(18, 22, 8, 4), (36, 23, 6, 3), (52, 23, 8, 3), (20, 32, 4, 3), (56, 32, 5, 3), (6, 4, 10, 8)]:
        z.rect(x, y, w, h, ",")
    # hedgerows: field boundaries with gaps
    for (x, y, w, h) in [(2, 31, 27, 1), (35, 31, 28, 1), (14, 31, 1, 13), (48, 31, 1, 13), (2, 24, 8, 1), (14, 24, 14, 1), (34, 24, 10, 1), (56, 24, 6, 1), (20, 31, 1, 13)]:
        z.rect(x, y, w, h, "H")
    for (x, y) in [(8, 31), (22, 31), (40, 31), (54, 31), (14, 36), (20, 37), (48, 38), (11, 24), (45, 24), (30, 24)]:
        z.set(x, y, ".")
    z.rect(30, 31, 3, 1, "#"); z.rect(30, 24, 3, 1, "#")
    z.rect(11, 24, 3, 1, "."); z.rect(45, 24, 11, 1, ".")
    # Mellifont Abbey ruins, north of the river
    z.building(26, 4, 8, 4, "chapel", "Mellifont Abbey")
    for (x, y) in [(23, 6), (36, 6), (24, 9), (37, 9)]:
        z.prop("standing_stone", x, y, variant=(x + y) % 3)
    z.rect(30, 8, 3, 1, "#"); z.rect(22, 9, 18, 1, ":")
    z.rect(10, 4, 8, 7, "."); scatter_props(z, "oak", 4, 3, 14, 10, 8, 3, avoid=(".", ","))
    z.prop("bench", 28, 9); z.prop("bench", 34, 9); z.prop("lamp_post", 29, 11); z.prop("lamp_post", 33, 11)
    z.sign(29, 10, "MELLIFONT ABBEY. The first Cistercian monastery in Ireland, founded in 1142, now a handsome ruin with a lavabo, where the monks washed. The roof's missing, but the washing arrangements are first-class.")
    z.sign(33, 25, "BRU NA BOINNE. The 'palace of the Boyne', a valley with three great passage tombs: Newgrange, Knowth and Dowth, built over 5,000 years ago. Newgrange is up the road to the east.")
    z.sign(12, 17, "THE SALMON OF KNOWLEDGE. In the legend, the young Fionn mac Cumhaill cooked the Salmon of Knowledge on the banks of the Boyne and burnt his thumb. He sucked it, and gained all its wisdom. Some of us get nothing from a burnt thumb but a burnt thumb.")
    z.sign(63, 26, "NEWGRANGE, EAST. Built around 3200 BC, so five hundred years older than the pyramids and a thousand older than Stonehenge. Mind the bus tours.")
    z.sign(31, 43, "DUBLIN, SOUTH. About an hour's drive. On foot, rather more.")
    z.sign(3, 26, "WEST TO SLIGO. Up past the Dromahair roads and down to Benbulben. Keep Benbulben on your left.")
    # the megalith: a lone standing stone
    z.prop("standing_stone", 54, 25, variant=1); z.prop("standing_stone", 55, 25, variant=2)
    z.prop("oak", 58, 33, variant=0); z.prop("oak", 40, 38, variant=2); z.prop("oak", 10, 36, variant=1)
    scatter_props(z, "bush", 3, 22, 60, 22, 20, 5, avoid=(".",))
    scatter_props(z, "oak", 3, 22, 60, 22, 8, 6, avoid=("."))
    # megalorn: the Irish elk, in a quiet field
    creature(z, zid, "megalorn", 52, 40, "still", "A huge, patient creature with antlers the width of a bus. The Irish elk really did have the biggest antlers of any deer, about three and a half metres across.", "Megalorn")
    creature(z, zid, "dextera", 24, 39, "wander", "A small, solid, glossy black Dexter cow. It's one of the smallest cattle breeds in Europe, and entirely confident about it.", "Dexter Cow")
    creature(z, zid, "moolet", 40, 35, "wander", "A Dexter calf bounds three steps, stops, and looks round to make sure everyone saw.", "Dexter Calf")
    # chat
    chat(z, "boyne_farmer", "farmer", 16, 28, "Farmer",
         ["Boyne farmland's some of the richest in Ireland. We've been growing barley here since the Stone Age. The builders of Newgrange ate our porridge, near enough.",
          "A hedgerow's a good thing. A habitat, a windbreak and a road map for hedgehogs."], "down", "still")
    chat(z, "battle_guide", "tour_guide", 33, 14, "History Guide",
         ["The Battle of the Boyne was in 1690. William of Orange beat James II. It's still in the history books, the songs and every marching season.",
          "I'll say this for the river: it's seen more battles than most, and it's still very peaceful about it."], "left", "still")
    chat(z, "salmon_fisher", "angler", 11, 17, "Salmon Fisher",
         ["The salmon here go out to sea and come back to the same river, years later, and the same stretch of water. They remember the smell of home.",
          "If I'd the Salmon of Knowledge, I'd know where the others are hiding."], "up", "still")
    chat(z, "tomb_student", "student", 44, 28, "Archaeology Student",
         ["Newgrange is a mound of earth and stone about 85 metres across, with a corbelled roof that's stayed dry for five thousand years. You'd have to be a very good builder, or very lucky.",
          "I do the maths and I don't believe it. I keep going back to look. It still doesn't add up. Brilliant."], "left", "wander")
    chat(z, "hedge_walker", "villager_2", 56, 30, "Walker",
         ["The best way to see the Boyne is on foot. The next best way's by canoe. The worst way's with a map held upside down, which I've tried.",
          "Hedges are Ireland's longest nature reserve. I've no idea who counts them."], "up", "wander")
    trainer(z, "boyne_hurler", "Hurler Cathal", "Hurler", "rugby_player", [("stagmor", 60), ("dextera", 59), ("gealhare", 60)],
            12, 26, "down", ["Meath's a Gaelic football county, but I'm a hurler in exile. Have a puck?"],
            "A good tussle. I'll be seeing you at the match.", "The sliotar's a small leather ball. It's got more stories than a library.", 2900)
    trainer(z, "boyne_birder", "Birdwatcher Una", "Birdwatcher", "birdwatcher", [("heronarch", 60), ("corncrake", 59), ("hushwing", 60)],
            44, 26, "down", ["Kingfishers along the Boyne. I've been waiting since Tuesday. It was worth it."],
            "That's the kingfisher gone. It saw you, it's furious.", "The kingfisher's a flash of blue over the water. Blink and you'll never believe me.", 2880)
    trainer(z, "boyne_angler", "Angler Fergus", "Angler", "angler", [("bradan", 60), ("rillotter", 60), ("parrlet", 59)],
            29, 22, "right", ["The Boyne's a great salmon river. I'm sure it's not a coincidence that the Salmon of Knowledge was here."],
            "Hooked. Reeled in. Landed. Proper job.", "A salmon's got a better memory than I have. And a better sense of direction.", 2920)
    trainer(z, "boyne_fiddler", "Fiddler Roisin", "Fiddler", "harpist", [("gealhare", 60), ("cluricaun", 60), ("bansheen", 61)],
            40, 30, "up", ["I'm on my way to a session in Slane. The fiddle's tuned, the battle's early."],
            "Right. Now I've a reel to play with a broken heart.", "The Boyne valley's full of tunes. Some of them are older than the words for them.", 2960)
    trainer(z, "boyne_warden", "Warden Algernon", "Warden", "warden_grunt", [("rooklet", 59), ("megalorn", 60), ("moolet", 59)],
            24, 30, "up", ["Welcome to Ireland's Ancient East Experience! A prehistoric valley, now with extra queues."],
            "I'll note it as a 'minor access incident'.", "Director Kerrigan says the Boyne is a 'brand'. The Boyne, I think, would like a word.", 2840)
    z.d["edges"] = {"west": {"to": "sligo", "offset": 0}, "south": {"to": "dublin", "offset": 0}, "east": {"to": "newgrange", "offset": 0}}
    z.d["spawn"] = [3, 28]
    wild(z, [("megalorn", 59, 60, 3, {"weather": ["fog"], "time": ["dawn", "dusk"]}), ("rooklet", 59, 60, 14, {}),
             ("rookery", 60, 61, 10, {"time": ["day", "dusk"]}), ("dextera", 59, 60, 10, {"time": ["day"]}), ("moolet", 59, 59, 8, {}),
             ("gealhare", 60, 61, 8, {"time": ["dawn", "dusk"]}), ("hazeldoze", 59, 60, 10, {}),
             ("corncrake", 59, 60, 8, {"time": ["dawn", "day"], "weather": ["clear", "sunshine"]}),
             ("crexling", 59, 59, 6, {"time": ["dawn"]}), ("hushwing", 60, 61, 8, {"time": ["night"]}),
             ("barnling", 59, 60, 6, {"time": ["dusk"]}), ("pooka", 60, 61, 3, {"time": ["night"], "weather": ["fog"]})])
    wild(z, [("bradan", 59, 60, 20, {}), ("parrlet", 59, 60, 16, {}), ("rillotter", 59, 60, 16, {}), ("heronarch", 60, 61, 14, {}), ("spatelord", 60, 61, 12, {"time": ["night"]})], "water")
    finish(z)
    z.save(OUT + "/boyne_valley.json")


def newgrange(OUT):
    W, H = 60, 44
    zid = "newgrange"
    z = Z(zid, "Newgrange", W, H, kind="town", region="ireland_east", music="town_ireland",
          weather={"clear": 22, "sunshine": 18, "drizzle": 24, "fog": 16, "downpour": 8, "frost": 8, "gale": 4})
    z.d["stage"] = "valley"; z.d["town_id"] = "newgrange"
    z.legend["q"] = {"tile": "cobbles", "colour": "#f0f0e8"}                       # white quartz paving
    z.legend["c"] = {"tile": "tall_grass", "colour": "#c9b24a", "prop": "none"}
    z.border("T", 2, gaps=[(0, 27, 2, 3)])
    z.scatter(0, 0, W, H, "P", 18, 2, only="T")
    # the mound: three stepped rings, a white quartz facade at the south foot
    z.height(21, 4, 19, 13, 1); z.height(23, 5, 15, 11, 2); z.height(25, 6, 11, 9, 3)
    z.rect(25, 6, 11, 9, ".")
    z.rect(28, 8, 5, 3, "f")
    z.building(26, 17, 9, 4, "white_render", "Newgrange", door=4)
    z.rect(22, 21, 17, 5, "q"); z.rect(24, 21, 13, 1, "q")
    z.warp(30, 20, "newgrange_tomb", 11, 29, "up")
    z.rect(30, 21, 1, 5, "q")
    z.sign(28, 21, "THE ENTRANCE STONE. Kerbstone K1, the great stone at the door, carved with triple spirals and lozenges. Nobody knows what the spirals meant. They're prehistoric art. They've been guessing for ten thousand years and still can't pin it down.")
    z.sign(32, 21, "THE ROOF BOX. Above the door a small slot lets the rising sun into the chamber for seventeen minutes around the winter solstice, 21 December. It's a calendar, a church and a lightbulb all in one, built five thousand years before anyone coined the term 'engineering'.")
    # the kerb: a ring of standing stones round the mound and a wider circle on the high ground
    import math as m
    for k in range(34):
        a = 2 * m.pi * k / 34
        x, y = int(round(30 + 12.5 * m.cos(a))), int(round(10.5 + 8.5 * m.sin(a)))
        if 22 <= x <= 38 and y >= 16:
            continue
        if 2 <= x < W - 2 and 2 <= y < H - 2:
            z.prop("standing_stone", x, y, variant=k % 3)
    for k in range(12):
        a = 2 * m.pi * k / 12 + 0.2
        x, y = int(round(30 + 19 * m.cos(a))), int(round(11 + 12 * m.sin(a)))
        if 3 <= x < W - 3 and 3 <= y < 24:
            z.prop("standing_stone", x, y, variant=(k + 1) % 3)
    # roads, forecourt and the visitor centre
    z.rect(2, 27, 56, 3, "="); z.rect(2, 26, 56, 1, ":"); z.rect(2, 30, 56, 1, ":")
    z.rect(22, 26, 17, 1, ":")
    z.building(4, 20, 14, 5, "cream_render", "Visitor Centre")
    z.rect(4, 25, 14, 1, ":"); z.prop("bench", 6, 26); z.prop("bench", 16, 26)
    z.sign(11, 26, "BRU NA BOINNE VISITOR CENTRE. Tickets, a cafe and a replica of the passage. Newgrange tours go by shuttle bus over the river. The winter solstice places go by lottery, and some years it rains anyway.")
    # Sanctuary, Corner Shop and a farmhouse cafe
    z.building(41, 22, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(48, 22, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(44, 25, "newgrange_sanctuary", 5, 6, "up"); z.warp(50, 25, "newgrange_shop", 4, 5, "up")
    z.building(4, 31, 7, 4, "white_render", "Farmhouse Cafe")
    z.building(12, 31, 6, 4, "slate_cottage", show_label=False)
    z.building(44, 31, 7, 4, "tudor", "The Boyne Inn")
    z.rect(2, 35, 55, 1, ":")
    for x in (6, 14, 24, 36, 42, 54):
        z.prop("lamp_post", x, 26)
    for x in (8, 20, 40, 52):
        z.prop("lamp_post", x, 30)
    z.prop("phone_box", 3, 26); z.prop("post_box", 55, 30); z.prop("bench", 28, 26); z.prop("bench", 34, 26)
    # tall grass, fields and trees
    for (x, y, w, h) in [(4, 6, 10, 8), (45, 6, 10, 8), (4, 38, 12, 4), (20, 38, 14, 4), (40, 38, 14, 4)]:
        z.rect(x, y, w, h, ",")
    for (x, y, w, h) in [(14, 6, 5, 8), (40, 6, 5, 8), (36, 36, 4, 5)]:
        z.rect(x, y, w, h, "c")
    for (x, y, w, h) in [(2, 14, 6, 1), (50, 14, 6, 1), (2, 36, 55, 1)]:
        z.rect(x, y, w, h, "H")
    for (x, y) in [(6, 14), (52, 14), (30, 36), (10, 36), (40, 36)]:
        z.set(x, y, ".")
    z.rect(30, 36, 1, 1, "#")
    scatter_props(z, "oak", 3, 3, 54, 24, 10, 6, avoid=(".", ","))
    scatter_props(z, "bush", 3, 3, 54, 38, 18, 7, avoid=(".",))
    # NPCs
    chat(z, "ng_guide", "tour_guide", 28, 25, "Tour Guide",
         ["Newgrange: built about 3200 BC, with roughly 200,000 tonnes of stone and earth. That's five hundred years older than the Great Pyramid and a thousand older than Stonehenge.",
          "The white quartz on the front was brought from Wicklow, sixty-odd miles off, and the grey stones from the Boyne. On a bright day, the whole thing glitters like a very big, very old iPhone."], "right", "still")
    chat(z, "lottery_winner", "student", 18, 28, "Lucky Visitor",
         ["Every year around 30,000 people enter the lottery for the winter solstice. Fifty get in, two at a time. I'm the first Munster winner since 1994.",
          "You stand in the dark, and then a thin line of gold comes down the passage. They say it's just the sun. I say it's still astonishing."], "up", "wander")
    chat(z, "ng_farmer", "farmer", 52, 28, "Local Farmer",
         ["My family's farmed beside this tomb for generations. We found stones in the field every year. Mostly we put them back. They looked cross.",
          "There are three tombs: Newgrange, Knowth and Dowth. Knowth has more carved stones than all the rest of Europe's. I've only half the facts, but I've all the pride."], "left", "still")
    chat(z, "ng_archaeologist", "hiker", 36, 28, "Archaeologist",
         ["Professor O'Kelly led the dig and rebuilding in the 1960s and 70s. The quartz wall's controversial, but I'm told the roof really does keep out the rain.",
          "After five thousand years, only one thing's had to be fixed: the roof of the passage. The Neolithic builders would be insulted."], "right", "wander")
    chat(z, "spiral_kid", "villager_5", 24, 24, "Child",
         ["There are three spirals joined at the middle, on the big stone at the door. I drew it on my hand with a pen. Mam says I'm not allowed near the stones.",
          "I think it's a map. Or a bus route. Or the world's first doodle."], "right", "wander")
    trainer(z, "ng_warden", "Warden Quentin", "Warden", "warden_grunt", [("rookery", 61), ("megalorn", 61), ("moolet", 61)],
            38, 24, "left", ["Welcome to the Boyne Valley Heritage Experience! The Stone Age, now with a gift shop and a one-way system."],
            "A momentary setback. It's a Stone Age problem.", "Director Kerrigan says the solstice should be 'bookable year-round'. Can you book the sun?", 3100)
    trainer(z, "ng_druid", "Druid Brannoc", "Druid", "villager_6", [("pooka", 61), ("bansheen", 61), ("hushwing", 61)],
            22, 24, "right", ["I'm a druid re-enactor, full time. Today's rite: 'Man in Cloak Glares at Tourists.' Join in, please."],
            "I was beaten by a day-tripper. I'll need to rethink my cloak.", "I do the winter solstice every year, in a very large hat. I love it.", 3080)
    z.d["edges"] = {"west": {"to": "boyne_valley", "offset": 0}}
    z.d["spawn"] = [6, 28]
    wild(z, [("rookery", 61, 61, 12, {"time": ["day", "dusk"]}), ("rooklet", 61, 61, 8, {}), ("dextera", 61, 61, 8, {"time": ["day"]}),
             ("gealhare", 61, 61, 8, {"time": ["dawn", "dusk"]}), ("hushwing", 61, 61, 10, {"time": ["night"]}),
             ("bansheen", 61, 61, 5, {"time": ["night"], "weather": ["fog"]}), ("pooka", 61, 61, 4, {"time": ["night"]}),
             ("corncrake", 61, 61, 8, {"time": ["dawn", "day"]}), ("hazeldoze", 61, 61, 8, {})])
    finish(z)
    z.save(OUT + "/newgrange.json")
    sanctuary(OUT, "newgrange", "Newgrange", (44, 26), music="sanctuary")
    shop(OUT, "newgrange", "Newgrange", (50, 26))
    nurse("newgrange", ["Welcome to Newgrange Sanctuary. We're only five thousand years younger than the tomb. Pop your team on the counter.",
                        "Sit by the fire. It's the one thing older than the roof that's still working.",
                        "All done. Slán abhaile, and don't forget your hat. It's cold in the passage.",
                        "The Ark terminal's here. It's the newest thing in the valley, by about five thousand years.",
                        "No worries. Take a seat. The solstice isn't for a while yet."])
    shopkeeper("newgrange", "Dia duit! Snares, tea, a laminated spiral and a very big scone. The scone's not older than the tomb. Probably.",
               "Slán! And mind the sun. Some mornings it's seventeen minutes. Other mornings it's gone.")


def tomb(OUT):
    W, H = 23, 32
    z = Z("newgrange_tomb", "Newgrange Passage Tomb", W, H, fill="x", kind="interior", region="", music="legend_crow", weather={})
    z.d["stage"] = "cave"
    z.legend["k"] = {"tile": "path", "colour": "#6e6c66"}
    z.rect(10, 18, 3, 12, "k")
    z.rect(7, 8, 9, 10, "k"); z.rect(3, 11, 4, 4, "k"); z.rect(16, 11, 4, 4, "k"); z.rect(9, 4, 5, 4, "k")
    z.set(11, 30, "D")
    z.warp(11, 30, "newgrange", 30, 21, "down")
    for (x, y, v) in [(7, 9, 0), (15, 9, 1), (7, 16, 2), (15, 16, 0), (10, 22, 1), (12, 24, 2)]:
        z.prop("standing_stone", x, y, variant=v)
    for (x, y, v) in [(4, 12, 1), (19, 12, 2), (11, 5, 0)]:
        z.prop("rock", x, y, variant=v)
    z.sign(10, 20, "THE PASSAGE. Nineteen metres of narrow corridor between huge slabs, rising slightly to the chamber so the sunbeam can travel all the way. Mind your head, mind your shoulders, and spare a thought for the builders.")
    z.sign(12, 19, "THE ROOF BOX. The slot above the door sends a beam of the rising sun straight down the passage on the winter solstice, onto the chamber floor. It lasts about seventeen minutes. It's one of the oldest clocks in Europe.")
    z.sign(5, 14, "THE WEST RECESS. A great basin stone, carved with spirals, where the cremated remains of the dead were laid. The spirals are about as old as writing. They don't say.")
    z.sign(18, 14, "THE EAST RECESS. Another basin stone, carved with the triple spiral, three loops joined in one line. It's Newgrange's trademark.")
    z.sign(10, 6, "THE NORTH RECESS. The deepest part of the tomb. The corbelled roof soars overhead, each stone set a little further in, until the last slab closes the dome. It has not leaked in five thousand years.")
    z.sign(8, 11, "CARVED STONES. Spirals, lozenges, zigzags and eyes, in a language we've forgotten. Some are hidden behind the slabs, where only the builders and the dead could see.")
    chat(z, "tomb_guide", "tour_guide", 10, 25, "Tomb Guide",
         ["Quiet, please. This is a five-thousand-year-old burial chamber, not a bus shelter. I'll turn out the lights, and you'll see what the sun did every winter.",
          "The lights go down, the lamp goes gold, a single beam crawls up the floor. People gasp. A few cry. I've seen a grown man ask for his mother."], "right", "still")
    z.npc(id="kerrigan_tomb", sprite="kerrigan", x=11, y=27, facing="down", move="still", script="kerrigan_tomb")
    script("newgrange_tomb", "kerrigan_tomb", say("Director Kerrigan", "Placeholder: the story agent writes Kerrigan's second battle here."))
    z.npc(id="morrigan_spot", sprite="creature:morrigan", x=11, y=6, facing="down", move="still", script="morrigan")
    script("newgrange_tomb", "morrigan", say("The Morrigan", "Placeholder: the story agent writes the Morrigan's awakening here."))
    z.d["spawn"] = [11, 29]
    finish(z)
    z.save(OUT + "/newgrange_tomb.json")
