# pembroke_coast (route) and st_davids (town) with its Sanctuary and Corner Shop.
from wcommon import *
from ws_cambrian import seal_ns


def build_coast(OUT):
    z = Z("pembroke_coast", "Pembroke Coast", 60, 48, kind="route", region="south_wales", music="route_coast",
          weather={"clear": 20, "drizzle": 22, "gale": 25, "fog": 13, "sunshine": 20})
    z.d["stage"] = "coast"
    # clifftop: heights, then sea
    z.height(6, 0, 11, 48, 1); z.height(8, 2, 10, 8, 2)
    z.rect(0, 0, 6, 48, "$"); z.rect(6, 0, 2, 48, "^")
    z.scatter(0, 0, 60, 48, "P", 0, 1)
    z.rect(56, 0, 4, 48, "P"); z.scatter(52, 0, 4, 48, "P", 24, 3)
    # east: the Preseli hills, heather-brown and rocky
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a6a5a", "prop": "heather"}
    z.height(38, 4, 18, 40, 1); z.height(42, 10, 10, 26, 2)
    for (x, y, w, h) in [(36, 6, 8, 6), (46, 14, 9, 8), (38, 26, 8, 8), (48, 30, 6, 8)]:
        z.rect(x, y, w, h, "h")
    z.scatter(36, 4, 20, 40, "R", 30, 4)
    z.scatter(34, 2, 22, 44, "P", 25, 5)
    # paths: main route, spurs, the coast path
    path(z, [(30, 0), (30, 12), (18, 12), (18, 24), (28, 24), (28, 36), (20, 36), (20, 47)], "#", 2)
    path(z, [(14, 12), (18, 12)], "#", 2); path(z, [(14, 36), (20, 36)], "#", 2)
    path(z, [(14, 3), (14, 46)], "#", 2)
    z.rect(30, 0, 3, 3, "#"); z.rect(20, 45, 3, 3, "#")
    # Strumble Head headland and lighthouse
    z.rect(8, 2, 10, 8, ".")
    z.prop("lighthouse", 9, 4)
    z.building(10, 6, 4, 3, "white_render", "Lighthouse Cottage")
    z.prop("bench", 16, 4); z.prop("bollard", 11, 3); z.prop("rock", 8, 9); z.prop("rock", 16, 8)
    z.rect(15, 3, 3, 2, "f")
    z.sign(15, 9, "STRUMBLE HEAD LIGHTHOUSE. 1908. It flashes four times every fifteen seconds. Your teacher's laser pointer did it in assembly too.")
    z.sign(17, 2, "PEMBROKESHIRE COAST PATH. 186 miles. Please do not do it in one go.")
    # islands offshore: Skomer (puffins) and Skokholm
    z.rect(1, 17, 4, 5, "."); z.rect(2, 18, 2, 3, "f"); z.scatter(1, 17, 4, 5, "R", 5, 2, only=".")
    z.rect(2, 39, 3, 3, "."); z.scatter(2, 39, 3, 3, "R", 3, 3, only=".")
    z.prop("buoy", 4, 25); z.prop("buoy", 3, 30, variant=1); z.prop("boat", 3, 12, variant=1); z.prop("boat", 4, 34, variant=1)
    z.sign(16, 19, "SKOMER ISLAND, offshore. Thousands of puffins April to July. They have gone for the winter. Not all of them. One is on that rock. Honest.")
    # chough fields and clifftop thrift along the path
    for (x, y, w, h) in [(15, 14, 3, 6), (15, 26, 3, 6), (16, 40, 3, 5), (21, 3, 7, 8), (22, 26, 4, 8), (30, 38, 6, 8), (22, 14, 5, 8)]:
        z.rect(x, y, w, h, ",")
    z.scatter(8, 10, 8, 38, "f", 18, 6, only=".")
    scatter_props(z, "rock", 8, 3, 6, 44, 10, 9, avoid=(".",))
    scatter_props(z, "bush", 20, 2, 12, 44, 12, 10, avoid=(".",))
    # littered cove (west): sand inlet reached from the coast path
    z.rect(6, 17, 8, 7, "s"); z.rect(6, 16, 8, 1, "^"); z.rect(6, 24, 8, 1, "^")
    z.height(6, 17, 8, 7, 0)
    z.rect(13, 20, 1, 1, "s")
    z.rect(5, 17, 1, 7, "w")
    scatter_props(z, "bollard", 7, 17, 6, 7, 6, 11, avoid=("s",))
    scatter_props(z, "planter", 7, 17, 6, 7, 4, 12, avoid=("s",))
    z.prop("bench", 11, 22)
    z.sign(12, 21, "LITTERED COVE. A shopping trolley, 14 flip-flops and what appears to be a full drum kit. The tide brings it, the beach keeps it.")
    clear_prop(z, 9, 20)
    z.npc(id="cleanup", sprite="villager_5", x=9, y=20, facing="right", move="still", script="cleanup")
    script("pembroke_coast", "cleanup", say("Beach Cleaner", "Placeholder: the story agent rewrites this clean-up side quest."))
    # seal cove (deep water, Brook-wade)
    z.rect(6, 31, 7, 7, "o"); z.rect(6, 30, 8, 1, "^"); z.rect(6, 38, 8, 1, "^"); z.rect(8, 33, 3, 3, "s")
    z.rect(12, 33, 2, 3, "s"); z.rect(13, 33, 1, 3, "s")
    z.height(6, 30, 8, 9, 0)
    z.prop("buoy", 7, 32)
    clear_prop(z, 9, 34)
    z.npc(id="seal_watcher", sprite="birdwatcher", x=9, y=34, facing="down", move="still", script="seal_watcher")
    script("pembroke_coast", "seal_watcher", say("Seal Watcher",
        "Grey seals pup on these beaches in autumn. The pups are white and fluffy and look like very cross bath towels.",
        "I came by wading. Splendid, if you like cold. The seals do not judge."))
    z.sign(15, 34, "SEAL COVE. Deep water between you and the beach. Not for the faint of wade.")
    # Preseli bluestones, Pentre Ifan
    for i, (x, y) in enumerate([(44, 18), (46, 18), (45, 20)]):
        z.prop("standing_stone", x, y, variant=i)
    z.rect(44, 19, 3, 1, "#")
    z.sign(45, 22, "PENTRE IFAN. A 5,500-year-old dolmen: the capstone weighs about 16 tonnes. No cranes. Stonehenge's bluestones came from these hills, too.")
    for (x, y) in [(40, 30), (41, 33), (49, 8)]:
        z.prop("standing_stone", x, y, variant=(x + y) % 3)
    z.prop("lamp_post", 29, 14); z.prop("post_box", 33, 4); z.prop("phone_box", 33, 24)
    z.sign(33, 6, "ST DAVIDS 14 miles. The smallest city in Britain. Probably the one with the most gulls per resident.")
    z.sign(19, 44, "ST DAVIDS: follow the path. If there's a cathedral, you've gone far enough.")
    # NPCs
    chat(z, "puffin_warden", "birdwatcher", 15, 18, "Puffin Volunteer",
         ["Puffins nest in burrows on Skomer from April. Up to twenty thousand of them, give or take a few.",
          "I'm a volunteer. I count puffins. They don't stay still. It is a very bad job."], "down", "wander")
    chat(z, "keeper_lh", "villager_2", 14, 10, "Lighthouse Keeper",
         ["Strumble Head Lighthouse is automatic now. I come for the chat.",
          "The lamp is thirty miles of visibility. The sea has no manners. But I'm very proud of it."], "right", "still")
    chat(z, "coast_walker", "hiker", 19, 30, "Coast Path Walker",
         ["Pembrokeshire coast path. 186 miles. I'm on mile 41 and my feet have formed a union.",
          "Wales' only coastal national park, they tell me. Wettest views in Britain."], "up", "still")
    chat(z, "preseli_farmer", "farmer", 44, 24, "Hill Farmer",
         ["Those blue stones at Stonehenge came from this hill. Four hundred miles. Pulled, probably, on sleds.",
          "I've a quarry full of them behind the barn. Nobody's asked for one yet."], "down", "wander")
    # trainers
    trainer(z, "gethin", "Birdwatcher Gethin", "Birdwatcher", "birdwatcher", [("puffling", 32), ("clownbill", 33), ("cragchough", 33)],
            16, 7, "left", ["Hush! Choughs. Red bill, red legs, black as a vicar's hat.", "Oh, you've scared them. Duel!"],
            "A fair fight. I'll note it in the logbook under 'rude'.", "Chough. Not crow. Never crow.", 700)
    trainer(z, "seren", "Surfer Seren", "Surfer", "surfer", [("greyhaul", 33), ("bayrunner", 33)], 17, 28, "left",
            ["The swell at Whitesands is perfect today. Swell is a technical term."], "Wipeout. Cheers for the lesson.",
            "Wetsuit's cold. Pride is drier.", 720)
    trainer(z, "ifor", "Angler Ifor", "Angler", "angler", [("clawcastle", 33), ("petrelash", 33), ("dolphlet", 32)], 26, 30, "right",
            ["Mackerel's running! Or it's the tide. Hard to say."], "Landed me. Shame about the line.",
            "I'll stay till dark. Or the flask's empty.", 700)
    trainer(z, "bronwen", "Hiker Bronwen", "Hiker", "hiker", [("adderking", 34), ("cragchough", 33)], 33, 8, "left",
            ["I have a flask, a map and a very strong opinion about waterproofs."], "Rain stops play. Fair play.",
            "Always pack a spare sandwich. Two if the path has a pub.", 740)
    trainer(z, "sion", "Warden Sion", "Warden", "warden_grunt", [("petrelash", 32), ("cragchough", 33)], 15, 33, "left",
            ["This cove is now a Curated Seal Experience! Wristband required!",
             "Seals are, er, included. Mostly. Please do not say 'free'."], "My sales pitch needed work.",
            "I'm not a Warden. I'm a Customer Experience Steward. The lanyard says so.", 600)
    z.d["edges"] = {"north": {"to": "aberystwyth", "offset": 0}, "south": {"to": "st_davids", "offset": 0}}
    z.d["spawn"] = [31, 1]
    seal_ns(z, 30, 32, True, False); seal_ns(z, 20, 22, False, True)
    wild(z, [("cragchough", 32, 34, 22, {"time": ["dawn", "day"]}), ("puffling", 32, 34, 26, {"time": ["dawn", "day", "dusk"]}),
             ("petrelash", 33, 34, 14, {"weather": ["drizzle", "downpour", "gale"]}), ("pinchkin", 32, 33, 14, {}),
             ("pupplash", 32, 33, 10, {"time": ["dawn", "dusk"]}), ("zigzlet", 32, 34, 14, {"time": ["dusk", "night"]}),
             ("cragchough", 33, 34, 8, {"weather": ["gale"]})])
    wild(z, [("dolphlet", 32, 34, 40, {}), ("pupplash", 32, 34, 30, {}), ("pinchkin", 33, 34, 15, {}),
             ("petrelash", 33, 34, 15, {"weather": ["drizzle", "downpour", "gale"]})], "water")
    z.save(OUT + "/pembroke_coast.json")


def build_town(OUT):
    z = Z("st_davids", "St Davids", 48, 40, kind="town", region="south_wales", music="town_wales",
          weather={"clear": 25, "drizzle": 28, "gale": 17, "sunshine": 18, "fog": 12})
    z.d["stage"] = "town"; z.d["town_id"] = "st_davids"
    z.border("T", 2)
    z.scatter(0, 0, 48, 40, "P", 30, 2, only="T")
    # the city on its rim at height 2, slope band, and the hollow at 0
    z.height(0, 0, 48, 23, 2); z.height(0, 23, 48, 2, 1)
    # roads
    z.rect(20, 0, 3, 18, "="); z.rect(19, 0, 1, 18, ":"); z.rect(23, 0, 1, 18, ":")
    z.rect(13, 16, 20, 5, ":")          # Cross Square
    z.rect(33, 18, 15, 3, "=")
    z.rect(33, 17, 14, 1, ":"); z.rect(33, 21, 14, 1, ":")
    z.rect(4, 18, 9, 2, "="); z.rect(4, 17, 9, 1, ":"); z.rect(4, 20, 9, 1, ":")
    z.prop("statue", 22, 18)    # the market cross, near enough
    for (x, y) in [(15, 16), (30, 16), (15, 20), (30, 20)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 18, 17); z.prop("bench", 26, 17); z.prop("planter", 18, 20); z.prop("planter", 26, 20)
    z.prop("phone_box", 20, 16); z.prop("post_box", 24, 16)
    # town buildings (door row at the bottom, pavement below)
    z.building(5, 12, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(12, 12, 5, 4, "shop", "Corner Shop", door=2)
    z.rect(5, 16, 12, 1, ":")
    z.building(26, 12, 7, 4, "white_render", "The Enclosure Gift Shop")
    z.rect(26, 16, 7, 1, ":")
    z.building(34, 12, 6, 4, "cream_render", "Oriel y Parc", show_label=True)
    z.building(41, 13, 5, 3, "slate_cottage", show_label=False)
    z.building(4, 5, 6, 3, "slate_cottage", show_label=False); z.building(11, 5, 5, 3, "terrace", "Tea Rooms")
    z.building(26, 4, 6, 4, "stone", "Pilgrim Hostel")
    z.rect(14, 8, 8, 1, ":")
    path(z, [(8, 8), (8, 11)], ":", 1); z.rect(8, 8, 1, 4, ":"); z.rect(13, 8, 1, 4, ":")
    z.rect(25, 8, 1, 8, ":"); z.rect(25, 8, 10, 1, ":")
    z.warp(8, 15, "st_davids_sanctuary", 5, 6, "up"); z.warp(14, 15, "st_davids_shop", 4, 5, "up")
    # the Enclosure's stall out front
    z.prop("market_stall", 29, 17, variant=2); z.prop("market_stall", 31, 17, variant=0)
    z.sign(30, 17, "THE ENCLOSURE GIFT SHOP. Authentic Dragon Scales, 3 for 2! Small print: crisps. Salt and vinegar. Ingredients: potato.")
    # station
    pf = station(z, 36, 4, 8, 3, "St Davids Halt")
    z.rect(35, 6, 1, 1, "#"); z.rect(44, 6, 1, 1, "#"); z.rect(36, 3, 8, 1, ":")
    z.rect(35, 3, 1, 5, "#"); z.rect(34, 3, 1, 1, ":")
    rail_guard(z, 41, 6, ["St Davids Halt. Britain's smallest city, with no real railway for sixty years.",
                          "Don't tell the timetable. The Wildlore rail doesn't mind. Where to?"])
    # the steps down and the hollow with its cathedral
    z.rect(4, 23, 17, 1, "W"); z.rect(24, 23, 20, 1, "W"); z.rect(4, 22, 17, 1, "H"); z.rect(24, 22, 20, 1, "H")
    z.rect(21, 21, 2, 4, "#")
    z.rect(21, 25, 2, 9, "#")
    z.rect(4, 25, 40, 13, ".")
    z.rect(4, 38, 40, 2, "T"); z.scatter(2, 36, 44, 4, "P", 20, 6, only="T")
    z.building(8, 26, 11, 6, "cathedral", "St Davids Cathedral", door=5)
    z.rect(11, 32, 11, 2, "#"); z.rect(11, 33, 12, 1, "#")
    z.rect(30, 25, 2, 13, "~"); z.rect(30, 33, 2, 2, "w"); z.rect(29, 33, 4, 2, "#")
    z.building(34, 26, 7, 4, "castle", "Bishop's Palace")
    z.building(38, 30, 5, 3, "castle", show_label=False)
    z.rect(27, 33, 3, 2, "#"); z.rect(32, 33, 9, 2, "#")
    scatter_props(z, "standing_stone", 5, 27, 5, 9, 4, 2, avoid=(".",))   # graves, near enough
    z.rect(5, 28, 3, 6, "f")
    z.prop("oak", 6, 36); z.prop("oak", 24, 28); z.prop("oak", 27, 36); z.prop("bench", 23, 30); z.prop("bench", 15, 34)
    z.prop("lamp_post", 11, 34); z.prop("lamp_post", 21, 34)
    z.sign(21, 25, "THE THIRTY-NINE STEPS. Down to the cathedral. Up again is the part nobody mentions.")
    z.sign(20, 19, "ST DAVIDS. Population about 1,600. A city because of the cathedral. Pop in. They'll pretend not to be surprised.")
    z.sign(28, 35, "RIVER ALUN. Shallow, polite, and the reason the cathedral sits in a hollow: nobody could see it from the sea.")
    # NPCs
    chat(z, "verger", "villager_2", 20, 34, "Verger",
         ["St Davids Cathedral sits in a hollow so Viking raiders couldn't spot it from the sea. Works rather well.",
          "Not perfectly. They sacked it several times. Still, nice try."], "up", "still")
    chat(z, "pilgrim", "hiker", 16, 19, "Pilgrim",
         ["In the Middle Ages, two pilgrimages to St Davids counted as one to Rome. Three, one to Jerusalem. A bargain.",
          "I've done one. I'm on the way back. My feet are asking about the other two."], "down", "wander")
    chat(z, "ramsey_boat", "sailor", 6, 19, "Boat Skipper",
         ["Boats to Ramsey Island leave from the lifeboat station. Seals, puffins and, on a bad day, passengers who forgot a coat.",
          "The tide race at Ramsey Sound is fierce. Perfect for lunch. Not for a swim."], "right", "still")
    chat(z, "tea_lady", "villager_1", 12, 8, "Tea Room Lady",
         ["Welsh cakes, bara brith and a pot for one. St David is the patron saint of Wales. March first.",
          "He ate bread and herbs and drank water. A very sensible man. I still insist on the cake."], "down", "still")
    chat(z, "hollow_gardener", "villager_6", 19, 29, "Gardener",
         ["Daffodils in the churchyard by March. I plant them at Christmas. It's tradition and bad planning.",
          "The leek's the other national emblem. Don't ask which is tastier. People get defensive."], "down", "wander")
    trainer(z, "warden_hywel", "Warden Hywel", "Warden", "warden_grunt", [("cragchough", 33), ("puffling", 33), ("petrelash", 34)],
            24, 18, "left",
            ["Authentic Dragon Scales! Hand-sourced from a genuine dragon! Mind the crisp-bag, I mean, scale.",
             "You doubt our scales? Our scales have a QR code!"],
            "Oh. They ARE crisps. I'll just, er, put the stall away.",
            "Salt and vinegar, mostly. The cheese and onion are hatchlings.", 760, "still")
    z.rect(42, 25, 3, 4, ","); z.rect(24, 36, 5, 2, ",")
    wild(z, [("puffling", 33, 34, 40, {"time": ["dawn", "day", "dusk"]}), ("cragchough", 33, 34, 40, {}),
             ("petrelash", 34, 34, 20, {"weather": ["drizzle", "gale"]})])
    z.d["edges"] = {"north": {"to": "pembroke_coast", "offset": 0}, "east": {"to": "beacons", "offset": 0}}
    z.d["spawn"] = [21, 17]
    seal_ns(z, 20, 22, True, True)
    # east edge: only rows 18..20 are open
    for y in range(40):
        if not 18 <= y <= 20 and z.g[y][47] in ".,#sf=:w":
            z.set(47, y, "T")
    z.save(OUT + "/st_davids.json")
    sanctuary(OUT, "st_davids", "St Davids", (8, 16))
    shop(OUT, "st_davids", "St Davids", (14, 16))
    nurse("st_davids", ["Welcome to the St Davids Sanctuary. The smallest city, the biggest sofa. Pop your team on the counter.",
                        "A quick rest, a warm cup of tea, and the Ark's pilgrims will be along shortly.",
                        "All better! Walk gently. Pilgrims have been coming this way for a thousand years.",
                        "The Ark terminal's just here. Mind the pew.",
                        "Right you are. Shout if anyone needs a plaster."])
    shopkeeper("st_davids", "Croeso! Snares, tea and the last honest dragon scale in town. It's a biscuit.",
               "Hwyl fawr! Follow the pigeons, they know the way to the cathedral.")


def build(OUT):
    build_coast(OUT)
    build_town(OUT)
