# plan 5 group C, part 2: skye (route over the Skye Bridge), faerie_glen (hidden Cu-Sith glen), portree (harbour town).
from ie_common import *
from wcommon import _stand
import math

WX = {"drizzle": 30, "fog": 22, "clear": 20, "downpour": 10, "gale": 10, "sunshine": 8}


def build(OUT):
    skye(OUT)
    glen(OUT)
    portree(OUT)


def skye(OUT):
    W, H = 80, 48
    z = Z("skye", "Isle of Skye", W, H, kind="route", region="scotland", music="route_highlands", weather=WX)
    z.d["stage"] = "mountain"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.legend["q"] = {"tile": "water", "colour": "#34c4d4"}      # the Fairy Pools' blue
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(78, 20, 2, 3), (26, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 34, 3, only="T")
    hills(z, [(14, 9, 4, 12), (66, 8, 4, 14), (70, 38, 3, 12), (8, 34, 2, 6)])
    # the strait, the Skye Bridge and the mainland shore
    z.rect(36, 0, 16, H, "$")
    for y in range(H):
        z.set(35, y, "w") if 3 < y < H - 3 else None
        z.set(52, y, "w") if 3 < y < H - 3 else None
    z.rect(0, 0, 3, H, "$"); z.rect(3, 4, 1, H - 8, "w"); z.rect(4, 4, 1, H - 8, "s")
    z.rect(26, 0, 3, 3, "="); z.rect(26, 3, 3, 28, "=")
    z.rect(28, 20, 52, 3, "=")
    z.rect(36, 19, 16, 1, "W"); z.rect(36, 23, 16, 1, "W")
    z.rect(35, 20, 1, 3, "="); z.rect(52, 20, 1, 3, "=")
    for (x, y) in [(35, 19), (35, 23), (52, 19), (52, 23)]:
        z.set(x, y, "k")
        z.prop("lamp_post", x, y)
    # Eilean Ban, with its lighthouse, under the bridge
    z.rect(42, 25, 4, 3, "k"); z.rect(41, 25, 1, 3, "w"); z.rect(46, 25, 1, 3, "w"); z.rect(42, 28, 4, 1, "w"); z.rect(42, 24, 4, 1, "w")
    z.prop("lighthouse", 43, 26); z.prop("rock", 45, 27)
    z.prop("boat", 39, 30, variant=1); z.prop("boat", 48, 33, variant=1); z.prop("buoy", 40, 14); z.prop("buoy", 47, 12, variant=1); z.prop("boat", 44, 8, variant=1)
    # Eilean Donan (mainland sea loch)
    z.rect(54, 26, 20, 12, "$"); z.rect(54, 25, 20, 1, "w")
    z.rect(60, 29, 5, 4, "k"); z.rect(62, 24, 1, 6, "|")
    z.building(60, 29, 4, 3, "castle", "Eilean Donan", show_label=True)
    z.prop("rock", 64, 31); z.prop("buoy", 70, 30)
    # the Old Man of Storr and his neighbours
    spires = [(14, 8, 6), (14, 9, 6), (13, 9, 4), (15, 9, 4), (14, 10, 4), (11, 7, 5), (11, 8, 5), (18, 12, 4), (17, 6, 3)]
    for (x, y, h) in spires:
        z.set(x, y, "R"); z.hg[y][x] = h
    for y in range(5, 15):
        for x in range(8, 22):
            if z.g[y][x] == "k" and z.hg[y][x] >= 3:
                z.g[y][x] = "h"
    z.rect(14, 12, 1, 5, "#"); z.rect(5, 16, 22, 1, "#")
    # the fairy knowe (hidden hollow)
    z.rect(3, 6, 5, 5, "R"); z.rect(4, 7, 3, 3, "f")
    z.set(5, 10, "#"); z.rect(5, 11, 1, 5, "#")
    for y in range(6, 11):
        for x in range(3, 8):
            z.hg[y][x] = 1
    z.warp(5, 8, "faerie_glen", 15, 21, "up")
    z.prop("standing_stone", 4, 7, variant=0); z.prop("standing_stone", 6, 7, variant=1); z.prop("standing_stone", 4, 9, variant=2); z.prop("standing_stone", 6, 9, variant=0)
    z.sign(5, 12, "THE FAIRY KNOWE. Locals say a ring of stones is a doorway if you stand in the middle at dusk and mind your manners. The sign is not official. The manners are.")
    # the Fairy Pools: stepped blue pools in Glen Brittle
    def base(y):
        if y < 24: return 0
        if y < 27: return y - 23
        if y < 31: return 4
        if y < 35: return 3
        if y < 39: return 2
        if y < 43: return 1
        return 0
    for y in range(24, H):
        for x in range(0, 36):
            z.hg[y][x] = max(0, base(y) - max(0, x - 22))
    for k in range(4):
        z.rect(9, 28 + 4 * k, 10, 2, "q")
        z.rect(13, 30 + 4 * k, 2, 3, "q")
    z.rect(13, 25, 2, 3, "q"); z.rect(13, 42, 2, 4, "q")
    z.set(13, 27, "w"); z.set(14, 27, "w")
    for k in range(4):
        z.rect(8, 28 + 4 * k, 1, 2, "R") if k % 2 == 0 else None
    z.rect(19, 25, 8, 2, "#")
    z.rect(4, 30, 4, 12, ","); z.rect(20, 35, 3, 8, ","); z.rect(4, 44, 4, 1, "k")
    for (x, y) in [(10, 27), (17, 31), (11, 35), (18, 39), (8, 34), (19, 43), (10, 44), (16, 44)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    for (x, y) in [(6, 29), (21, 29), (6, 38), (22, 41), (5, 43)]:
        z.prop("birch", x, y, variant=(x * y) % 3)
    z.sign(23, 27, "THE FAIRY POOLS (Glen Brittle). A stream tumbles down the glen in a staircase of crystal-clear pools, blue and green because of the pale rock beneath. The water is about 8 degrees all year. Brave people swim. Sensible people take a photograph and have a hot chocolate.")
    # heather, bracken, trees on the high ground
    blob(z, 66, 10, 8, 5, "h", only="k", seed=11, jitter=0.4)
    blob(z, 30, 11, 5, 3, "h", only="k", seed=12, jitter=0.4)
    blob(z, 71, 40, 5, 4, ",", only="k", seed=13)
    blob(z, 30, 36, 4, 5, ",", only="k", seed=14)
    blob(z, 56, 14, 4, 2, ",", only="k", seed=15)
    scatter_props(z, "pine", 3, 3, 74, 20, 20, 16, avoid=("k",))
    scatter_props(z, "rock", 3, 3, 74, 40, 20, 17, avoid=("k", "h"))
    scatter_props(z, "bush", 3, 3, 74, 40, 12, 18, avoid=("k",))
    # buildings: a croft or two, the toll-free bridge cafe, mainland village
    z.building(30, 13, 5, 4, "slate_cottage", "Croft", show_label=False)
    z.building(30, 24, 5, 4, "white_render", "Bridge Cafe")
    z.building(56, 12, 5, 4, "white_render", show_label=False)
    z.building(63, 12, 6, 4, "stone", "Kyle Station Cafe")
    z.rect(30, 17, 3, 2, "#"); z.rect(32, 28, 1, 0, ":"); z.rect(32, 28, 1, 1, ":")
    z.prop("bench", 29, 29); z.prop("lamp_post", 28, 24)
    z.rect(58, 17, 1, 3, "#"); z.rect(65, 16, 1, 4, "#")
    # signs
    z.sign(34, 21, "THE SKYE BRIDGE. Opened in 1995 and a bit of a saga: it had tolls until 2004, when locals and a lot of very cross campaigners had them scrapped. It replaced a ferry that queued for hours. The bridge goes over an island, Eilean Bàn, which has a lighthouse and a rather smug otter.")
    z.sign(27, 19, "AN t-EILEAN SGITHEANACH · THE ISLE OF SKYE. Gaelic for 'the winged island', named for the shape of its peninsulas, or the Cuillin, or a Viking nickname. Everyone has a theory. Fàilte.")
    z.sign(15, 17, "THE OLD MAN OF STORR. A tall, thin pinnacle of basalt, about 50 metres, left behind when a huge landslip fell away from the hillside thousands of years ago. It's still standing. So is the fog. The best photos are taken from the left, in good weather. Bring a coat anyway.")
    z.sign(58, 21, "EILEAN DONAN. A castle on a tiny island where three sea lochs meet, linked by a stone bridge. The castle was blown to bits by the Royal Navy in 1719, and rebuilt in the 1900s. It has starred in more films than most actors.")
    # chatty people
    chat(z, "bridge_toll_man", "farmer", 33, 21, "Bridge Watcher",
         ["I remember the ferry from Kyle to Kyleakin. You queued, you waited, and a seagull ate your sandwich. The bridge fixed two of those.",
          "The toll was the worst bit. It cost more than a small car to cross a few hundred yards. A campaign called 'SKAT' got it scrapped in 2004. I joined, for the singing."], "left", "still")
    chat(z, "storr_guide", "tour_guide", 20, 14, "Storr Guide",
         ["The Old Man's about 50 metres high, a rock tower with a thin neck and a bad attitude. A path winds up the hillside, and you can see him from the top of the track. In sun, he looks gorgeous. In fog, he looks like a rumour.",
          "The hills here have names in Gaelic: An T-Sràcan, Bodach an Stòrr. 'Bodach' means old man. Whoever named him didn't hang about."], "down", "still")
    chat(z, "pool_swimmer", "student", 5, 33, "Wild Swimmer",
         ["It's 8 degrees. It's not 'refreshing'. It's a medical event with a nice view.",
          "A blue pool, a waterfall, and the Black Cuillin behind it. Honestly the water's so clear you can see every rock. Which makes it worse. You know how far you have to climb out."], "right", "wander")
    chat(z, "wild_camper", "hiker", 71, 17, "Wild Camper",
         ["Scottish access law lets you camp almost anywhere, as long as you leave no trace. No trace means no trace. Pack your rubbish. Don't light a fire. Be nice to the sheep.",
          "I came for a night. That was three weeks ago. The midges are the real landlords. I pay in blood."], "down", "wander")
    # trainers
    trainer(z, "skye_piper", "Piper Calum", "Piper", "piper", [("heilan", 74), ("goldeneyrie", 75), ("highlynx", 74)],
            33, 18, "down", ["A piper at a bridge! It's tradition. I played for the first car across in 1995. The car wasn't impressed."],
            "A fine tune. I'll play you across.", "The pipes sound best across water. That's why I stand near it. The ferries used to ask me to stop.", 2480)
    trainer(z, "skye_angler", "Angler Mairi", "Angler", "angler", [("bayrunner", 75), ("heronarch", 74), ("plungebeak", 75)],
            30, 22, "up", ["The mackerel are running in the Kyle. I've caught eighteen, and a boot. The boot was in better shape than the mackerel."],
            "A grand catch. You can have the boot.", "Skye's waters are cold and clear. The fish are very sensible and do not bite.", 2470)
    trainer(z, "skye_walker", "Hillwalker Fraser", "Hillwalker", "hiker", [("ptarmigan", 75), ("heilan", 75), ("highlynx", 75)],
            20, 15, "down", ["The Storr is an easy hike. 'Easy' here means you'll only need a map, a compass, a flask and a good sense of humour."],
            "Och, I'll sit down for a bit.", "The Cuillin ridge is for climbers. The Storr is for people who wish to stay alive and have lunch.", 2500)
    trainer(z, "skye_birder", "Birdwatcher Eilidh", "Birdwatcher", "birdwatcher", [("goldeneyrie", 76), ("plungebeak", 75), ("lochosprey", 75)],
            19, 33, "right", ["There are white-tailed sea eagles on Skye. They're the biggest bird of prey in Britain, with a wingspan of 2.4 metres. I'm in a very small tent. It's a little humbling."],
            "Beautiful. I'll write it down in the log, in pencil.", "They were wiped out in Britain by 1918, and brought back in the 1970s. That's what we call a comeback.", 2520)
    trainer(z, "skye_ghillie", "Ghillie Hamish", "Ghillie", "ghillie", [("heilan", 75), ("ermine", 75), ("capercaillie", 75)],
            62, 19, "down", ["On the mainland side, the deer stalkers have ghillies to carry the gear. I carry a flask, a map, a rifle-shaped sense of duty, and a lot of opinions."],
            "A fair fight. Away and boil the kettle.", "A good ghillie knows the hill, the weather and exactly when to say nothing.", 2490)
    z.d["edges"] = {"east": {"to": "inverness", "offset": 0}, "north": {"to": "portree", "offset": 0}}
    z.d["spawn"] = [68, 21]
    wild(z, [("highlynx", 74, 76, 10, {"time": ["night", "dusk"]}), ("goldeneyrie", 74, 76, 10, {"time": ["day"]}), ("ptarmigan", 74, 76, 10, {"weather": ["fog", "frost", "drizzle"]}),
             ("heilan", 74, 76, 12, {}), ("clownbill", 74, 76, 8, {"time": ["day"]}), ("plungebeak", 74, 76, 8, {"time": ["day", "dawn"]}),
             ("midgeswarm", 74, 76, 10, {"time": ["dawn", "dusk"]}), ("cragchough", 74, 76, 8, {}), ("forkwing", 75, 76, 6, {"time": ["day"]}),
             ("polartern", 74, 76, 6, {"weather": ["gale", "fog"]}), ("hushwing", 74, 76, 6, {"time": ["night"]})])
    wild(z, [("orcalet", 74, 76, 14, {}), ("orcaird", 75, 76, 6, {"time": ["dawn", "dusk"]}), ("bayrunner", 74, 76, 16, {}), ("selkie", 75, 76, 8, {"time": ["dusk", "night"]}),
             ("greyhaul", 74, 76, 14, {}), ("plungebeak", 74, 76, 14, {"time": ["day"]}), ("rillotter", 74, 76, 12, {}), ("kelpie", 75, 76, 6, {"weather": ["fog"]})], "water")
    finish(z)
    z.save(OUT + "/skye.json")


def glen(OUT):
    W, H = 30, 24
    z = Z("faerie_glen", "Faerie Glen", W, H, kind="route", region="scotland", music="route_highlands",
          weather={"fog": 40, "drizzle": 25, "clear": 20, "sunshine": 15})
    z.d["stage"] = "forest"
    z.legend["k"] = {"tile": "grass", "colour": "#6f9a5a"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2)
    z.scatter(0, 0, W, H, "P", 16, 5, only="T")
    hills(z, [(15, 6, 3, 8), (6, 12, 2, 5), (24, 13, 2, 5), (10, 17, 2, 4)])
    z.rect(14, 15, 3, 6, "#"); z.rect(14, 20, 3, 3, "#")
    # a little pond and rings of stones
    z.rect(19, 17, 5, 3, "~"); z.rect(18, 16, 1, 5, "w"); z.rect(24, 17, 1, 3, "w")
    for (x, y, v) in [(12, 4, 0), (18, 4, 1), (11, 8, 2), (19, 8, 0), (15, 3, 1)]:
        z.prop("standing_stone", x, y, variant=v)
    z.rect(13, 5, 5, 4, "f")
    z.rect(5, 15, 5, 4, ","); z.rect(21, 7, 5, 4, ","); z.rect(5, 4, 4, 4, ","); z.rect(18, 12, 5, 3, ",")
    scatter_props(z, "birch", 3, 3, 24, 18, 18, 33, avoid=("k",))
    scatter_props(z, "oak", 3, 3, 24, 18, 8, 34, avoid=("k",))
    z.prop("bush", 12, 14); z.prop("bush", 18, 14)
    z.warp(15, 22, "skye", 5, 9, "down")
    z.sign(14, 19, "THE FAERIE GLEN. Every hill here is a perfect green cone, like a giant pressed a thumb into the ground. It's real, a place on Skye with the same strange shape. Nobody knows who built it. The sheep do not say.")
    z.sign(16, 11, "A RING OF STONES. Please stay on the path, speak softly and don't take anything home with you except photos. A fairy hound watches over the glen. It has a great deal of patience and a great deal of teeth.")
    chat(z, "glen_wanderer", "villager_4", 12, 17, "Glen Wanderer",
         ["I came for a picnic and got the best view on Skye. Cone-shaped hills in every direction, and not a soul about. Just you, me, and a sheep with an air of superiority.",
          "My gran said the fairies live under those hills. She said to leave a bit of bread out. I left a sausage roll. It was gone in the morning. Maybe a crow."], "right", "wander")
    z.npc(id="cusith_spot", sprite="creature:cusith", x=15, y=5, facing="down", move="still", script="cusith", hide_if="caught_cusith")
    script("faerie_glen", "cusith", say("Cù-Sìth", "Placeholder: the story agent writes the Cù-Sìth's appearance and the legend encounter here."))
    z.d["edges"] = {}
    z.d["spawn"] = [15, 19]
    wild(z, [("wispet", 75, 76, 16, {}), ("brownie", 75, 76, 14, {"time": ["dusk", "night"]}), ("pixiedell", 75, 76, 10, {}), ("glowmite", 75, 76, 8, {"time": ["dusk", "night"]}),
             ("lanternis", 76, 76, 6, {"time": ["night"]}), ("tylwyth", 75, 76, 10, {"weather": ["fog", "drizzle"]}), ("gealhare", 75, 76, 10, {"time": ["dawn", "day"]}),
             ("prismite", 75, 76, 8, {"weather": ["sunshine", "clear"]}), ("pooka", 75, 76, 8, {"time": ["night"]})])
    finish(z)
    z.save(OUT + "/faerie_glen.json")


def portree(OUT):
    W, H = 60, 46
    z = Z("portree", "Portree", W, H, kind="town", region="scotland", music="town_scotland", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = "portree"
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(26, 44, 3, 2)])
    z.scatter(0, 0, W, H, "P", 28, 6, only="T")
    hills(z, [(8, 36, 3, 10), (52, 38, 2, 8)])
    z.height(24, 24, 8, 22, 0)
    # the harbour to the north and the quay
    z.rect(0, 0, W, 9, "$"); z.rect(2, 9, 56, 1, "w"); z.rect(2, 10, 56, 3, ":")
    z.rect(30, 9, 6, 1, "w")
    z.rect(44, 2, 2, 8, "|"); z.rect(12, 3, 2, 7, "|")
    for (x, y) in [(44, 2), (45, 2), (12, 3), (13, 3)]:
        z.prop("bollard", x, y)
    z.prop("boat", 40, 4, variant=1); z.prop("boat", 49, 5, variant=1); z.prop("boat", 17, 6, variant=1); z.prop("boat", 8, 5, variant=1)
    z.prop("boat", 53, 2, variant=1); z.prop("buoy", 22, 3); z.prop("buoy", 36, 6, variant=1); z.prop("buoy", 30, 2); z.prop("buoy", 26, 7)
    # the row of colourful houses on the quay
    x = 4
    for (st, w, lab, door) in [("white_render", 4, None, None), ("red_brick", 4, None, None), ("cream_render", 4, None, None),
                               ("shop", 5, "Corner Shop", 2), ("tudor", 4, None, None)]:
        z.building(x, 13, w, 4, st, lab, door=door, show_label=bool(lab))
        if lab == "Corner Shop":
            z.warp(x + door, 16, "portree_shop", 4, 5, "up")
        x += w
    x = 29
    for (st, w, lab, door) in [("sanctuary", 6, "Sanctuary", 3), ("slate_cottage", 4, None, None), ("white_render", 4, None, None),
                               ("red_brick", 4, None, None), ("cream_render", 4, None, None), ("stone", 4, None, None)]:
        z.building(x, 13, w, 4, st, lab, door=door, show_label=bool(lab))
        if lab == "Sanctuary":
            z.warp(x + door, 16, "portree_sanctuary", 5, 6, "up")
        x += w
    # streets
    z.rect(4, 17, 52, 3, "=")
    z.rect(26, 20, 3, 26, "=")
    for xx in range(6, 55, 6):
        z.prop("lamp_post", xx, 10)
    # upper town
    z.building(6, 22, 9, 4, "stone", "Royal Hotel")
    z.building(17, 22, 5, 4, "chapel", "Kirk")
    z.building(32, 22, 7, 4, "cream_render", "Aros Centre")
    z.building(41, 22, 6, 4, "white_render", show_label=False)
    z.building(49, 22, 6, 4, "red_brick", show_label=False)
    z.building(33, 30, 6, 4, "slate_cottage", show_label=False)
    z.building(42, 30, 5, 4, "white_render", show_label=False)
    z.building(17, 30, 6, 4, "terrace", show_label=False)
    z.rect(10, 26, 1, 1, "#"); z.rect(19, 26, 1, 1, "#")
    z.rect(30, 27, 6, 1, ":"); z.rect(20, 28, 6, 1, ":")
    z.rect(6, 28, 11, 4, ",")
    z.rect(44, 36, 8, 5, ",")
    z.rect(30, 38, 5, 4, ",")
    # bus stop with a joke
    z.rect(30, 21, 5, 1, ":")
    z.prop("bench", 31, 21); z.prop("lamp_post", 34, 21)
    z.sign(33, 21, "BUS STOP. Route 57, Portree to Uig. Next bus: 'Soon'. The timetable was last updated: 'Recently'. A handwritten note underneath says the bus has gone for a wee coffee. It is not a lie, merely an optimistic forecast.")
    z.prop("post_box", 36, 21); z.prop("planter", 38, 21)
    z.prop("bench", 20, 27); z.prop("planter", 8, 21); z.prop("planter", 13, 21); z.prop("planter", 43, 21)
    z.prop("lamp_post", 5, 21); z.prop("lamp_post", 56, 21); z.prop("lamp_post", 25, 21)
    scatter_props(z, "oak", 2, 27, 56, 17, 8, 40, avoid=("k",))
    scatter_props(z, "birch", 2, 27, 56, 17, 8, 41, avoid=("k",))
    scatter_props(z, "bush", 2, 20, 56, 24, 14, 42, avoid=("k",))
    z.prop("market_stall", 11, 11); z.prop("market_stall", 38, 11); z.prop("bench", 20, 11); z.prop("bench", 50, 11)
    # signs
    z.sign(27, 19, "PORT RÌGH · PORTREE. Gaelic for 'King's Port', after King James V, who landed here in 1540 to calm the island clans down. It took a lot of tea. The harbour is the colourful bit, painted so fishermen could find their way home in the fog. It still works.")
    z.sign(10, 20, "RAASAY AND THE MINCH. The island across the water is Raasay, and the sea beyond is the Minch, where the Blue Men of the Minch are said to live. They are storm spirits who swim out to wrecks and challenge the captain to a poetry contest. Finish the rhyme or lose your ship.")
    z.sign(34, 33, "AROS CENTRE. A theatre, a cinema and a gallery, with a view of the harbour. The Skye Gaelic Mod and the Highland Games are held in the village, and everyone, including the pipers, turns up in the rain.")
    # chatty people
    chat(z, "house_painter", "farmer", 12, 18, "House Painter",
         ["Every house on the quay is a different colour. They say it was so fishermen could find their own front door from the sea. In the dark. With a dram.",
          "Reds, yellows, blues. I keep a tin of each. When one house fades, the neighbour's the same shade by sunset. I'm retired. The paint is not."], "up", "wander")
    chat(z, "bus_waiter", "villager_6", 32, 21, "Bus Waiter",
         ["The 57 to Uig is due at ten past. I've been here since twenty to. It's ten past, and the bus is, as ever, in a different time zone.",
          "I'm a patient person. It's the only way to live on an island. The ferry's late, the bus is late, and the weather's pretty much right on time."], "right", "still")
    chat(z, "minch_sailor", "angler", 20, 11, "Old Sailor",
         ["The Blue Men of the Minch. They'd come up beside the boat in a storm and call out a line of poetry. You answered in rhyme, or the sea took your boat.",
          "My granda made me learn forty rhymes. 'Weather' and 'together'. 'Fish' and 'dish'. A sailor never knows. I haven't met one yet. I'm ready, though."], "down", "still")
    chat(z, "gaelic_teacher", "student", 48, 18, "Gaelic Pupil",
         ["Gaelic's spoken here every day, on Skye. I'm learning. 'Madainn mhath' is 'good morning', 'tapadh leibh' is 'thank you', and 'slàinte mhath' is 'good health'. I can say all three while sneezing.",
          "Portree has a Gaelic college, Sabhal Mòr Ostaig, nearby on Sleat. People come from all over to learn. They say the grammar is easy. It is not."], "down", "wander")
    trainer(z, "portree_fisher", "Fisher Ailsa", "Fisher", "angler", [("bayrunner", 75), ("plungebeak", 75), ("minchman", 75)],
            24, 11, "right", ["Langoustines, scallops, crabs. The creel boats go out at dawn, and the gulls get the leftovers. I'm tempted to join them."],
            "A good catch. The pot's empty. I'll go and set it again.", "Skye langoustines are among the best in the world. Don't tell the Spanish. They already know.", 2550)
    trainer(z, "portree_walker", "Hillwalker Ruaridh", "Hillwalker", "hiker", [("goldeneyrie", 75), ("ptarmigan", 75), ("heilan", 75)],
            27, 36, "up", ["I'm walking the Skye Trail, 128 kilometres from Rubha Hunish to Broadford. I've had three days of rain, two of wind and one of both. Perfect."],
            "Och. I need a sit down and a dram of tea.", "Rubha Hunish is the northernmost tip of Skye, with a lookout bothy that the walkers use. It has a lovely view and a draught.", 2540)
    z.d["edges"] = {"south": {"to": "skye", "offset": 0}}
    z.d["spawn"] = [27, 18]
    wild(z, [("minchman", 75, 75, 10, {"weather": ["gale", "downpour", "fog"], "time": ["dusk", "night"]}), ("redbreast", 75, 75, 12, {"time": ["dawn", "day"]}), ("plungebeak", 75, 75, 12, {"time": ["day"]}),
             ("clownbill", 75, 75, 10, {"time": ["day"]}), ("polartern", 75, 75, 8, {"weather": ["gale", "fog"]}), ("hushwing", 75, 75, 8, {"time": ["night"]}),
             ("warrender", 75, 75, 10, {}), ("pierlord", 75, 75, 10, {"time": ["day", "dusk"]}), ("forkwing", 75, 75, 6, {"time": ["day"]})])
    wild(z, [("minchman", 75, 75, 16, {}), ("bayrunner", 75, 75, 18, {}), ("selkie", 75, 75, 10, {"time": ["dusk", "night"]}), ("greyhaul", 75, 75, 16, {}),
             ("plungebeak", 75, 75, 14, {}), ("pierlord", 75, 75, 14, {}), ("orcalet", 75, 75, 6, {"time": ["dawn"]})], "water")
    finish(z)
    z.save(OUT + "/portree.json")
    sanctuary(OUT, "portree", "Portree", (32, 17))
    shop(OUT, "portree", "Portree", (18, 17))
    nurse("portree", ["Fàilte to Portree Sanctuary. Pop your team on the counter. We're the only building on the quay that hasn't got a fishing boat painted on it.",
                      "In you come out of the wind. We've the heating on, the kettle on, and the biscuits out. We're a full set.",
                      "All done. Tapadh leibh, that's 'thank you', and mind the slippery bit on the quay. It's always slippery. It's the whole quay.",
                      "The Ark terminal. It's connected to the harbour office, so if it beeps, check the tide.",
                      "No worries. Come back when you're ready. The weather, as usual, will have changed twice."])
    shopkeeper("portree", "Fàilte! Midge cream, waterproofs, shortbread, and a fine line in kippers. The kippers aren't for sale. They're for staring at.",
               "Mar sin leibh! Mind the quay. The seagulls here have a union.")
