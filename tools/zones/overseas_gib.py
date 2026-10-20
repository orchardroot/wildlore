# Wildlore 3.3 "Overseas", wave 33 agent 1: Gibraltar.
#
#   python3 tools/zones/overseas_gib.py        (from the repo root)
#
# Two outdoor zones: `gibraltar` (the town under the Rock: the airfield with its road across the runway, Casemates
# Square, Main Street and the Convent, the marina) and `gibraltar_rock` (the Upper Rock Nature Reserve: Apes' Den,
# St Michael's Cave, the Great Siege Tunnels, the Moorish Castle and, at the far end, Europa Point). All scaled from
# par 95. The flight home leaves from the airfield terminal (the "overseas_home" command).
from overseas_lib import *
from wcommon import _stand

TERR = "gibraltar"
QF = "q_overseas_gibraltar"
OV = "overseas"
GREEN = {"g": {"tile": "grass", "colour": "#aaa564"}, "k": {"tile": "tall_grass", "colour": "#939050"}, "q": {"tile": "cliff", "colour": "#c2bca8"},
         "c": {"tile": "cobbles", "colour": "#d4c9ae"}, "a": {"tile": "path", "colour": "#e4dabc"}}


def fresh(zid, name, w, h, kind, music):
    z = Z(zid, name, w, h, kind=kind, region="overseas_gibraltar", music=music,
          weather={"clear": 34, "sunshine": 34, "fog": 8, "drizzle": 6, "gale": 10, "downpour": 4, "frost": 0, "heatwave": 0})
    z.d["weather"].pop("frost"); z.d["weather"].pop("heatwave")
    z.d["scaled_floor"] = FLOOR
    z.legend.update(GREEN)
    z.rect(0, 0, w, h, "g")
    return z


def town():
    zid = "gibraltar"
    W, H = 80, 64
    z = fresh(zid, "Gibraltar", W, H, "town", "town_city")
    z.d["stage"] = "coast"
    z.border("H", 2, gaps=[(78, 34, 2, 3)])
    # ---- the sea in the Bay of Gibraltar, with a cobbled harbour front
    for y in range(3, H - 2):
        for x in range(2, 12):
            z.set(x, y, "$")
        z.set(12, y, "w")
        z.set(13, y, "s")
    z.rect(2, 3, 11, 5, "g")
    z.rect(14, 3, 1, 1, "g")
    # ---- the frontier fence and the Spanish side beyond
    z.rect(12, 3, 40, 1, "F")
    bld(z, 24, 4, 7, 3, "raf_block", "Frontier", show_label=True)
    z.sign(32, 5, "SPAIN. The land frontier is just north of the runway. It was shut by General Franco in 1969, the pedestrian gate reopened in 1982 and the whole frontier only in 1985, which is a long time to wait for a cup of coffee.")
    # ---- the airfield: the runway, with the road across it
    z.rect(13, 8, 40, 3, "=")
    z.rect(30, 11, 22, 2, ":")
    path(z, [(26, 7), (26, 30)], "=", 3)
    z.sign(29, 7, "RUNWAY CROSSING. When a plane is landing the road is closed, the barriers come down and you wait. It's the only road in the world, we're told, that has to give way to a Hercules.")
    bld(z, 34, 13, 12, 5, "raf_terminal", "Air Terminal", 6, "gibraltar_terminal")
    z.rect(30, 18, 22, 1, ":")
    plaque(z, 52, 12, TERR, "runway", "The Runway and the Road",
           "Gibraltar's airfield is RAF Gibraltar and the civil airport together, with a runway that is only about 1,800 metres long and ends in the sea at both ends. The main road into town, Winston Churchill Avenue, crosses the runway on the level. When a plane lands or takes off the barriers go down, and the traffic waits for it.")
    # ---- Casemates Square
    z.rect(20, 19, 24, 9, "c")
    bld(z, 14, 19, 6, 5, "gib_house", show_label=False)
    bld(z, 44, 19, 6, 5, "gib_house", show_label=False)
    for (x, y) in [(24, 21), (28, 21), (36, 21), (40, 21), (24, 25), (40, 25)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(31, 22), (33, 22), (31, 25), (33, 25)]:
        z.prop("planter", x, y, variant=1)
    z.prop("bench", 35, 26)
    z.prop("bench", 29, 26)
    z.prop("flagpole", 22, 20, variant=6)
    z.prop("flagpole", 42, 20, variant=6)
    plaque(z, 30, 19, TERR, "casemates", "Casemates Square",
           "The square is named after the Grand Casemates, a barracks of vaulted rooms built by the British in the 1700s for the garrison. The old gate of the town stands at one end. It was once a place for parades, markets and a drum-beat at the end of the day. Today it is cafes, children and a very polite pigeon.")
    # ---- Main Street
    z.rect(30, 28, 4, 27, "c")
    z.rect(20, 33, 30, 1, "c")
    z.rect(20, 38, 30, 1, "c")
    z.rect(20, 43, 30, 1, "c")
    z.rect(20, 48, 30, 1, "c")
    z.rect(20, 53, 30, 1, "c")
    # west of Main Street
    bld(z, 22, 29, 8, 4, "gib_house", "Fish and Chips", 4, "gibraltar_chippy", iw=11, ih=9)
    bld(z, 22, 34, 8, 4, "gib_house", "Gibraltar Museum", 3, "gibraltar_museum")
    bld(z, 22, 39, 8, 4, "limestone_church", "Cathedral of St Mary the Crowned", 4, "gibraltar_cathedral")
    bld(z, 22, 44, 8, 4, "gib_house", show_label=False)
    # east of Main Street
    bld(z, 34, 29, 8, 4, "gib_house", "Sanctuary", 3)
    z.warp(37, 32, "gibraltar_sanctuary", 5, 6, "up")
    bld(z, 34, 34, 8, 4, "gib_house", "Corner Shop", 2)
    z.warp(36, 37, "gibraltar_shop", 4, 5, "up")
    bld(z, 34, 39, 8, 4, "gib_house", show_label=False)
    bld(z, 34, 44, 8, 4, "gib_house", "Garrison Library", 4, "gibraltar_library")
    bld(z, 43, 29, 6, 4, "gib_house", show_label=False)
    bld(z, 43, 34, 6, 4, "gib_house", show_label=False)
    bld(z, 43, 39, 6, 4, "gib_house", show_label=False)
    bld(z, 14, 29, 7, 4, "gib_house", show_label=False)
    bld(z, 14, 34, 7, 4, "gib_house", show_label=False)
    # the Convent at the head of Main Street
    bld(z, 26, 54, 14, 6, "palladian", "The Convent", 7, "gibraltar_convent", iw=15, ih=11)
    z.rect(26, 60, 14, 1, "c")
    for (x, y) in [(31, 30), (31, 36), (31, 41), (31, 46), (32, 51)]:
        z.prop("lamp_post", x, y)
    plaque(z, 32, 33, TERR, "main_street", "Main Street",
           "Main Street has been the heart of the town since the Moors. It runs almost the whole length of the old town, from Casemates Square at the north to the Convent at the south, and everyone, from sailors to governors, has walked along it. The shops sell sterling and euros; the road itself has a British letterbox and a Spanish siesta.")
    plaque(z, 30, 40, TERR, "cathedral", "St Mary the Crowned",
           "The Roman Catholic cathedral stands on the site of a mosque that the Moors built here. The Spanish consecrated it as a church after they retook the Rock in 1462, and it was rebuilt after damage in the 1700s. The Gothic arches inside are dwarfed by the voices of a very large congregation on feast days.")
    plaque(z, 30, 35, TERR, "museum", "The Gibraltar Museum",
           "The museum stands over a set of Moorish baths from around the 1300s, still in beautifully arched condition. It is also the keeper of the Rock's deep past: a Neanderthal skull found in Forbes' Quarry in 1848 was the first adult Neanderthal skull ever found, eight years before the creature got its name in the Neander Valley. The caves of Gorham's, on the Rock's far side, are a World Heritage Site.")
    plaque(z, 33, 45, TERR, "library", "The Garrison Library",
           "Founded in 1793, the Garrison Library was built for the officers of the garrison, who after the Great Siege had a great deal of time and not much to read. It held maps, histories and a fine collection of old Spanish and English books, and it is still a library today.")
    plaque(z, 31, 53, TERR, "convent", "The Convent",
           "The official residence of the Governor since the 1700s began as a Franciscan friary in the early 1500s, hence the name. The Royal Gibraltar Regiment mounts a Changing of the Guard outside it. The Governor's house also has a ghost, said to be a friar, which is not unusual in a convent.")
    plaque(z, 24, 53, TERR, "utrecht", "1704 and 1713",
           "An Anglo-Dutch fleet under Admiral Sir George Rooke took Gibraltar in 1704 in the War of the Spanish Succession. In 1713 the Treaty of Utrecht ceded the Rock to Great Britain 'in perpetuity'. In 1967 the Gibraltarians voted in a referendum, 12,138 to 44, to stay British, and 10 September is now Gibraltar National Day.")
    # ---- the marina on the Bay and the south end: Trafalgar and the Alameda
    z.rect(14, 40, 7, 14, "c")
    for (x, y) in [(10, 41), (9, 44), (10, 47), (8, 50)]:
        z.prop("boat", x, y, variant=(x + y) % 3)
    z.prop("bollard", 13, 42)
    z.prop("bollard", 13, 46)
    z.prop("bollard", 13, 50)
    plaque(z, 17, 45, TERR, "marina", "The Bay of Gibraltar",
           "The Bay is one of the busiest anchorages in the Mediterranean, with ships waiting to take on fuel, and it is home to groups of common dolphins that follow the fishing boats and the ferries. Dolphin-watching boats leave from the marina; the dolphins have a remarkable sense of timing and no interest in appointments.")
    z.rect(14, 56, 10, 6, "f")
    blob(z, 44, 58, 5, 3, "f", only="g", seed=2, jitter=0.2)
    plaque(z, 42, 55, TERR, "trafalgar", "Trafalgar Cemetery",
           "Just outside the old walls lies the Trafalgar Cemetery, where sailors who died of their wounds after the Battle of Trafalgar in 1805 were buried. HMS Victory, with the body of Admiral Nelson aboard, was brought into Gibraltar for repairs. The cemetery is a quiet place of old stones in the sun.")
    plaque(z, 47, 51, TERR, "flora", "The Gibraltar Candytuft",
           "The Rock has about 600 kinds of plant, and one of them grows nowhere else in the world: the Gibraltar candytuft, with clusters of pale-pink flowers on the cliffs. It is the national flower of Gibraltar. Barbary partridges and peregrines nest on the same cliffs.")
    # ---- the Rock: three great shoulders of limestone with a path up between them
    z.rect(52, 3, 26, 62, "g")
    bld(z, 54, 4, 24, 12, "gib_rock")
    bld(z, 54, 18, 24, 14, "gib_rock")
    bld(z, 54, 40, 24, 16, "gib_rock")
    z.rect(50, 34, 30, 3, "a")
    hills(z, [(66, 34, 4, 26)])
    for y in range(3, 63):
        for x in range(0, 50):
            z.hg[y][x] = 0
    z.sign(51, 36, "THE UPPER ROCK. The Apes' Den, St Michael's Cave and the Great Siege Tunnels are this way, up the path. Please do not feed the Barbary macaques: they are very good at asking, and they know where you keep your sandwiches.")
    z.sign(15, 28, "THE MARINA and the Bay. SOUTH: Main Street, Trafalgar, and Europa Point beyond.")

    # ---- people
    chat(z, "gib_cop", "rail_guard", 27, 13, "Royal Gibraltar Police",
         ["Mind the runway, please. If you hear the siren, stop. If you see a plane, definitely stop.",
          "Gibraltar has one of the smallest police forces anywhere, and one of the biggest views from the beat."], "down")
    chat(z, "gib_llanito", "villager_2", 38, 24, "Caleta Local",
         ["We speak Llanito here: English and Spanish tangled up together, with a bit of Genoese and Maltese for flavour. 'Yaniti' is the Llanito for what you'd call a bit of a mess, and 'mira' is how you get everyone's attention.",
          "The old rule is you can start a sentence in English and end it in Spanish, and it'll still be correct somewhere."], "down")
    chat(z, "gib_calentita", "shopkeeper", 33, 36, "Calentita Seller",
         ["Calentita is our national dish: a baked cake of chickpea flour, olive oil, water, salt and pepper, hot from the oven. The name is just 'little hot one' in Spanish. The Genoese brought it with them from Liguria, where they call it farinata.",
          "Eat it with black pepper, and a splash of lemon if you've got a taste for such things."], "left")
    chat(z, "gib_regiment", "hurler", 36, 20, "Royal Gibraltar Regiment",
         ["The Royal Gibraltar Regiment is the Rock's own regiment, and its soldiers are mostly local. The regiment's badge has the castle and key of Gibraltar.",
          "The castle and key was granted in 1502 by Ferdinand and Isabella of Spain, and the Rock still uses it today."], "down")
    chat(z, "gib_fisher", "fisherman_north", 16, 41, "Fisherman",
         ["The Bay's full of bream and mullet, and a few things I'd rather not catch. The dolphins are a nuisance and a joy; they take my bait and then wave.",
          "My granddad fished here before the border closed in 1969. Fifteen years of seeing Spain across the water, and nobody could cross."], "right")
    chat(z, "gib_dolphin_watcher", "tour_guide", 17, 51, "Boat Tout",
         ["Dolphin trip, two hours, guaranteed dolphins or you can have your money back. Well, you'll see the sea. And probably dolphins.",
          "We go out past the Bay to the Strait. On a clear day you can see Morocco, with Jebel Musa on the African side, the other Pillar of Hercules."], "right")
    chat(z, "gib_pilot", "sailor", 46, 18, "RAF Pilot",
         ["Landing here is the aviation equivalent of parking in a tight bay with a very big audience. The Rock throws up a curl of wind that can slap you sideways, called the Levanter.",
          "When the Levanter blows, a cloud sits over the Rock like a flat white tablecloth. It isn't an omen. It's just the wind meeting a mountain."], "down")
    chat(z, "gib_gardener", "hiker", 18, 59, "Alameda Gardener",
         ["The Alameda Gardens are the Rock's botanical gardens, laid out in the early 1800s by the Governor. The wishing well is still there, if you've a spare coin.",
          "A lot of what grows here is from the Mediterranean and Africa. The Governor of the day had a taste for exotic plants, and the soil agreed with them."], "right")
    chat(z, "gib_guard", "rail_guard", 28, 53, "Convent Sentry",
         ["I'm a ceremonial guard, but don't be fooled. If you start taking photos while I'm marching, I'll be a very polite guard indeed, with a very large rifle.",
          "The Changing of the Guard is at the Convent a few days a week. Come on a Tuesday in summer; it's the best seat in the house."], "up")
    chat(z, "gib_scholar", "gown_student", 44, 46, "Library Reader",
         ["I'm writing a dissertation on the Great Siege. There were more guns on this Rock than there were people in some English towns.",
          "The Garrison Library has the siege accounts of Captain John Drinkwater, who was there. His book is the best account of the siege in English."], "down")

    # trainers (scaled from par 95)
    trainer(z, "gib_customs", "Customs Officer", "Customs Officer", "rail_guard",
            [("binfox", 95), ("graftling", 95), ("tunneller", 95)], 33, 7, "down",
            ["Anything to declare? Cigarettes, spirits, a stray Barbary macaque?", "I'll need to see inside that bag. And the one in your head."],
            "Declared in full and cleared. Move along.", "I've seen a man with eleven watches under his sleeve. He was lovely about it.", 4200)
    trainer(z, "gib_dolphin", "Dolphin Guide", "Dolphin Guide", "sailor",
            [("dolfeen", 95), ("bayrunner", 95), ("plungebeak", 95)], 18, 55, "up",
            ["The dolphins aren't on a leash, and nor am I.", "Let's see how you handle a bit of Strait swell!"],
            "Smooth sailing. I'll tell the dolphins you said hello.", "The common dolphin can reach 60 km an hour. I can reach the harbour wall. Barely.", 4000)
    trainer(z, "gib_soldier", "Gibraltar Soldier", "Soldier", "hurler",
            [("shieldbiter", 95), ("steelheart", 95), ("legionette", 95)], 32, 26, "left",
            ["I'm on parade, so I'll make this quick.", "En garde, in the proper order."],
            "Well fought. I'll have to tell the Sergeant-Major.", "In the Great Siege they once fired red-hot cannonballs at the Spanish floating batteries. We stick to the polite sort now.", 4300)
    trainer(z, "gib_librarian", "Librarian", "Librarian", "gown_student",
            [("rhymerick", 95), ("longman", 95), ("chronophage", 95)], 43, 47, "left",
            ["Silence. Or, rather, a very specific amount of noise.", "This is a library, not a battlefield. Though the Siege reading group is getting close."],
            "I stand corrected. Please return that to the shelf.", "The librarian's rule: you can borrow a book, but a book can't borrow you.", 3900)
    trainer(z, "gib_ceremonial", "Ceremonial Guard", "Legend of the Rock", "rail_guard",
            [("centurion", 95), ("silvershod", 95), ("ironwatch", 95), ("hellbunker", 95)], 36, 53, "left",
            ["I have stood outside this Convent in the sun for eighteen summers and nobody has ever made me blink.", "You'll be the first. Come on, then."],
            "You made me blink. Enjoy it: you're the first.", "The guard's secret is in the knees. And in not thinking about the sun.", 6400)
    scale_all(["gib_customs", "gib_dolphin", "gib_soldier", "gib_librarian", "gib_ceremonial"])

    wild(z, [("chipgull", 95, 97, 14, {}), ("pierlord", 95, 97, 6, {}), ("kitelet", 95, 97, 10, {"time": ["dawn", "day"]}),
             ("peregrin", 95, 97, 8, {"time": ["day"]}), ("parakit", 95, 97, 8, {}), ("squawkster", 95, 97, 6, {}),
             ("binfox", 95, 97, 8, {"time": ["dusk", "night"]}), ("tunneller", 95, 97, 6, {}), ("graftling", 95, 97, 6, {}),
             ("levanter", 95, 97, 4, {"weather": ["fog", "gale"]}), ("macaquet", 95, 97, 5, {}), ("sapperling", 95, 97, 4, {})])
    wild(z, [("dolfeen", 95, 97, 12, {}), ("dolphlet", 95, 97, 14, {}), ("bayrunner", 95, 97, 10, {}), ("puffling", 95, 97, 8, {}),
             ("gannetling", 95, 97, 10, {}), ("pinchkin", 95, 97, 8, {})], "water")
    for (cx, cy, rx, ry, s) in [(16, 12, 4, 2, 1), (46, 22, 2, 3, 2), (48, 44, 2, 4, 3), (20, 60, 4, 2, 4), (6, 12, 3, 2, 5)]:
        blob(z, cx, cy, rx, ry, "k", only="g", seed=s, jitter=0.3)
    z.d["edges"] = {"east": {"to": "gibraltar_rock", "offset": 0}}
    z.d["spawn"] = [40, 19]
    fringe(z)
    smooth(z)
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "Gibraltar", (37, 33))
    shop(OUT, zid, "Gibraltar", (36, 38))
    nurse(zid, ["Buenas, my love, and welcome to St Bernard's. Or the Sanctuary, as the sign says, because it's cheaper than reprinting the letterhead.",
                "Pop your team on the couch. Everything in Gibraltar is a ten-minute walk away, which includes the hospital.",
                "There you go: right as the Rock, which is the national expression for 'perfectly fine'.",
                "The Ark's in the corner, next to the sunbed. It's the only place in the building where you can lie down in peace.",
                "Take a seat. It's too hot to rush."])
    shopkeeper(zid, "Hola, hello, and welcome. Pounds, euros, and calentita while it lasts. What'll it be?",
               "Hasta luego, as they say, and vaya con Dios. And mind the macaques.")

    landmark(OUT, "gibraltar_terminal", "Air Terminal", zid, (40, 18), "hall", [
        dict(id="gib_movements", sprite="rail_guard", x=6, y=2, facing="down", move="still", script="gib_movements", name="RAF Movements"),
        dict(id="gib_traveller", sprite="commuter", x=10, y=5, facing="left", move="still", script="gib_traveller", name="Traveller")])
    landmark(OUT, "gibraltar_museum", "Gibraltar Museum", zid, (26, 38), "museum", [
        dict(id="gib_curator", sprite="prof_garside", x=5, y=3, facing="right", move="still", script="gib_curator", name="Curator"),
        dict(id="gib_baths", sprite="villager_6", x=8, y=4, facing="left", move="still", script="gib_baths", name="Attendant")])
    landmark(OUT, "gibraltar_cathedral", "Cathedral of St Mary the Crowned", zid, (26, 43), "church", [
        dict(id="gib_priest", sprite="pilgrim", x=6, y=2, facing="down", move="still", script="gib_priest", name="Priest")])
    landmark(OUT, "gibraltar_library", "Garrison Library", zid, (38, 48), "library", [
        dict(id="gib_librarian_in", sprite="gown_student", x=5, y=3, facing="right", move="still", script="gib_librarian_in", name="Librarian"),
        dict(id="gib_siege_reader", sprite="astronomer", x=9, y=5, facing="left", move="still", script="gib_siege_reader", name="Reader")])
    landmark(OUT, "gibraltar_convent", "The Convent", zid, (33, 60), "hall", [
        dict(id="gib_governor_aide", sprite="explorer", x=6, y=2, facing="down", move="still", script="gib_governor_aide", name="Aide-de-Camp")], w=15, h=11)
    landmark(OUT, "gibraltar_chippy", "Fish and Chips", zid, (26, 33), "cafe", [
        dict(id="gib_chippy", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="gib_chippy", name="Fryer"),
        dict(id="gib_chippy_cust", sprite="villager_4", x=8, y=4, facing="left", move="still", script="gib_chippy_cust", name="Customer")], w=11, h=9)


def rock():
    zid = "gibraltar_rock"
    W, H = 64, 56
    z = fresh(zid, "The Upper Rock", W, H, "route", "route_mountain")
    z.d["stage"] = "mountain"
    z.border("H", 2, gaps=[(0, 34, 2, 3)])
    # the limestone ridge: a hill with the summit near the north, falling to the sea at Europa Point in the south
    hills(z, [(36, 14, 6, 26), (30, 36, 3, 16)])
    # sea round the south and east
    for y in range(H):
        for x in range(W):
            if x >= 54 or y >= 50:
                z.set(x, y, "$")
    z.rect(52, 2, 2, 48, "s")
    z.rect(2, 49, 52, 1, "s")
    for y in range(2, 50):
        z.set(54, y, "w")
    for x in range(2, 54):
        z.set(x, 50, "w")
    # paths: from the west gate up to the Apes' Den, the Cave, the Tunnels and the Castle; down to Europa Point
    path(z, [(2, 35), (16, 35), (16, 24), (30, 24), (30, 14)], "a", 2)
    path(z, [(16, 35), (16, 40), (36, 40), (36, 46)], "a", 2)
    path(z, [(16, 24), (16, 10)], "a", 2)
    z.d["spawn"] = [4, 35]
    # Apes' Den: a clearing with rocks and the troop
    for (x, y) in [(19, 27), (24, 22), (26, 27), (22, 28), (28, 28)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    # the Moorish Castle on the lower north-west slope
    bld(z, 10, 4, 9, 6, "castle", "Moorish Castle", 4, "gibraltar_castle")
    z.rect(14, 10, 1, 1, "a")
    # St Michael's Cave and the Great Siege Tunnels: limestone mouths in the cliff
    bld(z, 32, 18, 5, 3, "cave_mouth", "St Michael's Cave", 2, "gibraltar_stmichaels", iw=15, ih=11)
    bld(z, 34, 8, 5, 3, "cave_mouth", "Great Siege Tunnels", 2, "gibraltar_tunnels", iw=15, ih=11)
    z.rect(32, 21, 4, 3, "a")
    z.rect(34, 11, 4, 3, "a")
    # Europa Point at the southern tip: lighthouse, the mosque and the shrine, with a view of Africa
    bld(z, 40, 42, 6, 6, "europa_lighthouse", "Europa Point Lighthouse", None)
    z.rect(40, 48, 8, 1, "a")
    bld(z, 26, 44, 6, 4, "flat_house", "Shrine of Our Lady of Europe", 2, "gibraltar_shrine")
    z.rect(26, 48, 8, 1, "a")
    bld(z, 8, 42, 9, 5, "cathedral", "Ibrahim-al-Ibrahim Mosque", None)
    z.rect(4, 48, 44, 1, "a")
    # plaques
    plaque(z, 6, 33, TERR, "rock", "The Rock",
           "The Rock of Gibraltar is a ridge of Jurassic limestone 426 metres high, about 5 kilometres long and some 1.5 kilometres wide. It was one of the two Pillars of Hercules in the old stories, with Jebel Musa opposite in Africa; the ancient Greeks and Romans thought it the edge of the world. To the Moors it was Jabal Tariq, the Mountain of Tariq, which turned into 'Gibraltar'.")
    plaque(z, 19, 24, TERR, "macaques", "The Barbary Macaques",
           "Gibraltar's macaques are the only wild monkeys in Europe, and are tailless, which is why they are also called Barbary apes. There are around three hundred of them in several troops. The old saying goes that when the apes leave the Rock, the British will leave too, and in the Second World War Winston Churchill is said to have asked for their numbers to be restored. They are still here.")
    plaque(z, 33, 22, TERR, "stmichaels", "St Michael's Cave",
           "A natural cavern of stalactites and stalagmites in the limestone, with chambers that run deep into the Rock. In ancient times people thought it was bottomless and that it joined to Africa by a secret tunnel. In the Second World War it was fitted out as a hospital that was never needed. Today it hosts concerts, because the cave has remarkable acoustics.")
    plaque(z, 35, 12, TERR, "tunnels", "The Great Siege Tunnels",
           "During the Great Siege of 1779 to 1783, Spanish and French forces tried to take Gibraltar by land and sea. The British garrison needed to fire cannons down on the besiegers from the north face, so they dug a tunnel in the rock with hand tools and gunpowder. The tunnels have windows in the cliff for the guns, and more were added in the Second World War, with over 50 kilometres in all.")
    plaque(z, 12, 11, TERR, "moors", "The Moorish Castle",
           "The Moors landed in 711 under Tariq ibn Ziyad and took the Rock, and the castle's Tower of Homage dates from 1333, when it was rebuilt. The tower is the only large part of the Moorish fortress still standing, though the walls have lived through a great deal of cannon fire. Tariq's name is part of the word Gibraltar.")
    plaque(z, 41, 48, TERR, "europa", "Europa Point",
           "Europa Point is the southernmost tip of Gibraltar, with a lighthouse built in 1841 that is white with a red band. On a clear day the coast of Morocco can be seen across the Strait, 14 kilometres away. Ships from half the world pass by, going in and out of the Mediterranean.")
    plaque(z, 12, 48, TERR, "mosque", "The Ibrahim-al-Ibrahim Mosque",
           "The mosque at Europa Point was a gift from King Fahd of Saudi Arabia and opened in 1997. It is the largest mosque in Gibraltar and one of several places of worship, with synagogues and churches too, that make the Rock unusually mixed for a place so small.")
    plaque(z, 26, 8, TERR, "levanter", "The Levanter",
           "The Levanter is the east wind that funnels through the Strait, and it brings a cloud that sits on the top of the Rock like a tablecloth. The air is forced up the east face and cools into cloud, which tumbles down the western side but melts before it hits the town. It is harmless, and it makes the Rock look like it is wearing a hat.")
    plaque(z, 44, 36, TERR, "migration", "Migration at the Strait",
           "Each autumn, thousands of raptors, including black kites, honey buzzards and eagles, fly over the Strait to cross to Africa, because it is the shortest sea crossing and they like to stay over land as long as possible. Gibraltar is one of the best places in Europe to watch it, and many birdwatchers come for the sight.")

    # the troop and the keepers
    for (sp, x, y) in [("macaquet", 20, 26), ("macaquet", 24, 23), ("macaquet", 27, 26), ("macaquet", 22, 29)]:
        _stand(z, x, y)
        z.npc(id="c_%s_%d_%d" % (sp, x, y), sprite="creature:" + sp, x=x, y=y, facing="down", move="still", script="c_macaquet")
    script(zid, "c_macaquet", say1("Macaquet", "It looks at your bag, then at you, then at your bag. You hold on to it a little tighter."))
    chat(z, "gib_keeper_chat", "ghillie", 19, 33, "Ape Keeper",
         ["They're not tame, they're not pets and they do not want your biscuits. Feeding them is illegal and a fine of up to £4,000 is possible.",
          "They'll still try. A big male once took a lady's handbag, undid the zip and ate her lipstick. She wasn't the only one."], "right")
    chat(z, "gib_tunnel_guide", "hillwalker", 31, 14, "Tunnel Guide",
         ["Sergeant-Major Henry Ince is credited with the first tunnel. He got the idea from a crowded gun position that wasn't wide enough for the guns, and decided to open up the rock.",
          "Right up here is the Notch, and St George's Hall, a gun gallery as big as a cathedral. In all there are more tunnels in the Rock than there are public roads."], "down")
    chat(z, "gib_cave_guide", "tour_guide", 31, 22, "Cave Guide",
         ["St Michael's Cave has a concert hall in it. Sometimes people play the cave's own stalactites with a mallet.",
          "In the old days they said it was bottomless and went all the way down under the Strait. Nobody has found the bottom, and nobody who goes looking is back for tea."], "right")
    chat(z, "gib_birder", "birdwatcher", 44, 33, "Raptor Watcher",
         ["In autumn, when the wind's right, the sky above Europa Point is full of kites and honey buzzards. They hang there for hours, just waiting for the right thermal.",
          "If the weather's wrong, they gather and wait. You'll see ten thousand birds on a good day, and one very tired birdwatcher."], "left")
    chat(z, "gib_priest_europa", "pilgrim", 29, 49, "Pilgrim",
         ["The Shrine of Our Lady of Europe is a chapel at the southern tip. Sailors prayed there, and still do, for a safe passage through the Strait.",
          "The chapel was once a mosque and then a church, and it's now a peaceful place of both. The light through the window is lovely at dusk."], "up")

    # trainers
    trainer(z, "gib_keeper", "Ape Keeper", "Ape Keeper", "ghillie",
            [("macaquet", 95), ("grizzlet", 95), ("raidtail", 95)], 20, 31, "up",
            ["Keep your hands in your pockets and your sandwiches in your head.", "They're not mine, they're the Rock's. I just keep the count."],
            "A good match. They liked your style.", "The Rock has to keep its apes. If it ever lost one I'd have to tell the Governor. Then lie down.", 4300)
    trainer(z, "gib_sapper", "Royal Engineer", "Sapper", "steelworker",
            [("sapperling", 95), ("rustelver", 95), ("tinnet", 95)], 36, 14, "left",
            ["I dig tunnels. Today I'm digging in for a battle.", "The Rock's already full of holes. Let me make one in your plan."],
            "You tunnelled right under me. Good dig.", "A good sapper never goes round a problem. He goes under it.", 4300)
    trainer(z, "gib_birdwatcher", "Raptor Watcher", "Birdwatcher", "birdwatcher",
            [("eaglet", 95), ("goldeneyrie", 95), ("ospret", 95)], 40, 30, "down",
            ["Don't breathe. There's a short-toed eagle over the ridge. I've waited nine years.", "Fine, fine. But when it comes, you're counting."],
            "Fair play. And it flew off while we were at it.", "A good raptor day is when the sky goes dark and your neck goes stiff.", 4000)
    trainer(z, "gib_lighthouse", "Lighthouse Keeper", "Keeper", "lamplighter",
            [("beaconblaze", 95), ("petrelash", 95), ("aegir", 95)], 42, 49, "up",
            ["I tend the light at Europa Point. It has been lit since 1841. I'm only the latest in a long line of people bored in a very nice place.", "A fight? A change from counting ships."],
            "Fair enough. I'll count you as one of the good ones.", "A light's not for the ship that's passing. It's for the ship that isn't.", 4200)
    trainer(z, "gib_moor", "Castle Warden", "Castle Warden", "ravenmaster",
            [("legionette", 95), ("centurion", 95), ("ironwatch", 95), ("hellbunker", 95)], 14, 11, "down",
            ["I guard the Tower of Homage. It's been standing since 1333, and I've been standing next to it since breakfast.", "Tariq took this Rock in 711. You'll have to do better than a Tuesday."],
            "The tower stands, but not for long if you keep that up.", "The walls are six hundred years old, and so is my back.", 6400)
    scale_all(["gib_keeper", "gib_sapper", "gib_birdwatcher", "gib_lighthouse", "gib_moor"])

    wild(z, [("macaquet", 95, 97, 10, {}), ("sapperling", 95, 97, 8, {}), ("levanter", 95, 97, 8, {"weather": ["fog", "gale"]}),
             ("peregrin", 95, 97, 10, {"time": ["day"]}), ("stoopfalcon", 96, 98, 3, {"time": ["day"]}), ("kidgruff", 95, 97, 8, {}),
             ("kitelet", 95, 97, 10, {"time": ["dawn", "day"]}), ("moldiwarp", 95, 97, 8, {}), ("tunneller", 95, 97, 6, {}),
             ("cragchough", 95, 97, 8, {}), ("duneskink", 95, 97, 8, {}), ("hootlet", 95, 97, 5, {"time": ["night"]}),
             ("flittermouse", 95, 97, 6, {"time": ["night"]})])
    wild(z, [("dolfeen", 95, 97, 12, {}), ("dolphlet", 95, 97, 14, {}), ("gannetling", 95, 97, 10, {}), ("puffling", 95, 97, 8, {}),
             ("pinchkin", 95, 97, 8, {})], "water")
    for (cx, cy, rx, ry, s) in [(10, 18, 5, 3, 1), (22, 14, 4, 3, 2), (42, 24, 5, 3, 3), (28, 34, 5, 3, 4), (10, 38, 4, 2, 5), (46, 40, 3, 3, 6)]:
        blob(z, cx, cy, rx, ry, "k", only="g", seed=s, jitter=0.3)
    z.d["edges"] = {"west": {"to": "gibraltar", "offset": 0}}
    for y in range(4, 36):   # the sheer east face
        for x in range(47, 52):
            if z.g[y][x] == "g" and (x - 47) <= (y % 3) + 2:
                z.set(x, y, "q")
    sprinkle(z, "R", 70, 11, 20, 3, 48, 24, only="g")   # limestone outcrops along the ridge
    scatter_props(z, "bush", 3, 3, 49, 44, 24, 7, avoid=("g",))
    scatter_props(z, "pine", 3, 3, 49, 44, 10, 8, avoid=("g",))
    smooth(z)
    fringe(z)
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    for (rid, rname, ret, npcs, kind) in [
        ("gibraltar_stmichaels", "St Michael's Cave", (34, 21), [
            dict(id="gib_cavern", sprite="explorer", x=7, y=3, facing="down", move="still", script="gib_cavern", name="Cave Warden")], "castle"),
        ("gibraltar_tunnels", "Great Siege Tunnels", (36, 11), [
            dict(id="gib_gunner", sprite="steelworker", x=7, y=3, facing="down", move="still", script="gib_gunner", name="Tunnel Gunner")], "castle"),
        ("gibraltar_castle", "Moorish Castle", (14, 10), [
            dict(id="gib_castle_guide", sprite="druid", x=6, y=3, facing="down", move="still", script="gib_castle_guide", name="Castle Guide")], "castle"),
        ("gibraltar_shrine", "Shrine of Our Lady of Europe", (28, 48), [
            dict(id="gib_shrine_keeper", sprite="pilgrim", x=6, y=3, facing="down", move="still", script="gib_shrine_keeper", name="Shrine Keeper")], "church")]:
        w_, h_ = (15, 11) if rid in ("gibraltar_stmichaels", "gibraltar_tunnels") else (13, 10)
        zz = landmark(OUT, rid, rname, zid, ret, kind, npcs, w=w_, h=h_, write=False)
        if rid in ("gibraltar_stmichaels", "gibraltar_tunnels"):
            zz.d["stage"] = "cave"
            zz.d["music"] = "dungeon_underground"
        zz.save(OUT + "/" + rid + ".json")
    story()


def story():
    # ---- the flight home, and the airfield
    z = "gibraltar_terminal"
    script(z, "gib_movements", [
        {"do": "say", "who": "RAF Movements", "text": "RAF Gibraltar Movements. The Airbridge goes home from here, whenever you like."},
        {"do": "overseas_home", "territory": TERR}])
    script(z, "gib_traveller", say1("Traveller", "I've been through this terminal a dozen times and it's never the same twice. The runway ends in the sea, and the gate's in the town.",
                                    "I've stepped off the plane and walked to Main Street in ten minutes. Somewhere in the world that's called a commute."))
    z = "gibraltar_museum"
    script(z, "gib_curator", [iff(QF + "_started", [iff(QF + "_1", say1("Curator", "You've got the Neanderthal facts. Take them up to the Upper Rock and tell the Cave Warden."),
        say1("Curator", "The skull found in Forbes' Quarry in 1848 is called Gibraltar 1. It was the first adult Neanderthal skull ever found, and nobody knew what it was for eight years.",
             "The Neanderthals lived on the Rock for a very long time, some say until around 30,000 years ago. Gorham's Cave has their hearths, and a patch of rock they scratched with a pattern that looks like hashtags. Go and tell the Cave Warden at St Michael's Cave that you've seen it.") + sett(QF + "_1"))],
        say1("Curator", "Welcome to the Gibraltar Museum. Mind the baths: they are 14th century, very old and very arched, and they've got a lot of steps down.",
             "If you'd like a project, the Cave Warden at St Michael's Cave is looking for someone who knows the Rock's early story. Have a look round, then go and see them."))])
    script(z, "gib_baths", say1("Attendant", "The Moorish baths were hidden under later buildings for centuries. They were uncovered when the house above was being rebuilt.",
                                "The arches are horseshoe-shaped. If you're going to look at one thing, look at the roof. It has little star-shaped holes for the steam to escape."))
    z = "gibraltar_cathedral"
    script(z, "gib_priest", say1("Priest", "Gibraltar's people come from everywhere: Genoese, Maltese, Spanish, British, Portuguese, Jewish and Moroccan families, all mixed together. On Sunday we fill the aisles.",
                                 "The cathedral stands where a mosque stood, and the arches inside still carry a hint of that. Everything has been built on everything else in this town."))
    z = "gibraltar_library"
    script(z, "gib_librarian_in", say1("Librarian", "The Garrison Library has stood since 1793 and was built with money raised by the officers themselves, because nobody else would pay.",
                                       "It's a members' library, with a fine reading room and a fine collection of old maps. It's also one of the quietest buildings in the Mediterranean."))
    script(z, "gib_siege_reader", say1("Reader", "The Great Siege lasted three years, seven months and twelve days, which is the longest siege in British military history. They held on until the French and Spanish gave up in 1783.",
                                       "The famous 'sortie' in 1781 destroyed the Spanish siege works in one night. It was done by the garrison under General Eliott, in the dark, with spades and torches."))
    z = "gibraltar_convent"
    script(z, "gib_governor_aide", say1("Aide-de-Camp", "The Governor is out inspecting the guns. I'll tell him you stopped by, which is the protocol, and that you were exceptionally polite, which is not.",
                                         "The Convent has been the Governor's residence for nearly three hundred years. The Governor is the King's representative here, though the elected Government of Gibraltar runs the Rock day to day."))
    z = "gibraltar_chippy"
    script(z, "gib_chippy", say1("Fryer", "Fish and chips, Gibraltar-style. Same batter as Blackpool, but the fish has swum a bit further, and the vinegar has a lot more sun in it.",
                                 "We get our fish from the Bay. Dentex, bream and a bit of squid. The chips are from a potato that has always been very British."))
    script(z, "gib_chippy_cust", say1("Customer", "Fish and chips on Main Street, eaten with your back to the Rock, watching the Spanish ferry. It's my favourite thing in the world.",
                                      "Mind the seagulls. They're half-Spanish and fully ruthless."))
    # ---- the Upper Rock
    z = "gibraltar_stmichaels"
    script(z, "gib_cavern", [
        iff(QF + "_done", say1("Cave Warden", "The Neanderthal chapter is closed, and the macaque chapter is open. Mind the stalactites."),
            [iff(QF + "_2", [iff("trainer_gib_keeper", say1("Cave Warden", "You've spoken to the Curator and beaten the Ape Keeper in a fair fight. The Rock's scientific committee is satisfied. Take this, it's a cannonball from the Great Siege, found in a tunnel.")
                 + sett(QF + "_3", QF + "_done") + [item("siege_cannonball"), item("calentita", 3), item("gib_rosto", 2), standing(10)],
                 say1("Cave Warden", "Now go and challenge the Ape Keeper at the Den. He says no one fights a Barbary macaque and wins. I'd like to see that."))],
                [iff(QF + "_1", say1("Cave Warden", "The Curator sent you? Excellent. The ancient people of the Rock lived in caves much like this one. The truth is the Rock's whole story is under our feet. Go on and find the Ape Keeper at the Den and fight him.") + sett(QF + "_2"),
                    [iff(QF + "_started", say1("Cave Warden", "Ask the Curator at the Gibraltar Museum in town about the Neanderthal skull. Then come back and I'll teach you the rest."),
                         say1("Cave Warden", "Welcome to St Michael's Cave. It is full of stalactites, a few bats and a pretty good echo. I'm looking for someone to take the Rock's history seriously, and I can't make the macaques do it.",
                              "Could you go and see the Curator at the museum in town? They know about the Neanderthals. Then come back.") + sett(QF + "_started"))])])])])
    z = "gibraltar_tunnels"
    script(z, "gib_gunner", say1("Tunnel Gunner", "This is the Notch, the gun position that Ince's men blasted out in 1782. A cannon here can fire down on the isthmus, the narrow neck of land where the Spanish dug in.",
                                 "The cannon was lifted through here with ropes. Each gun weighed about two tonnes. Nobody has ever managed to drag one back out without complaining."))
    z = "gibraltar_castle"
    script(z, "gib_castle_guide", say1("Castle Guide", "The Moors held Gibraltar from 711 until 1309, then again from 1333 until 1462. The Tower of Homage goes back to the second period. The scars on the wall are from the Great Siege.",
                                       "The tower stands where the Moorish fortress stood. The Tower, The Gatehouse and the Keep. It's a beautiful view over the Bay and the whole town. And a very long staircase."))
    z = "gibraltar_shrine"
    script(z, "gib_shrine_keeper", say1("Shrine Keeper", "The Shrine of Our Lady of Europe was a mosque, then a chapel, then a ruin, and now it is a place where sailors still light candles.",
                                        "Our Lady's statue was carried by the Spanish and kept in Gibraltar when the town fell. The sailors always came here for her blessing."))


def main():
    town()
    rock()
    write_dialogue_and_trainers()
    print("gibraltar written")


if __name__ == "__main__":
    main()
