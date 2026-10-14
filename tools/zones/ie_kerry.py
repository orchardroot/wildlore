# ring_of_kerry (route) and dingle (town) with Sanctuary and Corner Shop.
from ie_common import *


def build(OUT):
    kerry(OUT)
    dingle(OUT)


def kerry(OUT):
    W, H = 64, 44
    zid = "ring_of_kerry"
    z = Z(zid, "Ring of Kerry", W, H, kind="route", region="ireland_west", music="route_ireland",
          weather={"drizzle": 30, "clear": 20, "fog": 14, "downpour": 12, "sunshine": 14, "gale": 6, "frost": 4})
    z.d["stage"] = "forest"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["r"] = {"tile": "tall_grass", "colour": "#6f7f4a", "prop": "reeds"}
    z.legend["k"] = {"tile": "grass", "colour": "#7f8a55"}
    z.border("T", 2, gaps=[(28, 0, 3, 2), (62, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 40, 2, only="T")
    # mountains: the Reeks in the south-east
    hills(z, [(50, 36, 5, 14), (38, 38, 3, 7), (58, 28, 2, 5)])
    z.rect(34, 27, 28, 15, "k")
    for (x, y, w, h) in [(40, 32, 8, 5), (52, 31, 7, 5), (36, 36, 5, 4), (46, 38, 6, 3), (56, 36, 4, 4)]:
        z.rect(x, y, w, h, "h")
    # Killarney lake: Lough Leane in the west with an island abbey
    blob(z, 14, 32, 12.5, 8.5, "w", only=".", seed=1)
    blob(z, 14, 32, 11, 7, "~", seed=2)
    blob(z, 12, 31, 2.5, 1.7, ".", seed=3)
    z.building(11, 30, 3, 2, "chapel", "Innisfallen Abbey")
    for (x, y, w, h) in [(5, 38, 6, 2), (18, 38, 7, 2), (2, 30, 2, 5), (24, 25, 2, 4)]:
        z.rect(x, y, w, h, "r")
    # the Muckross stream from the lake to the east, shallow and crossable
    z.rect(26, 34, 8, 1, "w"); z.rect(34, 34, 10, 1, "~"); z.rect(44, 34, 3, 1, "w")
    # old oak woods, north-west
    z.rect(3, 3, 21, 8, ".")
    woods = random.Random(7)
    for y in range(3, 19):
        for x in range(3, 25):
            if x < 24 and woods.random() < 0.52 and not (y > 10 and x > 18):
                z.set(x, y, "T")
    for (x, y, w, h) in [(5, 4, 5, 3), (13, 5, 5, 4), (19, 12, 4, 4), (4, 12, 4, 4), (9, 7, 3, 2)]:
        z.rect(x, y, w, h, ",")
    # Torc waterfall: a stepped plateau, a cliff face and a stream
    z.height(40, 3, 19, 6, 2)
    z.height(41, 9, 2, 2, 1)
    z.rect(39, 3, 1, 8, "R"); z.rect(40, 9, 1, 2, "R"); z.rect(43, 9, 1, 2, "R")
    z.rect(44, 9, 15, 1, "^")
    z.rect(44, 3, 15, 6, ".")
    for y in range(3, 9):
        for x in range(44, 59):
            if woods.random() < 0.3 and abs(x - 50) > 1:
                z.set(x, y, "T")
    z.rect(50, 3, 1, 7, "~")
    blob(z, 50, 12, 5, 2.6, "w", seed=4); blob(z, 50, 12, 3.6, 1.8, "~", seed=5)
    z.rect(47, 14, 7, 3, ","); z.rect(55, 11, 5, 6, ",")
    # paths
    z.rect(28, 0, 3, 23, "#")
    z.rect(4, 20, 26, 3, "#")
    z.rect(30, 20, 34, 3, "#")
    z.rect(41, 5, 9, 1, "#"); z.rect(41, 5, 2, 15, "#")
    z.rect(24, 3, 2, 18, "#")
    z.rect(48, 23, 2, 14, "#")
    z.rect(30, 23, 1, 11, "#")
    # Muckross House and its gardens
    z.building(8, 12, 9, 5, "stone", "Muckross House", door=4)
    z.rect(6, 17, 13, 3, "#"); z.rect(10, 10, 5, 2, "f"); z.rect(6, 13, 2, 4, "f"); z.rect(17, 13, 2, 4, "f")
    z.rect(5, 20, 0, 0, "#")
    z.prop("bench", 7, 18); z.prop("bench", 17, 18); z.prop("lamp_post", 10, 18); z.prop("lamp_post", 14, 18)
    z.prop("planter", 6, 12); z.prop("planter", 18, 12)
    z.sign(12, 18, "MUCKROSS HOUSE. A Victorian mansion of 1843, built for the Herberts and tidied up for a visit by Queen Victoria in 1861. Some say the visit nearly bankrupted them. It was only tea.")
    # Ross Castle
    z.building(32, 28, 5, 4, "castle", "Ross Castle")
    z.rect(27, 33, 4, 1, "#")
    z.prop("bench", 29, 31); z.prop("lamp_post", 31, 32); z.prop("bollard", 27, 34)
    z.sign(31, 27, "ROSS CASTLE. A tower house on the shore of Lough Leane, 15th century and built by the O'Donoghue clan. The legend says the chieftain still sleeps under the lake, and rises every seven years.")
    z.sign(29, 23, "KILLARNEY NATIONAL PARK. Ireland's first national park, 1932. Home of the last native herd of red deer in the country. They don't read the sign, either.")
    z.sign(42, 11, "TORC WATERFALL. About twenty metres of white water tumbling down an old oak wood. Torc means 'wild boar' in Irish. We've no idea why the boar needs a waterfall.")
    z.sign(46, 5, "LADIES' VIEW. Named for Queen Victoria's ladies-in-waiting, who were so taken with the view in 1861 that the road was named for them. The view hasn't charged for it since.")
    z.sign(48, 26, "MACGILLYCUDDY'S REEKS. The highest mountains in Ireland, with Carrauntoohil at 1,038 metres. The name is an English mangle of an old clan. 'Reek' means a rocky peak, not a smell.")
    # props and scatter
    for (x, y) in [(26, 18), (27, 25), (33, 24), (44, 24), (21, 24)]:
        z.prop("bush", x, y)
    scatter_props(z, "oak", 3, 3, 22, 16, 12, 5, avoid=(".",))
    scatter_props(z, "bush", 3, 21, 58, 20, 22, 6, avoid=(".", "k"))
    scatter_props(z, "rock", 34, 27, 28, 15, 20, 7, avoid=("k", "h"))
    scatter_props(z, "rock", 43, 3, 15, 5, 5, 8, avoid=("."))
    # red deer as scenery
    for (sp, x, y, mv) in [("stagmor", 46, 25, "wander"), ("fawnlet", 36, 25, "wander"), ("fawnlet", 56, 26, "wander"),
                           ("stagmor", 21, 8, "still"), ("fawnlet", 52, 17, "wander"), ("kerryspot", 29, 36, "wander")]:
        creature(z, zid, sp, x, y, mv, who={"stagmor": "Red Deer", "fawnlet": "Red Deer Calf", "kerryspot": "Kerry Slug"}[sp],
                 line={"stagmor": "The stag lifts a head like a coat rack and considers you. You are not a threat. You are barely a footnote.",
                       "fawnlet": "It trots three paces, stops, stares, and trots back. Calves are professionals at looking lost.",
                       "kerryspot": "A big dark slug with pale spots. It's the Kerry slug, found in Kerry and Spain and practically nowhere else. It is not in a hurry."}[sp])
    # chat
    chat(z, "jarvey", "villager_3", 33, 23, "Jarvey",
         ["Jaunting cars have carried visitors round Killarney for two hundred years. I'm a jarvey. The horse is the boss, I just hold the reins.",
          "Don't be hearing 'it's a tourist thing'. It's a very old tourist thing. Fáilte, anyway."], "up", "still")
    chat(z, "deer_ranger", "hiker", 44, 19, "Park Ranger",
         ["Killarney is home to Ireland's only native herd of red deer. They've been here since the last Ice Age, and survived hunting, wolves and tourists.",
          "I count them every autumn at the rut. The stags roar. It sounds like a very large cow with a tragic secret."], "left", "still")
    chat(z, "lake_painter", "student", 28, 34, "Sketching Student",
         ["Cill Airne, the Irish name for Killarney, means the church of the sloes. That's the blackthorn berry. It's the colour I can't ever get right.",
          "I've done the same lake eleven times. Every time the weather has moved it. Every time I'm not wrong."], "right", "still")
    chat(z, "kerry_farmer", "farmer", 15, 21, "Farmer",
         ["Kerry Bog Ponies are small, hardy and not at all impressed by you. And the Kerry cow is one of the oldest breeds in Europe.",
          "Hang on. Is that a slug? That's the Kerry slug. It's more famous than the cow, these days. The cow has taken it badly."], "up", "wander")
    chat(z, "reeks_walker", "jogger", 52, 21, "Fell Walker",
         ["Carrauntoohil in the Reeks is Ireland's highest. It's 1,038 metres and it will tell you every one of them.",
          "My advice: start at dawn, take a waterproof, and never trust a path that's called the Devil's Ladder."], "left", "wander")
    # trainers
    trainer(z, "kerry_birder", "Birdwatcher Niamh", "Birdwatcher", "birdwatcher", [("heronarch", 54), ("corncrake", 53), ("polartern", 54)],
            36, 17, "down", ["Shh. There's a white-tailed eagle over the lake. They were reintroduced to Killarney in 2007 after a hundred years away."],
            "Fair play to you. The eagle's gone off in a huff.", "Eagles: nine foot of wing and the manners of a landlord.", 2250)
    trainer(z, "kerry_angler", "Angler Cormac", "Angler", "angler", [("bradan", 54), ("rillotter", 54), ("spatelord", 55)],
            24, 29, "right", ["The lake's full of salmon, trout and char. The char's been here since the Ice Age. I only come for the patience."],
            "Landed fair and square. I'll have a cup of tea about it.", "A tight line, a flask and a view. That's the whole religion.", 2200)
    trainer(z, "kerry_hurler", "Hurler Eoin", "Hurler", "rugby_player", [("stagmor", 55), ("raidtail", 54), ("gealhare", 54)],
            58, 24, "left", ["Hurling's the oldest field game in Europe, at least three thousand years. I just hit things with a stick, but with tradition."],
            "A fair puck. I'll go back to practising the frees.", "A sliotar can hit a hundred and fifty kilometres an hour. Always wear a helmet.", 2260)
    trainer(z, "kerry_warden", "Warden Ptolemy", "Warden", "warden_grunt", [("hazeldoze", 53), ("pooka", 54), ("stagmor", 54)],
            14, 9, "down", ["Welcome to the Wild Atlantic Heritage Experience! A forest, curated! Sixteen deer, all numbered."],
            "I'll note it in my report. Under 'unforeseen competence'.", "Director Kerrigan wants the whole west coast on one handy leaflet.", 2160)
    z.d["edges"] = {"north": {"to": "dingle", "offset": 0}, "east": {"to": "cork", "offset": 0}}
    z.d["spawn"] = [29, 3]
    wild(z, [("fawnlet", 53, 54, 14, {}), ("stagmor", 54, 55, 8, {"time": ["dawn", "dusk"]}),
             ("kerryspot", 53, 55, 12, {"weather": ["drizzle", "downpour", "fog"]}), ("hazeldoze", 53, 54, 10, {}),
             ("gealhare", 54, 55, 8, {"time": ["dawn", "day"]}), ("rookery", 54, 55, 10, {"time": ["day", "dusk"]}),
             ("hushwing", 54, 55, 10, {"time": ["night"]}), ("pooka", 54, 55, 4, {"time": ["night"], "weather": ["fog"]}),
             ("snowhare", 54, 55, 6, {"weather": ["frost"]}), ("corncrake", 53, 54, 8, {"time": ["dawn", "day"], "weather": ["clear", "sunshine"]})])
    wild(z, [("kerryspot", 53, 55, 14, {}), ("bradan", 54, 55, 20, {}), ("rillotter", 54, 55, 20, {}), ("heronarch", 54, 55, 14, {}),
             ("spatelord", 54, 55, 16, {"time": ["dusk", "night"]}), ("parrlet", 53, 54, 10, {})], "water")
    finish(z)
    z.save(OUT + "/ring_of_kerry.json")


def dingle(OUT):
    W, H = 60, 44
    zid = "dingle"
    z = Z(zid, "Dingle", W, H, kind="town", region="ireland_west", music="town_ireland",
          weather={"clear": 22, "drizzle": 28, "sunshine": 16, "gale": 14, "fog": 10, "downpour": 10})
    z.d["stage"] = "docks"; z.d["town_id"] = "dingle"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.border("T", 2, gaps=[(28, 42, 3, 2), (58, 16, 2, 3)])
    z.scatter(0, 0, W, H, "P", 20, 2, only="T")
    z.rect(0, 0, W, 3, "$"); z.rect(0, 3, W, 6, "~")
    z.rect(0, 0, 2, 3, "$")
    # quay, pier and lighthouse
    z.rect(2, 9, 56, 2, ":")
    z.rect(41, 3, 2, 6, ":"); z.rect(14, 5, 8, 1, ":")
    z.prop("lighthouse", 42, 3)
    for x in range(4, 56, 6):
        z.prop("bollard", x, 9)
    for (x, y, v) in [(6, 6, 1), (10, 4, 1), (17, 7, 1), (25, 5, 1), (30, 7, 0), (34, 4, 1), (46, 6, 1), (51, 4, 1), (54, 7, 1), (22, 7, 1), (38, 6, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(8, 7), (13, 6), (28, 4), (44, 8), (49, 7)]:
        z.prop("buoy", x, y)
    # streets
    z.rect(2, 15, 56, 1, ":"); z.rect(2, 16, 58, 3, "="); z.rect(2, 19, 56, 1, ":"); z.rect(2, 24, 56, 1, ":")
    z.rect(28, 11, 3, 4, "="); z.rect(27, 11, 1, 4, ":"); z.rect(31, 11, 1, 4, ":")
    z.rect(28, 19, 3, 25, "="); z.rect(27, 20, 1, 22, ":"); z.rect(31, 20, 1, 22, ":")
    # the colourful row facing the harbour (their doors are the street, so fronts are painted at the back too)
    row_a = [(3, 7, "terrace", "The Dolphin Gifts"), (11, 6, "cream_render", "Fish Supper"), (18, 5, "white_render", "Cone Zone"),
             (24, 4, "slate_cottage", "Tweed and Wool"), (32, 5, "red_brick", "Marina Cafe"), (38, 6, "terrace", "Books Beyond the Bay"),
             (45, 5, "cream_render", "Strand Bakery"), (51, 6, "tudor", "The Pier Bar")]
    for (x, w, st, lab) in row_a:
        z.building(x, 11, w, 4, st, lab)
    # Sanctuary and Corner Shop on the south side of Main Street
    z.building(6, 20, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(13, 20, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(9, 23, "dingle_sanctuary", 5, 6, "up"); z.warp(15, 23, "dingle_shop", 4, 5, "up")
    z.building(19, 20, 8, 4, "white_render", "Oceanworld")
    z.building(32, 20, 9, 4, "tudor", "The Dolphin Inn")
    z.building(42, 20, 6, 4, "terrace", "Gallarus Gifts")
    z.building(49, 20, 6, 4, "slate_cottage", "Bus Office")
    z.building(2, 20, 3, 4, "red_brick", show_label=False)
    z.building(56, 20, 3, 4, "cream_render", show_label=False)
    # Fungie the dolphin, on the quay
    z.prop("statue", 34, 10)
    z.sign(33, 10, "FUNGIE. A bottlenose dolphin who turned up in Dingle harbour in 1983 and greeted the boats for over thirty-five years. In 2020 he swam off, and the whole town went quiet. The statue is here so we've somewhere to say hello.")
    z.sign(29, 9, "DINGLE, AN DAINGEAN. 'The fortress', in Irish. About two thousand people, a Gaeltacht where Irish is the everyday language, and a lot of pubs, some of which are also hardware shops.")
    z.prop("planter", 27, 10); z.prop("planter", 31, 10); z.prop("bench", 20, 10); z.prop("bench", 48, 10)
    for x in (6, 16, 24, 38, 46, 54):
        z.prop("lamp_post", x, 15)
    for x in (10, 22, 36, 44, 52):
        z.prop("lamp_post", x, 24)
    z.prop("phone_box", 3, 19); z.prop("post_box", 57, 19)
    # the bus stop (no rail here)
    z.rect(49, 25, 7, 1, "#")
    z.prop("bench", 51, 26); z.prop("bench", 53, 26); z.prop("lamp_post", 55, 26)
    z.sign(50, 26, "BUS STOP. Tralee, Killarney, Slea Head Drive. The timetable says 'approximately'. It's an honest timetable.")
    rail = z.d["npcs"]
    z.npc(id="rail_guard", sprite="rail_guard", x=52, y=26, facing="up", move="still", script="rail_guard")
    script(zid, "rail_guard", say("Rail Guard",
        "Dingle's railway closed in 1953 and the sheep have been using the track since. There's no train here, and I'm not entitled to sell you a ticket for one.",
        "I'm the guard of nothing, to be honest. It's a lovely job. I get to wave at the bus."))
    # the south: hill, green, church and cove
    hills(z, [(8, 35, 3, 9)])
    z.rect(2, 26, 54, 16, ".")
    z.rect(3, 27, 11, 5, ","); z.rect(34, 27, 11, 5, ","); z.rect(19, 33, 8, 4, ","); z.rect(46, 29, 10, 4, ",")
    z.rect(2, 33, 16, 8, "h")
    z.rect(34, 34, 6, 5, "f"); z.rect(12, 35, 3, 3, "f")
    blob(z, 50, 38, 7, 3.4, "s", seed=1); blob(z, 50, 38, 5, 2.2, "~", seed=2)
    z.rect(43, 36, 4, 4, "s")
    z.building(36, 28, 6, 4, "chapel", "St James' Church")
    z.rect(36, 32, 6, 1, "#"); z.rect(38, 25, 1, 3, "#")
    z.rect(8, 25, 1, 3, "#"); z.rect(20, 25, 1, 3, "#")
    z.rect(28, 25, 3, 18, "=")
    for (x, y) in [(31, 36), (24, 32), (46, 27)]:
        z.prop("bush", x, y)
    scatter_props(z, "bush", 3, 26, 52, 15, 18, 3, avoid=(".",))
    scatter_props(z, "rock", 2, 33, 16, 8, 10, 4, avoid=("h", "."))
    z.sign(20, 27, "SLEA HEAD DRIVE. A thirty-mile loop round the end of the peninsula, with the Blasket Islands out to sea and a view that makes people stop their cars in the middle of the road. Please don't.")
    z.sign(43, 33, "THE COVE. Grey seals haul out on the rocks below the harbour. They know exactly how photogenic they are.")
    # NPCs
    chat(z, "boat_skipper", "sailor", 26, 10, "Boat Skipper",
         ["I run the dolphin trips. Fungie was in the harbour from 1983 until 2020. He greeted thirty-five years of boats, and then he just quit.",
          "We still go out and look. You don't give up on a friend. You only cross-check the tide table."], "up", "still")
    chat(z, "irish_teacher", "student", 14, 17, "Gaeilge Student",
         ["Dingle's a Gaeltacht, so Irish is the everyday language. You'll hear it in the shop queue. 'Dia duit' is hello, and 'Dia is Muire duit' is the reply.",
          "'Slán' is goodbye. 'Go raibh maith agat' is thank you. Say it badly and they'll love you for trying."], "right", "wander")
    chat(z, "chipper_owner", "shopkeeper", 12, 16, "Chipper Owner",
         ["The best fish supper in Ireland is whichever one you're eating hungry, standing in the wind, with the seagull watching.",
          "We get the fish off the boats at eight. By nine they're gone. By ten I'm just telling people about it."], "down", "still")
    chat(z, "ceili_dancer", "villager_5", 40, 17, "Ceili Dancer",
         ["The set dances here go back to the quadrilles of old France. We changed them. Of course we did.",
          "Arms straight, feet quick, and never look at your feet. If you look at your feet, the floor knows."], "down", "wander")
    chat(z, "oceanworld_guide", "tour_guide", 24, 25, "Oceanworld Guide",
         ["Our aquarium has a tunnel with sharks overhead, and a tank of rays that behave like kids at a bus window.",
          "The Blasket Islands are across the water. The last islanders left in 1953. They wrote beautiful books about it, in Irish."], "up", "still")
    chat(z, "gallarus_walker", "hiker", 44, 17, "Walker",
         ["Gallarus Oratory is a little dry-stone church shaped like an upturned boat, about twelve hundred years old. And it's still dry inside.",
          "No mortar. Just stones that fit. It's the best bit of Irish engineering that nobody asked for."], "left", "wander")
    trainer(z, "dingle_rower", "Currach Rower Mairead", "Currach Rower", "sailor", [("selkie", 55), ("plungebeak", 55), ("bayrunner", 55)],
            21, 10, "right", ["A currach is a boat of tarred canvas on a lath frame. We've rowed them for a thousand years. They're lighter than a bad excuse."],
            "Fair play. I'd take a bow, but I'm sitting in the sea.", "Never row into a swell with the wind behind you. And never trust a seal's apology.", 2300)
    trainer(z, "dingle_fiddler", "Fiddler Tadhg", "Fiddler", "harpist", [("gealhare", 55), ("cluricaun", 55), ("selklet", 55)],
            44, 19, "up", ["Session's at nine. Warm-up's now. Fancy a tune, or a battle? They're not so different. Both are about timing."],
            "A lovely reel, you play a hard game.", "The tune doesn't belong to anyone. That's why it's still alive.", 2280)
    z.d["edges"] = {"south": {"to": "ring_of_kerry", "offset": 0}, "east": {"to": "burren", "offset": 0}}
    z.d["spawn"] = [29, 22]
    wild(z, [("gannetling", 55, 55, 10, {"time": ["day", "dawn"]}), ("plungebeak", 55, 55, 12, {}),
             ("ternlet", 55, 55, 8, {"weather": ["frost", "gale"]}), ("polartern", 55, 55, 8, {"weather": ["clear", "sunshine"]}),
             ("selklet", 55, 55, 10, {"weather": ["fog", "drizzle"]}), ("selkie", 55, 55, 8, {"time": ["dusk", "night"]}),
             ("chipgull", 55, 55, 14, {"time": ["day"]}), ("merrow", 55, 55, 3, {"time": ["night"], "weather": ["fog"]}),
             ("crexling", 55, 55, 6, {"time": ["dawn", "dusk"]})])
    wild(z, [("selklet", 55, 55, 20, {}), ("selkie", 55, 55, 12, {}), ("bayrunner", 55, 55, 12, {}), ("merrow", 55, 55, 6, {"time": ["night"]}),
             ("gannetling", 55, 55, 15, {}), ("plungebeak", 55, 55, 15, {})], "water")
    finish(z)
    z.save(OUT + "/dingle.json")
    sanctuary(OUT, "dingle", "Dingle", (9, 24), music="sanctuary")
    shop(OUT, "dingle", "Dingle", (15, 24))
    nurse("dingle", ["Céad míle fáilte to the Dingle Sanctuary. A hundred thousand welcomes, and no extra charge for the draught. Pop your team on the counter.",
                     "Grand job. Sit by the stove. The kettle's already on, it's a Dingle law.",
                     "They're right as rain. Slán abhaile, safe home, and mind the wind off the harbour.",
                     "The Ark terminal's in the corner. It runs on tea, brown bread and mild disapproval.",
                     "No bother at all. Sit as long as you want. The rain isn't going anywhere."])
    shopkeeper("dingle", "Dia duit! Snares, tea, one wool jumper and a postcard of a dolphin. Take your time, the sea's not going anywhere.",
               "Slán! Say hello to the harbour for me.")
