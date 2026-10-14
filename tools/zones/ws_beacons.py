# beacons: the mountain route from St Davids east to Cardiff over Pen y Fan, in bad weather.
from wcommon import *


def build(OUT):
    W, H = 70, 40
    z = Z("beacons", "Brecon Beacons", W, H, kind="route", region="south_wales", music="route_mountain",
          weather={"downpour": 28, "gale": 24, "fog": 20, "drizzle": 15, "clear": 8, "frost": 5})
    z.d["stage"] = "mountain"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a6a5a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#8a8a4d"}
    z.rect(0, 0, W, H, "k")
    # terrain: two peaks, Pen y Fan (6) and Corn Du (5), smooth so every tile has a gentle neighbour
    for y in range(H):
        for x in range(W):
            d1 = math.hypot(x - 42, y - 15)
            d2 = math.hypot(x - 33, y - 17)
            z.hg[y][x] = max(0, 6 - int(d1 // 4.5), 5 - int(d2 // 4.2))
    z.border("R", 2, gaps=[(0, 18, 2, 3), (68, 18, 2, 3)])
    z.scatter(0, 0, W, H, "P", 50, 2, only="R")
    # heather and bracken
    for (x, y, w, h) in [(4, 4, 12, 7), (18, 5, 10, 6), (48, 4, 14, 7), (3, 29, 14, 7), (26, 30, 12, 6), (44, 28, 8, 8),
                         (60, 8, 7, 8), (60, 20, 7, 6), (12, 12, 10, 4), (46, 20, 8, 3)]:
        z.rect(x, y, w, h, "h")
    z.scatter(2, 2, W - 4, H - 4, "R", 130, 3, only="k")
    for (x, y, w, h) in [(14, 30, 10, 1), (14, 31, 1, 5), (36, 30, 12, 1), (48, 31, 1, 5), (60, 10, 1, 8), (62, 26, 6, 1), (16, 8, 8, 1), (52, 14, 1, 6)]:
        z.rect(x, y, w, h, "W")
    z.scatter(2, 28, 12, 10, "P", 14, 5, only="k"); z.scatter(54, 2, 12, 12, "P", 14, 6, only="k")
    for (x, y) in [(20, 34), (21, 34), (20, 35), (44, 34), (45, 34), (45, 35), (30, 6), (31, 6), (62, 14), (63, 14)]:
        z.set(x, y, "R")
    # the route: Storey Arms, up the Fan and over, down to the east
    for pts in ([(0, 18), (10, 18), (10, 27), (22, 27), (22, 22), (32, 22), (32, 17), (40, 17), (40, 15), (47, 15)],
                [(47, 15), (47, 24), (58, 24), (58, 18), (69, 18)]):
        path(z, pts, "#", 2)
    z.rect(0, 18, 2, 3, "#"); z.rect(68, 18, 2, 3, "#")
    # north escarpment, the cwm below, scree
    z.rect(34, 8, 14, 2, "^"); z.rect(30, 10, 4, 2, "^"); z.rect(48, 9, 3, 3, "^")
    z.rect(35, 10, 10, 1, "/"); z.rect(36, 11, 6, 1, "/")
    # tarn at the foot of the south side
    z.rect(54, 29, 7, 4, "~"); z.rect(53, 28, 9, 1, "s"); z.rect(53, 33, 9, 1, "s"); z.rect(53, 29, 1, 4, "s"); z.rect(61, 29, 1, 4, "s")
    z.prop("bench", 56, 27)
    # Storey Arms
    z.building(4, 21, 6, 3, "white_render", "Storey Arms")
    z.rect(6, 24, 1, 1, "#"); z.rect(7, 24, 3, 1, "#")
    z.prop("bench", 3, 24); z.prop("lamp_post", 10, 24)
    z.prop("bollard", 10, 21); z.prop("post_box", 3, 22)
    z.sign(9, 20, "STOREY ARMS. Start of the Pen y Fan path. It's mostly up. Mostly sideways in the rain.")
    z.sign(3, 17, "BANNAU BRYCHEINIOG (BRECON BEACONS). A National Park and an International Dark Sky Reserve. Stars, if the sky co-operates.")
    # summit
    z.prop("standing_stone", 42, 14, variant=1); z.prop("standing_stone", 43, 14, variant=2); z.prop("standing_stone", 42, 15, variant=0)
    z.sign(44, 16, "PEN Y FAN, 886 m. The highest peak in southern Britain. You are at the top. Everyone else is also at the top. Mind the elbow.")
    z.sign(34, 18, "CORN DU, 873 m. Pen y Fan's less famous sibling. Good wind, no queue.")
    z.sign(23, 23, "SARN HELEN. A Roman road, still here after 1,900 years. Which is more than can be said for your umbrella.")
    z.sign(12, 28, "WILD PONIES. Do not feed. Do not pet. Do not ask them for directions.")
    z.sign(59, 25, "CARDIFF 20 miles. Downhill, mostly. The rain will come with you.")
    z.sign(1, 16, "ST DAVIDS 40 miles. Behind you. Good luck with that.")
    # ponies as lumps of scenery
    for (x, y, v) in [(14, 24, 0), (16, 25, 1), (30, 26, 0), (52, 22, 1), (54, 21, 0), (28, 12, 2)]:
        z.prop("rock", x, y, variant=v)
    z.prop("standing_stone", 38, 22, variant=2); z.prop("standing_stone", 24, 20, variant=1)
    scatter_props(z, "bush", 3, 3, 64, 34, 18, 9, avoid=("k", "h"))
    # NPCs
    chat(z, "pony_trekker", "farmer", 14, 26, "Pony Trekker",
         ["The ponies in these hills are semi-wild. Welsh Mountain ponies. They're tougher than me and better at hills.",
          "I tried to ride one once. It just stood there until I got off. Boss behaviour."], "up", "wander")
    chat(z, "stargazer", "student", 8, 17, "Stargazer",
         ["This is an International Dark Sky Reserve. On a clear night you can see the Milky Way. On a normal night, my umbrella.",
          "Since 2013, they've been very strict about streetlights. The sheep don't mind."], "right", "still")
    chat(z, "storey_instructor", "villager_2", 5, 25, "Instructor",
         ["Storey Arms started as a coaching inn. Now it's an outdoor centre. Kids come to learn about the hills.",
          "I teach 'Don't Wear Cotton'. Everyone remembers it by lunch. Usually in the bog."], "down", "still")
    chat(z, "shepherd", "farmer", 27, 24, "Shepherd",
         ["Pen y Fan is the highest point in southern Britain. Eight hundred and eighty-six metres.",
          "Soldiers train on these hills. Fan Dance, they call it. I just call it Tuesday with sheep."], "down", "wander")
    chat(z, "lost_walker", "hiker", 36, 20, "Lost Walker",
         ["Which way is Cardiff? East, everyone says. The mist says 'upwards' and 'maybe'.",
          "I've been on this path three hours. It's about forty metres long. I'm very thorough."], "left", "wander")
    # trainers
    trainer(z, "rhodri", "Fell Runner Rhodri", "Fell Runner", "jogger", [("forkwing", 34), ("gwyllgi", 34), ("zigzlet", 33)],
            14, 17, "down",
            ["Don't mind me! Training for the Fan Dance! I have to run up and down this thing in a rucksack!",
             "Hold on, I'll fit you in between intervals."],
            "My splits are ruined. Cheers.", "Two hundred metres of ascent. Then you start.", 740)
    trainer(z, "mair", "Hiker Mair", "Hiker", "hiker", [("peatmonarch", 35), ("sphagnet", 34), ("kitelet", 34)], 24, 25, "right",
            ["Right! Waterproofs? Gaiters? Map? Compass? Emergency cheese?", "No? Then we need to talk. Battle talk."],
            "Fair play. Take the cheese.", "Never go up a mountain without cheese. Rule one.", 760)
    trainer(z, "dai", "Rugby Player Dai", "Rugby Player", "rugby_player", [("adderking", 35), ("gwyllgi", 35), ("forkwing", 34)],
            36, 21, "right",
            ["Hill sprints! The coach says they build character. Mine's built already."],
            "Offside. Fair play.", "Back to hill sprints. My calves have gone on strike.", 780)
    trainer(z, "gwilym", "Warden Gwilym", "Warden", "warden_grunt", [("gwyllgi", 34), ("peatmonarch", 35)], 45, 17, "down",
            ["Welcome to the Summit Heritage Experience! Selfie permit: five pounds!",
             "It's a beautiful view for free but it's CURATED for five pounds."],
            "Refunds are processed within six to eight weeks.", "I've been told 'permit' is not a legal term. We're consulting.", 720)
    trainer(z, "carys", "Birdwatcher Carys", "Birdwatcher", "birdwatcher", [("kitelet", 35), ("forkwing", 36), ("gwyllgi", 35)],
            52, 26, "left",
            ["I'm waiting for red kites. They're a Welsh success story. Almost lost, then brought back."],
            "Hm. A rare sighting.", "There. A red kite. Or a bin bag.", 760)
    z.d["edges"] = {"west": {"to": "st_davids", "offset": 0}, "east": {"to": "cardiff", "offset": 0}}
    z.d["spawn"] = [2, 19]
    wild(z, [("gwyllgi", 34, 36, 22, {"time": ["dusk", "night"]}), ("kitelet", 33, 35, 26, {"time": ["dawn", "day"]}),
             ("sphagnet", 33, 35, 24, {"weather": ["drizzle", "downpour", "fog"]}), ("zigzlet", 34, 36, 18, {"time": ["dusk", "night"]}),
             ("kitelet", 34, 36, 16, {"weather": ["gale"]}), ("sphagnet", 34, 35, 14, {}), ("gwyllgi", 35, 36, 10, {"weather": ["fog"]}),
             ("zigzlet", 33, 35, 10, {"time": ["dawn", "day"]})])
    z.save(OUT + "/beacons.json")
