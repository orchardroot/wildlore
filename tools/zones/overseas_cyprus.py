# Wildlore 3.3 "Overseas", wave 33 agent 1: the Sovereign Base Areas of Akrotiri and Dhekelia (Cyprus).
#
#   python3 tools/zones/overseas_cyprus.py        (from the repo root)
#
# Two outdoor zones: `akrotiri` (RAF Akrotiri's runway, Episkopi, the Akrotiri Salt Lake with its flamingos, Lady's
# Mile, Kourion's theatre on the cliff, St Nicholas of the Cats) and `dhekelia` (the garrison, the carob and olive
# country, the coast, the village kafeneio and the Green Line). All scaled from par 95.
from overseas_lib import *
from wcommon import _stand

TERR = "akrotiri_dhekelia"
QF = "q_overseas_akrotiri_dhekelia"
COLOURS = {"g": {"tile": "grass", "colour": "#cbb870"}, "k": {"tile": "tall_grass", "colour": "#b0a05a"},
           "c": {"tile": "cobbles", "colour": "#dcd0b4"}, "a": {"tile": "path", "colour": "#e8dcbc"},
           "l": {"tile": "sand", "colour": "#f3eee2"}, "L": {"tile": "sand", "colour": "#eab3c0"},
           "M": {"tile": "tall_grass", "colour": "#dc92aa", "prop": "none"}}


def fresh(zid, name, w, h, kind, music):
    z = Z(zid, name, w, h, kind=kind, region="overseas_akrotiri_dhekelia", music=music,
          weather={"clear": 38, "sunshine": 38, "fog": 2, "drizzle": 6, "gale": 6, "downpour": 6})
    z.d["scaled_floor"] = FLOOR
    z.legend.update(COLOURS)
    z.rect(0, 0, w, h, "g")
    return z


def akrotiri():
    zid = "akrotiri"
    W, H = 80, 60
    z = fresh(zid, "Akrotiri", W, H, "town", "route_coast")
    z.d["stage"] = "coast"
    z.border("P", 2, gaps=[(78, 33, 2, 3)])
    # ---- sea to the south, with Lady's Mile along the shore
    for y in range(54, H):
        for x in range(0, W):
            z.set(x, y, "$" if y > 56 else ("w" if y == 56 else "s"))
    z.rect(2, 52, 76, 2, "s")
    # ---- the airfield: runway, apron, terminal, tower, hangars, a pair of transports
    z.rect(4, 6, 72, 3, "=")
    z.rect(20, 9, 50, 1, ":")
    bld(z, 52, 13, 12, 5, "raf_terminal", "Air Terminal", 6, "akrotiri_terminal")
    z.rect(36, 18, 34, 2, ":")
    bld(z, 46, 13, 4, 5, "control_tower", "Control Tower", None)
    bld(z, 18, 14, 12, 5, "raf_hangar", show_label=False)
    bld(z, 32, 14, 12, 5, "raf_hangar", show_label=False)
    z.building(6, 10, 9, 4, "raf_aircraft", None)
    plaque(z, 66, 11, TERR, "raf", "RAF Akrotiri",
           "RAF Akrotiri is a Royal Air Force station on the Akrotiri peninsula, built in the 1950s and one of the RAF's most important bases overseas. Its long runway has served as a stepping stone for flights from Britain to the Middle East for generations, and as a base for operations in the region. Most of the people who work here are in uniform; most of the people who help them are Cypriot.")
    plaque(z, 36, 20, TERR, "sba", "The Sovereign Base Areas",
           "When Cyprus became independent in 1960, the United Kingdom kept two areas of the island as Sovereign Base Areas: Akrotiri in the south-west and Dhekelia in the south-east, about 254 square kilometres in all. The Treaty of Establishment promised that they would stay military bases, with no colonies and no commercial development. A great many Cypriots live and work in the villages inside them.")
    # ---- Episkopi cantonment and the road
    path(z, [(40, 19), (40, 52)], "=", 4)
    z.rect(34, 25, 28, 1, "c")
    bld(z, 46, 21, 6, 4, "raf_block", "NAAFI", 3)
    z.warp(49, 24, "akrotiri_shop", 4, 5, "up")
    bld(z, 54, 21, 6, 4, "raf_block", "Sanctuary", 3)
    z.warp(57, 24, "akrotiri_sanctuary", 5, 6, "up")
    bld(z, 62, 21, 8, 5, "limestone_church", "Garrison Church", 4, "akrotiri_church")
    bld(z, 46, 28, 6, 4, "flat_house", show_label=False)
    bld(z, 54, 28, 6, 4, "flat_house", show_label=False)
    z.rect(34, 33, 28, 1, "c")
    bld(z, 30, 28, 6, 4, "flat_house", show_label=False)
    bld(z, 46, 34, 6, 4, "flat_house", show_label=False)
    bld(z, 54, 34, 6, 4, "flat_house", show_label=False)
    z.rect(44, 25, 18, 1, "c")
    for (x, y) in [(36, 24), (44, 24), (52, 26), (60, 26), (38, 32), (58, 32)]:
        z.prop("lamp_post", x, y)
    plaque(z, 44, 26, TERR, "episkopi", "Episkopi",
           "Episkopi is a British garrison town inside the Akrotiri Sovereign Base Area, with a church, a school, a NAAFI shop and a lot of palm trees. The families who live here are British service families and the Cypriot staff who work alongside them. Its name means 'bishopric' in Greek, which tells you it had a church long before it had a garrison.")
    # ---- the Akrotiri Salt Lake, white at the edge and pink in the middle
    blob(z, 18, 36, 17, 8, "l", only="g", seed=3, jitter=0.2)
    blob(z, 18, 36, 14, 6, "L", only="gl", seed=4, jitter=0.2)
    blob(z, 18, 36, 10, 4, "M", only="gLl", seed=5, jitter=0.15)
    bld(z, 24, 42, 6, 4, "flat_house", "Environmental Centre", 3, "akrotiri_centre")
    z.rect(24, 46, 6, 1, "a")
    path(z, [(27, 46), (27, 50)], "a", 1)
    for (x, y) in [(4, 28), (32, 28), (4, 44), (32, 44)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    plaque(z, 36, 38, TERR, "salt_lake", "The Akrotiri Salt Lake",
           "The salt lake is a shallow lagoon behind the Akrotiri peninsula, much of which dries to a white salt crust in summer. In winter it fills with rain, and thousands of greater flamingos, ducks and waders arrive from the north. The salt was harvested here for centuries, and the pink colour is from a tiny shrimp and salt-loving algae.")
    plaque(z, 14, 27, TERR, "flamingos", "The Flamingos",
           "The greater flamingo is a tall, pink bird that feeds by sweeping its curved bill through the shallow water and filtering out shrimp. The shrimp's pigments are what turn the flamingos pink. The Akrotiri Salt Lake is one of the best places to see them in the Mediterranean, and the birds stand on one leg to save warmth, and because they can.")
    plaque(z, 12, 50, TERR, "turtles", "The Turtle Beaches",
           "The Akrotiri beaches are nesting sites for the green turtle and the loggerhead. The females come ashore at night in summer, dig a pit, and lay about a hundred eggs. The hatchlings emerge two months later and run for the sea, guided by the horizon's brightness. Lights on the beach can lead them the wrong way, so the beach has quiet hours.")
    plaque(z, 36, 54, TERR, "ladys_mile", "Lady's Mile",
           "Lady's Mile is a long sand beach on the south coast of the Akrotiri peninsula, backed by dunes and a lagoon, and a favourite with swimmers, windsurfers and walkers. In spring the dunes are green with plants that have learnt to survive on salt and wind.")
    # ---- St Nicholas of the Cats, at the tip of the peninsula
    bld(z, 6, 44, 8, 5, "limestone_church", "St Nicholas of the Cats", 4, "akrotiri_cats")
    z.rect(6, 49, 8, 1, "a")
    path(z, [(10, 49), (10, 52)], "a", 1)
    plaque(z, 14, 49, TERR, "cats", "St Nicholas of the Cats",
           "The monastery of St Nicholas of the Cats, on the Akrotiri peninsula, takes its name from a legend. In the 4th century, Cyprus suffered a drought and a plague of snakes, and Saint Helena, the mother of the Emperor Constantine, is said to have sent a shipload of cats from Egypt to kill them. The monastery kept the cats, and it still has them.")
    # ---- Kourion on its cliff, to the east
    bld(z, 62, 40, 12, 7, "greek_theatre", "Kourion Theatre", None)
    bld(z, 62, 48, 8, 4, "flat_house", "House of Eustolios", 3, "akrotiri_eustolios")
    z.rect(60, 38, 16, 1, "a")
    z.rect(60, 52, 14, 1, "a")
    path(z, [(60, 26), (60, 52)], "a", 2)
    z.rect(62, 33, 18, 3, "a")
    for (x, y) in [(58, 38), (76, 38), (60, 47), (74, 47)]:
        z.prop("statue", x, y, variant=(x + y) % 3)
    plaque(z, 66, 38, TERR, "kourion", "Kourion",
           "Kourion was one of the ancient city-kingdoms of Cyprus, perched on a cliff above the sea. Its Greco-Roman theatre was first built in the 2nd century BC and rebuilt several times, and seated about 3,500 people. It is still used for summer performances, with the sea behind the stage.")
    plaque(z, 66, 52, TERR, "eustolios", "The House of Eustolios",
           "The House of Eustolios was a grand villa at Kourion, with a bath suite and floors of mosaic. The mosaics date from the early Christian period, and a Greek inscription reads, roughly, that there was no place there for envy. The house was built about the 5th century, after the city had begun to decline.")
    z.rect(77, 38, 3, 22, "P")
    scatter_props(z, "pine", 3, 3, 74, 48, 22, 3, avoid=("g",))
    scatter_props(z, "bush", 3, 3, 74, 48, 36, 4, avoid=("g",))
    for (cx, cy, rx, ry, s) in [(10, 14, 4, 2, 1), (74, 14, 3, 3, 2), (70, 30, 4, 2, 3), (6, 24, 3, 3, 4), (44, 50, 5, 2, 5), (74, 56, 2, 1, 6)]:
        blob(z, cx, cy, rx, ry, "k", only="g", seed=s, jitter=0.3)

    # ---- people and the salt-lake creatures
    for (sp, x, y) in [("brineling", 18, 31), ("brineling", 6, 36), ("brineling", 18, 41), ("brineflame", 30, 36)]:
        _stand(z, x, y)
        z.npc(id="c_%s_%d_%d" % (sp, x, y), sprite="creature:" + sp, x=x, y=y, facing="down", move="wander", script="c_" + sp)
    script(zid, "c_brineling", say1("Brineling", "It stands on one leg and stares at you with a look of deep and total calm. It has been doing this since before breakfast."))
    script(zid, "c_brineflame", say1("Brineflame", "A flame-pink flamingo at the heart of the lake, glowing like the sunset. It looks at you the way a very important person looks at a waiter."))
    chat(z, "akr_cypriot", "villager_4", 44, 27, "Akrotiri Resident",
         ["I'm Cypriot, and I live in a village inside the Base Area. The British have the bases, and the Republic of Cyprus has the rest, and the villages in between all get on with their lives.",
          "Everyone has a cousin on the other side of the fence. Nobody minds. Coffee is coffee."], "down")
    chat(z, "akr_kafe", "shopkeeper", 56, 26, "Kafeneio Owner",
         ["Cypriot coffee, boiled in a little pot and served with the grounds still in. Never stir it, and never drink the last sip.",
          "Order it metrios, medium sweet. Or sketos, no sugar. Or glykos, which is sugar with a bit of coffee."], "down")
    chat(z, "akr_flight", "sailor", 60, 20, "RAF Crew",
         ["I've flown to Akrotiri more times than I can count. It's the last decent stop before the Gulf, and the first on the way home.",
          "The runway is long, the sea is warm, and the tea, I'm told, is passable."], "down")
    chat(z, "akr_diver", "surfer", 30, 50, "Diver",
         ["The water off Akrotiri is clear as a bell. You can see sixty feet down on a calm day, to the sand and the old pottery.",
          "The coast has a lot of old shipwrecks and a lot of amphora fragments. Take only photographs and leave only bubbles."], "right")
    chat(z, "akr_archaeologist", "prof_garside", 64, 36, "Archaeologist",
         ["Look at the stage. The sea behind it isn't an accident: the Greeks liked a view. They built a theatre to be seen against the horizon.",
          "Earthquakes took Kourion in the 4th century, and the rest we've dug up with trowels and a lot of patience."], "down")
    chat(z, "akr_monk", "druid", 10, 51, "Monk",
         ["I look after the cats. There are about thirty of them at the moment, and they have never once listened to me.",
          "The legend says the monastery was founded to house the cats that Saint Helena sent. I say they came to us, and we've just never made them leave."], "up")
    chat(z, "akr_ranger", "ghillie", 20, 43, "Turtle Ranger",
         ["In summer I walk the beach at night with a red torch. The turtles hate white light.",
          "If you find a nest, mark it and tell me. Don't touch it. The baby turtles know what they're doing."], "left")

    trainer(z, "akr_warden", "Flamingo Warden", "Warden", "ghillie",
            [("heronarch", 95), ("levelcrane", 95), ("brineflame", 95)], 24, 40, "up",
            ["Keep your voice down: one cough and the whole flock goes up like pink fireworks.", "We'll have to do this in whispers."],
            "Not a feather out of place. Well done.", "A hide at dawn, with the lake turning from grey to pink: nothing else is like it.", 4400)
    trainer(z, "akr_gunner", "RAF Regiment Gunner", "RAF Regiment", "hurler",
            [("shieldbiter", 95), ("bombardon", 95), ("steelheart", 95)], 38, 21, "right",
            ["I'm RAF Regiment. Our motto is 'Per ardua', and our other motto is 'Mind that fence'.", "Defending an airfield means never taking your eye off the sky."],
            "Right, right. You'd have made a decent Airman.", "My grandad was in this regiment. He said the heat was the only enemy that never retreated.", 4300)
    trainer(z, "akr_diver_t", "Dive Instructor", "Diver", "surfer",
            [("glimmerjaw", 95), ("merrow", 95), ("clawcastle", 95)], 28, 52, "up",
            ["Keep your breathing steady. I'll teach you to read the water.", "Let's see how you handle a bit of current."],
            "Lovely buoyancy. You're a natural.", "The first rule of diving is never to hold your breath. The second is never to say 'I'll just have a look'.", 4200)
    trainer(z, "akr_dig", "Dig Supervisor", "Archaeologist", "astronomer",
            [("tesserite", 95), ("sarsenite", 95), ("chalkling", 95)], 68, 47, "up",
            ["Careful: that tile is two thousand years old and about as sturdy as a digestive biscuit.", "If you want to walk on my mosaic, you'll have to win."],
            "Fine, fine. Walk on it. But take your shoes off.", "The trick is to dig slowly and write it all down. The dig is the least of it.", 4300)
    trainer(z, "akr_cat_monk", "Cat Monk", "Legend of Akrotiri", "pilgrim",
            [("wildkit", 95), ("highlynx", 95), ("cusith", 95), ("grinalkin", 95)], 8, 51, "right",
            ["There are more cats here than monks, and more of both than snakes.", "You'll find the cats here are of a martial persuasion. Please take care."],
            "The cats approve. I can tell by how they're not looking at you.", "They do not belong to us. We belong to them. It is an old and happy arrangement.", 6400)
    scale_all(["akr_warden", "akr_gunner", "akr_diver_t", "akr_dig", "akr_cat_monk"])

    wild(z, [("heronarch", 95, 97, 8, {}), ("levelcrane", 95, 97, 8, {}), ("brineling", 95, 97, 14, {}), ("brineflame", 96, 98, 3, {"time": ["dawn", "dusk"]}),
             ("stalklet", 95, 97, 10, {}), ("cranelet", 95, 97, 10, {}), ("duneskink", 95, 97, 10, {}), ("kitelet", 95, 97, 8, {"time": ["day"]}),
             ("swiftlet", 95, 97, 8, {"time": ["day", "dawn"]}), ("tesserite", 95, 97, 6, {}), ("wildkit", 95, 97, 6, {"time": ["dusk", "night"]}),
             ("hootlet", 95, 97, 6, {"time": ["night"]}), ("dozelet", 95, 97, 6, {}), ("scuttlet", 95, 97, 8, {}), ("sapperling", 95, 97, 3, {})])
    wild(z, [("brineling", 95, 97, 14, {}), ("heronarch", 95, 97, 8, {}), ("stalklet", 95, 97, 10, {}), ("dipling", 95, 97, 10, {}),
             ("pinchkin", 95, 97, 8, {}), ("dolfeen", 95, 97, 6, {}), ("glimmerjaw", 95, 97, 4, {}), ("puffling", 95, 97, 6, {})], "water")
    z.d["edges"] = {"east": {"to": "dhekelia", "offset": 0}}
    z.d["spawn"] = [58, 19]
    fringe(z)
    smooth(z)
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "Akrotiri", (57, 25))
    shop(OUT, zid, "Akrotiri", (49, 25))
    nurse(zid, ["Kalimera, good morning, and welcome to the Sanctuary. Or the Medical Centre, if you want to be formal, which we never are.",
                "Pop your team on the bed. We treat sunburn, snakebite and the occasional case of sea urchin, which is every Wednesday.",
                "There we go: good as new. Drink lots of water, wear a hat, and stay in the shade when you can.",
                "The Ark is in the cool room at the back, which is the nicest room in the building.",
                "No hurry. In this heat, hurrying is a sin."])
    shopkeeper(zid, "Hello, and welcome to the NAAFI. Cold drinks, halloumi and every British biscuit you've ever missed. What'll it be?",
               "Efharisto, thank you. Take care of the sun.")

    landmark(OUT, "akrotiri_terminal", "Air Terminal", zid, (58, 18), "hall", [
        dict(id="akr_movements", sprite="rail_guard", x=6, y=2, facing="down", move="still", script="akr_movements", name="RAF Movements"),
        dict(id="akr_traveller", sprite="commuter", x=10, y=5, facing="left", move="still", script="akr_traveller", name="Traveller")])
    landmark(OUT, "akrotiri_church", "Garrison Church", zid, (66, 26), "church", [
        dict(id="akr_padre", sprite="pilgrim", x=6, y=2, facing="down", move="still", script="akr_padre", name="Padre")])
    landmark(OUT, "akrotiri_centre", "Akrotiri Environmental Centre", zid, (27, 46), "museum", [
        dict(id="akr_centre_warden", sprite="ghillie", x=5, y=3, facing="right", move="still", script="akr_centre_warden", name="Centre Warden"),
        dict(id="akr_centre_birder", sprite="birdwatcher", x=8, y=4, facing="left", move="still", script="akr_centre_birder", name="Birder")])
    landmark(OUT, "akrotiri_cats", "St Nicholas of the Cats", zid, (10, 49), "church", [
        dict(id="akr_prior", sprite="druid", x=6, y=2, facing="down", move="still", script="akr_prior", name="Prior"),
        dict(id="akr_cat_a", sprite="creature:wildkit", x=1, y=3, facing="down", move="still", script="akr_cat", name="Cat"),
        dict(id="akr_cat_b", sprite="creature:wildkit", x=9, y=4, facing="down", move="still", script="akr_cat", name="Cat")])
    landmark(OUT, "akrotiri_eustolios", "House of Eustolios", zid, (65, 52), "museum", [
        dict(id="akr_mosaic_guide", sprite="tour_guide", x=5, y=3, facing="right", move="still", script="akr_mosaic_guide", name="Site Guide")])


def dhekelia():
    zid = "dhekelia"
    W, H = 64, 56
    z = fresh(zid, "Dhekelia", W, H, "town", "route_coast")
    z.d["stage"] = "coast"
    z.border("P", 2, gaps=[(0, 33, 2, 3)])
    for y in range(H):
        for x in range(W):
            if y >= 46:
                z.set(x, y, "$" if y > 48 else ("w" if y == 48 else "s"))
    z.rect(2, 44, 60, 2, "s")
    path(z, [(2, 34), (30, 34), (30, 12)], "=", 3)
    path(z, [(30, 34), (30, 44)], "a", 2)
    z.d["spawn"] = [4, 35]
    # the garrison
    bld(z, 40, 14, 8, 4, "raf_block", "Sanctuary", 4)
    z.warp(44, 17, "dhekelia_sanctuary", 5, 6, "up")
    bld(z, 50, 14, 8, 4, "raf_block", "Garrison Shop", 4)
    z.warp(54, 17, "dhekelia_shop", 4, 5, "up")
    bld(z, 40, 22, 8, 4, "raf_block", "Garrison Hall", 4, "dhekelia_hall")
    bld(z, 50, 22, 6, 4, "raf_block", show_label=False)
    z.rect(34, 18, 24, 1, "c")
    z.rect(34, 26, 24, 1, "c")
    path(z, [(34, 18), (34, 29)], "c", 2)
    z.prop("flagpole", 39, 19, variant=6)
    z.prop("flagpole", 59, 19, variant=6)
    # the village and its kafeneio
    bld(z, 8, 14, 6, 4, "flat_house", "Kafeneio", 3, "dhekelia_kafeneio", iw=11, ih=9)
    bld(z, 16, 14, 6, 4, "flat_house", show_label=False)
    bld(z, 8, 22, 6, 4, "flat_house", show_label=False)
    bld(z, 16, 22, 6, 4, "flat_house", "Village Church", 3, "dhekelia_chapel")
    z.rect(6, 18, 18, 1, "c")
    z.rect(6, 26, 18, 1, "c")
    for (x, y) in [(10, 19), (18, 19), (10, 27), (18, 27)]:
        z.prop("lamp_post", x, y)
    # carob and olive groves, the coast
    z.rect(0, 38, 3, 18, "P")
    scatter_props(z, "oak", 4, 32, 50, 12, 30, 7, avoid=("g",))
    scatter_props(z, "bush", 4, 4, 56, 40, 40, 8, avoid=("g",))
    blob(z, 46, 38, 8, 4, "k", only="g", seed=2, jitter=0.3)
    blob(z, 12, 38, 6, 4, "k", only="g", seed=3, jitter=0.3)
    blob(z, 10, 8, 6, 3, "k", only="g", seed=4, jitter=0.3)
    blob(z, 56, 8, 5, 3, "k", only="g", seed=5, jitter=0.3)
    blob(z, 56, 32, 5, 4, "k", only="g", seed=6, jitter=0.3)
    plaque(z, 36, 20, TERR, "garrison", "Dhekelia Garrison",
           "Dhekelia is the eastern Sovereign Base Area, a stretch of coast on Larnaca Bay, with a British garrison and a number of Cypriot villages inside its boundary. The garrison has existed since the 1950s, and it houses soldiers, families, schools and, like every British garrison, a very good NAAFI.")
    plaque(z, 32, 40, TERR, "carob", "The Carob Tree",
           "Cyprus has grown carobs for thousands of years, and the dark, sticky pods were once the island's best-known export. The tiny seeds were so regular in weight that people used them to weigh gold, and the word 'carat' comes from the Greek name for a carob seed. The tree is still all over the island, usually looking contentedly crooked.")
    plaque(z, 24, 38, TERR, "olive", "The Olive Groves",
           "Olive trees on Cyprus live for centuries and look it, with trunks twisted like rope. The fruit is picked by hand in autumn, and the oil is pressed within a day. A Cypriot lunch is a plate of olives, a bit of halloumi, some bread and a lot of time.")
    plaque(z, 54, 40, TERR, "bay", "Larnaca Bay",
           "The sea in front of Dhekelia is Larnaca Bay, warm and shallow with a bottom of fine sand. The water is clear enough to see your toes, and the beach is lined with tamarisk trees that have learned to put up with salt and wind. In the distance lies the coast of the island.")
    plaque(z, 4, 20, TERR, "green_line", "The Green Line",
           "Since the 1974 division of Cyprus, a United Nations buffer zone known as the Green Line has run across the island from sea to sea, patrolled by UN peacekeepers. Dhekelia lies close to the buffer zone in the east. Many Cypriots on both sides hope for a peaceful settlement, and the UN has been there for decades to help keep the peace.")

    chat(z, "dhk_grower", "farmer", 28, 38, "Carob Grower",
         ["Carob syrup is the old sweetener of Cyprus: dark, thick and tasting a bit like toffee. My grandmother said it cured anything, and I've never proved her wrong.",
          "The pods are ground to a flour, too. It tastes of chocolate and is much better for the teeth."], "right")
    chat(z, "dhk_kafe", "villager_2", 12, 19, "Kafeneio Regular",
         ["I've been at this table since 1998. They tried to move me once, but the table wouldn't go.",
          "We play tavli here, which you'd call backgammon. The trick is to blame the dice and never your own wrist."], "down")
    chat(z, "dhk_fisher", "fisherman_north", 40, 42, "Fisherman",
         ["There are fewer fish than there used to be, but more of them in the right places. The bay's warm, and the sea bream like it.",
          "The best catch of the year is always the one that got away. It's a very large fish by the end of the evening."], "right")
    chat(z, "dhk_kid", "villager_6", 34, 24, "Garrison Child",
         ["My dad is in the Army and my mum is in the school. We've lived in Germany, Scotland and here. Here is the warmest.",
          "I have a Cypriot friend named Andreas. We trade crisps for pastries every Friday. I'm getting the better deal."], "down")
    chat(z, "dhk_peacekeeper", "rail_guard", 5, 32, "UN Observer",
         ["I'm stationed up the road, along the buffer zone. It's a quiet job, which is the idea.",
          "Everything we do is meant to make sure the next day is the same as the last. It's the oddest kind of success."], "right")

    trainer(z, "dhk_sergeant", "Garrison Sergeant", "Sergeant", "hurler",
            [("steelheart", 95), ("shieldbiter", 95), ("samsonian", 95)], 32, 22, "right",
            ["On parade! Right turn! Eyes front! And now you may stand easy, which is more than I can say for your stance.", "Drill is simple. You do what I say and I don't shout."],
            "Not bad. Not good, but not bad.", "I've drilled four thousand recruits. Two thousand of them had two left feet. I've forgotten the rest.", 4300)
    trainer(z, "dhk_grove", "Olive Farmer", "Farmer", "farmer",
            [("greenman", 95), ("thornwyn", 95), ("wistoak", 95)], 22, 34, "right",
            ["Careful of the trees. They're older than your country.", "If you want to fight me, you'll have to do it politely and avoiding the olives."],
            "Aye, well. The harvest starts tomorrow, and I've an excuse for being late.", "My great-grandfather planted these. He said 'plant a tree for those who come after.' I planted three. One of them died.", 4100)
    trainer(z, "dhk_beach", "Bay Swimmer", "Swimmer", "surfer",
            [("dolphlet", 95), ("selkie", 95), ("gannetling", 95)], 44, 43, "up",
            ["The water is perfect today. Forty minutes out and forty back. Do you want to race?", "Fine, a fight instead. Please don't splash."],
            "Impressive. You're a strong swimmer, and a stronger sport.", "The trick is to get in slowly, and to leave before you get cold. Neither of which I ever do.", 4000)
    scale_all(["dhk_sergeant", "dhk_grove", "dhk_beach"])

    wild(z, [("duneskink", 95, 97, 14, {}), ("scuttlet", 95, 97, 10, {}), ("wildkit", 95, 97, 6, {"time": ["dusk", "night"]}), ("dozelet", 95, 97, 8, {}),
             ("tesserite", 95, 97, 6, {}), ("kitelet", 95, 97, 8, {"time": ["day"]}), ("swiftlet", 95, 97, 8, {"time": ["day", "dawn"]}),
             ("hootlet", 95, 97, 6, {"time": ["night"]}), ("greenman", 95, 97, 4, {}), ("thornwyn", 95, 97, 4, {}),
             ("brineling", 95, 97, 4, {}), ("sapperling", 95, 97, 4, {}), ("flittermouse", 95, 97, 6, {"time": ["night"]})])
    wild(z, [("dolphlet", 95, 97, 14, {}), ("bayrunner", 95, 97, 10, {}), ("gannetling", 95, 97, 10, {}), ("pinchkin", 95, 97, 10, {}),
             ("glimmerjaw", 95, 97, 4, {}), ("puffling", 95, 97, 6, {})], "water")
    z.d["edges"] = {"west": {"to": "akrotiri", "offset": 0}}
    smooth(z)
    fringe(z)
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "Dhekelia", (44, 18))
    shop(OUT, zid, "Dhekelia", (54, 18))
    nurse(zid, ["Kalimera. Dhekelia Medical Centre. If it's sunburn, it's the second door.",
                "Pop your team down. We see all sorts here: broken limbs from the football, and broken pride from the tavli.",
                "All patched up. Remember, a hat and water, and go easy on the souvlaki.",
                "The Ark is in the back, under the fan. It's the only cool spot on the base.",
                "No rush. It's far too hot for that."])
    shopkeeper(zid, "Yassou, and welcome to the Garrison Shop. Halloumi, Cypriot delight and a supply of British tea that would stop a clock. What'll it be?",
               "Efharisto, and take care on the road. They drive on the left here, but sometimes in the middle.")

    landmark(OUT, "dhekelia_hall", "Garrison Hall", zid, (44, 26), "hall", [
        dict(id="dhk_sbaa", sprite="explorer", x=6, y=2, facing="down", move="still", script="dhk_sbaa", name="SBA Administration Officer"),
        dict(id="dhk_clerk", sprite="commuter", x=10, y=5, facing="left", move="still", script="dhk_clerk", name="Clerk")])
    landmark(OUT, "dhekelia_kafeneio", "Kafeneio", zid, (11, 18), "cafe", [
        dict(id="dhk_kafetzis", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="dhk_kafetzis", name="Kafetzis"),
        dict(id="dhk_tavli", sprite="villager_5", x=8, y=4, facing="left", move="still", script="dhk_tavli", name="Tavli Player")], w=11, h=9)
    landmark(OUT, "dhekelia_chapel", "Village Church", zid, (19, 26), "church", [
        dict(id="dhk_priest", sprite="pilgrim", x=6, y=2, facing="down", move="still", script="dhk_priest", name="Priest")])
    story()


def story():
    z = "akrotiri_terminal"
    script(z, "akr_movements", [
        {"do": "say", "who": "RAF Movements", "text": "RAF Akrotiri Movements. The Airbridge goes home from here, whenever you like."},
        {"do": "overseas_home", "territory": TERR}])
    script(z, "akr_traveller", say1("Traveller", "I've been through Akrotiri a dozen times on the way to somewhere else. It's the only airport where I've seen a flamingo while waiting for a flight.",
                                    "Last time my plane was delayed by a tortoise. I'm not making it up."))
    z = "akrotiri_church"
    script(z, "akr_padre", say1("Padre", "The Garrison Church serves Episkopi, a congregation of soldiers, airmen, families and the odd tourist who wandered in out of the sun.",
                                "It's the cool spot in the cantonment. People come for the hymns and stay for the air conditioning."))
    z = "akrotiri_centre"
    script(z, "akr_centre_warden", [
        iff(QF + "_done", say1("Centre Warden", "The flamingo census is on the wall. Your name is at the bottom, in small print, where the real heroes go."),
            [iff(QF + "_2", [iff("trainer_akr_warden",
                 say1("Centre Warden", "You've caught a Brineling and beaten the Flamingo Warden? That's the whole census done. Here, a feather from the lake, and some supplies from the Centre cupboard.")
                 + sett(QF + "_3", QF + "_done") + [item("flamingo_feather"), item("halloumi", 3), item("loukoumi", 2), standing(10)],
                 say1("Centre Warden", "A Brineling in your Ark, lovely. Now the Flamingo Warden at the lake wants to meet you in a fair match. He says flamingos are not for sharing."))],
                [iff(QF + "_1", [{"do": "when", "cond": "caught_brineling", "then": say1("Centre Warden", "A Brineling! Look at the pink on it. That's the shrimp. You've done the hard part: now the Flamingo Warden at the lake wants a word.") + sett(QF + "_2"),
                    "else": say1("Centre Warden", "I need you to catch a Brineling on the lake shore. They stand on one leg in the shallows. Bring one back, and don't scare the flock.")}],
                    [iff(QF + "_started", say1("Centre Warden", "Walk out to the lake and see what you can catch."),
                         say1("Centre Warden", "Welcome to the Akrotiri Environmental Centre. The lake is our job: the flamingos, the ducks, the waders and the one very confused heron.",
                              "We're counting this winter's birds, and I'm short of hands. Could you catch a Brineling out on the shore? It's the little pink one.") + sett(QF + "_started", QF + "_1"))])])])])
    script(z, "akr_centre_birder", say1("Birder", "Winter is the best time. You get thousands of flamingos on the lake, and the whole shore smells like a very expensive pond.",
                                        "The flamingos' pink colour comes from what they eat. A flamingo that eats nothing but toast goes white. I've never tested it."))
    z = "akrotiri_cats"
    script(z, "akr_prior", say1("Prior", "The cats of St Nicholas keep the snakes down, and the snakes keep the cats interested. Welcome, and please don't feed them. They have a rota.",
                                "We have a legend, a bell, a garden and about thirty cats. The cats are the only ones with a clear idea of how the day should go."))
    script(z, "akr_cat", say1("Cat", "It looks at you for a long moment, decides it has better things to do, and goes to sit on a prayer book."))
    z = "akrotiri_eustolios"
    script(z, "akr_mosaic_guide", say1("Site Guide", "These mosaics are over fifteen hundred years old. They're made from tiny stones, set by hand, with patterns of birds, fish and a rather formal-looking partridge.",
                                       "The roof is modern. It keeps the sun off, because the mosaics are far older than any sunscreen."))
    z = "dhekelia_hall"
    script(z, "dhk_sbaa", say1("SBA Administration Officer", "The Sovereign Base Areas are administered separately from the Republic of Cyprus. We run the roads, the police, the courts and the schools. And the paperwork.",
                               "About half the staff are Cypriot, and the rest are British. If you ever need a stamp, this is the building."))
    script(z, "dhk_clerk", say1("Clerk", "Please take a number. It's your number, you can keep it. Nobody has called for ninety minutes, but we do believe in queuing.",
                                "The local joke is that the only thing that moves faster than a tortoise in Cyprus is a form from this office."))
    z = "dhekelia_kafeneio"
    script(z, "dhk_kafetzis", say1("Kafetzis", "A kafeneio is a coffee house, but really it's a living room for the whole village. Men come to talk, argue, play cards and not go home.",
                                   "I serve Cypriot coffee, Cypriot brandy sours, and the best loukoumi in the district, the little rose-scented squares that taste like a flower."))
    script(z, "dhk_tavli", say1("Tavli Player", "Tavli is backgammon with more shouting. You throw the dice, you slap the pieces down, and you tell your opponent exactly what you think of his mother.",
                                "It's all done with affection. We've been playing the same game since 1971."))
    z = "dhekelia_chapel"
    script(z, "dhk_priest", say1("Priest", "Every village in Cyprus has a church, and each church has a saint. Ours is a saint of olives and patience.",
                                 "On the name day, the whole village comes to a feast, and everyone goes home with a loaf of bread. It is the best day of the year."))


def main():
    akrotiri()
    dhekelia()
    write_dialogue_and_trainers()
    print("akrotiri and dhekelia written")


if __name__ == "__main__":
    main()
