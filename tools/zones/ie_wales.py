# plan 4 group B, part 1: anglesey (route) and holyhead (port town) with Sanctuary and Corner Shop.
from wcommon import *
import math


def build(OUT):
    anglesey(OUT)
    holyhead(OUT)


def anglesey(OUT):
    W, H = 72, 40
    z = Z("anglesey", "Anglesey", W, H, kind="route", region="north_wales", music="route_coast",
          weather={"clear": 22, "sunshine": 14, "drizzle": 22, "gale": 16, "fog": 12, "downpour": 14})
    z.d["stage"] = "coast"
    z.legend["g"] = {"tile": "tall_grass", "colour": "#b5a53a", "prop": "none"}     # gorse
    z.border("T", 2, gaps=[(70, 10, 2, 3), (0, 22, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 3, only="T")
    # the Menai Strait, with a sandy shore on the island side
    z.rect(38, 0, 18, H, "~")
    z.rect(37, 2, 1, 36, "s")
    # mainland east bank
    z.rect(56, 2, 14, 36, ".")
    # Telford's suspension bridge: a long road over the water
    z.rect(28, 10, 44, 3, "=")
    z.rect(38, 9, 20, 1, "W"); z.rect(38, 13, 20, 1, "W")
    z.building(41, 4, 3, 6, "stone", "Pier Tower", show_label=False)
    z.building(41, 13, 3, 6, "stone", "Pier Tower", show_label=False)
    z.building(51, 4, 3, 6, "stone", "Pier Tower", show_label=False)
    z.building(51, 13, 3, 6, "stone", "Pier Tower", show_label=False)
    for x in (39, 46, 48, 56):
        z.prop("lamp_post", x, 9)
        z.prop("lamp_post", x, 13)
    z.prop("statue", 56, 7); z.prop("statue", 56, 15)    # the Britannia Bridge lions, borrowed for the day
    z.sign(35, 9, "THE MENAI SUSPENSION BRIDGE. Thomas Telford, 1826. At 176 m, the longest span in the world when it opened. It lets a road hop over the strait that kept Anglesey an island for the whole of history. Be nice to it: it is nearly two hundred years old.")
    z.sign(58, 9, "CROESO I YNYS MÔN. Welcome to Anglesey. Mam Cymru, 'Mother of Wales', because its wheat once fed the mountains. Please mind the sheep, the sheep do not mind you.")
    # east bank: a visitor centre and a lay-by
    z.rect(58, 6, 8, 3, ":"); z.rect(62, 9, 1, 1, ":")
    z.building(59, 3, 7, 3, "white_render", "Bridge Visitor Centre", door=3)
    z.rect(62, 6, 1, 4, ":")
    z.rect(58, 15, 6, 6, "g"); z.rect(63, 24, 6, 6, ","); z.rect(58, 29, 6, 6, "g")
    z.prop("bench", 60, 7); z.prop("planter", 58, 5); z.prop("planter", 65, 5); z.prop("post_box", 66, 9)
    scatter_props(z, "bush", 57, 14, 12, 22, 12, 4, avoid=(".",))
    # the island: roads and paths
    z.rect(28, 10, 3, 20, "#"); z.rect(0, 22, 31, 3, "#")
    z.rect(30, 10, 8, 3, "=")
    # field boundaries with gaps
    z.rect(18, 3, 1, 15, "H"); z.rect(18, 8, 1, 2, "."); z.rect(18, 14, 1, 2, ".")
    z.rect(3, 17, 24, 1, "H"); z.rect(8, 17, 2, 1, "."); z.rect(20, 17, 2, 1, ".")
    z.rect(3, 28, 24, 1, "W"); z.rect(10, 28, 2, 1, "."); z.rect(22, 28, 3, 1, ".")
    # tall grass and gorse
    for (x, y, w, h) in [(4, 4, 6, 3), (20, 4, 7, 5), (22, 12, 5, 4), (4, 19, 8, 3), (15, 19, 8, 3), (28, 31, 7, 5), (4, 35, 12, 2)]:
        z.rect(x, y, w, h, ",")
    for (x, y, w, h) in [(12, 3, 5, 3), (3, 12, 4, 4), (13, 12, 4, 3), (12, 31, 5, 3)]:
        z.rect(x, y, w, h, "g")
    # standing stones: Bryn Celli Ddu, the Mound in the Dark Grove
    z.rect(8, 7, 7, 5, "f")
    z.prop("standing_stone", 9, 8, variant=0); z.prop("standing_stone", 12, 7, variant=1); z.prop("standing_stone", 13, 10, variant=2)
    z.prop("standing_stone", 10, 11, variant=1)
    z.sign(11, 9, "BRYN CELLI DDU. A passage tomb 5,000 years old, under a mound near the strait. On the longest day of the year the sun shines down the passage. The builders didn't have a calendar. They had a very good eye and a lot of patience.")
    z.prop("standing_stone", 24, 19, variant=2)
    z.sign(25, 19, "A LONE STONE. Nobody knows who put it here or why. The farmer says it was here when he came. The sheep say it's their rubbing post.")
    # the village with the long name
    z.rect(3, 29, 15, 1, ":"); z.rect(10, 28, 2, 1, ":")
    z.building(3, 30, 7, 4, "white_render", "Llanfair PG Station Sign Shop")
    z.building(11, 30, 5, 4, "slate_cottage", show_label=False)
    z.rect(3, 34, 15, 1, ":"); z.rect(20, 29, 8, 1, ":")
    z.building(20, 30, 4, 4, "mill", "Llynnon Mill")
    z.building(25, 31, 3, 3, "stone", show_label=False)
    z.rect(20, 34, 8, 1, ":")
    z.prop("bench", 17, 29); z.prop("lamp_post", 17, 35); z.prop("planter", 10, 29); z.prop("planter", 5, 34)
    z.sign(27, 21, "LLANFAIRPWLLGWYNGYLLGOGERYCHWYRNDROBWLLLLANTYSILIOGOGOGOCH. Fifty-eight letters. The village renamed itself in the 1860s to attract tourists, and it worked. Locals say Llanfair PG. The sign is longer than the high street.")
    z.sign(9, 29, "SORRY. The rest of the name is on the next sign. And the one after that.")
    z.sign(23, 35, "LLYNNON MILL. One of the last working windmills in Wales. It grinds flour using only wind, grumbling, and a nice view of the sea.")
    # the strait shore: a jetty
    z.rect(31, 29, 9, 1, "|")
    z.prop("boat", 44, 29, variant=1); z.prop("buoy", 43, 32); z.prop("buoy", 46, 26); z.prop("boat", 48, 33, variant=1)
    z.prop("bollard", 34, 28); z.prop("bollard", 34, 30)
    scatter_props(z, "bush", 3, 3, 33, 33, 22, 5, avoid=(".",))
    scatter_props(z, "oak", 3, 3, 33, 33, 8, 6, avoid=(".",))
    scatter_props(z, "rock", 3, 3, 33, 33, 8, 7, avoid=(".",))
    # NPCs
    chat(z, "bridge_guide", "tour_guide", 61, 8, "Bridge Guide",
         ["Telford's bridge hangs on sixteen wrought iron chains. They are held at each end in tunnels cut into the rock.",
          "Before the bridge, you crossed by ferry, or you swam, or you waited for a tide, or you did not cross. Quite the commute."], "down", "still")
    chat(z, "island_farmer", "farmer", 21, 14, "Farmer",
         ["Anglesey's sheep and cattle are grand, but our sea salt is famous. Halen Môn, they call it.",
          "Roman soldiers wrote that the druids made their last stand on this island. It's got a lot of history for a place that mostly has fields."], "right", "still")
    chat(z, "stone_student", "student", 12, 12, "Archaeology Student",
         ["Bryn Celli Ddu is the passage tomb. The sun comes through the gap on the summer solstice. It's like a timer for the dead.",
          "I'm a volunteer. My job is to stand here and stop people climbing on the stones. And to look cross about it, which I do very well."], "down", "wander")
    chat(z, "sign_reader", "villager_2", 26, 23, "Passer-by",
         ["I've been trying to read the long sign for twenty minutes. I've got as far as 'Llan'.",
          "Locals call the place Llanfair PG. The ticket office sells you the short name. Cheeky."], "right", "wander")
    chat(z, "strait_sailor", "sailor", 36, 28, "Old Sailor",
         ["That's the Menai Strait. It's got fierce tides and a beautiful temper.",
          "The tide runs one way through the strait for six hours, then the other way. Dread to think what the fish make of it."], "right", "still")
    trainer(z, "ang_angler", "Angler Gwilym", "Angler", "angler", [("stalklet", 46), ("greyhaul", 47), ("heronarch", 47)],
            39, 29, "left", ["Bass, mackerel, and the odd boot. The strait's got a lot of everything. Come on."],
            "A fair catch. I'll throw you back, with a pat on the head.", "Fish where the tide pulls. And bring a flask.", 1320)
    trainer(z, "ang_hiker", "Hiker Elin", "Hiker", "hiker", [("cragchough", 47), ("coblynn", 46), ("adderking", 47)],
            31, 16, "left", ["I'm on the Anglesey Coastal Path. 130 miles round the island, and all of them are windy."],
            "Right. That's a moment for a flapjack.", "The coastal path goes right round the whole island. You can't get lost. You can only get windswept.", 1340)
    trainer(z, "ang_student", "Student Dilys", "Student", "student", [("tapknock", 46), ("coblynn", 47), ("pinewraith", 46)],
            16, 10, "right", ["I'm doing a dissertation on standing stones. Please don't lean on my data."],
            "Hm. I'll footnote that.", "Footnote one: the stones don't mind. Footnote two: the farmer minds.", 1300)
    trainer(z, "ang_warden", "Warden Hugo", "Warden", "warden_grunt", [("clownbill", 47), ("petrelash", 47), ("polartern", 48)],
            57, 11, "left", ["Welcome to the Bridge Heritage Experience! Toll: two pounds. Tolling's a hobby of mine."],
            "The Enclosure has a policy for this. It involves crying quietly.", "Telford's bridge has been free since 1941. I'm campaigning to bring the toll back.", 1360)
    trainer(z, "ang_birder", "Birdwatcher Mair", "Birdwatcher", "birdwatcher", [("hushwing", 47), ("polartern", 48), ("stalklet", 46)],
            8, 23, "right", ["Choughs, fulmars, and gannets over the South Stack cliffs. I'm half way to ticking off an owl."],
            "That's a good one. I'll note it in the logbook, between the gannet and the gull.", "The best time for birds is dawn. The second best is lunchtime, with a pasty.", 1380)
    z.d["edges"] = {"east": {"to": "llanberis", "offset": 0}, "west": {"to": "holyhead", "offset": 0}}
    z.d["spawn"] = [66, 11]
    wild(z, [("stalklet", 46, 47, 14, {}), ("heronarch", 47, 48, 6, {"weather": ["drizzle", "fog"]}), ("cragchough", 47, 48, 12, {}),
             ("clownbill", 46, 47, 10, {"time": ["day", "dawn"]}), ("polartern", 47, 48, 6, {"weather": ["gale", "frost"]}),
             ("petrelash", 47, 48, 8, {"weather": ["gale", "downpour"]}), ("hazeldoze", 46, 47, 12, {}),
             ("adderking", 47, 48, 8, {"time": ["dawn", "day"]}), ("coblynn", 47, 48, 8, {"time": ["dusk", "night"]}),
             ("hushwing", 47, 48, 10, {"time": ["night"]}), ("pinewraith", 47, 48, 6, {"time": ["dusk"]}),
             ("murmurant", 46, 47, 8, {"time": ["dusk", "dawn"]}), ("wispet", 47, 48, 4, {"weather": ["fog"]})])
    wild(z, [("stalklet", 46, 47, 30, {}), ("heronarch", 47, 48, 15, {}), ("greyhaul", 46, 48, 20, {}), ("pupplash", 46, 47, 15, {}),
             ("clawcastle", 47, 48, 15, {"time": ["night", "dusk"]})], "water")
    z.save(OUT + "/anglesey.json")


def holyhead(OUT):
    W, H = 60, 44
    z = Z("holyhead", "Holyhead", W, H, kind="town", region="north_wales", music="town_wales",
          weather={"drizzle": 28, "clear": 18, "gale": 18, "fog": 14, "sunshine": 12, "downpour": 10})
    z.d["stage"] = "docks"; z.d["town_id"] = "holyhead"
    z.rect(0, 0, W, H, "$")
    z.rect(14, 0, W - 14, 32, ".")
    z.border("T", 2, gaps=[(58, 22, 2, 3)])
    z.rect(0, 0, 14, H, "$"); z.rect(0, 32, W, 12, "$")
    z.scatter(14, 0, W - 14, 32, "P", 18, 3, only="T")
    # Holyhead Mountain, north-west
    for y in range(16):
        for x in range(14, W):
            z.hg[y][x] = max(0, 3 - int(math.hypot(x - 28, y - 7) / 3.2))
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    for (x, y, w, h) in [(17, 3, 6, 5), (32, 3, 6, 5), (17, 9, 7, 4), (32, 9, 7, 4)]:
        z.rect(x, y, w, h, "h")
    z.rect(27, 6, 3, 16, "#")
    for (x, y) in [(25, 4), (26, 5), (30, 5), (25, 7), (31, 7), (24, 11), (32, 11)]:
        z.set(x, y, "R")
    z.building(26, 3, 3, 3, "stone", "Roman Watchtower")
    z.sign(25, 9, "HOLYHEAD MOUNTAIN. 220 m of rock, the highest point on Anglesey, with a Roman lookout on top. In Welsh it's Mynydd Twr. On a clear day you can see Ireland. Today is not the clear day. Hope springs eternal.")
    # roads
    z.rect(18, 22, 42, 3, "="); z.rect(18, 21, 41, 1, ":"); z.rect(18, 25, 41, 1, ":")
    z.rect(27, 14, 3, 8, "=")
    for x in (22, 32, 42, 50, 56):
        z.prop("lamp_post", x, 21)
    for x in (24, 40, 46, 54):
        z.prop("lamp_post", x, 25)
    z.prop("phone_box", 20, 21); z.prop("post_box", 57, 25); z.prop("bench", 31, 21); z.prop("bench", 38, 25)
    # the ferry quay, west edge: a pier out into the sea
    z.rect(14, 12, 6, 20, ":")
    z.rect(8, 22, 12, 3, ":")
    z.d["ferry"] = {"x": 8, "y": 23, "route": "holyhead_dublin"}
    z.prop("boat", 4, 23, variant=0)
    z.prop("boat", 6, 29, variant=1); z.prop("boat", 8, 15, variant=1)
    z.prop("buoy", 3, 26); z.prop("buoy", 5, 18); z.prop("buoy", 9, 31)
    for y in (13, 17, 27, 30):
        z.prop("bollard", 14, y)
    z.prop("bollard", 9, 22); z.prop("bollard", 9, 24)
    z.building(15, 14, 8, 5, "white_render", "Ferry Terminal", door=3)
    z.rect(15, 19, 8, 1, ":")
    z.sign(13, 21, "THE FERRY QUAY. Boats leave here for Dublin. It's about three hours on a good day, and a good deal longer if the Irish Sea has an opinion. Take a flask. Take a good book.")
    # the harbour and its breakwater: 1.7 km of it, drawn short
    z.rect(18, 32, 31, 6, "~")
    z.rect(18, 31, 31, 1, "s")
    z.rect(14, 32, 4, 8, ":")
    z.rect(14, 38, 38, 2, ":")
    z.prop("lighthouse", 52, 38)
    z.prop("bench", 16, 34); z.prop("lamp_post", 16, 36); z.prop("lamp_post", 28, 38); z.prop("lamp_post", 40, 38); z.prop("bollard", 20, 38); z.prop("bollard", 34, 39)
    z.sign(15, 32, "THE BREAKWATER. 1.7 km (more than a mile) of granite, started in 1847 and finished in 1873, taking 26 years. For a time it was the longest in the world. It is also the best place in Wales to stare at the horizon and feel small.")
    for (x, y, v) in [(24, 34, 1), (30, 36, 1), (38, 34, 1), (43, 36, 0)]:
        z.prop("boat", x, y, variant=v)
    # Sanctuary and Corner Shop, north of the street
    z.building(31, 17, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(38, 17, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(34, 20, "holyhead_sanctuary", 5, 6, "up"); z.warp(40, 20, "holyhead_shop", 4, 5, "up")
    z.building(44, 17, 5, 4, "cream_render", "Maritime Museum")
    # south side: chippy, pub and terraces, then the station
    z.building(19, 26, 6, 4, "terrace", "Fish and Chips")
    z.building(26, 26, 7, 4, "red_brick", "The Ferry Inn")
    z.rect(19, 30, 14, 1, ":")
    z.building(45, 26, 6, 4, "slate_cottage", show_label=False)
    z.building(52, 26, 6, 4, "terrace", show_label=False)
    z.rect(45, 30, 13, 1, ":")
    station(z, 35, 27, 8, 3, "Holyhead Station")
    z.rect(34, 26, 1, 5, ":"); z.rect(43, 26, 1, 5, ":")
    z.prop("bench", 36, 29); z.prop("lamp_post", 41, 29)
    rail_guard(z, 40, 29, ["Holyhead. The end of the line, and the start of Ireland. Mind the gap, mind the gull.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    # Roman fort Caer Gybi and St Cybi's
    z.rect(43, 4, 16, 1, "W"); z.rect(43, 14, 16, 1, "W"); z.rect(43, 4, 1, 11, "W"); z.rect(58, 4, 1, 11, "W")
    z.rect(49, 14, 3, 1, ":")
    z.building(47, 6, 6, 5, "chapel", "St Cybi's Church")
    z.rect(50, 11, 1, 3, "#"); z.rect(50, 14, 1, 7, ":")
    z.rect(44, 5, 2, 3, "f"); z.rect(55, 5, 3, 3, "f")
    z.prop("bench", 46, 12); z.prop("bench", 55, 12); z.prop("oak", 45, 10); z.prop("oak", 56, 9, variant=1)
    z.sign(48, 12, "CAER GYBI. A Roman fort of the 4th century, one of the very few with its walls still around a working church. The sea once came right up to it. Cybi was a Cornish saint who founded the church, which means the Celtic world was an extremely good commuter belt.")
    z.rect(30, 13, 12, 3, ","); z.rect(52, 15, 5, 5, ","); z.rect(34, 31, 12, 1, ","); z.rect(52, 31, 6, 1, ",")
    scatter_props(z, "bush", 15, 3, 42, 28, 14, 5, avoid=(".",))
    scatter_props(z, "oak", 33, 22, 25, 8, 4, 6, avoid=(".",))
    # NPCs
    z.npc(id="hh_sailor", sprite="sailor", x=9, y=23, facing="up", move="still", script="sailor")
    script("holyhead", "sailor", say("Sailor", "The Ulysses sails for Dublin whenever the tide and the timetable agree. Fancy a crossing?") + [{"do": "ferry", "route": "holyhead_dublin"}])
    chat(z, "ticket_clerk", "villager_3", 19, 20, "Ticket Clerk",
         ["Three hours to Dublin. We have a lounge, a cafe, a shop, and a deck for people who've decided they'd like to be a figurehead.",
          "Holyhead is the main ferry port for the Irish Sea. On a good day it's a good deal calmer than the passengers."], "down", "still")
    chat(z, "old_fisherman", "angler", 22, 31, "Old Fisherman",
         ["The breakwater's the best place to fish. You can see the whole bay. And the whole bay can see you.",
          "In 1859 the Royal Charter was wrecked off Anglesey in a hurricane. That's when the weather forecast was invented, more or less. Admiral FitzRoy started the storm warnings that year."], "right", "still")
    chat(z, "welsh_local", "villager_5", 37, 22, "Local",
         ["Bore da! That's good morning. We say 'Caergybi' for Holyhead. 'Caer' is fort, and 'Cybi' is the saint. Fort of Cybi.",
          "Mind, it's mostly 'Holyhead' on the signs. But Caergybi is on the other half. If you can pronounce it, you can have a biscuit."], "down", "wander")
    chat(z, "museum_curator", "tour_guide", 47, 22, "Maritime Curator",
         ["The museum has models of the ferries that sailed from here. They look the same to me, but I'm told the funnels differ.",
          "Holyhead has had a harbour for two thousand years. The Romans, the Vikings, the Irish and the railway all came this way. We got good at waving."], "down", "still")
    chat(z, "fort_student", "student", 52, 12, "History Student",
         ["The fort walls at Caer Gybi are 4th-century Roman, nearly four metres thick in places. They still stand around the church.",
          "I wrote an essay about it. The marker said 'too much detail'. There's no such thing. There's only insufficient walls."], "left", "wander")
    trainer(z, "hh_angler", "Angler Idris", "Angler", "angler", [("selklet", 47), ("greyhaul", 48), ("plungebeak", 48)],
            15, 28, "right", ["The breakwater's mine on Thursdays. It's Thursday. You're in my spot."],
            "Well. Thursday's gone off me.", "Wet line, dry sandwich. The oldest rule in Holyhead.", 1400)
    trainer(z, "hh_hiker", "Hiker Nia", "Hiker", "hiker", [("polartern", 48), ("cragchough", 48), ("selkie", 48)],
            28, 10, "down", ["I climb the mountain every morning. It's 220 metres. It feels like Everest, in a gale."],
            "A summit's a summit. You've reached mine.", "From the top you can see Ireland, apparently. On a good day. In a good mood.", 1420)
    trainer(z, "hh_warden", "Warden Barnaby", "Warden", "warden_grunt", [("ternlet", 47), ("chipgull", 48), ("petrelash", 48)],
            50, 16, "down", ["Welcome to the Roman Heritage Experience! Toga hire: nine pounds. Dignity: not included."],
            "Veni, vidi, ... I'm going to need a minute.", "The Enclosure's keen on the fort. They want a gift shop where the barracks were. I'm told it'll be 'legion'.", 1440)
    z.d["edges"] = {"east": {"to": "anglesey", "offset": 0}}
    z.d["spawn"] = [30, 23]
    wild(z, [("selklet", 47, 48, 12, {"time": ["dusk", "night", "dawn"]}), ("selkie", 48, 49, 5, {"weather": ["fog", "drizzle"]}),
             ("ternlet", 47, 48, 12, {"time": ["day", "dawn"]}), ("polartern", 48, 49, 6, {"weather": ["gale", "frost"]}),
             ("chipgull", 47, 48, 14, {"time": ["day"]}), ("pierlord", 48, 49, 8, {"time": ["day", "dusk"]}),
             ("gannetling", 47, 48, 10, {"weather": ["clear", "sunshine"]}), ("plungebeak", 48, 49, 5, {"weather": ["gale", "clear"]}),
             ("clownbill", 47, 48, 10, {"time": ["dawn", "day"]}), ("cragchough", 47, 49, 10, {}),
             ("petrelash", 48, 49, 8, {"weather": ["gale", "downpour"]}), ("hushwing", 48, 49, 4, {"time": ["night"]})])
    wild(z, [("selklet", 47, 48, 20, {}), ("baskarr", 48, 49, 10, {"time": ["day"]}), ("greyhaul", 47, 49, 20, {}),
             ("gannetling", 47, 48, 20, {}), ("clawcastle", 47, 49, 15, {}), ("pierlord", 47, 49, 15, {})], "water")
    z.save(OUT + "/holyhead.json")
    sanctuary(OUT, "holyhead", "Holyhead", (34, 21))
    shop(OUT, "holyhead", "Holyhead", (40, 21))
    nurse("holyhead", ["Welcome to the Holyhead Sanctuary. Croeso! Last stop in Wales before the sea. Pop your team on the counter.",
                       "Right you are. Sit down, and don't look at the swell, it puts people off their tea.",
                       "All set. Safe crossing. Do take a bucket. For emergencies. Not yours, the gull's.",
                       "The Ark terminal. It was shipped here by ferry and has never quite forgotten.",
                       "No bother. Come in out of the wind, it's a Holyhead one."])
    shopkeeper("holyhead", "Croeso! Snares, soda bread for the crossing and ginger biscuits for the nerves.",
               "Hwyl! Safe crossing. Mind the gulls, they've seen your sandwiches.")
